# ALRT for Apple Watch: how to test it

Date: 7 October 2026. Branch: `claude/cool-ritchie-zf2xey`. TEST only. The production app, production signing lanes and production backend were not touched.

## 1. What you get

A small ALRT app on the Apple Watch that works with the ALRT app on your iPhone.

| On the watch | What it does |
|---|---|
| **Your circles** | Each circle with one coloured word: "SOS active", "Check-in requested", "Waiting for responses", "No pending requests". Shows when the iPhone last updated it, and "iPhone not connected" when it is not. |
| **Check in to Home** | One big green button. Sends a check-in to that circle only. No location is ever sent from the watch. |
| **SOS** | Shows who it will go to (the server's own list), then a 3-second hold with a filling ring and a tick each second. Sent with no location. To end an SOS, use the iPhone. |
| **Answers you can trust** | "Checked in to Home · 9:41 pm" appears only after the server confirms. Otherwise "Not sent" (with the reason) or "Not confirmed" with Try again. Try again can never send it twice. |
| **Notifications** | Check-in requests and SOS alerts appear on the wrist as today. With the watch app installed they open the right circle. |
| **Signed out** | Signing out on the iPhone wipes the watch immediately. |

How it compares: Life360's watch app offers one-tap check-in and one-tap SOS but needs a cellular watch through Family Setup and shows everyone's location. ALRT keeps the simple one-tap check-in, adds a deliberate hold and a recipient list before an SOS, never tracks anyone from the wrist, and works with any GPS Apple Watch paired to your iPhone.

## 2. What is in the build

| Layer | Files | Tested here |
|---|---|---|
| Watch app (SwiftUI, watchOS 10+) | `frontend/ios/AlrtWatch/*` | Compiled and signed by the iOS Dev TestFlight workflow (see §5) |
| iPhone bridge (Swift) | `frontend/ios/Runner/AppDelegate.swift` (`WatchSessionBridge`) | Same |
| iPhone bridge (Dart) | `frontend/lib/features/wearable/*`, hook in `family_widget_sync.dart`, `app.dart` | `flutter analyze` clean; 12 new unit tests + 14 existing widget tests pass |
| Backend | `clientRequestId` on check-in and SOS, circle check on answered asks, `WEARABLE_ACTIONABLE_PUSH` flag (default off), migration `20261007000000_wearable_client_request_id` | `verify_wearable_actions.ts` 12/12 against real Postgres; existing family/SOS scripts unchanged (three scripts fail identically before and after this change; see §6) |
| Signing / CI | `fastlane/Fastfile` (`ci_certs_dev`), `ExportOptionsCI-dev.plist`, `.github/workflows/ios-test-testflight.yml`, `scripts/add_watch_target.rb` | CI run |

## 3. Before you test

1. **Hardware:** your iPhone plus any Apple Watch (SE or newer, watchOS 10 or later) paired to it. No cellular plan needed.
2. **The build:** TestFlight → "ALRT Dev" → install the newest build. Then on the iPhone open the **Watch** app → scroll to **Available Apps** → **ALRT** → **Install** (or turn on "Automatic App Install").
3. **Two TEST accounts** in one circle (your iPhone plus a second phone, Android is fine) so there is someone to check in to and someone to receive an SOS.
4. **Backend (optional for a first look):** the watch works against the current TEST backend straight away. Duplicate-tap protection and the circle check need the backend commit deployed to `api-test.safetyalrt.com` with the normal rollout (it includes one additive migration, so not `--no-new-migrations`). Leave `WEARABLE_ACTIONABLE_PUSH` off for the first round.

## 4. Test checklist (record each as device pass / device fail / blocked)

| # | Do this | Expect |
|---|---|---|
| 1 | Open ALRT on the iPhone, then the watch app | Your circles appear with their state and "Updated <time>" |
| 2 | Second phone asks you to check in | Watch row says "Check-in requested"; notification on the wrist |
| 3 | Tap the circle → **Check in to Home** | "Sending…" then "Checked in to Home · <time>"; second phone sees your check-in; no location shown for it |
| 4 | Turn the iPhone's Wi-Fi and mobile data off, check in from the watch | "Not sent", iPhone is offline. Nothing arrives later by itself |
| 5 | Put the iPhone out of Bluetooth range, check in | "Not sent", iPhone isn't connected |
| 6 | Force-quit ALRT on the iPhone, lock it, check in from the watch | Still works (the watch wakes the app). If it says "Not sent" here, note it: this is the one behaviour that can only be proven on a device |
| 7 | SOS: open SOS on the watch | "Goes to <names>. No location is sent from your watch." |
| 8 | Hold for 1 second and let go | Ring resets, nothing sent |
| 9 | Hold for 3 seconds | "SOS sent to Home"; second phone gets the SOS with no location; the watch row turns to "Your SOS is active" |
| 10 | End the SOS on the iPhone | Watch row goes back to normal |
| 11 | Circle where nobody else is a member | SOS screen says nobody can get it; no hold button |
| 12 | Sign out on the iPhone | Watch says "Sign in on your iPhone"; no circles left |
| 13 | VoiceOver on the watch | Rows read as name + status; SOS reads "Hold for 3 seconds to send SOS" |

After the backend is deployed:

| # | Do this | Expect |
|---|---|---|
| 14 | Step 6 with "Not confirmed", then Try again | One check-in on the second phone, not two |
| 15 | Set `WEARABLE_ACTIONABLE_PUSH=true` on TEST, ask for a check-in | The wrist notification shows "Open circle", which opens that circle |

## 5. Rollback

- Watch app: remove it from the watch (Watch app on iPhone → ALRT → turn off "Show App on Apple Watch"), or install an earlier TestFlight build.
- Backend: `WEARABLE_ACTIONABLE_PUSH` off restores today's pushes exactly. The `clientRequestId` columns are nullable and unused by older apps.

## 6. Known limits and next steps

- **Not yet built:** watch-face complication, answering "I've seen this" to someone else's SOS from the wrist, journeys on the watch, nearby-alert summaries (Citizen-style), Wear OS.
- **Production:** the production signing lane (`ci_certs`) and production export options do not yet include the watch app. Before a production release, add `com.safetyalrt.alrt.watchkitapp` the same way as the dev one. Until then a production iOS build from this branch would stop at signing.
- **Background wake (test 6)** is the one behaviour that cannot be proven without a device.
- **Pre-existing script failures, not caused by this change:** `verify_family_push_delivery` (expects old "is safe" wording), `verify_family_location_consent` (a live-SOS case) and `verify_v1_access_model` (needs `REVENUECAT_WEBHOOK_AUTH` locally) fail the same way on the code before this change.

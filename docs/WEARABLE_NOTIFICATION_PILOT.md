# Wearable notification pilot (Milestone 1): runbook

Status: **code complete on the branch, not deployed, not device-tested.** This is the implementation of Milestone 1 in `WEARABLES_AUDIT_AND_PLAN.md` §4.5 and §9. Nothing here changes the TEST or production servers until the rollout steps below are run, with Sarah's approval, and nothing in the phone app changes behaviour until the server flag is on.

## What it does

With the backend flag `WEARABLE_ACTIONABLE_PUSH=true`, exactly two push types change shape:

| Type | Before | After (flag on) |
|---|---|---|
| `familyCheckInRequest` | System-drawn notification, no buttons | Android: data-only; the app draws it with **Check in to <circle>** and **Open on phone**. iOS: the same alert plus category `ALRT_CHECKIN_REQUEST` |
| `familySos` | System-drawn notification, no buttons | Android: data-only; the app draws it with **Open on phone** only. iOS: the same alert plus category `ALRT_SOS_RECEIVED` |

Every other push type is untouched. Both pilot pushes now name the circle in their title or body, flag on or off.

**Check in to <circle>** runs on the phone in the background (no screen opens), posts a check-in with **no location** for that request only, and then shows a follow-up notification in one of four states: Checked in (server confirmed), Already checked in, Not sent (with the reason), or Could not confirm (sent, no answer, not retried). A Wear OS watch paired to the phone shows the phone's notification and its buttons; the tap runs on the phone.

## Files changed

Backend (`backend/`):

- `src/utils/config.ts`: `wearableActionablePush` from `WEARABLE_ACTIONABLE_PUSH` (default false).
- `src/services/notification.service.ts`: `wearablePushFlags`, `wearableCategoryFor`, and the per-platform shape in `sendPushNotificationToTokens` for the two types.
- `src/services/family.service.ts`: circle name on the check-in request and SOS pushes; `clientKey` deduplication and the cross-circle `requestId` check in `createCheckIn`; `createCheckInRow` extracted.
- `src/utils/client_key.util.ts` (new): claim, complete, release of a client key in the cache with an in-process fallback. No migration.
- `src/validators/family.validator.ts`: optional `clientKey` on `POST /api/family/check-in`.
- `src/controllers/family.controller.ts`: a deduplicated repeat never stamps a second snapshot.
- `src/scripts/verify_family_push_delivery.ts`: §7, seven new checks (flag off shape, flag on shapes for both types, other types unchanged, duplicate key, cross-circle refusal).
- `.env.default`, `.env.test.example`: the flag, documented.

App (`frontend/`), build 1.0.5+52:

- `lib/features/notification/services/wearable_push.dart` (new): pure rules, unit-tested.
- `lib/features/notification/services/wearable_push_handler.dart` (new): the background message handler, the background action handler, `WearableNotifications`, `WearableCheckInAction`.
- `lib/features/notification/services/local_notification_service.dart`: pilot actions when the app is open, iOS categories, background response registration.
- `lib/features/notification/services/notification_service.dart`: foreground action wiring; reloads the circle after a check-in.
- `lib/others/app_bootstrap.dart`: registers the background handler; stores the resolved API base URL for the background isolate.
- `lib/features/family/...` and `lib/api/rest_client*.dart`: `clientKey` threaded through to the request.
- `lib/features/profile/providers/profile_provider.dart`: answered-request cache cleared on sign-out and account deletion.
- `lib/features/shared/enums/shared_prefs_key_types.dart`: two keys.
- `android/app/src/main/AndroidManifest.xml`: the `ActionBroadcastReceiver` for background actions.
- `test/wearable_push_test.dart` (new).

## What is verified, and what is not

| Claim | Status |
|---|---|
| Backend compiles | `npx tsc --noEmit` clean in every touched file (the remaining errors are pre-existing and come from newer Express type packages in this environment) |
| Backend push shapes and dedupe | `verify_family_push_delivery.ts` §7 written; **not yet run against a TEST database** |
| App compiles | **Not compiled here** (no Flutter toolchain). `android-test.yml` runs `flutter analyze` and `flutter test` on dispatch |
| App unit rules | `test/wearable_push_test.dart` written; runs in CI |
| Phone behaviour | **Untested on hardware** |
| Watch behaviour | **Untested on hardware** |
| iOS action handling | **Unverified.** The category is registered and the server sends it, but whether iOS hands a background action on a server-drawn push to the app needs a device; the iOS TEST build pipeline only began producing builds in October |

Nothing in the table above is proof of delivery or of reliable emergency behaviour. Only the device checklist below is.

## Rollout on TEST (needs approval before each step)

1. Build the app from this branch with `android-test.yml` (either billing mode). Install on phone A (paired to the watch) and phone B.
2. Deploy the backend from this branch with the rollout script in `--no-new-migrations` mode (there is no migration). The verify stage runs `verify_family_push_delivery` with its new §7.
3. On the TEST host, set `WEARABLE_ACTIONABLE_PUSH=true` in `.env.test` and restart the app container. This is the only switch. Older app builds still receive the two types and draw them from the data block without buttons.
4. Run the device checklist.

Rollback: set `WEARABLE_ACTIONABLE_PUSH=false` and restart. No redeploy, no migration, no app change needed; the app's new code is inert without the flag.

## Device checklist (record each as phone-tested pass, phone-tested fail, awaiting device, or blocked)

1. B asks A to check in. A's phone is locked, app closed. Within 30 s the watch shows "Check-in requested · <circle>" with "Check in to <circle>" and "Open on phone".
2. Tap "Check in to <circle>" on the watch. The request notification goes away; a follow-up reads "Checked in to <circle> · <time> · no location sent". B's phone shows "A checked in" with no location. Exactly one check-in row on TEST.
3. Tap the same button again before step 2's follow-up is dismissed, or from the phone and the watch within two seconds: one row, one push to B, and a follow-up "Already checked in" on the second attempt if it reached the handler.
4. Airplane mode on A, then tap: "Check-in to <circle> not sent · Your phone is offline." Nothing arrives later without a further tap.
5. Kill the network after the tap but before the answer (toggle Wi-Fi mid-request): "Could not confirm your check-in to <circle>" and no automatic retry beyond the one same-key repeat; open ALRT and confirm one row at most.
6. A is in two circles with open asks: the button names the right circle and only that circle's ask is answered.
7. B raises an SOS: A's watch shows "<name> triggered SOS" with "<circle> · Open ALRT…" and "Open on phone" only; nothing is recorded until A opens it on the phone.
8. Do Not Disturb on A's phone and watch: the check-in request stays quiet; the SOS follows the platform's rules. Record what happened, not what was expected.
9. Sign out on A: the follow-up and request notifications are gone; a tap on a stale mirrored notification reads "Open ALRT and sign in first".
10. Every item of `TEST_BUILD_51_ACCEPTANCE.md` still passes.

## Not in this milestone

- The device-status card and the "Test my alerts" extension (Phase 0 items 3 and 4 in the plan).
- Wear OS dismissal sync (`setDismissalId`), which flutter_local_notifications does not expose.
- A persisted `clientKey` column (needs a migration; the cache claim covers the pilot).
- Any watch-side code, any glasses code, any scheduler change.

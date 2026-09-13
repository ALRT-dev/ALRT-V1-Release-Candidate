# ALRT on the wrist and on glasses: audit and phased plan

Date: 13 September 2026. Author: Claude Code session for Sarah (safetyalrt.com).
Status: **audit and plan only. Nothing was built, deployed, purchased or configured.** No production, billing, store, scheduler, credential or database setting was touched. The only writes in this session are this document and its companion web page.

This document is written to be read top to bottom by Sarah, and to be handed to an engineer as-is. Every claim about code cites a file, a branch or a commit. Every claim about a platform cites the official page it was checked against on 13 September 2026, or says plainly that it could not be checked from this environment.

---

## 0. The short version

1. **The phone release is further along than the older repos suggest, and it lives in one place.** The current line is `ALRT-dev/ALRT-V1-Release-Candidate`, branch `test`, a monorepo (`frontend/`, `backend/`, `admin/`, `askalrt/`). The newest app build is **1.0.5 (51)**, commit `7eacfea`, built by GitHub run 34541544658 on 10 September 2026. Nothing newer exists in any of the twelve repositories. The deployed TEST backend is `https://api-test.safetyalrt.com`, recorded as verified at commit `f1f6b92` on 10 September; builds 50 and 51 changed the app only, so TEST is current for build 51. I could not reach that host from this sandbox (outbound HTTPS to it is blocked), so "deployed" is taken from the repository's own rollout record, not observed.
2. **Build 51 has not been accepted on a phone.** The repository's own record (`V1_RECONCILIATION_REPORT.md` §36.7) says no phone-checklist item for builds 44 to 51 has been run from that environment, and the hardware columns (push delivery, lock screen, sound, vibration, widget rendering) are untested. There is **no iOS TEST build at all** (the iOS TestFlight workflow has never run), the iOS time-sensitive entitlement is absent, and the iOS widget target is not in the Xcode project. These stay open and are listed in §2 so wearable work cannot hide them.
3. **There is no wearable code anywhere.** `watchinterface` is a design handoff (an HTML click-through of 13 Wear OS screens plus specs written against a Firestore model the real backend does not use). `glasses` is a README on `main` plus an unmerged Android XR Kotlin skeleton on one branch. `occulo` and `mattv2` are empty. The phone app has two reusable building blocks that matter: a text-to-speech alert reader and a tap-to-talk voice input, both on the release line.
4. **Recommendation: start with a phone-connected companion on whichever watch matches the phone you test with.** Google and Samsung watches only pair with Android phones; Apple Watch only pairs with iPhone. The first milestone is a **notification pilot with no watch app at all**: make the phone's existing check-in and SOS pushes reach the wrist with a clearly named "Check in to <circle>" action, and prove delivery on real hardware. That costs one to two engineering weeks plus device testing and answers the biggest unknown (whether wrist delivery is reliable) before a watch app is written. One finding shapes it: today a push that arrives while the app is closed carries **no action buttons on either platform** (the server sends a system-drawn notification with no APNs `category`, and Android has no background handler), so the pilot's first task is a small, flagged change to how two push types are shaped.
5. **Glasses are a second phase and are gated on access, not on our code.** Meta's Wearables Device Access Toolkit is a developer preview (v0.9) for camera, microphone and speaker on audio glasses, with display support on Meta Ray-Ban Display opened in May 2026; custom "Hey Meta" commands are not available to third parties, and publishing is reported as limited to selected partners until general availability. Android XR glasses have SDK previews and emulators but no consumer hardware yet. Meta's developer site could not be fetched from this sandbox, so those points must be re-confirmed on `developers.meta.com` before any glasses milestone is approved.
6. **I need four answers before the first milestone is chosen:** the phone model and OS version you test with, the watch model (if any) you own or can borrow, the glasses model (if any), and whether a Mac with Xcode is available. The hardware choice is yours; the plan below is written for both paths and does not pick one.

---

## 1. What the watch and glasses experiences would be, in plain words

### On the wrist (companion to the phone)

The watch is a **glance-and-act** surface for the circle you have chosen on the phone. It never becomes a small phone.

- The tile or complication shows one line: the selected circle's state ("Home · 1 check-in request", "Work · quiet", "SOS active · Home"). Grey when nothing needs you, coloured when something does, with a word next to the colour so it never relies on colour alone.
- A check-in request arrives on the wrist naming **who asked and which circle** ("Amy and Tom asked you to check in · Home"). One large button reads **"Check in to Home"**. It sends **no location** by default. The watch shows "Sending…", then "Checked in to Home · 9:41" only after the server has confirmed it. If the phone is out of reach, the watch says "Not sent · phone not connected" and never pretends.
- SOS is a deliberate hold with a visible ring, then a confirmation, then "Sending…" and "SOS sent to Home · 3 of 4 notified" only once the server answers. While an SOS is live the wrist shows who has acknowledged and offers "Stand down", which asks first.
- A journey shows time remaining, "Extend 1 hour" and "Finish".
- Alerts show a short summary with the source and the update time ("DFES · updated 12 min ago"). Full detail stays on the phone.
- Purchases, account setup, circle administration and maps stay on the phone.

### On glasses (second phase)

Audio-only glasses (Ray-Ban Meta, Oakley Meta) can **speak** what the phone already knows: an alert summary with its source, a check-in request naming the circle, and a spoken "Check in to Home? Say yes or press and hold" confirmation. Display glasses (Meta Ray-Ban Display, future Android XR glasses) can add a small glanceable card. Everything still goes through the phone app; the glasses have no account, no session and no independent connection. Spoken output is opt-in, respects the phone's silent switch and Do Not Disturb, and never reads out another person's location.

What the glasses will **not** do in the initial scope: no continuous recording, no automatic reporting, no AI hazard detection, no custom "Hey Meta" commands, no always-on listening, no arbitrary overlays, no "safe route" guidance.

---

## 2. Baseline: what exists today, with statuses kept apart

Statuses used throughout: **Code** (implemented in a branch), **Tests** (automated tests pass in CI), **TEST** (deployed to the isolated TEST backend), **Device** (physically tested on a phone or wearable). A tick in one column never implies the next.

### 2.1 The release line

| Item | Evidence | Code | Tests | TEST | Device |
|---|---|---|---|---|---|
| App 1.0.5+51 (Android, dev flavour, test_store and bypass artifacts) | `frontend/pubspec.yaml` on `test`; commit `7eacfea`; run 34541544658; `TEST_BUILD_51_ACCEPTANCE.md` | yes | `flutter analyze` and `flutter test` green on the runner | n/a (app) | **not run on a phone** (§36.7) |
| Backend at `f1f6b92` on `api-test.safetyalrt.com` | `V1_RECONCILIATION_REPORT.md` §36 "TEST verified at f1f6b92 (10 September 2026, 00:02:59Z)"; rollout script revision 14 | yes | verify scripts (consent 40/40, eleven regression scripts, `verify_hazard_push_dedupe` 7) | yes, per record; **not reachable from this sandbox** | n/a |
| Scheduled jobs on TEST | §36.8 "Scheduler OFF on TEST"; switch `RUN_SCHEDULED_JOBS_IN_TEST` defaults to `false` (`backend/src/utils/config.ts:48-49`, `scheduled_jobs.util.ts:16-23`) | code exists | n/a | **off** | SOS 4-hour auto-end, expiry sweeps and daily reminders **untested** |
| Server-side saved-location limit | §36.8, `BILLING_ENABLED=false` on TEST | yes | `verify_saved_location_limit` | off | n/a |
| iOS TEST build | `.github/workflows/ios-test-testflight.yml`; GitHub API returns 404 for its runs; acceptance guide "no iOS TEST build exists" | workflow exists | n/a | **never produced** | none |
| iOS time-sensitive entitlement | acceptance guide "iOS: what is blocked and why" | server sends `interruption-level: time-sensitive`; entitlement absent | n/a | n/a | urgent pushes arrive as ordinary alerts on iOS |
| iOS home-screen widget | `frontend/ios/AlrtWidget/*` present; target not in `Runner.xcodeproj` | Swift exists | model tests | n/a | **blocked** |
| Push delivery, lock screen, sound, vibration | acceptance guide item 12; report §36.7 | yes | `verify_family_push_delivery` (11) proves eligibility and message shape only | yes | **untested on hardware** |
| Notification-settings decisions (a) to (c) | acceptance guide item 7 | n/a | n/a | n/a | **awaiting product decision** |
| Known duplicate: a public alert can arrive twice when it is both in a saved area and near a family member | report §36 build 47, "known and unfixed" | open | | | |

Two further facts about the release line that shape wearable work:

- The launched store app is **1.0.4+34** (archived as `ALRT-dev/v3`); the release line is 1.0.5. The wearable plan must not change what 1.0.5 ships.
- The report refers to `ALRT-dev/widget` as the frontend baseline that fed the monorepo. No repository of that name is accessible to this session; `ALRT-dev/frontendV2` branch `claude/safety-alert-repo-audit-8exgvn` (1.0.5+35, last commit `1e1d9cf`, 20 August 2026) matches its described content and CI run history. Please confirm whether `widget` was renamed or deleted.

### 2.2 Historical repositories

| Repository | What it is | Latest | Verdict for wearables |
|---|---|---|---|
| `ALRT-V1-Release-Candidate` `main` | Four planning documents (release plan, source registry, pipeline, backlog) | `1d2271f`, 22 Aug | Planning only; `test` branch is the code |
| `ALRT-V1-Release-Candidate` `claude/test-app-audit-p5djd2` | Ancestor of `test` (fully merged) | `8e0f34f`, 7 Sep | Superseded |
| `ALRT-V1-Release-Candidate` `claude/alrt-v1-rc-audit-a3gmai` | Stage 9B to 12 work; **not** an ancestor of `test` (`git merge-base` confirms); `test` merged it via `ea85cd3` then diverged | `fc87fb1`, 5 Sep | Do not merge again |
| `frontendV2` | Older Flutter app; `main` at 1.0.3+33 (26 Jul); audit branch at 1.0.5+35 (20 Aug, 156 commits ahead of main) | `1e1d9cf` | Superseded by the monorepo `frontend/`; no wearable code (grep of `lib/`, `ios/`, `android/`: zero real hits) |
| `backendV2` | Older backend; `main` at `5ce3825` (8 Jul); audit branch +75 commits (20 Aug) | `9f36208` | Superseded by monorepo `backend/`; no wearable code |
| `V2-Claude` | Older Flutter lineage 1.0.3+33; `feature/voice` (tap-to-talk, `speech_to_text`), `ci/ios-testflight` | `2e7bac1`, 3 Aug | Voice work already carried into the release line; nothing else to recover |
| `v3` | Zip archive of the launched 1.0.4+34 app | `94c5394`, 20 Aug | Reference only |
| `askalrt` | Firebase Functions Ask ALRT (`askAlrt` callable, Anthropic SDK, quotas 5 free / 30 ALRT+) | `c26115d`, 7 Sep | Reusable for spoken answers; response is `{answer, source, usedAI, refused?}` with **no citation array**, attribution is inside the prose |
| `watchinterface` | V2 design handoff: `prototype/ALRT Wear OS.dc.html` (13 screens), `backend/wear-os-standalone-sos-spec.md`, product rules | `e98b660`, 6 Aug | **Prototype only.** Screens and copy reusable; data model obsolete (Firestore `onSosStart`, `sosEvents`, `liveShareSessions`, `widgetPayload/{uid}`; the real backend is Postgres + REST + Socket.IO). Its "standalone install, never through a phone relay" rule conflicts with the companion-first decision below. Its hold 3 s + 5 s countdown + 12 s undo differs from the phone's 3 s hold; pricing $7.99 differs from the locked $9.99 |
| `glasses` | `main`: README + `.gitignore`. Branch `feat/glasses-android-xr-scaffold` (3 commits, 26 Jul): `docs/ar-glasses-launch-spec.md`, Kotlin skeleton (`AlrtApi.kt`, `SosController.kt`, `HudState.kt`, `VoiceCommand.kt`), a CI that skips because no Gradle wrapper is committed | `cbab4ed` | **Scaffold only, never compiled.** The REST endpoints it names match the real backend. Its "navigate to safety" AR route overlay, wake-word voice, look-to-identify and phone-less SOS are **out of scope by your rules** (no guaranteed evacuation routes, no wake word, no AI hazard detection). Reusable: the sharing-level clamp idea in `SnapshotPolicy` and the acceptance-test style |
| `ALRT-screen` | Design and docs; `alrt-v2-backend-changes.md` §7/§13/§17/§18 (widget payload, haptic tier map, "Watch v1 = notification actions + complication; no independent networking", "no wake word ever", Android XR phases: read-aloud first) | `bc614f6`, 20 Aug | The "notification actions + complication first" idea is exactly the pilot below |
| `alrt` (website) | Marketing site; redesign branch already advertises "Watch, widgets, glasses … The watch works without the phone" | `e73f089`, 7 Sep | **Copy promises something that does not exist.** Recommend softening before the site ships |
| `occulo`, `mattv2` | Empty (no commits) | | Nothing to recover |

### 2.3 Reusable code on the release line (branch `test`)

See §2.4 for the detailed audit. Directly reusable for wearables:

- `frontend/lib/features/shared/services/alert_speech_service.dart`: `flutter_tts` reader, one voice at a time, used by `view_hazard_screen.dart` and `notification_service.dart`. This is the spoken-summary engine for both the phone and audio glasses.
- `frontend/lib/features/shared/services/voice_input_controller.dart` and `views/widgets/voice/*`: tap-to-talk, on-device, no wake word (matches the locked rule).
- Notification categories and action identifiers in `frontend/lib/features/notification/services/local_notification_service.dart` (`ALRT_LOW_BAND`, `ALRT_LOW_BAND_FOLLOWING`, `ALRT_HIGH_BAND`, `ALRT_CHECKIN_PROMPT`; actions `alrt_im_safe` "Check in", `alrt_view_details`, `alrt_follow_updates`, `alrt_open_map`). The "Check in" action already sends a check-in **with no location** (`notification_service.dart:195-201`, `checkIn(shareLocation: false)`) but it opens the app to do it and does not name the circle. The backend's `urgent` flag, Android channel naming (`alrt_alerts`, `alrt_alerts_urgent`, `priority: high`, `visibility: private`), APNs `sound` and `interruption-level`, tray collapse keys (`backend/src/services/notification.service.ts:349-458`); stable notification ids; `POST /api/notifications/test` and `DELETE /api/notifications/push-notification-token`.
- Two gaps that matter for the wrist: the APNs payload sets **no `category`** (so a system-drawn iOS notification has no actions), and there is **no `FirebaseMessaging.onBackgroundMessage` handler** (so an Android notification drawn while the app is closed has no actions either). Actions exist only when the phone app is in the foreground and draws the notification itself.
- The Family widget payload v2 (`FamilyWidgetModel.build`): one row per circle, ordered SOS › requested › waiting › ordinary, honest freshness line, no member names or locations. This is the natural **wearable payload** too.
- Backend: multiple circles per user (`?circleId=` on every family route); `checkInRequests` (every open ask in the last day, newest first, targeted or everyone) and per-circle `pendingCheckInRequests`; check-in with optional location and the sharing-level ceiling enforced twice server-side (`family.service.ts:1514-1522`, `family.controller.ts:513-528`); `GET /family/sos/active` across circles; SOS response upsert (idempotent), explicit "I've seen this" (the phone no longer offers "On my way"); journeys (15, 30 or 60 minute start, up to 60 minutes per extension, 240 minute cap, `family_journey.service.ts:16-20`); SOS 4 hour cap with a lapse sweeper (`endLapsedSosEvents`, scheduler-driven, so off on TEST).
- Existing snapshot and sharing rules: `SNAPSHOT_TTL_MS` one hour; approximate is a suburb label from reverse geocoding with coordinates withheld (`family_alert.service.ts:37-102`); `off` is refused server-side.

### 2.4 Detailed code audit of branch `test`

(Filled from the frontend and backend audits; see the tables at the end of this document, Appendix A and B.)

---

## 3. Platform comparison, checked against official documentation

### 3.1 Smartwatch

| Question | Wear OS (Pixel Watch, Galaxy Watch) | Apple Watch |
|---|---|---|
| Phone required | Android phone only. Pixel Watch support page: iPhone not supported; Pixel Watch 4 needs Android 11+ ([support.google.com/googlepixelwatch/answer/12652073](https://support.google.com/googlepixelwatch/answer/12652073)). Samsung: Wear OS Galaxy watches need an Android phone with Google Mobile Services ([samsung.com support](https://www.samsung.com/us/support/answer/ANS10004668/)) | iPhone only; watch is set up from the iPhone |
| Phone notifications reach the watch without a watch app | Yes. "By default, the system automatically bridges notifications from a phone app to any paired watches." Duplicates are controlled with `BridgingManager`, `setBridgeTag`, `setLocalOnly`, and `setDismissalId` for dismissal sync ([developer.android.com/training/wearables/notifications/bridger](https://developer.android.com/training/wearables/notifications/bridger)) | Yes. "If your iPhone is locked or asleep, you get notifications on your Apple Watch, unless your Apple Watch is locked"; per-app "Mirror iPhone Alerts From" setting; dismissals sync ([support.apple.com/108369](https://support.apple.com/en-us/108369)) |
| Action buttons on mirrored notifications | Yes, `NotificationCompat.WearableExtender().addAction(...)`; a `BroadcastReceiver` cannot be the action target on the watch side ([creating](https://developer.android.com/training/wearables/notifications/creating)) | Yes, category actions declared by the iOS app appear on the watch |
| Phone to watch data channel | Wearable Data Layer: `DataClient` items sync when connected; `WearableListenerService` runs in the background; **does not work if the watch is paired with an iPhone** ([data-layer](https://developer.android.com/training/wearables/data/data-layer)) | WatchConnectivity: `updateApplicationContext` and `transferUserInfo` work in the background and when the iPhone is locked; `sendMessage` needs the counterpart reachable; complication transfers are budgeted ([developer.apple.com/documentation/watchconnectivity](https://developer.apple.com/documentation/watchconnectivity)) |
| Glanceable surface | Tiles (`protolayout`, `tiles` libraries, refresh throttled, "don't overcrowd") and watch-face complications (`ComplicationDataSourceService`) ([tiles](https://developer.android.com/training/wearables/tiles)) | Complications are WidgetKit accessory widgets (ClockKit is being retired) ([WidgetKit](https://developer.apple.com/documentation/WidgetKit/Creating-accessory-widgets-and-watch-complications)) |
| Ongoing status (live SOS, journey) | Ongoing Activity: needs an ongoing notification and a foreground service; shows on the watch face and recents ([ongoing-activity](https://developer.android.com/training/wearables/ongoing-activity)) | Live Activities on watchOS (Smart Stack) via ActivityKit; not verified from here |
| Standalone or cellular | Manifest `com.google.android.wearable.standalone`; Play requires target API 34+; watch traffic is proxied through the phone over Bluetooth, else Wi-Fi or LTE; FCM works natively on the watch and is the recommended way to notify it ([standalone](https://developer.android.com/training/wearables/apps/standalone-apps), [network-access](https://developer.android.com/training/wearables/data-layer/network-access)) | "Supports Running Without iOS App Installation"; an independent app must do its own sign-in, permissions, downloads and APNs pushes and "can't use Watch Connectivity as their main source of data" ([creating-independent-watchos-apps](https://developer.apple.com/documentation/watchos-apps/creating-independent-watchos-apps)) |
| Breaking through Do Not Disturb | Channel importance and bypass are user-controlled on Android; must be observed on hardware | `timeSensitive` needs the Time Sensitive capability on the App ID (absent today); `critical` needs an Apple-approved entitlement ([UNNotificationInterruptionLevel](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel)) |
| Flutter | Flutter's supported-platforms list has no wearable OS; smartwatch support is a stated non-goal; community `wear_plus` 1.2.5 exists. A Flutter module can run on Wear OS as an Android app, but tiles, complications, ongoing activities and the Data Layer are Kotlin | Not supported. watchOS targets are Swift/SwiftUI in Xcode. `watch_connectivity` 0.2.10 bridges the phone side only |
| Build and distribution | Same Play Console listing, Android App Bundle; existing Android CI can build the Wear module | Watch app ships inside the iOS bundle (or independently); needs the iOS signing that has **never yet produced a TEST build** in this repo |

Reading of the comparison, in plain English:

- Both platforms can do the pilot (mirrored actionable notifications) with **no watch code at all**. That is why it is the first milestone.
- A Wear OS companion is cheaper for this team: same repo, same CI, Kotlin module, no Mac needed, and the Android TEST pipeline already works. An Apple Watch companion is not harder to write, but it sits behind an iOS TEST pipeline that has never run and a signing setup that needs a Mac or a paid macOS runner.
- Standalone operation (watch with no phone, on LTE) is a separate product on both platforms: the watch needs its own session, its own push token, its own permission prompts and its own tests. It is planned as its own phase, not folded into the companion.
- **The decision is forced by your test phone, not by preference.** If you test on an iPhone, Wear OS watches cannot even pair. If you test on Android, an Apple Watch cannot pair. Please tell me which phone(s) you have.

### 3.2 Glasses

| Question | Meta glasses (Wearables Device Access Toolkit) | Android XR glasses (Jetpack XR SDK) |
|---|---|---|
| Which devices have a display | **Audio-only:** Ray-Ban Meta Gen 1 and Gen 2, Ray-Ban Meta Optics, Oakley Meta HSTN, Oakley Meta Vanguard. **Display:** Meta Ray-Ban Display (monocular right-lens display, Meta Neural Band wristband) | "Audio glasses" (speaker, camera, microphone, no display) and "display glasses" (additive display); consumer devices announced for later 2026, pre-release hardware via Google's Catalyst program ([devices](https://developer.android.com/develop/xr/devices), [glasses/build](https://developer.android.com/develop/xr/jetpack-xr-sdk/glasses/build)) |
| SDK status | Developer preview, v0.9 (`facebook/meta-wearables-dat-ios`, Swift Package; Android Kotlin SDK too); `MockDeviceKit` for testing without glasses. Display support for third parties opened 14 May 2026 as a preview with two paths: extend a native mobile app (Swift/Kotlin UI components: text, images, lists, buttons, video) or ship a web app (HTML/CSS/JS) that runs on the glasses | Developer Preview 4 (May 2026); SceneCore, ARCore for Jetpack XR and XR Runtime in beta (Aug 2026); Compose Glimmer for glasses UI; emulator AVDs for glasses |
| How it runs | A phone app talks to the glasses over Bluetooth; the glasses have no app store account of their own for native apps. Camera streaming, photo capture, microphone and speaker are exposed; display UI on Ray-Ban Display | Projected activities: "the activity … doesn't run directly on the device, but is instead projected to the device from a host device (such as user's phone)"; `ProjectedContext` gives access to glasses camera, sensors, audio ([projected context](https://developer.android.com/develop/xr/jetpack-xr-sdk/access-hardware-projected-context)) |
| Voice | Third-party apps get microphone audio and can run their own on-device recognition. **No custom "Hey Meta" commands and no Meta AI access** are available to third parties (reported by developer coverage of the preview; `developers.meta.com` is blocked from this sandbox, so re-confirm) | On-device ASR and TTS APIs are part of the SDK; no wake word for third parties documented |
| Background or phone locked | **Not confirmed.** Session states, pause and resume are documented topics; behaviour with the phone locked must be tested on hardware | Projected context is valid only while `isProjectedDeviceConnected()` is true; lifecycle tied to the host app |
| Notifications | Not documented as bridged to third-party apps | The system bridges phone notifications to glasses "when they meet certain criteria" ([notifications](https://developer.android.com/develop/xr/jetpack-xr-sdk/glasses/notifications)) |
| Distribution | Reported as limited to selected partners during preview, general availability targeted later in 2026. Must be confirmed with Meta | No consumer hardware yet |

Reading: **audio-only glasses are the realistic second phase**, because the phone already has the spoken-alert reader and the voice input, and the glasses add only a microphone and a speaker over Bluetooth. Display cards come after, and only on Ray-Ban Display or future Android XR hardware you actually hold. Nothing in either SDK supports "independent connectivity" for a third-party safety app today, so the glasses never hold a session.

---

## 4. Recommended architecture

### 4.1 Principles

1. **One authoritative backend.** The wearables call nothing new. Every action is one of the existing REST calls (`POST /api/family/check-in`, `POST /api/family/sos`, `POST /api/family/sos/:id/respond`, `POST /api/family/sos/:id/resolve`, `POST /api/family/journeys/:id/extend`, `/stop`) with the existing rules applied server-side.
2. **Companion first, phone holds the session.** In the pilot and the companion phases the watch never holds a token. It asks the phone to act, and the phone posts with its own session. That means logout, account switch, leaving a circle and unpairing are handled once, on the phone, and the wrist cache is cleared from the same code path. Standalone (Phase 3) introduces a watch session and is treated as a separate capability with its own device registration and revocation.
3. **The wearable reads a payload, not the API.** Reuse the Family widget payload v2 shape (one row per circle, honest freshness line, no member names or locations) as the wrist payload, pushed over the Data Layer or WatchConnectivity application context. The watch cannot show what the payload does not carry, which enforces the privacy floor by construction.
4. **Every action is deliberate and named.** Notification actions and watch buttons read "Check in to <circle>", never "I'm safe". Opening a notification never sends anything. SOS is hold-to-arm with confirmation. Acknowledge, stand-down and extend are explicit taps.
5. **Four visible states everywhere:** sending, confirmed (only after the server answers), failed, uncertain (sent but no answer). Uncertain is reconciled by asking the server (the phone already does this for SOS: "a send whose answer was lost asks the server for my active SOS before offering a retry") before any retry.
6. **Idempotency across devices.** Add a client-generated `requestId` (UUID) to check-in, SOS trigger, SOS respond, journey extend and stop, with a unique index server-side, so the same action from the phone and the watch within seconds produces one row and one fan-out. The backend currently dedupes SOS responses (`@@unique([sosEventId, memberId, type])`) and cancels a prior active SOS on retrigger, but check-ins have no duplicate protection.
7. **Do not shrink the phone app.** No Flutter on the watch. The wrist and glasses layers are thin native code that reads a payload and sends intents; the brains stay in the phone app and the backend.

### 4.2 Where the code lives

Recommendation: **inside the release-candidate monorepo**, not in `watchinterface` or `glasses`.

- `frontend/android/wear/` (new Gradle module; Kotlin, Compose for Wear OS, Tiles, complications, `WearableListenerService`). Same package name and signing key as the phone app, which the Data Layer requires.
- `frontend/ios/AlrtWatch/` (new WatchKit extension target; SwiftUI; WidgetKit complication). Same team; bundle id `com.safetyalrt.alrt.dev.watchkitapp` for TEST.
- `frontend/lib/features/wearable/` (Dart): one `WearablePayload` builder (reusing `FamilyWidgetModel`), one method channel for "action requested by wearable" and one for "push payload to wearable". This is the only Flutter change and it is behind a runtime flag.
- `backend/`: additive only (`requestId` idempotency, `deviceKind` on `UserDevice` and on check-in/SOS rows, optional). No migration until approved; the pilot needs none.
- `watchinterface` and `glasses` become **design and spec repos**: keep the Wear OS prototype and product rules there, update the SOS spec to the real REST model, delete the Firestore references. Do not put buildable code there; a second CI, a second signing setup and a second release line for a safety feature is a risk, not a saving.

Trade-offs, plainly:

- Monorepo: one CI, one version number, one test suite, one TEST rollout. Cost: the phone workflow gets longer and a broken Wear module could block a phone build. Mitigation: separate workflow file (`android-wear-test.yml`), the Wear module excluded from `android-test.yml`, and the Flutter changes behind a flag that is off in 1.0.5.
- Separate repos: cleaner isolation, but two sets of secrets, two signing keys to keep aligned (the Data Layer needs the same signature), and drift between phone payload and watch parser. Not recommended.

### 4.3 What must be native

| Piece | Wear OS | Apple Watch |
|---|---|---|
| Notification bridging control (avoid duplicates once a watch app exists) | Kotlin on the phone: `BridgingManager` config plus `setBridgeTag` on notifications that must still bridge | Automatic once a watch app is installed for that category; the watch app's notification controller takes over |
| Payload transport | `DataClient` on phone and watch, `WearableListenerService` on the watch | `WCSession.updateApplicationContext` on both sides |
| Tile / complication | Kotlin `TileService`, `ComplicationDataSourceService` | Swift WidgetKit accessory widget |
| Ongoing SOS / journey status | Kotlin `OngoingActivity` with a foreground service | Swift ActivityKit (watchOS 11+) |
| Hold-to-send SOS, check-in, ack, extend, finish screens | Kotlin, Compose for Wear OS | SwiftUI |
| Wrist cache clear on logout / unpair | Kotlin: delete DataItems, cancel notifications, clear local store | Swift: clear app group container and complication timeline |
| Flutter side | Method channel only | Method channel only |

### 4.4 Backend changes (small, additive, all needing approval before any migration)

| Change | Why | Migration? |
|---|---|---|
| `requestId` on check-in, SOS trigger, SOS respond, journey extend and stop; unique per user | Cross-device duplicate prevention; safe retry after "uncertain" | Yes, one column and index per table |
| `deviceKind` (`phone`, `watch`, `glasses`) on `UserDevice` and, optionally, on check-in and SOS rows | Device-status screen; audit; "Checked in from watch" wording | Yes, one nullable column |
| Refresh-token revocation on logout and account deletion | Today logout deletes the push token but the JWT refresh token stays valid until expiry (no revocation list). A lost or unpaired standalone watch could keep a session. Needed before Phase 3, recommended before Phase 2 | Yes, a small table or a token version on `User` |
| Set `RUN_SCHEDULED_JOBS_IN_TEST=true` on the TEST host | The SOS 4-hour auto-end, snapshot expiry sweeps and daily reminders are untested on TEST; wrist SOS tests need the cap to fire. The switch already exists in code and defaults to off | No code change; an environment change on TEST that **needs your approval** (§36.8 lists it as "not changed without approval") |
| Validate `requestId` against the circle in `createCheckIn` | Today a client can post a check-in against circle A carrying circle B's request id and the row is stored (`family.service.ts:1533`); the cross-circle rule currently rests on the phone's `checkInTargetCircleIds` guard and read-side scoping. A second client makes a server-side check necessary | No migration |
| APNs `category` and `apns-push-type` on check-in request and SOS pushes; Android data-only shape for the same two types | Needed for action buttons on system-drawn notifications, which is what a watch mirrors. Per platform: keep the iOS alert in `apns.payload.aps.alert` with a `category`; send Android as data-only so the phone app draws it with actions from a background handler. Behind a server flag, TEST first | No migration |

The pilot (Milestone 1) needs none of these.

---

## 5. Phased delivery

Sequencing rule, taken from the repo's own guidance: **finish a surface before starting a surface.** Phase 0 ships with or after 1.0.5 and touches the phone only in ways that are also phone improvements.

| Phase | Scope | Depends on | Exit criterion |
|---|---|---|---|
| **0. Foundations (phone and backend)** | Notification actions renamed to name the circle and never send location; wearable-safe notification bodies; device-status screen (paired device, last sync, last delivery); "Test my alerts" flow extended to connected devices; `requestId` idempotency; `deviceKind`; iOS time-sensitive capability (approval) | 1.0.5 acceptance not blocked | All existing acceptance items still pass; no new location behaviour for Off, Alerts only, Just check in |
| **1. Wrist pilot (no watch app)** | Mirrored actionable notifications on one platform: check-in request with "Check in to <circle>" action, SOS receipt with "Open on phone", server-confirmed result notification; the per-platform push shape change and a Dart background handler for those two types only; phone-side duplicate control | Phase 0 items 1 and 2; hardware chosen | Milestone 1 acceptance (§9) passed on real devices |
| **2. Companion watch app** | Tile or complication; circle switcher; pending requests with requester names; check-in; hold-to-send SOS with server confirmation; active SOS with acks and stand-down; journey remaining, extend, finish; alert summaries; cache clear on logout, switch, leave, unpair | Phase 1 proved delivery; scheduler on TEST for SOS cap tests | Full device matrix (§8) passed; no duplicate notifications with the watch app installed |
| **3. Standalone or cellular watch** | Watch session and push token, own sign-in, own permissions, watch-originated location for SOS live share, revocation; separate Play or App Store listing status | Backend revocation and device registry; a cellular watch to test | The `watchinterface` acceptance test ("phone left at home, the dot must still move") plus the standalone security tests |
| **4. Glasses, audio** | Phone speaks alert summaries and check-in requests through the glasses; confirmed check-in by button hold or spoken yes routed through the phone; deliberate SOS with spoken countdown; Ask ALRT answers spoken with source named first; optional user-initiated photo for a report, reviewed on the phone before posting | Meta developer access confirmed; a pair of glasses; Phase 2 payload | Spoken flows pass the privacy tests (§8); nothing posts from a voice utterance without a confirmation |
| **5. Glasses, display** | Glanceable cards on Meta Ray-Ban Display or Android XR display glasses | Hardware in hand; SDK past preview | Cards show only what the wrist payload carries |

Not in any phase: continuous recording, automatic reporting, AI hazard detection, custom wake words, always-on listening, arbitrary overlays, independent glasses connectivity, "safe route" guidance, purchases or circle administration on a wearable.

---

## 6. Effort, assumptions and blockers

All ranges are engineering effort for one experienced mobile engineer plus your device testing; they exclude waiting on approvals and third-party access.

| Phase | Range | Assumptions | Blockers |
|---|---|---|---|
| 0 Foundations | 1 to 2 weeks | Backend additive changes approved; iOS capability change approved | Phone acceptance of build 51 still open; iOS TEST pipeline never run |
| 1 Wrist pilot | 1 to 2 weeks plus 3 to 5 days of device testing | One platform; two phones plus one watch; TEST backend reachable | Hardware not yet named |
| 2 Companion app, Wear OS | 6 to 9 weeks | Kotlin engineer; Android TEST pipeline; scheduler on TEST | Same-signature requirement means the Wear module must be built and signed by the same workflow |
| 2 Companion app, Apple Watch | 7 to 10 weeks | Swift engineer; Mac or macOS runner; fastlane match profiles for the watch bundle ids | iOS TEST build must exist first (never produced); time-sensitive capability |
| 3 Standalone or cellular | 4 to 8 weeks | Cellular watch available; backend revocation and device registry shipped | Play or App Store review of a standalone safety app; battery testing |
| 4 Glasses, audio | 3 to 6 weeks (spike first, 1 week) | Meta developer program access granted; a supported pair; `MockDeviceKit` for CI | Preview SDK, partner-only publishing until GA; background behaviour unknown |
| 5 Glasses, display | 4 to 8 weeks | Ray-Ban Display plus Neural Band, or Android XR hardware | SDK maturity; no consumer Android XR glasses yet |

---

## 7. Hardware and developer-account requirements

### Common to every path

- Two phones with TEST accounts (already required by the build 51 checklist), one of which will pair with the watch.
- Access to the TEST backend and Admin Portal, and the ability to trigger the Android Test Build workflow (already in place).
- Firebase project `alrt-a6539` (existing; FCM is used for the watch too).

### Wear OS path

- Android phone on Android 11 or later for Pixel Watch 4 (Android 10 for Pixel Watch 3, 9 for Pixel Watch 2) or a Galaxy phone for Galaxy Watch.
- A Wear OS 4 or 5 watch: Pixel Watch 2, 3 or 4, or Galaxy Watch 6, 7 or 8. An LTE model only if Phase 3 is wanted.
- Google Play Console access (existing) to add the Wear form factor to the listing later; Android Studio with the Wear OS emulator for engineers.
- The existing TEST keystore (the Wear module must be signed with the same key).

### Apple Watch path

- iPhone on iOS 18 or later; Apple Watch Series 9, 10 or 11, or SE 2, or Ultra, on watchOS 11 or later.
- A Mac with Xcode, or the paid macOS GitHub runner already used by `ios-test-testflight.yml` (which still needs the `MATCH_*` and App Store Connect API secrets and has never run).
- Apple Developer Program team `JR89M7CYPR`: App IDs for `com.safetyalrt.alrt.dev.watchkitapp` and the widget, App Group `group.com.safetyalrt.alrt.dev`, the Time Sensitive Notifications capability, new match profiles. Critical Alerts would need a separate Apple approval and are **not** proposed.

### Glasses path

- Meta: a developer account on `developers.meta.com`, enrolment in the Wearables Device Access Toolkit preview (v0.9), the Meta AI app on the phone, and a supported pair: Ray-Ban Meta Gen 2 for audio; Meta Ray-Ban Display plus Neural Band for display. Confirm the current partner and publishing terms on Meta's site before purchasing.
- Android XR: no consumer glasses to buy yet; emulator only, or an application to Google's Catalyst program.

No purchase is recommended until you confirm the phone and the first platform.

---

## 8. Testing requirements (real devices; nothing else counts)

Each row is recorded as **device pass**, **device fail** (with what was seen), **awaiting device**, or **blocked**, exactly as the build 51 checklist already does. Unit tests, screenshots, emulators and mocked push services are evidence of code shape only and never fill a device column.

| Area | Tests |
|---|---|
| Connectivity | Phone and wearable connected; Bluetooth off; out of range then back in range; phone rebooted; wearable rebooted. Queued check-in from the wearable while disconnected must show "not sent" and must not send later without the user seeing it |
| App state | Phone app in foreground, background, force-closed, and after a fresh install; phone locked; watch on wrist and off wrist (Apple Watch only forwards when on wrist and unlocked) |
| Uncertain requests | Kill the network after the phone posts and before the answer: wearable shows "uncertain", the phone reconciles with the server, no duplicate row and no duplicate push to the circle |
| Duplicates | Check in from phone and watch within two seconds; SOS hold on both within two seconds; the same push tapped on watch and phone; notification dismissed on one device disappears on the other |
| SOS roles | Sender on the watch: hold, confirm, "sending", server-confirmed, acks arrive, stand-down asks first. Recipient on the watch: receipt with circle name, "seen" recorded only by an explicit open, "On my way" explicit; a stand-down never navigates the recipient |
| Circles and requesters | Two circles with open asks; two requesters in one circle; check-in to circle A never answers circle B's ask; the watch names the circle before sending |
| Location and consent | Wearable check-in sends no location; a precise check-in is only possible through the phone's consent sheet; snapshot expires at one hour and the wearable stops showing it; Off, Alerts only and Just check in members never gain a location path from the wearable |
| Accounts and devices | Logout, account switch, leave circle, unpair and re-pair, watch reset: wrist tile, notifications and cache are cleared each time; a second account on the same phone never sees the first account's wrist state |
| Notifications | Sound, vibration, private lock-screen body, user-disabled permission on phone or watch, Do Not Disturb and Bedtime on both devices, Focus on iPhone; urgent vs ordinary channel |
| Battery and staleness | 24 hours of normal wear with the tile installed; stale marker appears when the payload is older than an hour; limited background execution on Wear OS (Doze) and watchOS |
| Wearable-specific | Wear OS: bridged notification and watch-app notification never both appear; Data Layer items reset after phone uninstall. Apple Watch: Mirror iPhone Alerts setting off for ALRT then on |

---

## 9. First milestone (proposed, not started): the wrist pilot

**Name:** Milestone 1, "Check in from the wrist, no watch app".

**Scope:** on one platform (your choice after the hardware answer), make the existing phone pushes for check-in requests and SOS arrive on the watch with a deliberate action, and prove it on real devices. Zero watch code. Phone changes limited to notification content and actions, plus the device-status and test-my-alerts additions from Phase 0 that the pilot needs to be observed.

**Work items:**

1. Notification body for a check-in request names the circle and the requesters: "Amy and Tom asked you to check in · Home".
2. Action button "Check in to Home" (per circle, never generic). It posts a check-in with **no location** and the request id, through the phone app in the background, and never opens a map or sends a snapshot. This needs: (a) backend, behind a flag on TEST: check-in request and SOS pushes gain an APNs `category` and are sent to Android as data-only; (b) app: a `FirebaseMessaging.onBackgroundMessage` handler (`@pragma('vm:entry-point')`) that draws those two types with actions, and a background action handler that posts the check-in without opening the app. The existing foreground action becomes the same path. All other push types are untouched.
3. A follow-up local notification with the server's answer: "Checked in to Home · 9:41" or "Check-in to Home not sent · open ALRT". Nothing is shown as done before the server answers.
4. SOS receipt on the wrist shows circle name and "Open on phone" only. No SOS action of any kind from a notification.
5. Wear OS: `setDismissalId` per event so dismissals sync; bridging left at default (no watch app yet). Apple Watch: confirm the category actions surface on the watch; no changes needed to mirroring.
6. Device-status card on the phone: paired wearable present (via `NodeClient` or `WCSession.isPaired`), last sync time, last delivery time (from the test notification).
7. "Test my alerts" gains "Send a test to my watch" using the existing `POST /api/notifications/test`.

**Acceptance criteria (all on real hardware, all recorded per the build 51 checklist convention):**

- A check-in request raised on phone B appears on phone A's watch within 30 seconds with the circle name and requester names, with the phone locked and the app closed.
- Tapping "Check in to Home" on the watch results in exactly one check-in row on TEST with no location, attributed to A, answering only Home's ask; phone B sees "A checked in · just now" with no location.
- The watch and phone A both show the server-confirmed result; if the phone is offline when the action is tapped, the result reads "not sent" and no check-in appears later without a further deliberate tap.
- The same request answered on the phone and the watch within two seconds produces one row and one push to B.
- An SOS from B appears on A's watch with the circle name and only "Open on phone"; opening it records nothing on the server until A opens the SOS on the phone.
- With Do Not Disturb on, an ordinary check-in request stays silent and an urgent SOS behaves as the platform's rules allow; both outcomes are recorded, not assumed.
- Logout on phone A removes ALRT notifications from the watch and the device-status card reads "signed out".
- None of the existing build 51 acceptance items regress.

**What the pilot must not touch:** every other push type keeps its current shape; the change is flagged and off in the 1.0.5 store build; the rollout script's `verify_family_push_delivery` gains checks for the two new shapes before anything is deployed to TEST.

**Approval needed before any of this starts:** your hardware answer, your choice of platform, and agreement that the two notification-content changes (items 1 and 2) are acceptable for the phone release line.

---

## 10. Supporting improvements

Must-have foundations (needed for the pilot to be observable and honest):

- Device-status screen: paired wearable, last sync, last delivery, last test result, permission state. Builds on the existing Manage notifications card.
- "Test my alerts" flow, clearly labelled as a test: permission state, sound, vibration, lock-screen appearance, and connected devices, each with a "not tested yet / passed / failed" record on the phone. Extends the existing "Send a test notification" and "Test vibration" rows.
- Notification actions that name the circle and never send location.
- Accessibility floor for the wearable payload: severity as word plus shape plus colour; text sizes that survive the largest system size; haptic patterns that differ for check-in request, SOS and alert and that are described in words in the settings.

Optional, later:

- iOS lock-screen widgets and Live Activities for an active SOS or journey (needs the WidgetKit target that is still not in the Xcode project).
- App Intents and Android App Actions ("check in to Home" by voice on the phone) once the check-in action path exists; no SOS by voice.
- Spoken summaries on the phone as an accessibility setting (the engine exists; only the setting and the privacy rules around surroundings are missing).
- Larger-control mode for the phone check-in sheet.

---

## 11. How each privacy and safety rule is preserved

| Rule | How the plan keeps it |
|---|---|
| Clearly name the destination circle | Every action label and every confirmation includes the circle name; the watch payload carries the circle name per row |
| Never silently broadcast a check-in to other circles | The action carries the circle id and request id; the phone's existing `checkInTargetCircleIds` guard applies; the server's per-circle rule is unchanged |
| Quick wearable check-in defaults to no new location | The wearable action has no location field at all; precise or approximate sharing is only reachable through the phone consent sheet |
| Precise location needs explicit consent and stays a fixed one-hour snapshot | Unchanged server TTL; the wearable never posts coordinates in Phases 1 and 2 |
| Approximate means suburb only | Server-side label unchanged; the wearable payload never carries coordinates |
| Off, Alerts only, Just check in gain no new location behaviour | The wearable path has no location; these levels keep their server-side ceilings |
| Alert association does not prove proximity | Alert summaries on the wrist say "near <saved place>" or "near a circle member's last check-in", never "you are near" |
| No automatic SOS, acknowledgement, stand-down or check-in from opening a notification | Opening does nothing; only a labelled action button acts; SOS has no notification action; "seen" stays tied to opening the SOS on the phone |
| Success only after server confirmation | The four-state model; the follow-up notification is sent only from the server response |
| Distinguish sending, confirmed, failed, uncertain; reconcile before retry | Same states on wrist and phone; uncertain triggers a server query before retry, as the phone SOS already does |
| Prevent duplicates across devices | `requestId` idempotency (Phase 0) and dismissal sync |
| Clear sensitive cached state after logout, switch, leave, unpair | One phone-side clear path fans out to widget, wrist and glasses caches |
| Preserve OS permissions, notification preferences and Do Not Disturb | No bypass requested beyond what the phone already asks; no critical-alert entitlement proposed |
| Spoken output respects privacy and surroundings | Opt-in; off by default; never speaks names or locations of others; silent on headset removal; obeys the silent switch |
| ALRT is not a guaranteed emergency-response service | The existing disclaimer travels with every alert; wearable copy uses "tells your circle", never "gets help" |

---

## 12. Questions for Sarah

1. Which phone(s) do you test with (make, model, OS version)? This decides Wear OS versus Apple Watch.
2. Do you own or can you borrow a watch, and which one? Is it cellular?
3. Which glasses, if any (Ray-Ban Meta Gen 1 or 2, Oakley Meta, Meta Ray-Ban Display)?
4. Is a Mac with Xcode available, or should the paid macOS runner be used for any iOS work?
5. Can you confirm `https://api-test.safetyalrt.com` is the TEST backend to use, and that build 51 is the build on your phone (the Profile footer shows it)?
6. Was `ALRT-dev/widget` renamed to `frontendV2`, or deleted?
7. Do you approve the two Phase 0 backend items that need a migration (`requestId`, `deviceKind`), the `createCheckIn` request-id validation, and setting `RUN_SCHEDULED_JOBS_IN_TEST=true` on the TEST host? None is needed for Milestone 1 except the flagged push-shape change; all are needed before Phase 2.

I will not choose hardware, start Milestone 1, or change the phone release line until you answer and approve.

---

## Appendix A. Frontend audit, branch `test` (`frontend/`, 1.0.5+51)

| Topic | Finding | Where |
|---|---|---|
| Push handling | Foreground only: `onMessage` draws a local notification on Android; iOS foreground is delegated to the OS. **No `onBackgroundMessage` handler.** | `lib/features/notification/services/notification_service.dart:142-147`; `local_notification_service.dart:204-206` |
| Channels | `alrt_alerts` (Importance.max) and `alrt_alerts_urgent` (strong vibration pattern; created only while the accessibility switch is on). No `bypassDnd`. | `local_notification_service.dart:31-43`, `:120-169` |
| iOS categories | `ALRT_LOW_BAND`, `ALRT_LOW_BAND_FOLLOWING`, `ALRT_HIGH_BAND`, `ALRT_CHECKIN_PROMPT`; every action is `foreground`. Android actions all `showsUserInterface: true`. | `local_notification_service.dart:53-56`, `:280-328`, `:333-384` |
| Check-in action | `_handleImSafeAction()` calls `checkIn(shareLocation: false)` and opens the Family tab; a comment states a notification button never attaches location. | `notification_service.dart:185-201` |
| Tap dedupe and ids | Launch message consumed once per `messageId`; stable notification id from `sosEventId`, `checkInId`, `requestId`, `journeyId`, `locationRequestId`, `id`, `messageId`. | `notification_service.dart:27,109-122`; `local_notification_service.dart:251-272` |
| `urgent` | `data['urgent']` or severity band action/critical; urgent channel only when strong vibration is on. No `interruptionLevel`, `timeSensitive` or critical alert code. | `local_notification_service.dart:215,243-248` |
| Test notification | Manage notifications card: "Send a test notification" → `POST /api/notifications/test`; "Open phone settings". | `views/widgets/notification_status_card.dart:76-79,164-173`; `lib/api/endpoints.dart:85` |
| Tokens | Access and refresh tokens in **SharedPreferences**; no `flutter_secure_storage`. | `features/shared/enums/shared_prefs_key_types.dart:1-20`; `features/auth/services/auth_service.dart:199-227` |
| Sign-out order | Unregister push token (4 s cap) → clear tokens → Firebase sign-out → clear Family widget → RevenueCat sign-out → invalidate ALRT+ providers. Account deletion mirrors it. No account-switch flow (sign out, then sign in). | `features/profile/providers/profile_provider.dart:204-294` |
| Socket reconnect | Backoff 2, 4, 8, 16 s capped at 30 s; fresh token each reconnect. | `features/shared/services/socket_reconnect_policy.dart` |
| Selected circle | `providerOfSelectedCircleId` is **in-memory only**, not persisted; `null` means the first circle. A wearable cannot read it from disk today. | `features/family/providers/selected_circle_provider.dart:8-18` |
| Check-in | `checkIn({required shareLocation})`; `checkInTargetCircleIds` scopes an answered ask to its own circle, a proactive check-in fans out to every circle; consent sheet offers precise, suburb or none by sharing level. | `family_provider.dart:1205-1310`; `views/widgets/family_check_in_consent_sheet.dart:28-73` |
| Multi-ask | "View N requests" sheet lists every asker and other circles with open asks; one button answers the selected circle. | `views/widgets/family_check_in_requests_sheet.dart` |
| Sharing levels | `precise, approximate, alertsOnly, off` (no separate "just check in" level; that is a check-in with no location). | `models/family_models.dart:16-21` |
| SOS send | Hold 3 s; release cancels; no post-send undo; `_sending` guard; on a lost answer, `findMyActiveSos()` asks the server before any retry; auto-return 1.2 s after confirmation. Live share every 20 s when opted in. | `views/screens/family_sos_screen.dart:35-40,471-528`; `family_provider.dart:82,1893-1993` |
| SOS receive | "I've seen this" is an explicit tap; "On my way" is removed from the flow (enum kept); stand-down via `/sos/{id}/resolve`; 4-hour lapse is server-side; active SOS read across circles with a 90 s grace and an ended-id tombstone set. | `views/screens/family_sos_receiver_screen.dart:143-154,668-674`; `family_provider.dart:2041-2079` |
| Journeys | 15 / 30 / 60 minute start, extend and stop; snap points every 10 min, live every 45 s, per-journey opt-in; circle rule can force snap points only. | `views/screens/family_journey_screen.dart:31-33,266-307`; `family_provider.dart:1510-1600` |
| Alerts | Source name from `hazard.source?.name`; "updated {time ago}" from `hazard.updatedAt`; mandatory "In plain terms" line; bands `info, monitor, action, critical`. | `views/screens/view_hazard_screen.dart:425-427,603-707`; `enums/hazard_severity_band_types.dart` |
| Widgets | `home_widget`, App Groups `group.com.safetyalrt.alrt.dev` and `group.com.safetyalrt.alrt`; payload v2 rows per circle; Android providers present; **iOS WidgetKit target absent from `project.pbxproj`**; `alrtwidget://` taps only navigate. No Live Activity, App Intents or Siri code. | `features/home_screen_widget/*`; `ios/AlrtWidget/*`; `android/.../Alrt*WidgetProvider.kt` |
| Flavours | prod `https://api.safetyalrt.com`; dev `DEV_BASE_URL` from `.env` else a LAN IP; TEST builds set `DEV_BASE_URL=https://api-test.safetyalrt.com`; build label from `ALRT_BUILD_COMMIT` and `ALRT_BILLING_MODE`. Dev iOS Firebase options still carry the prod iOS app id. | `lib/api/endpoints.dart:1-3`; `base_url_provider.dart:13-16`; `profile/utils/build_label.dart`; `firebase_options_dev.dart:62-70` |
| Tests | 52 test files; SOS (4), check-in (4), notifications (2); no auth tests; CI runs `flutter analyze` and `flutter test`. | `test/`; `.github/workflows/android-test.yml:210-237,348-349` |
| Voice and speech | `flutter_tts` reader speaks action and critical alerts once in the foreground when Read aloud is on; `speech_to_text` tap-to-talk. | `features/shared/services/alert_speech_service.dart`; `notification_service.dart:150-169`; `voice_input_controller.dart` |
| Wearable code | None. | grep of `lib/`, `ios/`, `android/`, `pubspec.yaml` |

## Appendix B. Backend audit, branch `test` (`backend/`)

| Topic | Finding | Where |
|---|---|---|
| Stack | Node 24, TypeScript, Express 5, Prisma 6 on PostgreSQL + PostGIS, Socket.IO, `firebase-admin` FCM. No test framework; 24 `verify_*.ts` scripts run against a live server; no backend CI workflow; `tsc` gate is a convention. | `package.json`; `src/scripts/`; `.github/workflows/` |
| Environments | `NODE_ENV` dev, prod, test; `.env.${NODE_ENV}`; TEST compose on port 3010 with its own Postgres; TEST host health URL `https://api-test.safetyalrt.com/api/test`; rollout by `scripts/alrt-test-rollout.sh` (revision 14). `docs/TEST_ENVIRONMENT.md` still says the DNS name is proposed only; it is stale. | `src/utils/config.ts:6,38`; `docker-compose.test.yml`; `scripts/alrt-test-rollout.sh:56-57` |
| Scheduler | `RUN_SCHEDULED_JOBS_IN_TEST` (default false); prod always runs. | `src/utils/config.ts:48-49`; `src/utils/scheduled_jobs.util.ts:16-23`; `src/index.ts:174-186` |
| Billing | `BILLING_ENABLED` false on TEST means every entitlement check passes and new circles default to `plus`. `ALRT_PLUS_TEST_UNLOCK` is an app flag only. | `src/services/entitlement.service.ts:31-57` |
| Auth | Email, Google, Apple, Microsoft, refresh, password reset. **No logout endpoint, no revocation, no refresh rotation**; only `passwordChangedAt` invalidates. | `src/routes/auth.route.ts:26-54`; `src/controllers/auth.controller.ts:331-358`; `src/utils/jwt.util.ts` |
| Devices | `POST` and `DELETE /api/notifications/push-notification-token`; `UserDevice {deviceToken, platform String?}` only; no device id, last seen, app version or platform enum; dead tokens pruned on FCM errors; sockets are per-user rooms, never per device. | `src/routes/notification.route.ts:26-38`; `prisma/schema.prisma:433-443`; `notification.service.ts:328-347`; `src/utils/socket_client.util.ts:19-21` |
| Push builder | Always `notification` + `data {payload, notificationType, urgent}`; Android `priority high`, channel by urgency, `tag` collapse key, `visibility private`, no `ttl`; APNs `apns-collapse-id`, `sound default`, `interruption-level` time-sensitive or active; **no `category`, no `apns-push-type`, no `thread-id`, never critical**. Chunked at 500. | `src/services/notification.service.ts:349-458` |
| Preferences | Only public hazard pushes honour `UserPushNotificationSetting` and the cooldown; every family type and the test push bypass them. No quiet-hours or DND model. | `notification.service.ts:157-190`; `family.service.ts:200-267` |
| Privacy in pushes | `pushSafeHazard` strips coordinates and reporter fields; check-in and SOS bodies carry no free text or place names. | `notification.service.ts:296-318`; `family.service.ts:1557-1561,2290-2292` |
| Dedupe | One public-alert push per person per hazard event via Redis `SET NX` (48 h) with in-process fallback; SOS response upsert; SOS trigger cancels the prior active event. **No idempotency on check-in, SOS trigger or journey points.** | `notification.service.ts:233-282`; `family.service.ts:2261-2265,2361-2372` |
| Family API | Circles (up to 4 owned, 8 seats, leave outcomes `left`, `deleted`, `hostTransition`, 7-day host grace), members, invites (7 days), location, location requests, check-ins, targeted check-in requests (`memberIds` ≤ 50 validated against the circle), scheduled check-ins, places, SOS lists (max 4), SOS, journeys. | `src/routes/family.route.ts:91-247` |
| Check-in rules | Body: `status?, message?, latitude?, longitude?, requestId?, hazardId?`; circle from `?circleId=`; coordinates stored only for `precise`; approximate is a suburb label refreshed after 1 km; `off` refused; snapshot TTL 1 hour; `requestId` **not validated against the circle**. | `src/validators/family.validator.ts:83-100`; `family.service.ts:1514-1537`; `family_alert.service.ts:37-102` |
| SOS rules | `isLive` required; one active SOS per member; acks refused on closed records and on self; owner gets a directed socket and push; 4-hour lapse sweeper deletes trail and coordinates and pushes the full row; history 30 days, locations stripped. | `family.service.ts:2261-2398,2549-2623` |
| Journeys | Start 15, 30 or 60; extend up to 60 at a time; 240 total; explicit recipients; live per journey. | `src/services/family_journey.service.ts:16-20,87,170-180` |
| Alerts | `/api/alerts/geo` exposes `sourceId` and `sourceName` only (no URL or licence); full `HazardSource` and `HazardSourceLicense` via detail; `aiSummary`, `callsToAction`, `updatedAt`, `expiresAt` in geo properties; no separate `issuedAt` (`occurredAt`). | `src/utils/geojson.util.ts:55-71`; `prisma/schema.prisma:232-279,328-356,641-658` |
| Ask ALRT | Not in this backend; `POST /api/user/firebase-token` mints the Firebase custom token; the service is `askalrt/` (Firebase Functions). README quotas (3 / 20) disagree with code (5 / 30). | `src/index.ts:128-135`; `askalrt/README.md:24-26`; `askalrt/functions/src/index.ts:15` |
| Version gating | None; no min-app-version endpoint and no app version on devices. | grep of `src/` |
| Wearable code | None. | grep of `src/`, `prisma/`, `docs/`, `scripts/` |

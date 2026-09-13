# ALRT on the wrist and on glasses: audit and phased plan

Date: 13 September 2026 (revision 2, same day). Author: Claude Code session for Sarah (safetyalrt.com).
Status: **audit and plan only. Nothing was built, deployed, purchased or configured.** No production, billing, store, scheduler, push-delivery, credential or database setting was touched, and none will be until the first milestone is approved separately. The only writes in this session are this document and its companion web page.

Revision 2 changes: findings from the older repositories and default branches are marked superseded and are not carried into the plan; the release-candidate `test` branch is the only baseline; the wearable material is described as design documents and an unverified scaffold; the TEST backend statement is worded as historical evidence; a new §4.5 explains what the notification pilot would change before anything is implemented; the Meta section is rebuilt from Meta's own published statements; §7 is rewritten as a minimum-hardware shopping recommendation for the Android-first order Sarah chose.

This document is written to be read top to bottom by Sarah, and to be handed to an engineer as-is. Every claim about code cites a file, a branch or a commit. Every claim about a platform cites the official page it was checked against on 13 September 2026, or says plainly that it could not be checked from this environment.

---

## 0. The short version

1. **The phone release is further along than the older repos suggest, and it lives in one place.** The current line is `ALRT-dev/ALRT-V1-Release-Candidate`, branch `test`, a monorepo (`frontend/`, `backend/`, `admin/`, `askalrt/`). The newest app build is **1.0.5 (51)**, commit `7eacfea`, built by GitHub run 34541544658 on 10 September 2026. Nothing newer exists in any of the twelve repositories. The TEST backend is `https://api-test.safetyalrt.com`. Its last verification supplied in this conversation is commit `f1f6b92`, completed on 10 September 2026 through the original verification run and the resumed final test (`verify --resume`, rollout script revision 14). That is **historical evidence from the repository record, not a fresh server observation**; this sandbox cannot reach the host. Builds 50 and 51 changed the app only, so the app on your phone is ahead of TEST by two app-only builds and TEST needs no redeploy for them.
2. **Build 51 has not been accepted on a phone.** The repository's own record (`V1_RECONCILIATION_REPORT.md` §36.7) says no phone-checklist item for builds 44 to 51 has been run from that environment, and the hardware columns (push delivery, lock screen, sound, vibration, widget rendering) are untested. There is **no iOS TEST build at all** (the iOS TestFlight workflow has never run), the iOS time-sensitive entitlement is absent, and the iOS widget target is not in the Xcode project. These stay open and are listed in §2 so wearable work cannot hide them.
3. **The existing wearable material is design documents and one unverified scaffold, not a wearable app.** `watchinterface` is a design handoff (an HTML click-through of 13 Wear OS screens plus specs written against a Firestore model the real backend does not use). `glasses` is a README on `main` plus an unmerged, never-compiled Android XR Kotlin skeleton on one branch. `occulo` and `mattv2` are empty. No watch or glasses code exists in the release line. The phone app has two reusable building blocks that matter: a text-to-speech alert reader and a tap-to-talk voice input, both on the release line.
4. **Recommendation: start with a phone-connected companion on whichever watch matches the phone you test with.** Google and Samsung watches only pair with Android phones; Apple Watch only pairs with iPhone. The first milestone is a **notification pilot with no watch app at all**: make the phone's existing check-in and SOS pushes reach the wrist with a clearly named "Check in to <circle>" action, and prove delivery on real hardware. That costs one to two engineering weeks plus device testing and answers the biggest unknown (whether wrist delivery is reliable) before a watch app is written. One finding shapes it: today a push that arrives while the app is closed carries **no action buttons on either platform** (the server sends a system-drawn notification with no APNs `category`, and Android has no background handler), so the pilot's first task is a small, flagged change to how two push types are shaped.
5. **Glasses are a second phase and are gated on access, not on our code.** Meta's Wearables Device Access Toolkit is a developer preview (v0.9) for camera, microphone and speaker on audio glasses, with display support on Meta Ray-Ban Display opened in May 2026; custom "Hey Meta" commands are not available to third parties, and publishing is reported as limited to selected partners until general availability. Android XR glasses have SDK previews and emulators but no consumer hardware yet. Meta's developer site could not be fetched from this sandbox, so those points must be re-confirmed on `developers.meta.com` before any glasses milestone is approved.
6. **Hardware, as of revision 2:** Sarah has a Samsung phone and an iPhone, no watch and no glasses, and can buy test hardware. Her chosen order is Android watch first, Apple Watch later, glasses only after a supported prototype path is confirmed. §7 gives the minimum shopping list for that order. Still needed before the first milestone is approved: the **exact Samsung and iPhone models and OS versions** (Galaxy watches need Android 12 or later; Pixel Watch 4 needs Android 11 or later). Nothing is to be purchased or implemented until Sarah approves the milestone separately.

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
| Backend at `f1f6b92` on `api-test.safetyalrt.com` | `V1_RECONCILIATION_REPORT.md` §36 "TEST verified at f1f6b92 (10 September 2026, 00:02:59Z)": original verification plus the resumed final test; rollout script revision 14 | yes | verify scripts (consent 40/40, eleven regression scripts, `verify_hazard_push_dedupe` 7) | yes, as historical record; **not observed from this sandbox** | n/a |
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

### 2.2 Historical repositories (superseded)

**Superseded, read this first.** During the audit I first examined the older repositories and their default branches (`frontendV2`, `backendV2`, `V2-Claude`, `v3`, `askalrt` standalone) before finding the release-candidate `test` branch. Findings from that first pass, such as "no TEST environment", "no tests or CI", "no push-token cleanup on logout", "no journeys", "no Ask ALRT", "FCM 500-token cap unhandled", described those repositories at the time and are **superseded**. The `test` branch has an isolated TEST environment, 52 test files run by CI, 24 backend verify scripts pinned by the rollout, push-token removal on sign-out and account deletion, journeys, urgent flags, dead-token pruning and hazard-push dedupe. None of the superseded findings is carried into the plan. Only facts verified on the `test` branch (Appendix A and B) are used.

| Repository | What it is | Latest | Verdict for wearables |
|---|---|---|---|
| `ALRT-V1-Release-Candidate` `main` | Four planning documents (release plan, source registry, pipeline, backlog) | `1d2271f`, 22 Aug | Planning only; `test` branch is the code |
| `ALRT-V1-Release-Candidate` `claude/test-app-audit-p5djd2` | Ancestor of `test` (fully merged) | `8e0f34f`, 7 Sep | Superseded |
| `ALRT-V1-Release-Candidate` `claude/alrt-v1-rc-audit-a3gmai` | Stage 9B to 12 work; **not** an ancestor of `test` (`git merge-base` confirms); `test` merged it via `ea85cd3` then diverged | `fc87fb1`, 5 Sep | Do not merge again |
| `frontendV2` | Older Flutter app; `main` at 1.0.3+33 (26 Jul); audit branch at 1.0.5+35 (20 Aug, 156 commits ahead of main) | `1e1d9cf` | **Superseded** by the monorepo `frontend/`; no wearable code (grep of `lib/`, `ios/`, `android/`: zero real hits). Earlier findings about this repo are not used |
| `backendV2` | Older backend; `main` at `5ce3825` (8 Jul); audit branch +75 commits (20 Aug) | `9f36208` | **Superseded** by monorepo `backend/`; no wearable code. Earlier findings about this repo are not used |
| `V2-Claude` | Older Flutter lineage 1.0.3+33; `feature/voice` (tap-to-talk, `speech_to_text`), `ci/ios-testflight` | `2e7bac1`, 3 Aug | Voice work already carried into the release line; nothing else to recover |
| `v3` | Zip archive of the launched 1.0.4+34 app | `94c5394`, 20 Aug | Reference only |
| `askalrt` | Firebase Functions Ask ALRT (`askAlrt` callable, Anthropic SDK, quotas 5 free / 30 ALRT+) | `c26115d`, 7 Sep | Reusable for spoken answers; response is `{answer, source, usedAI, refused?}` with **no citation array**, attribution is inside the prose |
| `watchinterface` | V2 design handoff: `prototype/ALRT Wear OS.dc.html` (13 screens), `backend/wear-os-standalone-sos-spec.md`, product rules | `e98b660`, 6 Aug | **Design documents only; no app.** Screens and copy reusable; data model obsolete (Firestore `onSosStart`, `sosEvents`, `liveShareSessions`, `widgetPayload/{uid}`; the real backend is Postgres + REST + Socket.IO). Its "standalone install, never through a phone relay" rule conflicts with the companion-first decision below. Its hold 3 s + 5 s countdown + 12 s undo differs from the phone's 3 s hold; pricing $7.99 differs from the locked $9.99 |
| `glasses` | `main`: README + `.gitignore`. Branch `feat/glasses-android-xr-scaffold` (3 commits, 26 Jul): `docs/ar-glasses-launch-spec.md`, Kotlin skeleton (`AlrtApi.kt`, `SosController.kt`, `HudState.kt`, `VoiceCommand.kt`), a CI that skips because no Gradle wrapper is committed | `cbab4ed` | **A launch spec and an unverified scaffold; never compiled, never run, no app.** The REST endpoints it names match the real backend. Its "navigate to safety" AR route overlay, wake-word voice, look-to-identify and phone-less SOS are **out of scope by your rules** (no guaranteed evacuation routes, no wake word, no AI hazard detection). Reusable: the sharing-level clamp idea in `SnapshotPolicy` and the acceptance-test style |
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

**How the Meta column was checked.** Every Meta host (`developers.meta.com`, `wearables.developer.meta.com`, `about.fb.com`) is blocked by this sandbox's network policy. The Meta statements below are the wording of Meta's own pages as returned by web search against those domains only (the toolkit FAQ, the "Introducing the Meta Wearables Device Access Toolkit" and "Build for display glasses" blog posts, and the `wearables.developer.meta.com` docs). They are Meta's words, but the pages themselves were not opened here. **Before any glasses purchase or milestone, open `developers.meta.com/wearables/faq/` and `wearables.developer.meta.com/docs` and confirm each row.** No claim below about voice commands or display access goes beyond Meta's published text.

| Question | Meta glasses (Wearables Device Access Toolkit) | Android XR glasses (Jetpack XR SDK) |
|---|---|---|
| Which devices have a display | **Audio-only (camera, microphones, open-ear speakers, no display):** Ray-Ban Meta Gen 1 and Gen 2, Ray-Ban Meta Optics, Oakley Meta HSTN, Oakley Meta Vanguard. **Display:** Meta Ray-Ban Display (monocular in-lens display, Meta Neural Band wristband) | "Audio glasses" (speaker, camera, microphone, no display) and "display glasses" (additive display); consumer devices announced for later 2026, pre-release hardware via Google's Catalyst program ([devices](https://developer.android.com/develop/xr/devices), [glasses/build](https://developer.android.com/develop/xr/jetpack-xr-sdk/glasses/build)) |
| SDK status | Meta: "The Wearables Device Access Toolkit is in developer preview." Mobile SDK for iOS (Swift) and Android (Kotlin); "MockDeviceKit" for testing without glasses. Display: "rolling out access to the display on Meta Ray-Ban Display glasses with two build paths: for mobile apps and Web Apps, both in developer preview" (announced May 2026) | Developer Preview 4 (May 2026); SceneCore, ARCore for Jetpack XR and XR Runtime in beta (Aug 2026); Compose Glimmer for glasses UI; emulator AVDs for glasses |
| Capabilities | Meta: "video streaming, photo capture, microphone and audio, and on Meta Ray-Ban Display glasses, access to the on-device display." Display UI components: "text, images, lists, buttons, and video playback." Web Apps "can access motion and orientation data from the glasses, GPS from a connected phone, input from both the Meta Neural Band and captouch, and local storage" | Projected activities: "the activity … doesn't run directly on the device, but is instead projected to the device from a host device (such as user's phone)"; `ProjectedContext` gives access to glasses camera, sensors, audio ([projected context](https://developer.android.com/develop/xr/jetpack-xr-sdk/access-hardware-projected-context)) |
| Voice commands and "Hey Meta" | Meta: "accessing the Meta AI capabilities of the glasses, including voice commands, isn't part of the initial developer preview"; "the team is working on voice invocation and Wifi direct." So: **no custom "Hey Meta" commands and no wake word for third parties today.** A third-party app can process microphone audio with its own on-device recognition | On-device ASR and TTS APIs are part of the SDK; no wake word for third parties documented |
| Phone requirements and pairing | Meta: same OS requirements as the Meta AI app, "iOS 15.2+ and Android 10+"; developers "must connect their glasses to the Meta AI app and enable developer mode in the Meta AI app" | Projected context valid only while `isProjectedDeviceConnected()` is true |
| Background or phone locked | **Not stated in the text retrieved.** Session states, pause and resume are documented topics. Must be tested on hardware before any claim | Lifecycle tied to the host app |
| Who may publish | Meta: "Developer Preview means developers can build and test experiences, but cannot yet distribute them to end users"; developers "can share what they've built to testers within their organizations and teams, but only select partners will be able to publish their integrations to the general public." | No consumer hardware yet |
| Country eligibility | Meta: "developers everywhere will be able to download the SDK, but only those in AI glasses supported countries will have access to the full capabilities of the toolkit, including the Wearables Developers Center." Australia is listed among AI-glasses supported countries in the retrieved text; confirm on the FAQ | Catalyst program, by application |
| Australian retail availability | Ray-Ban Meta Gen 2 sold in Australia from A$629 (meta.com/au, ray-ban.com/australia). **Meta Ray-Ban Display is not sold in Australia**; Meta paused its international rollout in January 2026 citing US demand and limited inventory (press reports; no Australian launch date) | None to buy |

Reading: **audio-only glasses are the realistic second phase**, because the phone already has the spoken-alert reader and the voice input, and the glasses add only a microphone and a speaker over Bluetooth. Display cards come after, and only on hardware you actually hold; Ray-Ban Display cannot currently be bought in Australia. Nothing in either SDK supports "independent connectivity" for a third-party safety app today, so the glasses never hold a session. Under Meta's preview terms an ALRT glasses integration could be tested with your own testers but **not published to the public** until Meta opens publishing beyond selected partners; that is a gate on the glasses phase, not on the watch.

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

### 4.4 Backend changes (proposed only; none is to be made now)

Per Sarah's instruction, **the scheduler setting and the existing push delivery are not to be changed yet.** The rows below are the proposals that would be put to her, each separately, when the corresponding phase is approved.

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

### 4.5 Before the notification pilot: what would change, and how the phone keeps working

This section is the explanation Sarah asked for before any implementation. It describes a proposal. Nothing here has been started.

**Which notification types would change.** Two of the fifteen push types only: `familyCheckInRequest` and `familySos` (the list is `backend/src/models/push_notification_types.ts:1-24`). Hazard alerts, check-in responses, stand-downs, location requests, journeys, badges and the test notification keep their exact current shape. The pilot is gated by one server-side flag (proposed name `WEARABLE_ACTIONABLE_PUSH`, default off) so the change can be turned on for TEST accounts only and turned off without a redeploy.

**Which files would change.**

- Backend `src/services/notification.service.ts` (the builder at lines 349 to 458): when the flag is on and the type is one of the two, add `apns.payload.aps.category` (`ALRT_CHECKIN_REQUEST` or `ALRT_SOS_RECEIVED`), add the `apns-push-type: alert` header, and move the Android copy to a data-only shape (drop the top-level `notification` block for Android by putting the title and body in `apns.payload.aps.alert` for iOS and in `data` for Android). Everything else in the builder is untouched.
- Backend `src/services/family.service.ts` where the two pushes are composed (check-in request around line 1557, SOS around line 2290): the body gains the circle name and the requester names, in the same private wording style already used (no free text, no place names).
- Backend `src/scripts/verify_family_push_delivery.ts`: two new checks for the two shapes, run by the rollout before deployment to TEST.
- App `frontend/lib/features/notification/services/notification_service.dart`: a top-level `@pragma('vm:entry-point')` background handler registered with `FirebaseMessaging.onBackgroundMessage`, which draws a local notification with actions for the two types only and ignores every other type.
- App `frontend/lib/features/notification/services/local_notification_service.dart`: two new category and action definitions, "Check in to <circle>" (background action, no user interface) and "Open on phone" (foreground). The existing `alrt_im_safe` action stays for the foreground path.
- App `frontend/lib/features/family/providers/family_provider.dart` and `family_service.dart`: no behavioural change; the background action calls the existing `checkIn(shareLocation: false)` path with the `requestId` and the circle id already carried in the push payload. Native: none on Android for the pilot; on iOS the categories are registered from Dart as today.

**How existing phone notifications remain working.**

- With the flag off, the server sends exactly what it sends today and the app's new handler receives nothing new. The current acceptance checklist (item 12) stays valid as written.
- With the flag on, iOS still receives a system-drawn alert with sound and interruption level as today; it only gains a category. Android receives a data message; the new handler draws it on the same channel (`alrt_alerts` or `alrt_alerts_urgent`), with the same stable id (`_notificationIdFor`), the same private visibility and the same tap routing, so the tray behaves as before. The foreground path (`onMessage`) is unchanged.
- The regression risk is the Android data-only path being dropped by the OS when the app is force-stopped or battery-restricted. That is precisely what the device tests must observe, and why the pilot runs behind the flag on TEST before any store build carries it.

**How duplicate notifications and duplicate check-ins are prevented.**

- One notification per event: the server keeps its tray collapse key (`tag` on Android, `apns-collapse-id` on iOS) and the app keeps its stable per-event id, so a redelivered or replayed push replaces the earlier one instead of stacking. On Wear OS the bridged copy is the phone's notification, so dismissing on either device dismisses both once `setDismissalId` is set to the same event key. On Apple Watch mirroring already syncs dismissal.
- One check-in per tap: the action carries the `requestId`. Server-side, the pilot needs the `requestId` uniqueness proposed in §4.4 (a client-generated key on `POST /api/family/check-in`), which needs a migration and is therefore **the one backend item that must be approved before the pilot rather than after**. Until then the app-side guard is: the background handler records the request id it has answered and refuses a second post for the same id, and the foreground path (`checkInRequestOwedByMe`) already clears the ask on the next circle load. A check-in from the phone and the wrist within seconds would otherwise create two rows and two pushes to the circle; the server key closes that.
- No double display when a watch app is added later: Wear OS bridging is switched off per type with `BridgingManager` only in Phase 2, when the watch app draws its own copy. In the pilot there is no watch app, so bridging stays on.

**What happens when the phone is locked, disconnected, or cannot confirm delivery.**

- Phone locked, watch on wrist: Apple forwards the notification to the watch only when the iPhone is locked or asleep and the watch is unlocked and worn; Wear OS bridges regardless of lock state. The action runs on the phone in the background. The user sees "Sending…" on the phone's follow-up notification, then "Checked in to <circle> · time" only when the server has answered.
- Phone disconnected from the network: the action is attempted, fails, and the follow-up notification reads "Check-in to <circle> not sent · open ALRT". Nothing is queued for silent later delivery; the next deliberate tap sends it. The watch shows whatever the phone's notification shows, because it has no state of its own in the pilot.
- Phone cannot confirm (request sent, no answer): the state is "uncertain". The app asks the server (`GET /api/family/check-ins` for the request id) before offering a retry, the same pattern the SOS screen already uses (`findMyActiveSos`). If the server has the row, the follow-up says confirmed; if not, it offers "Try again". No automatic retry.
- Watch out of range of the phone: no notification reaches it; nothing is lost, because the phone still holds the notification and the tap can be made there.
- Phone off: nothing reaches the wrist. The pilot does not change this; it is one of the honest limits of a companion, and the device-status card must say so.

**What hardware testing and rollback controls are required.**

- Hardware: two phones with TEST accounts (Sarah's Samsung as phone A with the watch, a second Android or the iPhone as phone B), one Wear OS watch paired to phone A. The iPhone path is blocked until an iOS TEST build exists and the time-sensitive capability decision is made; the Android pilot does not wait for it.
- Tests before the flag is turned on for anyone else: the matrix in §8 rows "App state", "Uncertain requests", "Duplicates", "Circles and requesters", "Accounts and devices" and "Notifications", recorded per the build 51 convention (device pass, device fail, awaiting device, blocked). Automated `verify_family_push_delivery` checks prove the message shape only.
- Rollback: the server flag off restores today's shape immediately without a redeploy or migration; the app change is inert with the flag off, so an app rollback is not needed. The rollout script's existing controls apply (rollback tag, image id, restore-tested backup, `--no-new-migrations` mode) if the `requestId` migration is approved and deployed. TEST first, and only TEST accounts, until Sarah accepts the results on hardware.

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

## 7. Minimum hardware for the first milestone, and what comes later

Sarah's position (13 September): a Samsung phone and an iPhone, no watch, no glasses, willing to buy for testing; order of work Android watch first, Apple Watch later, glasses only after a supported prototype path is confirmed. **Nothing is to be bought until the exact phone models and OS versions are confirmed and the milestone is approved.** Prices are Australian retail as found on 13 September 2026 and will move; check the linked store page before ordering.

### 7.1 What to confirm first

- The Samsung phone's model and Android version (Settings › About phone › Software information). Galaxy watches on Wear OS need **Android 12 or later with more than 1.5 GB of memory** (Samsung newsroom, Galaxy Watch8 announcement); Pixel Watch 4 needs Android 11 or later (Google Pixel Watch compatibility page). Both need Google Mobile Services, which every Australian retail Samsung has.
- The iPhone's model and iOS version (Settings › General › About). Apple Watch SE 3 and Series 11 need iOS 26 on the paired iPhone per Apple's current pages; confirm on apple.com/au for the exact model bought.

### 7.2 Android notification pilot: one watch

| Option | Model | Why | Approx. AU price | Enables |
|---|---|---|---|---|
| **Recommended** | Samsung Galaxy Watch8, 40 mm, Bluetooth (Wear OS 6, One UI 8 Watch) | Pairs with any Android 12+ phone; Samsung phone gives the fullest pairing experience through the Galaxy Wearable app; current Wear OS; widely stocked in Australia; the newer Galaxy Watch9 (announced 22 July 2026, released 7 August, Wear OS 7) is the same platform at a higher price and is not needed for the pilot | RRP A$649 at [samsung.com/au](https://www.samsung.com/au/watches/galaxy-watch8/buy/); seen at A$648 at Harvey Norman and lower at discounters | Milestone 1 in full: bridged actionable notifications, dismissal sync, tile and complication work in Phase 2, Data Layer companion |
| Lower cost | Samsung Galaxy Watch FE, Bluetooth | Same Wear OS platform, older hardware; adequate for the pilot and Phase 2; slower for Phase 3 | A$399 RRP (Samsung AU) | Same as above; battery and performance results will not represent current hardware |
| Alternative | Google Pixel Watch 4, 41 mm, Wi-Fi | The `watchinterface` prototype was drawn for Pixel Watch; pairs with a Samsung phone (Android 11+); reference Wear OS build | A$579 RRP at [store.google.com/au](https://store.google.com/au/product/pixel_watch_4); seen at A$378 at Officeworks | Same as above; useful later to confirm behaviour on non-Samsung Wear OS |

Buy **one** watch. A second Wear OS model is only worth it in Phase 2, to prove the companion on both Samsung and Google skins.

### 7.3 Bluetooth and Wi-Fi versus cellular

Bluetooth plus Wi-Fi is sufficient for Milestone 1 and Phase 2. Google's documentation states that when a watch has a Bluetooth connection to a phone "the watch's network traffic is generally proxied through the phone", and the platform moves between Bluetooth, Wi-Fi and cellular automatically ([network access](https://developer.android.com/training/wearables/data-layer/network-access)). In the pilot the watch never talks to the backend at all; it shows the phone's notifications. Cellular is genuinely required only for Phase 3 (standalone: watch-originated SOS with the phone left at home), which needs its own session, push token and tests. On the Pixel Watch 4 the 4G model costs A$170 more; on Galaxy Watch8 the LTE variant is likewise a separate SKU and a carrier plan. **Do not buy cellular for the pilot.**

### 7.4 Australian availability, developer support and accounts (Android path)

- Availability: Galaxy Watch8, Galaxy Watch FE and Pixel Watch 4 are all sold through Australian retail (Samsung AU, Google Store AU, JB Hi-Fi, Harvey Norman, Officeworks).
- Official developer support: Wear OS is a first-party Android target with current documentation for notifications, bridging, Tiles, complications, Ongoing Activities and the Data Layer (links in §3.1). Wear OS apps ship through the existing Google Play Console listing as an Android App Bundle; new apps must target API level 34 or later.
- Accounts: a Google account on the phone (required for the watch), a Samsung account for a Galaxy watch (the Galaxy Wearable app asks for it), the existing Google Play Console (no new fee), the existing Firebase project `alrt-a6539`, and the existing TEST keystore, because a Wear module must be signed with the same key as the phone app for the Data Layer. No purchase beyond the watch.

### 7.5 Later, for Apple Watch

- Watch: Apple Watch SE 3, 40 mm, GPS, from A$399 at [apple.com/au](https://www.apple.com/au/shop/buy-watch/apple-watch-se); or Series 11 from A$679. (Apple has announced Series 12; pricing was not confirmed here.) SE 3 is enough for the companion phase.
- A Mac with Xcode is required to add the watch target and the widget target to the Xcode project, register the App Group and the Time Sensitive capability, and run on a cabled device. A Mac mini (M4) is the least expensive route; confirm the current price on apple.com/au (retail listings vary widely). The alternative is the paid macOS GitHub runner already scripted in `ios-test-testflight.yml`, which has never run and still needs the App Store Connect API key and fastlane match secrets; it can build and upload, but cannot do the one-off Xcode project changes.
- Accounts: the existing Apple Developer Program team `JR89M7CYPR` (about A$150 a year, already held); new App IDs for `com.safetyalrt.alrt.dev.watchkitapp`, the App Group `group.com.safetyalrt.alrt.dev` and the Time Sensitive Notifications capability. Critical Alerts are **not** proposed.
- Dependency: the iOS TEST build must exist before any Apple Watch work; producing it is the first Apple-side task, not buying a watch.

### 7.6 Glasses: verify before buying anything

- **Audio glasses (no display):** Ray-Ban Meta Gen 2 is sold in Australia from A$629 ([meta.com/au](https://www.meta.com/au/ai-glasses/)). Meta's toolkit gives a phone app camera, microphone and speaker access; voice commands and Meta AI are not available to third parties in the preview; distribution is to your own testers only until Meta opens publishing. Australia appears in Meta's list of supported countries for the toolkit's full capabilities, per the retrieved text. **Confirm on `developers.meta.com/wearables/faq/` before purchase**, and confirm that a developer account under the ALRT organisation can enrol in the preview.
- **Display glasses:** Meta Ray-Ban Display is **not sold in Australia** and Meta paused its international rollout; Android XR display glasses have no consumer hardware yet. Do not plan a display purchase for 2026.
- What a Gen 2 pair would enable once the path is confirmed: spoken alert summaries and spoken check-in requests routed through the phone, a confirmed check-in by temple press or spoken yes, deliberate SOS with a spoken countdown, and user-initiated photo capture for a report reviewed on the phone. It would not enable custom "Hey Meta" commands, always-on listening or any display.

### 7.7 Shopping summary (do not order yet)

| Now (after phone models are confirmed and Milestone 1 is approved) | Later | Not yet |
|---|---|---|
| One Galaxy Watch8 40 mm Bluetooth (about A$649, often less), or Galaxy Watch FE (A$399) as the lower-cost option | Apple Watch SE 3 (from A$399) plus Mac access, once an iOS TEST build exists | Any cellular watch; any display glasses; Ray-Ban Meta Gen 2 until the developer-preview terms are confirmed on Meta's site |

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

## 12. Open questions for Sarah

1. Exact Samsung phone model and Android version, and exact iPhone model and iOS version.
2. Is a Mac with Xcode available for the later Apple Watch work, or should the paid macOS runner be used?
3. Was `ALRT-dev/widget` renamed to `frontendV2`, or deleted?
4. For the pilot, the one backend item that should be approved before rather than after: a client-generated `requestId` uniqueness on `POST /api/family/check-in` (one column and index, one migration). Everything else in §4.4 waits for Phase 2.

Answered on 13 September: Sarah has a Samsung phone and an iPhone, no watch or glasses, can buy test hardware; order is Android watch first, Apple Watch later, glasses after a supported path is confirmed; `api-test.safetyalrt.com` is the TEST backend; the scheduler and push delivery are not to be changed yet; Sarah will approve the first milestone separately.

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

# Launching ALRT on the wrist with V1: what is required

Date: 6 October 2026. Status: **audit and plan only.** Nothing was built, deployed, purchased or configured. The scheduler, existing push delivery, TEST environment, store listings and signing were not touched. Implementation waits for Sarah's hardware details and separate approval of the first milestone.

Baseline: the release-candidate monorepo, tip branch `claude/community-alerts-privacy-and-points` (contains `test`), app **1.0.5+52**. Findings from the older repositories and default branches (`frontendV2`, `backendV2`, `V2-Claude`, `v3`, standalone `askalrt`) are **superseded** and are not used here (e.g. "no TEST environment", "no tests", "no push-token cleanup" described those old repos, not the release line). See `PROJECTS_INDEX.md` for the full repository map.

This document updates `WEARABLES_AUDIT_AND_PLAN.md` (branch `claude/focused-brown-8ptpdl`, 13 September, revision 2) for what has changed since, and answers one question: **what does it take to ship Apple Watch (and Wear OS) support with this release?**

---

## 1. The short answer

| Option | What the user gets at V1 launch | Watch code | Effort | Risk to V1 date |
|---|---|---|---|---|
| **A. Wrist pilot (recommended for V1)** | ALRT check-in requests and SOS alerts appear on Apple Watch and Wear OS with a named **"Check in to <circle>"** action and **"Open on phone"**. Result shown only after the server confirms. | **None.** Uses the watch's built-in mirroring of phone notifications | 1–2 weeks engineering + 3–5 days device testing | Low; behind a server flag, off by default |
| B. Native Apple Watch companion app | A real ALRT watch app: tile/complication, circle switcher, check-in, hold-to-send SOS, journey extend/finish, alert summaries | New SwiftUI watchOS target + WidgetKit complication + WatchConnectivity bridge | 7–10 weeks (Swift engineer) | **High.** Would push V1 by about two months |
| C. Standalone / cellular watch | Watch works with the phone left at home | Option B + its own sign-in, push token, revocation | +4–8 weeks on top of B | Not V1 |

**Recommendation:** ship V1 with **Option A on both platforms**, and say "ALRT alerts and check-ins on your watch" rather than "ALRT watch app". Plan Option B as V1.1.

The website copy on `alrt` (redesign branch) currently says "The watch works without the phone". That is Option C, and it is not in any V1 plan. It must change before launch.

---

## 2. What changed since the 13 September plan

| 13 Sep plan said | Now (6 Oct, verified on tip branch) | Effect on the watch |
|---|---|---|
| "There is no iOS TEST build at all; the iOS TestFlight workflow has never run" | **iOS Dev TestFlight succeeds.** Runs 21, 24, 25, 26, 27, 28 all succeeded (latest 6 Oct 12:14 UTC, tip branch). Signing via fastlane match `ci_certs_dev`, upload via `ci_upload_dev` to the "ALRT Dev" app | **The biggest Apple Watch blocker is gone.** Apple Watch no longer has to wait for "Apple later" on pipeline grounds; the Option A pilot can run on iPhone + Apple Watch through TestFlight |
| SOS max 4 hours | **SOS lasts 1 hour; sender extends or ends** (`SOS_MAX_DURATION_MS`, `backend/src/services/family.service.ts`) | Wrist SOS state must show time remaining and "Extend"/"End" for the sender |
| Phone speaks alerts automatically in some paths | **Read aloud only when the user taps Listen** (commits `deef3bc`, `5e2211e`) | Glasses/watch must never speak automatically either |
| Ask ALRT on Firebase Functions | **Ask ALRT is in the backend** (`POST /api/ask-alrt`); Firestore, Firebase Auth, App Check removed (`7a058f6`). Firebase Core + Messaging remain for push | `watchinterface`'s Firestore data model is now doubly obsolete; FCM/APNs path is unchanged |
| Trial 1 month | Trial 2 weeks | No watch effect |

TEST backend: `https://api-test.safetyalrt.com`. The last verification supplied in this conversation is commit `f1f6b92`, completed on 10 September 2026 through the original verification run and the resumed final test. That is **historical evidence from the repository record, not a fresh server observation**. This sandbox cannot reach the host, and the 6 Oct backend commits (Ask ALRT move, blocking enforcement) have not been shown to be deployed to TEST.

### Still true (re-verified on the tip branch today)

- No watch or wearable code exists anywhere in the release line. The `watchinterface` repo holds design documents (an HTML Wear OS prototype and specs). The `glasses` repo holds a README plus one **unverified, never-compiled** Android XR scaffold on an unmerged branch. Neither is a completed wearable app.
- Pushes carry **no APNs `category`** (`backend/src/services/notification.service.ts`, the `apns.payload.aps` block sets only `sound` and `interruption-level`). An iOS notification drawn by the system, which is what Apple Watch mirrors, therefore has **no action buttons**.
- There is **no `FirebaseMessaging.onBackgroundMessage` handler** in `frontend/lib`. An Android notification arriving while the app is closed has no actions either.
- The `com.apple.developer.usernotifications.time-sensitive` entitlement is **absent** from `Runner.entitlements` and `Runner-dev.entitlements`. Urgent pushes arrive as ordinary alerts on iPhone and watch.
- `frontend/ios/AlrtWidget/*` exists but is **not a target** in `Runner.xcodeproj` (0 references), so the iOS home-screen widget is not built.
- The phone already registers Darwin categories (`ALRT_CHECKIN_PROMPT`, action `alrt_im_safe`, `local_notification_service.dart:333-380`), but they apply only to notifications the app draws itself in the foreground.

---

## 3. Option A for V1: everything required, by layer

This is the pilot already specified in `WEARABLES_AUDIT_AND_PLAN.md` §4.5, now for **both** platforms because the iOS pipeline exists. It is still a proposal; nothing below has been started.

### 3.1 Backend (`backend/`)

| # | Change | File | Migration | Approval |
|---|---|---|---|---|
| B1 | Server flag `WEARABLE_ACTIONABLE_PUSH`, default **off** | `src/utils/config.ts` | No | Milestone 1 |
| B2 | When the flag is on, **only** `familyCheckInRequest` and `familySos`: add `apns.payload.aps.category` (`ALRT_CHECKIN_REQUEST`, `ALRT_SOS_RECEIVED`) + `apns-push-type: alert` header. Android gets a data-only shape so the app draws it with actions. Every other push type is unchanged | `src/services/notification.service.ts` (builder ~lines 349–458) | No | Milestone 1 |
| B3 | Push body names the circle and requester(s); carries `circleId` and `checkInRequestId` in `data` | `src/services/family.service.ts` (check-in request and SOS composition) | No | Milestone 1 |
| B4 | Client-generated `requestId` (UUID), unique per user, on `POST /api/family/check-in` | `prisma/schema.prisma`, `family.service.ts`, `family.controller.ts` | **Yes** (one column + index) | **Must be approved before the pilot**, because it is the server-side duplicate guard |
| B5 | Validate that the answered check-in request belongs to the posted circle | `family.service.ts` `createCheckIn` | No | Milestone 1 |
| B6 | Two new checks in the push-shape verifier | `src/scripts/verify_family_push_delivery.ts` | No | Milestone 1 |

**Not changed:** the scheduler (`RUN_SCHEDULED_JOBS_IN_TEST` stays as is), hazard-alert pushes, collapse keys, Android channels, existing delivery.

### 3.2 Phone app (`frontend/`)

| # | Change | File |
|---|---|---|
| F1 | Top-level `@pragma('vm:entry-point')` handler registered with `FirebaseMessaging.onBackgroundMessage`. It draws actionable notifications for the two types only and ignores all others | `lib/features/notification/services/notification_service.dart` |
| F2 | New categories/actions: **"Check in to <circle>"** (runs in the background, no UI, **sends no location**) and **"Open on phone"** (foreground). Register the iOS categories at launch so the system-drawn notification, and therefore the watch, shows them | `lib/features/notification/services/local_notification_service.dart` |
| F3 | Background action calls the existing `checkIn(shareLocation: false)` with `requestId`, `circleId` and `checkInRequestId`. A follow-up notification shows Sending → Checked in to <circle> · time (only after the server answers), or Not sent, or Uncertain | `family_provider.dart`, `family_service.dart` (no behaviour change to existing paths) |
| F4 | App-side guard: remember answered `checkInRequestId`s and refuse a second post | same |
| F5 | Android: `setDismissalId` = event key so dismissing on the watch clears the phone and vice versa. Bridging stays **on** (there is no watch app) | Android notification details in F2 |

### 3.3 iOS / Apple configuration (for Apple Watch specifically)

| # | Item | Where | Needs |
|---|---|---|---|
| A1 | Add the **Time Sensitive Notifications** capability to App IDs `com.safetyalrt.alrt.dev` (TEST) and later `com.safetyalrt.alrt` (prod); add `com.apple.developer.usernotifications.time-sensitive` to both entitlements files; regenerate match profiles (`ci_certs_dev generate:true` for dev) | Apple Developer portal (team `JR89M7CYPR`), `Runner*.entitlements`, `ios-certificates` repo | Sarah's approval; Apple portal access. **Critical Alerts are not proposed** |
| A2 | Nothing else on iOS. Apple Watch mirrors iPhone notifications, including category actions, when the iPhone is locked and the watch is worn and unlocked. The action runs on the iPhone | n/a | n/a |

Without A1 the pilot still works, but an SOS will not break through a Focus mode on the iPhone or watch.

### 3.4 CI / release

- Both existing workflows (`android-test.yml`, `ios-test-testflight.yml`) build the change unchanged. No new workflow, target or signing identity is needed for Option A.
- App Store / Play: no new listing and no watch screenshots. Release notes should say "check-in and SOS notifications now have actions you can use from your watch".

### 3.5 How existing phone notifications keep working, duplicates, offline, rollback

These are answered in full in `WEARABLES_AUDIT_AND_PLAN.md` §4.5 and still hold. In short:

- **Flag off:** the server sends exactly what it sends today.
- **Flag on:** iOS gains a category only. Android draws the same two types itself, on the same channel, with the same stable id, private visibility and tap routing. All other types are untouched.
- **Duplicates:** existing collapse keys (`tag` on Android, `apns-collapse-id` on iOS) and stable ids stop repeated notifications. The B4 `requestId` uniqueness plus the F4 app guard stop duplicate check-ins. Dismissal syncs via `setDismissalId` (Wear OS) and native mirroring (Apple).
- **Phone locked:** the action runs in the background on the phone, and the watch shows the phone's follow-up.
- **Disconnected:** "Not sent · open ALRT". Nothing is queued silently.
- **No answer:** "Uncertain". The app asks the server before offering a retry, and never retries automatically.
- **Phone off or out of range:** nothing reaches the wrist. This is an honest limit of a companion.
- **Rollback:** turn the flag off. No redeploy and no app rollback. TEST accounts only until Sarah accepts the results on hardware.

---

## 4. Option B (native Apple Watch app), for planning V1.1

Listed so the cost is visible. **Not recommended for the V1 date.**

| Area | Required |
|---|---|
| Code | `frontend/ios/AlrtWatch/` SwiftUI watchOS app target embedded in Runner; WidgetKit accessory complication; `WCSession.updateApplicationContext` payload (reuse Family widget payload v2: one row per circle, no member names or locations); method channels in `frontend/lib/features/wearable/`. Flutter cannot target watchOS |
| Backend | B4 extended to SOS trigger/respond and journey extend/stop; `deviceKind` on `UserDevice`; refresh-token revocation before any standalone phase |
| Apple setup | New App IDs `com.safetyalrt.alrt.watchkitapp` (+ `.dev.watchkitapp`), App Group membership, match profiles for each, `ExportOptionsCI*.plist` `provisioningProfiles` entries for the watch bundle IDs, `ci_upload_dev` bundle-ID check extended |
| Xcode project | Adding targets is safest on a **Mac with Xcode**. It can be scripted on the macOS runner (`xcodeproj` gem), but debugging on a cabled watch needs a Mac. Do the same for the unbuilt `AlrtWidget` target at the same time |
| Store | Watch screenshots, watch App Store review, and the watch app shown on the product page |
| Product conflicts to resolve | `watchinterface` uses a 3 s hold + 5 s countdown + 12 s undo for SOS (the phone uses a 3 s hold), a $7.99 price (locked: $9.99), and "standalone, never through a phone relay" (conflicts with companion-first) |
| Effort | 7–10 weeks for one Swift engineer, plus device testing |

---

## 5. Hardware, tests and decisions still open

Hardware advice is unchanged from `WEARABLES_AUDIT_AND_PLAN.md` §7, with one change: the Apple Watch no longer has to wait for an iOS TEST build, because one now exists.

| Device | Approx. AU price | Enables |
|---|---|---|
| Samsung Galaxy Watch8 40 mm Bluetooth (or Galaxy Watch FE, lower cost) | A$649 RRP, often less (FE A$399) | Option A on Wear OS: bridged actions, dismissal sync, duplicate and offline tests |
| Apple Watch SE 3 40 mm GPS | from A$399 | Option A on Apple Watch through TestFlight build 52+: mirrored category actions, locked-iPhone path, Time Sensitive behaviour once A1 is approved |
| Mac with Xcode | confirm on apple.com/au | Only for Option B and the iOS widget target. **Not needed for Option A** |
| Cellular watch, any glasses | n/a | Not V1 |

The Apple Watch SE 3 has moved from "later" to "candidate for V1". The order (Android first, Apple later) is still Sarah's call. Prices are from 13 September and must be re-checked before ordering.

**Decisions needed from Sarah, in order:**

1. Exact Samsung and iPhone models and OS versions (Galaxy watches need Android 12+; current Apple Watch models need a recent iOS on the paired iPhone; confirm on apple.com/au).
2. V1 wrist scope: Option A (recommended) or delay V1 for Option B.
3. Whether to pilot both platforms in V1, or Wear OS first as previously chosen.
4. Approve the B4 `requestId` migration (the only migration before the pilot).
5. Approve the Time Sensitive capability (A1).
6. Change the website watch copy.
7. Glasses remain out of V1. Meta capabilities must be reconfirmed on Meta's current official documentation before any claim or purchase. Nothing in this document makes a new Meta claim.

**Exit criterion for Option A:** the device matrix in `WEARABLES_AUDIT_AND_PLAN.md` §8 (rows App state, Uncertain requests, Duplicates, Circles and requesters, Accounts and devices, Notifications) is recorded as device pass on each watch shipped. Unit tests, emulators and screenshots never fill a device column.

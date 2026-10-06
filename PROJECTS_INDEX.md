# ALRT projects index: every repository, in order

Date: 6 October 2026. Scope: all 13 repositories in the `ALRT-dev` organisation, every branch, checked against the live remotes on this date.

This file is the single map of where ALRT lives. It answers three questions: which line is the real product, where every older project fits in the sequence, and what is still outside the release line.

---

## 1. The one line that matters

**`ALRT-dev/ALRT-V1-Release-Candidate` is the product.** It is a monorepo:

| Folder | What it is |
|---|---|
| `frontend/` | Flutter phone app (iOS + Android), version **1.0.5+52** on the tip branch |
| `backend/` | Node/TypeScript API, Postgres (Prisma), Socket.IO, FCM push |
| `admin/` | Admin Portal (React) |
| `askalrt/` | Former Firebase Function for Ask ALRT; **retired on 6 Oct**, Ask ALRT now lives in `backend/` (`POST /api/ask-alrt`) |
| `docs/` + root `*.md` | Reconciliation report, acceptance guides, audits, source registry |

Every other repository either **fed into** this monorepo, is a **design/spec reference**, or is **empty**. Nothing outside it should be built or released.

### 1.1 Branch order inside the release candidate (oldest → newest)

Each step contains everything before it.

| # | Branch | Date | Contains |
|---|---|---|---|
| 1 | `main` | 25 Sep | Planning docs only (release plan, source registry, pipeline, backlog) + iOS Dev workflow. **No app code.** |
| 2 | `release/v1-integration` | 5 Oct | The integrated monorepo: frontendV2 + backendV2 + askalrt + admin, reconciled (see `V1_RECONCILIATION_REPORT.md`) |
| 3 | `test` | 6 Oct | #2 + iOS CI fixes (Xcode 26, match profiles, CocoaPods) + background-location purpose string. Build 1.0.5+51 |
| 4 | `claude/test-builds-signin-update` | 6 Oct | #3 + 25 commits (see 4b) |
| 5 | **`claude/community-alerts-privacy-and-points`** | 6 Oct | **Tip of the product.** #4 + merge of `test`. Build **1.0.5+52**. Last 6 iOS Dev TestFlight runs **succeeded** (runs 21, 24–28, latest 6 Oct 12:14 UTC) |

4b. What #4/#5 add over `test`: community-alert privacy and clean-up, deferred points, server-side blocking on all read paths, reviewer-only login, free-trial record, read-aloud only on tap, Ask ALRT moved into the backend (Bedrock Haiku; Firestore, Firebase Auth and App Check removed from app and admin), iOS TEST sign-in fixes, Android TEST Maps identity fix.

**Recommended next merge:** `claude/community-alerts-privacy-and-points` → `test` → `release/v1-integration` → `main`, once Sarah accepts build 52 on a phone. Until then `main` is a planning branch, not the product.

### 1.2 Branches already merged (safe to delete after the merge above)

`claude/admin-portal-go-live`, `claude/alrt-subscription-audit-r4szxr`, `claude/rules-and-2-week-trial`, `claude/test-app-audit-p5djd2`, `claude/test-ask-alrt-content`, `claude/cool-ritchie-zf2xey` (this branch, docs only).

### 1.3 Branches outside the tip, and what to do with each

| Branch | Status | Action |
|---|---|---|
| `claude/admin-ask-alrt-answers-emergency-numbers` | Same change already in tip (patch-equivalent) | Delete |
| `claude/test-signin-config` | Same change already in tip | Delete |
| `codex/android-test-maps-identity` | Same change already in tip | Delete |
| `codex/test-ios-background-location-purpose` | Superseded: tip has `NSLocationAlwaysAndWhenInUseUsageDescription` in both plists | Delete |
| `codex/ios-testflight-location-purpose` | Superseded (same purpose strings; its other commits touch only the unused nested `frontend/.github` workflow copy) | Delete |
| `copilot/fix-github-actions-build-job` | Superseded: tip's iOS workflow resolves the installed match profile and builds successfully | Delete |
| `claude/alrt-v1-rc-audit-a3gmai` | Not an ancestor, but its content (7-day host-transition grace, leaderboard exclusion) is present in tip | Do not merge again; delete |
| **`claude/live-connection-config`** | **Outstanding.** Production (live) connection config without secrets: `admin/.env.production`, `backend/.env.prod.example` | Merge at go-live, after TEST acceptance |
| **`claude/focused-brown-8ptpdl`** | **Outstanding.** `WEARABLES_AUDIT_AND_PLAN.md` (13 Sep, revision 2) | Keep as reference; superseded in part by `APPLE_WATCH_LAUNCH_REQUIREMENTS.md` on this branch |

---

## 2. Every other repository, filed in sequence

Ordered by lineage: what was launched, what replaced it, what fed the monorepo, then design and side projects.

| Order | Repository | Role | Latest activity | Status |
|---|---|---|---|---|
| A1 | `v3` | Archive of the **launched store app 1.0.4+34** (zip of the source) | 20 Aug | **Archive / reference only.** Production users are on this build |
| A2 | `V2-Claude` | Older Flutter lineage (1.0.3+33); feature branches `feature/voice`, `feature/alrt-plus`, `feature/email-login`, `feature/navigation`, `feature/leaderboard`, `ci/ios-testflight` | 3 Aug | **Superseded.** Voice and the other features were carried into the monorepo. README already marks it superseded |
| A3 | `frontendV2` | Flutter app V2; audit branch `claude/safety-alert-repo-audit-8exgvn` (1.0.5+35) became `frontend/` | 13 Sep (website-copy branch) | **Superseded by `frontend/`.** `feature/home-screen-widgets` widget code is already in the monorepo (`frontend/ios/AlrtWidget`) |
| A4 | `backendV2` | API V2; audit branch + `hardening/safe-fixes`, `feature/alrt-plus-subscription`, `claude/alrt-data-export-tzq4ex` (Intel Centre spec) became `backend/` | 20 Aug | **Superseded by `backend/`.** Re-check `claude/alrt-data-export-tzq4ex` (EONET/USGS/GDACS/NHC source spec) against `SOURCE_REGISTRY.md` before discarding |
| A5 | `askalrt` | Firebase Function for Ask ALRT (Anthropic SDK, quotas) | 7 Sep | **Retired.** Folded into monorepo then moved into `backend/` on 6 Oct. Archive the repo |
| B1 | `watchinterface` | **Wear OS design handoff**: HTML prototype of 13 screens, standalone SOS spec, design tokens, product rules | 6 Aug | **Design reference for the watch.** Screens and copy reusable; its data model (Firestore `sosEvents`, `liveShareSessions`) is obsolete because Firestore was retired 6 Oct; its SOS timing (3 s + 5 s countdown + 12 s undo) and $7.99 price conflict with locked rules |
| B2 | `glasses` | README on `main`; unmerged Android XR Kotlin scaffold (`feat/glasses-android-xr-scaffold`), never compiled | 3 Aug | **Design reference for glasses, phase 4+.** Do not build here |
| B3 | `ALRT-screen` | Design docs and mockups: `alrt-v2-backend-changes.md` (widget payload, haptic tiers, "Watch v1 = notification actions + complication"), skills library, accessibility | 20 Aug | **Design reference.** Its "watch v1" definition matches the launch recommendation |
| C1 | `alrt` | Marketing website; redesign branch `claude/safetyalert-website-redesign-4uao5f` | 7 Sep | **Separate product (website).** Its copy says "the watch works without the phone"; that is not true for any planned V1 watch scope. Change the copy before the site ships |
| D1 | `ios-certificates` | fastlane match storage (encrypted signing certificates and profiles) | 5 Oct | **Infrastructure, keep private.** A watch app adds new profiles here |
| E1 | `occulo` | Empty (no commits) | n/a | Archive or delete |
| E2 | `mattv2` | Empty (no commits) | n/a | Archive or delete |

### 2.1 Suggested housekeeping (owner decision; nothing was changed)

1. Archive on GitHub (read-only): `v3`, `V2-Claude`, `frontendV2`, `backendV2`, `askalrt`.
2. Delete or archive empty repos: `occulo`, `mattv2`.
3. Keep as spec repos with a README line pointing to this file: `watchinterface`, `glasses`, `ALRT-screen`.
4. Keep live: `ALRT-V1-Release-Candidate` (product), `alrt` (website), `ios-certificates` (signing).

---

## 3. Documents on `main` that are out of date

`V1_RELEASE_PLAN.md` on `main` still states rules that were changed on 3 October (commit on `claude/rules-and-2-week-trial`, now in `test`):

| Rule | `main` says | Current (in code on `test` and tip) |
|---|---|---|
| ALRT+ free trial | 1 month | **2 weeks** |
| SOS duration | max 4 hours | **1 hour; sender extends or ends** (`SOS_MAX_DURATION_MS = 60 min`, `backend/src/services/family.service.ts`) |
| Ask ALRT quota | 5 free / 30 ALRT+ | Every answer counts; backend limits per `claude/community-alerts-privacy-and-points` commit `7a058f6` (re-confirm the numbers) |
| Read aloud | not stated | Only by tapping Listen; never automatic |

`main` will pick these up when the merge in §1.1 lands. Until then, treat `V1_RECONCILIATION_REPORT.md` on the tip branch as the source of truth for rules.

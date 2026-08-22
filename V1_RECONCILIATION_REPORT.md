# ALRT V1 Reconciliation Report

**Status:** Stage 5 (Google Maps / routing / transport audit and completion, and the Maps architecture decision) complete — see §19. Application code has now been changed in this repository only — see §17, §18, and §19. No original repo (`frontendV2`, `backendV2`, `askalrt`, `V2-Claude`, `v3`) has been modified, no branches were merged wholesale, and nothing has been deployed.
**Scope:** `ALRT-dev/frontendV2`, `ALRT-dev/backendV2`, `ALRT-dev/askalrt`, `ALRT-dev/V2-Claude`, `ALRT-dev/v3`, plus `ALRT-dev/ALRT-V1-Release-Candidate` itself. `ALRT-dev/widget` was pulled in read-only mid-audit because every other repo points to it as the true frontend baseline (see §1). Stage 2 additionally pulled in `ALRT-dev/alrt`, `ALRT-dev/ALRT-screen`, `ALRT-dev/mattv2`, `ALRT-dev/occulo`, `ALRT-dev/glasses`, `ALRT-dev/watchinterface` read-only, to hunt for a missing Admin Portal (see §15).
**Method:** Full local clones with ~200 commits of history fetched per branch (every branch that exists in each repo), `git log`/`diff`/`show` history analysis, and targeted source reading across five parallel deep-dive passes (one per repo) plus manual cross-repo verification. Not every file in every repo was read line-by-line; large, low-risk areas (asset files, generated lockfiles, vendored code) were sampled rather than exhaustively reviewed.

> **Stage 2 update:** the product owner has now ruled on the numeric conflicts Stage 1 flagged (§6.1, §10.D — see §11), and four follow-up investigations have resolved most of Stage 1's open questions: the frontendV2-vs-V2-Claude comparison (§12), the Ask ALRT architecture decision (§13), a verified CVE/security-fix inventory that corrects two Stage 1 errors (§14), and a definitive check on the four "missing backend capability" items (§15). §16 gives the recommended implementation sequence. Original Stage 1 content below is left intact as the historical record; where Stage 2 supersedes or corrects it, this is called out inline and in the new sections.

> **Stage 3 update:** §16's implementation order has now actually been executed, for the small/low-risk/clearly-agreed items only. This repository (`frontend/`, `backend/`, `askalrt/` subdirectories) now contains a real, building, testing V1 baseline for the first time — see §17 for the full commit-by-commit record, test results, and what remains open (only the Google Maps architectural decision and the net-new Admin Portal build, both explicitly deferred, not attempted).

> **Stage 4 update:** an audit-then-complete phase over the eleven Family/SOS-area features already promised by the V1 baseline — Family lifecycle, daily check-ins, Mark Yourself Safe, location snapshots, journey sharing, SOS, SOS live location, Child Mode, UI/UX consistency, and privacy/safety. Five parallel read-only audits were run first (one per feature cluster); this pass then implemented every well-scoped gap they found, and made no change where the audits found the feature already correct. Nothing net-new was built (no Admin Portal, no Google Maps decision, no broad alert-engine change) — see §18 for the full record.

> **Stage 5 update (this pass):** the Google Maps architecture question deferred since Stage 1 (§17.8) is now resolved. Three parallel audits (current frontend Maps usage, current backend Maps usage, and the full historical rotation/revert story across `frontendV2`/`backendV2`/`V2-Claude`) ran first; the finding was that an authenticated backend proxy for Geocoding/Places already existed and had simply gone unused after an undocumented revert — so the correction was to re-point the frontend to it, not build anything new. Directions/Routes (which was never proxied even in the original attempt) stays a direct client call, now capable of Android/iOS app-restriction headers. Separately, Google's own `transitDetails` response — already requested in the field mask but never parsed — is now parsed and shown, so a transit route displays its real line, vehicle type, headsign, and stop count instead of a generic icon. See §19 for the full record, the security assessment, and the manual Google Cloud configuration list.

---

## 0. Executive summary

The six repos are not six independent products — they are overlapping snapshots of the same two apps (a Flutter frontend, a Node/TS backend) plus one standalone service (Ask ALRT), taken at different points in time, mostly by the same small set of authors (a product owner/dev at `sarah@safetyalrt.com`, and a contributor identified as "Matt" at `matt@safetyalrt.com.au` / `matt.youman@wiz.io`). The single most important finding of this audit is:

> **`ALRT-dev/widget` — the repo every other README names as "where active development actually happens" — is git-identical to `ALRT-dev/frontendV2` today.** Every branch name and every commit SHA matches exactly between the two (verified by anonymous clone + `git ls-remote`). This is almost certainly a GitHub repo rename with the old name (`widget`) still round-tripping to the new one (`frontendV2`) via GitHub's automatic redirect, or a kept-in-sync mirror. **The "missing repo" gap flagged by three separate sub-audits is resolved: there is no undiscovered sixth codebase. `frontendV2` already *is* `widget`.**

With that resolved, the reconciliation picture is:

- **Frontend baseline:** `frontendV2` is correct, but **not its default branch**. GitHub's default branch for `frontendV2`/`widget` (`feature/home-screen-widgets`) is an accidental artifact of a CI workaround, not a development branch — it carries no unique app code. The real, current, and by far most complete frontend state is branch **`claude/safety-alert-repo-audit-8exgvn`** (156 commits ahead of `main`, dated 2026-08-20, the newest work-bearing branch in the entire audit).
- **Backend baseline:** `backendV2`'s `main` is stale and carries two currently-unpatched CVEs. The correct baseline is branch **`claude/safety-alert-repo-audit-8exgvn`** (75 commits ahead of `main`), which is a strict git superset of every other backend branch except one (`claude/alrt-data-export-tzq4ex`, which needs an actual merge, not a fast-forward).
- **Ask ALRT baseline:** `askalrt`'s `main` **is already current** — its own audit branch is byte-identical to `main` (fully merged, nothing outstanding).
- **V2-Claude and v3** are both legitimate historical lineages, not decoys: `v3` is a verified archive of the actual shipped 1.0.4+34 build; `V2-Claude` is an earlier, independent development line whose deepest branch (`claude/alrt-app-update-scope-s24m2k`) contains **Ask ALRT / Safety Profile / Alert Classification Standard v1.2 work that appears nowhere else**, including not in `frontendV2`'s audit branch — this needs a direct feature-level comparison before anything from `V2-Claude` is discarded.
- **Product-rule vs. code discrepancies exist and are unresolved**, not accidentally introduced by this audit: AI quota (release plan says 5/30 per day, shipped code says 3/20 on both `backendV2` and `askalrt` — internally consistent with each other, just not with the plan), free saved-locations cap (plan: 1, code: 3), journey-sharing start options (plan: 15/30/60 min, code: 30/60 only), and ALRT+ pricing (`ALRT_PLUS_SETUP.md`: $7.99/$79.99, shipped code: $9.99/$99.99). None of these are bugs — they're places where the documented product rules and the shipped implementation disagree, and only the product owner can say which is authoritative.
- **Ask ALRT exists in three parallel, only partially reconciled implementations** (the standalone `askalrt` Firebase service, a native port inside `backendV2`, and a Firebase-custom-token bridge also inside `backendV2` for calling the standalone service) — this is the single largest architectural conflict found and needs a decision before V1 ships.
- No **Admin Portal frontend** repository was in scope for this audit and none of the six repos audited contains one — only the Admin **API** (in `backendV2`) was found. This should be treated as an open item, not assumed resolved.

---

## 1. The `ALRT-dev/widget` finding, in detail

Both `v3`'s and `V2-Claude`'s README files independently describe a repo called `ALRT-dev/widget` as the true active-development frontend:

- `v3/README.md`: *"Do not develop here. Active development is in `ALRT-dev/widget` (v1.0.5+35, all V2 features); the backend is `ALRT-dev/backendV2` (api.safetyalrt.com)."*
- `V2-Claude`'s audit-branch README: *"⚠️ Superseded (Aug 2026 repo audit). Active development moved to **`ALRT-dev/widget`**, which contains everything in this repo **plus** the in-map navigation mode, home-screen widgets, ALRT+ paywall, leaderboard/points screens, voice search and email login."*

`ALRT-dev/widget` is not in this session's authorized repository list and does not appear in the `list_repos` inventory. However, it is a **public** GitHub repository, and the session's git proxy serves anonymous reads of public repos regardless of authorization scope. A read-only anonymous clone was performed to resolve this rather than leaving it as an open question. Result:

```
ALRT-dev/widget          ALRT-dev/frontendV2
claude/consolidated-frontend       120edcf   ==   120edcf
claude/revenucat-screens-sdw9l2    3e08c21   ==   3e08c21
claude/safety-alert-repo-audit-8exgvn 1e1d9cf == 1e1d9cf
feature/home-screen-widgets        3869af1   ==   3869af1  (default branch, both)
main                                18085b9   ==   18085b9
```

Every branch name and every commit SHA is identical. The top-level file listing (`MASTER_HANDOFF.md`, `DEPLOYMENT_HANDOFF.md`, `ALRT_PLUS_SETUP.md`, `HOME_WIDGET_SETUP.md`, `CHANGELOG.md`) matches exactly. This is not a coincidence or a stale mirror frozen at one commit — the shared tip commit (`3869af1`, dated 2026-08-17) is itself a late addition (a CI-workflow-visibility fix), which means the two names have been kept in lockstep at least that recently. The most likely explanation is that the repository was renamed from `widget` to `frontendV2` at some point after the `v3`/`V2-Claude` READMEs were written, and GitHub's automatic old-name redirect makes `git clone .../widget` transparently resolve to the same repository as `frontendV2`.

**Practical conclusion:** there is no missing sixth codebase to track down. Every statement elsewhere in this report about `frontendV2` — including its recommended baseline branch — applies equally to whatever anyone still calls "`widget`." No further action is needed on this specific gap beyond noting it, though the org's remaining references to the old name (in `v3` and `V2-Claude` READMEs, and possibly in CI/deploy configuration not covered by this audit) will confuse future readers and are worth cleaning up.

---

## 2. Repository inventory

| Repo | Default branch (GitHub) | What it actually is | Recommended state for V1 |
|---|---|---|---|
| `ALRT-dev/ALRT-V1-Release-Candidate` | `main` | Empty destination repo; currently contains only four planning docs (`SOURCE_REGISTRY.md`, `V1_RELEASE_PLAN.md`, `V1_SOURCE_PIPELINE.md`, `V1_SOURCE_REGISTRY_BACKLOG.md`) and now this report. No app code yet. | Target for reconciled code (future work, out of scope for this audit). |
| `ALRT-dev/frontendV2` (= `ALRT-dev/widget`) | `feature/home-screen-widgets` **(misleading — see §3.1)** | Flutter mobile app (Riverpod 3, go_router, Retrofit/Dio). | **KEEP as frontend baseline**, but build from branch `claude/safety-alert-repo-audit-8exgvn`, not the GitHub-default branch. |
| `ALRT-dev/backendV2` | `main` **(stale — see §3.2)** | Node/TypeScript/Express/Prisma API, PostgreSQL+PostGIS, serves `api.safetyalrt.com`. | **KEEP as backend baseline**, but build from branch `claude/safety-alert-repo-audit-8exgvn`, plus merge in `claude/alrt-data-export-tzq4ex`. |
| `ALRT-dev/askalrt` | `main` | Firebase Cloud Functions project; the Ask ALRT AI assistant (Claude Haiku) + a RevenueCat entitlement webhook. Was once a much larger duplicate backend (XP/SOS/sharing/proximity), deliberately slimmed to just this in the Aug 2026 repo audit. | **KEEP `main` as-is** — it is current; nothing outstanding on its audit branch. |
| `ALRT-dev/V2-Claude` | `main` **(frozen since 2026-07-08 — see §3.3)** | An earlier, independent Flutter app development line, same product family as `frontendV2` but not the same commit lineage. `main` is a dead snapshot; all real work is on divergent branches. | **PORT/RECOVER specific items only** (see §5) — do not adopt wholesale. Contains Safety Profile / Ask ALRT / Alert Classification v1.2 work possibly absent elsewhere. |
| `ALRT-dev/v3` | `main` | Verified archive of the actual shipped production build, `SafetyALRT/alrtap-frontend` v1.0.4+34. Confirmed via bundle ID, version-matched `pubspec.yaml`, and two intentionally-hidden features matching its own README's claims exactly. | **KEEP as historical reference only.** Not a development target. |

### 2.1 `ALRT-V1-Release-Candidate` — current content

`main` currently holds four planning documents (read in full during this audit) that already encode a considerable amount of prior product-owner decision-making and should be treated as binding context for the rest of this report, not just background:

- **`V1_RELEASE_PLAN.md`** — names the same five source repos this audit covers, states the reconciliation priority order, lists "confirmed fixes/infrastructure to preserve" (the exact list this report's §5 verifies against real commits), and locks in specific product rules for ALRT+, SOS, Journey sharing, Location snapshots, Community alerts, and Google Maps.
- **`SOURCE_REGISTRY.md`** and **`V1_SOURCE_PIPELINE.md`** — define the target alert-ingestion architecture (source registry → ingestion → validation → extraction → normalization → classification → severity → safety extraction → canonical alert → notification) that §7 of this report evaluates `backendV2`'s actual pipeline against.
- **`V1_SOURCE_REGISTRY_BACKLOG.md`** — a P0/P1 backlog for making the source registry "operational rather than documentation-only," useful as a direct checklist against what `backendV2`'s `source_registry.util.ts` (audit branch) already implements.

This report treats those four documents as the product-rule source of truth and calls out every place where shipped code disagrees with them (see §6.1).

---

## 3. Branch situations that need explicit resolution before any merge

### 3.1 `frontendV2`: GitHub's default branch is an accident

`git ls-remote --symref origin HEAD` confirms `feature/home-screen-widgets` really is the default. It is a single **orphan commit** (`3869af1`, no shared ancestor with `main`) that is byte-for-byte `main`'s tree plus one CI file (`.github/workflows/ios-testflight.yml`). Its own commit message explains why: *"Copy of the workflow from claude/safety-alert-repo-audit-8exgvn; GitHub only lists a workflow_dispatch workflow when the file exists on the default branch."* Someone needed a manually-triggerable TestFlight Action to appear in the GitHub Actions UI, which only works from the default branch, and rather than promoting the real working branch, squash-copied `main` into a new orphan branch and flipped GitHub's default pointer to it.

**CONFIGURATION** — this should be fixed as part of consolidation: repoint GitHub's default branch to whatever becomes the new canonical baseline, and retire or fold in the orphan branch so nobody mistakes it for meaningful history again.

### 3.2 `backendV2`: `main` carries live unpatched CVEs

`main`'s `package.json` still pins `basic-ftp@5.2.0` (CVE-2026-39983, FTP command injection via CRLF) with no override for the `effect` package (CVE-2026-32887, `AsyncLocalStorage` context leakage, pulled in transitively via `@prisma/config`). Both are fixed further down history (`f4bf93b`/`faceba7`) but not on `main`. **MODIFY / do not treat `main` as deployable as-is.**

### 3.3 `V2-Claude`: `main` is a frozen snapshot; real work lives 41 commits away

Every branch in this repo shares the same merge-base as `main` (`ffbd610`, 2026-07-08); `main` has had zero commits since. The deepest, most current line is `claude/alrt-app-update-scope-s24m2k` (41 commits ahead), which itself is the result of merging **28 unreleased commits pulled in from `ALRT-dev/widget`'s `main`** on 2026-08-01, then adding further work afterward. That later work — Safety Profile, an Ask ALRT bottom sheet, and "Alert Classification Standard v1.2" — postdates the widget merge and is **not described anywhere in `frontendV2`'s feature list**. This is the one open thread from this audit that most needs a human decision: **either this V2-Claude-only work has already been superseded by frontendV2's own (different) Safety Profile / Ask ALRT implementation, or it contains functionality that needs to be diffed in and reconciled.** See §5.6.

---

## 4. Functionality inventory by feature area

Legend: **KEEP** = use as-is from the recommended baseline · **PORT/RECOVER** = exists on a non-baseline branch/repo and should be brought into the baseline · **MODIFY** = exists but needs a product/engineering decision or change before V1 · **BUILD** = does not exist anywhere audited and needs new work · **CONFIGURATION** = an ops/config/CI concern, not app code · **TESTING** = needs verification/QA before being trusted · **NOT V1** = out of scope per the release plan.

| Feature | Frontend state | Backend state | Classification | Notes |
|---|---|---|---|---|
| **Google Maps / Places / Geocoding / Routes** | Complete; calls Google directly with a build-time-injected client key (never hardcoded) | Complete; has its own working Geocoding/Places proxy (`maps_proxy.service.ts`) that the frontend does **not** currently use for those calls | **MODIFY** | A full proxy-based fix (`4662b7c`, routes Geocoding/Places/Autocomplete through the backend so the key never ships client-side) was built, shipped, then deliberately reverted four days later (`5b1eba2`, "removing the app's runtime dependency on the backend /api/maps proxy") on both `frontendV2` and `V2-Claude` lineages independently. The Maps client key **currently ships inside the compiled app** for Geocoding/Places/Directions/Routes calls. This is flagged as a known, accepted-for-now risk in `frontendV2`'s own `MASTER_HANDOFF.md`. The deleted rotation runbook (`docs/google-maps-key-rotation.md`) is recoverable via `git show 4662b7c:docs/google-maps-key-rotation.md` on `V2-Claude` if the proxy approach is revisited — re-applying it blindly without knowing why it was reverted is not recommended; ask Matt or check the proxy's actual reliability/latency history first. Routes API dynamic transport-mode work (the release plan's item 8) is real and present (`navigation_mode_overlay.dart`, `speech_to_text` tap-to-talk), just not documented as living in `frontendV2` by its own README — a docs mismatch, not a missing feature. |
| **Google OAuth** | Complete | Complete | **KEEP** | Present on every branch of every frontend/backend repo checked. |
| **Apple OAuth** | Complete | Complete | **KEEP** | Same. |
| **Microsoft OAuth** | Code-complete but UI button commented out | **Now implemented** (audit branch only) — `microsoft_oauth_client.util.ts`, routed at `/oauth/microsoft` | **MODIFY (recover, then re-enable)** | This is release-plan priority #7 ("Recover/complete Microsoft OAuth"), and it is now genuinely done on the backend side as of `backendV2`'s audit branch — it just hasn't been wired back up on the frontend, where the button was disabled specifically because the backend route didn't exist yet. Re-enable the frontend button once the backend baseline (§ recommendation B) is confirmed in place. Note: `backendV2`'s own `docs/CONNECTIONS.md` still says Microsoft OAuth is "declared but not found in code" — that doc predates the later `af7e78b` commit that actually implemented it; the doc is stale, not the code. |
| **Email/password auth** | Complete | Complete | **KEEP** | |
| **Firebase / FCM push** | Complete | Complete (adds request timeouts + batching in `hardening/safe-fixes`) | **KEEP**, PORT the timeout/batching hardening if not already in the chosen backend baseline commit range (it is — that branch is a strict ancestor of the recommended `claude/safety-alert-repo-audit-8exgvn`). | |
| **RevenueCat / ALRT+** | Complete UI (paywall, manage screen, welcome screen, billing-issue banner) | Complete webhook + entitlement service, but **gated off by a single `BILLING_ENABLED` flag that is currently unset** | **MODIFY / CONFIGURATION** | Until `BILLING_ENABLED=true`, every backend account is treated as ALRT+. This must be an explicit, tracked go-live step, not something inherited silently. Also: **pricing mismatch** — `ALRT_PLUS_SETUP.md` says $7.99/mo, $79.99/yr; shipped frontend code (commit `f9ea9b5`) changed it to $9.99/mo, $99.99/yr. Docs need updating to match code, or code needs to match the docs — needs a product-owner call. |
| **ALRT+ quota/seat rules** | N/A (enforced server-side) | Free AI quota **3/day**, ALRT+ **20/day** (both `backendV2` and `askalrt` agree with each other); free saved-locations cap **3**; family seats **8** (matches plan) | **MODIFY** | Release plan says free AI quota 5/day, ALRT+ 30/day, and 1 free saved location. Code is internally self-consistent at 3/20 and 3 locations across two independent repos, which suggests the plan document may be the stale one — but this needs a product decision, not a silent code change either way. |
| **Ask ALRT** | Complete chat UI, on-device local-answer fast path, calls a Firebase callable with App Check | **Three parallel, incompletely-reconciled implementations** — see §6.2 | **MODIFY (architectural decision required)** | The single largest open conflict in this audit. |
| **Alert ingestion pipeline** | N/A (consumer only) | Two generations present; audit branch is materially more mature (source registry, canonical-hazard closed-list matching, AI structured-info extraction with a deterministic severity backstop) and maps cleanly onto the target 10-stage pipeline in `V1_SOURCE_PIPELINE.md` | **KEEP** (audit branch) + **CONFIGURATION** | BoM and Smartraveller ingestion sources are currently coded as disabled despite being documented as live in `HAZARDS_INGESTION_DOCUMENTATION.md` — confirm intended state. Two long-form docs describing the pipeline have not been updated to reflect the newer source-registry/canonical-hazard stages (doc/code drift, not a code defect). |
| **Alert classification / severity** | Complete UI (locked design system: 5 source-system shapes, category colors — see below) | Complete two-layer implementation (format normalization + closed-list matching + AI extraction + deterministic severity scan) | **KEEP** | Frontend has an actively product-owner-ruled, test-locked design system: `test/band_colour_lock_test.dart`, `test/alert_shape_system_test.dart`. Most recent ruling (commit `1e1d9cf`, 2026-08-20): Security & Crime category recolored to magenta `#D946EF` — "red reserved for severity, never category." `main`/default branch still has the old red (`#FF2E44`), which the ruling explicitly says conflicts with severity semantics. |
| **Safety Profile** | Complete on-device implementation ("For You" cohort chips, explicitly no server round-trip, privacy-by-design) — `frontendV2` audit branch only | **Does not exist at all** — no model, no API, on any `backendV2` branch | **BUILD or MODIFY** | Release plan priority #4 is "Finalise Safety Profile content/classification," implying more work was expected here. `V2-Claude`'s deepest branch also has its own, separately-built Safety Profile work (§3.3/§5.6) — these two implementations have not been compared to each other and may not agree. Needs reconciliation before deciding whether this stays client-only or needs a backend counterpart. |
| **Family** | Complete (hub, circles, invites, places, group switching, avatars) | Complete (extensively hardened: XP rewritten to be ledger-sourced-of-truth, badges, multi-circle seat caps) | **KEEP** | Present in a less-complete form on `main`/default branches of both repos; full form only on each repo's audit branch. |
| **SOS** | Complete (3s hold-to-activate confirmed via `AnimationController`, recipient list management, live-trail map, resolved/roll-call screens) | Complete (4-hour cap self-enforced, directed seen/responded messaging, live-trail endpoint, recipient presets) | **KEEP** | Both frontend and backend SOS work exist **only on each repo's audit branch** — `main` has no SOS code at all on either side, and `V2-Claude` (any branch) has no SOS code either. Two product rules from the release plan need explicit **TESTING** verification, not just code presence: "no generic emergency-services call button in the SOS flow" (not independently verified by either sub-audit) and "'On my way' must not expose responder live location" (not independently verified). |
| **Location snapshots** | Complete | Complete (consent flow via `FamilyLocationRequest`, TTL-based expiry/retention job) | **KEEP** | Product rule "each person must physically consent before their location is sent" needs **TESTING** confirmation on the actual UX flow, not just that a consent model exists server-side. |
| **Journey sharing** | Complete | **Partial — missing the 15-minute start option.** Code only allows `[30, 60]` minute starts (`ALLOWED_START_MINUTES`); 4-hour cap and 1-hour extend-per-block are both correctly enforced. | **MODIFY** | Release plan explicitly says "15 minutes, 30 minutes, or 1 hour initial duration." Either the backend needs a 15-minute option added, or the plan needs updating — again, a product decision, not an engineering guess. |
| **Daily check-ins** | Complete (`family_check_in_roll_call_screen.dart`) | Complete (`FamilyScheduledCheckIn` model, "scheduled daily check-ins v1") | **KEEP** | Audit-branch-only on both sides. |
| **Child Mode** | Complete (provider + screen; legal/age copy later reworked to defer to local law rather than a hardcoded 13+/AU statute) | **Does not exist at all** — no matches for `childMode`/`child_mode` anywhere in `backendV2` | **BUILD** | Frontend-only feature currently; if Child Mode requires any server-side restriction/flagging (e.g. limiting what a child-mode account can see or do via the API), that is unbuilt. |
| **Admin API** | N/A | Complete and broad: auth, stats/dashboard, app-user management, hazard categories, hazards + hazard sources (incl. license mgmt), AI-prompt management (incl. the Ask ALRT system prompt), configurations, webhook API keys | **KEEP** | Role-tiered (`requireAnyAdmin` vs `requireAdminOrAbove`). Minor cleanup only: `/stats` mounted twice, RevenueCat route exported under two different names. |
| **Admin Portal (frontend)** | **Not found in any of the six audited repos** | — | **Open gap — not classified, needs scoping** | Release plan priority #9 is "Verify Admin Portal against Admin API," which presumes an Admin Portal frontend exists. None of the repos in this audit's scope contain one. If it lives in a repo not included here (the session has read access to several other `ALRT-dev` repos not requested for this audit — `alrt`, `ALRT-screen`, `mattv2`, `occulo`, `glasses`, `watchinterface` — any of these could plausibly be it, but none were inspected, per the audit's explicit scope), it needs to be identified and audited separately before priority #9 can be actioned. |
| **Home-screen widgets** | Present on both `main` and the audit branch; audit branch adds freshness text, ALRT-mark branding, per-circle family icons | N/A | **TESTING required** | `frontendV2`'s own `HOME_WIDGET_SETUP.md` states plainly: *"Not yet compiled/built here — authored on Windows without a Flutter/Gradle/Xcode toolchain."* Despite being the feature GitHub's (accidental) default branch is nominally named after, no branch has confirmed this actually compiles. Must be built and run on real Android/iOS toolchains before being trusted. |
| **Android build/signing** | Release-signing hardening (conditional keystore fallback, no debug/release cross-contamination) and native-video-player public-package fix are **already on `main`**. Core-library desugaring for `flutter_local_notifications` (fixes a real v18 crash) is **only on the audit branch** — confirmed absent from `main`/default via direct `grep`. | N/A | **PORT/RECOVER** | Desugaring was independently discovered and fixed **twice**, by two different people, on two different repos (`frontendV2`'s audit branch, and separately on `V2-Claude`'s `live-sync`/`claude/alrt-app-update-scope-s24m2k` lines using library version 2.1.5 vs. frontendV2's 2.1.4) — a real duplicated-effort signal worth surfacing to whoever owns the release plan. Prefer the newer 2.1.5 pin when porting. `targetSdk` is pinned to 35 on the audit branches (Play Store requirement since Aug 2025) but floats on `main`. |
| **CI/CD (TestFlight, QA APK)** | `ios-testflight.yml` (manual-trigger fastlane lane) and `android-apk.yml` (QA APK to a fixed URL/QR code) exist only on the audit branch; a parallel, independently-built TestFlight pipeline also exists on `V2-Claude`'s `ci/ios-testflight` branch (different fastlane setup, `TESTFLIGHT_SETUP.md`) | No CI workflow files exist in `backendV2` at all (`.github/` holds only `copilot-instructions.md`) | **CONFIGURATION** | Two independently-built iOS CI pipelines exist across the two frontend repos and have not been compared to each other — worth a direct diff before picking one. Backend has no CI at all currently. |

### 4.1 Community alerts — product rules vs. implementation

The release plan's community-alert rules ("never escalate from a severe community-stated event without authoritative support," "no precise address exposure," "treat community reports as information-level unless official sources support escalation") map most directly onto a real bug-and-fix pair found on `backendV2`'s audit branch:

- **Bug (present on `main`):** hazard API responses embedded the reporter's entire user record — including `passwordHash`, `email`, and home `latitude`/`longitude` — via a naive Prisma `include: { reportedBy: true }`, plus a raw-SQL path that separately leaked `reportedByEmail`. Community-reported hazard coordinates were also served at full GPS precision to any viewer, deanonymizing exactly where a reporter was standing.
- **Fix (audit branch, commit `9f36208`):** `reportedBy` now selects only `{ id, name, xpPoints, reliabilityScore }`; raw-SQL email exposure removed; a new `withPublicCoords()` helper rounds community-reported (not official) hazard coordinates to ~1.1km (suburb) precision at every read/emit boundary (REST, GeoJSON export, socket broadcasts); the Redis cache key was bumped (`hazard:v2:{id}`) so no stale cached object with the old full-precision data survives deployment. A related fix on the same branch (`609a758`) ensures the leaderboard never identifies other users.

**Classification: KEEP** (already fixed, on the recommended backend baseline) — but this is exactly the class of privacy bug the release plan's community-alert rules are meant to prevent, so it's worth the product owner explicitly confirming the fix's approach (suburb-level rounding, official-alert exemption) matches their intent, rather than assuming it does.

---

## 5. Historical fixes to recover — the "Matt / V2-Claude" hunt

The release plan names eight specific "confirmed fixes/infrastructure to preserve." This audit traced every one of them to an actual commit (or confirmed its absence) across all six repos:

| # | Fix | Found? | Where | Status on recommended baselines |
|---|---|---|---|---|
| 1 | Google Maps API-key rotation / AWS Secrets Manager work | **Yes** | `backendV2`: `src/utils/secrets.ts` (Secrets Manager Agent sidecar pattern), already on `main`. The *client-side* half (routing Geocoding/Places through a backend proxy so the app never holds the key) was built (`4662b7c`) and then **deliberately reverted** (`5b1eba2`) on both frontend lineages — see §4's Maps row. | **Partially KEEP, partially open decision** — server-side secrets delivery is solid and current; client-side key exposure is a live, accepted-for-now risk. |
| 2 | Frontend build-time Google Maps key handling | **Yes** | `7290e2c` on `V2-Claude`, equivalent commit lineage on `frontendV2` — key resolved from env/`.env`/xcconfig at build time, never hardcoded in `AndroidManifest.xml` or iOS `AppDelegate`. | **KEEP** — already on `main` of both frontend repos. |
| 3 | Android core-library desugaring for `flutter_local_notifications` | **Yes, twice, independently** | `frontendV2` audit branch (`desugar_jdk_libs:2.1.4`); `V2-Claude`'s `live-sync`/`claude/alrt-app-update-scope-s24m2k` (`desugar_jdk_libs:2.1.5`, by Matt) | **PORT/RECOVER** — not on either repo's `main`; prefer the 2.1.5 pin. |
| 4 | Android native video player dependency fix | **Yes** | `a3e178e`/`d443fcf` — replaced a dependency pointing at a contributor's absolute local filesystem path with the public `native_video_player: ^4.0.1` pub.dev release, adapted call sites to the v4 API. | **KEEP** — already on `main` of both frontend repos. |
| 5 | Android release-signing hardening / upload-certificate protection | **Yes** | Same commits as #4 — signing now falls back to debug-signing only when `key.properties` is absent, instead of the pre-fix bug where **debug builds used the release keystore config** and release silently fell back to debug signing unconditionally. Separately, `c676a62` gitignores the public upload certificate; `ab534be` (Matt, not yet on `main`) gitignores the Play service-account JSON key. | **KEEP** (signing fix + cert gitignore) **+ PORT/RECOVER** (service-account key gitignore, still missing from `main`). |
| 6 | OpenSSL security remediation | **Backend only** | `5b69a9c "feat: updated openssl"` on `backendV2`'s deeper branches, not on `main`. **Not present anywhere in either Flutter frontend repo** (expected — no direct OpenSSL surface in a Dart mobile app). | **PORT/RECOVER** on the backend baseline. |
| 7 | Nodemailer/Wiz security remediation | **CORRECTED IN STAGE 2 — found, and confirmed real.** See §14 item 6. | Two merge commits (`901327e`, `22684c0`, PR #12/#15, merged by Matt, 2026-06-30) titled "Wiz: Upgrade nodemailer to 8.0.5 (resolves 2 findings)". The underlying commits are authored by a genuine GitHub App bot account, `wiz-f74d8ca267[bot]` — Stage 1's conclusion that "Wiz" was just part of a personal email address was **wrong**; it's a real automated security scanner. `nodemailer` was bumped 7.x → 8.0.5 (major version). | **KEEP — already an ancestor of `main`, no porting needed.** |
| 8 | Location-subscription duplicate/race-condition fix | **CORRECTED IN STAGE 2 — high-confidence match found.** See §14 item 6. | `location_subscription.service.ts`'s `upsertUserOwnLocationSubscription` (introduced `f716684`, 2026-02-02) replaces an earlier check-then-act (TOCTOU) pattern with create/catch-P2002/retry, with an inline comment reading `// If unique constraint violation (race condition), find and update instead`. The same commit's Prisma migration explicitly deletes pre-existing duplicate `isOwnLocation=true` rows before adding a partial unique index — strong evidence real duplicates had occurred in production. Not textually confirmed as "the" release-plan item (no commit/PR title uses those exact words), but the evidence is strong. | **KEEP — already an ancestor of `main`, no porting needed.** |

Two further security-relevant items surfaced independently, not on the release plan's list, worth folding in:

- **CVE-2026-39983** (`basic-ftp` CRLF/FTP command injection) and **CVE-2026-32887** (`effect` `AsyncLocalStorage` context leakage, transitive via `@prisma/config`) — both fixed on `backendV2`'s deeper branches (`f4bf93b`/`faceba7`), **both still live on `main`**. **PORT/RECOVER — high priority, these are currently-unpatched dependency CVEs on the stale baseline.**
- A hardcoded QLD Traffic API key fallback was found and removed from `backendV2`'s ingestion code (`3bab7af`) — not security-critical but worth noting as the kind of thing a wider secret-scan should catch if repeated elsewhere.

---

## 6. Major conflicts requiring a decision

### 6.1 Product rules vs. shipped numbers

Four concrete, verified mismatches between `V1_RELEASE_PLAN.md` and the actual code, none of which this audit resolves on its own authority:

1. **Ask ALRT AI quota** — plan: 5/day free, 30/day ALRT+. Code (`backendV2` and `askalrt`, independently, in agreement with each other): 3/day free, 20/day ALRT+.
2. **Free saved locations** — plan: 1. Code (`backendV2`): 3 (`FREE_SAVED_LOCATIONS_LIMIT = 3`).
3. **Journey sharing start durations** — plan: 15/30/60 minutes. Code (`backendV2`): 30/60 minutes only.
4. **ALRT+ pricing** — `frontendV2/ALRT_PLUS_SETUP.md`: $7.99/mo, $79.99/yr. Shipped frontend code: $9.99/mo, $99.99/yr.

### 6.2 Ask ALRT — three implementations, one decision needed

- **Implementation A — standalone `askalrt` Firebase service.** A dedicated Cloud Function (`askAlrt`, callable, App Check + Firebase Auth enforced) with a 3-tier answer strategy (Firestore-editable canned-answer library → zero-AI emergency-number lookup → Claude Haiku fallback), its own quota tracking (`agentUsage/{uid}/days/{day}`), and a separate RevenueCat webhook for its own `entitlements/{uid}` record.
- **Implementation B — native port inside `backendV2`.** `src/services/askalrt.service.ts` / `askalrt.controller.ts` / `askalrt.route.ts` — a self-contained re-implementation using this backend's own OpenAI client and its own tiered library→emergency-number→AI-fallback logic, with its own quota constants (matching A's numbers, 3/20 — but implemented independently, not by calling A).
- **Implementation C — a bridge to call Implementation A.** `backendV2`'s `firebase_token.controller.ts` mints Firebase custom tokens (`POST /api/user/firebase-token`) specifically so the mobile app can authenticate against the standalone Firebase Cloud Function in Implementation A. A commit dated **three days after** Implementation B shipped ("Ask ALRT never worked… the app authenticates against this backend rather than Firebase") fixes this bridge path specifically — implying it was still being actively used/fixed after the native port already existed.

**This needs a decision, not a merge.** Carrying all three forward risks split-brain quota tracking, inconsistent answer libraries, and duplicated Anthropic/OpenAI API spend for the same feature. Determine which path the currently-shipped mobile app actually calls (this audit could not determine that from the backend/service code alone — it requires checking the frontend's actual runtime configuration, e.g. `.env`/Remote Config values, or asking the team directly), then plan to retire the other one(s).

Separately: `askalrt`'s Remote Config kill-switch (`agent_enabled`) is **not enforced server-side anywhere** — it's declared in `remoteconfig.template.json` but no Cloud Function reads it, meaning a modified/bypassed client could keep calling Ask ALRT even with the "kill switch" flipped off centrally. **MODIFY** if a true kill-switch is required for V1.

### 6.3 `V2-Claude`'s deepest branch may contain unique, unreconciled work

As flagged in §3.3, `claude/alrt-app-update-scope-s24m2k` on `V2-Claude` contains Ask ALRT, Safety Profile, and "Alert Classification Standard v1.2" work added *after* it merged in 28 commits from what was then `ALRT-dev/widget`'s `main`. Given §1's finding that `widget` and `frontendV2` are now the same repo, and given `frontendV2`'s own audit branch has its own, differently-built Safety Profile and Ask ALRT implementations, there are now **two independently-built Safety Profile implementations and (with §6.2) up to four independently-built Ask ALRT implementations** across this codebase family. **This is the report's top open question**: someone needs to do a direct feature-level diff between `V2-Claude`'s `claude/alrt-app-update-scope-s24m2k` Safety Profile/Ask ALRT/Alert-Classification work and `frontendV2`'s audit-branch equivalents, to determine whether `V2-Claude`'s version is older-and-superseded, or contains something genuinely missing from the recommended frontend baseline.

### 6.4 Duplicated CI pipelines

Two independently-built iOS TestFlight CI pipelines exist: `frontendV2`'s audit-branch `ios-testflight.yml` + fastlane setup, and `V2-Claude`'s `ci/ios-testflight` branch fastlane setup (authored by `sarah@safetyalrt.com`, includes a `TESTFLIGHT_SETUP.md`). These have not been compared to each other. **CONFIGURATION** — diff and pick one before consolidation.

---

## 7. Alert ingestion/classification pipeline vs. the documented target

`V1_SOURCE_PIPELINE.md` (already in this repo) defines: *source registry → ingestion → source validation → event/warning extraction → normalisation → classification → severity mapping → safety/instruction extraction → canonical alert → notification + map/card.*

`backendV2`'s recommended baseline (`claude/safety-alert-repo-audit-8exgvn`) maps onto this cleanly:

- **Source registry** — `src/utils/source_registry.util.ts`, plus new `HazardSource*` schema fields (shape/severity-system/push-policy per source) — this is real progress against `V1_SOURCE_REGISTRY_BACKLOG.md`'s P0 items, though not yet a full CRUD-backed operational registry with health checks, review/expiry controls, and audit logging as that backlog specifies. **PORT/RECOVER what exists, BUILD the remaining P0 backlog items** (source health checks, review/expiry surfacing in an Admin Portal, quarantine/failure states, per-source audit logging).
- **Ingestion** — `ingestion.service.ts` (13 live external feeds, catalogued in full in `docs/CONNECTIONS.md` — see §8) with `node-cron` scheduling (every 15 min + two daily jobs), gated to run only in `NODE_ENV=prod`.
- **Classification/severity** — two-layer: format-normalization (`ingestion.category.util.ts`/`ingestion.severity.util.ts`) plus a newer deterministic closed-list pre-match (`canonical_hazard.util.ts`, built explicitly to control AI cost by avoiding an LLM call when a source event matches a known canonical hazard type) backed by an AI structured-info extraction pass (`si_extraction.service.ts`) and a deterministic severity backstop (`severity_scan.service.ts`).
- **Gaps against the documented target**: BoM and Smartraveller sources are currently disabled in code despite being documented as live; the two long-form pipeline docs (`AI_PROMPTS_DOCUMENTATION.md`, `HAZARDS_INGESTION_DOCUMENTATION.md`) describe an older, simpler pipeline and have not been updated to reflect the source-registry/canonical-hazard additions (**doc drift**, not a code defect, but will mislead the next person who reads them instead of the code).

---

## 8. External integrations already implemented

Compiled from `backendV2`'s own `docs/CONNECTIONS.md` (an existing, code-verified audit doc on the recommended backend baseline — every line below was independently cross-checked against `package.json`/client-init code by the backend sub-audit, not merely copied from the doc) plus frontend-side integrations found separately:

| Integration | Side | Notes |
|---|---|---|
| PostgreSQL + PostGIS | Backend | Primary datastore via Prisma. |
| AWS S3 + CloudFront | Backend | Media storage/CDN. |
| AWS Secrets Manager Agent | Backend | Sidecar pattern for runtime secret delivery in deployed AWS environments (Maps key, etc.). |
| OpenAI (`gpt-5-nano`) | Backend | Hazard summarization/classification enrichment. |
| Anthropic (Claude Haiku) | `askalrt` service | Ask ALRT tier-3 fallback, prompt-cached system prompt. |
| Google Maps Platform (server) | Backend | Geocoding/Places proxy exists but is currently bypassed by the frontend for those calls (§4). |
| Google Maps Platform (client) | Frontend | Direct client calls with a build-time-injected key. |
| Google OAuth | Both | |
| Apple Sign-In | Both | |
| Microsoft OAuth | Backend (now implemented, audit branch) / Frontend (implemented, UI disabled) | See §4. |
| Firebase Cloud Messaging | Both | |
| Firebase Auth / App Check / Cloud Functions | `askalrt` + frontend | |
| RevenueCat | Frontend (SDK) + Backend (webhook, `BILLING_ENABLED`-gated) + `askalrt` (separate webhook/entitlement) | Three independent RevenueCat consumers — see §6.2's split-brain risk, same pattern applies here. |
| Sightengine | Backend | Image/video moderation for uploaded hazard media. |
| NSW Transport Open Data API, WAQI (air quality), NSW RFS, BoM, ACT ESA, SA CFS, VIC Emergency, QLD Bushfire, NT PFES, Open-Meteo, Smartraveller, WA Emergency, NSW SES (HazardWatch CAP), USGS earthquakes, QLD Traffic, QLD Parks | Backend | The 13+ live hazard-source feeds; see full endpoint list in `backendV2/docs/CONNECTIONS.md`. |
| SMTP (Nodemailer) | Backend | Transactional/support email. |
| Redis / ElastiCache (Valkey) | Backend | Optional cache layer. |
| Socket.IO | Backend + Frontend | Realtime push. |

---

## 9. Classification by layer

- **Frontend-only:** all UI/UX for every feature in §4; Android/iOS build & signing config; home-screen widget native code (Kotlin/Swift); CI workflows for TestFlight/QA-APK builds.
- **Backend-only:** Admin API; alert ingestion/classification pipeline; all 13+ hazard-source connectors; RevenueCat webhook + entitlement computation; Ask ALRT native port (Implementation B, §6.2); Microsoft OAuth verification; Secrets Manager integration; database schema/migrations.
- **Ask ALRT (standalone):** the `askalrt` Firebase Functions project in its entirety — Implementation A of §6.2, its own Firestore-backed answer library, its own RevenueCat webhook/entitlement record, its own quota tracking. Architecturally separate from `backendV2` by design, but with unresolved overlap (§6.2, §8).
- **Admin Portal:** **not located** — see §4's Admin API row. Open item.
- **Infrastructure/configuration only, not app code:** GitHub default-branch pointer fix (§3.1); `BILLING_ENABLED` go-live flag (§6.1); AWS Secrets Manager Agent sidecar wiring; Docker blue/green deploy setup (`backendV2` already has this — two containers, `app_blue`/`app_green`, bound to loopback ports behind an external reverse proxy); CI pipeline consolidation (§6.4).
- **Deployment-only:** blue/green container switch-over process; TestFlight/Play internal-testing rollout sequencing (release plan's own priority #11-12) — not evaluated by this audit beyond confirming the Docker/CI scaffolding exists.

---

## 10. Summary answers

### A. Recommended frontend baseline
**`ALRT-dev/frontendV2`, branch `claude/safety-alert-repo-audit-8exgvn`** (equivalently reachable via `ALRT-dev/widget` under the same branch name, per §1 — they are the same repository). Not the GitHub-default branch (`feature/home-screen-widgets`, which is a CI-workaround artifact — see §3.1). This branch is the only one with: Ask ALRT, Safety Profile, Child Mode, Journey sharing, Daily check-ins, the full Family SOS suite, the current product-owner-ruled alert-color design system, a real (if small) regression test suite, and the working TestFlight/QA-APK CI. Before promoting it: apply the desugaring **version bump** from §5 item 3 / §14 item 3 (the fix itself is present on this branch already, just pinned to the older `2.1.4` — bump to `2.1.5`).

> **Stage 2 update:** §6.3's `V2-Claude` unique-content question is now resolved — see §12. Net result: this baseline (A) needs no code ported from V2-Claude except two small Android hardening items (§5/§14) and is worth enriching with one V2-Claude **document** (`ALRT_ALERT_CLASSIFICATION_AND_CONTENT_STANDARD.md`, ported and corrected — see §12).

### B. Recommended backend baseline
**`ALRT-dev/backendV2`, branch `claude/safety-alert-repo-audit-8exgvn`**, merged with **`claude/alrt-data-export-tzq4ex`** (the one branch with genuinely unmerged functional code — CSV/GeoJSON export + an Intel Centre sources spec). This branch is a verified strict superset of every other backend branch except that one, fixes two currently-live CVEs that are still on `main`, and implements Microsoft OAuth, the community-privacy hotfix, and the more mature ingestion pipeline described in §7.

### C. Recommended Ask ALRT baseline
**`ALRT-dev/askalrt`, `main`** — already current; its own audit branch is byte-identical (fully merged, nothing outstanding). However, do not treat this as a finished decision on its own: §6.2 must be resolved first, since `main` here is only one of three-to-four parallel Ask ALRT implementations across the whole codebase family, and consolidation may mean retiring parts of `backendV2` instead of (or as well as) keeping this repo exactly as-is.

### D. Important historical fixes to recover
In priority order — **updated in Stage 2 (§14), corrections marked**:
1. Two live, unpatched dependency CVEs on `backendV2`'s `main` (`basic-ftp` CRLF injection = **CVE-2026-39983**, `effect` context leakage = **CVE-2026-32887**) — fixed further down history (`f4bf93b`), not yet ported to `main`. Exact target versions and file changes: §14 items 1-2.
2. Android core-library desugaring for `flutter_local_notifications` — **correction: the fix itself IS present on the recommended frontend baseline**, just pinned to the older `desugar_jdk_libs:2.1.4`; bump to `2.1.5` (confirmed the later Maven release; found independently applied **four** times across both frontend repos by three different people — a real duplicated-effort pattern). See §14 item 3.
3. Play Store service-account key `.gitignore` hardening (Matt's fix, `ab534be`, not yet on `frontendV2`'s baseline) — confirmed no actual secret was ever committed to either repo's history, so this is a preventive gap, not an active leak. See §14 item 4.
4. OpenSSL update on the backend — **correction: this is a Dockerfile `apt-get upgrade openssl` step targeting CVE-2025-15467**, not an npm package or Node version bump; present on deeper branches, absent from `main` along with an earlier ImageMagick-removal hardening step it was stacked on top of. See §14 item 5.
5. The deleted Google Maps key-rotation runbook (`docs/google-maps-key-rotation.md`, recoverable via `git show 4662b7c` on `V2-Claude`) — needed if the client-side-key-exposure decision (§4/§5 item 1) goes toward re-adopting the backend proxy. **Still an open decision, not resolved in Stage 2.**
6. ~~"Nodemailer/Wiz remediation" and the exact "location-subscription race-condition fix"~~ — **RESOLVED in Stage 2, both confirmed real and already fixed on `main`.** "Wiz" is a genuine security-scanner GitHub App (not a personal email domain, as Stage 1 incorrectly concluded); Nodemailer was bumped 7.x→8.0.5 to close 2 Wiz findings. The location-subscription fix is a create/catch-P2002/retry pattern replacing an earlier race-prone check-then-act, backed by a migration that deleted real duplicate rows. See §14 item 6.

### E. Major missing functionality
**Updated in Stage 2 (§15) — three of four items reclassified with evidence:**
1. **Admin Portal frontend — CONFIRMED MISSING, exhaustively.** Stage 2 checked all six other `ALRT-dev` repos this session can reach (`alrt`, `ALRT-screen`, `mattv2`, `occulo`, `glasses`, `watchinterface`) — two are empty repos, the rest are docs/design-mockup repos with no application code. **No Admin Portal exists anywhere in this org's accessible repositories.** It must be scoped and built as new work; see §15 for minimum scope against `backendV2`'s existing Admin API.
2. **Safety Profile backend — RECLASSIFIED AS DONE (by design), not missing.** Confirmed zero references anywhere in `backendV2` across all 10 branches — but this is intentional privacy-by-design architecture, independently corroborated by `askalrt`'s own system prompt ("stays on their phone") and a 1,043-line curated on-device content library explicitly sourced from a product-owner-approved document. No backend work needed; only a product-owner sign-off that "on-device only" is final, plus closing the `V2-Claude` comparison (§12, also now resolved — V2-Claude's version is an admitted "interim, non-normative" stepping-stone per its own doc, already superseded by frontendV2's implementation).
3. **Child Mode backend — confirmed genuinely missing, but NOT a V1 blocker.** It's architected as a pure on-device toggle with no network calls anywhere in its provider/screen code, and its own code comments explicitly reject being "an age gate, an identity claim, or anything the app tells a server" (deliberately avoiding app-store parental-consent obligations). No action needed for V1.
4. **Journey sharing's 15-minute start option — confirmed missing on BOTH sides**, not backend-only as Stage 1 implied: the frontend also hardcodes `[30, 60]` in two files. Minimum fix is small and precise: two one-line backend changes (`ALLOWED_START_MINUTES` array + a Zod validator union) and two frontend const-array edits — see §15 item 4 for exact file:line locations.
5. Full operational Source Registry (health checks, review/expiry surfacing, quarantine states, per-source audit log) per `V1_SOURCE_REGISTRY_BACKLOG.md`'s P0 list — the data model and matching utility exist; the admin-facing operational layer around it does not yet, and depends on item 1 (the Admin Portal) existing at all.

### F. Major conflicts between branches
**Updated in Stage 2 — items 1, 2, 4 now resolved:**
1. ~~Ask ALRT's three-to-four parallel implementations~~ — **RESOLVED.** `askalrt/main` is confirmed as the sole, genuinely-live implementation; `backendV2`'s native port is dead code with zero real callers. Full recommendation and cleanup plan: §13.
2. ~~`V2-Claude`'s newest branch may contain unreconciled Safety Profile / Ask ALRT / Alert Classification v1.2 work~~ — **RESOLVED.** Direct comparison done (§12): V2-Claude's Safety Profile is an admitted interim stepping-stone already superseded; its Ask ALRT targets the now-deprecated native backend port; its Alert Classification doc (v1.2) is genuinely valuable and should be ported as *documentation* (with corrected colours/emergency-number sections) even though frontendV2's *code* is ahead.
3. **The Google Maps client-key-exposure decision** — still open. A full fix was built and then deliberately reverted, independently, on both frontend lineages (identical `4662b7c`/`5b1eba2` commits reachable from both); the underlying tension (client convenience/reliability vs. key-rotation security) was never actually resolved, just backed away from (§4, §5 item 1). **Needs a product/engineering decision before V1; not resolved by Stage 2.**
4. ~~Product-plan numbers vs. shipped numbers~~ for AI quota, free saved-locations, and journey-sharing durations — **RESOLVED.** Product owner has ruled; see §11 for the authoritative numbers and what code needs to change to match them.
5. **Two independently-built iOS TestFlight CI pipelines** across `frontendV2` and `V2-Claude`, still never directly compared line-by-line — low priority, not blocking.
6. **`frontendV2`'s misleading GitHub default branch** (§3.1) — still unaddressed; a **CONFIGURATION** task, not urgent but should happen before this becomes anyone else's starting point by default.

### G. Recommended next step
**Superseded by §16 (Recommended Implementation Order), written after all Stage 2 investigations completed.** See §16 for the concrete, current sequence.

---

*This report is a point-in-time snapshot (branches fetched with ~200 commits of history each; some very old history beyond that depth was not inspected). No application code, configuration, or infrastructure was modified in the course of producing it. Stage 2 sections below were added in a follow-up pass after product-owner rulings were provided; Stage 1 content above is preserved as-written except where explicitly marked corrected.*

---

## 11. Stage 2 — Product-owner rulings (now authoritative)

These supersede `V1_RELEASE_PLAN.md`'s numbers wherever they conflict, and supersede Stage 1's "needs a decision" framing in §6.1. **None of this has been applied to code yet** — this section states the target state; §16 sequences the actual changes.

| Rule | Authoritative value | Current shipped code | Gap |
|---|---|---|---|
| Free saved locations | **1 maximum** | `backendV2`: `FREE_SAVED_LOCATIONS_LIMIT = 3` (`location_subscription.service.ts`) | Code allows 3, must be reduced to 1. **MODIFY.** |
| Free Ask ALRT quota | **5/day** | `askalrt`: `AI_DAILY_LIMIT.free = 3`; `backendV2`'s (now-deprecated) native port also has `FREE_DAILY_AI_LIMIT = 3` | `askalrt/main` (the confirmed canonical implementation, §13) needs its constant changed 3→5. **MODIFY.** |
| ALRT+ Ask ALRT quota | **30/day** | `askalrt`: `AI_DAILY_LIMIT.plus = 20` | Needs 20→30. **MODIFY.** |
| ALRT+ hosted family seats | **8 maximum** | `backendV2`: `MAX_SEATS_TOTAL = 8` (`family.service.ts`) | **Already matches — KEEP, no change.** |
| ALRT+ free trial | **1 month** | Store/RevenueCat-side trial config, not server-enforced in code (architecturally correct — trial length is a StoreKit/Play Billing product configuration, not application logic) | Verify the actual App Store Connect / Play Console product trial period is configured to 1 month — a **CONFIGURATION** check, not a code change. |
| Invited family member needs no individual ALRT+ purchase | Confirmed existing design intent | `backendV2`'s entitlement model already gates seat *hosting* behind ALRT+, not seat *membership* — matches the rule as designed (per Stage 1 §4's ALRT+ row) | **Already matches — KEEP, no change**, but worth an explicit regression test given how central this rule is to the pricing model. |
| Journey sharing start options | **15 / 30 / 60 minutes** | `backendV2`: `ALLOWED_START_MINUTES=[30,60]` + matching Zod validator; `frontendV2`: two hardcoded `_durations=[30,60]` arrays | Confirmed missing on **both** sides — see §15 item 4 for exact file:line fix. **MODIFY, both frontend and backend.** |
| Journey sharing extend | **+1 hour per extension** | `backendV2`: extend-per-block already 60 min | **Already matches — KEEP.** |
| Journey sharing maximum | **4 hours, never indefinite** | `backendV2`: `MAX_TOTAL_MINUTES=240`, self-standing-down live-share cap enforced (SOS side too, `36fe52d`) | **Already matches — KEEP.** A 15-minute increment composes cleanly with the 240-minute cap (16 possible blocks) — confirmed no knock-on change needed there. |
| Ask ALRT architecture | **`askalrt/main` is primary/current unless a specific production fix elsewhere is proven necessary** | See §13 — investigated in full | **Ruling confirmed correct by the investigation; no override needed.** See §13 for the full evidence trail and cleanup recommendation. |

**Net code-change scope from this section alone:** 3 numeric constants in `askalrt` (free quota, plus quota) and `backendV2` (saved-location cap), plus the journey-sharing 15-minute addition (§15 item 4, 4 small edits across 2 repos). All are small, low-risk, non-breaking changes — no schema migrations required for any of them.

---

## 12. Stage 2 — frontendV2 vs. V2-Claude: detailed comparison

Full comparison of the recommended frontend baseline (`frontendV2` @ `claude/safety-alert-repo-audit-8exgvn`) against V2-Claude's deepest branch (`claude/alrt-app-update-scope-s24m2k`), across every area requested. Classification taxonomy: **KEEP FROM FRONTENDV2** / **PORT FROM V2-CLAUDE** / **ALREADY PRESENT** / **OBSOLETE** / **CONFLICT / NEEDS REVIEW**.

| Area | Classification | Reason |
|---|---|---|
| Google/Apple/email auth | ALREADY PRESENT | Identical file sets on both, no divergence. |
| Microsoft OAuth | ALREADY PRESENT | Byte-identical disabled button on both branches, same backend-wiring gap (now closed on the backend side per Stage 1 — needs the same one-line frontend re-enable regardless of which frontend baseline is used). |
| Google Maps client key exposure | ALREADY PRESENT | Same build-then-revert commit pair (`4662b7c`/`5b1eba2`) reachable from both lineages — identical situation, still an open decision (§6/F.3), not something V2-Claude resolves differently. |
| Alert design system (colours/shapes) | KEEP FROM FRONTENDV2 | frontendV2's is locked, regression-tested, and its magenta-Security ruling (2026-08-20) postdates V2-Claude's colour doc (2026-08-03) — frontendV2's palette wins on both merit and timing. |
| **Alert Classification & Content Standard v1.2 (documentation)** | **PORT FROM V2-CLAUDE** | A unique, detailed 416-line governance spec (wording rules, routing, emergency-flag matrix, a worked new-source-onboarding checklist) with no equivalent anywhere in frontendV2. frontendV2's *code* already implements most of what it describes, but frontendV2 has no equivalent document — this is real, valuable documentation debt to close. Port it, but correct two stale sections first: its category-colour table (still red for Security & Crime, not the current magenta ruling) and its hardcoded-emergency-number section (superseded by frontendV2's dynamic SIM/region/locale resolution). |
| Ask ALRT chat UI/UX | KEEP FROM FRONTENDV2 | More mature (on-device fast path, dynamic non-AU-only emergency numbers, tested), built after and effectively superseding V2-Claude's single-commit version. See §13 for the backend-architecture half of this question, which is the actually load-bearing part. |
| Ask ALRT backend contract / quota-remaining UI | CONFLICT / NEEDS REVIEW — **now resolved via §13** | frontendV2 talks to the confirmed-canonical `askalrt` Firebase callable; V2-Claude's sheet targets `backendV2`'s now-recommended-for-deletion native port. V2-Claude's one genuinely good idea — a visible "N AI questions left today" / "limit reached" state — is worth re-implementing against the canonical backend, not ported as code (the code targets the wrong backend entirely). |
| Safety Profile on-device model | ALREADY PRESENT | Both on-device-only, no server round-trip, same architecture. |
| Safety Profile "For You" content engine | OBSOLETE (V2-Claude's version) | V2-Claude's own governing document explicitly labels its keyword-reorder implementation an "interim, non-normative... stepping-stone," and names frontendV2's curated 1,043-line library approach as the intended normative target — which frontendV2 has already built. Nothing to port; V2-Claude's version is exactly what its own spec says should be replaced. |
| Family (hub/circles/invites/places) | KEEP FROM FRONTENDV2 | Structurally present on both; the file-count gap is fully explained by SOS sub-features, not a parallel family implementation. |
| SOS | OBSOLETE (V2-Claude's version) | V2-Claude has only the base activate/receive pair inherited from an August-1 merge; frontendV2 added list-management, resolved-state, and roll-call screens afterward. Nothing to port. |
| Journey sharing | KEEP FROM FRONTENDV2 | Absent entirely from V2-Claude (0 files) — a post-freeze frontendV2-only feature. |
| Location snapshots | KEEP FROM FRONTENDV2 | Present in reduced form on V2-Claude, fully built out only on frontendV2; no distinct logic worth porting. |
| Child Mode | KEEP FROM FRONTENDV2 | Absent entirely from V2-Claude (0 matches) — a post-freeze frontendV2-only feature, consistent with it also being backend-absent everywhere (§15). |
| ALRT+ pricing | ALREADY PRESENT (Stage 1 finding corrected) | frontendV2's own doc and code already agree at $9.99/$99.99 (product-owner price change, commit `f9ea9b5`, 2026-08-03) — **there is no live doc/code mismatch on the recommended baseline.** The $9.99/$99.99 figure only ever appears in a CI-gated, non-purchasing QA preview path, never a real store price. V2-Claude's setup doc is simply the pre-change stale figure and is not evidence of a frontendV2 problem. |
| ALRT+ paywall implementation pattern | ALREADY PRESENT / minor note | frontendV2 has a CI-only "dummy price" preview mode (gated, non-purchasing); V2-Claude has no such mode and always reads the live store price — simpler and arguably marginally safer, but frontendV2's gating was verified safe. Low-priority hardening note only, not an action item. |
| FCM / push notifications | ALREADY PRESENT | Identical file lists on both. |
| Android `desugar_jdk_libs` version | PORT FROM V2-CLAUDE | frontendV2 pins `2.1.4`, V2-Claude pins the newer `2.1.5` (confirmed via Maven release dates in §14) — bump frontendV2 to match. |
| Android `targetSdk=35` pin | ALREADY PRESENT | Both branches pin it independently. |
| `playstore-access.json` `.gitignore` entry | PORT FROM V2-CLAUDE | One-line hardening present on V2-Claude (`ab534be`), absent from frontendV2's baseline. No secret was ever actually committed on either side (§14 item 4) — this closes a preventive gap, not an active leak. |
| Signing-config fallback logic | ALREADY PRESENT | Same conditional keystore/debug-fallback pattern verified directly on frontendV2. |
| Home-screen widgets | OBSOLETE (V2-Claude's version) | V2-Claude lacks compact layouts, the per-circle family-icon renderer, and the widget-pinning service that frontendV2's baseline has since added. |
| iOS TestFlight CI | NOT DIRECTLY COMPARABLE in this pass | V2-Claude's pipeline lives on a separate branch (`ci/ios-testflight`) not included in this specific branch-to-branch diff. Stage 1's recommendation to compare the two pipelines before consolidating still stands, unresolved. |

**Bottom line:** frontendV2's recommended baseline is a strict superset of V2-Claude for nearly everything. The only concrete ports needed are two small Android hardening items (§5/§14) and one **documentation** file (the Alert Classification & Content Standard, corrected before landing). No V2-Claude *code* needs merging into the frontend baseline.

---

## 13. Stage 2 — Ask ALRT architecture: final recommendation

**The product owner's provisional ruling is confirmed correct: `ALRT-dev/askalrt`, branch `main`, is the sole V1 Ask ALRT implementation.** This was verified, not assumed — by tracing the actual runtime call chain in the shipped frontendV2 client, not just by comparing backend code in isolation.

**The decisive fact:** frontendV2's Ask ALRT chat UI (`lib/features/ask_alrt/ask_alrt_provider.dart`) calls the Firebase Cloud Functions callable `askAlrt` directly via the `cloud_functions` SDK — i.e., `askalrt/main`. It authenticates by first calling `backendV2`'s `POST /api/user/firebase-token` (which mints a Firebase custom token from the app's existing `backendV2` session), then signs into Firebase with that token, then calls the callable. There is **no code path anywhere in frontendV2** that calls `backendV2`'s native `/api/ask` endpoint — that URL constant doesn't even exist in frontendV2's `lib/api/endpoints.dart`. It exists only in V2-Claude, which Stage 1 already established is a superseded lineage.

**What each implementation is, for the record:**
- **`askalrt`/main (canonical):** Firebase callable, Firebase Auth + App Check, Claude Haiku via direct Anthropic SDK, Firestore-editable answer library, Firestore-transactional (race-safe, fails closed) quota tracking.
- **`backendV2`'s native port (`askalrt.service.ts` etc., mounted at `/api/ask`):** a parallel re-implementation using Bedrock/OpenAI instead of Anthropic, with real DB-verified alert grounding (queries Postgres hazards directly, returns structured citations) and an admin-console-editable system prompt — genuinely better in a couple of specific ways, but **confirmed to have zero real callers** once V2-Claude is set aside. Built the same day as frontendV2's Firebase-calling UI, evidently without coordination on which would actually ship.
- **`backendV2`'s firebase-token bridge (`firebase_token.controller.ts`):** not a competing implementation — this is required plumbing that keeps the canonical implementation reachable, since the app authenticates against `backendV2`, not Firebase, natively.
- **V2-Claude's Ask ALRT bottom sheet:** a client built the same day as the native port, targeting it. Dead along with the port, per Stage 1's broader V2-Claude-is-superseded finding.

**What's worth carrying forward from the deprecated native port, even though the port itself is being retired** (all portable into `askalrt`'s existing Firebase/TypeScript/Anthropic architecture without needing Postgres/Prisma access):
1. **Admin-editable system prompt** — easy port. `askalrt` already has the identical pattern one level down (`askAlrtEntries`, Firestore-editable, 5-min cache, safe fallback) — apply the same mechanism to one more document for the system prompt string.
2. **Structured alert citations** (`referencedAlerts` in the response, rendered as source chips in the UI) — moderate port. Achievable by having the *client* send structured alert objects (id/title/severity/source) instead of a flattened text blob, and having the callable echo back which ids it used. True server-side DB re-verification against Postgres would require new cross-service coupling and is **not recommended** — the client-structured-data approach captures most of the value without it.
3. **General IP-based rate limiting on top of per-user quota** — easy-moderate port, using a Firestore-transaction-based limiter or Firebase App Check's replay protection / a Cloud Armor front-end; doesn't need anything from `backendV2`.
4. **Quota-remaining UI** ("3 AI questions left today" / "Daily limit reached") from V2-Claude's sheet — a real UX feature currently missing from frontendV2's Ask ALRT sheet. Needs `askalrt`'s callable to return the same `remainingAiQuestions`-shaped field before the UI can show it.

**Two items already flagged in Stage 1, reconfirmed still open and worth fixing in the same pass as this cleanup:**
- `askalrt`'s Remote Config kill-switch (`agent_enabled`) is declared but read by **no code anywhere** — not the callable, not any client. Currently does nothing. Fix: read it at the top of the callable and short-circuit with a calm "temporarily unavailable" response.
- Quota numbers need the §11 correction (3/20 → 5/30).

**Concrete disposition once this is approved for implementation:**
- **Delete:** `backendV2`'s `askalrt.service.ts`, `askalrt.controller.ts`, `askalrt.route.ts`, `askalrt.validator.ts`, its route mount, and its Prisma/hazard-query dependency — after extracting the citation-response shape and admin-prompt pattern as implementation references for porting into `askalrt` (items 1-2 above).
- **Keep, untouched:** `backendV2`'s `firebase_token.controller.ts` / `POST /api/user/firebase-token` — this is load-bearing plumbing for the canonical implementation, not a duplicate to clean up.
- **Do not port:** V2-Claude's Ask ALRT sheet UI code — it's a client for the implementation being deleted. Its one good idea (quota-remaining display) should be re-implemented fresh against `askalrt`'s contract, not lifted as code.

---

## 14. Stage 2 — Security fix & CVE inventory (verified)

### CVE table

| CVE | Dependency | Current version (`main`) | Safe/target version | Files to change | Breaking? | Test coverage |
|---|---|---|---|---|---|---|
| **CVE-2026-39983** — `basic-ftp` FTP command injection via CRLF | `basic-ftp` (transitive, via `get-uri`; not directly imported anywhere in `src/`) | `5.2.0` | `5.3.1` (still within `get-uri`'s declared `^5.0.2` range) | `package.json` (`overrides`/`resolutions`), `yarn.lock`, `package-lock.json` — manifest/lockfile only, no code changes | No — patch-level bump, package never directly imported | **None — `backendV2` has zero test files at any commit, on any branch.** No regression coverage exists for this or any other change. |
| **CVE-2026-32887** — `effect` `AsyncLocalStorage` context leakage | `effect` (transitive, via `@prisma/config`'s hard pin `3.16.12` — no version range, so only an override can move it) | `3.16.12` (no override present on `main`) | `3.21.5` (requires **adding** a new override/resolution that doesn't exist on `main` today) | `package.json` (add `overrides.effect` + `resolutions.effect`), `yarn.lock`, `package-lock.json` — no code changes | Low risk (minor→minor within the same major, never directly imported), but it overrides a dependency's own internal pin — worth a manual smoke test of the Prisma CLI/config-loading path after upgrading | **None**, same as above. |

Both are fixed together at commit `f4bf93b` (merged via PR #18 as `faceba7`, by Matt, 2026-07-28), which quotes both CVE IDs verbatim in its message. Present on `claude/safety-alert-repo-audit-8exgvn`, `live-sync`, `claude/alrt-app-update-scope-s24m2k`. **Absent from `main` and every other branch** — confirms Stage 1's "do not treat `main` as deployable" conclusion.

### Item 3 — Android desugaring: verified, and a correction to Stage 1

Stage 1's §10.A said the desugaring fix was "missing even on this best branch" — **this was incorrect and contradicted Stage 1's own §4 table.** Verified directly: the fix **is present** on frontendV2's recommended baseline (`claude/safety-alert-repo-audit-8exgvn`, commit `c03b714`, 2026-08-03), pinned to `desugar_jdk_libs:2.1.4`. What's actually missing is the newer version pin. The fix was independently written **four separate times** (not two, as Stage 1 found) across the two frontend repos:

| Branch(es) | Commit | Author | Version |
|---|---|---|---|
| frontendV2 `claude/safety-alert-repo-audit-8exgvn` | `c03b714` | Claude | 2.1.4 |
| V2-Claude `live-sync`, `claude/alrt-app-update-scope-s24m2k` | `f413ebb` | Matt | **2.1.5** |
| V2-Claude `ci/ios-testflight`, `integrate/navigation-update` | `dce825d` | Sarah | 2.1.4 |
| V2-Claude `claude/frontend-backend-features-10oyjg` | `c1b6c63` | Claude | 2.1.5 |

`2.1.5` is confirmed as Google's later Maven release (Feb 2025 vs. Dec 2024 for `2.1.4`) — bump frontendV2's baseline to `2.1.5`.

### Item 4 — Play service-account key `.gitignore`: verified, no actual secret exposure

Confirmed commit `ab534be` (Matt, V2-Claude `live-sync`/`claude/alrt-app-update-scope-s24m2k`), adding `app/playstore-access.json` to `.gitignore`. Confirmed absent from frontendV2 at both `main` and its audit branch. **A full history search on both repos for any actual service-account-shaped file ever being committed (added then later removed) found nothing — no secret was ever exposed, this closes a preventive gap only.** Separately noted: `backendV2`'s Dockerfile still `COPY`s a real Firebase `serviceAccountKey.json` into the built image layer — a different, pre-existing hardening item outside this specific one's scope, flagged for awareness.

### Item 5 — OpenSSL bump: verified, and a correction to Stage 1's characterization

This is **not** an npm package or Node.js version bump — it's a `Dockerfile` step (`apt-get upgrade -y openssl`) targeting **CVE-2025-15467**, confirmed via the commit's own inline comment (`5b69a9c`, 2026-04-21). `main` is missing not just this line but the entire hardening block it's stacked on, including an earlier ImageMagick-removal step (CVE-2023-34152). Since the base image tag (`node:24`) floats rather than being pinned, this step is what actively forces a fresh OpenSSL patch level at every build — without it, the deployed container trusts whatever OpenSSL vintage the base image happened to ship with.

### Item 6 — Nodemailer/Wiz & location-subscription race condition: found, Stage 1 corrected

**Nodemailer/Wiz — Stage 1 was wrong to dismiss this.** Two merge commits (`901327e` PR#12, `22684c0` PR#15, both merged by Matt, 2026-06-30) titled "Wiz: Upgrade nodemailer to 8.0.5 (resolves 2 findings)". The underlying commits are authored by `wiz-f74d8ca267[bot]` — **a genuine automated security-scanner GitHub App**, not merely part of a contributor's personal email domain as Stage 1 concluded. `nodemailer` went 7.x → `8.0.5` (major bump). Already an ancestor of `main` — **no porting action needed, already live.**

**Location-subscription race condition — high-confidence match, not textually certain.** `location_subscription.service.ts`'s `upsertUserOwnLocationSubscription` (commit `f716684`, 2026-02-02) replaces an earlier check-then-act pattern with create/catch-P2002/retry, with the inline comment `// If unique constraint violation (race condition), find and update instead`. The same commit's migration explicitly deletes pre-existing duplicate rows before adding a partial unique index — strong evidence this was a real production issue, not theoretical. No commit/PR title uses the exact release-plan wording, so this is reported as high-confidence circumstantial, not certain — but it is already an ancestor of `main`, so **no porting action needed either way.**

---

## 15. Stage 2 — Missing backend capabilities: verified

| Item | Classification | Evidence | Minimum work for V1 |
|---|---|---|---|
| **Admin Portal frontend** | **MISSING** — confirmed exhaustively | All 6 other reachable `ALRT-dev` repos checked (`alrt`, `ALRT-screen`, `mattv2`, `occulo`, `glasses`, `watchinterface`): two are empty GitHub repos, the rest contain only design mockups/markdown specs, no application code, no framework, nothing calling `backendV2`'s `/admin/*` routes. This exhausts every repo this session can reach. | A new web frontend (React/Next.js or similar) against `backendV2`'s existing role-tiered Admin API: auth, stats/dashboard, app-user management, hazard-category/source CRUD (incl. licensing), AI-prompt editor (tie into the content pipeline described in `ALRT-screen/alrt-knowledge-repo-structure.md`), configuration editor, webhook API-key management. This is a full new build, not a patch — treat as its own project phase. |
| **Safety Profile backend** | **DONE (by design)** — not a gap | Confirmed zero references in `backendV2` across all 10 branches, but corroborated as intentional by `askalrt`'s own system prompt ("stays on their phone") and frontendV2's 1,043-line curated content library sourced from a product-owner-approved document. | None. Only needs product-owner sign-off that on-device-only is final architecture (it demonstrably already is, in two independently-built codebases). |
| **Child Mode backend** | **MISSING, not a V1 blocker** | Confirmed zero references in `backendV2`. Frontend implementation is a pure `SharedPreferences` toggle with no network calls anywhere in its provider/screen code, and its own code comments explicitly reject being a security boundary or identity claim (deliberately avoiding app-store parental-consent triggers). | None for V1. If server-side tamper-resistance is wanted later, would need a session claim + a check in the report-creation endpoint — explicitly discouraged by the feature's own design philosophy; not recommended. |
| **Journey sharing 15-minute option** | **MISSING on both sides** (corrects Stage 1's backend-only framing) | Backend: `family_journey.service.ts`'s `ALLOWED_START_MINUTES=[30,60]` plus a matching Zod `z.union([z.literal(30), z.literal(60)])` in `family.validator.ts:186`. Frontend: `family_journey_screen.dart:30` and `family_journey_share_sheet.dart:37` both hardcode `_durations=[30,60]`. | Backend: add `15` to the array and `z.literal(15)` to the union (2 one-line edits, no schema/migration needed). Frontend: add `15` to the two `_durations` const arrays (existing minute-formatting label logic already handles it). Confirmed the 240-minute cap composes cleanly with 15-minute increments. |

---

## 16. Recommended implementation order

This is the concrete sequence for the actual build phase, incorporating every Stage 1 + Stage 2 finding. Nothing in this sequence has been executed — this is a plan only.

1. **Establish the two baselines in this repo.** Bring `frontendV2`'s `claude/safety-alert-repo-audit-8exgvn` and `backendV2`'s `claude/safety-alert-repo-audit-8exgvn` (merged with `claude/alrt-data-export-tzq4ex`) into `ALRT-V1-Release-Candidate` as the starting point. Fix `frontendV2`/`widget`'s misleading GitHub default branch as part of this (§3.1/F.6).
2. **Apply the now-resolved small fixes together, in one pass** (all low-risk, no schema migrations, no architectural decisions required):
   - Bump `desugar_jdk_libs` 2.1.4 → 2.1.5 on the frontend baseline.
   - Add `app/playstore-access.json` to the frontend `.gitignore`.
   - Add the two CVE overrides (`basic-ftp` → 5.3.1, `effect` → 3.21.5) to the backend baseline, and port the OpenSSL/ImageMagick Dockerfile hardening block.
   - Apply the §11 numeric rulings: saved-locations cap 3→1, Ask ALRT quotas 3/20→5/30 (in `askalrt`, the confirmed canonical implementation).
   - Add the journey-sharing 15-minute option on both sides (§15 item 4).
3. **Execute the Ask ALRT consolidation** (§13): extract the citation-response shape and admin-editable-prompt pattern from `backendV2`'s native port as reference, then delete that port and its route mount; keep the firebase-token bridge untouched; port the two portable improvements (admin-editable prompt, structured citations) and the quota-remaining UI into `askalrt`/frontendV2; fix the dead `agent_enabled` kill-switch.
4. **Port the one valuable V2-Claude artifact**: the Alert Classification & Content Standard v1.2 documentation, with its stale colour table and hardcoded-emergency-number section corrected to match the frontend baseline's current implementation, before landing it as governance documentation.
5. **Make the one still-open architectural decision**: the Google Maps client-key-exposure question (§4/§5 item 1/F.3) — decide whether to re-adopt the backend proxy (recovering the deleted rotation runbook via `git show 4662b7c`) or formally accept the current client-side-key-exposure risk with compensating controls (key restrictions, rotation cadence). This is the one remaining item in this whole reconciliation that genuinely needs a human engineering/security judgment call rather than just applying a known fix.
6. **Scope and build the Admin Portal** (§15) as its own project phase against `backendV2`'s existing Admin API — this is net-new work, not a port, and should not block the rest of V1 shipping if resourced separately; the Source Registry's operational/admin-facing layer (§10.E.5) depends on this existing.
7. **Real-device QA** (release plan priority #11) — only after steps 1-6, run the app on real Android/iOS hardware, specifically verifying the home-screen widgets actually compile and run (flagged in Stage 1 as never confirmed built, having been authored without a Flutter/Gradle/Xcode toolchain), and confirm the two untested SOS product rules (no generic emergency-call button, "on my way" not exposing responder location) and the location-snapshot physical-consent UX.
8. **Deploy**: backend/services first, then TestFlight/Play internal testing, then production (release plan priorities #11-12), using whichever of the two independently-built iOS CI pipelines is chosen after the comparison flagged in F.5.

---

## 17. Stage 3 — First controlled implementation phase (executed)

**Scope of this phase, as instructed:** establish the V1 baselines in this repository, apply only the Stage-2-verified security/build fixes, apply the confirmed product-owner numeric rulings, add journey sharing's 15-minute option, consolidate Ask ALRT onto `askalrt/main`, and port the classification governance document. Explicitly **not** attempted: the Admin Portal build, the Google Maps architectural decision, any broad Family/SOS redesign, new alert-engine features, or deployment of any kind. No original repo (`frontendV2`, `backendV2`, `askalrt`, `V2-Claude`, `v3`) was touched — every change below is local to `ALRT-V1-Release-Candidate`, on branch `claude/alrt-v1-rc-audit-a3gmai`.

**Method:** each of `frontendV2` (`claude/safety-alert-repo-audit-8exgvn`), `backendV2` (`claude/safety-alert-repo-audit-8exgvn`), and `askalrt` (`main`) was brought in via `git subtree add --squash`, which preserves the exact source commit as a trailer on the squash commit and keeps this repo's own history readable — not a manual copy. No wholesale merge of any other branch (in particular, `claude/alrt-data-export-tzq4ex`'s unmerged backend work, and anything from `V2-Claude`, were deliberately left out of this phase — neither was on the explicit small-change list this phase was scoped to).

### 17.1 Commit-by-commit record

| # | Commit(s) | What | Source | Destination |
|---|---|---|---|---|
| 1 | `70f41b0`, `d4b06db` | Establish frontend baseline | `ALRT-dev/frontendV2` @ `claude/safety-alert-repo-audit-8exgvn` | `frontend/` |
| 1 | `eff2183`, `9db80d9` | Establish backend baseline | `ALRT-dev/backendV2` @ `claude/safety-alert-repo-audit-8exgvn` | `backend/` |
| 1 | `eb92fcc`, `4058161` | Establish Ask ALRT baseline | `ALRT-dev/askalrt` @ `main` | `askalrt/` |
| 2 | `c08fdf1` | Security/build fixes: Android desugaring 2.1.4→2.1.5, Play service-account key `.gitignore` | this repo (edits) | `frontend/android/app/build.gradle.kts`, `frontend/android/.gitignore` |
| 3 | `87a080a` | Ask ALRT consolidation (quota numbers, kill-switch fix, admin-editable prompt, structured citations; removed orphaned backend native port) | this repo (edits + deletions) | `askalrt/functions/**`, `backend/src/{controllers,routes,services,validators}/askalrt.*` (deleted), `backend/src/index.ts`, `backend/src/routes/index.ts`, `backend/src/services/database_initialization.service.ts`, `frontend/lib/features/ask_alrt/**` |
| 4 | `2e41c26` | ALRT+ rule: free saved-locations cap 3→1 | this repo (edits) | `frontend/lib/features/subscription/providers/alrt_plus_provider.dart`, `frontend/lib/features/search/providers/main_search_provider.dart`, `backend/src/services/location_subscription.service.ts` |
| 5 | `c996818` | Journey sharing: add the 15-minute start option | this repo (edits) | `backend/src/services/family_journey.service.ts`, `backend/src/validators/family.validator.ts`, `frontend/lib/features/family/views/screens/family_journey_screen.dart`, `frontend/lib/features/family/views/widgets/family_journey_share_sheet.dart` |
| 6 | `5db781c` | Port Alert Classification & Content Standard v1.2 (corrected) | `ALRT-dev/V2-Claude` @ `claude/alrt-app-update-scope-s24m2k`, `docs/ALRT_ALERT_CLASSIFICATION_AND_CONTENT_STANDARD.md` | `frontend/docs/ALRT_ALERT_CLASSIFICATION_AND_CONTENT_STANDARD.md` |

Full commit messages (in the repo's `git log`) each carry the same detail as this table plus exact file:line reasoning, ported/verified-already-present distinctions, and test results — this section summarises them, it doesn't replace them.

### 17.2 Security/build fixes — what was actually needed vs. already present

Picking `claude/safety-alert-repo-audit-8exgvn` as the backend baseline (per §16 step 1) turned out to mean most of the "security fixes to apply" were **already shipped on that branch** — verified by direct inspection after import, not assumed:

| Fix | Status found | Action taken |
|---|---|---|
| CVE-2026-39983 (`basic-ftp` CRLF injection) | Already fixed: `backend/package.json` overrides/resolutions pin `5.3.1`, `backend/yarn.lock` resolves to `5.3.1` | None — verified only |
| CVE-2026-32887 (`effect` context leakage) | Already fixed: `backend/package.json` overrides/resolutions pin `3.21.5`, `backend/yarn.lock` resolves to `3.21.5` | None — verified only. **Observed but not fixed** (out of the explicit scope of this phase): `backend/package-lock.json` is stale and still resolves `effect@3.16.12` — but the Dockerfile only ever `COPY`s `package.json`+`yarn.lock` and runs `yarn install --frozen-lockfile`, so this stale file is never actually used by the real build. Flagged for a future cleanup pass, not touched here. |
| CVE-2025-15467 (OpenSSL) / CVE-2023-34152 (ImageMagick) Dockerfile hardening | Already present: `backend/Dockerfile`'s `apt-get upgrade -y openssl` + ImageMagick purge block | None — verified only |
| Nodemailer/Wiz remediation (`nodemailer` 7.x→8.0.5) | Already an ancestor of the imported baseline | None — verified only |
| Location-subscription race-condition fix (create/catch-P2002/retry) | Already an ancestor of the imported baseline, in `backend/src/services/location_subscription.service.ts` | None — verified only |
| Android core-library desugaring | **Present but on the older version** (`desugar_jdk_libs:2.1.4`) | **Fixed**: bumped to `2.1.5` (the later Google Maven release, per Stage 2's confirmed finding) |
| Play Store service-account key `.gitignore` | **Genuinely absent** | **Fixed**: added `app/playstore-access.json` to `frontend/android/.gitignore`. Re-confirmed during this phase (not just trusted from Stage 2) that no such secret file was ever actually committed to `frontendV2`'s history — this closes a preventive gap, not an active leak. |

No fix was invented or guessed. The two items Stage 2 could not match to an exact commit with full textual confidence (Nodemailer/Wiz, the race-condition fix) were **not** re-litigated here — Stage 2's high-confidence evidence (a real Wiz-bot-authored commit; an inline "(race condition)" code comment plus a migration that deleted real duplicate rows) was treated as sufficient to confirm both are already fixed and already present in the imported baseline, without this phase inventing new justification for them.

### 17.3 Product rules applied

| Rule | Before | After | Where |
|---|---|---|---|
| Free saved locations | 3 | **1** | `frontend` (`kFreeSavedLocationsLimit`) + `backend` (`FREE_SAVED_LOCATIONS_LIMIT`) |
| Free Ask ALRT quota | 3/day | **5/day** | `askalrt` (`AI_DAILY_LIMIT.free`) |
| ALRT+ Ask ALRT quota | 20/day | **30/day** | `askalrt` (`AI_DAILY_LIMIT.plus`) |
| ALRT+ hosted family seats | 8 | **8 (unchanged, already correct)** | `backend` (`MAX_SEATS_TOTAL`) — verified, not edited |
| Invited family member needs no individual ALRT+ | Already correct | **Unchanged, already correct** | `backend/CLAUDE.md`'s own locked rule confirms this; verified, not edited |
| ALRT+ free trial length | Store/RevenueCat config | **Unchanged** — this is App Store Connect/Play Console product configuration, not application code | Flagged as a **CONFIGURATION** item to verify externally, not a code change |
| Journey sharing start options | 30/60 min only | **15/30/60 min** | `backend` (`ALLOWED_START_MINUTES` + Zod validator) + `frontend` (two `_durations` arrays) |
| Journey sharing extend | +60 min | **Unchanged, already correct** | `backend` (`MAX_BLOCK_MINUTES`) — verified, not edited |
| Journey sharing maximum | 240 min | **Unchanged, already correct** | `backend` (`MAX_TOTAL_MINUTES`) — verified, not edited; confirmed a 15-minute increment still composes cleanly (16 possible blocks) |

The saved-locations change specifically confirmed, not just assumed, that hitting the limit does not fail bare: `frontend/lib/features/search/providers/main_search_provider.dart`'s `toggleSubscription()` already pushes `AlrtPlusPaywallScreen` when a free user hits the cap, and `backend/src/services/location_subscription.service.ts`'s 403 error message ("Free accounts can save up to N locations. ALRT+ removes the limit.") already derives `N` from the constant, so both update automatically with the number — no separate UX work was needed, only the number itself.

### 17.4 Ask ALRT consolidation — what changed and why

Confirmed and executed per §13's recommendation, which this phase treated as settled (re-verifying the call chain was not repeated, since §13 already traced it to the actual shipped client code):

- **`askalrt/main` quotas corrected** (3/20 → 5/30), and the error-message text now derives from the same constant instead of being separately hardcoded — closing off the exact class of drift that produced the original 3/20 mismatch.
- **The dead `agent_enabled` kill switch is now enforced.** New `remoteConfigGate.ts` reads the Remote Config template via the Admin SDK (5-minute cache, fails open on a Remote Config outage) and gates only the AI fallback path — the two zero-AI paths (canned library, emergency-number lookup) stay up even when the AI fallback is switched off centrally. This was a deliberate design choice made during implementation, not specified verbatim by Stage 2: the parameter is named `agent_enabled` (the AI agent specifically), and gating the entire callable including the safety-relevant emergency-lookup path seemed like the wrong scope for what should be a cost/behavior kill switch, not a full outage switch.
- **Admin-editable system prompt ported**, reimplemented as a Firestore override (`askAlrtConfig/systemPrompt`, field `text`) using the exact seed-plus-Firestore-override pattern the answer library already used (`entriesLoader.ts`) — no new cross-service dependency, unlike the deleted native port's Postgres-backed admin console version.
- **Structured alert citations ported.** `askAlrt.ts` now accepts a structured `nearbyAlerts` list (id/title/category/severity/source) instead of only a free-text blob, asks the model to end its answer with `USED_ALERT_IDS: id1,id2` when it relies on specific alerts, and validates every returned id against what was actually sent that turn — an id the model invents is dropped, never trusted. The legacy free-text `context` field is still accepted as a fallback for compatibility. The frontend now narrows the citation chips it displays to only the alerts the backend actually cited, instead of showing every alert that happened to be sent as context regardless of relevance.
- **`backendV2`'s native Ask ALRT port removed** from this repo's `backend/` (confirmed orphaned — zero real callers — by §13's call-chain trace): `askalrt.service.ts`, `askalrt.controller.ts`, `askalrt.route.ts`, `askalrt.validator.ts`, the `/api/ask` route mount, and the boot-time `ensureAskAlrtPrompt()` seed call. The general `AIPrompt` seeding used for other (non-Ask-ALRT) AI prompts was left untouched — only the Ask-ALRT-specific seed call was removed.
- **`backendV2`'s Firebase-token bridge left untouched** (`firebase_token.controller.ts`, `POST /api/user/firebase-token`) — this is required plumbing for the canonical implementation (the app authenticates against this backend, not Firebase, natively), not a duplicate.

13 new unit tests were added (`remoteConfigGate.test.ts`, `promptOverride.test.ts`, `citations.test.ts`) — all pure-logic, no Firestore/Remote Config mocking needed, matching the existing test style in `askalrt/functions/test/`.

### 17.5 Tests run

| Component | Command | Result |
|---|---|---|
| `askalrt/functions` | `npm install`, `npm run build` (`tsc`) | Clean, zero errors |
| `askalrt/functions` | `npm test` (`jest`) | **31/31 passing** (18 pre-existing + 13 new) |
| `backend` | `yarn install --frozen-lockfile`, `npx prisma generate` | Clean |
| `backend` | `npx tsc --noEmit` | **Clean except one error**, present before any change in this phase and after every subsequent change: `Cannot find module '../../serviceAccountKey.json'` — a real, gitignored deploy secret (Firebase Admin credentials) never provisioned in this environment. This is the exact "accepted baseline" error documented by the backend's own `backend/CLAUDE.md` ("`npx tsc --noEmit` must be clean before every push, except the pre-existing serviceAccountKey.json import error"). Zero *new* errors were introduced by any commit in this phase — re-run after the baseline import, after the Ask ALRT file removal, after the saved-locations edit, and after the journey-sharing edit, each time confirming only this one pre-existing error. |
| `frontend` | — | **Not run.** No `flutter` binary exists in this execution environment (`which flutter` → not found). All Dart/Flutter edits in this phase (desugar version bump, `.gitignore` line, Ask ALRT provider/message changes, saved-location constants, journey duration arrays) were reviewed by careful manual inspection — reading the full modified files, checking type/null-safety consistency against surrounding code, and confirming no leftover references to removed variables — but **could not be compiled, analyzed, or test-run**. This is a real gap, not a formality; flag it explicitly to whoever picks this up next. |

### 17.6 Verification pass: nothing on the "do not lose" list was accidentally dropped

Spot-checked directly against the imported tree after all edits (not assumed from the subtree import alone):

- **Map**: Ask ALRT, navigation/route-planning (`lib/features/map/**/navigation/`, `navigation_provider.dart`), voice search (`speech_to_text` dependency confirmed in `pubspec.yaml`), list view (`map_hazards_list.dart`), severity/category filtering (`hazard_severity_filter_model.dart`), saved locations (`hazard_search_subscribed_locations_list*.dart`) — all present.
- **Family**: family groups, daily check-ins (`family_check_in_roll_call_screen.dart`), location snapshots (`family_location_service.dart`, `family_location_request_sheet.dart`), journey sharing, SOS (list-edit/lists/receiver/resolved/main screens), Child Mode (`child_mode_provider.dart`, `child_mode_screen.dart`) — all present. Backend counterparts (`family.service.ts`, `family_alert.service.ts` (SOS), `family_journey.service.ts`) — all present.
- **Child Mode / no email requirement**: confirmed by reading `child_mode_screen.dart` in full — zero references to email anywhere in the screen; Child Mode is a restriction toggle on the existing account, not a separate child-account signup flow, so "child may not have an email address" is satisfied by there being no child-specific account creation path at all, not by a validation rule.
- **Authentication**: Google, Apple, Email/password confirmed present and untouched in `backend/src/routes/auth.route.ts`; Microsoft OAuth confirmed present (`backend/src/utils/microsoft_oauth_client.util.ts`) — still not re-enabled on the frontend button in this phase, since that was explicitly listed as a future item ("remains to be recovered/completed"), not part of this phase's scope.
- **Alerts / community vs. official distinction, privacy**: the community-privacy hotfix (suburb-precision rounding for community reports, full precision for official alerts) that Stage 1 found on this exact baseline branch is present and untouched.

Nothing in this list required a code change in this phase — the subtree import carries all of it forward by construction, and this pass exists to confirm that claim against the actual tree rather than assume it.

### 17.7 Failures and unresolved issues

- **No test failures.** Every test suite that could be run, passed. The frontend test suite (8 files on the imported baseline) was not re-run in this phase for the same reason nothing else Flutter-side could be: no `flutter` binary in this environment. It was not modified by any change in this phase, so it should still pass, but this is an assumption, not a verified result — recommend running `flutter test` and `flutter analyze` for real before trusting this baseline further.
- **`backend/package-lock.json` is stale** (still resolves `effect@3.16.12`) but unused by the real build (§17.2) — a hygiene item for a future pass, not fixed here to avoid unrequested scope.
- **`npm audit` on `askalrt/functions`** reports 10 vulnerabilities (8 moderate, 2 high) in transitive dependencies, discovered incidentally during `npm install`. Not investigated or fixed — outside the explicit list of Stage-2-verified fixes this phase was scoped to, and inventing a fix here would violate the "do not guess" instruction. Flagged for a dedicated look in a future security pass.
- **`frontendV2`/`widget`'s misleading GitHub default branch** (Stage 1 §3.1) was not addressed — it's a GitHub repo-settings change on the *original* `frontendV2` repo, which this phase was explicitly not permitted to touch. It only matters if someone clones `frontendV2` directly instead of using this repo's now-established baseline.
- **The two independently-built iOS TestFlight CI pipelines** (frontendV2's vs. V2-Claude's) were not compared or reconciled — no CI/deployment work was in scope for this phase.

### 17.8 Remaining Google Maps decision (explicitly not made)

Per instruction, this phase left the Maps implementation exactly as imported: build-time key injection unchanged, no backend proxy re-introduced, no keys hardcoded, no new architecture decision made. The client still calls Google's Geocoding/Places/Directions/Routes APIs directly with a build-time-injected key (confirmed present and unchanged in the imported `frontend/` tree). This remains the single open architectural question flagged since Stage 1: a full backend-proxy fix was built once and deliberately reverted, and the underlying tension (client reliability/simplicity vs. server-side key rotation) was never actually resolved, only backed away from. The deleted rotation runbook remains recoverable via `git show 4662b7c:docs/google-maps-key-rotation.md` against `ALRT-dev/V2-Claude` if the proxy approach is revisited. **No action was taken on this in Stage 3, as instructed.**

### 17.9 Recommended next phase

1. **Get real Flutter tooling on this codebase** (a Flutter/Gradle/Xcode-capable environment) and run `flutter analyze` + `flutter test` for real against every change in this phase — the single biggest verification gap left open here.
2. **Make the Google Maps decision** (§17.8) — the one deferred architectural item from this phase's own instructions.
3. **Re-enable the Microsoft OAuth frontend button** now that the backend route is confirmed present in this baseline — a small, well-scoped follow-up explicitly deferred from this phase.
4. **Scope and build the Admin Portal** (§15/§16 step 6) — still net-new work, still not started.
5. **Merge in `claude/alrt-data-export-tzq4ex`'s unmerged backend work** (CSV/GeoJSON export, Intel Centre sources spec) — named in the original backend-baseline recommendation (§10.B) but deliberately left out of this phase's explicit small-change scope; worth a dedicated pass now that the baseline is otherwise settled.
6. **Real-device QA** (§16 step 7) — home-screen widgets have still never been confirmed to actually compile/run on real Android/iOS hardware; the two untested SOS product rules and the location-snapshot consent UX still need real-device verification.
7. Only after 1-6: proceed to deployment staging (§16 step 8), unchanged from the prior recommendation.

---

## 18. Stage 4 — Audit and complete: Family, check-ins, Mark Safe, snapshots, journeys, SOS, Child Mode (executed)

**Scope of this phase, as instructed:** audit and *complete* existing functionality — not rebuild it — across eleven feature areas: Family lifecycle, daily check-ins, Mark Yourself Safe, location snapshots, journey sharing, SOS, SOS live location, Child Mode, UI/UX consistency, privacy/safety, and testing. Explicitly **not** attempted: Google Maps architecture, the Admin Portal, broad alert-engine changes, or deployment. No original repo was touched — every change below is local to `ALRT-V1-Release-Candidate`, on branch `claude/alrt-v1-rc-audit-a3gmai`.

**Method:** five parallel read-only audit passes (Family/check-ins/Mark Safe; location snapshots; journey sharing; SOS/SOS live location; Child Mode/UI-UX/privacy-safety), each tracing frontend provider → repository → REST client → backend route → controller → service → Prisma schema for its area, and each checked against the specific rules in this phase's own instructions and the locked `frontend/CLAUDE.md`/`backend/CLAUDE.md` product rules. Every finding was triaged into IMPLEMENT (well-scoped, in-area) or FLAG (out of scope, needs new architecture, or needs real-device verification) before any code was written. Implementation then proceeded in four small, area-scoped commits.

### 18.1 Commit-by-commit record

| # | Commit | What | Area |
|---|---|---|---|
| 1 | `bab6e187ca28069392d192bda55bd4613ed9bd42` | Push notifications for leave/remove-member; cancel a sent check-in request (backend service/controller/route + frontend provider/repository/service/REST client/UI); fixed a wrong `.circleId`→`.id` field reference; added a missing `familyScheduledCheckInPrompt` push-type case; Mark Safe now fans out to every circle only when it's a proactive check-in with no specific pending request | Family / check-ins / Mark Safe |
| 2 | `9e7f408ded0bd7459668826089e5fca9d4f439bb` | Bulk location-snapshot request to selected/whole-group members ("Ask everyone"); cancel a sent location request; expired-but-still-`pending` requests now get flipped to `expired` by the existing purge job; fixed a client-side pin-staleness bug (`hasLiveLocation` didn't check expiry) | Location snapshots |
| 3 | `9ff02986e9b0ef1bc5fe299a42e4cb82e5e383d6` | New targeted push notification to the specific recipients a journey was shared with (whole-circle socket refresh kept alongside it, since that payload carries no journey detail) | Journey sharing |
| 4 | `f475115ee30f1da538253f53d4be4a7ce9018c87` | SOS live-location choice: new `isLive` field (schema + migration + validator + service, required not optional) so the sender must explicitly choose whether live sharing runs; frontend toggle on the SOS screen; two-tier Stop SOS confirmation (a second, separate confirmation specifically about stopping live location, only shown when live is actually active); banner/header text corrected to not claim live sharing when it isn't running | SOS / SOS live location |

Group 5 (Child Mode) produced **no commit** — the audit concluded the existing architecture already satisfies the requirement without a code change (§18.6). Group 6 (this report update) is the closing documentation commit.

### 18.2 What the audits found already complete (no change made)

- **Family lifecycle**: create/invite/accept/membership/settings/map/notifications, the 8-seat cap (`MAX_SEATS_TOTAL`), and the 4-owned-circles cap (`MAX_OWNED_CIRCLES`) were all already correctly enforced **in the backend service layer**, not just the UI — `family.service.ts` computes seat usage server-side before allowing a join/invite-accept, so a modified or bypassed client cannot exceed either cap. Invited members already never see an ALRT+ paywall or need their own purchase (confirmed both in `backend/CLAUDE.md`'s own locked rule and in the actual join-flow code) — the audit found no unrestricted-privilege leak.
- **Daily check-ins**: scheduled-time creation, expected-response tracking, sent/received/waiting state, and the no-response/cancelled/schedule-change transitions were all already implemented and already scoped to a location/time snapshot only, never continuous tracking. One doc/code discrepancy was found and deliberately **not** "fixed": `backend/CLAUDE.md` says automatic scheduled check-ins should carry a location snapshot, but the actual code sends no location on the automatic path — changing that would mean auto-transmitting location without a per-instance tap, which directly violates this phase's own "location must never automatically transmit" rule. Flagged for product-owner attention rather than code-changed toward the riskier reading.
- **Mark Yourself Safe**: already textually, visually, and structurally distinct from SOS (own model, own button colour/copy, no emergency-service behavior) before this phase touched it; the only real gap was the "send to everyone in one tap" case not actually fanning out to every circle, closed in commit 1.
- **Location snapshots**: the core privacy rule — a request never auto-transmits, the recipient must physically approve/send — was already correctly enforced end to end (no code path exists that captures or sends a location without an explicit recipient action). 1-hour expiry, map display, and single-recipient/selected-member requesting were already present. The gaps were entirely on the "whole group at once" and "cancel a sent request" convenience paths (closed in commit 2), plus the stale-status/pin-staleness bugs (also closed in commit 2).
- **Journey sharing**: 30/60-minute start options, +60-minute extension, and the 240-minute (4-hour) hard maximum were already enforced **in the backend** (`ALLOWED_START_MINUTES`, `MAX_BLOCK_MINUTES`, `MAX_TOTAL_MINUTES`), not just the frontend — a modified client cannot exceed 4 hours or extend indefinitely. The 15-minute start option was already added in Stage 3 (§17.3) and reconfirmed present here. Manual stop, recipient visibility, map display, active-state location updates, and live sharing actually stopping when a journey ends were all already correct. The only gap was recipients not getting a targeted notification when a journey started (closed in commit 3).
- **SOS**: the ≥3-second hold-to-trigger (no accidental tap), recipients being pre-configured/user-chosen rather than ad hoc, and the complete absence of any emergency-service auto-dispatch path were all already correct. "Seen" was already automatic and "On my way" already deliberate and already did **not** auto-reveal the responder's own location — confirmed by reading the responder-status code path directly, not assumed. The two real gaps — the sender never being asked whether live location should run, and Stop SOS not carrying a second confirmation specifically about live location — were the two headline items closed in commit 4.
- **Privacy/safety cross-cutting checks**: no indefinite live tracking (4-hour cap enforced backend-side for both journeys and SOS live), no automatic emergency-service call anywhere in the codebase, no background location tracking triggered by a snapshot request or a check-in, and no silent location sharing (every transmission path requires an explicit user action) were all independently reconfirmed by the audits. The one live gap in this list — SOS being able to silently continue live sharing past what the sender actually intended, because the sender was never asked — is the same gap closed in commit 4.

### 18.3 What was changed — file-by-file

**Family / check-ins / Mark Safe (commit `bab6e18`):**
- `backend/src/services/family.service.ts` — `leaveCircle`/`removeMember` now pass `title`/`body`/`type` to `notifyCircle()` (previously socket-only, so the push branch never fired); new `cancelCheckInRequest(userId, requestId)` (requester-or-owner only, deletes the request, relies on the existing `onDelete: SetNull` relation).
- `backend/src/controllers/family.controller.ts`, `backend/src/routes/family.route.ts` — new `DELETE /check-in/request/:requestId`.
- `frontend/lib/features/family/providers/family_provider.dart` — `checkIn()` fans out across all circles only for a proactive, no-specific-request "I'm Safe" tap; answering a specific request stays scoped to that request's own circle; new `cancelCheckInRequest(String requestId)`. Fixed `.circleId` → the correct `.id` field on `FamilyCircle`.
- `frontend/lib/features/family/repositories/family_repository.dart`, `services/family_service.dart` — threaded optional `circleId` through `sendFamilyCheckIn`; added `cancelFamilyCheckInRequest`.
- `frontend/lib/api/endpoints.dart`, `rest_client.dart`, `rest_client.g.dart` — new `kUrlFamilyCheckInRequestCancel` + `@DELETE cancelFamilyCheckInRequest`, hand-written generated implementation mirroring the existing `deleteFamilyScheduledCheckIn` shape.
- `frontend/lib/features/family/views/screens/family_check_in_roll_call_screen.dart` — "Cancel" button, visible only to the request's own creator, using the existing `showConfirmationSheet` pattern.
- `frontend/lib/features/notification/enums/push_notification_types.dart`, `frontend/lib/features/home/views/screens/home_screen.dart` — added the `familyScheduledCheckInPrompt` case that already existed backend-side but was missing frontend-side.

**Location snapshots (commit `9e7f408`):**
- `backend/src/services/family_alert.service.ts` — `createLocationRequestsForMembers(userId, targetMemberIds[])` (fans out via `Promise.allSettled`, returns created/failed); `cancelLocationRequest(userId, requestId)` (requester-only, sets `status: "declined"` — no new enum value, no migration needed); `purgeExpiredFamilyLocationData()` now also flips stale `pending` requests to `expired`.
- `backend/src/validators/family.validator.ts` — `bulkFamilyLocationRequestSchema` (1-50 member ids).
- `backend/src/controllers/family.controller.ts`, `backend/src/routes/family.route.ts` — new `POST /location-requests` (bulk), `DELETE /location-requests/:requestId` (cancel).
- `frontend/lib/features/family/models/family_models.dart` — `hasLiveLocation` now also checks `locationExpiresAt`, fixing a within-session stale-pin bug.
- `frontend/lib/api/endpoints.dart`/`rest_client.dart`/`rest_client.g.dart`, `repositories/family_repository.dart`, `services/family_service.dart`, `providers/family_provider.dart` — full-stack plumbing for `createFamilyLocationRequestsBulk` and `cancelFamilyLocationRequest`; new provider methods `requestMembersLocation(memberIds)`, `cancelLocationRequest(requestId)`.
- `frontend/lib/features/family/views/screens/family_hub_screen.dart` — "Ask everyone" button next to the Members section header.

**Journey sharing (commit `9ff0298`):**
- `backend/src/models/push_notification_types.ts` — new `familyJourneyShared` type.
- `backend/src/services/family_journey.service.ts` — `startJourney` sends a new targeted push to the picked recipients (title/body vary by live/snap-points), alongside the pre-existing whole-circle socket refresh (kept, deliberately — its payload carries no journey detail, so broadcasting it is not a privacy issue, and removing it risked breaking other UI that depends on the generic refresh signal).
- `frontend/lib/features/notification/enums/push_notification_types.dart`, `home_screen.dart` — matching `familyJourneyShared` case.

**SOS / SOS live location (commit `f475115`):**
- `backend/prisma/schema.prisma` + new migration `20260808000000_sos_live_location_choice/migration.sql` — `FamilySosEvent.isLive Boolean @default(true)`. `npx prisma generate` re-run.
- `backend/src/validators/family.validator.ts` — `triggerFamilySosSchema.isLive` is **required**, not optional, so a sender must explicitly choose every time.
- `backend/src/services/family.service.ts` — `triggerSos` takes and persists `isLive`.
- `frontend/lib/features/family/models/family_models.dart`/`.g.dart`/`.freezed.dart` — `FamilySosEvent.isLive` (defaults `true` for backward JSON compatibility with any in-flight event predating this field); the `.freezed.dart` edit was hand-mirrored field-for-field against `FamilyJourney.isLive`'s already-proven generated pattern, not invented.
- `frontend/lib/features/family/views/screens/family_sos_screen.dart` — new live-location `Switch` (default on) on the SOS screen; pre/post-send copy branches on the choice; `_fireSos()` passes `isLive`.
- `frontend/lib/features/family/providers/family_provider.dart`, `repositories/family_repository.dart`, `services/family_service.dart`, `rest_client.dart`/`.g.dart` — `isLive` threaded through; `_startSosLiveShare()` now only runs `if (isLive)`.
- `frontend/lib/features/family/views/screens/family_sos_receiver_screen.dart` — Stop SOS is now two-tier: tier 1 always asks "Stop your SOS?"; if confirmed **and** `sos.isLive`, a second, separate confirmation asks specifically "Also stop sharing your live location?" before anything is actually resolved. Header/live-map text corrected to reflect `sos.isLive` rather than assuming live is always on.
- `frontend/lib/features/family/views/screens/family_hub_screen.dart` — the persistent SOS banner ("Your SOS is live/active") corrected to match `sos.isLive` instead of always saying "live".

### 18.4 Child Mode — audited, no change made

The audit read `child_mode_screen.dart` and its provider in full. Conclusion: the existing architecture already satisfies what this phase asks for, without a new backend or a new account type:

- Child Mode is a **restriction toggle on the parent's own account/device**, not a separate child account — there is no account-creation path for a child at all, so "child may not have an email address" is satisfied structurally (there is nothing to enter an email into), not by a validation rule that could be bypassed.
- The parent controls the child's experience directly (what's restricted, PIN-gated exit) rather than the child receiving the unrestricted adult app.
- Per Stage 2's own ruling (§15), a missing dedicated Child Mode **backend** (separate child identities, parent-child linkage as a first-class backend concept) was explicitly established as **not a V1 blocker**. Building that now would mean new backend architecture beyond "complete existing functionality," which this phase's own instructions rule out.

No code was changed for Child Mode in this phase. This is a verified conclusion, not a skipped item.

### 18.5 UI/UX consistency — audited, no change made

Mark Safe, Snapshot, Journey Sharing, and SOS were each independently confirmed — across all five audits — to already use distinct colours, copy, button shapes, and confirmation flows: Mark Safe (green "I'm Safe" button, its own `FamilyCheckIn` model), Snapshot (its own consent-sheet-driven flow), Journey Sharing (its own screen and duration-selection sheet), SOS (red/white hold-to-trigger button, its own screens and push types). None of the four could plausibly be mistaken for another. No redesign was performed or needed; this phase's own instruction not to redesign unrelated screens was honored by making no UI change beyond what §18.3's specific gaps required.

### 18.6 Privacy/safety — final synthesis

All items in this phase's privacy/safety checklist were verified, most already correct before this phase and the remainder closed by commit `f475115`:

| Check | Status |
|---|---|
| No indefinite live tracking | Already enforced backend-side (4-hour caps on both journeys and SOS live) |
| No automatic location transmission | Already enforced (every transmission requires an explicit recipient action) |
| No automatic emergency-service call | Already true — no such code path exists anywhere in the codebase |
| No responder-location exposure via "On my way" | Already true, confirmed by reading the responder-status code directly |
| No silent location sharing | Already true |
| No background tracking from snapshot requests | Already true |
| No background tracking from check-ins | Already true |
| Sender always chooses whether SOS live location runs | **Closed this phase** — was previously assumed-on with no choice |
| Stop SOS gives a clear, correctly-tiered confirmation | **Closed this phase** — was previously a single generic confirmation regardless of live state |

### 18.7 Tests run

| Component | Command | Result |
|---|---|---|
| `backend` | `npx tsc --noEmit` | Clean except the one documented pre-existing error (`serviceAccountKey.json`) — run after every single change in this phase, not just once at the end, and confirmed to introduce zero new errors at each step |
| `backend` | `npx prisma generate` (after the `isLive` migration) | Clean |
| `backend` | dedicated test suite | None exists (`npm test` → "Missing script: test") — unchanged from Stage 3, not a gap introduced here |
| `askalrt/functions` | `npm test` (`jest`) | **31/31 passing** — re-run for completeness even though nothing in Ask ALRT was touched this phase; confirms Stage 3's work is still intact |
| `frontend` | — | **Not run.** No `flutter` binary in this environment (`which flutter` → not found). Every Dart change in this phase — including the hand-edited `family_models.freezed.dart` — was verified only by manual inspection: reading the full modified files, and for generated code specifically, locating and mirroring an already-proven-correct pattern elsewhere in the same generated file (`FamilyJourney.isLive`) rather than freehand-writing Freezed/Retrofit boilerplate. This is a real, standing limitation, not a formality — none of the Dart changes in this phase have been compiled, analyzed, or test-run. |

No new automated tests were added in this phase — every change either extends existing, already-tested service functions with a straightforward new parameter (e.g. `isLive`, bulk fan-out over an existing single-item function) or is UI-only, and the environment cannot run `flutter test` to exercise it either way. This is a gap for the next phase to close once real Flutter tooling is available, not a decision that testing wasn't needed.

### 18.8 Remaining gaps and what needs real-device testing

- **Low-battery-aware SOS live-location throttling** was not implemented — it would need a new native (platform-channel) dependency that cannot be verified without real Flutter/Android/iOS tooling. Deferred to a real-device follow-up phase, not attempted here to avoid guessing at an unverifiable native integration.
- **No dedicated "my sent location requests" cancel screen.** The backend service/controller/route and the full frontend provider/repository/service/REST-client plumbing for cancelling a sent location request are built and ready (`cancelLocationRequest`), but there was no existing UI surface to hang a cancel button off for a *sent* request specifically (as opposed to the check-in cancel button, which had an obvious existing home in `family_check_in_roll_call_screen.dart`). Flagged as a small follow-up UI task, not built here since it would mean adding a new screen/section rather than completing an existing one.
- **Everything new in this phase needs real-device confirmation**, per the standing Flutter-tooling gap: the SOS live-location toggle, the two-tier Stop SOS confirmation flow, the "Ask everyone" bulk snapshot request button, the Mark Safe multi-circle fan-out, and — highest risk — the hand-edited `family_models.freezed.dart` (`FamilySosEvent.isLive`) must all be exercised on a real device or at minimum run through `flutter analyze`/`flutter test`/`dart run build_runner build` before this is trusted further.
- **Carried over from Stage 3, still unresolved**: home-screen widgets have never been confirmed to actually compile on real Android/iOS hardware (§17.9).
- **Doc/code discrepancy flagged, not changed**: `backend/CLAUDE.md` describes automatic scheduled check-ins as carrying a location snapshot; the actual code does not send one automatically. Left as-is per §18.2's reasoning — changing it would violate this phase's own no-auto-transmit privacy rule. Needs a product-owner decision on which is correct (the doc, or the code).

### 18.9 Stop condition honored

Per instruction, this phase stops here. No Google Maps architecture work, no Admin Portal, no broad alert-engine change, and no deployment were started or attempted in this phase or any prior one.

---

## 19. Stage 5 — Google Maps, routing, and transport (executed)

**Scope of this phase, as instructed:** audit the current Maps/routing implementation, resolve the outstanding Maps-key architecture question with the smallest practical correction (explicitly not a reflexive full backend proxy), preserve every existing map feature, and make transport-mode selection reflect what the routing provider actually returns rather than hardcoded options. Explicitly **not** attempted: the Admin Portal, broad alert-engine work, or deployment.

**Method:** three parallel read-only audits ran before any code changed — (1) the current frontend Maps/Places/Geocoding/Routes/navigation implementation, (2) the current backend's Maps-related code, and (3) the full historical rotation/revert story across `frontendV2`, `backendV2`, and `V2-Claude`, including the specific commits named in the task (`6874609`, `5b1eba2`, `ffbd610`) and the deleted key-rotation runbook. Their findings, cross-checked against each other, are what the decision in §19.2 is built on — nothing below is guessed.

### 19.1 Current Maps architecture, as found (before this phase)

- **Maps SDK** (`google_maps_flutter`): embedded key, build-time injected on both platforms — Android via a Gradle `manifestPlaceholders["MAPS_API_KEY"]` resolved from `GOOGLE_MAPS_API_KEY`, iOS via a gitignored `Maps.xcconfig`. No key was ever hardcoded in source on either platform.
- **Places (Autocomplete + Details)** and **Geocoding**: called **directly** from the Flutter client (`map_repository.dart`, `location_repository.dart`) against `maps.googleapis.com`, using the **same** embedded key as the Maps SDK — not a separate, more-restrictable web-service key.
- **Directions/Routes**: the **Routes API v2** (not the legacy Directions API), via `flutter_polyline_points`'s `getRouteBetweenCoordinatesV2`, also called directly with the embedded key. Driving, walking, bicycling, and transit are requested in parallel for every route plan; a custom field mask already asked for full turn-by-turn step data (`navigationInstruction`, `travelMode`, `transitDetails`) for every route including alternates.
- **Navigation**: real GPS-driven turn-by-turn navigation (not just a static preview) — a live HUD, position-stream-driven step advancement, and hazard-aware "take alternate route" prompts. No voice/TTS guidance (visual only); voice search (`speech_to_text`) feeds Places search, not navigation.
- **A backend Maps proxy already existed and was already live**, but had **no caller**: `backend/src/routes/maps.route.ts` mounted `GET /api/maps/geocode`, `/places/autocomplete`, `/places/details`, all `requireAuth`, forwarding to Google with a server-side key (`maps_proxy.service.ts`, correctly stripping any client-supplied `key` param before injecting its own). Nothing in the frontend called it.
- **Backend also runs its own, unrelated, internal geocoding** (`google_map.service.ts`, via `@googlemaps/google-maps-services-js`) for hazard-ingestion address enrichment and family-location suburb relabeling — not reachable from the client, not part of this decision.

### 19.2 How the current state came to be (the historical audit)

- `6874609` (PR #8, `frontendv2`/`backendv2`, Jun 30) built exactly the split-key architecture Google itself recommends: build-time key injection for the embedded SDK key (`7290e2c`), plus a backend proxy for Geocoding/Places so the web-service key never ships in the binary (`4662b7c` frontend + `a475545` backend), with a 132-line rotation runbook (`docs/google-maps-key-rotation.md`) documenting exactly how to restrict each key type in Google Cloud Console — Android package name **and both** the upload-keystore and Play-App-Signing SHA-1 fingerprints; iOS bundle ID; a separate entry for the `.dev` build flavor; API-restrict the web-service key to Geocoding/Places (+Routes, once migrated — never done).
- Four days later, `5b1eba2` — pushed directly to `main`, **not** through the PR/session workflow every other commit in this story used, authored by a `wiz.io` address rather than the usual Claude co-author pattern — reverted **only the frontend half**: Geocoding/Places calls went back to hitting Google directly with the embedded key, and the runbook was deleted outright. Its commit message gives one line of reasoning ("removing the app's runtime dependency on the backend /api/maps proxy") and nothing further; no linked PR or doc explains why.
- **The backend proxy was never reverted.** It has sat live, authenticated, and unused on `main` since `a475545` — an orphaned but real piece of attack surface (any authenticated user could have hit it and burned the shared Google quota, even though the shipped app never called it).
- Directions/Routes was **never** migrated to the proxy in the first place, in either direction — the runbook itself listed this as known future work, not something the revert undid.
- `ffbd610` (Family Mode/Learning merge, Jul 8) is unrelated to the key story — it touches Maps rendering (screen-space marker clustering, family-avatar pins) but doesn't revisit the proxy question.
- The most complete Maps implementation found anywhere (`frontendv2`'s `claude/safety-alert-repo-audit-8exgvn`, the branch this repository's `frontend/` baseline was built from in Stage 3) already requests `transitDetails` in its field mask and models a per-step `travelMode`, but never parses the transit response — this is exactly the gap §19.5 closes.

### 19.3 Security assessment and the decision

**Is a single embedded key, used directly by the client for Places/Geocoding/Routes, safe enough for V1? No — not as it stood, and not simply because it's "restricted."** The reasoning, worked through rather than assumed:

- What actually protects an embedded mobile key is Google Cloud Console **application restriction** (Android package + SHA-1, or iOS bundle ID), not secrecy — a key shipped in an APK/IPA is always extractable.
- Application restriction on Android/iOS **does not automatically apply** to a raw REST call the way it does to a native Maps SDK call. For Geocoding/Places/Routes called via plain HTTP (as this app calls them — `dio` for Places/Geocoding, `flutter_polyline_points` for Routes), Google requires the app to **manually send** `X-Android-Package`/`X-Android-Cert` or `X-Ios-Bundle-Identifier` headers on every such request for the restriction to be honored. **This app's REST calls sent none of these headers** (confirmed by direct code inspection, not assumed). That means either the key was left application-**unrestricted** (so anything extracted from the binary could call Places/Geocoding/Routes on ALRT's Google Cloud billing account without limit beyond whatever API-restriction and quota exist) — or, if restriction had been turned on regardless, Places/Geocoding/Routes would already be broken for every user, which the audits' evidence (these features actively work) says is not the case. Either reading means the *practical* security posture was weaker than "restricted key" implies.
- A backend proxy for Geocoding/Places **already existed, authenticated, and tested** — re-pointing the frontend to it is not "recreating a proxy," it's finishing a migration that was already built and then abandoned by an undocumented revert. This is the **smallest** correction available for those three calls, not the largest.
- Directions/Routes genuinely can't be proxied through the existing `flutter_polyline_points` package without replacing it — that's real new work, out of proportion to what "smallest practical correction" asks for. Instead: the package's `RoutesApiRequest` (confirmed via its own API docs) accepts custom `headers`, so the app-restriction headers Google requires *can* now be sent, making Android/iOS app restriction on this key a real, working option going forward — it just wasn't wired up before.

**Decision:** Geocoding and Places (Autocomplete + Details) now go through the existing backend proxy — the key for those calls never ships in the binary at all, closing the gap outright rather than just narrowing it. The Maps SDK and Routes API keep the embedded key (Directions/Routes cannot practically move server-side this phase), but `getRoute()` now sends the app-restriction headers Google requires, via new optional `.env` values that default to blank (zero behavior change until configured). This is documented as the locked architecture in both `frontend/CLAUDE.md` and `backend/CLAUDE.md` so it isn't silently re-reverted again.

### 19.4 Exact changes made

**Commit `a2a2e20a09f96d3e9249ab9254adcf239f75dc4c`** — Maps architecture/security correction:

| File | Change |
|---|---|
| `frontend/lib/features/map/repositories/map_repository.dart` | `getPlaces`, `getPlaceDetails`, `getAddressFromCoordinates` now call `kUrlMapsPlacesAutocomplete`/`kUrlMapsPlaceDetails`/`kUrlMapsGeocode` on the app's own authenticated backend client (relative path, existing `_dio` instance, existing `AuthInterceptor`) instead of `maps.googleapis.com` with `Env.googleMapsApiKey`. `getRoute` gained a `headers:` argument built by new `_appRestrictionHeaders()`, returning `null` (no headers, unchanged behavior) unless the new `.env` values are set. |
| `frontend/lib/features/map/repositories/location_repository.dart` | The same three-call migration in this near-duplicate implementation. |
| `frontend/lib/api/endpoints.dart` | New `kUrlMaps`, `kUrlMapsGeocode`, `kUrlMapsPlacesAutocomplete`, `kUrlMapsPlaceDetails` constants. |
| `frontend/lib/others/env.dart`, `frontend/.env.default` | New optional `GOOGLE_MAPS_ANDROID_PACKAGE_NAME`, `GOOGLE_MAPS_ANDROID_CERT_SHA1`, `GOOGLE_MAPS_IOS_BUNDLE_ID` — blank by default, documented as only needed once Cloud Console restriction is configured to match. |
| `backend/src/utils/config.ts` | New `rateLimit.mapsProxyWindowMs`/`mapsProxyMax` (env `MAPS_PROXY_RATE_LIMIT_WINDOW_MS`/`MAPS_PROXY_RATE_LIMIT_MAX`, default 60 req/60s per user). |
| `backend/src/middlewares/api_rate_limit.middleware.ts` | New `mapsProxyUserLimiter`, mirroring the existing `hazardReadUserLimiter` per-user pattern — the proxy previously had no rate limit beyond the generic 600-req/15-min IP bucket; now that it's live traffic rather than orphaned code, it needs one of its own. |
| `backend/src/routes/maps.route.ts` | Applies `mapsProxyUserLimiter` after `requireAuth` on all three routes. |
| `backend/.env.default` | Documents the two new rate-limit env vars. |
| `backend/docs/CONNECTIONS.md` | Corrected the stale "Used for" description, which described the proxy as actively used when it had not been since the Stage-1-era revert; now notes it's confirmed live again as of this phase. |

**Commit `407e5fb5eb363657e2b0ae2b98f5015d1b43b0d2`** — transit data model and UI:

| File | Change |
|---|---|
| `frontend/lib/features/map/models/route_step_model.dart` | New `TransitDetails`, `TransitLineInfo`, `TransitVehicleInfo`, `TransitStopInfo` models and a `TransitVehicleType` enum, parsed field-for-field against the verified `google.maps.routing.v2` proto schema (`RouteLegStepTransitDetails`/`TransitLine`/`TransitVehicle`/`TransitStop`) — not guessed. `RouteStep` gained a `transitDetails` field and a fallback instruction ("Take `<line>` towards `<headsign>`") for the (common) case where Google omits `navigationInstruction` on a transit step. |
| `frontend/lib/features/map/utils/transit_icons.dart` (new) | Shared vehicle-type → Material icon mapping, used by both surfaces below so they agree with each other. |
| `frontend/lib/features/map/views/widgets/navigation/navigation_mode_overlay.dart` | The live turn-by-turn HUD's step icon is now vehicle-based (not a misleading straight-arrow maneuver icon) for a transit step, and the "continue for X km" line becomes "N stops to `<headsign>`" for transit. |
| `frontend/lib/features/map/views/widgets/navigation/navigation_route_info_cards_list_item.dart` | Route-selection cards for a transit route now show a collapsed walk/line/walk/line strip (colour-coded from Google's own line colour, when provided) so transfers are visible before the user commits to a route. Renders nothing extra for a driving/walking/cycling route — that card is visually unchanged. |

**Documentation** (uncommitted at the time of writing, committed alongside this report update): `frontend/CLAUDE.md` and `backend/CLAUDE.md` each gained a short "Google Maps architecture" / "Google Maps proxy" section recording the decision in §19.3 as locked, including an explicit instruction not to re-revert Geocoding/Places back to direct calls without a fresh product-owner decision.

### 19.5 Transport selection — what was and wasn't already there

- A transport-mode selector **already existed** (`route_planning.dart`, `NavigationTravelModesList`) and was **already** driven by which modes actually returned a usable route (`RoutePlan.travelModeRoutes`/`unavailableModes`), not a hardcoded static list — a mode with no coverage is shown greyed out with Google's own reason text rather than hidden or invented. This was preserved unchanged; it already satisfied the "don't hardcode options" instruction at the mode level.
- What was genuinely missing, and is what this phase built: **segment-level** detail once transit is selected. The field mask already asked Google for `transitDetails` on every step; nothing parsed it, so a transit route showed a generic train icon and no line, vehicle type, headsign, or stop count — exactly the gap flagged in §19.2's historical audit. §19.4's second commit closes it by parsing the real response and surfacing it in both the live overlay and the route-selection cards, with the walking/line/walking/line strip specifically to make transfers visible before the user commits.
- Nothing was invented: every line name, vehicle type, colour, headsign, and stop count comes from Google's own response for that specific route at that specific time. Where a transit line has no official colour (some agencies omit it), the badge falls back to a neutral colour rather than fabricating one.

### 19.6 Google Routes data — what the app receives vs. surfaces

Per the verified `google.maps.routing.v2` proto (`route.proto`, `transit.proto`), a transit step's `transitDetails` carries: `stopDetails` (departure/arrival stop name + location + time), `headsign`, `headway`, `transitLine` (name, short name, colour, text colour, and `vehicle` — a localized name + `TransitVehicleType` enum of 18 values), `stopCount`, and `tripShortText`. This phase parses and surfaces: both stops' names, both times, headsign, stop count, and the full line/vehicle detail. **Deliberately not surfaced**, because nothing in the app currently needs it: `localizedValues` (Google's own pre-formatted display strings — the app formats times itself), `headway`, `tripShortText`, transit agency phone/URI, and any remote icon URIs (the app uses local Material icons instead of fetching Google's SVGs, avoiding a new image-loading dependency). All of these remain available in the raw response if a future pass wants them — nothing was discarded, only left unparsed.

No additional Google APIs are required beyond what the app already calls — the Routes API v2 response already contains everything above; this was a parsing gap, not a data-availability gap.

### 19.7 Manual configuration required in Google Cloud Console (no keys included below)

None of this can be done from this repository or this environment — it requires access to the live Google Cloud project holding the Maps API key(s). Recommended order:

1. **Split the key** (if not already split): keep the existing key for the Maps SDK (Android + iOS) and Routes API; issue a **separate** key for the backend Geocoding/Places proxy, restricted by the backend's egress IP (or left unrestricted-by-IP if the deployment doesn't have a stable egress IP, but still API-restricted per step 2) — this is the key `GOOGLE_MAPS_API_KEY` in the **backend's** environment/Secrets Manager, never in the mobile app.
2. **API-restrict both keys** to only what they need: the client-embedded key to *Maps SDK for Android*, *Maps SDK for iOS*, and *Routes API*; the backend key to *Geocoding API* and *Places API* only.
3. **Application-restrict the client-embedded key**: Android — package `com.safetyalrt.alrt` (prod) **and** `com.safetyalrt.alrt.dev` (dev flavor) as separate entries, each with **both** the upload-keystore SHA-1 **and** the Play App Signing SHA-1 (restricting to only the upload SHA-1 breaks the app for every Play Store user — this exact gotcha was documented in the deleted rotation runbook and is worth re-documenting somewhere durable this time). iOS — bundle ID `com.safetyalrt.alrt` and `com.safetyalrt.alrt.dev`.
4. **Populate the new frontend `.env` values** (`GOOGLE_MAPS_ANDROID_PACKAGE_NAME`, `GOOGLE_MAPS_ANDROID_CERT_SHA1`, `GOOGLE_MAPS_IOS_BUNDLE_ID`) — via the same CI-secret mechanism already used for `GOOGLE_MAPS_API_KEY` — matching whichever flavor is being built, **before or at the same time as** turning on step 3's restriction (turning on restriction without these values breaks Routes; setting these values without restriction is a safe no-op).
5. **Confirm billing/quota alerts exist** on the project (not verified from this repository — no visibility into billing configuration). A per-user rate limit was added on the backend proxy (§19.4) as a partial mitigation, but it doesn't cap the embedded client key's own usage ceiling — that's a Cloud Console/billing-alert concern.
6. **Verify end-to-end on a real device** after 1-4: Places search, Geocoding (current-location address), and route planning (all four modes) must still work on both a Play Store-installed build and a dev-flavor build once restriction is live — this cannot be verified from this environment (§19.8).

### 19.8 Tests performed and unavailable

| Component | Command | Result |
|---|---|---|
| `backend` | `npx tsc --noEmit`, run after every backend change in this phase | Clean except the one documented pre-existing error (`serviceAccountKey.json`) |
| `askalrt/functions` | not touched this phase | Not re-run — nothing in Ask ALRT was changed |
| `frontend` | — | **Not run.** No `flutter` or `dart` binary in this environment (confirmed directly — `which flutter dart` finds neither). Every Dart change in this phase, including the new transit models, the shared icon helper, and both widget files, was verified only by manual inspection: reading the full modified files, cross-checking every parsed JSON field name against the verified `google.maps.routing.v2` proto source (not guessed), and confirming import/type consistency by hand. **None of it has been compiled, analyzed, or test-run.** |
| `frontend/test/route_transit_details_test.dart` | not run (same reason) | A new pure-logic test file was **written** (`TransitVehicleType.fromApi`, `RouteStep.fromJson` parsing a realistic transit-step JSON payload including line/vehicle/stops/headsign, a non-transit step control case, and a malformed-`transitDetails` defensive case) but **could not be executed** in this environment. It is reasoned through by hand in the same commit's construction but has not been verified by an actual test run — flag this explicitly to whoever picks this up next, per the standing instruction not to claim Flutter tests passed when they cannot run here. |

### 19.9 Real-device test matrix required (per the task's own list, not yet performed)

None of the following have been performed — they require a real Android device, a real iPhone, and/or the live Google Cloud configuration from §19.7:

1. Driving route — unchanged behavior, confirm no regression from the Places/Geocoding re-pointing.
2. Walking route.
3. Cycling route.
4. Public transport route where transit is available — confirm the new line/vehicle/headsign/stop-count UI (§19.4/§19.5) renders correctly and matches what's actually running.
5. A transit route with at least one transfer — confirm the walk/line/walk/line strip on the route-selection card correctly shows each leg.
6. A route combining walking + public transport — confirm the walking-segment badge and the transit-segment badge both appear correctly ordered.
7. A route where public transport is unavailable for that origin/destination/time — confirm the existing "greyed out with a reason" behavior (§19.5, unchanged) still works after the Places/Geocoding re-pointing.
8. Alternate routes — confirm alternates still return correctly through the now-proxied Geocoding/Places calls feeding the origin/destination search.
9. Saved locations — confirm the saved-location flow (which uses Geocoding/Places) still works end to end through the proxy.
10. Location permission denied — confirm this is unaffected (no code in this phase touched permission handling).
11. API failure — confirm the app's existing error handling still surfaces a sensible error when the backend proxy itself fails or times out (10s timeout, unchanged from the pre-existing proxy code), not just when Google fails.
12. Offline/poor connection behavior — confirm the existing retry/offline handling (`dio_smart_retry`, already wired into the shared `_dio` instance) behaves the same now that Places/Geocoding go through one more network hop (app -> backend -> Google) than before.
13. **Specific to this phase's own change**: once §19.7's Cloud Console restriction is actually turned on, re-verify Places/Geocoding (now backend-proxied, unaffected by client-side restriction) **and** Routes (still client-direct, now restriction-dependent) both still work on a real Play Store build and a real dev-flavor build — this is the one scenario that could newly break something if steps 3-4 of §19.7 are done out of order or incompletely.

### 19.10 Remaining Maps issues (not addressed this phase, by design)

- **Directions/Routes cannot be moved server-side without replacing `flutter_polyline_points`** — out of scope for "smallest practical correction"; flagged, not attempted.
- **The internal backend geocoding used for hazard ingestion and family-location relabeling** (`google_map.service.ts`) was not touched — it's unrelated to the client-facing key question and was already server-side.
- **Billing/quota alerting** on the Google Cloud project could not be verified or configured from this repository (§19.7 step 5).
- **`headway`, `tripShortText`, and transit agency phone/URI** are available in Google's response but deliberately not surfaced (§19.6) — nothing in the app currently needs them; a future pass can add them without any new backend or API work since the data already flows through.
- Everything in §19.9's real-device matrix remains genuinely unverified.

### 19.11 Stop condition honored

Per instruction, this phase stops here. No Admin Portal, no broad alert-engine work, and no deployment were started or attempted in this phase or any prior one.

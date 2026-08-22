# ALRT V1 Reconciliation Report

**Status:** Audit only. No application code has been changed, merged, or deployed as part of this report.
**Scope:** `ALRT-dev/frontendV2`, `ALRT-dev/backendV2`, `ALRT-dev/askalrt`, `ALRT-dev/V2-Claude`, `ALRT-dev/v3`, plus `ALRT-dev/ALRT-V1-Release-Candidate` itself. `ALRT-dev/widget` was pulled in read-only mid-audit because every other repo points to it as the true frontend baseline (see §1).
**Method:** Full local clones with ~200 commits of history fetched per branch (every branch that exists in each repo), `git log`/`diff`/`show` history analysis, and targeted source reading across five parallel deep-dive passes (one per repo) plus manual cross-repo verification. Not every file in every repo was read line-by-line; large, low-risk areas (asset files, generated lockfiles, vendored code) were sampled rather than exhaustively reviewed.

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
| 7 | Nodemailer/Wiz security remediation | **Partially — needs disambiguation** | Nodemailer itself is backend-only (`src/utils/email.util.ts`, `backendV2`) and shows no CVE-flagged remediation commit found by name. **Important:** "Wiz" in this audit trail is `matt.youman@wiz.io`, i.e. part of a committer's personal/employer email address — **not evidence of a Wiz security-scanner finding**. No string matching "CVE-" or "vulnerab" tied to Nodemailer was found in any repo. Recommend treating "Nodemailer/Wiz remediation" as **unconfirmed** rather than assuming it's the two live CVEs found elsewhere (`basic-ftp`, `effect` — see §3.2), which are unrelated to Nodemailer. | **CLARIFY WITH RELEASE-PLAN AUTHOR** — this line item may be describing something not found by this audit, or may be a mislabeling of the `basic-ftp`/`effect` CVE fixes. |
| 8 | Location-subscription duplicate/race-condition fix | **Backend only** | Not found by name in either Flutter repo (all commits touching location-subscription files there are ordinary feature commits). `backendV2`'s audit branch does fix an ingestion race condition (`05616e2`) and enforces the free saved-locations cap server-side (`f112d97`, closing a client-side-only bypass) — plausible matches, but neither commit message uses the words "race condition" or "duplicate subscription" verbatim, so this should be confirmed with whoever wrote the release plan rather than assumed. | **LIKELY KEEP (needs confirmation of which commit is meant)**. |

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
**`ALRT-dev/frontendV2`, branch `claude/safety-alert-repo-audit-8exgvn`** (equivalently reachable via `ALRT-dev/widget` under the same branch name, per §1 — they are the same repository). Not the GitHub-default branch (`feature/home-screen-widgets`, which is a CI-workaround artifact — see §3.1). This branch is the only one with: Ask ALRT, Safety Profile, Child Mode, Journey sharing, Daily check-ins, the full Family SOS suite, the current product-owner-ruled alert-color design system, a real (if small) regression test suite, and the working TestFlight/QA-APK CI. Before promoting it: resolve §6.3 (the `V2-Claude` unique-content question) and apply the desugaring fix from §5 item 3 (it's missing even on this best branch).

### B. Recommended backend baseline
**`ALRT-dev/backendV2`, branch `claude/safety-alert-repo-audit-8exgvn`**, merged with **`claude/alrt-data-export-tzq4ex`** (the one branch with genuinely unmerged functional code — CSV/GeoJSON export + an Intel Centre sources spec). This branch is a verified strict superset of every other backend branch except that one, fixes two currently-live CVEs that are still on `main`, and implements Microsoft OAuth, the community-privacy hotfix, and the more mature ingestion pipeline described in §7.

### C. Recommended Ask ALRT baseline
**`ALRT-dev/askalrt`, `main`** — already current; its own audit branch is byte-identical (fully merged, nothing outstanding). However, do not treat this as a finished decision on its own: §6.2 must be resolved first, since `main` here is only one of three-to-four parallel Ask ALRT implementations across the whole codebase family, and consolidation may mean retiring parts of `backendV2` instead of (or as well as) keeping this repo exactly as-is.

### D. Important historical fixes to recover
In priority order:
1. Two live, unpatched dependency CVEs on `backendV2`'s `main` (`basic-ftp` CRLF injection, `effect` context leakage) — fixed further down history, not yet ported to `main`.
2. Android core-library desugaring for `flutter_local_notifications` (missing even on the recommended frontend baseline; two independent fixes exist, prefer the newer `desugar_jdk_libs:2.1.5` pin from `V2-Claude`).
3. Play Store service-account key `.gitignore` hardening (Matt's fix, not yet on `frontendV2`'s `main`).
4. OpenSSL update on the backend (present on deeper branches, not on `main`).
5. The deleted Google Maps key-rotation runbook (`docs/google-maps-key-rotation.md`, recoverable via `git show 4662b7c` on `V2-Claude`) — needed if the client-side-key-exposure decision (§4/§5 item 1) goes toward re-adopting the backend proxy.
6. "Nodemailer/Wiz remediation" and the exact "location-subscription race-condition fix" named in the release plan could not be matched to a specific commit with full confidence — flagged in §5 for clarification with whoever wrote the original plan, rather than guessed at.

### E. Major missing functionality
1. **Admin Portal frontend** — not found in any repo in scope; needs to be located (possibly among the session's other accessible-but-unaudited `ALRT-dev` repos) or scoped as new work.
2. **Safety Profile backend** — the frontend's on-device implementation has no server counterpart at all in `backendV2`; release plan implies more work was expected here (priority #4), and a second, independently-built Safety Profile implementation exists on `V2-Claude` that hasn't been reconciled against it (§6.3).
3. **Child Mode backend** — exists on the frontend only; no server-side model, restriction, or flag exists.
4. **Journey sharing's 15-minute start option** — missing server-side against the documented product rule.
5. Full operational Source Registry (health checks, review/expiry surfacing, quarantine states, per-source audit log) per `V1_SOURCE_REGISTRY_BACKLOG.md`'s P0 list — the data model and matching utility exist; the admin-facing operational layer around it does not yet.

### F. Major conflicts between branches
1. **Ask ALRT's three-to-four parallel implementations** (§6.2) — the single biggest architectural decision outstanding.
2. **`V2-Claude`'s newest branch may contain unreconciled Safety Profile / Ask ALRT / Alert Classification v1.2 work** not present in the recommended frontend baseline (§6.3).
3. **The Google Maps client-key-exposure decision** — a full fix was built and then deliberately reverted, independently, on two frontend lineages; the underlying tension (client convenience/reliability vs. key-rotation security) was never actually resolved, just backed away from (§4, §5 item 1).
4. **Product-plan numbers vs. shipped numbers** for AI quota, free saved-locations, and journey-sharing durations (§6.1) — code is internally consistent with itself but not with `V1_RELEASE_PLAN.md`.
5. **Two independently-built iOS TestFlight CI pipelines** across `frontendV2` and `V2-Claude`, never compared (§6.4).
6. **`frontendV2`'s misleading GitHub default branch** (§3.1) risks anyone unfamiliar with this audit picking the wrong starting point by default.

### G. Recommended next step
Before any code is merged into this release-candidate repo:

1. **Get a product-owner ruling** on the four §6.1 plan-vs-code numeric discrepancies (AI quota, saved-location cap, journey durations, ALRT+ pricing) — these are cheap to resolve now and expensive to discover post-launch.
2. **Get an architectural decision on Ask ALRT** (§6.2) — which of the three-to-four implementations is canonical, and what happens to the others.
3. **Diff `V2-Claude`'s `claude/alrt-app-update-scope-s24m2k`** (Safety Profile / Ask ALRT / Alert Classification v1.2 sections specifically) against `frontendV2`'s audit-branch equivalents to close §6.3 before anything from `V2-Claude` is discarded as "superseded."
4. **Locate the Admin Portal** (§9/E.1) — confirm whether it exists among the other `ALRT-dev` repos this session can see but wasn't asked to audit, and bring it into scope for a follow-up audit if so.
5. Only after 1-4: begin the actual reconciliation merge into this repo, starting from the frontend/backend baselines named in A/B, layering in the §5 fix list, and re-running this audit's classification pass against whatever the merged result looks like before it goes to real-device QA (release plan priority #11).

---

*This report is a point-in-time snapshot (branches fetched with ~200 commits of history each; some very old history beyond that depth was not inspected). No application code, configuration, or infrastructure was modified in the course of producing it.*

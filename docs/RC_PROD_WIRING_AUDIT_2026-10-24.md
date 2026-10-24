# ALRT RC production wiring audit — 24 Oct 2026

Scope: current RC repo code + local docs + live unauthenticated endpoint checks against `api.safetyalrt.com` and `api-test.safetyalrt.com`.

## Verified live now

- `GET /api/app/config` returns **200** on both prod and TEST.
- `POST /api/maps/routes` returns **401 auth missing** on both prod and TEST, which proves the route is deployed on both.
- `POST /api/revenuecat/webhook` returns **401 invalid webhook authorization** on both prod and TEST, which proves the route exists and auth is configured on both.
- `GET /api/ask-alrt/allowance` returns **401 auth missing** on both prod and TEST.
- `GET /api/access` returns **401 auth missing** on both prod and TEST.

That closes the older `/api/maps/routes` and `/api/app/config` TEST-behind-prod concern. Some local docs still say otherwise.

## Status by release area

| Area | Present in code | Working on TEST | Production-wired end to end | Exact blocker list |
|---|---|---|---|---|
| Auth persistence / login / logout | **Yes** — secure token storage, startup restore, silent refresh, session-expired handling (`frontend/lib/features/shared/repositories/secure_token_storage.dart`, `frontend/lib/api/interceptors/auth_interceptor.dart`, `frontend/lib/others/app_wrapper.dart`) | **Unknown** — no repo evidence of a current phone pass/fail for the logout complaint | **No** | 1. The phone complaint is not reproduced or logged anywhere in this repo. 2. `SecureTokenStorage.read()` treats keystore/keychain read failures as `null`, which becomes an apparent signed-out state. 3. Logout is still client-side token clearing only; there is no server-side revocation/session ledger for normal user auth (`backend/src/utils/jwt.util.ts`, `backend/src/controllers/auth.controller.ts`). 4. Priority is device repro + backend logs before any auth fix work. |
| Prod/TEST route parity (`/api/maps/routes`, `/api/app/config`) | **Yes** — frontend calls both and backend serves both (`frontend/lib/api/endpoints.dart`, `frontend/lib/features/map/repositories/map_repository.dart`, `backend/src/routes/maps.route.ts`, `backend/src/routes/app.route.ts`) | **Yes, verified live** | **Yes for route deployment** | Main blocker here is now **docs drift**, not missing code: `docs/TEST_TURN_ON_EVERYTHING.md`, `backend/CLAUDE.md`, and `docs/ENVIRONMENT_MAP.md` still describe older route state or old Google Routes assumptions. |
| RevenueCat / prod billing | **Yes** — RC SDK in app, backend webhook, access model, reconcile flow (`frontend/lib/features/subscription/services/revenuecat_service.dart`, `backend/src/controllers/revenuecat.controller.ts`, `backend/src/controllers/access.controller.ts`, `backend/src/services/entitlement.service.ts`) | **Partly** — routes exist on TEST, but local docs still say TEST billing is intentionally off (`backend/CLAUDE.md`, `TEST_BUILD_51_ACCEPTANCE.md`) | **No** | 1. `BILLING_ENABLED` is still the master launch gate in backend logic; until it is on, access checks default to paid. 2. Need one real sandbox purchase traced end to end: store -> RevenueCat webhook -> backend subscription state -> `/api/access`. 3. Dashboard config must exactly match code contracts: `individual` entitlement, `personal`/`groups` offerings, package ids `family`/`group20`/`group50`, correct `RC_APP_IDS`, `RC_PRODUCT_TIERS`, `REVENUECAT_SECRET_API_KEY`, `REVENUECAT_WEBHOOK_AUTH`. |
| Push notifications | **Yes** — token register/delete, test push endpoint, urgent channel, iOS interruption level, dedupe (`backend/src/controllers/notification.controller.ts`, `backend/src/routes/notification.route.ts`) | **Partly** — code and endpoints exist, but repo only has acceptance instructions, not current device proof | **No** | 1. No current phone-tested proof for delivery, sound, vibration, tap-open, or dedupe on RC. 2. iOS time-sensitive capability is still an Apple/Xcode setup item, not a repo-complete feature (`docs/IOS_WIDGET_AND_PUSH_SETUP.md`, `TEST_BUILD_51_ACCEPTANCE.md`). 3. Push remains operationally blocked until real-device QA is recorded for current builds. |
| Ask ALRT | **Yes** — current app path is backend `/api/ask-alrt`, not Firebase (`frontend/lib/features/ask_alrt/providers/ask_alrt_provider.dart`, `backend/src/routes/ask_alrt.route.ts`, `backend/src/services/ask_alrt.service.ts`) | **Partly** — live route exists on TEST, but no proof here of successful Bedrock-backed answers | **No** | 1. Major doc/runbook drift: `askalrt/README.md` still describes the Firebase service as live, while `askalrt/RETIRED.md`, `docs/ASK_ALRT_ANALYTICS_PROMPT.md`, backend code, and frontend code all treat backend Ask ALRT as current. 2. Need one authoritative deployment/runbook for the backend implementation. 3. Need TEST/prod verification of Bedrock access and admin-managed content changes on the current path. |
| Admin/config (`severityLabels`, app config) | **Yes** — admin page, configuration storage, public `/api/app/config`, app bootstrap consumption (`admin/src/pages/SeverityLabelsPage.tsx`, `backend/src/services/configuration.service.ts`, `frontend/lib/features/shared/providers/app_config_provider.dart`) | **Read path yes** — `/api/app/config` is live on TEST | **Partly** | 1. Read path is deployed, but there is no evidence here of a live admin save on TEST/prod followed by app cold-start consumption. 2. Lower priority than auth/billing/push, but still needs one end-to-end verification pass. |
| Backend deployment / rollout state | **Yes** — current RC endpoints are in repo and deployed on prod + TEST for the routes checked | **Partly** | **No** | 1. Several local docs are stale enough to mislead rollout work: `docs/ENVIRONMENT_MAP.md` still says prod RevenueCat webhook was 404; `TEST_TURN_ON_EVERYTHING.md` still points to an old branch and pre-proxy Routes guidance; `backend/CLAUDE.md` still says Routes is not proxied; `askalrt/README.md` still says Firebase Ask ALRT is live. 2. No current repo evidence of a fresh TEST rollout/migration rehearsal for today's head. 3. iOS widget target and time-sensitive push capability are still external setup tasks, not repo-complete (`docs/IOS_WIDGET_AND_PUSH_SETUP.md`). |

## Highest-priority remaining blockers

1. **Reproduce the phone login-persistence/logout issue on a current RC build.** Without that, auth work is guesswork.
2. **Finish real billing verification, not just route presence.** The code path exists; the store-to-backend trace is the missing proof.
3. **Finish real push verification on phones.** Especially iOS urgency/time-sensitive behaviour.
4. **Collapse the Ask ALRT runbook onto the backend implementation.** Right now the code and docs disagree on what is live.
5. **Clean up stale rollout docs before the next TEST/prod change.** The route parity issue that used to block release is now closed; the docs should stop sending people toward old fixes.

## Net assessment

- **Closed since earlier notes:** `/api/maps/routes` and `/api/app/config` are now deployed on both TEST and prod.
- **Still real release blockers:** auth persistence repro, real RevenueCat billing trace, phone-proven push, and Ask ALRT/documentation convergence.
- **Most important repo risk right now:** operational confusion from stale docs is starting to rival missing code as a release blocker.

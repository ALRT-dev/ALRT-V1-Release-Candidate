# 02 -- PROD Backend Surface Audit

Audit date: 2026-10-09
Scope: READ ONLY. No edits, deployments, or writes to any live environment.

This document maps the production backend surface, identifies what is new in the
release-candidate branch versus what is running in production, and lists what the
TEST environment needs from PROD infrastructure before a go-live.

---

## 1. What Is Running in Production Today

Source: `docs/LIVE_CONNECTIONS.md:1-97`, `backend/docs/CONNECTIONS.md:1-199`.

Production runs the **backendV2** repo (separate from this monorepo), last deployed
at commit `5ce3825` (July 2026). The release-candidate branch in this monorepo
(`origin/claude/compassionate-franklin-512so7`, commit `2895f82`) is significantly
ahead.

| Resource | Live value | Source |
|---|---|---|
| AWS account | `082258816984`, region `ap-southeast-2` | LIVE_CONNECTIONS.md:12 |
| EC2 instance | `i-0c7a10c5b1d74310d`, t3.medium, Ubuntu 24.04 | LIVE_CONNECTIONS.md:13 |
| Public IP | `15.135.57.148` (Elastic IP labelled "(Dev) Alrt") | LIVE_CONNECTIONS.md:13 |
| Domain | `https://api.safetyalrt.com` via Cloudflare DNS | LIVE_CONNECTIONS.md:14 |
| Database | RDS PostgreSQL `alrt-app-db-dev` (db.t3.micro) | LIVE_CONNECTIONS.md:15 |
| DB password | Secrets Manager `safetyalrt/db/postgres` | LIVE_CONNECTIONS.md:15 |
| S3 bucket | `alrt-app-bucket` | LIVE_CONNECTIONS.md:16 |
| Maps key | Secrets Manager `GOOGLE_MAPS_API_KEY` + `safety-alert-prod/api-token` | LIVE_CONNECTIONS.md:17 |
| n8n | EC2 `i-0f84456f93b803036` in same account | LIVE_CONNECTIONS.md:19 |
| Firebase | Project `alrt-a6539` (push only) | LIVE_CONNECTIONS.md:21 |
| Monitoring | Datadog + Wiz (Lambda functions, not app-facing) | LIVE_CONNECTIONS.md:20 |
| Docker | Blue/green on 127.0.0.1:3001/3002 -> 9000, loads `.env.prod` | LIVE_CONNECTIONS.md:13 |
| IAM role | `safety-alrt-prod-instance-role` | LIVE_CONNECTIONS.md:13 |
| Old admin | `https://admin.safetyalrt.com` (not built from this repo) | LIVE_CONNECTIONS.md:18 |

**RDS naming note**: The database is named `alrt-app-db-dev` but is the database
in the production account. LIVE_CONNECTIONS.md:15 says: "Confirm with Matt that
it holds the real users and alerts before any migration."

---

## 2. What the Release-Candidate Adds Over Production

The production backendV2 has 82 migrations. This branch has 116 -- a difference
of 34 migrations. The following sections break down what is new.

### 2.1 New Prisma Models (not in production backendV2)

These models exist only on the release-candidate branch. Every model below was
added by migrations dated 2026-09-01 or later.

| Model | Migration | Purpose | schema.prisma line |
|---|---|---|---|
| StoreSubscription | 20260928000000_v1_access_model | RevenueCat subscription records | 776 |
| SponsorshipIntent | 20260928000000_v1_access_model | Pre-checkout group sponsorship intent | 826 |
| RevenueCatWebhookEvent | 20260928000000_v1_access_model | Idempotent webhook event log | 849 |
| FamilyScheduledCheckIn | 20260904000000_family_check_in_request_targets | Automated daily check-in schedule | 1140 |
| FamilyPlaceEvent | (place notifications) | Arrive/leave events for family places | 1202 |
| FamilySosList | (SOS lists) | Named SOS recipient presets | 1220 |
| FamilySosResponse | (SOS) | Recipient "seen"/"on my way"/"called" | 1300 |
| FamilyJourney | (journeys) | Start/extend/stop journeys with recipients | 1487 |
| FamilyJourneyRecipient | (journeys) | Per-recipient journey link | 1519 |
| XpEvent | (XP system) | Gamification point events | 1420 |
| UserBadge | (XP system) | Earned badges | 1464 |
| HazardCorroboration | (voting rework) | Corroboration for community reports | 1443 |
| HazardFlag | (reporting) | User-flagged content records | 1551 |
| UserBlock | (blocking) | User-to-user blocks | 1571 |
| TrialRecord | 20261005000100_trial_record | Free trial hash ledger | 1592 |
| AskAlrtEntry | 20261006000000_ask_alrt_in_backend | Curated Ask ALRT knowledge entries | 1604 |
| AskAlrtConfig | 20261006000000_ask_alrt_in_backend | Ask ALRT feature config | 1616 |
| AskAlrtUsage | 20261006000000_ask_alrt_in_backend | Daily usage counter per user | 1624 |
| AskAlrtZone | 20261006000000_ask_alrt_in_backend | Geographic zone definitions | 1635 |

**Total**: 19 new models on top of the 35 that already exist in production (54 total).

### 2.2 New Route Groups (not in production backendV2)

| Route group | Endpoints | Key service file | Purpose |
|---|---|---|---|
| `/api/access` | 5 endpoints (GET /, POST /reconcile, /sponsorship-intents, /sponsorships/:id/bind, /groups/:circleId/individual-funding) | entitlement.service.ts (1426 lines) | V1 access model: personal plan + group sponsorship |
| `/api/revenuecat` | POST /webhook | entitlement.service.ts | RevenueCat subscription event handler |
| `/api/ask-alrt` | POST /, GET /allowance | ask_alrt.service.ts | Ask ALRT moved from Firebase into backend |
| `/api/xp` | GET /summary, /breakdown, /leaderboard, /badges | xp.service.ts | XP/badges gamification system |
| `/api/guides` | GET /topics, /for-category/:id, /:slugOrId, POST /:slugOrId/complete | guide.service.ts | Safety guides content |
| `/api/app` | GET /version-policy | app.route.ts:18 | Force-update min version check |
| `/api/public` | GET /hazards/:id, /share/alert/:id, /share/alert/:id/card.png, /a/:id | public.route.ts | Public alert sharing (no auth) |

### 2.3 New/Expanded Family Features (release-candidate only)

Source: `routes/family.route.ts` (265 lines), cross-referenced with backend_audit.md.

| Feature | Endpoints | Status in production |
|---|---|---|
| SOS lists (presets) | GET/POST/PUT/DELETE /sos-lists, GET /sos-recipients | Not in production |
| SOS extensions | POST /sos/:id/extend (1-hour increments) | Not in production |
| SOS location consent | PUT /sos/:id/location-consent | Not in production |
| SOS trail | GET /sos/:id/trail | Not in production |
| SOS preview | GET /sos/preview | Not in production |
| SOS history | GET /sos/history | Not in production |
| Journeys | POST /journeys, GET /journeys/me, /journeys/shared, /journeys/:id, POST /journeys/:id/extend, /journeys/:id/point, /journeys/:id/stop | Not in production |
| Scheduled check-ins | POST/GET/DELETE /scheduled-check-ins | Not in production |
| Family places + events | GET/POST/PUT/DELETE /places, PUT /places/:id/prefs | Not in production |
| Location requests | POST /members/:id/location-request, POST /location-requests, GET /location-requests/pending, POST /location-requests/:id/respond, DELETE /location-requests/:id | Not in production |
| Circle photo | PUT/DELETE /circle/photo | Not in production |
| Member photo | PUT /members/me/photo | Not in production |
| Circle transfer/takeover | GET /circle/transfer-candidates, POST /circle/transfer-ownership, POST /circle/take-over | Not in production |

### 2.4 New External Service Integrations

| Service | Production | Release-candidate | Files |
|---|---|---|---|
| AWS Bedrock | Not present | Default AI provider (Claude Haiku 4.5) | bedrock_client.util.ts, bedrock.service.ts (243 lines) |
| RevenueCat | Webhook pointed but 404ing | Full webhook + reconcile + intent system | entitlement.service.ts (1426 lines) |
| Ask ALRT (in-backend) | Runs as separate Firebase function | Native service with Bedrock chat | ask_alrt.service.ts, ask_alrt/ subdirectory |

### 2.5 New Admin Portal Features

Source: admin_and_prototype_audit.md, admin/README.md.

The release-candidate includes a complete new admin portal (`admin/` directory)
built in Vite + React + TypeScript. The production admin console at
`admin.safetyalrt.com` is an older, separate build.

| New admin capability | Endpoint | Status |
|---|---|---|
| Ask ALRT management | POST /admin/ask-alrt/ask, GET/PUT /admin/ask-alrt/config, CRUD /admin/ask-alrt/entries, CRUD /admin/ask-alrt/emergency-numbers | New -- not in old admin |
| AI prompt management | CRUD /admin/ai-prompts, /admin/ai-prompt-groups | New -- old admin had no prompt editing |
| Webhook key management | CRUD /admin/webhook-api-keys | New |
| Source/license management | CRUD /admin/hazard-sources, /admin/hazard-source-licenses | New |
| Audit log viewer | GET /admin/audit-log | New |
| Configuration management | CRUD /admin/configurations | New |

**Known V1 limitations** (admin/README.md:124-160): No emergency information
screen, no category icon upload, no AI prompt create/delete (read/update only),
no configuration `value` editing, no ALRT+/subscription data in the Users screen,
paging inconsistencies.

### 2.6 Migrations Not Yet Applied to Production

Source: `prisma/migrations/` directory listing. 34 migrations from the release-
candidate are not applied to production. The 14 from 2026-09-01 onward are:

| Migration | Description |
|---|---|
| 20260902000000_repair_hazard_geom_generated_columns | Fix hazard geometry generated columns |
| 20260904000000_family_check_in_request_targets | Targeted check-in request support |
| 20260905000000_family_host_transition | Family host/ownership transition |
| 20260925000000_operational_source_registry | Operational source registry |
| 20260928000000_v1_access_model | V1 access model (StoreSubscription, SponsorshipIntent) |
| 20260929000000_v1_subscription_changes | Subscription tier change support |
| 20260930000000_source_registry_review_fields | Source registry review fields |
| 20260930000000_v1_review_followup | V1 access model review follow-up |
| 20261003000000_sos_one_hour_extend | SOS 1-hour extension support |
| 20261005000000_terms_acceptance_record | Terms acceptance record |
| 20261005000100_trial_record | Free trial ledger (TrialRecord) |
| 20261006000000_ask_alrt_in_backend | Ask ALRT moved into backend |
| 20261006100000_sos_ending_soon_marker | SOS ending-soon reminder marker |
| 20261008000000_sos_history_survives_sender_leaving | SOS history persists on sender leaving |

The remaining 20 migrations (between production's 82 and these 14) were added
during earlier development stages on this branch and are already represented in
the current schema.

---

## 3. Environment Variables: PROD vs Release-Candidate

### 3.1 Variables Already in Production (carry forward)

These exist in the production `.env.prod` and must be preserved during upgrade.
Source: LIVE_CONNECTIONS.md:30-41, backend/docs/CONNECTIONS.md.

| Variable group | Carry-forward action |
|---|---|
| DATABASE_URL | Keep same value (same RDS instance) |
| JWT_ACCESS_SECRET, JWT_REFRESH_SECRET | **Keep same values** or all users are signed out |
| ADMIN_JWT_ACCESS_SECRET, ADMIN_JWT_REFRESH_SECRET | Keep same values |
| GOOGLE_OAUTH_CLIENT_ID_WEB/IOS/ANDROID | Keep same values |
| APPLE_OAUTH_AUDIENCE | Keep same value |
| OPENAI_API_KEY | Keep same value (now fallback AI provider) |
| GOOGLE_MAPS_API_KEY | Keep (also delivered via Secrets Manager) |
| AWS_S3_REGION, AWS_S3_BUCKET_NAME | Keep same values |
| NSW_TRANSPORT_API_KEY | Keep same value |
| WAQI_API_TOKEN | Keep same value |
| SIGHTENGINE_API_USER/SECRET/WORKFLOW_ID | Keep same values |
| SMTP_HOST/PORT/USER/PASSWORD | Keep same values |
| EMAIL_FROM_ADDRESS, EMAIL_SUPPORT_ADDRESS | Keep same values |
| WEBHOOK_API_KEY | Keep same value (n8n uses this) |
| NODE_ENV | Keep as "prod" |

### 3.2 New Variables Required for Release-Candidate

Source: `src/utils/config.ts:1-307`, `src/services/entitlement.service.ts`.

| Variable | Required? | Purpose | Default | config.ts line |
|---|---|---|---|---|
| AWS_BEDROCK_REGION | Yes | Bedrock AI calls | -- | 162 |
| AI_PROVIDER | No | Switch bedrock/openai | "bedrock" | 177 |
| AWS_BEDROCK_ACCESS_KEY_ID | No | Explicit Bedrock creds | "" (IAM role fallback) | 163 |
| AWS_BEDROCK_SECRET_ACCESS_KEY | No | Explicit Bedrock creds | "" (IAM role fallback) | 164 |
| AWS_BEDROCK_FALLBACK_MODEL_ID | No | Default model | "global.anthropic.claude-haiku-4-5-20251001-v1:0" | 168-170 |
| BILLING_ENABLED | Decision | Master billing toggle | "false" (runtime, entitlement.service.ts:35) | -- |
| RC_PRODUCT_TIERS | When billing on | Product-to-tier JSON map | -- (runtime, entitlement.service.ts:68) | -- |
| RC_EXPECTED_ENVIRONMENT | When billing on | PRODUCTION or SANDBOX filter | -- (runtime, entitlement.service.ts:829) | -- |
| RC_APP_IDS | When billing on | Allowed RevenueCat app ids | -- (runtime, entitlement.service.ts:831) | -- |
| REVENUECAT_WEBHOOK_AUTH | When billing on | Webhook Authorization header | "" | 282 |
| REVENUECAT_SECRET_API_KEY | No | Server-side reconciliation | -- (runtime, entitlement.service.ts:1296) | -- |
| REVENUECAT_API_BASE | No | API base URL override | -- (runtime, entitlement.service.ts:1295) | -- |
| TRIAL_LEDGER_SECRET | No | Free trial hash | "" | 67 |
| TERMS_VERSION | No | Legal text tracking | "2026-08-01" | 69 |
| PRIVACY_VERSION | No | Legal text tracking | "2026-08-01" | 70 |
| COMMUNITY_GUIDELINES_VERSION | No | Guidelines tracking | "2026-08-01" | 71 |
| COMMUNITY_REPORTS_PER_HOUR | No | Rate limit | "3" | 72 |
| COMMUNITY_REPORTS_PER_DAY | No | Rate limit | "10" | 73 |
| COMMUNITY_DUPLICATE_RADIUS_M | No | Duplicate radius | "500" | 74 |
| COMMUNITY_REPORT_MEDIA_ENABLED | No | Photo/video toggle | "false" | 75-76 |
| MIN_APP_VERSION_IOS | No | Force-update gate | "" | 211 |
| MIN_APP_BUILD_IOS | No | Force-update gate | "" | 212 |
| APP_STORE_URL_IOS | No | Store link for update | "" | 213 |
| MIN_APP_VERSION_ANDROID | No | Force-update gate | "" | 216 |
| MIN_APP_BUILD_ANDROID | No | Force-update gate | "" | 217 |
| APP_STORE_URL_ANDROID | No | Store link for update | "" | 218 |
| CACHE_URL | No | ElastiCache/Valkey | "" | 228 |
| CACHE_TLS | No | Cache TLS toggle | "false" | 229 |
| PASSWORD_RESET_BASE_URL | No | Password reset link | "" | 291 |

---

## 4. What TEST Needs from PROD Infrastructure

The TEST environment runs on AWS account `488658242173`. Source:
`admin/.env.test:11` points to `https://api-test.safetyalrt.com`.

### 4.1 Already Required (should be in TEST already)

| Infrastructure | TEST equivalent | Notes |
|---|---|---|
| RDS PostgreSQL + PostGIS | Own TEST RDS instance | Never point TEST at PROD database (LIVE_CONNECTIONS.md:93) |
| S3 bucket | Own TEST bucket | Never share with PROD (LIVE_CONNECTIONS.md:93) |
| Firebase project | Same `alrt-a6539` project (FCM only) | Push tokens differ between builds |
| EC2 or equivalent | TEST backend host | Running at api-test.safetyalrt.com |
| Cloudflare DNS | `api-test.safetyalrt.com` A record | Already configured |
| Google OAuth client IDs | Same as PROD or test-specific | Same Google Cloud project |
| Apple Sign-In | Same audience | |
| OpenAI key | Same key or test key | Now fallback; Bedrock is default |
| Google Maps key | Test key recommended | Avoid burning PROD quota |
| SMTP | Same or test mailbox | |
| Sightengine | Same or test account | |

### 4.2 New Infrastructure for Release-Candidate Features

| Infrastructure | What TEST needs | PROD dependency? |
|---|---|---|
| AWS Bedrock access | IAM role with `bedrock:InvokeModel` on the TEST account, or explicit creds | No PROD dependency -- uses TEST account's own IAM |
| RevenueCat sandbox | RevenueCat sandbox webhook pointed at `api-test.safetyalrt.com/api/revenuecat/webhook` | No -- separate sandbox environment in RevenueCat |
| ElastiCache/Valkey | Optional; app runs without cache | No PROD dependency |
| CloudFront CDN | Optional; S3 direct works for TEST | No PROD dependency |

### 4.3 Secrets Manager Mapping

Production uses the Secrets Manager Agent sidecar (`src/utils/secrets.ts:1-27`).
The sidecar calls `http://localhost:2773` with a token file. For TEST, either:

1. Deploy the same sidecar pattern on the TEST EC2 with TEST account secrets, or
2. Put all values directly in `.env.test` on the TEST server (sidecar is a no-op
   when running locally or when the agent is unavailable).

Production secrets that need TEST equivalents:

| Secret name (PROD) | Purpose | TEST action |
|---|---|---|
| `safetyalrt/db/postgres` | DATABASE_URL | Create in TEST account with TEST DB URL |
| `GOOGLE_MAPS_API_KEY` | Maps proxy | Create in TEST account or use .env |
| `safety-alert/aws-credentials` | S3 keys | Create in TEST account or use IAM role |
| `safety-alert-prod/api-token` | Alt maps key ref | Create or omit (same as GOOGLE_MAPS_API_KEY) |

---

## 5. RevenueCat Status (PROD vs TEST)

Source: LIVE_CONNECTIONS.md:22, entitlement.service.ts:1-1426.

| Aspect | Production | TEST/Release-candidate |
|---|---|---|
| Webhook URL | `https://api.safetyalrt.com/api/revenuecat/webhook` | `https://api-test.safetyalrt.com/api/revenuecat/webhook` |
| Last recorded delivery | Failed with 404 (24 Sep 2026) | Route exists in code; needs REVENUECAT_WEBHOOK_AUTH set |
| Why 404 in PROD | backendV2 does not have `/api/revenuecat/webhook` route | Release-candidate has it at revenuecat.route.ts:13 |
| BILLING_ENABLED | Not applicable (route doesn't exist) | Set to "false" -- all access checks pass |
| RC_PRODUCT_TIERS | Not applicable | Must be set before enabling billing |
| Product IDs | Must NOT use `alrt_dev_*` products on PROD | TEST uses `alrt_dev_*` products only |
| RC_EXPECTED_ENVIRONMENT | -- | Must be SANDBOX for TEST, PRODUCTION for PROD |

**Critical rule** (LIVE_CONNECTIONS.md:93-94): Never put `alrt_dev_*` products in
the live `RC_PRODUCT_TIERS`. Never set `RC_EXPECTED_ENVIRONMENT=SANDBOX` on live.

---

## 6. Scheduled Jobs: PROD Behavior vs TEST

Source: `src/services/scheduler.service.ts:1-103`, `src/utils/scheduled_jobs.util.ts:1-23`.

| Schedule | What it does | PROD (NODE_ENV=prod) | TEST (NODE_ENV=test) |
|---|---|---|---|
| Every 15 min | Sync hazards from 16 external sources | Always runs | Only if RUN_SCHEDULED_JOBS_IN_TEST=true |
| Daily 2 AM AEST | Process scheduled account deletions | Always runs | Only if toggled on |
| Every 5 min | Purge expired locations, end lapsed journeys, prune pings | Always runs | Only if toggled on |
| Every 10 min | Award XP for expired community reports | Always runs | Only if toggled on |
| Every 1 min | Fire due scheduled check-ins | Always runs | Only if toggled on |
| Every 1 min | End lapsed SOS events, remind SOS ending soon | Always runs | Only if toggled on |

**Gate logic** (scheduled_jobs.util.ts:16-23): `prod` always runs, `test` only
when `RUN_SCHEDULED_JOBS_IN_TEST=true`, `dev` and anything else never runs.

---

## 7. Known Issues and Conflicts

### 7.1 Flagged Invalid Model Name

Source: backend/docs/CONNECTIONS.md:70.

The OpenAI service references model name `gpt-5-nano` at `hazard.service.ts:650`
and `ai-prompt.service.ts:665+`. This model name is not found in OpenAI's current
model list. Since the default `AI_PROVIDER` is `bedrock` (not openai), this is
only hit if `AI_PROVIDER` is switched to `openai` and the admin-configured prompts
specify `gpt-5-nano`.

### 7.2 Conflicts Between Documentation and Code

Source: prototype traceability matrix rows 78-82 (admin_and_prototype_audit.md).

| ID | Conflict | What docs say | What code does |
|---|---|---|---|
| R08 | Community push timing | Proposal not approved | Prototype follows existing code behavior |
| SOS cap | SOS 4-hour cap | Docs say max 4 hours | Code has no cap (extend indefinitely in 1h increments) |
| SOS end | Who ends an SOS | Docs say sender or host | Code restricts to sender only |
| R03 | Ask ALRT counting | Library/emergency queries don't count toward daily limit | Code counts all queries |
| Group cap | Group capacity defaults | Schema default vs docs disagree | Needs reconciliation |

### 7.3 Backend Gaps Identified

Source: prototype traceability matrix rows 12, 75, 77, 83-85, 87.

| Gap | Description | Impact |
|---|---|---|
| Alert level minimum band | No `minimumBand` field in `UserPushNotificationSetting` | New onboarding "alert level" step cannot persist choice |
| Apple Watch | No watch target in repo | Prototype shows widget but no backend support |
| Keep-it-quiet level | No minimum band field | User cannot set "only notify me about X and above" |
| Scheduled check-in timezone | Hardcoded to `Australia/Brisbane` | All users get Brisbane-anchored times |
| Admin review push/XP | No push notification or XP award when admin accepts a community report | Reporter gets no feedback on acceptance |
| Daily digest | Not built | No daily summary notification |
| Google Routes key | `flutter_polyline_points` calls Google directly with key in client | Key exposure risk; proxy through `/api/maps` or remove |

---

## 8. Credential Safety Check

Source: Full codebase grep for committed secrets.

| Check | Result |
|---|---|
| `.env.prod` committed? | No -- gitignored |
| `serviceAccountKey.json` committed? | No -- gitignored, copied into Docker image at build time |
| API keys in source? | No hardcoded keys found; all loaded from env vars or Secrets Manager |
| Google Routes key exposure | Client-side: `flutter_polyline_points` uses a key from `.env` (compile-time). Not committed but compiled into app binary. Noted as backend gap #87 in traceability. |
| `.env.example` / `.env.default` | Contains placeholder names only, no real values |

---

## 9. Switch-On Order (from LIVE_CONNECTIONS.md)

The documented deployment order in `LIVE_CONNECTIONS.md:43-96` is:

1. **Back up** RDS snapshot + copy `.env.prod`
2. **Prepare settings file** using `fill-env-prod-from-aws.sh` and `check-env-prod.sh`
3. **Deploy backend** -- `prisma migrate deploy` applies all pending migrations
4. **Health check** -- `/api/test` answers, sign-in works, alerts arrive
5. **RevenueCat** -- set `REVENUECAT_WEBHOOK_AUTH`, send test event
6. **New Admin Portal** -- build and host at `admin.safetyalrt.com` (or `admin-new.safetyalrt.com` during transition)
7. **Ask ALRT** -- now runs in-backend; keep Firebase function until all users update
8. **n8n** -- confirm webhook key still works
9. **App release** -- ship production flavour
10. **Turn on billing** -- set `BILLING_ENABLED=true` after one real purchase verified

**"Never do" list** (LIVE_CONNECTIONS.md:90-97):
- Commit `.env.prod`, a key, a password, or a token to this repository
- Point TEST at the live database, bucket, or RevenueCat webhook secret
- Put `alrt_dev_*` products in the live `RC_PRODUCT_TIERS`
- Set `RC_EXPECTED_ENVIRONMENT=SANDBOX` on live
- Change the live JWT secrets during the upgrade

---

## 10. Summary Statistics

| Metric | Production (backendV2) | Release-candidate |
|---|---|---|
| Migrations | 82 | 116 (+34) |
| Prisma models | ~35 | 54 (+19) |
| Route groups | ~12 | 19 user-facing + 11 admin sub-routers |
| Total endpoints | ~60-70 (estimated) | ~120+ |
| External service integrations | ~8 (Firebase/FCM, OpenAI, S3, Google Maps, Sightengine, SMTP, Socket.IO, n8n) | 12 (+Bedrock, +RevenueCat, +ElastiCache/Valkey, +ingestion refactored) |
| Env vars required | ~20 | 33 required + 40+ optional + 8 runtime |
| Scheduled jobs | Basic sync + deletion | 6 cron schedules |
| Admin routes | Old console (separate build) | 11 sub-routers, 38 endpoints |
| Ask ALRT | Firebase Cloud Function | Native backend service (Bedrock) |
| Subscription system | None | Full V1 access model (RevenueCat + entitlement.service.ts) |

---

## End of Phase 2 Audit

# ENVIRONMENT MAP

> Generated: 2026-10-09 | Phase 1 deliverable
> Source: release-candidate repo (`ALRT-dev/alrt-v1-release-candidate`, branch `release-candidate`)

---

## 1. Environments

| Aspect | Production | TEST | Local Dev |
|---|---|---|---|
| API hostname | `api.safetyalrt.com` | `api-test.safetyalrt.com` | `localhost:3000` |
| EC2 instance | `i-0c7a10c5b1d74310d` (safety-alrt-prod) | `i-0045a41694e315d45` (alrt-test-api) | N/A |
| AWS account | `082258816984` (Matt's) | `488658242173` (sarah-sandbox) | N/A |
| Env file | `.env.prod` | `.env.test` | `.env.dev` |
| NODE_ENV | `prod` | `test` | dev |
| Database | RDS `alrt-app-db-dev` (db.t3.micro) | PostGIS container `127.0.0.1:5433` | Local PostGIS `5431` |
| Docker ports | `127.0.0.1:3001/3002 → 9000` (blue/green) | `3010 → 9000` | `3000 → 9000` |
| App bundle ID | `com.safetyalrt.alrt` | `com.safetyalrt.alrt.dev` | `com.safetyalrt.alrt.dev` |
| Admin Portal | `admin.safetyalrt.com` | `alrt-v1-release-candidate.pages.dev` | `localhost:5173` |
| RevenueCat env | PRODUCTION | SANDBOX | N/A |

---

## 2. Backend Connections

### 2.1 Databases

| Service | Env Var | Required | Notes |
|---|---|---|---|
| **PostgreSQL + PostGIS** | `DATABASE_URL` | YES | Primary DB. Prod: RDS in ap-southeast-2. Prisma ORM, 116 migrations. |
| **Redis / Valkey (ElastiCache)** | `CACHE_URL`, `CACHE_TLS` | NO | Hazard push dedup + hazard data cache. Falls back to in-memory Map. |

### 2.2 AWS Services

| Service | Env Vars | Required | Purpose |
|---|---|---|---|
| **S3** | `AWS_S3_REGION`, `AWS_S3_BUCKET_NAME`, optionally `AWS_S3_ACCESS_KEY_ID`/`SECRET` | YES | File uploads (media, avatars). Bucket: `alrt-app-bucket`. Falls back to instance role. |
| **Bedrock** | `AWS_BEDROCK_REGION`, optionally `AWS_BEDROCK_ACCESS_KEY_ID`/`SECRET` | YES | AI provider (Claude Haiku) for alert summaries + Ask ALRT. Default model: `global.anthropic.claude-haiku-4-5-20251001-v1:0`. |
| **Secrets Manager Agent** | `MAPS_API_KEY_SECRET_ID` | NO | Sidecar on localhost:2773. Loads secrets (Maps API key) into process.env at startup. No-op if agent not running. |
| **CloudFront** | `AWS_CLOUDFRONT_DOMAIN` | NO | CDN for S3 file URLs. Direct S3 URLs if unset. |

### 2.3 External APIs

| Service | Env Vars | Required | Purpose |
|---|---|---|---|
| **Google Maps (server SDK)** | `GOOGLE_MAPS_API_KEY` | YES | Reverse/forward geocoding for hazard ingestion and family location. |
| **Google Maps (proxy for frontend)** | `GOOGLE_MAPS_API_KEY` | YES | Server-side proxy at `/api/maps/*` for Geocoding, Places Autocomplete, Places Details. Key injected server-side. |
| **Sightengine** | `SIGHTENGINE_API_USER`, `SIGHTENGINE_API_SECRET`, `SIGHTENGINE_WORKFLOW_ID` | YES* | Image/video moderation. *Required at config parse but feature currently disabled via `COMMUNITY_REPORT_MEDIA_ENABLED=false`. |
| **RevenueCat (outbound API)** | `REVENUECAT_SECRET_API_KEY`, `REVENUECAT_API_BASE` | NO | Queries subscriber status to confirm pending plan changes. Skipped when key absent. |
| **OpenAI** | `OPENAI_API_KEY`, `AI_PROVIDER` | YES* | *Key required at startup even when Bedrock is primary (`AI_PROVIDER=bedrock` is default). Fallback AI provider. |
| **WAQI (air quality)** | `WAQI_API_TOKEN` | YES | Real-time air quality from `api.waqi.info` for Australian region. |
| **Open-Meteo** | None (public) | YES | Air quality data for multiple Australian cities. No auth needed. |
| **NSW Transport** | `NSW_TRANSPORT_API_KEY` | YES | Live incident and major event hazards from Transport for NSW. |
| **QLD Traffic** | `QLD_TRAFFIC_API_KEY` | NO | Traffic events. Source skipped when key is empty. |

### 2.4 Hazard Data Feeds (unauthenticated)

All fetched during 15-minute hazard sync cron. No env vars. No auth.

| Source | URL | Format |
|---|---|---|
| NSW RFS | `rfs.nsw.gov.au/feeds/majorIncidents.json` | GeoJSON |
| ACT ESA | `esa.act.gov.au/feeds/currentincidents.xml` | RSS/XML |
| SA CFS | `data.eso.sa.gov.au/prod/cfs/criimson/cfs_current_incidents.json` | JSON |
| VicEmergency | `data.emergency.vic.gov.au/Show?pageId=getIncidentRSS` | RSS |
| QLD Fire | `publiccontent.gis.psba.qld.gov.au/.../bushfireAlert.xml` | RSS |
| NT Fire & Rescue | `pfes.nt.gov.au/incidentmap/json/incidents.json` | JSON |
| WA DFES Warnings | `api.emergency.wa.gov.au/v1/rss/warnings` | RSS |
| WA DFES Incidents | `api.emergency.wa.gov.au/v1/rss/incidents` | RSS |
| NSW SES (HazardWatch) | `hazardwatch.gov.au/feed/v1/nswses-cap-au-active-warnings.atom.xml` | ATOM |
| USGS Earthquake | `earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson` | GeoJSON |
| QLD Parks | `parks.qld.gov.au/xml/rss/parkalerts.xml` | RSS |

### 2.5 Authentication Providers

| Provider | Env Vars | Required | Notes |
|---|---|---|---|
| **Google OAuth** | `GOOGLE_OAUTH_CLIENT_ID_WEB`, `_IOS`, `_ANDROID` | YES | id-token verification via `google-auth-library`. 3 platform client IDs. |
| **Apple Sign-In** | `APPLE_OAUTH_AUDIENCE` | YES | id-token verification via `apple-signin-auth`. |
| **Microsoft OAuth** | `MICROSOFT_OAUTH_CLIENT_ID`, `MICROSOFT_OAUTH_TENANT_ID` | NO | Manual JWKS-based verification. Returns 501 if not configured. Server boots without it. |
| **Email/Password** | `EMAIL_PASSWORD_AUTH_ENABLED` | NO | Backend-only auth. Toggle to enable. |

### 2.6 Push Notifications

| Service | Config | Required |
|---|---|---|
| **Firebase Cloud Messaging (FCM)** | `serviceAccountKey.json` at project root, optionally `FIREBASE_PROJECT_ID` | YES |

Firebase project: `alrt-a6539`. Sends via `firebaseAdmin.messaging().sendEachForMulticast()`, batches of 500. Channels: `alrt_alerts`, `alrt_alerts_urgent`. Two init modes: classic service account key (prod) or AWS workload identity federation (test).

### 2.7 Webhooks (inbound)

| Endpoint | Auth | Purpose |
|---|---|---|
| `POST /api/revenuecat/webhook` | `Authorization` header vs `REVENUECAT_WEBHOOK_AUTH` | RevenueCat subscription lifecycle events |
| `POST /api/webhook/hazards` | `X-Webhook-Api-Key` header vs `WEBHOOK_API_KEY` | External hazard data ingestion (from n8n) |

### 2.8 Email

| Service | Env Vars | Required |
|---|---|---|
| **SMTP (Nodemailer)** | `SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`, `SMTP_USER`, `SMTP_PASSWORD`, `EMAIL_FROM_ADDRESS`, `EMAIL_SUPPORT_ADDRESS` | YES |

Used for: password reset, support contact forms, account deletion confirmation. Sends from "ALRT Support".

### 2.9 Socket.IO (Realtime)

Initialized at server startup. Authenticated via JWT. Users join room `user_{userId}`. CORS controlled by `CORS_ALLOWED_ORIGINS` (default: `https://admin.safetyalrt.com`).

Used for: hazard alerts, family events (check-in, SOS, location updates), circle membership changes.

### 2.10 Scheduled Tasks (node-cron)

Run only when `NODE_ENV=prod` or `RUN_SCHEDULED_JOBS_IN_TEST=true`.

| Schedule | Task |
|---|---|
| `*/15 * * * *` | Hazard sync (all 15+ sources) |
| `0 2 * * *` | Process queued account deletions |
| `*/5 * * * *` | Purge expired location snapshots (1hr TTL) |
| `*/5 * * * *` | End expired journeys |
| `*/5 * * * *` | Prune stale location pings |
| `*/10 * * * *` | Award XP for expired community reports |
| `* * * * *` | Send scheduled check-in reminders |
| `* * * * *` | Auto-end 4hr SOS events + ending-soon reminders |

---

## 3. Frontend Connections (Flutter)

### 3.1 Backend API

- Prod: `https://api.safetyalrt.com`
- Dev: `http://192.168.1.67:9000` (overridable via `DEV_BASE_URL` in `.env`)
- Socket.IO connects to same base URL for realtime events

### 3.2 Firebase

- Project: `alrt-a6539` (project number `705221000399`)
- Services used: **Core**, **Cloud Messaging (FCM)**, **Analytics**
- Config files: `lib/firebase_options.dart` (prod), `lib/firebase_options_dev.dart` (dev), platform-specific `google-services.json` / `GoogleService-Info.plist`
- Android registered apps: prod (`com.safetyalrt.alrt`), dev (`com.safetyalrt.alrt.dev`)
- iOS registered app: prod only (`com.safetyalrt.alrt`) — **no separate dev iOS app registered yet**

### 3.3 Google Maps / Places / Routes

- SDK packages: `google_maps_flutter`, `flutter_polyline_points`, `geolocator`
- **Geocoding and Places**: proxied through backend (`/api/maps/*`)
- **Routes API**: called directly from client with embedded key
- **Maps SDK rendering**: uses embedded client key
- Env var: `GOOGLE_MAPS_API_KEY` (injected into Android manifest via Gradle + iOS Info.plist)

### 3.4 RevenueCat

- Package: `purchases_flutter` ^10.4.3
- Env vars: `REVENUECAT_API_KEY_APPLE`, `REVENUECAT_API_KEY_GOOGLE`
- Entitlement: `individual`
- Offerings: `personal`, `groups`
- Products: ALRT+ Individual, ALRT+ Family, Group 20, Group 50

### 3.5 Authentication (client-side)

| Provider | Package | Config |
|---|---|---|
| Google Sign-In | `google_sign_in` | `GOOGLE_OAUTH_SERVER_CLIENT_ID` in `.env` |
| Apple Sign-In | `sign_in_with_apple` | iOS entitlement `com.apple.developer.applesignin` |
| Microsoft (MSAL) | `msal_auth` | `MICROSOFT_CLIENT_ID`, `MICROSOFT_TENANT_ID` in `.env`; config in `assets/msal_config.json` |

### 3.6 Other Frontend SDKs

| SDK | Purpose | Network? |
|---|---|---|
| `in_app_review` | App Store / Play Store review prompt | Yes |
| `speech_to_text` | Voice search | On-device |
| `flutter_tts` | Read-aloud for critical alerts | On-device |
| `mobile_scanner` | QR code scanning (family invites) | On-device |
| `home_widget` | Native home screen widgets | Via backend |
| `google_fonts` | Bebas Neue font fetch at startup | Yes |

---

## 4. Admin Portal

- **Stack**: React/Vite SPA
- **Hosting**: Cloudflare Pages
- **API connection**: Uses a Cloudflare Pages Function relay (`functions/api/[[path]].ts`) to proxy `/api/*` requests to the backend server-to-server, avoiding CORS
- **Relay config**: `API_ORIGIN` Pages env var → explicit backend URL; absent → defaults to `https://api-test.safetyalrt.com`; production project sets `API_ORIGIN=https://api.safetyalrt.com`
- **Production URL**: `admin.safetyalrt.com`
- **TEST URL**: `alrt-v1-release-candidate.pages.dev`
- **In release scope**: YES — admin portal will be updated alongside the backend and mobile app

---

## 5. Infrastructure

### 5.1 Production (account `082258816984`)

| Resource | Details |
|---|---|
| EC2 (backend) | `safety-alrt-prod` / `i-0c7a10c5b1d74310d`, t3.medium, Ubuntu 24.04, IP `15.135.57.148` |
| EC2 (n8n) | `i-0f84456f93b803036`, posts to `/api/webhook/hazards` |
| RDS | `alrt-app-db-dev` (db.t3.micro), PostgreSQL + PostGIS |
| S3 | `alrt-app-bucket` |
| Secrets Manager | `safetyalrt/db/postgres`, `GOOGLE_MAPS_API_KEY`, `safety-alert/aws-credentials`, `safety-alert-prod/api-token` |
| IAM role | `safety-alrt-prod-instance-role` (on EC2 for S3 + Bedrock) |
| Monitoring | Datadog + Wiz (Lambda-based) |

### 5.2 TEST (account `488658242173` — sarah-sandbox)

| Resource | Details |
|---|---|
| EC2 (backend) | `alrt-test-api` / `i-0045a41694e315d45` |
| API | `https://api-test.safetyalrt.com` |
| Database | Local PostGIS container on `127.0.0.1:5433` |

### 5.3 Deployment

- **Backend**: Docker blue/green (`app_blue` on 3001, `app_green` on 3002, both → 9000). Prisma migrations run at container start. Host reverse proxy (Caddy/nginx) in front — not managed in repo.
- **Admin Portal**: Cloudflare Pages (auto-deploy from repo)
- **Mobile**: CI workflows (`android-test.yml`, `ios-test-testflight.yml`) — manual dispatch only. No production CI exists in this repo.
- **Infrastructure-as-Code**: None. All infra is manually managed.

### 5.4 CI/CD Secrets (GitHub)

| Secret | Purpose |
|---|---|
| `TEST_ANDROID_KEYSTORE_BASE64` + password/alias/key-password | Android test signing |
| `TEST_GOOGLE_MAPS_API_KEY` | Android test Maps key |
| `TEST_GOOGLE_MAPS_API_KEY_IOS` | iOS test Maps key |
| `TEST_GOOGLE_OAUTH_SERVER_CLIENT_ID` | Google Sign-In for test builds |
| `TEST_GOOGLE_IOS_CLIENT_ID` | Google Sign-In iOS client |
| `TEST_REVENUECAT_API_KEY_GOOGLE` | RevenueCat Android test |
| `TEST_REVENUECAT_API_KEY_APPLE` | RevenueCat iOS test |
| `APP_STORE_CONNECT_API_KEY_ID`, `_ISSUER_ID`, `_API_KEY_CONTENT` | TestFlight upload |
| `MATCH_GIT_URL`, `MATCH_GIT_BASIC_AUTHORIZATION`, `MATCH_PASSWORD` | Fastlane match (iOS certs) |

---

## 6. Services NOT Used

| Service | Status |
|---|---|
| AWS SES | Not used — email is SMTP/Nodemailer |
| AWS SNS | Not used — push is FCM |
| Firestore | Retired — migrated to Postgres |
| SMS / Twilio / SendGrid | Not present |
| Ask ALRT (Firebase Functions) | Retired — migrated to backend + Bedrock |

---

## 7. Complete Env Var Reference

### Required at startup

```
DATABASE_URL
JWT_ACCESS_SECRET, JWT_ACCESS_EXP_M, JWT_REFRESH_SECRET, JWT_REFRESH_EXP_D
ADMIN_JWT_ACCESS_SECRET, ADMIN_JWT_ACCESS_EXP_M, ADMIN_JWT_REFRESH_SECRET, ADMIN_JWT_REFRESH_EXP_D
SUPER_ADMIN_EMAIL, SUPER_ADMIN_PASSWORD, SUPER_ADMIN_NAME
GOOGLE_OAUTH_CLIENT_ID_WEB, GOOGLE_OAUTH_CLIENT_ID_IOS, GOOGLE_OAUTH_CLIENT_ID_ANDROID
APPLE_OAUTH_AUDIENCE
OPENAI_API_KEY
AWS_S3_REGION, AWS_S3_BUCKET_NAME
AWS_BEDROCK_REGION
NSW_TRANSPORT_API_KEY
WAQI_API_TOKEN
GOOGLE_MAPS_API_KEY
SIGHTENGINE_API_USER, SIGHTENGINE_API_SECRET, SIGHTENGINE_WORKFLOW_ID
SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD
EMAIL_FROM_ADDRESS, EMAIL_SUPPORT_ADDRESS
```

### Optional

```
CACHE_URL, CACHE_TLS
AWS_S3_ACCESS_KEY_ID, AWS_S3_SECRET_ACCESS_KEY (fall back to instance role)
AWS_BEDROCK_ACCESS_KEY_ID, AWS_BEDROCK_SECRET_ACCESS_KEY (fall back to instance role)
AWS_BEDROCK_FALLBACK_MODEL_ID (default: claude-haiku-4-5)
AWS_CLOUDFRONT_DOMAIN
AI_PROVIDER (default: bedrock)
MICROSOFT_OAUTH_CLIENT_ID, MICROSOFT_OAUTH_TENANT_ID
QLD_TRAFFIC_API_KEY
REVENUECAT_WEBHOOK_AUTH, REVENUECAT_SECRET_API_KEY, REVENUECAT_API_BASE
RC_PRODUCT_TIERS, RC_APP_IDS, RC_EXPECTED_ENVIRONMENT
WEBHOOK_API_KEY
FIREBASE_PROJECT_ID
CORS_ALLOWED_ORIGINS (default: https://admin.safetyalrt.com)
BILLING_ENABLED, TRIAL_LEDGER_SECRET
RUN_SCHEDULED_JOBS_IN_TEST
EMAIL_PASSWORD_AUTH_ENABLED, REVIEW_LOGIN_EMAILS
PASSWORD_RESET_BASE_URL
COMMUNITY_REPORT_MEDIA_ENABLED
MIN_APP_VERSION_IOS, MIN_APP_BUILD_IOS, APP_STORE_URL_IOS
MIN_APP_VERSION_ANDROID, MIN_APP_BUILD_ANDROID, APP_STORE_URL_ANDROID
TERMS_VERSION, PRIVACY_VERSION, COMMUNITY_GUIDELINES_VERSION
TRUST_PROXY + rate limit tuning vars
```

### Required files (not env vars)

```
serviceAccountKey.json (Firebase Admin credential at backend project root)
```

### Frontend .env vars

```
GOOGLE_OAUTH_SERVER_CLIENT_ID
GOOGLE_MAPS_API_KEY
MICROSOFT_CLIENT_ID, MICROSOFT_TENANT_ID
REVENUECAT_API_KEY_APPLE, REVENUECAT_API_KEY_GOOGLE
DEV_BASE_URL (dev flavor only, optional)
GOOGLE_MAPS_ANDROID_PACKAGE_NAME, GOOGLE_MAPS_ANDROID_CERT_SHA1, GOOGLE_MAPS_IOS_BUNDLE_ID (optional, for key restriction)
```

---

## 8. Connection Test Results (2026-10-09)

Tested from browser against live endpoints.

### Production (`api.safetyalrt.com`)

| Endpoint | Status | Result |
|---|---|---|
| `GET /api/test` | ✅ 200 | "Test route is working!" — matches backendV2 code |
| `POST /api/revenuecat/webhook` | ✅ 404 | Route not found — confirms backendV2 (no RevenueCat) deployed |
| Admin Portal (`admin.safetyalrt.com`) | ✅ reachable | Responds OK |

### TEST (`api-test.safetyalrt.com`)

| Endpoint | Status | Result |
|---|---|---|
| `GET /api/test` | ✅ 200 | "Test route is working!" |
| `POST /api/revenuecat/webhook` | ✅ exists | CORS block (not 404) — confirms release-candidate code deployed |
| `GET /api/family` | ✅ 401 | "Authorization header missing" — route exists, auth working |
| Admin Portal (`alrt-v1-release-candidate.pages.dev`) | ✅ alive | Login page renders (email/password form) |

### External Hazard Data Feeds

| Feed | Status |
|---|---|
| NSW RFS (`rfs.nsw.gov.au`) | ✅ reachable |
| VicEmergency (`data.emergency.vic.gov.au`) | ✅ reachable |
| WA DFES (`api.emergency.wa.gov.au`) | ✅ reachable |
| USGS Earthquake (`earthquake.usgs.gov`) | ✅ reachable |
| WAQI Air Quality (`api.waqi.info`) | ✅ reachable |
| Open-Meteo (`air-quality-api.open-meteo.com`) | ✅ reachable |

### Not Tested (require credentials)

| Connection | Reason |
|---|---|
| PostgreSQL (RDS) | Requires `DATABASE_URL` — cannot test from browser |
| Redis / ElastiCache | Internal network only |
| AWS S3 | Requires IAM credentials |
| AWS Bedrock | Requires IAM credentials |
| Firebase (FCM push) | Requires `serviceAccountKey.json` |
| Google Maps API (server key) | Requires API key — tested indirectly via maps proxy route |
| Sightengine | Requires API credentials |
| RevenueCat outbound API | Requires `REVENUECAT_SECRET_API_KEY` |
| OpenAI | Requires API key |
| SMTP email | Requires SMTP credentials |
| NSW Transport API | Requires API key |
| QLD Traffic API | Requires API key |
| Google/Apple/Microsoft OAuth | Requires client IDs + real tokens |

> **Note:** Credential-gated connections can only be verified from the TEST server itself. This will be done in Phase 3 when sandbox work begins.

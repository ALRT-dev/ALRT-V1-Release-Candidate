# ALRT live connections: what is live, where it lives, how to switch it on

Recorded 4 October 2026 from a read-only look at the live AWS account and the
code on this branch. **No secret values are in this repository, and none may
ever be added - the repository is public.** Secrets go only in the live
server's `backend/.env.prod` (gitignored) or in AWS Secrets Manager.

## 1. What is live today

| Part | Live resource | Notes |
|---|---|---|
| AWS account | `082258816984` (ALRT), region `ap-southeast-2` | Owned by Matt. Sarah has Billing and ReadOnlyAccess only. |
| Backend server | EC2 `safety-alrt-prod`, `i-0c7a10c5b1d74310d`, t3.medium, Ubuntu 24.04, public IP `15.135.57.148` | Runs `backend/docker-compose.yml` (blue/green on 127.0.0.1:3001/3002 -> 9000), which loads `backend/.env.prod`. IAM role `safety-alrt-prod-instance-role`. The Elastic IP is labelled "(Dev) Alrt". |
| Public API | `https://api.safetyalrt.com` | Compiled into the production app (`frontend/lib/api/endpoints.dart`). |
| Database | RDS PostgreSQL `alrt-app-db-dev` (db.t3.micro), password in Secrets Manager `safetyalrt/db/postgres` | Named "dev" but it is the database in the production account. **Confirm with Matt that it holds the real users and alerts before any migration.** |
| Photo storage | S3 bucket `alrt-app-bucket` | Credentials likely in Secrets Manager `safety-alert/aws-credentials`. |
| Maps key | Secrets Manager `GOOGLE_MAPS_API_KEY` and `safety-alert-prod/api-token` | |
| Admin Portal (old) | `https://admin.safetyalrt.com` ("Safety ALRT - Admin Console") | Not built from this repository. Has a hazard map and forced password change that the new portal does not have yet. |
| n8n | EC2 `i-0f84456f93b803036` in the same account | Posts alerts to `/api/webhook/hazards` with a webhook key. |
| Monitoring | Datadog and Wiz (Lambda functions and secrets in the account) | Not used by the app itself. |
| Firebase | Project `alrt-a6539` | Push. (The new code moves Ask ALRT and entitlements into the backend.) |
| RevenueCat | Webhook currently targets `https://api.safetyalrt.com/api/revenuecat/webhook` (Production + Sandbox) | Last recorded delivery failed with 404 on 24 Sep 2026 - the live code predates this route. |

Checked and empty of app settings: Systems Manager Parameter Store, App
Runner, Lambda environment. Every other live key is **only** in the
existing `.env.prod` on the live server.

## 2. Where each setting comes from

The full annotated list is `backend/.env.prod.example`. In short:

| Setting group | Source |
|---|---|
| `DATABASE_URL` | Secrets Manager `safetyalrt/db/postgres` (script fills it) |
| `GOOGLE_MAPS_API_KEY` | Secrets Manager `GOOGLE_MAPS_API_KEY` (script fills it) |
| `AWS_S3_ACCESS_KEY_ID`, `AWS_S3_SECRET_ACCESS_KEY` | Secrets Manager `safety-alert/aws-credentials` (script fills it) |
| JWT and admin JWT secrets | Existing server `.env.prod` - **keep the same values** or everyone is signed out |
| OpenAI, Sightengine, NSW Transport, WAQI, QLD Traffic, SMTP | Existing server `.env.prod`, otherwise each provider's dashboard |
| Google / Apple sign-in client ids | Existing server `.env.prod`, otherwise Google Cloud console / Apple Developer |
| RevenueCat (`REVENUECAT_WEBHOOK_AUTH`, `RC_*`) | New - not on the old live server. Set up during the upgrade. |
| `BILLING_ENABLED` | Decision. Keep `false` until one real purchase is traced end to end. |

## 3. Switch-on order

Do these in order. Steps 1-2 need someone with more than ReadOnlyAccess on
account `082258816984`.

1. **Back up.** Take an RDS snapshot of `alrt-app-db-dev` and copy the
   current server `.env.prod` somewhere private. Do not reset or re-create the
   database.
2. **Prepare the settings file on the server** (from `backend/`):
   ```
   cp .env.prod .env.prod.old          # keep the working copy
   cp .env.prod.example .env.prod.new
   # copy every value from .env.prod.old into .env.prod.new (same names)
   ENV_FILE=.env.prod.new bash scripts/fill-env-prod-from-aws.sh
   ENV_FILE=.env.prod.new bash scripts/check-env-prod.sh
   ```
   Fix anything the check lists, then `mv .env.prod.new .env.prod`.
3. **Deploy the backend** from the approved branch. The compose command runs
   `prisma migrate deploy` on start, which applies every pending migration,
   including `20260928000000_v1_access_model`,
   `20260929000000_v1_subscription_changes` and
   `20260930000000_v1_review_followup`. Rehearse this on the TEST server
   first.
4. **Check it is up:** `https://api.safetyalrt.com/api/test` answers, an app
   sign-in works, and alerts keep arriving (source sync runs every 15 minutes
   when `NODE_ENV=prod`).
5. **RevenueCat:** put the same random string in `REVENUECAT_WEBHOOK_AUTH`
   and in the RevenueCat webhook's Authorization header. Send a test event
   from RevenueCat and confirm it is accepted (no 404, 401 or 503).
6. **New Admin Portal:** `cd admin && npm ci && npm run build` (uses
   `admin/.env.production`, which points at `https://api.safetyalrt.com`).
   Host `admin/dist` and point `admin.safetyalrt.com` at it once you are happy
   to replace the old console. Existing admin logins carry over (same backend
   login system) - test one first.
7. **Ask ALRT:** now runs inside the backend (migration
   `20261006000000_ask_alrt_in_backend`, applied in step 3); the live
   server's role already allows Bedrock. Firebase is only used for push.
   Keep the old Firebase Ask ALRT function running until every user has an
   app build that calls `/api/ask-alrt`, then retire it.
8. **n8n:** confirm its webhook key still works after the upgrade (Admin
   Portal -> Webhook keys).
9. **App release:** ship the production flavour (`com.safetyalrt.alrt`),
   which already targets `api.safetyalrt.com`, with the RevenueCat app keys
   set. The ALRT+ test unlock only works in the dev flavour.
10. **Turn on billing:** after one real purchase reaches `/api/access`
    correctly, set `BILLING_ENABLED=true` and restart.

## 4. Never do

- Commit `.env.prod`, a key, a password or a token to this repository.
- Point TEST at the live database, bucket or RevenueCat webhook secret.
- Put `alrt_dev_*` products in the live `RC_PRODUCT_TIERS`.
- Set `RC_EXPECTED_ENVIRONMENT=SANDBOX` on live.
- Change the live JWT secrets during the upgrade.

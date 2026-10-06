# TEST setup checklist: make the TEST app behave like the store app

Goal: the ALRT Dev app (`com.safetyalrt.alrt.dev`, TestFlight and the Android
TEST build) works end to end like the store app, against the isolated TEST
backend `https://api-test.safetyalrt.com`. Nothing here touches the live app,
the live server (`api.safetyalrt.com`, AWS account 082258816984) or real users.

Each item says where to click and what to paste. Secret VALUES are never put
in the repo; only their names appear here.

## 1. Google Maps on iPhone (fixes the blank map; the crash itself is fixed in code)

1. Google Cloud Console, the project that holds the TEST Android Maps key
   (`TEST_GOOGLE_MAPS_API_KEY`). APIs and services, Library: enable
   **Maps SDK for iOS**.
2. Credentials, Create credentials, API key. Restrict it: Application
   restrictions **iOS apps**, bundle ID `com.safetyalrt.alrt.dev`; API
   restrictions **Maps SDK for iOS** (add **Routes API** if routes are used).
3. GitHub, `ALRT-dev/ALRT-V1-Release-Candidate`, Settings, Secrets and
   variables, Actions, New repository secret:
   `TEST_GOOGLE_MAPS_API_KEY_IOS` = that key.

## 2. Google sign-in on Android (Samsung)

1. Same Google Cloud project as the TEST web OAuth client already stored in
   the secret `TEST_GOOGLE_OAUTH_SERVER_CLIENT_ID`. Credentials, Create
   credentials, OAuth client ID, **Android**:
   - Package name: `com.safetyalrt.alrt.dev`
   - SHA-1: `18:5E:43:9B:FC:7A:99:42:0C:AD:F0:EB:A9:E1:4F:0A:EE:66:2D:DB`
     (the TEST keystore the Android TEST build is signed with).
2. Nothing else in GitHub: `android-test.yml` now passes the existing
   `TEST_GOOGLE_OAUTH_SERVER_CLIENT_ID` to the app.

## 3. TEST backend settings for sign-in

On the TEST server's environment (`.env.test`), then restart it:

| Key | Value |
|---|---|
| `GOOGLE_OAUTH_CLIENT_ID_WEB` | the TEST web client (same value as the GitHub secret `TEST_GOOGLE_OAUTH_SERVER_CLIENT_ID`) |
| `GOOGLE_OAUTH_CLIENT_ID_IOS` | the TEST iOS client (same value as `TEST_GOOGLE_IOS_CLIENT_ID`) |
| `GOOGLE_OAUTH_CLIENT_ID_ANDROID` | the Android client ID from step 2 |
| `APPLE_OAUTH_AUDIENCE` | `com.safetyalrt.alrt.dev` |

## 4. Push notifications on the iPhone TEST app

1. Firebase console, project `alrt-a6539`, Project settings, Add app, iOS,
   bundle ID `com.safetyalrt.alrt.dev`. Download its `GoogleService-Info.plist`
   (a client config file, not a secret) and hand it over so the dev flavour
   can be wired to it.
2. Project settings, Cloud Messaging, Apple app configuration: make sure the
   APNs authentication key (.p8) for the Apple team is uploaded.

## 5. Real sandbox purchases (trials, restore) like the store

1. RevenueCat: the sandbox/test project's public Apple and Google SDK keys as
   GitHub secrets `TEST_REVENUECAT_API_KEY_APPLE` and
   `TEST_REVENUECAT_API_KEY_GOOGLE`.
2. RevenueCat, Integrations, Webhooks: URL
   `https://api-test.safetyalrt.com/api/revenuecat/webhook`, Authorization
   header value of your choice (also step 3 below).
3. TEST server `.env.test`:

| Key | Value |
|---|---|
| `BILLING_ENABLED` | `true` |
| `REVENUECAT_WEBHOOK_AUTH` | the Authorization value from step 2 |
| `RC_PRODUCT_TIERS` | each store product ID mapped to a tier, e.g. `<individual id>:individual,<family id>:family,<group20 id>:group20,<group50 id>:group50` |
| `RC_EXPECTED_ENVIRONMENT` | `SANDBOX` |
| `RC_APP_IDS` | the RevenueCat app IDs of the Dev apps (comma separated) |
| `REVENUECAT_SECRET_API_KEY` | the RevenueCat secret API key (Restore checks) |
| `TRIAL_LEDGER_SECRET` | a long random value, set once and never rotated |

4. Build with the iOS workflow input `billing_mode = platform_sandbox` and the
   Android input `billing_mode = test_store`.

## 6. Alerts arriving on their own, like prod

TEST server `.env.test`: `RUN_SCHEDULED_JOBS_IN_TEST=true`. Without it alerts
only appear after Admin Portal, Alerts, Sync, and they expire after 6 to 48
hours; SOS auto-end, the SOS ending-soon reminder and account deletions also
need it.

## 7. Ask ALRT AI answers on TEST

1. In the AWS account that runs the TEST server: Amazon Bedrock, Model access,
   enable **Anthropic Claude Haiku 4.5**.
2. The TEST server's role (or `AWS_BEDROCK_ACCESS_KEY_ID`/`SECRET`) needs
   `bedrock:InvokeModel` on the Haiku 4.5 foundation model and the
   `global.anthropic.claude-haiku-4-5-20251001-v1:0` inference profile.
   (The live server's role already has this.)
3. `AWS_BEDROCK_REGION` set (for example `ap-southeast-2`).

## 8. The TEST Admin Portal can reach the TEST server

TEST server `.env.test`:
`CORS_ALLOWED_ORIGINS=https://alrt-v1-release-candidate.pages.dev`

## 9. Deploy the new backend to TEST

Deploy branch `claude/compassionate-franklin-512so7` to the TEST server only.
`docker-compose.test.yml` runs `prisma migrate deploy` on start, which applies
the new database changes (Ask ALRT tables, SOS reminder marker). Leave the
`MIN_APP_*` force-update keys blank until you want to retire an old build.

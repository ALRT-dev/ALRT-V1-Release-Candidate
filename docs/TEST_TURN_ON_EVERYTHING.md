# Turning on everything for the TEST app (12 Oct 2026)

For the owner or Matt. Nothing here touches the live server. Only the TEST
instance (i-0045a41694e315d45, api-test.safetyalrt.com) is involved.

## A. Put the new backend code on TEST

The app now calls two backend things that exist only in this branch
(claude/compassionate-franklin-512so7):

1. `POST /api/family/hazards/:hazardId/share` ("Send to my group").
2. Scheduled check-ins send `utcOffsetMinutes` (the phone's timezone) and
   the server no longer defaults to Brisbane.

Steps on the TEST server:

1. Pull the branch and install: `git pull`, `npm ci`.
2. Apply migrations: `npx prisma migrate deploy` (the newest are
   `20261010000000_scheduled_checkin_timezone` and
   `20261010100000_ready_tab_plan_drill`), then `npx prisma generate`.
3. Build and restart the TEST service.
4. Check: `POST /api/revenuecat/webhook` should answer 401 or 400, not 404.

## B. Turn on paywalls (enforced billing)

1. GitHub repo secrets: `TEST_REVENUECAT_API_KEY_APPLE` (the ALRT Dev app's
   public Apple SDK key; never a Test Store key).
2. RevenueCat webhook: `https://api-test.safetyalrt.com/api/revenuecat/webhook`
   with an Authorization value you choose.
3. `.env.test` on the TEST server: `BILLING_ENABLED=true`,
   `REVENUECAT_WEBHOOK_AUTH`, `RC_PRODUCT_TIERS`,
   `RC_EXPECTED_ENVIRONMENT=SANDBOX`, `RC_APP_IDS`,
   `REVENUECAT_SECRET_API_KEY`, `TRIAL_LEDGER_SECRET`. Restart.
4. Install the TestFlight build made with `billing_mode = platform_sandbox`.
   (The default "bypass" build keeps ALRT + unlocked and hides paywalls.)
5. Use an Apple sandbox tester account to buy.

## C. Alerts arrive on their own

`.env.test`: `RUN_SCHEDULED_JOBS_IN_TEST=true`, then restart. Without it,
alerts appear only after Admin Portal, Alerts, Sync.

## D. Get Directions

Google Cloud Console, the TEST iOS Maps key (`TEST_GOOGLE_MAPS_API_KEY_IOS`):
enable the **Routes API** on that key and make sure it is allowed for bundle
id `com.safetyalrt.alrt.dev`. The app now shows the reason on screen when
directions fail.

## E. Ask ALRT answers

Bedrock model access for Claude Haiku 4.5 in the TEST account, and
`AWS_BEDROCK_REGION` set (see TEST_SETUP_CHECKLIST.md section 7).

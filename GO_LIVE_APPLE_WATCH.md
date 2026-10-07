# ALRT + Apple Watch: go-live runbook

Date: 7 October 2026. Branch: `claude/cool-ritchie-zf2xey`.
Status: **prepared, not released.** Nothing here has been deployed to the TEST or live backend, and nothing has been uploaded to the live app's TestFlight. Every step below is run by Sarah or her engineer. ALRT's repository rules say Claude never deploys.

## What "live" means for the watch

The watch app ships **inside** the ALRT iPhone app, and it talks to the backend **only through the iPhone**. So the watch goes live when two things are live:

1. **The V1 release-line backend** on `api.safetyalrt.com`. The live server today runs the older backend behind store app 1.0.4. The watch needs the V1 family routes (circles, check-in, SOS, SOS preview) plus the watch commit's duplicate-tap protection. In practice the watch goes live **together with V1 (app 1.0.5)**, not on its own.
2. **The live iPhone app** (`com.safetyalrt.alrt`) built with the watch inside, first in TestFlight, then submitted to the App Store.

The live app already points at the live backend (`kUrlBase = https://api.safetyalrt.com` in `frontend/lib/api/endpoints.dart`); no app setting changes for "live".

## What was prepared on this branch

| Piece | File | State |
|---|---|---|
| Live signing for the watch | `frontend/ios/fastlane/Fastfile` (`ci_certs`), `frontend/ios/ExportOptionsCI.plist` | Adds `com.safetyalrt.alrt.watchkitapp` (App ID registered and profile created only on a `generate_certs=true` run) |
| Live build pipeline | `.github/workflows/ios-prod-testflight.yml` ("iOS Live TestFlight (ALRT + Apple Watch)") | Manual only. Refuses to start unless you type `LIVE`. Runs in the GitHub Environment `production` so you can require an approver. Checks the archive is `com.safetyalrt.alrt` with `com.safetyalrt.alrt.watchkitapp` inside before uploading. Uploads to the live app's **TestFlight only** (no App Store release). Not run yet. |
| TEST rollout for new migrations | `backend/scripts/alrt-test-rollout.sh` revision 15 | New mode `--apply-listed-migrations "NAMES"`: deploys only if the pending migrations equal exactly the names you type. Harness: 78/78 scenarios pass (69 existing + 9 new); the new ledger query was also run against a real Postgres. |

## Order of work

### Stage 1: TEST backend (api-test)

1. Pick the commit to deploy on this branch (the full 40-character SHA) and approve it.
2. On the TEST host, in your AWS SSM session, with the repository's rollout script:
   ```
   bash alrt-test-rollout.sh preflight --pin <SHA>
   bash alrt-test-rollout.sh record --pin <SHA>
   bash alrt-test-rollout.sh deploy --pin <SHA> --apply-listed-migrations "<every pending migration name>"
   bash alrt-test-rollout.sh verify
   ```
   The deploy step prints the pending list (`pending-migrations.txt`) and stops unless it matches your names exactly. Expect to name **all** migrations newer than what TEST has, not only `20261007000000_wearable_client_request_id`. If TEST was last deployed at `f1f6b92` (10 September), that includes the October migrations (SOS one hour, terms record, trial record, Ask ALRT in backend) as well. Review that list before typing it.
3. Optional, TEST only: `WEARABLE_ACTIONABLE_PUSH=true` in the TEST `.env.test`, then restart, for the "Open circle" button on wrist notifications.
4. Run the device checklist in `APPLE_WATCH_TESTING_GUIDE.md` with TestFlight build 133 (ALRT Dev) on your iPhone and Apple Watch.

### Stage 2: live backend (api.safetyalrt.com)

5. Merge `claude/live-connection-config` (live settings template and the AWS Secrets Manager fill script; no secrets).
6. Take a backup of the live database and confirm it restores.
7. Deploy the V1 backend to the live server with its migrations. The watch migration is additive (two nullable columns and two unique indexes); store app 1.0.4 never sends `clientRequestId`, so it behaves as before. Leave `WEARABLE_ACTIONABLE_PUSH` off until stage 4.
8. Smoke test with a staff account: sign in, check in, request a check-in, send and end an SOS between two staff phones.

### Stage 3: live app in TestFlight

9. GitHub → Settings → Environments → `production` → add yourself (or another person) as a required reviewer.
10. Actions → "iOS Live TestFlight (ALRT + Apple Watch)" → Run workflow: type `LIVE`, tick `generate_certs` **the first time only** (registers the watch App ID and creates its profile; additive, nothing is revoked).
11. In App Store Connect → ALRT → TestFlight, add internal testers; install on an iPhone with a paired Apple Watch and repeat the device checklist against the live backend with staff accounts only.

### Stage 4: App Store

12. App Store Connect → ALRT → new version 1.0.5: add **Apple Watch screenshots** (required once a watch app is included), mention the watch in "What's New", and give App Review a demo account that is in a circle with a second account so check-in and SOS can be tried.
13. Submit. Release manually after approval.
14. After release, optionally turn on `WEARABLE_ACTIONABLE_PUSH=true` on the live backend.

## Rollback

- Backend: the rollout records a rollback image; the watch migration's columns are nullable and unused by older apps. `WEARABLE_ACTIONABLE_PUSH` off restores today's pushes exactly.
- App: TestFlight builds can be expired in App Store Connect; an App Store release can be paused (phased release) or replaced.
- Watch only: a person can hide the watch app from the Watch app on their iPhone.

## Not included

Watch-face complication, answering "I've seen this" from the wrist, journeys on the watch, Wear OS, glasses.

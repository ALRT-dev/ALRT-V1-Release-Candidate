# ALRT production readiness checklist (12 Oct 2026)

Branch `claude/compassionate-franklin-512so7`. Status words: DONE (checked, with the evidence named), CODE ONLY (in the code, not checked live or on a phone), OPEN (not done), OWNER (only Sarah or Matt can do it). Nothing here has been deployed. Production is untouched.

## 1. App (iOS and Android)

| Item | Status | Evidence / note |
| --- | --- | --- |
| Test builds compile, analyse and pass tests | DONE | Android 38255244536 and iOS 38255247975 green on e157a55 |
| Latest build (95c5b64: wording only) | CHECK | Runs 38258292136 (Android) and 38258295907 (iOS) started; read the result before release |
| Every app API call has a backend route | DONE | 115 app calls vs 138 backend routes, 0 unmatched (method and path only, not fields) |
| Phone testing of the new screens (filters, cards, onboarding plans, map layers, report chips) | OPEN | No phone results yet; never claim a pass without them |
| Map layers icon opens map type sheet | CODE ONLY | e157a55 |
| Onboarding plan cards open sign-up | CODE ONLY | 6233679; buying needs the RevenueCat sandbox key |
| iPhone home-screen widgets | OPEN | Widget target is not in the Xcode project (see ios/AlrtWidget/SETUP.md); OWNER (Xcode) |
| Android home-screen widgets | CODE ONLY | Declared in the manifest; untested |
| For You (Safety profile) block on alerts | OPEN | Not reproduced; needs one alert and the ticked chips |
| Backend routes with no app caller | OPEN | GET /api/alerts/geo, GET /api/user/account/deletion-status, POST /api/auth/password-reset/confirm, hazard media edit/delete: wire or remove |
| Crash report "ALRT Dev crashed" | OPEN | Need crash text from the phone (Analytics Data) |
| Directions (Routes API) | OWNER | Routes API must be enabled on the TEST iOS Maps key; not confirmed |

## 2. Backend and services

| Item | Status | Evidence / note |
| --- | --- | --- |
| TEST backend has the share route and timezone fix | OPEN | OWNER: deploy to TEST (needs AWS sandbox access; connector is signed out) |
| Scheduled alert fetch on TEST | DONE | Admin shows fetches at 3:30 pm 12 Oct, 509 active alerts, 19 sources |
| WA coverage beyond DFES | OPEN | BoM feed disabled in code; owner decision, not touched |
| Source health | OPEN | SA CFS failing; BoM, Smartraveller, GDACS, Canada, QLDTraffic never fetched |
| Severity bands stored on alerts match the Standard v1.2 | OPEN | Code implements it; stored values not yet checked |
| Test data in feeds | OPEN | "TEST AUSALERT" alert in the ACT feed |
| Billing (BILLING_ENABLED, RevenueCat webhook, product ids) | OWNER | Off on TEST per project notes; not checked live |
| Bedrock (AI) access | OWNER | Not confirmed |
| Ask ALRT service | OPEN | Not checked live |

## 3. Before any production release (all OWNER decisions)

1. Confirm the release commit and that its iOS and Android builds are green.
2. Complete real-device QA on iOS and Android and record the results.
3. Deploy backend and services to TEST first, then repeat the QA.
4. Confirm production settings (billing, scheduled jobs, keys, store products and prices) against docs/V1_ACCESS_MODEL_IMPLEMENTATION.md.
5. Then TestFlight and Play internal testing, then production.

Rules that do not change: production is never deployed or reconfigured without an explicit instruction naming it; no secrets in the repo; the AI never sets severity.

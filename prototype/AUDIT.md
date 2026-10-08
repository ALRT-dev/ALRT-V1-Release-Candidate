# ALRT UI prototype: audit

Branch `claude/ui-prototype-8oct` (from `claude/compassionate-franklin-512so7` @ 495a764). Only the `prototype/` folder was added. No app, backend, migration, workflow or config file in the repo was changed. Nothing deployed.

Run it: `node prototype/server.js` then open http://localhost:4173. Audit: `python3 prototype/audit.py` (204 checks, drives the real UI in Chromium against the mock backend, writes `audit-results.json`).

Result at commit: **204 / 204 passed** (phase 1: core loop, 115 checks; phase 2: every remaining screen from the traceability matrix, 89 checks).

## Traceability
`traceability.json` maps all 87 real screens, sheets and backend rules to a design board, a prototype screen and a status. The same matrix is published as the "ALRT UI Traceability Audit" doc. After phase 2 every row marked MISSING or PARTIAL in the frontend now has a working screen in `public/app2.js` (family invites, roll call, location requests, member sheet, sharing level, circle profile, scheduled check-ins, family places, SOS lists and preview, SOS receiver and resolved, past SOS, shared journey, group settings, host hand-over, switch group, filters, flag and block, follow, family strip and guide strip on alerts, duplicate report, rate limit, My ALRTs, manage notifications, accessible alerts, points and leaderboard and badges, child mode, blocked accounts, support, delete and recover, add widget, share ALRT, language, legal, sign-out confirm, My plans with billing issue and unbound sponsorship, all 11 refusal codes, forced update, set-up complete, notification priming, forgot password). The rows that stay open are the backend gaps and conflicts listed below.

## What it is
- `rules.json`: every price, limit, timing, colour and phrase, taken from the 28 Sep reconciled spec, the 3 Oct rules commit, `frontend/CLAUDE.md` and the alert surfaces audit. The UI and the mock backend both read it, so they cannot disagree.
- `server.js`: zero-dependency mock of the real `/api` routes (auth, access + refusal codes, alerts, votes, saved places, Ask ALRT quota, family circles, check in, check on, SOS, journeys, sponsorship bind, individual funding, notifications, XP, RevenueCat webhook). `ALRT_API=https://api-test.safetyalrt.com node prototype/server.js` proxies `/api` to the TEST API instead of the mock. Never point it at prod.
- `public/`: the interactive app. Splash, 5 onboarding steps, map and list, alert detail (AWS, official, community, global, ALRT Assessment, urgent-wording example), report and posted, saved places, Ask ALRT, notifications feed and lock screen push, Ready, Learn, Drill, Family empty and hub, Plan and cover, Journey, SOS hold sheet, three paywalls, Me (plan, alert level, Safety Profile, points), widgets, offline banner. Footer is the Instagram-style flat icon bar in ALRT colours.
- Dev panel (right of the phone): reset, advance the clock 10/50/61 min, billing on/off, offline, add a friend, neighbour confirms, lock screen push.

## Rules verified by the audit
| Area | Verified |
|---|---|
| Onboarding | white splash; Welcome to ALRT first; age gate blocks Continue; no location prompt; no prices; sign in last |
| Wording | no "I'm safe", "is safe", "all clear", "000", em or en dashes on any screen scanned; Check in / Check on / Checked in |
| Shapes and bands | triangle, diamond, circle, square, shield present; AWS shows the level word; non-AWS official shows none; urgent-wording official alert stays Info grey |
| Official alert order | In plain terms (#23252B), What we know, What to do, For you; share button; no emergency contacts block |
| Community | category mandatory; always Unverified; I see it / I don't see it; push on AI acceptance (code truth, R08), one push only, title 'Community report \| title'; reporter gets ALRT Approved; duplicate 409 opens 'Is this the alert?'; 3 per hour / 10 per day 429; flag (3 flags sends back to review) and block |
| Free limits | 1 saved place (402 SAVED_PLACE_LIMIT, refusal sheet, then paywall); 3 Ask ALRT a day (4th is 429 ask_limit, as in code) |
| ALRT + | $5.99/month, 2 week trial, purchase goes through the RevenueCat webhook, access reflects trial, 10 Ask a day, second place allowed |
| Groups | create and join free; invite codes ALRT-XXXXX 20 uses 7 days, host only to create and revoke; free member refused in an uncovered group (INDIVIDUAL_REQUIRED) and in an expired one (GROUP_PLAN_ENDED); covered group lets the free member in; PLAN_TOO_SMALL, HOST_ONLY, GROUP_ALREADY_COVERED, PAYER_ONLY, CHANGE_IN_STORE all surface as refusal sheets; host hand-over pushes 'is now hosting'; leaving as host starts a 7 day transition; multi circle switch |
| SOS | 1 s hold does nothing; 3 s hold sends; preview shows who it reaches; NO_SOS_RECIPIENTS when nobody; SOS lists max 4, one group per list (422 SOS_PRESET_OTHER_GROUP); lasts 1 h; Ending soon inside last 10 min; Extend adds 1 h with no cap (code); auto-expires; only the sender can end (403); receivers respond seen / on my way / called, seen pushes the sender; past SOS has no coordinates; widget never fires SOS |
| Journey | 15/30/60; recipients chosen; live is opt-in and refused (409 LIVE_JOURNEY_NOT_ALLOWED) while the group is snap-points only; snapped points every 10 min; capped at 4 h; shared journey viewer polls 10 min or 45 s live |
| Me | alert level saved to backend and the 5 raw flags editable (Emergency Warning locked on); Safety Profile stays on device; sharing level per circle saved; snapshot expires after 1 h; location request refused when sharing is off; leaderboard shows Community member only; no streaks; child mode hides Report; block and unblock; support; delete with 30 day recovery; 4 distinct widgets |
| Offline | banner "Showing alerts as of HH:MM" |
| Billing flag | off makes `/api/access` report `billingEnabled:false` |

## Honest gaps (mocked or not yet real)
1. This is a web prototype on a mock backend. It shows behaviour and wording; it is not Flutter code. Matt and Shrijan implement against `rules.json` and the screens.
2. The store purchase sheet is simulated; the RevenueCat webhook call is real in shape but the mock does not verify signatures. Products and prices in App Store Connect / Play and RevenueCat are still not verified (open item from the access docs).
3. Ask ALRT answers are canned. The real path is the Bedrock Claude Haiku route in the backend; the AI provider conflict (P1) is still open.
4. Share sheet shows the real public link shape (/a/:id); the family-circle share is client side only.
5. "Keep it quiet" notification level needs a minimum-band field the backend does not have. Daily digest not built. Guest mode is retired; the prototype has no guest button and the real auth screen still does.
9. Where docs and code disagree the prototype follows code: no SOS 4 hour cap, sender-only end, community push on acceptance, 429 ask_limit, 20 person individually funded groups. See the traceability doc for the decisions list.
6. Map is a schematic, not PostGIS. No real geofencing, FCM, widgets or lock screen: those are previews.
7. Tier names "ALRT 20 / 40 people" in your message are Group 20 and Group 50 in the repo. Prototype uses the repo names. Tell me if the names changed.
8. Learn topics, Family widget wording and the drill content are placeholders.

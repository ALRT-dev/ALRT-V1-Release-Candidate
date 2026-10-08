# ALRT UI prototype: audit

Branch `claude/ui-prototype-8oct` (from `claude/compassionate-franklin-512so7` @ 495a764). Only the `prototype/` folder was added. No app, backend, migration, workflow or config file in the repo was changed. Nothing deployed.

Run it: `node prototype/server.js` then open http://localhost:4173. Audit: `python3 prototype/audit.py` (104 checks, drives the real UI in Chromium against the mock backend, writes `audit-results.json`).

Result at commit: **104 / 104 passed.**

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
| Community | category mandatory; always Unverified; I see it / I don't see it; no push until first confirmation; one push only; push says Community report, no band word |
| Free limits | 1 saved place (402 SAVED_PLACE_LIMIT then paywall); 3 Ask ALRT a day (4th is 402 ASK_LIMIT) |
| ALRT + | $5.99/month, 2 week trial, purchase goes through the RevenueCat webhook, access reflects trial, 10 Ask a day, second place allowed |
| Groups | create and join free; free member refused Check in in an uncovered group (INDIVIDUAL_REQUIRED); covered group (Family, 6) lets the free member in; copy says a plan gives nobody personal benefits |
| SOS | 1 s hold does nothing; 3 s hold sends; lasts 1 h; Ending soon inside last 10 min; Extend adds 1 h; auto-expires; member push is critical with "Call your local emergency number"; widget never fires SOS |
| Journey | 15/30/60; live is opt-in; snapped points every 10 min; capped at 4 h |
| Me | alert level saved to backend; Safety Profile stays on device (not in profile API); leaderboard has no identities; no streaks; 4 distinct widgets |
| Offline | banner "Showing alerts as of HH:MM" |
| Billing flag | off makes `/api/access` report `billingEnabled:false` |

## Honest gaps (mocked or not yet real)
1. This is a web prototype on a mock backend. It shows behaviour and wording; it is not Flutter code. Matt and Shrijan implement against `rules.json` and the screens.
2. The store purchase sheet is simulated; the RevenueCat webhook call is real in shape but the mock does not verify signatures. Products and prices in App Store Connect / Play and RevenueCat are still not verified (open item from the access docs).
3. Ask ALRT answers are canned. The real path is the Bedrock Claude Haiku route in the backend; the AI provider conflict (P1) is still open.
4. Share-to-family-circle is client side only here. The real build needs the public share link route.
5. "Keep it quiet" notification level needs a minimum-band field the backend does not have. Daily digest not built. Guest mode is retired in the rules but the button still exists in code.
6. Map is a schematic, not PostGIS. No real geofencing, FCM, widgets or lock screen: those are previews.
7. Tier names "ALRT 20 / 40 people" in your message are Group 20 and Group 50 in the repo. Prototype uses the repo names. Tell me if the names changed.
8. Learn topics, Family widget wording and the drill content are placeholders.

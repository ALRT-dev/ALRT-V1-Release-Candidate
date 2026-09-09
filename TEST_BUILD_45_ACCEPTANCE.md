# TEST build 45 — install, acceptance and paywall guide

Version **1.0.5 (45)**, commit **(the workflow run's head, printed below the build)**, branch `test`, dev flavour
(`com.safetyalrt.alrt.dev`, app label "[Dev] ALRT"), backend
`https://api-test.safetyalrt.com`. Two artifacts are built from the same
commit by `.github/workflows/android-test.yml`:

| Artifact | Billing mode | Build type | What it is for |
|---|---|---|---|
| `ALRT-android-test-apk-test_store` | RevenueCat Test Store (`ALRT_PLUS_TEST_UNLOCK=false`) | debug | Paywalls, purchase, restore, expiry: the real gates run against a sandbox store. No money moves. |
| `ALRT-android-test-apk-bypass` | billing bypass (`ALRT_PLUS_TEST_UNLOCK=true`) | release | Everything except billing. Every ALRT+ gate is open, so it must not be used to judge paywalls. |

Both are signed with the TEST keystore (SHA-1
`18:5E:43:9B:FC:7A:99:42:0C:AD:F0:EB:A9:E1:4F:0A:EE:66:2D:DB`), which the
workflow's apksigner step verifies on every run. They install beside the
production "ALRT" app, not over it, and they replace TEST builds 36 to 44.

## Prove which build you are holding

Profile tab, scroll to the bottom, under "Log out". The footer reads, for
example:

    ALRT 1.0.5 (45) · TEST build · <commit> · RevenueCat Test Store

or `… · billing bypass` on the bypass build. If the footer shows no commit
or billing mode, the phone is running an older build.

The footer proves the build number and commit, not the certificate. To
check the binary itself on a computer, unzip the artifact and run:

    sha256sum app-dev-debug.apk        # must equal the "APK file sha256" line in the workflow log
    apksigner verify --print-certs app-dev-debug.apk   # (Android build-tools) SHA-1 must be 18:5E:43:9B:FC:7A:99:42:0C:AD:F0:EB:A9:E1:4F:0A:EE:66:2D:DB
    keytool -printcert -jarfile app-dev-debug.apk      # works only when the APK carries a v1 signature

## Install

1. Download the artifact zip from the workflow run, unzip, copy the APK to
   the phone (or `adb install -r app-dev-debug.apk` / `app-dev-release.apk`).
2. Uninstall an earlier "[Dev] ALRT" only if the install is refused; build
   39 installs over 36, 37 and 38.
3. Open "[Dev] ALRT", sign in with a TEST account, confirm the footer above.

## Acceptance checklist (Family, palette, wording)

- [ ] Family tab: deep purple header, lavender page, compact header with
      circle name and a chevron that opens "Choose a circle".
- [ ] One green control labelled **Check in** (white text). When someone has
      asked you, it reads **Check in · lets <name> know**; the ask banner has
      no second button.
- [ ] Tap Check in → consent sheet → "Just check in" (white on green); the
      share button reads exactly "Check in and share my suburb" /
      "…my location" (no "too"). Toast
      **Checked in**. The member row on the other phone shows "Checked in
      just now" with no location.
- [ ] Sharing set to Approximate → "share my suburb too" sends a suburb label
      only. Precise → 1-hour pin, expiry shown on the row. Off / Alerts only
      → "Location hidden · …" and nothing is sent even from a check-in.
- [ ] Several people ask within the same day (two other phones tap Ask):
      the card reads "Amy, Tom requested a check-in" with both faces,
      "View 2 requests" opens the list with names and times, the button
      reads "Check in · lets Amy and Tom know", and one check-in clears
      both (both askers' trackers show you answered). Needs the TEST
      backend redeployed with rollout script revision 7 in
      `--no-new-migrations` mode (see the report, §36.6); on the older
      server only the newest asker is named.
- [ ] A request in a circle you do not have open shows under "Other
      circles" in that list, and in the Choose-a-circle sheet as
      "1 check-in request waiting on you"; Switch circle, then check in.
- [ ] Member row tap → details sheet (Ask to check in, Request location,
      Remove for the host).
- [ ] Choose-a-circle sheet: switch circles, "Add a person" (host only),
      "Join with code", "Create another circle" (ALRT+), "Manage all circles".
- [ ] Circle settings: name, three rules, picture, beacon colour.
- [ ] Dark mode and largest text size: nothing clipped, four tiles become
      two rows of two.
- [ ] Learn tab: no "0 of 20 guides done" card and no "This week" strip.
- [ ] Manage notifications → Categories: "types of ALRTs" in capitals.
- [ ] Map filter sheet: light background, opens to about half height,
      Security & crime pill clearly redder than Community.
- [ ] Unrelated screens (Home, Map, Search, Profile) look as before.

## Phone checklist for the seven issues (build 45, backend redeployed at the build-45 pin)

Run on the **test_store** APK. Two phones, A and B, synthetic TEST accounts
with names set is easier to read, but names are not required: an account
with no name reads "Family member" everywhere.

1. **SOS send.** A: Family › SOS tile › hold. Expected: tick for about a second, then Family by itself with the red "Your SOS is active" strip; Open shows "Your SOS" with "I'm safe". Airplane mode on A before the hold, then off: one SOS only (the app asks the server before any retry), an error toast if the send truly failed.
2. **SOS stand-down and recipients.** A taps "I'm safe": back on Family with the toast "Your SOS has ended. Your circle has been told"; no "marked safe" page opens on A. B: strip names A; a tap on the top banner or on the push opens A's SOS; after stand-down B's open screen reads "has ended"; B's strip goes. Kill and reopen B: the ended SOS does not come back. Raise an SOS from B while A's is live: two strips, each named.
3. **Notifications vs filters.** ALRT Filters: turn Global humanitarian off: GDACS squares vanish from the map AND the feed; Official off hides state, humanitarian and Intel alerts; restart the app: still the same on both tabs. Manage notifications › Categories: switch Advice off, restart: still off (never reset). Push table: `TEST_BUILD_45_ACCEPTANCE.md` § matrix below.
4. **Map details.** Map › rail › Map details: light sheet about three-quarters high, map visible above, list scrolls inside, Done above the navigation bar; largest text and a small phone: same; dismiss by swipe and by Done; reopen.
5. **Check in from an alert.** Open a community report and an official alert without "What to do": both show "Near this alert? Let your family know you are okay." with "To <circle>" / "change circle". Check in: consent sheet, toast, the alert stays open. B: Family › tap A's row: the sheet reads `Checked in near "<alert title>"`. With no circle: the strip points to Family.
6. **Leave a circle.** Member of two: Circle settings › Leave: toast "You left <name>.", the other circle opens. Host with members: toast says the circle has 7 days to choose a host. Last member: toast says the circle was deleted. Airplane mode then Leave: error toast, circle still there; online again: Leave works. After leaving, nothing of that circle shows anywhere.
7. **Vibration.** Profile › Safety profile › Strong vibration on: "Test vibration" posts "Test: urgent alert vibration" with the long pattern. Off: the row goes. Restart with it on: a synthetic take-action push (an admin test alert in an area you saved) vibrates long; with it off, normal. Block ALRT notifications in Android settings: Test vibration says so. In-app haptics (button taps) are unrelated to this switch.
8. **Saved location and ALRT+ (test_store build).** Search tab › a suburb › Subscribe: first one saves ("Saved <name>…"). A second suburb › Subscribe: the "One free saved location" sheet, See ALRT+ opens the paywall headed "Save every place that matters" with real Test Store plans; Maybe later: back on Search, nothing saved, no error; decline the store dialog: paywall stays with no error; approve: the second location saves on the same screen without a restart; Manage locations lists both. Restore purchases on a free account: "No previous ALRT + purchase found."; on a subscribed account reinstalled: entitled again.

## What is proven where (build 45)

Three separate columns; nothing in one column counts for another.

| Issue | Automated (this environment) | TEST server | Phone |
|---|---|---|---|
| 1 SOS navigation, duplicate sender screen, stale/duplicate events | `family_sos_flow_test.dart` (9): lost answer found on the server, no second SOS, stand-down reports truthfully, a replayed familySos never revives an ended SOS, events for a departed circle ignored, a server refresh ends a stale SOS, a bare lapse payload parses. Backend `verify_family_leave_and_alert_link` §2: live SOS listed across circles. | after redeploy: inside `verify` | items 1 and 2 |
| 2 Notifications, map and feed alignment | `hazard_visibility_util_test.dart` (+4): Global humanitarian / ALRT Intel / Official switches on the map, AWS levels by official severity; `hazard_filters_persistence_test.dart` (4); backend `verify_alert_filter_matrix` (56): the table below; `verify_push_notification_settings` (14+2): defaults never overwrite opt-outs, switches enforced, urgent channel routing, cooldown exemption | after redeploy: inside `verify` | item 3 |
| 3 Map details light three-quarter sheet | screenshot scene 15 (real widget) | n/a | item 4 |
| 4 Check in from every alert, alert link stored and shown | backend `verify_family_leave_and_alert_link` §3 (5): bad id refused, real alert stored, named in the list; screenshot scene 18 (member sheet "Checked in near …"); `family_check_in_requests_test.dart` (5) | after redeploy | item 5 |
| 5 Leaving a circle | `family_leave_circle_test.dart` (4); backend §1 (5): left / hostTransition / deleted outcomes, no memberless circle, departed member gets 404 | after redeploy | item 6 |
| 6 Vibration | `accessible_alerts_preference_test.dart` (5): preference in device storage, explicit choice wins, off/on/on; channel calls and the pattern itself are hardware | n/a | item 7 |
| 7 Saved-location paywall | `saved_location_gate_test.dart` (5): one free, second needs ALRT+, ALRT+ removes the limit; screenshot scenes 09, 17. **Not automated**: the RevenueCat offering and a Test Store purchase (needs the dashboard and a phone) | server enforcement is OFF on TEST (`BILLING_ENABLED=false`): the free limit is a client gate only, stated, not hidden | item 8 |
| Global humanitarian / ALRT Intel push switch; source push policies enforced; onboarding three-way choice | **not done**: needs the decisions listed in the report (schema and policy) | not done | not done |

## Alert filter / push matrix (server, from `verify_alert_filter_matrix`, 56 checks)

For a user whose saved location covers the alert. "shown" = returned by
the list endpoint the map and feed use; "push" = a push is sent.

| Alert kind | all on | Emergency off | Watch & Act off | Advice off | Official off | Community off | Community only |
|---|---|---|---|---|---|---|---|
| AWS Emergency Warning | shown / push | hidden / no push | shown / push | shown / push | shown / push | shown / push | hidden / no push |
| AWS Watch & Act | shown / push | shown / push | hidden / no push | shown / push | shown / push | shown / push | hidden / no push |
| AWS Advice | shown / push | shown / push | shown / push | hidden / no push | shown / push | shown / push | hidden / no push |
| AWS Info level | shown / push | shown / push | shown / push | hidden / no push | shown / push | shown / push | hidden / no push |
| Official (state agency) | shown / push | shown / push | shown / push | shown / push | hidden / no push | shown / push | hidden / no push |
| Community report | shown / push | shown / push | shown / push | shown / push | shown / push | hidden / no push | shown / push |
| Global humanitarian (GDACS) | shown / push | shown / push | shown / push | shown / push | hidden / no push | shown / push | hidden / no push |
| ALRT Intel (shield) | shown / push | shown / push | shown / push | shown / push | hidden / no push | shown / push | hidden / no push |

App-side, on top of the server: the Global humanitarian and ALRT Intel
filter switches hide those two rows on the map and in the feed (build 45
made the map honour them; before, only the feed did). There is no push
switch for them: they push under Official. Browsing the map never writes
a saved location or a push preference; only a GPS fix updates the
automatic own-location follow. Family check-ins and SOS are private
circle events and bypass these switches by design.

## Paywall matrix (test_store build only)

The client decides every gate from RevenueCat's entitlement `plus`; the
TEST backend has `BILLING_ENABLED=false`, so the server never refuses a
request on billing grounds. That is by design for TEST and means the
matrix below exercises the app's own gates, which are the ones a user sees.

Prerequisites in the RevenueCat dashboard (TEST project, Test Store):
an offering marked current with a monthly and an annual package attached
to the `plus` entitlement. A free trial is shown only if the Test Store
product has an introductory offer; otherwise the button reads "Continue"
and nothing claims a trial.

| # | State | How to get there | Expected on device |
|---|---|---|---|
| 1 | Free, never subscribed | Fresh TEST account | Profile ALRT+ card offers upgrade; Family "Create another circle" opens the host-a-circle sheet then the paywall; saving a 2nd location opens the saved-location sheet then the paywall; inviting past the seat cap shows the seats-full sheet. Joining a circle with a code is never gated. |
| 2 | Paywall, no store | Blank RevenueCat key (bypass build) | Not applicable on this build; the paywall would show "unavailable". |
| 3 | Purchase success | Paywall → pick a plan → Continue / Start trial → Test Store dialog → approve | Welcome screen, then every gate above is open. Profile card shows Manage. No prompt on any later ALRT+ action. |
| 4 | Purchase cancelled | Same, decline in the Test Store dialog | Back on the paywall with no error, still free (a cancel is not an error). |
| 5 | Purchase failed | Test Store dialog → simulate failure | A specific message on the paywall (network, not available, not allowed, or "could not be completed (<code>)"), still free. |
| 6 | Trial | Only if the Test Store product carries an intro offer | Button "Start 14-day free trial" (read from the product), trial dates on Manage. |
| 7 | Subscriber, second device / reinstall | Reinstall, sign in as the same user | Entitlement restored on sign-in (RevenueCat app user ID = ALRT user ID). "Restore purchases" reports success. |
| 8 | Restore with nothing to restore | Free account → Restore purchases | "No previous ALRT + purchase found." |
| 9 | Expired / cancelled-and-ended | RevenueCat dashboard → the customer → refund or revoke the Test Store transaction (or let the sandbox renewal lapse) | Profile card routes to the "back on the free plan" screen, gates return, no billing banner. |
| 10 | Billing issue | Dashboard → simulate a billing issue on the transaction, if the Test Store offers it | Amber billing banner on Family; gates stay open until the entitlement ends. |

Record pass/fail, the account and a screenshot per row. Rows 6, 9 and 10
depend on what the Test Store lets you simulate; if a control is missing,
record "not simulable in Test Store" rather than pass.

## Not to do on TEST

No production deployment, store upload, billing change, extra migration or
rollback. Scheduled jobs stay OFF. The live Google key stays as configured.

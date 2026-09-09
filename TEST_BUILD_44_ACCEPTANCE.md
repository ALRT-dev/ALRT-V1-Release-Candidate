# TEST build 44 — install, acceptance and paywall guide

Version **1.0.5 (44)**, commit **(see the workflow run)**, branch `test`, dev flavour
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
production "ALRT" app, not over it, and they replace TEST builds 36 to 43.

## Prove which build you are holding

Profile tab, scroll to the bottom, under "Log out". The footer reads, for
example:

    ALRT 1.0.5 (44) · TEST build · <commit> · RevenueCat Test Store

or `… · billing bypass` on the bypass build. If the footer shows no commit
or billing mode, the phone is running an older build.

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

## Phone checklist for the six 9 September issues (build 44, backend at 1aee3d4 or later)

1. **SOS send and stand-down.** Phone A: Family › SOS tile › hold. Expected: green tick for about a second, then the Family screen by itself with the red "Your SOS is active" banner and Open. Open shows "Your SOS" with the "I'm safe" button. Tap it, confirm: back on Family with the toast "Your SOS has ended. Your circle has been told." No "marked safe" page opens on phone A. Phone B: the red strip names phone A's person, Open shows "<name> triggered SOS" with the response buttons; after stand-down it reads "<name> is marked safe" only if B is already on that page, otherwise B's screen is left alone. Repeat twice; then raise an SOS from B while A's is live (two banners, each named).
2. **Notifications vs filters.** Manage notifications › Categories: the five switches now read Emergency Warning, Watch & Act, Advice, Official, Community; a fresh TEST account shows them ON. ALRT Filters (map or feed): turn Community off, switch tabs, restart the app: still off on both, and the Map details sheet has no second set of toggles, only a link to ALRT Filters.
3. **Map details.** Map › rail › Map details: opens to about three-quarters, map visible above, list scrolls inside, Done stays above the navigation bar. Largest text size: same.
4. **Check in from an alert.** Open a community report, then an official alert with no "What to do" section: both show "Near this alert? Let your family know you are okay." with "To <circle>" (and "change circle" when you have two). Check in: consent sheet, then toast; the alert stays open. With no circle: the strip says to join or create one and links to Family.
5. **Leave a circle.** Member of two circles: Circle settings › Leave: lands on the other circle at once. Member of one: lands on the create/join screen. Airplane mode then Leave: an error toast, the circle still there; back online, Leave works.
6. **Vibration.** Profile › Safety profile › Strong vibration on: a "Test vibration" row appears; tap it: a notification "Test: urgent alert vibration" arrives with the long pattern. Switch off: the row disappears. Notifications blocked in Android settings: the tap says so instead of pretending.

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
| 4 | Purchase cancelled | Same, decline in the Test Store dialog | Back on the paywall with no error, still free. |
| 5 | Purchase failed | Test Store dialog → simulate failure | "That purchase could not be completed." on the paywall, still free. |
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

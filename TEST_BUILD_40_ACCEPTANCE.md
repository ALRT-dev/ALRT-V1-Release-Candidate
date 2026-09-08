# TEST build 40 — install, acceptance and paywall guide

Version **1.0.5 (40)**, commit **(see the workflow run)**, branch `test`, dev flavour
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
production "ALRT" app, not over it, and they replace TEST builds 36 to 39.

## Prove which build you are holding

Profile tab, scroll to the bottom, under "Log out". The footer reads, for
example:

    ALRT 1.0.5 (40) · TEST build · <commit> · RevenueCat Test Store

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
- [ ] Tap Check in → consent sheet → "Just check in" (white on green). Toast
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
      backend at this commit or later; on the older server only the
      newest asker is named.
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

# TEST build 49 — install, acceptance, notification delivery, widget and pricing guide

Version **1.0.5 (49)**, commit **(the workflow run's head, printed below the build)**, branch `test`, dev flavour
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
production "ALRT" app, not over it, and they replace TEST builds 36 to 48.

## Prove which build you are holding

Profile tab, scroll to the bottom, under "Log out". The footer reads, for
example:

    ALRT 1.0.5 (49) · TEST build · <commit> · RevenueCat Test Store

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

## Before any checklist: confirm what is installed and what is deployed

Write these four facts down first; nothing below is judged without them.

1. **Installed build**: Profile footer, e.g. `ALRT 1.0.5 (49) · TEST build · <commit> · RevenueCat Test Store`. The build number and commit come from the footer, never from how a screen looks. Failures reported before this footer read build 49 were seen on an earlier build. Build 48 added the store price wording; build 49 adds three small fixes found by the new screen tests on a 360 px phone (the paywall's Terms · Privacy links wrapped off screen, three manage-screen rows clipped) and clears the phone's widget, store identity and Ask ALRT session on account deletion, as sign-out already did.
2. **Billing mode**: the footer's last word (`RevenueCat Test Store` on the test_store APK, `billing bypass` on the other). Paywall items count only on the test_store APK.
3. **App code**: the commit in the footer must equal the app commit named in the handover for build 48. The backend pin for the rollout may be a different commit on the same branch; the handover names both.
4. **Deployed TEST backend**: **f1f6b92**, deployed 9 September 2026 23:37Z and fully verified 10 September 00:02:59Z (run `run-20260909233730-629825`, image `sha256:9be0d3e4…f959bd`, 40/40 consent checks and twelve regression scripts across the original run and the `--resume` recovery, health OK, zero restarts, scheduler OFF). The app and the backend are the same commit for build 49. Before it, TEST was verified at **6a1115f** (the build-46 pin) on 9 September 2026, run directory `run-20260909042910-293693`, image `sha256:95fe66e1…a65cb`, 40/40 consent checks and ten regression scripts passed, scheduler OFF. Everything from builds 43 to 46 is therefore live on TEST. What is **not** yet on TEST is only the build-47 backend delta (below) plus the dedupe fix; until that rollout, the items marked "needs redeploy" run against the build-46 server.

**Backend delta since the verified baseline (6a1115f → the build-47 pin):** `notification.service.ts` (safe hazard payload without coordinates or reporter fields, `urgent` in push data, private Android visibility, APNs sound and interruption level, dead-token pruning, one push per person per hazard event with tray collapse keys), `family.service.ts` (`urgent` and hazard-event dedupe on `notifyCircle`, SOS body wording), `family_alert.service.ts` (place bodies, safe hazard payload, hazard-event dedupe), `notification.controller.ts` / `notification.route.ts` / `notification.validator.ts` / `push_notification_types.ts` (`POST /api/notifications/test`, `DELETE /api/notifications/push-notification-token`), verification scripts `verify_family_push_delivery` (11) and `verify_hazard_push_dedupe` (7), rollout script revision 12. No migration, no schema change, no scheduler change, no policy or opt-out change.

## Phone checklist for the twelve items (build 49; unchanged from 47 except item 10)

Run on the **test_store** APK. Two phones, A and B, synthetic TEST accounts. Record each item as one of: **phone-tested pass**, **phone-tested fail** (with what you saw), **awaiting device acceptance**, **blocked** (say by what). Automated results never fill a phone column.

1. **SOS send returns to Family.** A: Family › SOS tile › hold 3 s. Expected: tick for about a second, then the Family tab by itself with the red "Your SOS is active" strip at the top and Open. Tap Done during the tick: same place, and the timer does not move you again. Airplane mode before the hold: red error toast, still on the send screen, no SOS on B. Airplane mode switched on *during* the hold (lost answer): at most one SOS, found on the server, no second one on a retry.
2. **Sender never sees a recipient screen.** A taps Open › "I'm safe": Family with the toast "Your SOS has ended"; no "<name> is safe" page on A. If the stand-down call fails, A sees "Could not end your SOS" and the SOS stays live. Kill and reopen A while an SOS is live: strip present, no screen opens by itself. B: banner or push opens A's SOS; after stand-down B's open screen reads "has ended"; kill and reopen B: the ended SOS does not come back and no old push tap revives it.
3. **Home-screen widget.** Add the "[Dev] ALRT" Family widget (long-press the launcher). Walk the six states and compare with the previews sent with the handover: (a) no requests: "No pending requests", one row per circle, "1 of 2 checked in today" style honesty, never "everyone is safe"; (b) B asks A to check in: amber row "Check-in requested" for that circle, headline in amber, tap opens the check-in flow for that circle (consent sheet, nothing sent by the tap); (c) asks in two circles: "2 circles asked you to check in", one row each, no duplicate rows; (d) A's SOS: solid red card "Your SOS is active", tap opens that SOS; (e) B's SOS: red card "SOS active · <circle>", no member name; (f) sign out: "Signed out". Also: leave a circle → its row goes; restart the phone → the card shows "Updated h:mm"; leave the phone for an hour with the app closed → "As of h:mm · open ALRT". Long circle names and the largest text size: nothing clipped. Widget rendering on iOS is **not built** (the widget target is not in the Xcode project): record blocked.
4. **Map details everywhere.** Map › rail › Map details, and the Around-you sheet's details link: the same light three-quarter sheet, map visible above, map type selector, internal scroll, Done above the navigation bar. The badge on the rail equals the number of filters switched off. The old "Keys" button and dark keys sheet are gone.
5. **Check-in strip on every alert.** Open one of each: community report, official alert, AWS warning, Global humanitarian (GDACS), ALRT Intel. Each detail screen shows "Near this alert? Let your family know you are okay." with "To <circle>" / "change circle"; no alert kind lacks it. Check in: consent sheet, toast, the alert stays open; nothing is sent without the consent tap. No circle: the strip points to Family and nothing is sent. While the circle is still loading the strip says so instead of offering a wrong circle.
6. **Check-in visibility and map privacy (two phones).** A checks in "Just check in": B sees "Checked in just now" and no location. A with Approximate: B sees the suburb only. A with Precise: B sees a pin that expires after an hour. A with Off / Alerts only: nothing. A member of a circle A did not select for the check-in sees nothing.
7. **Notification settings vs map and feed.** ALRT Filters: Global humanitarian off hides GDACS on the map and feed; restart: still hidden. Manage notifications › Categories: Advice off survives a restart. Known gaps (unchanged, need decisions): Global humanitarian and ALRT Intel push under Official; source push policies are not enforced on delivery; onboarding "User reported" turns Emergency off.
8. **Leaving a circle does not hang.** Member of two: Leave › toast "You left <name>." and the other circle opens within seconds. Host with members: toast about 7 days to choose a host. Last member: circle deleted toast. Airplane mode then Leave: error toast, still a member. After leaving: no rows, strips, banners, widget rows or SOS from that circle anywhere; a check-in ask from it after leaving never appears.
9. **Vibration.** Profile › Safety profile › Strong vibration on › Test vibration: the long pattern. Off: the row goes. Notifications blocked in Android settings or Do not disturb on: the card says so and offers Open phone settings. In-app button haptics are unrelated.
10. **Saved-location paywall and prices (test_store).** The plan cards, the line under Subscribe and Manage must all show the same store amount with its currency code beside a bare "$" (see "Prices and currency" below). Second suburb › Subscribe › "One free saved location" › See ALRT+ › plan › approve the Test Store dialog: the second location saves once on the same screen with no restart. Decline: nothing saved, no red message. Airplane mode: "No connection…". Subscriber: never asked again; two quick taps save once. Restore on a free account: "No previous ALRT + purchase found." Server enforcement is OFF on TEST; the app's gate is what you are testing.
11. **ALRT+ benefits.** Paywall, Profile › ALRT+ Manage, and the expired screen all show the same "Free versus ALRT+" table: saved locations 1 vs unlimited, hosting circles 0 vs 4, seats 8, joining with a code always free. Prices, periods and trial words come from the store; nothing else is promised.
12. **Notification delivery.** See the next section; record its table separately.

## Item 12: notification delivery, lock screen, sound and vibration

Nothing in this section is marked passed from Firebase acceptance, mocked tests or screenshots. Only a phone that received, displayed, sounded, vibrated and opened the right screen counts, one row per event kind.

**How each push is decided (trace, for the record).** Alert created → server eligibility (saved-location coverage, category switch, source policy, cooldown; `verify_push_notification_settings`, 15 checks) → `sendPushNotificationToUser` builds one FCM message with both a `notification` block (so Android and iOS display it even with the app closed) and a `data` block (`notificationType`, `payload`, `urgent`) → Android channel `alrt_alerts` or `alrt_alerts_urgent` (urgent only when the server marks it urgent: SOS start, needs-help, take-action alerts), visibility **private** so the lock screen never shows the body's details on a locked phone with sensitive content hidden → iOS `sound default`, interruption level time-sensitive for urgent → tap → `NotificationService` routes by `notificationType` (hazard → the alert; SOS → that SOS if still live, otherwise Family; check-in request → the roll call; check-in response → Family; test → the Profile tab it was sent from). Dead tokens are pruned on `UNREGISTERED`; sign-out deletes the token on the server before the session ends (4 s cap), so a signed-out phone stops receiving; leaving a circle removes it from that circle's recipients on the server.

**Test action.** Profile › Manage notifications: the card at the top shows the permission state (allowed / denied with Open phone settings / provisional on iOS) and has **Send a test notification** (urgent when Strong vibration is on). It only proves the token, the channel and the display; it never proves a real alert's eligibility. Needs the build-47 backend delta on TEST (the endpoint is not in 6a1115f).

**Device acceptance matrix.** For each event kind, run the five app states and fill every column separately. Hardware columns stay "untested" until you felt or heard it.

| Event | App state | Eligible (server log) | Provider accepted (FCM id) | Received on phone | Shown on lock screen (no precise location, no safety profile) | Sound | Vibration | Tap opens | No duplicate |
|---|---|---|---|---|---|---|---|---|---|
| Test notification | foreground / background / locked / closed / offline-then-online | | | | | | | Profile tab | |
| Public alert in a saved area (Advice) | same five | | | | | normal | normal | that alert | one per alert (a second copy from the family-proximity path is a known defect, see below) |
| Public alert, take-action | same five | | | | | | strong when Strong vibration is on | that alert | |
| Check-in request from B | same five | | | | | | | roll call for that circle | |
| Check-in response from A | same five | | | | | | | Family | |
| SOS started by B | same five | | | | urgent channel | urgent | strong | that SOS | one per SOS; an ended SOS never reopens |
| SOS stand-down | same five | | | | | | | Family, reads "has ended" | |

Also record: notifications denied in Android settings (the card explains, Open phone settings works, nothing is silently dropped in-app); sound off / vibration off in the phone's channel settings (the app does not delete and recreate channels to override the choice); Do not disturb (urgent channel may or may not break through, record what happened); force-stopped app (Android delivers nothing to a force-stopped app by design: record as blocked-by-platform, not as failure).

**Handling by payload type and app state (trace, for the record).** Every push the server sends carries both a `notification` block and a `data` block (`notificationType`, `payload`, `urgent`); there is no data-only push anywhere in the backend. So: *foreground* — FCM hands the message to the app (`onMessage`), which draws it itself on the ordinary or urgent channel with the event's stable id (a repeat replaces, never stacks), and a tap routes by `notificationType`; *background* — the system draws it from the `notification` block on the channel the server named, and a tap arrives through `onMessageOpenedApp`; *closed* — the system draws it, and the tap that launches the app is read once through `getInitialMessage` and never replayed on a rebuild; *locked* — the system draws it with private visibility, so the phone's own lock-screen setting decides whether the text shows; *offline then online* — FCM holds the message and delivers it on reconnect, and an SOS tap then asks the server before opening anything, so an ended SOS reads "has ended". **Background handler decision:** a `onBackgroundMessage` handler is only needed for data-only pushes; none exist. Registering one that draws a local notification would produce the very duplicate this item forbids, because the system already draws the `notification` block. No handler is added; the requirement holds without it.

**Duplicate delivery, fixed in the build-47 backend delta:** one accepted hazard could reach a person twice, through a saved area covering it and through a circle with a member or saved place near it (and a circle with two nearby places sent one per place). The server now claims one push per person per hazard **event** across every path (the first path to reach a person sends, the others skip that person), keeps the claim for 48 hours in the cache (in-process when there is no cache), keys it by event rather than by hazard so a genuine later event is still sent, and stamps every hazard push with a tray key (Android tag, APNs collapse id) so a copy that still gets through replaces rather than stacks. `verify_hazard_push_dedupe` proves all of that (7 checks). On the phone: expect exactly one notification per alert, whichever paths qualify you.

**Still not fixed, listed so they are not mistaken for phone errors:** iOS has no time-sensitive entitlement (urgent pushes arrive as ordinary alerts on iOS); the iOS widget target is not in the Xcode project; account deletion now clears the widget, the store identity and the Ask ALRT session (build 49).

## Home-screen widget: what the previews prove and do not prove

The two preview images (`20_widget_previews.png`, `21_widget_previews_large_text.png`) are Flutter replicas of the Android layout drawn from the exact payload the app writes (`FamilyWidgetModel.build`), so they prove the words, the ordering (SOS › requests › waiting › ordinary), the colours, the glyphs and that no member name, location or safety-profile detail is in the payload (`family_widget_model_test.dart`, 13 checks; `family_widget_previews_test.dart` asserts the six headlines). They do not prove the launcher's rendering; that is item 3 above, on the phone. Updates are written after every family event, sign-out, restart and reconnect; the freshness line is the honest signal when the platform stopped redrawing.

## Check-in strip: coverage of every alert kind

Only one screen renders alert details, `ViewHazardScreen`; every route (feed, map marker, search result, push tap, widget tap, saved-location list) lands there. The strip is a fixed part of that screen, so all five alert kinds get it. `family_safe_strip_test.dart` renders the strip with a complete screen for each kind: community report, official, AWS warning, Global humanitarian, ALRT Intel, plus change-circle, no-circle and loading states, and asserts that no check-in is sent by a tap without the consent sheet.

| Alert kind | Renderer | Strip | Entry points that reach it |
|---|---|---|---|
| Community report | ViewHazardScreen | yes | feed, map, search, push, widget |
| Official (state agency) | ViewHazardScreen | yes | feed, map, search, push, widget |
| AWS warning (Emergency / Watch & Act / Advice) | ViewHazardScreen | yes | feed, map, search, push, widget |
| Global humanitarian (GDACS) | ViewHazardScreen | yes | feed, map, push (under Official) |
| ALRT Intel | ViewHazardScreen | yes | feed, map, push (under Official) |

## Map details: one implementation

Entry points: the Map rail's "Map details" button and the Around-you sheet. Both open `MapDetailsSheet` (light, three-quarter height, map visible above, map-type selection, internal scroll, Done). The old Keys button, the dark keys sheet and the second copy of the visible-systems logic were deleted; the rail badge and the marker filter now read the same filter provider as the feed.

## iOS: what is blocked and why (no change made)

The only iOS TEST path in this repository is `.github/workflows/ios-test-testflight.yml`: a dev-flavour (`com.safetyalrt.alrt.dev`) archive signed manually with certificates that fastlane match installs, exported with `ExportOptionsCI-dev.plist` (method app-store, team JR89M7CYPR, one profile: `match AppStore com.safetyalrt.alrt.dev`), uploaded to the "ALRT Dev" TestFlight app. GitHub reports no run of that workflow has ever been registered, so **no iOS TEST build exists**; every iOS item is blocked on producing one, not on code in this repo.

- **APNs environment.** `Runner-dev.entitlements` carries `aps-environment = production`. For the path above that is correct: a TestFlight build must use the production APNs environment, and the App Store profile match installs carries that value. It only reads as a mismatch for a direct Xcode debug run on a cable, where Xcode substitutes `development` itself. Not a defect; nothing to change.
- **Time-sensitive delivery.** The server asks for `interruption-level: time-sensitive` on urgent pushes. iOS honours that only when the App ID has the Time Sensitive Notifications capability and the entitlement `com.apple.developer.usernotifications.time-sensitive` is in the app's entitlements and profile. Neither is present for the `.dev` App ID. Adding it means a capability change in the Apple Developer portal, both entitlements files, and regenerating the match profile: that is a signing and capability change and needs your approval. Until then urgent pushes on iOS arrive as ordinary alerts (still with sound). **Blocked, by decision.**
- **Widget.** The WidgetKit sources and both entitlements files exist under `ios/AlrtWidget/`, but the extension target is not in `Runner.xcodeproj` (`SETUP.md` there gives the Xcode steps). Adding it also needs the App Group `group.com.safetyalrt.alrt.dev` registered on the `.dev` App IDs and a second match profile for `com.safetyalrt.alrt.dev.AlrtWidget`, and the export options updated. Xcode and portal access are required; CI cannot do it. **Blocked.**
- **Production signing and capabilities**: untouched.

## RevenueCat TEST offering: what to screenshot

No read access exists from this environment: there is no RevenueCat key of any kind here, the backend holds only the webhook shared secret, and the REST API needs a secret key that must not be pasted into chat. A rebuilt APK or the mocked paywall tests cannot stand in for the configuration. Please screenshot these screens in the RevenueCat dashboard (TEST project, the one whose public Google key is in the repository secret `TEST_REVENUECAT_API_KEY_GOOGLE`); mask any key values:

1. **Product catalog › Offerings**: the list, showing which offering is marked **Current** and its package count.
2. **That offering › Packages**: each package (monthly and annual expected) with the product attached to it and the app/store column reading **Test Store**.
3. **Product catalog › Entitlements › `plus`**: the attached products (both Test Store products must be listed).
4. **Product catalog › Products**: the two products with their store shown as Test Store, and their status.
5. **Project settings › Apps**: the Test Store app row, showing that it exists and which platform it is for (do not include the key).
6. After one attempt on the phone: **Customers › the test account › Customer history**: the events around the attempt (offering fetched, purchase started, any error), which will place the failure point.

If screen 1 shows no current offering, or screen 2 shows packages without a Test Store product, the paywall's "no plans" or "could not load" message is the configuration, not the app.

## Prices and currency on the paywall (builds 48 and 49)

**Where the USD comes from.** On the test_store APK every amount on the paywall is the store's own formatted string and currency code, read from the RevenueCat offering at the moment the screen opens; nothing on that path is hard-coded. The RevenueCat **Test Store** is not a real storefront: each Test Store product carries the one price and currency entered for it in the RevenueCat dashboard (Product catalog › Products › the product › its Test Store price), and that same price is returned to every phone whatever country or Play account it has. USD there means the Test Store products were created with a USD price; it does not mean the app chose USD, and it says nothing about what Google Play will charge. The only hard-coded amounts in the app are the two preview cards on the **billing bypass** APK, now labelled `US$9.99` / `US$99.99` with "Preview prices in USD · billing bypass build only · not store prices"; they never appear on the test_store APK.

**What real Google Play does.** Play returns the price for the Play account's storefront country in that country's currency, formatted by Play: an Australian account sees the AUD base-plan price set in Play Console (Monetise › Subscriptions › the base plan › country pricing, either the auto-converted default or a manually set AUD amount), and the app shows exactly that. No AUD is hard-coded for any country and no conversion is done in the app. Note that Play formats AUD as a bare `$9.99` on an en-AU phone, which looks like USD; build 48 therefore prints the ISO code beside any amount whose string carries no letters (`$9.99 AUD`), on the plan cards, the line under the purchase button and the manage-screen summary, while an amount that already names its currency (`A$9.99`, `US$9.99`) is left as the store wrote it.

**Wording, all from the store (build 48, verified on a rendered 360 px screen in build 49):** plan cards show the store amount, then "AUD · per month" (code only when needed; period from the store's own period, else the package type); the line under Subscribe reads "<trial>, then $9.99 AUD a month" for the selected card; Profile › ALRT+ › Manage reads "Monthly · $9.99 AUD a month · renews 9 Oct 2026" once the store answers, and just "Monthly · renews …" when it does not (never a made-up figure). `store_price_test.dart` (9) pins these rules; `alrt_plus_store_price_screens_test.dart` (4) renders the real paywall and manage screen against a fake store that answers like Google Play for an Australian account and checks the cards, the line under the button (which follows the selected card), the manage summary, the no-price fallback and a clean layout at 1.4× text; both monthly and annual go through the same code. Golden scenes 22–24 show the rendered screens.

**To verify the AUD price for Australian testing** (needs no code and no change to live prices):

1. Test Store (what the TEST APK shows): RevenueCat dashboard › Product catalog › Products › `alrt_plus_monthly` and `alrt_plus_yearly` › the Test Store price and currency fields. If they read USD, the paywall will read USD on every phone. Changing them to AUD amounts is a dashboard configuration change to the TEST project only; I have not made it and will not without your approval.
2. Real Play pricing (what a released build shows): Play Console › Monetise › Subscriptions › each base plan › Australia row: the AUD amount there is the one an Australian account will see, and whether it is auto-converted from USD or set by hand. Production, not touched.
3. On the phone, after either change: the plan cards must show the store's amount with `AUD` beside it, the line under the button the same amount, and Manage the same amount after a Test Store purchase. If the three disagree, that is an app defect; if they agree but are not the AUD figure you expect, that is the store configuration.

## What is proven where (build 47)

Three separate columns; nothing in one column counts for another. "TEST server" reads "not deployed (build-47 delta)" for what is beyond the verified 6a1115f baseline; everything from builds 43 to 46 is live.

| Item | Automated (this environment) | TEST server | Phone |
|---|---|---|---|
| 1 SOS returns to Family | `family_sos_screen_navigation_test.dart` (5, through a real router on a 360×780 phone surface: leaves by itself after the server confirms, Done leaves once and the timer never navigates again, a failed send shows an error and stays, a lost answer is found on the server and sent once, a second hold in flight sends nothing extra); `family_sos_flow_test.dart` (9) | build-46 server suffices | item 1 |
| 2 No recipient screen for the sender | `family_sos_flow_test.dart`; `family_sos_authorization_test.dart` (mine across circles); receiver screen keeps sender wording while standing down and reports a failed stand-down | build-46 server suffices | item 2 |
| 3 Widget | `family_widget_model_test.dart` (13); previews for six states + stale marker, normal and large text | n/a | item 3 (Android); iOS blocked |
| 4 Map details | screenshot scene 15; filter badge and marker filter share `providerOfHazardFiltersForMap` | n/a | item 4 |
| 5 Check-in strip on every alert | `family_safe_strip_test.dart` (9: five kinds, change circle, no circle, loading, no auto send); coverage table above | live since 6a1115f (alert title stored and shown) | item 5 |
| 6 Check-in visibility and map privacy | backend privacy scripts (build 41) unchanged; selected-circle scope unchanged | deployed since 74bd770 | item 6 |
| 7 Notification settings alignment | `hazard_visibility_util_test.dart`, `verify_alert_filter_matrix` (56), `verify_push_notification_settings` (17) | live since 6a1115f | item 7; gaps need decisions (pending, unchanged) |
| 8 Leave a circle | `family_leave_circle_test.dart` (4); backend `verify_family_leave_and_alert_link` §1 | live since 6a1115f | item 8 |
| 9 Vibration | `accessible_alerts_preference_test.dart` (5); channel routing by `urgent` in `local_notification_service` | n/a | item 9 (hardware untested) |
| 10 Saved-location paywall | `saved_location_flow_test.dart` (6), `revenuecat_service_test.dart` (10), `saved_location_gate_test.dart` (5); backend `verify_saved_location_limit` (3 off / 5 on) | enforcement OFF on TEST, stated | item 10; offering configuration unverified |
| 11 ALRT+ benefits | `alrt_plus_benefits_test.dart` (single source of truth for the limits; no invented benefit) | n/a | item 11 |
| 12 Notification delivery | backend `verify_family_push_delivery` (11: SOS start/stand-down/check-in request and response reach the right members with the right urgency, the sender is excluded, a departed member and a signed-out token get nothing, previews carry no coordinates, dead tokens are pruned, the test endpoint sends one message); `verify_stage11_blocker2_notification_payload` (data keys incl. `urgent`); `verify_hazard_push_dedupe` (7: one push per person per hazard event across saved-area and family paths, retry sends nothing, a later event still sends, tray keys, socket untouched) | not deployed (build-47 delta) | item 12 table; delivery, sound and vibration stay untested until observed |
| Global humanitarian / ALRT Intel push switch; source push policies; onboarding | **not done**: needs the decisions in the report | not done | not done |

## Issue 7 phone checklist: saved location and ALRT+ (test_store APK only)

Before anything else, write down three facts from the phone: the Profile footer text (build, commit, billing mode), whether the Profile ALRT+ card says Manage (subscribed) or offers an upgrade (free), and the account's email. Two synthetic TEST accounts: F (free, never subscribed) and S (subscribed through the Test Store during this checklist).

Configuration this checklist depends on, which cannot be verified from the code and needs its own approval to change: in the RevenueCat TEST project, an offering marked **current** with a monthly and an annual package (identifiers `$rc_monthly` and `$rc_annual`, or any others: the paywall now renders whatever the offering carries) whose Test Store products (`alrt_plus_monthly`, `alrt_plus_yearly` per `frontend/ALRT_PLUS_SETUP.md`) are attached to the entitlement **plus**; and the repository secret `TEST_REVENUECAT_API_KEY_GOOGLE` (present: the workflow refuses to build test_store without it; its value is never shown). If the paywall reads "ALRT+ plans could not be loaded" or "ALRT+ has no plans in the store yet" on a phone with network, the offering is the missing piece, not the app.

1. **Free user reaches the paywall at the approved limit.** As F: Search › a suburb › Subscribe: "Saved <suburb>…". Second suburb › Subscribe: the "One free saved location" sheet; See ALRT+ opens the paywall headed "Save every place that matters" with real plan cards and store prices. Maybe later: back on Search, nothing saved, no error toast. Manage locations lists one saved location plus My Location.
2. **Existing subscriber uses the allowance without another paywall.** As S (after step 3, or an account subscribed earlier): Subscribe on a second and a third suburb: each saves at once, no sheet, no paywall. Profile ALRT+ card says Manage.
3. **Successful test purchase unlocks the pending action.** As F: second suburb › Subscribe › See ALRT+ › pick a plan › Subscribe now (or Start trial) › approve the Test Store dialog: welcome screen (first host) or straight back, then the toast "Saved <suburb>…" without any restart, and Manage locations shows both. F is now S.
4. **Cancelled or failed purchase does not unlock.** A fresh free account: same path, decline the store dialog: the paywall stays with no red message; Maybe later: nothing saved. Airplane mode, then Subscribe now: "No connection…" on the paywall; back online it works. A product the store cannot sell: "This plan is not available in the store right now."
5. **Restore and restart keep the right entitlement; accounts do not leak.** As S: kill and reopen the app: Manage still shown, a further suburb saves. Restore purchases: entitled. Sign out, sign in as a free account on the same phone: the second suburb hits the sheet (no leaked entitlement); Restore purchases there: "No previous ALRT + purchase found." Sign back in as S: entitled again with no purchase prompt.

Joining a circle with a code stays free on every account above; hosting is a separate gate and unchanged.

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

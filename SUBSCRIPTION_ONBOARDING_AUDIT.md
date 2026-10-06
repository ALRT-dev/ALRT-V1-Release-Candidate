# ALRT + subscription, seats, paywalls and onboarding: TEST audit

> **Superseded target (28 September 2026).** The code findings below
> remain dated evidence about `ea93889`, but the commercial targets this
> audit measured against (A$9.99/A$99.99, 3 free saved places, 8 seats
> across 4 groups, a covered seat carrying every personal benefit) were
> replaced by the reconciled master specification. Current rules, what is
> now implemented and the external settings to change:
> `docs/V1_ACCESS_MODEL_IMPLEMENTATION.md`.

Audit date: 27 September 2026. Branch audited: `test` at `ea93889` (still the
tip of `test`; no newer commits were found). This report changes no app
behaviour, no service configuration and no production resource. Nothing was
uploaded to a store.

Three kinds of evidence are kept apart throughout:

| Label | Meaning |
|---|---|
| **Code** | Exists in this repository at `ea93889`. Read, not run on a phone. |
| **Deployed** | Proven live on the TEST API, TEST Admin, RevenueCat, App Store Connect or Play Console. |
| **Device** | Passed on a physical Android or iOS phone. |

**What this session could not reach.** The cloud session's network policy
refused connections to `api-test.safetyalrt.com` and
`alrt-v1-release-candidate.pages.dev`. It also has no access to the RevenueCat,
App Store Connect, Play Console, Firebase or Apple Developer consoles. So
nothing in this report upgrades any item to **Deployed** or **Device**. Where
your brief states something as verified (Admin 28 tests, build 51, Apple App
ID and profile), it is recorded as **reported by you, not rechecked here**.

---

## 1. Confirmed / missing / unverified

Status key: **OK** = code matches the rule. **CONFLICT** = code contradicts
the rule. **MISSING** = no code for the rule. **UNVERIFIED** = depends on
configuration or devices this audit could not see.

### 1.1 Subscription rules

| Rule | What the code does today | Status |
|---|---|---|
| Brand "ALRT +" with a space | 35 user-facing strings say `ALRT+`, 18 say `ALRT +`. The paywall headline, upsell sheets and benefits table mostly use `ALRT+`. Welcome, expired and restore messages use `ALRT +`. | CONFLICT |
| AUD $9.99 / $99.99 | The app shows store-returned prices only (`store_price.dart`), which is correct. The bypass-build preview cards say `US$9.99` / `US$99.99`. `ALRT_PLUS_SETUP.md` gives prices without a currency. Store prices are unverified. | Code OK, store UNVERIFIED |
| One-month free trial | `trial_copy.dart:7` fallback says "14-day free trial". `ALRT_PLUS_SETUP.md:27,35` tells whoever sets up the stores to configure **14 days**. Real trial text comes from the store product, which is correct. | CONFLICT (docs and fallback), store UNVERIFIED |
| Free: 3 Ask ALRT questions a day | `askalrt/functions/src/askalrt/askAlrt.ts:43` has `AI_DAILY_LIMIT = { free: 5, plus: 30 }`. Its comment says "do not reintroduce 3/20". `askalrt/README.md:24` says 3/20. | CONFLICT |
| ALRT +: 10 a day | Code gives 30. The expired screen promises "30 Ask ALRT questions a day (back to 5)" (`alrt_plus_expired_screen.dart:170`). | CONFLICT |
| RevenueCat handles the store; the intended authority is Firestore `entitlements` | There are three separate readers. (1) The **app** reads the RevenueCat SDK directly for every gate (`alrt_plus_provider.dart`). (2) The **backend** reads Postgres `User.plan`, written by its own webhook (`entitlement.service.ts`). (3) **Ask ALRT** reads Firestore `entitlements/{uid}`, written by a second webhook (`askalrt/.../entitlements.ts`). Firestore is only used for the Ask ALRT quota. Nothing treats it as the authority. | CONFLICT (decision D1) |
| 8 seats across up to 4 groups | `MAX_SEATS_TOTAL = 8` and `MAX_OWNED_CIRCLES = 4` (`family.service.ts:284-285`), checked at create and join. | OK |
| The payer's own membership uses a seat | `SEAT_FREE_ROLES = ["owner", "guest"]` (`family.service.ts:288`). The host's membership **never** uses a seat. The comment records a 3 September 2026 product-owner ruling that says so. The welcome screen still says "7 seats waiting" (`alrt_plus_welcome_screen.dart:74`), so the app contradicts itself too. | CONFLICT |
| One person in two groups uses two seats | Counted per (person, circle) pair. | OK |
| Joining costs the member nothing | The join path makes no entitlement check. | OK |
| Free users with no covered seat get no family features | A **guest** role exists: guests use no seat and get alerts and "I'm safe". SOS, check-ins, snapshots, journeys and SOS lists have **no entitlement check** on the server or in the app. The only paid checks are circle creation (server, when `BILLING_ENABLED=true`) and the app's hosting sheet. | CONFLICT |
| Seat-covered members get every benefit | The app decides from the member's **own** RevenueCat entitlement. The backend decides from the member's **own** `User.plan`. Ask ALRT decides from the member's **own** Firestore document. A covered member is therefore treated as free for saved places (limit 1), for Ask ALRT (5 a day) and for any future gate. | CONFLICT |

### 1.2 Access and location rules

| Rule | What the code does today | Status |
|---|---|---|
| Navigation is free; sharing a journey needs paid or covered access | Navigation is ungated. `POST /journeys` has no entitlement check. | MISSING (journey gate) |
| Saved locations: 3 free, unlimited with ALRT + | Frontend `kFreeSavedLocationsLimit = 1` (`alrt_plus_provider.dart:13`). Backend `FREE_SAVED_LOCATIONS_LIMIT = 1` (`location_subscription.service.ts:122`). Copy says "One free saved location". `V1_RELEASE_PLAN.md:59` said 1 (corrected in this commit). `V1_RECONCILIATION_REPORT.md` §11, §17.3 and §25.16 record 1 as the ruling. | CONFLICT |
| Snapshots are deliberate one-time shares and expire after 1 hour | `SNAPSHOT_TTL_MS = 1h`. `serializeMember` hides expired coordinates at read time. A 5-minute cron deletes them. **On TEST the cron is off** (`RUN_SCHEDULED_JOBS_IN_TEST=false`), so expired coordinates are hidden but not deleted there. A snapshot goes to the **whole circle**, including when you answer one person's request. | Code OK. Scope needs decision D14. TEST deletion MISSING |
| Live tracking needs the person's explicit opt-in (SOS and journeys too) | SOS `isLive` is required on every send (`family.validator.ts:172`). Journey `isLive` is opt-in and defaults off. | OK |
| Nobody can enable another person's sharing | Sharing level is only written through `PUT /members/me`. No host endpoint exists. | OK |
| SOS recipients must be chosen precisely (people and groups) | You can send to a saved SOS list, which may include people from several circles, or to the whole of one circle. Two defects: (a) `GET /sos/active` returns the event to **every member of the sender's circle**, including people who were left off the list. (b) List recipients in a **different** circle get 404 on respond and on the live trail, because `respondToSos` and `getSosTrail` call `requireMembership(userId, sos.circleId)` (`family.service.ts:2350, 2484`). You also cannot pick "these two groups" at send time. | CONFLICT |
| Automatic check-ins | Scheduled check-ins in `automatic` mode post "safe" for the member with no action from them (`family.service.ts:1869`). The member sets this up themselves, but family see "safe" even when nobody confirmed it. | Needs decision D13 |
| Scheduled check-in timezone | Fixed at Australia/Brisbane, UTC+10 (`family.service.ts:1741`). This is wrong for other states in daylight saving time and for any other country. | CONFLICT (for any worldwide use) |

### 1.3 Brand and paywall

| Rule | What the code does today | Status |
|---|---|---|
| Exactly three automatic paywall triggers: 4th saved location, sending location to family, sending an SOS | The actual triggers are: **2nd** saved location (`save_location_flow.dart`), **creating/hosting a circle** (`family_group_actions.dart:117`) and a manual Profile ALRT + card. A seats-full sheet and a circle-limit sheet are shown but do not open the paywall. **No** paywall exists for sending location or for SOS. | CONFLICT |
| The paywall must never appear during onboarding (current code comment) versus your proposed onboarding trial offer | `alrt_plus_paywall_screen.dart:28` says "never during onboarding". | Needs decision D8 |
| No em dashes in user-facing copy | 42 string literals contain an em dash. Examples: the hosting sheet, delete account, share text, family hub, SOS list edit, Ask ALRT fallback. | CONFLICT |
| "Your local emergency number", not a specific number | `emergency_number.dart` maps countries to 000, 911, 112 and so on. That number appears in the SOS screen ("call $emergencyNumber", `family_sos_screen.dart:459`), the Ask ALRT fallback and local answers. Onboarding disclaimer, emergency screen and Ask ALRT header already say "your local emergency number". | CONFLICT |
| SOS must not suggest it contacts emergency services | The SOS screen and Ask ALRT say it does not. The SOS response type `called` pushes "<name> is calling for help". That describes the responder's action, which is acceptable. | OK |
| "Alerts are always free" | The benefits table says "Official alerts, the map and emergency guidance never cost anything". This becomes false if the country restriction goes ahead. | Depends on D2-D7 |
| SOS live-share limit | `family_share_ending_screen.dart:119` says the SOS live share reaches its "1 hour limit". The backend cap is 4 hours (`SOS_MAX_DURATION_MS`). | CONFLICT (flag, not fixed) |

### 1.4 Service configuration and verification

| Item | Evidence | Status |
|---|---|---|
| TEST Admin updated, 28 tests pass | Reported by you | UNVERIFIED here |
| Android TEST 1.0.5+51 built (`test_store`) | Reported by you, and recorded in `TEST_BUILD_51_ACCEPTANCE.md`. Test Store is RevenueCat's virtual store. It proves nothing about Google Play billing, trials, eligibility or currency. | Built; Play billing UNVERIFIED |
| Device acceptance and push delivery | Nothing recorded as passed on a phone. | UNVERIFIED |
| Apple Dev App ID, app group, profile, ASC record, tester group | Reported by you | UNVERIFIED here |
| iOS signing key access and a TestFlight build | Outstanding | MISSING |
| Apple certificate/profile expiry (last seen 21 October 2026) | 24 days away. Could not recheck. | UNVERIFIED, **urgent** |
| Dev iOS Firebase identity | `firebase_options_dev.dart:66-70` reuses the **production** iOS app id with `iosBundleId: 'com.safetyalrt.alrt'`. `frontend/ios/Runner/GoogleService-Info.plist` is the production one. | CONFLICT |
| TEST Firebase isolation | TEST and production share Firebase project `alrt-a6539` by design (`backend/docs/TEST_ENVIRONMENT.md:28-33`). That design means TEST users' Ask ALRT quota and entitlement documents, the production `askAlrt` function and its AI spend, and FCM/APNs are all production resources. The TEST backend must hold a service-account key able to mint custom tokens for the **production** Firebase project. | CONFLICT with "credential isolation" |
| Scheduled jobs on TEST | `.env.test.example`: `RUN_SCHEDULED_JOBS_IN_TEST=false`. Snapshot purge, journey and SOS auto-end, and scheduled check-ins do not run on TEST unless someone turns them on. | Affects acceptance tests |
| `BILLING_ENABLED` on TEST | `false`. The server never refuses on billing grounds, so every paid rule on TEST is enforced by the app alone. | Must change for billing acceptance (D12) |
| Maps secret loader | `backend/src/utils/secrets.ts:22` defaults `SECRET_ID` to `safety-alert-prod/api-token`. It fills any env var that is **empty** (`if (process.env[key]) continue`), and `.env.test.example` leaves many values blank. The repo's `docker-compose.test.yml` does not mount the agent token, so the loader does nothing **as committed**. If the deployed TEST container can see `/var/run/awssmatoken`, TEST loads production secrets into every blank variable. The deployed state is unverified. | Latent risk; deployed state UNVERIFIED |
| RevenueCat project `15454f8d`: apps, products, `plus` entitlement, current offering, webhooks, secrets | Not visible from here. `ALRT_PLUS_SETUP.md:51` points the webhook at the **production** API. It documents only one of the two webhooks. | UNVERIFIED |
| Google Play subscription products | Your last check found none | MISSING (recheck) |
| Apple monthly/yearly products | Your last check found `MISSING_METADATA` | Incomplete (recheck) |
| TEST API, deployed database, AI prompt, credential isolation | Unreachable from this session | UNVERIFIED |
| Alert coverage | The TEST source script configures 11 sources: 6 Australian (NSW RFS, Live Traffic NSW, VicEmergency, QLD Fire, WA DFES, NSW SES), WAQI and Open-Meteo (both limited to Australia) and 2 global (USGS earthquakes, GDACS). There is nothing for SA, TAS, NT or ACT, and no national source for any other country. `Hazard` has no country field; only `HazardSource.country` exists, as free text ("Australia", "Global"). | Coverage is Australia-only in practice |

---

## 2. Contradictions in the webhook and entitlement path

Two consumers are registered: backend `POST /api/revenuecat/webhook` and
Ask ALRT's Cloud Function `revenuecatWebhook`. They are not consistent.

| Behaviour | Backend (`entitlement.service.ts`) | Ask ALRT (`entitlements.ts`) | Correct behaviour |
|---|---|---|---|
| `CANCELLATION` | Ignored (access continues) | Sets **free immediately** | Access continues to `expiration_at_ms`, except for a refund |
| Refund (`CANCELLATION` with `cancel_reason` `CUSTOMER_SUPPORT`, or an expiry in the past) | Ignored, so the user keeps plus until the stored expiry | Sets free | Deactivate when the expiry has passed |
| `BILLING_ISSUE` | Ignored (banner in the app) | Sets **free** | Keep access during the store's grace period |
| `TRIAL_STARTED` | n/a | Listed as a type | RevenueCat has no such event. A trial arrives as `INITIAL_PURCHASE` with `period_type: TRIAL` |
| `TRANSFER` | Ignored | Ignored | Move access from `transferred_from` to `transferred_to` |
| `SUBSCRIPTION_PAUSED` (Play) / `EXPIRATION` | Only `EXPIRATION` deactivates | `EXPIRATION` deactivates | Paused ends access at the pause date |
| Expiry stored | Yes (`planExpiresAt`) | No (plan only) | Store the expiry and trust nothing past it |
| Out-of-order events | Last write wins, with no `event_timestamp_ms` check | Last write wins | Ignore events older than the last one applied, or refetch the subscriber from the RevenueCat REST API on every event |
| Duplicates / retries | Idempotent in effect, no `event.id` record | Same | Record `event.id`. Return 200 for a duplicate |
| Sandbox vs production | Not checked | Not checked | Production must reject `environment: SANDBOX`. TEST should accept sandbox only |
| Anonymous ids | Ignored | **Writes** `entitlements/$RCAnonymousID...` | Ignore |
| Seat coverage | Not modelled | Not modelled | Must be derived from groups (backend only) |

Circles created while billing is off start as `plan: plus` and keep it until
a later webhook event happens to touch the owner. This is still an open
decision (D11).

---

## 3. Decisions I need from you

These are grouped by what they block. My recommendation comes first where I
have one.

### Country restriction (blocks all country work)

| # | Question | Options | Recommendation |
|---|---|---|---|
| D2 | Is the free country the home country, or does it follow travel? | (a) Home country, stored on the account. (b) Follows the device's current country. (c) Home country, plus the current country while travelling. | **(a)**. It is predictable, and a travelling free user still sees where they are through (c) only if you want to be generous. Note: (b) needs background-free location checks. |
| D3 | How often can a user change their country? | Any time / once every 30 days / once a year / only with support | **Once every 30 days**, with the first change free during the first 7 days. |
| D4 | Does picking another country open a paywall (a 4th automatic trigger) or only show an explanation? | Paywall / explanation with an optional "See ALRT +" | **Explanation only**. That keeps the automatic trigger count at three plus the one-time onboarding offer. |
| D5 | Do seat-covered members get worldwide alerts? | Yes / no | **Yes**. Your seat-benefit list says covered members inherit every benefit. |
| D6 | Cross-border and overseas family alerts | See the next table | |
| D7 | Which alert types are restricted? | Public hazards / saved-place alerts / family alerts / a subset | **Public hazards and saved-place alerts outside the free country only**. Family alerts (SOS, check-ins, a member near a hazard) are never country-restricted. |

For D6, cases that need an answer:

1. An alert whose polygon crosses the border into the free country. Recommendation: free, if any part touches the free country.
2. A free user's saved place is abroad. Recommendation: the place can be saved; its alerts show a "Worldwide alerts are part of ALRT +" card.
3. A covered family member abroad triggers a "near a hazard" family alert. Recommendation: always delivered, because it is a family alert.
4. Global sources (GDACS, USGS) that cover the free country. Recommendation: free, filtered by where the event is, not by the source's country.
5. What alert data do we actually have outside Australia? Today it is only earthquakes and GDACS. A non-Australian free user would get almost nothing. **Before this goes live we need a decision on which countries are launch-ready.**

Enforcement also needs a country on each alert. Recommendation: fill it in at
ingestion from the geometry, not from the source's free-text country.

### Entitlement and seats

| # | Question | Recommendation |
|---|---|---|
| D1 | What is the single source of truth for access? Your brief says Firestore `entitlements`. The code uses Postgres `User.plan`, plus RevenueCat on the phone. | **The backend database is the authority**, because seats and groups live there and Firestore cannot compute seat coverage. The backend alone consumes the RevenueCat webhook, works out each person's effective access (own plan, or covered by a seat), and **mirrors** it to Firestore `entitlements/{uid}` for Ask ALRT. Retire Ask ALRT's own webhook. The app reads access from the backend and uses the RevenueCat SDK only to buy, restore and show the person's own subscription. If you want Firestore as the authority instead, the family graph has to be copied to Firestore. I do not recommend that. |
| D9 | The payer's own membership now uses a seat (your rule), which reverses the 3 September ruling in the code. Please confirm the consequence: a payer in all 4 groups has **4 seats left** for other people. | Confirm, or say "the payer uses one seat in total no matter how many groups". |
| D10 | Guests (no seat; get alerts and "I'm safe") contradict "no family features without a covered seat". | **Remove the guest role for new invites**. Existing guests either become seat-holders if seats are free, or lose access with notice. |
| D11 | When the payer's plan ends: the code gives a 7-day grace period during which SOS, check-ins and journeys keep working, then only host administration locks. Another eligible payer can take over. | **Keep a 7-day grace period** during which everything works and the group sees "Ask <payer> to renew, or take over the group". After that, covered members lose family features and see the take-over or trial offer. Their data is kept. Also decide whether circles created before billing launched are reset at go-live (a one-off script). Recommendation: yes, reset. |
| D12 | Switch on `BILLING_ENABLED=true` on the **TEST** backend for the billing acceptance run? | **Yes, on TEST only**, after the backend changes land. Without it, server-side rules cannot be tested. |
| D15 | Is the Ask ALRT quota per person? Do library and emergency-lookup answers (which cost nothing) count? | **Per person**, same on every device. **Only AI answers count**, as today. The copy then says "questions answered by ALRT's AI". If you want every question counted, say so. |
| D16 | When does the daily quota reset? The code resets at **UTC midnight**, which is 10:00 or 11:00 in eastern Australia. | **Local midnight** using the account's timezone. Store the IANA timezone on the account at sign-up and when it changes. |

### Family and privacy

| # | Question | Recommendation |
|---|---|---|
| D13 | Automatic scheduled check-ins post "safe" with no action from the person. | **Remove automatic mode**. Keep reminder mode, so only the person can say they're safe. Otherwise label such check-ins in the app as "Automatic, not confirmed". |
| D14 | Who sees a snapshot: the whole group, or only the person who asked? | **The requester, or the people and groups the sender picks**, matching the SOS rule. Today everyone in the group sees it. |
| D17 | SOS recipient model: allow picking several groups and specific people at send time, with the default list ready in advance. | Yes. Fix the visibility defects in §1.2 in any case, because they are privacy bugs. |

### Paywall, onboarding and store

| # | Question | Recommendation |
|---|---|---|
| D8 | Approve the onboarding trial offer as a fourth prompt: once, at the end of onboarding, never shown again automatically. | Approve. |
| D18 | How often do automatic paywalls repeat after someone taps "Not now"? | The same trigger opens the full paywall at most **once every 7 days**. In between, the action shows a short explanation with a "See ALRT +" link. |
| D19 | Should the SOS gate show before the hold starts, never after it? | **Yes, before the hold.** Any SOS gate must show "If you are in danger now, call your local emergency number" above every button. A free user must never finish a 3-second hold and then hit a paywall. |
| D20 | Can the disclaimer and the legal screen be merged into one screen with one checkbox? | Recommend merging. **Needs your legal advice**, because the current wording was written as separate acknowledgements. |
| D21 | Google Play billing can only be tested after a signed build of `com.safetyalrt.alrt.dev` is uploaded to a **closed or internal testing track** in a Play Console app for that package. That is a store upload, but not a public release. | Approve an internal-testing-only upload, or keep Android billing verification blocked. |
| D22 | Separate TEST Firebase project, or keep sharing `alrt-a6539`? | **Separate project** (`alrt-test`), with its own Ask ALRT function, Firestore and APNs key. At minimum, register the iOS dev app `com.safetyalrt.alrt.dev` in the current project and give TEST its own Firestore collections. |
| D23 | Analytics consent: on by default with an opt-out in Settings, or opt-in? | Opt-out in Australia. Opt-in where the law requires it (EU/UK). |

---

## 4. Proposed complete paywall trigger list

These are the only places a **full paywall opens by itself**, meaning the
paywall appears straight after the person taps something:

| # | Trigger | Who sees it | Status |
|---|---|---|---|
| 1 | Saving a **4th** location | Free, no covered seat | Existing rule; the code currently fires at the 2nd |
| 2 | **Sending your location to a family member** (snapshot or "send my location") | Free, no covered seat | New in code |
| 3 | **Sending an SOS**, gated **before** the hold starts (D19) | Free, no covered seat | New in code |
| 4 | **End of onboarding**, once only | Anyone who is not already entitled or covered | Proposed (D8) |
| (5) | Choosing alerts outside the free country | Free, no covered seat | **Pending D4.** Recommended as an explanation only, not an automatic paywall |

These places stay restricted but **never open the paywall by themselves**.
Each shows an explanation in place, with a "See ALRT +" button the person
can choose to tap:

| Area | What a free person without a covered seat sees |
|---|---|
| Family tab | A clearly labelled preview of groups, check-ins and SOS, with a "Start your free month" button. No automatic sheet. |
| Create a group | The button sits inside that preview. Tapping it shows the explanation, not the paywall. Today it opens the paywall (conflict). |
| "I'm safe" check-ins and asking someone to check in | Not available outside a group. They appear only inside the preview. |
| Sharing a journey | The "Share this journey" button on navigation shows "Sharing a journey is part of ALRT +. Navigation stays free." and a See ALRT + link. |
| Ask ALRT daily limit reached | "You've used today's 3 AI answers. ALRT + gives you 10 a day. Library answers are still free." There is a link, and no automatic paywall. |
| Seats full, or 4 groups already | A management sheet only. Upgrading cannot fix these, so there is no paywall. This matches the current behaviour. |
| Profile ALRT + card | The person opens it themselves. |

Never gated: joining with an invite when a seat covers you, alerts in the
free country, navigation, emergency guidance, the first 3 saved places, and
restoring purchases.

Anyone already entitled, or covered by a seat, never sees triggers 1 to 4.

---

## 5. Onboarding

### 5.1 Current flow (code at `ea93889`)

1. Sign up or sign in.
2. **Welcome** ("Step 1 of 4"). "Make safety awareness a daily habit." Three generic bullets. "Get Started".
3. **Disclaimer**. "CRITICAL: NOT AN EMERGENCY SERVICE". Four statements. "I UNDERSTAND & AGREE".
4. **Legal & Privacy**. Terms, privacy, disclaimer links, age, "Independent", "Location", a checkbox. "CONFIRM & CONTINUE". This repeats the not-an-emergency-service and independence points from step 3.
5. **Safety profile**. "This alert season, my household includes…". This is a sensitive, detailed question at a point where the person has not yet seen an alert.
6. **Complete**. "Congratulations!", "+20 points", "Post your first alert to earn +10 points". This celebrates before anything useful has happened.
7. On the next launch, Home: the **OS location prompt fires during app start-up** with no explanation first (`app_initialization_provider.dart`, `_getCurrentUserLocation`). The notification priming sheet appears later on Home.

Not in the flow: country, a first saved place, any preview of family
features, a trial offer or post-purchase group setup. The location, radius,
alert-sources and emergency screens (about 3,000 lines) exist but are
commented out of the flow. iOS `NSLocationWhenInUseUsageDescription` says
"This app needs access to your location…", which is generic, and it has a
line break in the middle.

Problems in summary: two legal screens that repeat each other; the safety
profile asked too early; celebration and points before value; the location
prompt out of context; no family story at all; and no route to the trial.

### 5.2 Proposed shorter flow

Six short screens. Only the first is mandatory to read; everything else can
be skipped.

| # | Screen | Purpose | Permission asked |
|---|---|---|---|
| 1 | Welcome and agreement | Value in one line, plus the single legal checkbox (D20) | none |
| 2 | Your country | Suggest from location, or choose manually. Stores an ISO 3166-1 alpha-2 code | Location, with the benefit shown first |
| 3 | A place that matters (optional) | First saved place | none |
| 4 | Alerts on your phone | Notification priming | Notifications |
| 5 | ALRT + preview | Clearly labelled preview of family features | none |
| 6 | Trial offer | One month free, with "Continue free" | none |
| 7 | After purchase only: create a group | Name the group, then invite | none |

Rules:

- People joining through an invite with a covered seat skip screens 5 and 6. They see "You're covered by <payer>'s ALRT +".
- Already-entitled people skip screen 6.
- Finishing onboarding never grants access. Access comes only from a verified entitlement or a covered seat.
- The safety profile moves to a card on the first alert detail ("Tailor this guidance for your household"). Points move to after the first real action.
- The step counter shows the real number of steps and is hidden for skipped screens.

### 5.3 Draft onboarding copy

No em dashes. The brand is always "ALRT +".

**1. Welcome**
- Title: **The alert that tells you your family is safe**
- Body: ALRT shows official alerts for where you are and the places you care about, and lets the people you love tell you they're OK.
- Bullets: Official alerts near you and your places · "I'm safe" check-ins from your family · SOS to the people you choose
- Note: ALRT is not an emergency service. If you are in danger, call your local emergency number.
- Checkbox: I agree to the Terms of Use and Privacy Policy, and I understand ALRT is not an emergency service.
- Button: **Continue**

**2. Your country**
- Title: **Where should we watch for alerts?**
- Body: We can suggest your country from your location, or you can choose it yourself.
- Line above the button: Your location is used to show alerts near you. Nobody sees it unless you choose to share it.
- Buttons: **Use my location** · Choose my country
- Result: We'll show alerts for **Australia**. Change
- If D2-D7 adopt the restriction: Alerts for Australia are free. ALRT + adds alerts in every country we cover.
- Location refused: No problem. Choose your country and you can turn location on later in Settings.

**3. A place that matters**
- Title: **Keep an eye on the places that matter**
- Body: Home, school, work or a parent's place. We'll tell you when something happens there.
- Footnote: Free includes 3 saved places.
- Buttons: **Add a place** · Skip for now

**4. Alerts on your phone**
- Title: **Hear about it when it matters**
- Body: Allow notifications so we can tell you about warnings near you and your places, and when your family checks in.
- Buttons: **Allow notifications** · Not now

**5. ALRT + preview** (a "Preview" chip at the top)
- Title: **Look after your family with ALRT +**
- Card 1: **"I'm safe" in one tap**. Your group knows you're OK, without a phone call.
- Card 2: **Send an SOS to your group**. Choose exactly who gets it, person by person or group by group.
- Card 3: **Unlimited saved places**. For you and everyone you cover.
- Card 4: **Share a trip**. Let them follow along until you arrive. You choose, and it always ends.
- Footnote: One plan covers 8 seats across up to 4 groups. Each group membership uses a seat, including yours. Joining costs your family nothing.
- Button: **Continue**

**6. Trial offer** (store-returned prices and eligibility; the AUD shown is only an example)
- Title (eligible): **Try ALRT + free for 1 month**
- Title (not eligible): **Get ALRT + for your family**
- Subtitle: Be the one who keeps everyone connected, and make staying safe easier for them.
- Plan cards: **Yearly** · A$99.99 a year · "Best value" · **Monthly** · A$9.99 a month. The yearly card never shows a per-month amount unless it also says "billed yearly as A$99.99".
- Main button (eligible): **Start my free month**
- Main button (not eligible): **Subscribe for A$99.99 a year** (or the monthly equivalent)
- Disclosure under the button (eligible, yearly): Free for 1 month, then A$99.99 a year. Renews automatically every year until you cancel. Cancel at least 24 hours before your trial ends and you won't be charged. Manage or cancel anytime in your App Store / Google Play account.
- Disclosure (not eligible, monthly): A$9.99 charged today, then every month. Renews automatically until you cancel. Cancel at least 24 hours before your renewal date in your App Store / Google Play account.
- Secondary button, fully visible and not greyed: **Continue free**
- Links: Restore purchases · Terms of Use · Privacy Policy
- Pending: Your payment is pending. We'll turn on ALRT + as soon as your store confirms it. You can keep using ALRT for free meanwhile.
- Failed: That didn't go through, and you haven't been charged. Try again, or continue free.
- Cancelled: no message; stay on the screen.

**7. After purchase**
- Title: **You're covering your family**
- Body: Your ALRT + is on. Create your first group and invite the people you look after.
- Buttons: **Create a group** · Later
- Invite screen: **Invite someone to <group>**. They join free. Each person in a group uses 1 of your 8 seats, including you. **N of 8 seats used.**

### 5.4 Draft paywall and gate copy

| Moment | Title | Body | Buttons |
|---|---|---|---|
| 4th saved place | Keep an eye on the places that matter | Free includes 3 saved places. ALRT + lets you save as many as you like, for you and everyone you cover. | See ALRT + · Not now |
| Send location | Let your family know where you are | Sending your location is part of ALRT +. You choose who sees it, and it disappears after 1 hour. | See ALRT + · Not now |
| SOS (before the hold) | Send an SOS to your group | If you are in danger now, call your local emergency number. ALRT SOS alerts the people and groups you choose. It does not contact emergency services. | See ALRT + · Not now |
| Journey share (explanation) | Share your trip with ALRT + | Navigation stays free. Sharing a trip with your group is part of ALRT +. | See ALRT + · OK |
| Ask ALRT limit (explanation) | That's today's AI answers | You've used today's 3 AI answers. ALRT + gives you 10 a day. Library answers stay free, and your limit resets at midnight. | See ALRT + · OK |
| Worldwide (pending D4) | See alerts wherever your family is | Free includes alerts for <country>. ALRT + adds every country we cover. | See ALRT + · OK |
| Full paywall header | Be the alert your family wants to get | One plan covers 8 seats across 4 groups: "I'm safe" check-ins, SOS to your group, shared trips, unlimited saved places and 10 Ask ALRT answers a day each. | plan cards, disclosure, Continue free |

Visuals: keep `AlrtPlusStyle`'s gradient band, and add a soft glow behind
the plan cards and a tinted selected card. Make the "+" in "ALRT +" the
wordmark colour everywhere. Remove "Maybe later" and "Not now" wording
inconsistencies (choose one: **Not now**). Never use countdowns, "only today",
scarcity or crossed-out prices. Show no benefit that isn't delivered to
covered members as well.

---

## 6. Prioritised plan (TEST only)

### P0: before any billing test on TEST

Backend
1. **Effective access service.** Add `GET /api/me/access` returning `{ source: "self" | "seat" | "none", coveredByUserId, features, savedLocationLimit, askDailyLimit, planExpiresAt }`. Covered = a member of a circle whose owner has live access and whose membership holds a seat. Use it in every paid check.
2. **Server-side gates** (when `BILLING_ENABLED=true`): SOS send, snapshot send, check-in, check-in requests, SOS lists, journey start, circle create. Return 402 with a machine-readable `reason` so the app shows the right explanation.
3. **Seat model**: remove `owner` from `SEAT_FREE_ROLES`, subject to D9 and D10. Add a seat check at circle creation: creating a group consumes the payer's seat, so refuse it when the pool is full.
4. **Webhook hardening** (§2): record event ids, order by timestamp or refetch the subscriber, separate environments, handle refunds, transfers and pauses. Mirror effective access to Firestore `entitlements/{uid}` (D1). Retire Ask ALRT's webhook.
5. **Constants**: `FREE_SAVED_LOCATIONS_LIMIT = 3`, Ask ALRT `{ free: 3, plus: 10 }` with Ask ALRT reading the mirrored access. Reset at local midnight (D16).
6. **SOS visibility fix**: store recipient user ids on the event. `GET /sos/active`, respond and trail authorise against that recipient list, not circle membership.
7. **Secrets loader**: no production default. Refuse to start when `NODE_ENV!=prod` and the secret id contains `prod`. Treat empty values the same as set values.

Frontend
8. Read gates from `/me/access` (cached, refreshed after purchase, restore and group changes). Keep the RevenueCat SDK for offerings, purchase, restore and the Manage screen.
9. Constants and copy: 3 saved places, 3/10 Ask ALRT, "ALRT +" everywhere, no em dashes, "your local emergency number" everywhere, a 1-month trial fallback, a 4-hour SOS string.
10. Trial eligibility: iOS `checkTrialOrIntroductoryPriceEligibility`, Android the product's default option free phase. Hide trial wording when not eligible.

Service configuration (with your approval; TEST only)
11. RevenueCat `15454f8d`: confirm the Play app `com.safetyalrt.alrt.dev` and the App Store app for the same bundle; products monthly and yearly in one subscription group; entitlement `plus`; a **current** offering with `$rc_monthly` and `$rc_annual`; **one** webhook pointing at `https://api-test.safetyalrt.com/api/revenuecat/webhook` with a TEST-only secret. No TEST project webhook may point at production.
12. App Store Connect (ALRT Dev): clear `MISSING_METADATA` (display name, description, review screenshot and review note), AU price A$9.99 / A$99.99, introductory offer "Free, 1 month", Paid Apps agreement active, sandbox testers. Recheck the certificate and profile expiry before 21 October 2026.
13. Play Console (subject to D21): an app for `com.safetyalrt.alrt.dev`, subscriptions with base plans P1M and P1Y, a free-trial offer P1M for new customers only, AUD prices, license testers, an internal testing track.
14. Firebase (D22): register iOS `com.safetyalrt.alrt.dev`, upload the APNs key, replace `firebase_options_dev.dart` iOS values, and restrict the iOS Maps key to the dev bundle.
15. TEST backend: `BILLING_ENABLED=true` (D12), and `RUN_SCHEDULED_JOBS_IN_TEST=true` for the privacy tests, or run the purge by hand during tests.

### P1: flows and copy

16. Paywall trigger rework (§4) with a frequency cap (D18). The SOS gate goes before the hold (D19).
17. Onboarding (§5), with location and notification permission asked in context. The iOS location usage string: "ALRT uses your location to show alerts near you. Nobody sees it unless you choose to share it."
18. Full paywall redesign and disclosure copy (§5.3, §5.4). Handle pending purchases with a CustomerInfo listener, so access turns on without a restart.
19. Post-purchase group creation and invite flow, with the seat counter.
20. Snapshot audience (D14); remove automatic check-ins (D13); SOS multi-group selection (D17).
21. Scheduled check-in timezone per member (not fixed at Brisbane).
22. Analytics (§8).

### P2: country restriction (after D2-D7)

23. `User.countryCode` (ISO alpha-2), `countryChangedAt`, and a `Hazard.countryCodes[]` array filled in at ingestion from the geometry.
24. One filter used by feeds, map queries, search, alert detail and notification fan-out. Covered and entitled users bypass it.
25. App: country picker in onboarding and Settings, change limits (D3), explanation cards (D4).
26. Confirm launch countries and their source coverage before switching it on.

Documentation to correct along with the code: `ALRT_PLUS_SETUP.md` (14
days, a production webhook URL, one webhook), `askalrt/README.md` (3/20),
the ruling tables in `V1_RECONCILIATION_REPORT.md` §11/§17.3/§25.16 (1
saved place, 5/30), and `backend/CLAUDE.md` if it restates them.
`V1_RELEASE_PLAN.md`'s rule list is corrected in this commit.

---

## 7. Acceptance tests (Android and iOS, TEST only)

Preconditions: TEST backend with P0 deployed, `BILLING_ENABLED=true`,
scheduled jobs on. Android: a Play internal-testing build, a license tester
account and an Australian Play profile. iOS: a TestFlight build and an
Australian sandbox Apple ID. Record for each run: the build footer, the
account, pass or fail, and a screenshot. A result on the RevenueCat Test Store
build **does not** count for Play or App Store.

### 7.1 Subscriptions

| ID | Steps | Expected (both platforms unless noted) |
|---|---|---|
| SUB-1 | New account with a trial-eligible store account. Finish onboarding to the offer. | Store AUD prices for both plans. "Try ALRT + free for 1 month". Disclosure names the selected plan's price after the trial and automatic renewal. The yearly card shows no monthly figure unless it says "billed yearly". |
| SUB-2 | Switch between plan cards | The disclosure and main button follow the selected card. |
| SUB-3 | Start the trial and approve the store sheet | `/me/access` = self within 60 s. Welcome, then create a group. Manage shows the trial end date. |
| SUB-4 | Cancel on the store sheet | Stays on the offer. No error. Still free. |
| SUB-5 | Payment declined or a test card failure | "That didn't go through, and you haven't been charged". Still free. |
| SUB-6 | Pending purchase (Android slow test card; iOS Ask to Buy) | Pending message. Still free. Unlocks when approved **without restarting**. Declined: stays free. |
| SUB-7 | "Continue free" | Home. No paid access. The offer is not shown again automatically. |
| SUB-8 | A store account that has already used the trial | Not-eligible title and button. "Charged today" disclosure. No trial wording anywhere. |
| SUB-9 | Reinstall, sign in again. Restore purchases. | Access restored. Restore on an account with no purchase says "No previous ALRT + purchase found." |
| SUB-10 | Sign out and in as a different ALRT account on the same phone | No access leaks between accounts. |
| SUB-11 | Let the trial convert (accelerated renewal in the store's test mode) | One `INITIAL_PURCHASE`, then a `RENEWAL` in the backend log. Access continues. |
| SUB-12 | Cancel auto-renew in the store | Access continues to the period end, then ends. The "back on free" screen appears. The group enters grace (D11). |
| SUB-13 | Refund (iOS: sandbox refund request; Android: Play Console refund) | Access ends when the store reports it. Ask ALRT drops to 3 in the same minute. |
| SUB-14 | Billing issue or grace period | Banner shown. Access kept during grace. |
| SUB-15 | Replay one webhook event twice, then an older event after a newer one | No change after the duplicate. The older event is ignored. |
| SUB-16 | Send a `SANDBOX` event to a backend configured for production only (a staging copy, never production) | Rejected with 200 and the reason "ignored". |
| SUB-17 | Entitled user reaches each trigger (4th place, send location, SOS) | No paywall appears. |

### 7.2 Seats and groups

| ID | Steps | Expected |
|---|---|---|
| SEAT-1 | Payer creates group A | Seat counter shows 1 of 8 (payer). |
| SEAT-2 | Invite 7 people into A | 8 of 8. The 9th invite is refused with a management sheet and no paywall. |
| SEAT-3 | Create groups B, C and D with seats left | Each creation uses 1 seat. A 5th group is refused with no paywall. |
| SEAT-4 | Same person in A and B | Uses 2 seats. |
| SEAT-5 | Invited member joins | No purchase prompt. "Covered by <payer>". `/me/access` = seat. |
| SEAT-6 | Covered member adds a 4th, 5th and 10th saved place | Saved, with no paywall. |
| SEAT-7 | Covered member asks 10 AI questions, then an 11th | 10 answered. The 11th shows the limit message. |
| SEAT-8 | Remove the member | Their seat frees immediately. They lose family features and keep their data. Triggers work again for them. |
| SEAT-9 | Transfer ownership to an entitled member | Seats move to the new payer. Checks against the new payer's pool. |
| SEAT-10 | Payer's plan ends | 7-day grace (D11), everything works, with a banner. After grace: members lose family features. A take-over by an entitled member restores access. |
| SEAT-11 | Invite code at an expired, revoked or maximum-use limit | Correct refusal message for each. |
| SEAT-12 | Free user with no seat opens the Family tab | Preview only. No SOS, check-in or group creation. No automatic paywall. |

### 7.3 Quotas

| ID | Steps | Expected |
|---|---|---|
| QUO-1 | Free: 3 AI questions, then a 4th | The 4th shows the limit message with a link to ALRT +. |
| QUO-2 | Free: ask library-matched questions after the limit | Answered (if D15 keeps library answers free). |
| QUO-3 | Same account on an Android phone and an iPhone | The count is shared. The limit applies across both. |
| QUO-4 | Account timezone Australia/Perth. Use the limit at 23:50 local, then ask at 00:05 local. | Resets at local midnight (D16). |
| QUO-5 | Buy during a session that already hit the limit | 10 a day applies from the next question. |

### 7.4 Country restriction (after D2-D7)

| ID | Steps | Expected |
|---|---|---|
| CTY-1 | Onboarding with location allowed, in Australia | Australia suggested and stored as `AU`. |
| CTY-2 | Location refused | Manual picker. Onboarding still finishes. |
| CTY-3 | Free user, AU | AU alerts in the feed, map, search, detail and notifications. |
| CTY-4 | Free user opens a New Zealand alert by deep link, search or map pan | Explanation card; the API refuses the details (402 with a reason). No push arrives for it. |
| CTY-5 | Change country twice within 30 days | The second change is refused with the date it becomes possible (D3). |
| CTY-6 | A cross-border alert touching AU | Shown free (D6.1). |
| CTY-7 | Covered member | Worldwide (D5). |
| CTY-8 | Covered family member abroad near a hazard | The family alert is delivered to the group (D6.3). |

### 7.5 Location privacy

| ID | Steps | Expected |
|---|---|---|
| LOC-1 | Send a snapshot | Recipients see it with its expiry time. At 60 minutes it disappears from the recipient's view with no refresh needed, and within 5 minutes after that the coordinates are gone from the database (checked by the verify script). |
| LOC-2 | Sharing level Off, then check in | No location is sent. |
| LOC-3 | Journey without live selected | Snap points only. With live selected: live. Stop: the recipient's map stops updating within 10 s, and the trail is deleted. |
| LOC-4 | SOS with live off | No stream is started. With live on: stops immediately on stand-down, and at 4 hours on its own. |
| LOC-5 | SOS to a list of person X (group A) and person Y (group B) | X and Y get the push and can open, respond and see the trail. Other members of A and B see **nothing** in `GET /sos/active`. |
| LOC-6 | Host tries to change another member's sharing (API call) | Refused. |
| LOC-7 | Location request answered | Only the audience chosen in D14 sees it. |
| LOC-8 | Revoke location permission in OS settings while a journey is running | The journey stops sharing, and the recipient sees "location unavailable". |

### 7.6 Notifications

| ID | Steps | Expected |
|---|---|---|
| NOT-1 | Onboarding notification screen, Allow | OS prompt appears. Token registered on TEST. The test push arrives on Android and **iOS (APNs for the dev bundle)**. |
| NOT-2 | Not now | No OS prompt. A later in-context prompt is offered. |
| NOT-3 | SOS to the phone locked, silent or Do Not Disturb (iOS time-sensitive, Android urgent channel) | Delivered with the urgent treatment. The lock screen shows no location. |
| NOT-4 | Check-in and check-in request | Right people only. The sender is excluded. |
| NOT-5 | Public alert for a saved place and for a family member's area | One push per person per event. |
| NOT-6 | Country-restricted alert (after D2-D7) | Not pushed to free users outside the country. |
| NOT-7 | TEST push never reaches a production device | Install production ALRT and TEST on one phone. Only the TEST app receives TEST pushes. |

### 7.7 Onboarding and paywall

| ID | Steps | Expected |
|---|---|---|
| ONB-1 | Complete onboarding, choose Continue free | No paid access. The backend shows `source: none`. |
| ONB-2 | Join by invite during sign-up | The offer is skipped; "Covered by…" is shown. |
| ONB-3 | Already-entitled account reinstalls | The offer is skipped. |
| PW-1 | Dismiss the 4th-place paywall, retry within 7 days | Explanation only, not the full paywall (D18). |
| PW-2 | Copy check on every paywall and gate | "ALRT +" with a space, no em dash, "your local emergency number", store prices only, no urgency wording. |
| PW-3 | SOS gate | Shown before the hold. The emergency-number line is at the top. |
| PW-4 | Large text and a 360 px wide screen | Nothing clipped. "Continue free" visible without scrolling. |

---

## 8. Measuring the result

Use the existing Firebase Analytics wrapper (`analytics_service.dart`) for
screen and tap events, and the backend, from webhooks, for money events. Do
not work out conversion from the phone.

Privacy rules: no names, emails, coordinates, place names, alert text or
group names in any event. Use the Firebase app-instance id only and never
set a user id. Store country as an ISO code only. Keep 14 months of data.
Add a Settings switch (D23). Update the App Store privacy label and the Play
data-safety form to match.

| Event | Where | Parameters |
|---|---|---|
| `onb_step_viewed` / `onb_step_completed` | app | `step` (1-7), `skipped` |
| `onb_completed` | app | `steps_skipped` count |
| `permission_result` | app | `type` (location/notifications), `result` |
| `offer_viewed` | app | `placement` (onboarding / place4 / send_location / sos / profile / worldwide), `eligible_trial` |
| `offer_plan_selected` | app | `period` |
| `purchase_started` / `purchase_cancelled` / `purchase_failed` / `purchase_pending` | app | `placement`, `period`, `error_code` |
| `first_useful_action` | app, once | `type` (place_saved / check_in / group_created / member_joined / snapshot / sos_list_set) |
| `trial_started`, `trial_converted`, `trial_cancelled`, `renewed`, `cancelled`, `refunded`, `expired` | backend, from webhooks | `period`, `store`, day count |

Report these separately, so that trial take-up is never mistaken for success:

1. **Onboarding completion**: `onb_completed` / sign-ups.
2. **Offer take-up**: trial starts / `offer_viewed` for each placement.
3. **Purchase failure rate**: failed / started, broken down by `error_code`.
4. **Activation (meaningful use)**: in the first 7 days, a group with 2 or more members **and** at least one check-in or snapshot. For free users, the equivalent is one saved place plus one alert opened.
5. **Trial-to-paid**: `trial_converted` / `trial_started`, by cohort week.
6. **Cancellations**: during the trial compared with after conversion.
7. **Retention**: day-30 active rate for activated payers, unactivated payers and free users. The key comparison is activated against unactivated trial users.

---

## 9. Not changed by this audit

No code behaviour, constants, service configuration, secrets, store
products, RevenueCat settings or production resources were changed. The only
file edits are this report and the ALRT + rule list in `V1_RELEASE_PLAN.md`,
which now states your confirmed rules and says where the code still differs.

# ALRT V1 access model: implementation record and reconfiguration plan

Prepared 28 September 2026 against the reconciled master specification
("06-Reconciled-Claude-Master-Spec", 28 Sep 2026), which supersedes the
commercial rules in earlier chats, mock-ups, audit plans and CLAUDE.md.

- Baseline: `origin/test` = `ea93889928c2aceaca79389b72c8360947cf3f9b`
  (fetched 28 Sep 2026; unchanged since the 27 Sep audit).
- Working branch: `claude/alrt-subscription-audit-r4szxr` (0 behind
  `test`; earlier commits on it are documentation only).
- Nothing in this work changed a store, RevenueCat, Firebase, AWS,
  production data, a deployment or a launch setting. No dashboard was
  reachable from this session, so every live setting below is
  **Not verified**.

Evidence levels used below:

| Label | Meaning |
|---|---|
| Static | Read in the code at the stated commit |
| Local test | Ran against a local backend and throwaway Postgres+PostGIS, store events simulated with authenticated RevenueCat webhook calls (and, for subscription changes, a fake RevenueCat server API served by the test script) |
| App test | Flutter widget/unit test with a fake store and fake backend |
| Test render | PNG of the real Flutter screen rendered in a test, fake store prices; a picture of the code, not of a phone |
| TEST | Observed on the deployed TEST backend (none in this work) |
| Store sandbox | Real Apple/Google sandbox purchase (none in this work) |
| Device | Real phone behaviour (none in this work) |

Requirement status: Implemented / Partial / Missing / Conflicting /
Decision needed / Unverified.

## 1. Current-state audit (before this change, `ea93889`, Static)

| Area | Finding |
|---|---|
| Access model | One `User.plan` flag (free/plus) set by the webhook; the same event also overwrote `FamilyCircle.plan` for every circle the payer owned. No per-group funding, no product-to-tier mapping, no purchase identity. |
| Webhook | Any product with the `plus` entitlement (or none listed) activated; no event-id idempotency, no ordering guard, no environment/app check, TRANSFER ignored, refunds not distinguished. |
| Second webhook | `askalrt/functions/src/entitlements.ts` separately wrote `entitlements/{uid}` and removed access on CANCELLATION and BILLING_ISSUE (premature loss). Two interpretations of one store state. |
| Identity | RevenueCat `app_user_id` = backend `User.id` = Firebase custom-token UID (`firebase_token.controller.ts`). Consistent. Aliases are not handled. |
| Gates when billing is on | Only: creating a circle (host needs plus), 4 owned circles, 8-seat ledger on join, extra saved places. Check-in, check on, SOS, Journey and location sharing were never gated per person or per group. |
| Guests | Guest invites created seat-free members. |
| SOS | No stored audience; SOS without a preset went to the whole circle with no "anyone there?" check (empty SOS possible); preset recipients in other circles were notified but could not read the trail; any circle member could read and respond; a missing location fell back to stale stored coordinates; end push said "SOS resolved / is now marked safe" to the whole circle. |
| Check-ins | Push "[Name] is safe / Checked in safe"; asks said "Are you safe?"; Daily "automatic" mode posted a "safe" check-in on the person's behalf. |
| Ask ALRT | 5 free / 30 plus per UTC day. |
| Severity | Info override used substring matching: "test" matched "latest", "contest", "protest"; "exercise caution", "cleared land" and "not a test" downgraded real incidents. |

## 2. Requirement-by-requirement completion

Commits on `claude/alrt-subscription-audit-r4szxr`: `f3f6f7d` backend
access model, `51b4f27` app and Ask ALRT, `7e8a995` subscription changes
and refusal codes (backend), `11eac94` app follow-up (colours, upgrades,
Restore, refusals, SOS preview, onboarding). TEST keeps
`BILLING_ENABLED=false`, under which every access check answers yes
exactly as before, so deploying this code alone does not change what TEST
users can do.

Each evidence column is separate. "None" means not run. No row has
deployed-TEST, store-sandbox or device evidence.

| # | Requirement (master spec / follow-up) | Status | Local test (backend) | App test / render | TEST | Sandbox | Device |
|---|---|---|---|---|---|---|---|
| 1 | Personal access and group coverage separate; no global flag (§3, §17) | Implemented | Pass | Pass (My plans, Profile) | None | None | None |
| 2 | Canonical `StoreSubscription`; idempotent webhook, newest event wins, product -> tier map, env/app filters, refunds, billing issue keeps access, TRANSFER (§18) | Implemented | Pass (10 webhook cases) | n/a | None | None | None |
| 3 | Individual: unlimited places, 10 Ask/day, unlimited groups; Free: 1 place, 3 Ask/day; sponsorship never raises personal limits | Implemented | Pass | Pass | None | None | None |
| 4 | Four-group cap and seats removed; creating/joining free | Implemented | Pass | Pass | None | None | None |
| 5 | Individually funded groups: each participant needs Individual; lapse pauses only that person | Implemented | Pass | n/a | None | None | None |
| 6 | Family 6 / Group 20 / Group 50 cover ONE group; concurrent joins can't exceed | Implemented | Pass (incl. race) | n/a | None | None | None |
| 7 | Sponsorship bound to the group chosen before checkout; unmatched purchase bound by payer only | Implemented | Pass | n/a | None | None | None |
| 8 | Individual and a group plan coexist | Implemented | Pass | Pass (restore wording) | None | Store grouping unverified (C2) | None |
| 9 | Sponsorship lapse pauses only its group; no silent switch | Implemented | Pass | Pass (refusal sheet) | None | None | None |
| 10 | Connection features gated per person per group; stop/end/leave never gated | Implemented | Pass | n/a | None | None | None |
| 11 | Guests retired; old guest codes refused; existing rows untouched | Implemented (no conversion) | Pass | n/a | Guest rows NOT inspected (no DB access) | n/a | n/a |
| 12 | No empty SOS; stored audience enforced everywhere; cross-group preset refused | Implemented | Pass | Pass | None | n/a | None |
| 13 | No stale SOS coordinates | Implemented | Pass | n/a | None | n/a | None |
| 14 | Factual end wording; no "safe"/"resolved" | Implemented | Static | Pass | None | n/a | None |
| 15 | Daily is a reminder only (R07 provisional) | Implemented | Static | Pass (copy) | None | n/a | None |
| 16 | Extra places paused (not deleted) after Individual lapses | Partial (which place stays is R04) | Pass | n/a | None | None | None |
| 17 | Ask ALRT 3/10 per local day, travel-safe | Implemented (counting unit is R03) | Unit tests (36) | n/a | None | n/a | None |
| 18 | Ask ALRT reads backend-written mirror; second webhook retired | Implemented in code | Static | n/a | None | n/a | None |
| 19 | Severity override by phrase | Implemented | 18 phrase checks | n/a | None | n/a | n/a |
| 20 | `GET /api/access` | Implemented | Pass | Pass | None | n/a | None |
| 21 | Scheduled changes: tier moves only when the store confirms the change took effect | Implemented | Pass (scheduled downgrade, withdrawn change, stale purchase ignored, server-record confirm) | Pass (pending wording) | None | NOT verified: real RevenueCat event sequences for Apple/Google changes must be confirmed | None |
| 22 | Family -> Group 20 -> Group 50 upgrades keep the group and the separate Individual; Android replacement | Implemented | Pass (Google new-transaction replacement x2, App Store same-transaction, payer-only, ambiguous never guessed) | Pass (Android passes the old product with prorated replacement; iPhone does not) | None | NOT verified (C5, C22) | None |
| 23 | Restore: failure, pending reconciliation and confirmed access each truthful | Implemented | Pass (reconcile reports unrecorded purchases, never grants; API failure = unchecked) | Pass (4 widget + 7 unit) | None | None | None |
| 24 | Contextual refusals: ended sponsorship, capacity, permissions, missing SOS recipients distinguished; not all sent to Individual | Implemented | Pass (codes on 402/403/409/422) | Pass (7 unit + 3 renders) | None | n/a | None |
| 25 | SOS recipient and location preview before sending | Implemented | n/a | Pass (2 widget + 3 unit) | None | n/a | None |
| 26 | Optional onboarding ALRT + step | Implemented | n/a | Pass (1 widget + render) | None | n/a | None |
| 27 | Plan colours and naming (owner 28 Sep: ALRT + purple, Family green, Group blue, gradients; "Individual" not shown) | Implemented | n/a | Pass + 13 renders | None | n/a | None |
| 28 | Store / RevenueCat / Firebase configuration | Unverified | n/a | n/a | None | None | None |

### How subscription changes work now

- `PRODUCT_CHANGE` is a request. It sets `pendingTier` and never moves
  the active tier or capacity. The tier moves when (a) a later store event
  on that transaction names the new product (for example the RENEWAL that
  starts a scheduled downgrade), or (b) RevenueCat's server record, read by
  the backend with `REVENUECAT_SECRET_API_KEY` (optional, C22), shows the
  new product purchased after the request and not expired. Without the key
  an immediate App Store upgrade waits for the next store event; ALRT
  under-delivers rather than over-delivers.
- Upgrades are started by the current payer only
  (`POST /api/access/sponsorship-intents` answers with the product it
  replaces). Android buys with a Play replacement of that product
  (`StoreReplacementMode.chargeProratedPrice`); the App Store upgrades
  within the subscription group. A new store transaction that replaces
  the plan takes over the same group and the old row is marked
  superseded, so the group is never counted twice and Individual is never
  touched. With two possible plans to replace, nothing is guessed.
- Smaller plans are changed in the store and apply at renewal; the app
  never offers a downgrade purchase. An over-capacity downgrade blocks new
  joins and removes no one (R02).
- `POST /api/access/reconcile` (after purchase or Restore) confirms
  pending changes and REPORTS store purchases ALRT has not recorded yet.
  It never grants access; access still comes only from the webhook.

### New backend API for the app

| Endpoint | Purpose |
|---|---|
| `GET /api/access` | `{ billingEnabled, personal: { plan, reason, isTrial, expiresAt, willRenew, extraSavedPlaces, askPerDay }, groups: [{ circleId, name, role, fundingMode, peopleCount, capacity, sponsorship: { tier, live, status, expiresAt, coveredBy, youPay }, connectionAccess: { allowed, reason } }], unboundSponsorships, computedAt }` |
| `POST /api/access/sponsorship-intents` `{ circleId, tier }` | Host chooses the group before the store sheet opens; checks capacity and that no live plan covers it |
| `POST /api/access/sponsorships/:id/bind` `{ circleId }` | Payer applies an unmatched group purchase to one group they host, once |
| `POST /api/access/groups/:circleId/individual-funding` | Host explicitly returns a lapsed sponsored group to individual funding |
| `GET /api/family/circles` | Adds `fundingMode`, `capacity`, `sponsorshipLive`, `connectionAccess`; `seatCount` is now just the headcount (deprecated) |
| `GET /api/user/location-subscriptions` | Adds `isPaused` per saved place |
| `POST /api/access/reconcile` | `{ store: { checked, confirmedChanges, unrecorded: [{productId, tier}] }, access }` |
| Intent response | Adds `replaces: { tier, productId, store }` for an upgrade (payer only) |
| Sponsorship in `/api/access` | Adds `pendingTier`; `productId` and `store` for the payer only |

Refusals carry `{ error, code, details }`. Codes: `INDIVIDUAL_REQUIRED`
(402), `GROUP_PLAN_ENDED` (402), `SAVED_PLACE_LIMIT` (402), `GROUP_FULL`
(409 sponsored / 400 technical cap, `details.capacity`),
`GROUP_ALREADY_COVERED`, `PLAN_TOO_SMALL`, `CHANGE_IN_STORE` (409),
`HOST_ONLY`, `PAYER_ONLY` (403), `NO_SOS_RECIPIENTS` (422,
`details.hasCandidates`), `SOS_PRESET_OTHER_GROUP` (422).

## 3. Exact reconfiguration table

Nothing here was changed. Every "Current" value is **Not verified** unless
stated; historical values are discovery clues only. Secrets are named,
never shown.

| # | System / env | Current (evidence) | Target | Action | Type | Owner | Depends on | Rollback | Verify |
|---|---|---|---|---|---|---|---|---|---|
| C1 | App Store Connect, TEST and prod apps | Not verified. Historical: generic ALRT+ monthly/yearly | 4 auto-renewing products: Individual monthly, Family monthly, Group 20 monthly, Group 50 monthly | Create products; AU prices A$5.99 / 15.99 / 24.99 / 49.99 (targets) | Config | Owner | Legal copy (R09) | Remove from sale | Product list screenshot |
| C2 | App Store subscription groups | Not verified | Individual in its OWN group; Family/Group 20/Group 50 together in a second group (levels 50 > 20 > Family) | Create 2 groups. One group for everything would make Individual and a group plan mutually exclusive | Config | Owner | C1 | Move products before first sale only | Sandbox: buy Individual then Family, both active |
| C3 | App Store introductory offer | Not verified | Individual only: 1 month free, new subscribers; none on group products | Configure | Config | Owner | C1, R09 | Remove offer | Sandbox eligible vs ineligible account |
| C4 | Google Play subscriptions | Historical (25 Sep, turn b01b52ec): zero subscriptions on `com.safetyalrt.alrt`. Re-inspect | 4 subscriptions, monthly base plans; Individual free-trial offer (30 days, new customers); none on group plans | Create; do not create replacements blindly if some now exist | Config | Owner | R09 | Deactivate base plan | Play console + test purchase |
| C5 | Play replacement / proration | Not verified | Family, Group 20, Group 50 in one Play subscription family so a purchase can replace another; Individual separate. The app requests `CHARGE_PRORATED_PRICE` for upgrades (immediate, same renewal date) | Confirm Play allows prorated upgrades between these products | Config | Owner | C4 | n/a | Sandbox: Family -> Group 20 on Android keeps the same group covered, old token expires, no unbound plan left |
| C6 | Play acknowledgement | Not verified | RevenueCat acknowledges (default) | Confirm no second acknowledger | Config | Owner | | n/a | No refunds for unacknowledged purchases in test |
| C7 | App Store Server Notifications v2 / Google RTDN | Not verified | Point to RevenueCat | Configure both envs | Config | Owner | | Remove URL | RevenueCat shows store events |
| C8 | RevenueCat project and apps | Historical: project 15454f8d, TEST app `com.safetyalrt.alrt.dev` | Confirm which RC app ids map to TEST vs prod | Record app ids; set backend `RC_APP_IDS` | Config | Owner | | Clear env | Webhook with other app id is ignored |
| C9 | RevenueCat entitlements | Historical: one `plus` | `individual` (Individual product only). Optional `group_family`, `group_20`, `group_50` for SDK display only | Create; do NOT attach group products to any personal entitlement; detach from `plus` only after checking existing purchases (C15) | Config | Owner | C1, C4 | Re-attach | SDK: Family buyer has no `individual` |
| C10 | RevenueCat offerings | Historical: default offering, monthly/annual | Offering `personal` with the Individual product as its Monthly package; offering `groups` with custom packages identified exactly `family`, `group20`, `group50` (the app matches on these ids). Entitlement id `individual` | Create; remove annual package | Config | Owner | C9 | Keep old offering unused | App lists store prices |
| C11 | RevenueCat webhook to backend | Historical: TEST passes existed for the old model; they do not validate this catalogue | `POST https://<env-api>/api/revenuecat/webhook`, Authorization = `REVENUECAT_WEBHOOK_AUTH`, all event types, correct environment per RC app | Keep/confirm; per-env URL | Config | Owner | D1 deployed | Disable | Test event -> `RevenueCatWebhookEvent` row |
| C12 | RevenueCat webhook to Firebase `revenuecatWebhook` | Historical: configured with `REVENUECAT_AUTH` | Removed | Delete this webhook in RevenueCat AFTER D1 and D3 (§4) | Config | Owner | D1, D3 | Re-add | Only one webhook listed |
| C13 | Backend env TEST | Historical: `BILLING_ENABLED=false`, API `api-test.safetyalrt.com` | Add `RC_PRODUCT_TIERS` (real product ids -> tiers), `RC_EXPECTED_ENVIRONMENT=SANDBOX`, `RC_APP_IDS`; keep `REVENUECAT_WEBHOOK_AUTH`. Set `BILLING_ENABLED=true` on TEST only for enforced-billing test runs | Env change | Config | Owner | C1 to C11 | Revert env | `GET /api/access` shows real state |
| C14 | Backend env production | Not verified | Same variables with `RC_EXPECTED_ENVIRONMENT=PRODUCTION`; `BILLING_ENABLED` stays false until launch approval | Env change at launch only | Config / Decision | Owner | Launch approval | Revert env | Launch checklist |
| C15 | Existing purchases on `plus` | Not verified | Assessed before any mapping change | Export active `plus` subscribers per env; decide mapping (likely Individual for personal buyers) | Decision | Owner | | n/a | Count reviewed |
| C16 | Firestore rules `entitlements/{uid}` | Code: client cannot write | Unchanged; backend writes with admin SDK | None | n/a | | | | Rules test |
| C17 | Firebase function secrets | `REVENUECAT_AUTH` used by retired function | Remove after C12 | Delete secret | Config | Owner | C12 | Re-create | Secret list |
| C18 | Backend Firebase credentials | Backend already uses `serviceAccountKey.json` (file, not env) | Service account needs Firestore write on `entitlements` | Confirm IAM role | Config | Owner | | | Mirror doc written on a sandbox purchase |
| C19 | Database migration | Not applied anywhere | `20260928000000_v1_access_model` applied TEST then prod | `prisma migrate deploy` | Migration | Engineering | D1 | See §4 | Tables present |
| C20 | Apple/Google test identities | Not verified | Sandbox testers for eligible and ineligible trial, Family payer, member | Create | Config | Owner | C1, C4 | n/a | Test matrix §5 |
| C22 | Backend env `REVENUECAT_SECRET_API_KEY` (optional) | Not set | RevenueCat secret (server) API key per environment, read-only use: `GET /v1/subscribers/{id}` to confirm pending changes and spot unrecorded purchases. Never shipped in the app | Add as a secret on TEST first | Config | Owner | C8 | Remove env (pending changes then wait for store events) | Sandbox App Store upgrade shows the new tier within a minute |
| C23 | Database migration 2 | Not applied anywhere | `20260929000000_v1_subscription_changes` (additive columns) after C19 | `prisma migrate deploy` | Migration | Engineering | C19 | Drop the added columns | Columns present |
| C24 | App Store subscription group levels | Not verified | Group 50 highest, Group 20, Family lowest in the group-plans subscription group, so moving up is an upgrade (immediate, prorated refund) and down is a downgrade (at renewal) | Set levels | Config | Owner | C2 | Reorder before first sale | Sandbox: Family -> Group 20 immediate; Group 50 -> Family at renewal |
| C21 | Store listing / legal copy | Not verified | Individual trial wording per platform, group "no trial", SOS safety statement | Legal review | Decision (R09) | Owner | | | Sign-off |

## 4. Migration, rollout and rollback

Migration `20260929000000_v1_subscription_changes` (additive: pending
change columns, `supersededAt/By`, `SponsorshipIntent.replacesSubscriptionId`)
goes right after the first one; rollback drops those columns.

Migration `20260928000000_v1_access_model` is additive: three new tables,
three enums, `FamilyCircle.fundingMode` (default `individual`, which is
what every existing circle meant), and three `FamilySosEvent` columns
(existing events keep whole-circle visibility). No row is changed or
deleted. Verified locally by applying it to a copy of the `ea93889`
schema and diffing against `schema.prisma` (only pre-existing PostGIS
index noise remained).

Deploy order:

1. D1 Backend with the migration, `BILLING_ENABLED` unchanged. Behaviour
   is unchanged while billing is off; the webhook starts recording
   `StoreSubscription` rows for mapped products and writing the mirror.
2. D2 Configure C8 to C11, C13 on TEST.
3. D3 Ask ALRT functions (reads the new mirror; still honours legacy
   `plan` when the new fields are absent). Firebase will ask to delete the
   retired `revenuecatWebhook` function.
4. D4 Remove the old Firebase webhook in RevenueCat (C12), then its
   secret (C17).
5. D5 On TEST only, enable billing and run the §5 matrix with sandbox
   purchases and real devices.

Existing data:

- Existing `User.plan = plus` rows are a mirror only and grant nothing
  once billing is on unless a mapped `individual` purchase exists. Before
  enabling billing anywhere with real purchasers, replay or re-sync their
  RevenueCat state (C15) so a `StoreSubscription` row exists.
- Guests: 0 new guests can be created. Proposal (not run): convert each
  existing `guest` row to `adult` after telling the host, because V1 has
  no uncounted category; until then they count as people and keep guest
  permissions. Needs owner approval.
- Circles hosted by a past ALRT+ payer become individually funded (each
  participant needs Individual once billing is on). If an owner wants
  those covered, they buy a group plan for the group. Communicate before
  launch.

Rollback: redeploy the previous backend image (the new tables are simply
unused), or run `DROP TABLE "StoreSubscription", "SponsorshipIntent",
"RevenueCatWebhookEvent"; ALTER TABLE "FamilyCircle" DROP COLUMN
"fundingMode"; ALTER TABLE "FamilySosEvent" DROP COLUMN
"recipientUserIds", DROP COLUMN "audienceRestricted", DROP COLUMN
"endedByMemberId"; DROP TYPE "PlanTier", "StoreSubscriptionStatus",
"CircleFundingMode";` only after taking a backup, because it discards
recorded purchases. Re-add C12 if the old Ask ALRT function is restored.

## 5. Acceptance evidence (master spec §20)

Local test = `backend/src/scripts/verify_v1_access_model.ts` (30 checks)
and `verify_v1_subscription_changes.ts` (10 scenarios, fake RevenueCat
server API), both passing with BILLING_ENABLED=true and simulated
webhooks; functions unit tests (36). App test = `flutter test` (340
passing, 33 skipped opt-in renders), including
`v1_restore_refusal_preview_test.dart` (19),
`v1_upgrade_restore_onboarding_test.dart` (8), the extended
`family_sos_screen_navigation_test.dart` (7) and
`alrt_plus_store_price_screens_test.dart` (9). Test renders: 13 PNGs from
`test/screenshots/v1_plans_screenshots_test.dart`.

| # | Case | Local test | App test / render | TEST | Sandbox | Device |
|---|---|---|---|---|---|---|
| 1 | Individual joins 5th and 10th group | Pass | n/a | None | None | None |
| 2 | Two Individuals, no group plan | Pass | n/a | None | None | None |
| 3 | Sponsored Free member and sponsor keep 1 place / 3 Ask | Pass | Pass | None | None | None |
| 4 | Individual + group plan coexist; tier change | Pass | Pass | None | Unverified (C2, C24) | None |
| 5 | Individual lapse pauses only that person | Pass | n/a | None | None | None |
| 6 | Sponsorship lapse only affects its group | Pass | Pass (sheet) | None | None | None |
| 7 | Two sponsored memberships don't merge personal quotas | Pass | n/a | None | None | None |
| 8 | 6/20/50 capacity incl. payer; concurrent joins | Pass | Pass (full-group sheet) | None | None | None |
| 9 | Cross-group recipients and unauthorized readers denied | Pass | n/a | None | n/a | None |
| 10 | Duplicate / delayed / out-of-order webhooks | Pass | n/a | None | None | n/a |
| 11 | Only Individual trial; no manufactured eligibility | Backend reports store data | Pass | None | None | None |
| 12 | Limits under concurrency and day boundaries | Places pass; Ask unit tests | n/a | None | n/a | None |
| 13 | Personal and group states agree across surfaces | Pass | Pass | None | None | None |
| 14 | Scheduled change not applied early | Pass | Pass | None | None | None |
| 15 | Upgrade keeps group, separate Individual | Pass | Pass | None | None | None |
| 16 | Restore truthful | Pass | Pass | None | None | None |
| 17 | Refusals distinguished | Pass | Pass | None | n/a | None |
| 18 | SOS preview | n/a | Pass | None | n/a | None |

Regression with billing off (today's TEST behaviour), re-run after the
follow-up: `verify_circle_list_state` (5), `verify_family_leave_and_alert_link`
(12), `verify_family_location_consent` (40), `verify_sos_history` (8),
`verify_stage9a_journey_recipient` (13), `verify_targeted_check_in_request`
(14), `verify_saved_location_limit` (3 off / 5 on), severity phrases (18):
all pass. Backend `tsc --noEmit` clean apart from the pre-existing
`serviceAccountKey.json` import. `flutter analyze`: the 6 pre-existing
infos only.

## 6. Open decisions: current provisional behaviour and recommendation

Nothing below is approved by being in the code. Each "Now" is what the
code does today, provisionally.

| ID | Decision | Now (provisional) | Recommendation |
|---|---|---|---|
| R01 | Capacity of groups with no Family/Group plan; pending members | No commercial cap; the old technical `maxMembers` (10) applies; joins are immediate (no pending state) | Keep a technical cap but raise it to 50 so an unsponsored group can grow into Group 50; no pending state in V1 |
| R02 | Repeat sponsorships, payer leaves, reassignment, over-capacity downgrade | One live plan per group; only the payer can upgrade; smaller plans change in the store at renewal; if the payer leaves, the plan keeps covering the group until it lapses; TRANSFER moves the payer, coverage stays; over capacity blocks new joins, removes no one | Keep all of that. Add: when the payer leaves, tell the host the plan ends at renewal unless they rejoin; allow the host to buy a new plan once the old one lapses (already works) |
| R03 | What counts as an Ask ALRT question | Counted BEFORE the AI call, so a model failure, a timeout and a safety refusal all count; library and emergency answers never count; nothing counts while the AI is switched off | Count only an AI answer actually delivered: give the question back when the model call fails, and have the app send a request id so a network retry of the same question is not counted twice. Keep refusals counted (they used the model) |
| R04 | SOS/Journey running when access ends; which free saved place stays | A running SOS keeps its live share to the 4-hour cap; a running Journey continues to its end time but can't be extended or restarted; the OLDEST saved place stays active, the rest pause (none deleted) | Keep SOS and Journey as is (never cut off a safety share mid-way). Let the person choose which saved place stays active, defaulting to the oldest |
| R05 | Retention periods | Locations: snapshots deleted after 1 hour, SOS live share after the 4-hour cap, journey points on end. Kept with no end date: SOS history (who and when, no locations), check-in events, webhook receipts, subscription rows, Ask ALRT daily counters. Deleted accounts: removed by the nightly job | Keep the location rules. Set end dates: SOS and check-in history 12 months, Ask counters 30 days, webhook receipts 13 months (refund window), subscription rows for as long as tax/accounting requires. Publish them in the privacy policy |
| R06 | Who may end someone else's SOS; SOS across groups for an Individual | The sender or the group's host can end it (actor recorded, "[Name] ended their SOS." / "SOS ended by [Name]"); an SOS goes to one group only | Keep: sender or host only, never other members. Keep one group per SOS; offer a quick "also send to [other group]" only after launch if people ask |
| R07 | Daily | Both modes send a reminder only; nothing is ever posted on the person's behalf | Keep reminder only. Remove the "automatic" option from settings entirely |
| R08 | Community push rules | One community report is pushed to everyone nearby who has community alerts on, as soon as the AI review accepts it; no corroboration needed | Push a community report only after it is corroborated (a second person, or review plus a nearby official source), and never at night unless it is Critical-looking; keep showing it on the map at once |
| R09 | Trial wording, legal / age / privacy disclosure | App shows the disclosure from store data; trial only when the store reports an eligible free intro offer | Legal review of the four disclosure strings and the upgrade wording before submission |
| R10 | Points vs XP | Unchanged | Out of this scope; decide separately |
| R11 | Group Places limits; renaming the Family area | Group Places: no limit, free, adults and host manage them, separate from personal saved places; the tab is still called "Family" | Cap group Places at 20 per group as an abuse limit, keep them free. Rename the tab to "Groups" only with the store screenshots update |
| G1 | Existing guest members | Not converted; they count as people and keep guest permissions; guest codes refused | Run `inspect_guest_members.ts` (read-only) on TEST and production first. Then ask each host to convert their guests (host action, one tap), rather than converting everyone to adult |

### Ask ALRT: failure and retry charging, exactly as coded

1. Library answers and emergency-number answers: free, never counted.
2. AI switched off (Remote Config kill switch): error, not counted.
3. Daily limit reached: refused before counting, not counted.
4. Otherwise the question is counted FIRST, then the AI is called:
   - model error or timeout: the person gets "Ask ALRT is unavailable
     right now. Please try again." AND the question stays counted;
   - a safety refusal from the model: counted;
   - the answer is produced but the phone loses the response (network
     drop): counted, and asking again counts again.
5. Retrying therefore costs a question each time. This is the current
   code, not an approved rule (R03); see the recommendation above.

### Guest records

`backend/src/scripts/inspect_guest_members.ts` is read-only: counts, group
ids, roles, join and last check-in dates, whether the group is sponsored
or has a host. It changes nothing. It was run only on the local test
database (0 guests; and 1 temporary row to prove the report works, then
reverted). TEST and production guest rows have NOT been inspected, because
this session has no access to those databases. No conversion is proposed
until that report has been run and read.

## 7. Launch blockers

1. Store products, subscription groups and levels, offers, Play
   replacement and RevenueCat mapping (C1 to C12, C22, C24) not created or
   verified.
2. The real RevenueCat event sequences for App Store and Google Play
   upgrades and scheduled downgrades must be confirmed in sandbox; the
   backend handles both shapes, but only simulated events were tested.
3. R01 to R05 and R08 need decisions before billing is enabled.
4. Existing `plus` purchasers need re-sync or mapping (C15).
5. Guest records on TEST and production must be inspected (G1).
6. No deployed-TEST, store-sandbox or device evidence for any purchase,
   upgrade, restore, refusal sheet, SOS preview or push.
7. Earlier launch items (iOS signing and build, APNs, Maps, Apple sandbox,
   TEST source sync, real-device push) were not rechecked here.

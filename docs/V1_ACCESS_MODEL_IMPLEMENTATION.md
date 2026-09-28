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
| Local test | Ran against a local backend and throwaway Postgres+PostGIS, store events simulated with authenticated RevenueCat webhook calls |
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

## 2. What changed in code

All backend, Ask ALRT function and app changes below are on this branch.
TEST keeps `BILLING_ENABLED=false`, under which every access check answers
yes exactly as before, so deploying this code alone does not change what
TEST users can do.

| # | Requirement (master spec) | Status | Evidence |
|---|---|---|---|
| 1 | Personal access and group coverage are separate; no global flag (§3, §17) | Implemented | Static, Local test |
| 2 | Canonical `StoreSubscription` per original transaction; webhook idempotent on event id, newest event wins, product->tier via `RC_PRODUCT_TIERS`, env/app filters, refunds, billing issue keeps access to expiry, TRANSFER moves purchases (§18) | Implemented | Local test (10 webhook cases) |
| 3 | Individual: unlimited saved places, 10 Ask/day, unlimited groups; Free: 1 place, 3 Ask/day; sponsorship never raises personal limits (§3, §14) | Implemented | Local test |
| 4 | Remove four-group cap and seats; creating/joining free (§4) | Implemented | Local test (Individual in 10 groups, hosts 6) |
| 5 | Individually funded groups: each active participant needs Individual; a lapse pauses only that person (§4) | Implemented | Local test |
| 6 | Family 6 / Group 20 / Group 50 cover ONE group; everyone in it counts; concurrent joins can't exceed (§5) | Implemented | Local test (Family 7th join 409; Group 20 21st join 409; race: exactly one of two succeeds) |
| 7 | Sponsorship bound once to the group chosen before checkout; host only; unmatched purchase bound later by its payer only (§6, §18) | Implemented | Local test |
| 8 | Individual and a group plan coexist; tier change keeps Individual (§5) | Implemented | Local test |
| 9 | Sponsorship lapse pauses only its group; no silent switch to individual funding (§7) | Implemented | Local test |
| 10 | Connection features gated per person per group; stop/end/leave never gated (§17) | Implemented | Static, Local test |
| 11 | Consumer guests retired; old guest codes refused (§5) | Implemented | Local test. Existing guest rows unchanged (see §4 migration) |
| 12 | No empty SOS; stored audience enforced on reads, responses, trail, sockets, history, end notifications; cross-group preset refused (§12) | Implemented | Local test |
| 13 | SOS never uses stale stored coordinates (§12) | Implemented | Local test |
| 14 | End wording factual, actor recorded; no "safe"/"resolved" in backend pushes (§11, §12) | Implemented | Static |
| 15 | Daily never manufactures a check-in (§11) | Implemented (both modes send a reminder) | Static. Final Daily behaviour is R07 |
| 16 | Extra saved places paused (no alert fan-out) after Individual lapses; nothing deleted (§7) | Partial | Local test. Which place stays active is provisional (oldest) pending R04 |
| 17 | Ask ALRT 3/10 per local day, once per account, travel-safe (§14) | Implemented | Unit tests (functions). Counting unit unchanged, R03 |
| 18 | Ask ALRT reads a backend-written versioned mirror; second webhook retired (§17) | Implemented in code | Static. Needs the deploy order in §4 |
| 19 | Severity override by phrase with "not a test" precedence (§15) | Implemented | 18 phrase checks |
| 20 | `GET /api/access` returns personal plan and each group's coverage separately with access reason and computed time (§17) | Implemented | Local test |
| 21 | Frontend: plans, paywalls, onboarding, Profile, colours, copy (§8 to §10, §13, §16) | Partial | Implemented: chooser, Individual and Cover-a-group paywalls, My plans, Profile entry, plan colours, §9 copy, seats/guests/4-group cap removed from the app, SOS end wording, no "safe" wording, "Periodic updates". Not done: onboarding ALRT + step, dedicated 402 upsell routing on connection features (the backend's message is shown as a toast), SOS recipient preview. Evidence: widget tests and test renders (see §5a); no device |
| 22 | Store / RevenueCat / Firebase configuration for the new catalogue (§19) | Unverified | See §3 |

### New backend API for the app

| Endpoint | Purpose |
|---|---|
| `GET /api/access` | `{ billingEnabled, personal: { plan, reason, isTrial, expiresAt, willRenew, extraSavedPlaces, askPerDay }, groups: [{ circleId, name, role, fundingMode, peopleCount, capacity, sponsorship: { tier, live, status, expiresAt, coveredBy, youPay }, connectionAccess: { allowed, reason } }], unboundSponsorships, computedAt }` |
| `POST /api/access/sponsorship-intents` `{ circleId, tier }` | Host chooses the group before the store sheet opens; checks capacity and that no live plan covers it |
| `POST /api/access/sponsorships/:id/bind` `{ circleId }` | Payer applies an unmatched group purchase to one group they host, once |
| `POST /api/access/groups/:circleId/individual-funding` | Host explicitly returns a lapsed sponsored group to individual funding |
| `GET /api/family/circles` | Adds `fundingMode`, `capacity`, `sponsorshipLive`, `connectionAccess`; `seatCount` is now just the headcount (deprecated) |
| `GET /api/user/location-subscriptions` | Adds `isPaused` per saved place |

Distinct errors: 402 access (Individual needed / group plan paused), 409
capacity or already covered, 422 no reachable SOS recipient or
cross-group preset, 403 permission, 404 not found or not in audience.

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
| C5 | Play replacement / proration | Not verified | Family -> Group 20 -> Group 50 as upgrades within the group family; Individual independent | Configure replacement mode per offer | Config | Owner | C4 | Revert mode | Sandbox upgrade keeps binding (tested locally via PRODUCT_CHANGE) |
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
| C21 | Store listing / legal copy | Not verified | Individual trial wording per platform, group "no trial", SOS safety statement | Legal review | Decision (R09) | Owner | | | Sign-off |

## 4. Migration, rollout and rollback

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

Local test = `backend/src/scripts/verify_v1_access_model.ts` (30 checks,
all passing, BILLING_ENABLED=true, simulated webhooks) plus the functions
unit tests. Nothing below has TEST, store-sandbox or device evidence yet.

| # | Case | Local test | TEST / Sandbox / Device |
|---|---|---|---|
| 1 | Individual joins 5th and 10th group | Pass | Not run |
| 2 | Two Individuals, no group plan | Pass | Not run |
| 3 | Sponsored Free member and sponsor keep 1 place / 3 Ask | Pass | Not run |
| 4 | Individual + group plan coexist, tier change | Pass (webhook level) | Store grouping unverified (C2, C5) |
| 5 | Individual lapse pauses only that person | Pass | Not run |
| 6 | Sponsorship lapse only affects its group, no charge, no mode switch | Pass | Not run |
| 7 | Two sponsored memberships don't merge personal quotas | Pass | Not run |
| 8 | 6/20/50 capacity incl. payer; concurrent joins | Pass (Family 6 and Group 20 filled to capacity; Group 50 same code path) | Not run |
| 9 | Cross-group recipients and unauthorized readers denied | Pass (REST); sockets follow the same audience list (Static) | Not run |
| 10 | Duplicate / delayed / out-of-order webhooks | Pass | Not run |
| 11 | Only Individual trial; no manufactured eligibility | Backend reports trial from store data; eligibility is store-side | Store sandbox needed |
| 12 | Saved place and Ask limits under concurrency, day boundaries, plan changes | Saved places: pass. Ask: unit tests for local day, DST, zone validation | Firestore transaction not run against emulator |
| 13 | Personal and group states agree across app surfaces | App reads `GET /api/access` for Profile, My plans and both paywalls (widget tests) | Not run on device |

Regression (billing off, today's TEST behaviour): existing scripts
`verify_circle_list_state` (5), `verify_family_leave_and_alert_link` (12),
`verify_family_location_consent` (40), `verify_sos_history` (8),
`verify_stage9a_journey_recipient` (13), `verify_targeted_check_in_request`
(14), `verify_saved_location_limit` (3 off / 5 on) all pass.
`verify_seat_rule.ts` was removed: it asserted the retired seat model.
Backend `tsc --noEmit` clean; functions build clean, 36 unit tests pass
(including the `utcOffsetMinutes` fallback: when the app sends no IANA
zone name, the day key is `offset:<minutes>`).

### 5a. App evidence

`flutter analyze`: 6 pre-existing infos only. `flutter test`: 311 pass,
28 skipped (opt-in screenshot tests). `test/alrt_plus_store_price_screens_test.dart`
checks exact §9 copy, store prices, trial shown only for an eligible
account, no trial on group plans, "too small" plans, and My plans for a
payer and a covered member. Test renders of 8 screens come from
`ALRT_SCREENSHOTS=1 flutter test --update-goldens
test/screenshots/v1_plans_screenshots_test.dart` (fake store, not a
device).

## 6. Open decisions (unchanged register, with what the code does now)

| ID | Question | Code today |
|---|---|---|
| R01 | Capacity of individually funded groups; pending members | No commercial cap; the existing technical `maxMembers` (10) still applies. Needs a decision before billing is on |
| R02 | Repeat sponsorships, payer departure, reassignment, over-capacity downgrade | One live plan per group; a payer can buy plans for several groups they host (store support unverified); TRANSFER moves the payer, coverage stays; an over-capacity downgrade blocks new joins and evicts no one |
| R03 | Ask counting unit | Every AI attempt that reaches the model counts; library and emergency answers don't. Copy must say "questions", not "answers", until decided |
| R04 | Active SOS/Journey at expiry; which free saved place stays | An SOS already running keeps its live share; new Journey/extend is gated; oldest saved place stays active (provisional) |
| R05 | Retention periods | Unchanged; nothing deleted on lapse |
| R06 | Who may end another person's SOS; multi-group Individual SOS | Sender or host may end (existing rule), actor recorded; SOS never crosses groups |
| R07 | Daily semantics | Reminder only in both modes |
| R08 | Community push threshold | Unchanged by this work |
| R09 | Trial wording, legal/age/privacy disclosure | App shows the §9 disclosure from store data (trial only when the store reports an eligible free intro offer); legal sign-off still needed |
| R10 | Points vs XP | Unchanged |
| R11 | Family/group Places limits, Family-area rename | Group Places unchanged and separate from personal saved places |

Also needs an owner decision: whether to convert existing guest rows to
adults (§4).

## 7. Launch blockers

1. Frontend remainder: onboarding ALRT + step, 402 upsell routing on
   connection features, SOS recipient preview before sending. Paywalls,
   My plans, colours and wording are done (widget-tested, not on a device).
2. Store products, subscription groups, offers and RevenueCat mapping
   (C1 to C12) not created or verified.
3. R01, R02, R03, R04 need decisions before billing is enabled.
4. Existing `plus` purchasers need re-sync or mapping (C15).
5. No store-sandbox or device evidence for any purchase, restore or push.
6. Earlier launch items still open per the release chat (iOS signing and
   build, APNs, Maps, Apple sandbox, TEST source sync, real-device push)
   were not rechecked here.

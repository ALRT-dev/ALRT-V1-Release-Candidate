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

## Status (29 Sep 2026, after the review of `28bdec1`)

Most V1 functionality is implemented. The five code-review findings on
`cb26a8d` have fixes with local regression tests (§2a). The independent
review of `28bdec1` found seven further findings (§2b); fixes for all
seven are on the working branch, but this session's sandbox could not run
either backend script (Prisma's engine download is blocked) or any
Flutter tooling (no toolchain, pub.dev also blocked), so every §2b fix is
Static evidence only - none are Local test, Flutter test or otherwise
run. All twelve findings across both rounds are awaiting verification
(independent review, deployed TEST and device checks), not closed.
Product decisions (14 open, §6), configuration (§3) and migration work
(§4) remain. Deployed TEST, real store-sandbox and real-device validation
have not been performed. Launch readiness has not been established.

Evidence levels used below:

| Label | Meaning |
|---|---|
| Static | Read in the code at the stated commit |
| Local test | Ran against a local backend and throwaway Postgres+PostGIS, store events simulated with authenticated RevenueCat webhook calls (and, for subscription changes, a fake RevenueCat server API served by the test script) |
| Flutter test | Flutter unit/widget test with a fake store, fake backend or fake location source |
| Test render | PNG of the real Flutter screen rendered in a test, sample store prices; a picture of the code, not of a phone |
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

Branch `claude/alrt-subscription-audit-r4szxr`. The follow-up review
(29 Sep 2026) was addressed on top of `a27cdd7` (recorded head before
editing; no newer work existed). Commits:

| Commit | Content |
|---|---|
| `f3f6f7d` | Backend access model |
| `51b4f27` | App plans and Ask ALRT |
| `7e8a995` | Backend subscription changes and refusal codes |
| `11eac94` | App colours, upgrades, Restore, refusals, SOS preview, onboarding |
| `7ca4e30` | Review: backend SOS validation/location, effective time, Restore matching, upgrade recovery |
| `998a3a2` | Review: app location freshness, SOS choices, backend-driven preview |
| `7f98fb7` | Review: app Restore per purchase, dated changes, upgrade recovery |
| `cb26a8d` | Review: documentation corrections and this table |
| `67ebf9e` | Review of cb26a8d: backend fixes for findings 1, 2, 4, 5 and verify_v1_findings_round2 |
| `ace1e8d` | Review of cb26a8d: app fixes for findings 1 to 4 and their tests |
| `e94f2f8` | Review of cb26a8d: older-app SOS points routed across the sender's groups |
| (this commit) | Reports corrected for the review of cb26a8d |

TEST keeps `BILLING_ENABLED=false`, under which every access check
answers yes exactly as before. "None" = not performed. No row has
deployed-TEST, store-sandbox or real-device evidence.

Scenario ids: **B-** local backend scripts (`backend/src/scripts/`):
`AM` verify_v1_access_model (30), `SC` verify_v1_subscription_changes
(10), `RF` verify_v1_review_followup (21), `EB`
verify_effective_tier_boundary (5), `LC` verify_family_location_consent
(40), `R2` verify_v1_findings_round2 (11, run on a server WITHOUT
`REVENUECAT_SECRET_API_KEY`). **F-** Flutter tests (`frontend/test/`):
`SP` alrt_plus_store_price_screens (9), `RR` v1_restore_refusal_preview
(26), `UR` v1_upgrade_restore_onboarding (10), `SN`
family_sos_screen_navigation (21), `SF` family_sos_flow (13), `LF`
location_fix (10), `S2` sos_review_round2 (5). **R-** test renders (13
PNGs, sample prices). The revised SOS send screen, the running-SOS
controls and the one-group list editor have NO render.

| # | Requirement | Status | Commit | Static | Local backend | Flutter | Render | TEST | Sandbox | Device | Remaining limitation |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Personal access and group coverage separate | Implemented | f3f6f7d | Yes | AM pass | SP, UR pass | R-06/07 | None | None | None | Real store products unverified |
| 2 | Canonical subscriptions; idempotent, ordered webhook; env/app filters; refunds; TRANSFER | Implemented | f3f6f7d | Yes | AM (10 cases), RF duplicates/out-of-order pass | n/a | n/a | None | None | n/a | Real RevenueCat payloads unverified |
| 3 | Personal limits (1 place + 3 Ask on Free; unlimited + 10 on ALRT +); sponsorship never raises them | Implemented | f3f6f7d | Yes | AM pass | SP pass | R-08 | None | None | None | Ask counting unit is R03 |
| 4 | Seats and group cap removed; creating/joining free | Implemented | f3f6f7d | Yes | AM pass | SP pass | n/a | None | n/a | None | Unsponsored group size is R01 |
| 5 | Unsponsored groups need each participant's ALRT +; lapse pauses only that person | Implemented | f3f6f7d | Yes | AM pass | n/a | n/a | None | None | None | |
| 6 | Family 6 / Group 20 / Group 50 cover one group; concurrent joins | Implemented | f3f6f7d | Yes | AM pass (race) | n/a | n/a | None | None | None | |
| 7 | Sponsorship bound to the group chosen before checkout | Implemented | f3f6f7d | Yes | AM pass | UR pass | R-04/05 | None | None | None | |
| 8 | ALRT + and a group plan coexist; tier change keeps ALRT + | Implemented | 7e8a995 | Yes | AM, SC, RF pass | UR pass | n/a | None | Unverified (C2, C24) | None | Store grouping must allow both |
| 9 | Sponsorship lapse pauses only its group | Implemented | f3f6f7d | Yes | AM pass | RR pass | R-11 | None | None | None | Expiry policy R04 |
| 10 | Connection features gated per person per group; stop/end never gated | Implemented | f3f6f7d | Yes | AM, RF pass | n/a | n/a | None | n/a | None | |
| 11 | Guests retired; existing rows untouched and restricted | Implemented (no conversion) | f3f6f7d | Yes | AM pass; guest report run on local data only | n/a | n/a | Guest rows NOT inspected | n/a | n/a | G1 open |
| 12 | SOS validated before any location write, notification or broadcast; older apps' live points reach only the SOS audience | Implemented; finding 2 fix awaiting verification | 7ca4e30, 67ebf9e, e94f2f8 | Yes | RF as before; R2: the exact older-app request (no `purpose`) during a live SOS reaches the selected recipient only, not an unselected member, not the group snapshot, also when it names another group; refused (409) during a non-live SOS; labelled manual shares unchanged | S2 (`purpose` sent) | n/a | None | n/a | None | Older apps keep their old screens (no consent controls); their manual shares during a live SOS are narrowed to the SOS audience; minimum supported version is R14 |
| 13 | SOS location: No location / Share location once / Share live location, explicit, within the SOS audience, changeable while it runs | Implemented; finding 1 fix awaiting verification | 7ca4e30, 998a3a2, 67ebf9e, ace1e8d | Yes | RF as before; R2: precise live SOS reduced to suburb only then stopped: stored point and trail deleted, recipients told, next update stays suburb only / refused, recipient reads show no coordinates; lowering group sharing narrows, raising it never widens; explicit re-enable works; only the sender can change it | SN precision (2), S2 controls (2) | None | None | n/a | None | Precedence between SOS consent and later group changes is provisional (R12); background live sharing on a locked phone not tested |
| 14 | Precision enforced before delivery (SOS and Journey) | Partial | 7ca4e30, 67ebf9e | Yes | RF, LC pass; R2 SOS precision follows the per-SOS choice | SF, SN pass | n/a | None | n/a | None | SOS has its own per-SOS precision; Journey has NO per-journey choice and follows the group setting at each point ("off"/"alerts only" = suburb label). Keeping Journey consent distinct is not implemented (R12) |
| 15 | Location freshness: current / last known (with age) / unavailable; never "now" for an old point; judged again at SOS send | Implemented; finding 3 fix awaiting verification | 998a3a2, ace1e8d | Yes | RF capture time stored | LF (10); SN (6 new): fresh at open, clock moved 3 min: relabelled with age; Once sends the old point only if shown as last known, with its real time; Live never starts from it; refresh at send is used; aged during the hold without refresh: sent without location and said so; No location still sends | None | None | n/a | None | Static review finding, not reproduced by a test on cb26a8d (the tests need the new clock seam); real GPS timing needs a device |
| 16 | SOS preview = backend eligibility, re-checked at send; delivery never promised | Implemented | 7ca4e30, 998a3a2 | Yes | RF: lapsed excluded, removed member (outdated / empty), mixed-group and other-group-only presets, no people, none eligible, device flag | SN (7) pass | n/a | None | n/a | None | "No device registered" is the only delivery signal |
| 17 | One group per SOS list in the editor, the API and the send; preset repair opens that preset; Invite only when nobody else exists | Implemented; finding 4 fix awaiting verification | 998a3a2, 67ebf9e, ace1e8d | Yes | R2: create and update of a mixed list refused (422 SOS_PRESET_OTHER_GROUP); an old mixed list is reported `needsRepair`; once repaired it saves and the send accepts it (recipients = that group's person) | SN (this group's lists only, other group's default not preselected); S2: mixed list opens with a repair notice and saves one group; switching group clears picks | None | None | n/a | None | Several groups in one SOS is a separate future proposal |
| 18 | Scheduled changes applied at their effective time, including consecutive changes | Implemented; finding 5 fix awaiting verification | 7e8a995, 7ca4e30, 67ebf9e | Yes | SC, RF, EB as before; R2 (no server key): Group 50 -> Group 20 takes effect, no event in between, payer schedules Family: stays Group 20 (capacity 20) until Family is in effect, never Group 50; duplicate ignored, older event ignored, Individual unaffected; reconcile says unchecked | UR dated note | n/a | None | NOT verified: real store event shapes | None | Needs sandbox |
| 19 | Upgrades Family -> Group 20 -> Group 50 keep the group and ALRT + | Implemented | 7e8a995, 11eac94 | Yes | SC (Google new transaction x2, App Store same transaction) | UR (Android replacement id, iPhone none) | R-09 | None | NOT verified | None | Play replacement mode and App Store levels (C5, C24) |
| 20 | Ambiguous upgrade: complete payer recovery | Implemented | 7ca4e30, 7f98fb7 | Yes | RF: plain bind refused with replaceable flag, other user 403, payer replaces own smaller plan, old plan's expiry harmless, smaller/other payer refused | UR pass | n/a | None | None | None | ALRT cannot cancel the replaced store subscription; the app tells the payer |
| 21 | Restore confirms the specific purchases | Implemented | 7ca4e30, 7f98fb7 | Yes | RF: ALRT + active + Family pending = partial; outage/no key = unchecked; unknown and not-on-server ids; unbound confirmed | RR (9), UR (4) pass | n/a | None | None | None | Server key (C22) needed for "pending"; without it answers are "unchecked" |
| 22 | Coded refusals answered for what they are | Implemented | 7e8a995, 11eac94 | Yes | SC, RF pass | RR pass | R-11/12/13 | None | n/a | None | |
| 23 | Optional onboarding ALRT + step | Implemented | 11eac94 | Yes | n/a | UR pass | R-10 | None | n/a | None | |
| 24 | Product identity: ALRT + purple, Family green, Group 20/50 blue; `individual` entitlement stays separate internally | Implemented | 11eac94 | Yes | n/a | RR pass | R-01 to R-13 | None | n/a | None | Green near Check in green: device check |
| 25 | Ask ALRT 3/10 per local day | Implemented | 51b4f27 | Yes | Functions unit tests (36; not re-run this round, unchanged) | n/a | n/a | None | n/a | None | Charging/refund/retry contract unapproved (R03) |
| 26 | Store / RevenueCat / Firebase configuration | Unverified | n/a | n/a | n/a | n/a | n/a | None | None | None | See §3 |

Note on row 12 (supported-client policy, `67ebf9e`, `e94f2f8`): app
builds from before `998a3a2` send live SOS points to the ordinary
`POST /api/family/location` without a `purpose`. Current builds send
`purpose: "manual"` for ordinary shares and use
`POST /api/family/sos/:id/location` for SOS points. When the sender has a
live SOS in any of their groups, an unlabelled post is treated as that
SOS's point (SOS audience and precision only, never the group snapshot);
while a non-live SOS runs it is refused (409). With no SOS running it is
an ordinary share, as before. Consequence for old builds: an ordinary
share made during an SOS reaches only the SOS audience or is refused.

### How the backend decides purchases and changes

- **Verified webhooks.** Access comes only from RevenueCat webhook
  events that pass the shared-secret check, the environment and app-id
  filters, the event-id idempotency check and the newest-event-wins
  order. The app never writes access.
- **Verified server reconciliation (optional).** With
  `REVENUECAT_SECRET_API_KEY` (C22) the backend reads RevenueCat's own
  subscriber record, server to server, to (a) confirm a requested change
  has taken effect and (b) report store purchases whose webhook has not
  arrived. It never grants access from that read, and a missing key or an
  unavailable API is reported as "unchecked", never as a match.
- **Requested vs effective changes.** `PRODUCT_CHANGE` is a request:
  `pendingTier` only. A later event on that transaction naming the new
  product applies it; if that event's new period starts in the future
  (advance renewal), `pendingEffectiveAt` records the start and the
  current tier and capacity hold until exactly then.
- **Upgrades.** The current payer asks for a bigger tier; the intent
  names the subscription it replaces. Android buys with a Play
  replacement (prorated); the App Store upgrades within its group. A new
  transaction that replaces the plan takes over the same group; the old
  row is superseded. With two possible plans to replace, nothing is
  guessed: the purchase stays unbound and the payer explicitly chooses,
  including replacing their own smaller plan (`replaceExisting`).
- **Restore.** The app sends the product ids the store found; the
  backend only looks them up against its verified records (and, when it
  can, the store's server record) and answers per product.

### New backend API for the app

| Endpoint | Purpose |
|---|---|
| `GET /api/access` | `{ billingEnabled, personal: { plan, reason, isTrial, expiresAt, willRenew, extraSavedPlaces, askPerDay }, groups: [{ circleId, name, role, fundingMode, peopleCount, capacity, sponsorship: { tier, live, status, expiresAt, coveredBy, youPay }, connectionAccess: { allowed, reason } }], unboundSponsorships, computedAt }` |
| `POST /api/access/sponsorship-intents` `{ circleId, tier }` | Before the store sheet opens. First plan: host only, capacity checked, refused if the group already has a live plan. Upgrade: only the current payer, only a bigger tier; answers `replaces: { tier, productId, store }` so Google Play can replace it. Smaller tiers: refused (`CHANGE_IN_STORE`), changed in the store at renewal |
| `POST /api/access/sponsorships/:id/bind` `{ circleId, replaceExisting? }` | The payer applies an unmatched group purchase to one group, once. With `replaceExisting`, the payer replaces their OWN smaller live plan on that group; answers `replaced: { tier, mayStillRenew }` |
| `POST /api/access/groups/:circleId/individual-funding` | Host explicitly returns a lapsed sponsored group to individual funding |
| `GET /api/family/circles` | Adds `fundingMode`, `capacity`, `sponsorshipLive`, `connectionAccess`; `seatCount` is now just the headcount (deprecated) |
| `GET /api/user/location-subscriptions` | Adds `isPaused` per saved place |
| `POST /api/access/reconcile` `{ productIds? }` | `{ store: { checked, confirmedChanges, unrecorded, products: [{ productId, tier, status: confirmed/pending/notFound/unchecked/unknown, bound }] }, access }` |
| Sponsorship in `/api/access` | Adds `pendingTier`, `pendingEffectiveAt`; `productId` and `store` for the payer only |
| `POST /api/family/sos` | Adds optional `locationMode` (none/once/live), `locationPrecision`, `locationCapturedAt`, `locationAccuracyM`. Validates everything before any side effect. Never writes the group snapshot |
| `GET /api/family/sos/preview?sosListId=` | `{ state: ok/noPeople/noneEligible/presetInvalid/senderNoAccess, preset: { id, name, state: ok/outdated/otherGroup/empty }, recipients: [{ memberId, name, deliveryLimited }], excluded: [{ memberId, name, reason }] }` |
| `POST /api/family/sos/:id/location` | The sender's live point for a live SOS: audience only, current points only, at the SOS precision |

Refusals carry `{ error, code, details }`. Codes: `INDIVIDUAL_REQUIRED`
(402), `GROUP_PLAN_ENDED` (402), `SAVED_PLACE_LIMIT` (402), `GROUP_FULL`
(409 sponsored / 400 technical cap, `details.capacity`),
`GROUP_ALREADY_COVERED`, `PLAN_TOO_SMALL`, `CHANGE_IN_STORE` (409),
`HOST_ONLY`, `PAYER_ONLY` (403), `NO_SOS_RECIPIENTS` (422,
`details.hasCandidates`, `sosListId`, `presetState`),
`SOS_PRESET_OTHER_GROUP` (422, `details.sosListId`).

## 2a. Review of `cb26a8d`: the five findings

"Reproduced" = the regression script failed on `cb26a8d` (run from a
worktree at that commit, same local database, server without the
RevenueCat server key: 6 of 10 checks failed) and passes on the fix.
"Static" = found by reading the code; not reproduced by a test on
`cb26a8d`. "Awaiting verification" = fixed with local tests only; no
independent review, deployed TEST or device check yet.

| # | Finding | Evidence of the defect | Status | Fix | Regression scenario and actual result | Remaining limitation |
|---|---|---|---|---|---|---|
| 1 | SOS location consent changes ignored during an active SOS | Reproduced (3 checks failed on cb26a8d: a later point restored precise, coordinates and trail kept, group narrowing ignored) | Fixed; awaiting verification | 67ebf9e (backend), ace1e8d (app) | R2: start precise live SOS, send a point; reduce to suburb only: stored coordinates null, SOS trail deleted, recipient socket told, next point delivered suburb only, recipient reads show no coordinates. Stop sharing: point and label cleared, next update 409. Group sharing lowered to approximate then off: SOS narrowed then stopped; raised back to precise: update still 409 (not widened); explicit re-enable: precise point stored. Only the sender may change it (404 for others). App: S2 controls call the endpoint and the view updates; SN per-SOS Exact / Suburb only sent. All pass | Precedence of SOS consent vs later group changes is provisional (R12); Journey has no separate consent (row 14) |
| 2 | Older apps' live SOS points via `POST /family/location` reach the group | Reproduced (1 check failed on cb26a8d: point written to the group snapshot, no SOS routing) | Fixed; awaiting verification | 67ebf9e, e94f2f8 | R2: the exact older request (no `purpose`) during a live SOS: selected recipient gets `familySosLocation`, unselected member gets nothing, group snapshot and group pings untouched; same when the request names another group; after the sender stops sharing: 409, nothing written; labelled manual share during an SOS: ordinary group share delivered; no SOS: ordinary share. App S2: `purpose: "manual"` sent. All pass | Old builds keep old screens; minimum supported version is R14 |
| 3 | SOS activation does not recheck freshness | Static (the tests need the new clock seam, so they cannot run on cb26a8d) | Fixed; awaiting verification | ace1e8d | SN with a controlled clock: fresh fix at open, clock moved 3 minutes: relabelled "last known, 3 min ago"; Once: old point sent with its real capture time because it was shown as last known; Live: SOS sent live with NO starting point; Live with a refresh available: fresh point used; Once shown as current but aged during the hold, no refresh: sent without location and the sender told; No location: still sends. All pass | Real GPS timing and the 4-second refresh on a device not checked |
| 4 | SOS list editor allows several groups | Reproduced (1 check failed on cb26a8d: a mixed list was created, 201) | Fixed; awaiting verification | 67ebf9e, ace1e8d | R2: mixed create and update refused 422 `SOS_PRESET_OTHER_GROUP`; old mixed list reported `needsRepair: multipleGroups`, repaired, then the send accepts it. App S2: mixed list opens with a repair notice and saves only the chosen group; switching group clears picks (nothing hidden kept). SN: only this group's lists offered. All pass | Multi-group SOS is a separate future proposal |
| 5 | A second scheduled change resurrects the pre-change tier | Reproduced (1 check failed on cb26a8d: Group 50 came back) | Fixed; awaiting verification | 67ebf9e | R2 on a server without `REVENUECAT_SECRET_API_KEY`: Group 50 -> Group 20 scheduled and elapsed, no lifecycle event in between, payer schedules Family: group stays Group 20 (capacity 20), row tier written as group20, Family pending; duplicate event "duplicate"; older event "ignored"; Family applies only on a store event naming it; ALRT + unaffected throughout. All pass | Real store event sequences need sandbox |

## 2b. Independent review of `28bdec1`: the seven findings

None of the seven are Reproduced or Local test this round: this session's
sandbox blocks `binaries.prisma.sh` at the egress policy (confirmed via
the proxy's own status endpoint, not worked around), so `npx prisma
generate` cannot fetch a query engine and no script - `round2` or the new
`round3` - could run against a live database; the frontend findings also
could not run `flutter analyze`/`flutter test` (no Dart/Flutter toolchain
in this sandbox, and pub.dev is blocked the same way). Every fix below is
Static (read against the diff, traced through the surrounding code and
the existing regression conventions) and needs Local test / Flutter test
evidence from an environment where those hosts are reachable before it
counts as run, not just written. R12 and R14 (older-client support) are
unchanged in spirit; none of these fixes resolve them.

| # | Finding | Evidence of the defect | Status | Fix | Regression scenario (written, not run this session) | Remaining limitation |
|---|---|---|---|---|---|---|
| 1 | Starting Live/Suburb only with no GPS fix left `locationPrecision` unset, so the first later point fell back to the group's ordinary sharing level | Static: `triggerSos` stored `locationPrecision` only inside the `hasPoint` spread, unlike the already-unconditional `locationMode` | Fixed; Static only | `42dcc63` | round3 #1: create Live/approximate with no point; row already reads `locationPrecision: approximate`; first point stays approximate | Needs Local test against a live database |
| 2 | An in-flight `recordSosLocation` upload read precision before a slow suburb lookup, then wrote it back unconditionally, able to restore a wider share after a concurrent Stop/Suburb only completed | Static: the read-then-slow-await-then-unconditional-`update` shape in `recordSosLocation`, plus a second, narrower gap where `setSosLocationConsent`'s own trail purge was a separate statement from its row update | Fixed; Static only | `42dcc63` | round3 #2: a live point and a concurrent Stop fired together, looped 5x, asserting the row never reads stopped with a restored point | Needs Local test with real timing; the fix is an optimistic lock (row `updatedAt`) plus a one-shot re-read-and-retry, not a controllable delay, so the regression checks the invariant rather than forcing the exact interleaving |
| 3 | An unlabelled point with no live SOS to route to (none running, or more than one live at once in different groups) fell through to the ordinary group snapshot, reading absence/ambiguity as manual-sharing consent | Static: `shareLocationSnapshot`'s `if (running) {...}` had no `else` - it fell through past the whole block | Fixed; Static only | `5a21bd3` | round2's existing "no SOS running" check corrected from asserting the old fallback to asserting refusal; round3 #3 adds two-groups-at-once, refused, then unambiguous once one ends | Needs Local test; round2's OTHER older-app checks (selected/unselected recipient, another group named, stop then refused, labelled manual share) were not re-run either |
| 4 | The app never listened for `familySosLocation` at all; a locally cached trail could also outlive a consent reduction that arrived by a slower, superseded poll response | Static: no `familySosLocation` handler anywhere in `lib/`; `family_sos_receiver_screen.dart`'s 25s trail poll had no ordering guard | Fixed; Static only | `e125cae` | None written this session - Flutter-only, needs a widget test driving `debugReceiveSosLocation` and the corrected `_refreshTrail` | Needs a Flutter test (fake socket payloads, fake out-of-order poll responses) and a render check |
| 5 | Stop/Suburb only were shown only for Live; a Once/Exact sender had no way to remove or reduce the retained location while the SOS stayed active | Static: `_sosLocationControlsBuilder`'s `else` branch offered only "Share live location" | Fixed; Static only | `e125cae` | round3 #4 confirms the backend endpoint already supports reducing then withdrawing a Once snapshot without ending the SOS; the new UI controls themselves are not covered here | Needs a Flutter widget test and a render check of the new Once controls |
| 6 | The SOS hold-start handler recomputed the fix's freshness fresh at the instant of touch, so a fix that went stale between two 15s repaints could count as accepted "last known" even though the screen still showed "current" wording | Static: `onTapDown` read `_fixNow` (always recomputed) rather than what the last `build()` had painted | Fixed; Static only | `e125cae` | None written this session - needs a Flutter test that ages a fix between two frames without an intervening rebuild and asserts `_acceptedLastKnown` stays false | Needs a Flutter test with a controlled clock, mirroring round2's app-side clock-seam tests for finding 3 of `cb26a8d` |
| 7 | Four StoreSubscription writes (`materializeDueChange`, the webhook's main write, `recordPendingChange`, the reconcile confirm loop) read-decided-wrote without a guard, so a concurrent write to the same row could be overwritten by an older snapshot, reverting a newer scheduled or confirmed tier | Static: each was a plain `prisma.storeSubscription.update` based on a row read one or more awaits earlier, outside any transaction | Fixed; Static only | `5353b66` | round3 #5: a scheduled change becoming due and a fresh PRODUCT_CHANGE request, fired together, still land on the elapsed tier, never an older one | Needs Local test; `bindSponsorship`/`replaceSponsorship` were already safe (fresh read inside the same transaction, or disjoint fields) and are untouched |



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
| C19 | Database migration | Not verified; not applied by this work | `20260928000000_v1_access_model` applied TEST then prod | `prisma migrate deploy` | Migration | Engineering | D1 | See §4 | Tables present |
| C20 | Apple/Google test identities | Not verified | Sandbox testers for eligible and ineligible trial, Family payer, member | Create | Config | Owner | C1, C4 | n/a | Test matrix §5 |
| C22 | Backend env `REVENUECAT_SECRET_API_KEY` (optional) | Not verified; not set by this work | RevenueCat secret (server) API key per environment, read-only use: `GET /v1/subscribers/{id}` to confirm pending changes and spot unrecorded purchases. Never shipped in the app | Add as a secret on TEST first | Config | Owner | C8 | Remove env (pending changes then wait for store events) | Sandbox App Store upgrade shows the new tier within a minute |
| C23 | Database migration 2 | Not verified; not applied by this work | `20260929000000_v1_subscription_changes` (additive columns) after C19 | `prisma migrate deploy` | Migration | Engineering | C19 | Drop the added columns | Columns present |
| C24 | App Store subscription group levels | Not verified | Group 50 highest, Group 20, Family lowest in the group-plans subscription group, so moving up is an upgrade (immediate, prorated refund) and down is a downgrade (at renewal) | Set levels | Config | Owner | C2 | Reorder before first sale | Sandbox: Family -> Group 20 immediate; Group 50 -> Family at renewal |
| C25 | Database migration 3 | Not verified; not applied by this work | `20260930000000_v1_review_followup` (additive columns) after C23 | `prisma migrate deploy` | Migration | Engineering | C23 | Drop the added columns | Columns present |
| C21 | Store listing / legal copy | Not verified | Individual trial wording per platform, group "no trial", SOS safety statement | Legal review | Decision (R09) | Owner | | | Sign-off |

## 4. Migration, rollout and rollback

Migration `20260930000000_v1_review_followup` (additive: SOS
`locationMode`, `locationPrecision`, `locationCapturedAt`,
`locationAccuracyM`; `FamilyLocationPing.sosEventId`;
`StoreSubscription.pendingEffectiveAt`) goes third. Verified locally by
applying all three to a copy of the `ea93889` schema and diffing against
`schema.prisma` (only pre-existing PostGIS index noise).

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
- Guests: no new guests can be created. Existing guest rows are NOT
  converted and keep their restrictions (no location requests, cannot
  host). Before any decision, run the read-only
  `inspect_guest_members.ts` on TEST and production (G1).
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

## 5. Test results (local only)

Latest run, 29 Sep 2026, for the review of `cb26a8d`. Backend suites ran
against code at `e94f2f8`; app suites at `ace1e8d` (no app change since).
Local Postgres+PostGIS, simulated RevenueCat webhooks. Three local
servers: billing on with a fake RevenueCat server API, billing off, and
billing on WITHOUT `REVENUECAT_SECRET_API_KEY` (for R2).

| Script | Server | Result |
|---|---|---|
| verify_v1_findings_round2 (new) | billing on, no server key | 11 passed, 0 failed. On `cb26a8d` (worktree, first 10 checks): 4 passed, 6 failed (findings 1, 2, 4, 5 reproduced; the consent-owner check "passed" there only because the route did not exist) |
| verify_v1_review_followup | billing on | 21 passed. One check changed: its "ordinary snapshot during an SOS is not trail data" step now sends `purpose: "manual"`, because an unlabelled post during a live SOS is now, by design, an SOS point (finding 2). Before that edit it failed 20/21 on the fixed code |
| verify_v1_access_model | billing on | 30 passed |
| verify_v1_subscription_changes | billing on | 10 passed |
| verify_effective_tier_boundary | no server | 5 passed |
| verify_saved_location_limit | billing on / off | 5 passed / 3 passed |
| verify_family_location_consent | billing off | 40 passed |
| verify_sos_history / circle_list_state / targeted_check_in_request / family_leave_and_alert_link / stage9a_journey_recipient | billing off | 8 / 5 / 14 / 12 / 13 passed |
| verify_severity_override_phrases | no server | 18 passed |
| `tsc --noEmit` | | Clean apart from the pre-existing `serviceAccountKey.json` import |

App (`ace1e8d`): `flutter test` 382 passed, 33 skipped (the opt-in
screenshot renders, `ALRT_SCREENSHOTS=1`; not run this round).
`flutter analyze`: 6 infos, all in files this work did not touch. New
this round: 9 tests in family_sos_screen_navigation (now 21) and
sos_review_round2 (5).

Not performed or not rerun: deployed TEST checks, store-sandbox
purchases, real-device runs, the 33 opt-in renders (none exist for the
revised SOS screen, running-SOS controls or list editor), Ask ALRT
functions unit tests (unchanged, not rerun). Passing local tests show the
scenarios listed; they are not evidence for anything they do not cover.

## 5a. Test results, review of `28bdec1` (not run this session)

Backend fixes at `42dcc63`/`5a21bd3`/`5353b66`; `verify_v1_findings_round3`
added at `e276198`; frontend fixes at `e125cae`. Nothing in this row was
executed - it records what would need to run, not a result:

| Script | Server | Result |
|---|---|---|
| verify_v1_findings_round3 (new) | billing on, no server key | Not run: this sandbox's egress policy blocks `binaries.prisma.sh`, so `npx prisma generate` cannot fetch a query engine and no server could even start against a real database |
| verify_v1_findings_round2 (its "no SOS running" check corrected) | billing on, no server key | Not rerun for the same reason; the correction itself is Static only |
| `npx tsc --noEmit` | | Not usefully run: the same block leaves `@prisma/client` as an untyped stub, so the whole codebase (not just the touched files) reports missing-member/implicit-any errors unrelated to this change. Filtered by hand to the touched files' own diagnostics, plus a standalone TypeScript syntax parse (`ts.transpileModule`) of every edited file: no errors beyond the stub-client noise |
| `flutter analyze` / `flutter test` | | Not run: no Dart/Flutter toolchain in this sandbox, and its egress policy also blocks pub.dev, so one could not even be installed |

Before this round's evidence can move past Static: run
`verify_v1_findings_round2`/`round3` against a local Postgres+PostGIS in
an environment where `binaries.prisma.sh` is reachable, and run `flutter
analyze`/`flutter test` (plus a render of the new Once controls) in an
environment with the Flutter SDK and pub.dev access.

## 6. Open decisions: current provisional behaviour

Nothing in this table is approved. "Now" is what the code does,
provisionally. "Proposal" is a suggestion only: none of the proposals are
implemented. These are product decisions, not implementation defects
(defects are in §2a). Open: 14 (R01 to R12, R14, G1). R13 is closed by
the reviewer's one-group rule.

| ID | Decision | Now (provisional, in code) | Proposal (NOT approved, NOT in code) |
|---|---|---|---|
| R01 | Capacity of groups with no Family/Group plan; pending members | Technical `maxMembers` (10) applies; joins immediate | A higher technical limit (for example 50); no pending state |
| R02 | Repeat sponsorships, payer leaving, reassignment, over-capacity downgrade | One live plan per group; only the payer can upgrade; smaller plans change in the store at renewal; an over-capacity downgrade blocks joins and removes no one. Leaving the group does NOT stop the store subscription: it keeps renewing (and keeps covering the group) until the payer cancels it in the store | Tell a payer who leaves that their subscription continues until they cancel it in the store; decide whether coverage should continue after the payer leaves |
| R03 | Ask ALRT: what is counted, and failure/retry charging | Counted BEFORE the AI call: a model failure, a timeout, a safety refusal and a lost response all count; each retry counts again; library and emergency answers and "AI switched off" never count | Count only delivered AI answers: refund on model failure, request ids so a retried question counts once |
| R04 | Access ending during an SOS or Journey; which free saved place stays | A running SOS keeps its live share to the 4-hour cap; a running Journey runs to its end time but can't be extended; the OLDEST saved place stays active, the rest pause (none deleted) | Let the person choose which saved place stays |
| R05 | Retention | Locations deleted on schedule (1-hour snapshots, 4-hour SOS, journey on end); everything else (SOS/check-in history, webhook receipts, subscription rows, Ask counters) has no end date | Set retention periods (for example 12 months for history) and publish them |
| R06 | Who may end someone else's SOS; multi-group SOS | Sender or host, actor recorded; one group per SOS | Keep as is |
| R07 | Daily | Reminder only | Remove the "automatic" option from settings |
| R08 | Community reports | Publication and push are separate. Publication: accepted by AI review -> shown on the map and list. Push: sent at once to nearby people who opted into community alerts; no corroboration, no quiet hours | Separate push authorization from publication (for example corroboration or quiet hours); rules to be decided |
| R09 | Trial and legal wording | Store-driven disclosures | Legal review |
| R10 | Points vs XP | Unchanged | Decide separately |
| R11 | Group Places; Family tab name | No limit; free; adults and host manage | An abuse limit; rename with store screenshots |
| R12 | Precedence between explicit SOS/Journey location consent and ordinary group sharing | SOS: the sender chooses None / Once / Live and Exact / Suburb only per SOS (default from group sharing); that choice can be finer than group sharing. While it runs, LOWERING group sharing narrows it (approximate -> suburb only; off or alerts only -> stops sharing); RAISING group sharing never widens it; the sender can widen it again only with the SOS's own control. Journey: no per-journey choice; each point follows the group setting ("off"/"alerts only" = suburb label, never coordinates). "Off" is never treated as "approximate" for a running SOS | Exact question: when a person gives explicit SOS or Journey consent and later changes ordinary group sharing, which wins? And should Journey get the same per-journey choice as SOS? |
| R13 | SOS lists spanning groups | CLOSED: one group per list in editor, API and send (reviewer instruction, `67ebf9e`, `ace1e8d`) | Multi-group SOS is a separate future proposal |
| R14 | Older app builds (supported-client policy) | Unlabelled `POST /family/location` during a live SOS goes to that SOS only; refused while a non-live SOS runs, with no live SOS at all, or with more than one live at once in different groups (corrected by finding 3 of the `28bdec1` review, `5a21bd3` - it previously fell through to ordinary group sharing in the no-SOS and ambiguous cases). No minimum version is enforced | Set a minimum supported app version (forced update) before billing is switched on |
| G1 | Existing guest members | Not converted; keep guest restrictions; count as people | Inspect TEST/production with the read-only report first; then decide per host. No blanket conversion to adult |

### Ask ALRT: failure and retry charging, exactly as coded

1. Library answers and emergency-number answers: free, never counted.
2. AI switched off (Remote Config kill switch): error, not counted.
3. Daily limit reached: refused before counting, not counted.
4. Otherwise the question is counted FIRST, then the AI is called:
   - model error or timeout: "Ask ALRT is unavailable right now. Please
     try again." and the question stays counted;
   - a safety refusal from the model: counted;
   - the answer is produced but the phone loses the response: counted,
     and asking again counts again.
5. This is the current code, not an approved rule (R03).

### Guest records

`backend/src/scripts/inspect_guest_members.ts` is read-only. It was run
only on the local test database. TEST and production guest rows have NOT
been inspected (no access from this session). No conversion is proposed
or implemented.

## 7. Launch blockers and checks still needed

1. Store products, subscription groups and levels, offers, Play
   replacement and RevenueCat mapping (C1 to C12, C22, C24): live state
   unverified; nothing was created or changed by this work.
2. Real RevenueCat event sequences for upgrades, scheduled downgrades and
   advance renewals must be confirmed in sandbox.
3. Decisions: 14 open (R01 to R12, R14, G1); R01 to R05, R08, R12, R14
   and G1 affect launch.
4. Existing `plus` purchasers need re-sync or mapping (C15).
5. Migrations 1 to 3 applied to TEST (not done).
6. Device checks: the SOS hold button reachable without scrolling on
   small phones and with large text; location permission prompts; real
   GPS freshness and accuracy; live SOS points while the phone is locked;
   push delivery; the Family green next to the Check in green.
7. Earlier launch items (iOS signing and build, APNs, Maps, Apple sandbox,
   TEST source sync) not rechecked here.
8. The five review findings on `cb26a8d` are fixed locally and await
   verification: an independent review of `67ebf9e`, `ace1e8d` and
   `e94f2f8`, then deployed TEST (after migrations) and device checks:
   consent changes seen on a recipient's phone, an older build during a
   live SOS, freshness at send with real GPS.
9. No render of the revised SOS send screen, the running-SOS controls or
   the one-group list editor; a visual check (render or device) is
   needed, including hold-button reachability now that the precision
   choice adds a row.
10. The seven independent-review findings on `28bdec1` are fixed on the
    working branch (`42dcc63`, `5a21bd3`, `5353b66`, `e276198`, `e125cae`)
    but entirely unverified: this session's sandbox blocks
    `binaries.prisma.sh` (no Prisma query engine, so `round2`/`round3`
    could not run) and has no Dart/Flutter toolchain with pub.dev also
    blocked (`flutter analyze`/`flutter test` could not run either).
    Needed before these count as more than Static: run both backend
    regression scripts against a local database, run the Flutter suite
    plus a render of the new Once controls, then an independent review of
    the fix commits themselves, then deployed TEST and device checks -
    the in-flight-upload race (finding 2) and the interleaved
    subscription change (finding 7) especially need real concurrent
    timing, which this session could only exercise as a best-effort
    invariant check (`round3` #2, #5), not a controlled reproduction.

# ALRT backend (Express + Prisma) — locked product rules

These rules are locked. Do not weaken, remove, or "improve" them without an
explicit instruction from the product owner in the current session.

## Safety and privacy (non-negotiable)

- ALRT never contacts emergency services; the disclaimer travels on the
  alert payload itself.
- Location leaves a phone only by the owner's action. No endpoint may
  create a continuous location stream except SOS live share.
- Snapshots expire after 1 hour: keep the event log (who was notified,
  seen, on their way, called, when sharing started/ended), delete the
  location data. Never archive or aggregate expired locations.
- SOS live share caps at 4 hours; on stop the last point is deleted, and
  history keeps only time and duration.
- SOS acknowledgments (product owner 2026-09-03): a "seen" response is an
  explicit recipient action; the sender is told by name. Once an SOS is no
  longer active, respondToSos refuses new responses (closed record), and
  GET /api/family/sos/history returns stood-down events with their
  responses and NO coordinates or location label - regardless of whether
  the purge job has run yet.
- Journeys are snap points by default; live is per-journey opt-in.
- Scheduled snapshots: one point per time, 1-hour expiry, never continuous.
- Call buttons only by advance grant; phone numbers are never returned to
  the caller's client for display.
- Legacy guests never request locations. No mute/snooze for circle SOS
  receipt.
- Daily (scheduled check-ins) only ever sends a reminder; a scheduled job
  never posts a check-in for anyone (open decision R07).
- Severity text overrides (drill/test/resolved) match phrases, never
  substrings: see isInfoOverride and verify_severity_override_phrases.ts.
- Leaderboard responses never identify other users (anonymise name, no
  email/id for anyone but the caller).

## Commercial rules (V1 access model, master spec 28 Sep 2026)

Supersedes the seat model (8 seats / 4 owned circles / free guests) and
the "hosting needs ALRT+" rule. Full record, reconfiguration table and
open decisions: docs/V1_ACCESS_MODEL_IMPLEMENTATION.md. Do not
reintroduce seats, a group-count cap or a single global plan flag.

- entitlement.service.ts is the only place store state becomes access.
  StoreSubscription rows are written only by the authenticated,
  idempotent RevenueCat webhook (event id receipts, newest-event-wins,
  product -> tier via RC_PRODUCT_TIERS, no built-in product ids).
- Personal access = a live `individual` StoreSubscription (or its trial):
  unlimited saved places, 10 Ask ALRT a day. Free: 1 saved place besides
  the own-location follow, 3 Ask ALRT a day. Group sponsorship never
  grants personal benefits, payer included. User.plan and Firestore
  entitlements/{uid} are write-only mirrors of personal access.
- Group access is per person per group (getConnectionAccess):
  `sponsored` groups are covered while their bound Family/Group plan is
  live (capacity 6/20/50 counts everyone in that group, enforced on join
  under a row lock); `individual` groups need each participant to hold
  Individual. One person's lapse never pauses anyone else; a lapsed
  sponsorship pauses only its own group and never switches it to
  individual funding without an explicit host action.
- Gated (402): check in, check on, SOS, Journey start/extend, location
  requests and snapshots. Never gated: stopping, ending, leaving,
  declining, an SOS's own live share while it runs.
- Creating and joining groups is free; there is no commercial cap on
  groups (a technical abuse ceiling of 100 created groups remains).
  Consumer guests are retired: no new guest invites, old guest codes are
  refused, existing guest rows count as people.
- A sponsorship binds once to the group chosen before checkout
  (SponsorshipIntent, host only) or later by its payer; never re-pointed.
- Tier changes (2026-09-28 follow-up): PRODUCT_CHANGE is a REQUEST and
  never moves the active tier; it is kept as pendingTier until a store
  event names the new product on that transaction, or RevenueCat's server
  API (REVENUECAT_SECRET_API_KEY, optional) shows it in effect. Upgrades
  Family -> Group 20 -> Group 50 are started by the current payer with an
  intent that names the subscription it replaces; a new store transaction
  (Google replacement) takes over the SAME group and the old row is
  superseded, never counted twice. Smaller tiers change in the store at
  renewal. An ambiguous replacement is never guessed (stays unbound).
- Refusals carry a stable `code` (HttpErrorCode): INDIVIDUAL_REQUIRED,
  GROUP_PLAN_ENDED, SAVED_PLACE_LIMIT, GROUP_FULL, GROUP_ALREADY_COVERED,
  PLAN_TOO_SMALL, CHANGE_IN_STORE, HOST_ONLY, PAYER_ONLY,
  NO_SOS_RECIPIENTS, SOS_PRESET_OTHER_GROUP. The app branches on the code,
  never on wording.
- POST /api/access/reconcile only confirms pending changes and REPORTS
  store purchases not yet recorded; it never grants access itself.
- Legacy guests: nothing converts them automatically.
  scripts/inspect_guest_members.ts is a read-only report.
- Billing is still off on TEST (BILLING_ENABLED=false): every access check
  answers yes, exactly as before.
- Hosting and ownership transfer are administrative, not paid: children
  and legacy guests can't host; payer departure/reassignment is open
  decision R02.
- SOS: the audience is stored on the event (recipientUserIds) and every
  read, response, trail, socket and end notification is limited to it;
  no SOS without at least one eligible recipient; a preset naming someone
  in another group is refused (422); no stale stored coordinates. End
  wording is factual ("SOS ended", "[Name] ended their SOS."), never
  "safe" or "resolved".

## Google Maps proxy (decided Stage 5, 2026-08-22)

- `/api/maps/*` (geocode, places/autocomplete, places/details) is the app's
  live call path for Geocoding/Places, not orphaned code — the frontend
  calls it, per `frontend/CLAUDE.md`. Keep `requireAuth` +
  `mapsProxyUserLimiter` on every route; never let a client override the
  injected `key` param (see `pick()` in `maps_proxy.service.ts`).
- Directions/Routes is not proxied here (the frontend's
  `flutter_polyline_points` client calls Google directly) — do not add a
  `/api/maps/directions` route without also updating the frontend to use
  it; a half-migrated proxy is worse than the current split.

## AI alert-generation prompts (decided Stage 6A, 2026-08-22)

- `src/utils/ai-prompt.util.ts` + `src/services/ai-prompt.service.ts`
  (the `DefaultAIPromptNames` / bracket-named prompts) is the **sole**
  authoritative alert-generation prompt system. A second, repo-versioned
  system (`src/prompts/alert_summarization_prompts.ts`, seeded via
  `npm run seed:prompts`) was removed — it covered only 3 of 5 prompt
  groups, silently dropped the locked "never write a specific emergency
  number" rule, and was reachable only via a manual script nothing else
  called. Do not recreate a second prompt-content system; edit prompts
  in the admin panel or in `ai-prompt.util.ts`, not both.
- If `Configuration.aiPrompts` on a given deployment still points at
  snake_case-named prompts from the removed system (any deployment that
  ever ran the old `seed:prompts`), run
  `npm run reset-ai-prompts` once to repoint it at the bracket-named
  defaults. Safe to run on any deployment, including one that's never
  been touched — it's a no-op there.
- Community reports (`reviewHazard`) never carry a call-to-action —
  `callsToAction` is always `[]`. A community report is an unverified
  observation, never an instruction, regardless of how the report reads.
- `reviewHazard`'s `reviewStatus` must reflect what the AI actually
  returned (`mapAiReviewStatus` in `hazard.util.ts`), never a hardcoded
  value — this gates real moderation (spam/abuse/instruction-injection/
  private data rejected, not silently accepted).
- AQI hazards (`SubCategoryId.airQualityAlert`) never call the AI —
  `getDeterministicAirQualityContent` in `air_quality_template.util.ts`
  builds the card content directly from the already-deterministic
  severity band and the AQI value/station name in the source text. Do
  not route AQI back through `executePrompt`.

## Engineering conventions

- `npx tsc --noEmit` must be clean before every push, except the
  pre-existing serviceAccountKey.json import error.
- Migrations are hand-authored SQL in timestamped dirs under
  prisma/migrations/ (match the existing naming).
- Zod validators in src/validators/, thin controllers, logic in
  src/services/.
- Circle-scoped endpoints accept optional ?circleId= and default to the
  user's oldest membership; id-addressed endpoints anchor the circle on
  the resource.
- Australia/Brisbane is fixed UTC+10 (no DST) for day boundaries and cron.
- QLD Traffic API key comes from env (QLD_TRAFFIC_API_KEY); ingestion
  skips the source when empty. Never commit API keys.
- Work happens on branch `claude/safety-alert-repo-audit-8exgvn`.
- Never touch SafetyALRT org repos; never deploy.
- No en-dashes in any output.

## Check-in asks and group-list state (2026-09-04)

- `FamilyCheckInRequest.targetMemberIds` (empty = everyone): a targeted
  ask notifies only its targets, and a member's `latestCheckInRequest`
  is the latest ask that concerns them (everyone, them, or sent by them).
  Never widen an invalid target list to everyone: refuse it.
- `GET /api/family/circles` carries per-group `checkedInCount`,
  `waitingOn` (names) and `activeSos` ({id, memberId, memberName,
  createdAt}). Names and times only; this list must never carry a
  location. Verified by `verify_circle_list_state.ts` and
  `verify_targeted_check_in_request.ts`.

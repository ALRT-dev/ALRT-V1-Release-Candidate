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
- Journeys are snap points by default; live is per-journey opt-in.
- Scheduled snapshots: one point per time, 1-hour expiry, never continuous.
- Call buttons only by advance grant; phone numbers are never returned to
  the caller's client for display.
- Guests never request locations. No mute/snooze for circle SOS receipt.
- Leaderboard responses never identify other users (anonymise name, no
  email/id for anyone but the caller).

## Commercial rules

- Invited members never hit a paywall; join-by-code is free.
- Seats: ALRT+ = 8 seats across up to 4 owned circles (MAX_SEATS_TOTAL=8,
  MAX_OWNED_CIRCLES=4 in family.service.ts). A seat is a (person, circle)
  pair in an owned circle; the host's own membership consumes a seat;
  joining someone else's circle consumes nothing of the joiner's.
- Billing is not launched: every circle defaults to plan `plus`. When the
  entitlement system ships, new circles default to `free`.
- Ownership transfer (§29): eligible = active subscription + enough free
  seats to absorb the whole circle; ineligible members are returned greyed
  with a reason, never hidden.

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

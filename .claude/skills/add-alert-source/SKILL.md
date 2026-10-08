---
name: add-alert-source
description: Onboard a new official alert/warning source into ALRT ingestion, either as an in-code adapter polled by the backend cron or as an n8n workflow that POSTs to the hazards webhook. Use when someone asks to add, connect, register or onboard a new feed, agency, country, API, CAP/RSS/GeoJSON source or n8n flow for alerts/hazards, or asks what is needed to add one.
---

# Add an alert source to ALRT

ALRT has **two ingestion paths**. Both end in the same function,
`summarizeAndPostHazards()` in `src/services/ingestion.service.ts` (backendV2),
which handles dedupe, geocoding, AI summary, confidence score, DB write, push,
socket and family alerts. A new source only has to produce a list of
`HazardDataWithRelations` objects with a stable `id` and a registered `source`.

| | Path A: in-code adapter | Path B: n8n → webhook |
|---|---|---|
| Who fetches | backend cron, every 15 min (`scheduler.service.ts`) | n8n workflow on its own schedule |
| Who parses | a `parseXToHazards()` in `src/utils/ingestion.util.ts` | n8n Code/Set nodes |
| Entry point | `externalSources[]` in `syncHazardsFromDifferentSources()` | `POST /api/webhook/hazards` (`webhook.controller.ts`) |
| Needs a backend deploy | yes | only to register the `HazardSource` row |
| Good for | stable, high-value official feeds (CAP, GeoJSON, RSS) | experiments, HTML/scrape sources, odd auth, fast iteration |

The V1 contract this must satisfy lives in this repo's `SOURCE_REGISTRY.md` and
`V1_SOURCE_PIPELINE.md`. Read them if the request goes beyond a straight feed hookup.

## Step 0: Locate the backend code

The ingestion code lives in `ALRT-dev/backendV2` (being reconciled into this
release-candidate repo). If `src/services/ingestion.service.ts` is not in the
working tree, attach/clone `ALRT-dev/backendV2` and work there. Before editing,
re-read the files named below. They change, and the line numbers here are only hints.

## Step 1: Intake (always, for both paths)

Fill in `references/source-intake.md` for the source and show it to the user
**before writing code**. Do not proceed while any of these are unknown:

- **Authority**: an official/statutory publisher. If it's a trusted secondary
  source (like WAQI), say so explicitly.
- **Licence / terms**: which `HazardSourceLicense` badge applies (`ccBy4`, `ccBy3`,
  `licensed`, `permission`, `pending`). Unknown means `pending`, and flag it to the user.
- **Endpoint, format, auth**: JSON/GeoJSON, RSS/Atom, CAP-AU, XML, HTML. Note
  whether it needs an API key.
- **Stable event ID** field in the payload. This drives dedupe (see Step 4).
- **Geography**: point coords, polygon, or place name only (place names cost a
  Google geocode, and anything that can't be geocoded is **dropped**).
- **Native severity vocabulary**: AWS levels (Advice / Watch and Act / Emergency
  Warning), colours, magnitudes, or none.
- **Update cadence** and whether expired items disappear from the feed.

Fetch a real sample payload (`curl` it) and save it as a fixture next to your
notes. Every parser decision should be checked against real data.

## Step 2: Register the source (always)

Every hazard is linked to a `HazardSource` row. Unknown `sourceId`s are rejected
by the webhook (400) and make the in-code adapter return nothing.

1. Add an enum member to `ExternalSourceId` in `src/services/ingestion.service.ts`.
   Use camelCase in the form `<jurisdiction><Agency>`, e.g. `tasSes`, `nzMetService`.
   The id is permanent: it prefixes every hazard id from this source.
2. Add a matching entry to `hazardSources[]` in `initializeHazardSources()`
   (`src/services/hazard.service.ts`): `id`, `name`, `url` (landing page),
   `copyrightText`, optional `copyrightLink`/`advisoryText`, and `license.connect.badgeText`.
   The list is upserted on every server start.
3. For an n8n-only source with no deploy planned, create the row on live through the
   Admin API (`/api/admin/hazard-sources`, backed by `createHazardSource` in
   `hazard_source.service.ts`). Still add it to the seed list so the next deploy
   keeps it consistent.
4. Add the id to the "Source ID Values" list in `WEBHOOK_CLIENT_DOCUMENTATION.md`.

## Step 3a: Path A, in-code adapter

1. **Parser.** Add `parseXToHazards()` to `src/utils/ingestion.util.ts`. Reuse
   before writing new code:
   - Generic GeoJSON with `title`/`description`/`pubDate` properties: `parseGeoJsonToHazards({ data, availableCategories, idPrefix })`
   - Generic RSS/Atom (georss point, `identifier`/`guid`): `parseRSSFeedToHazards({ url, idPrefix, availableCategories })`
   - CAP-AU Atom (hazardwatch.gov.au style): model on `parseSESToHazards`
   - Clean single-category template: `parseUSGSEarthquakeToHazards`

   Each returned hazard must set:
   - `id`: `` `${ExternalSourceId.x}-${nativeEventId}` `` (never omit if the feed has an id)
   - `title`, `description`: description carries the source wording, including the
     native alert level (e.g. prefix `Alert Level: Watch and Act`), because category
     and severity are keyword-derived from it
   - `latitude`/`longitude` **or** `locationName` (plus bounding box if the source gives an area)
   - `category`, `severity`, `severityBand`, `isAwsCompliant`, `fireStatus` (fire only).
     Either get these from `getHazardAttributesFromDescription(description, availableCategories)`
     or set them explicitly from the source's native fields (preferred when the
     source has a real severity scale, like USGS magnitude/alert colour)
   - `occurredAt`, plus `expiresAt` if the source provides one (otherwise expiry
     is derived from severity), and `link` to the canonical source page
   - `callsToAction` only if the source states instructions. **Never invent
     directives** (V1 rule). Leave it unset and the AI summary step fills suggestions.

   Skip items without coordinates or place names instead of guessing.

2. **Register in the pipeline.** Add an entry to `externalSources[]` in
   `syncHazardsFromDifferentSources()`:
   ```ts
   {
     id: ExternalSourceId.newSource,
     apiUrl: "https://…",                 // or apiUrls: [...] for several endpoints
     fetchOptions: { headers: { Authorization: `apikey ${config.newSourceApi.apiKey}` } },
     severityBandFilter: { minimumSeverityBands: [HazardSeverityBand.action, HazardSeverityBand.critical] }, // optional, for noisy sources
     parseFunction: (responseData: any) => parseNewSourceToHazards({ data: responseData, availableCategories }),
   }
   ```
   Gotcha: the fetcher checks `parseFunction.length`. A **zero-arg** parse function
   means "I fetch it myself" (the RSS pattern: `() => parseRSSFeedToHazards({ url, … })`).
   A **one-arg** function gets `response.json()`, so XML sources must use the zero-arg form.

3. **Secrets.** API keys go in `src/utils/config.ts` + env vars + AWS Secrets
   Manager. **Never put a key in the URL literal** (the existing `qldTraffic`
   entry does this; don't copy it).

4. **New category?** Only if no existing one fits. Add it to `populateInitialCategories()`
   (`hazard_category.service.ts`) with keywords. Note that it only seeds when the table
   is empty, so existing environments also need the category added through the Admin
   API or a migration. If the parser looks a category up by id, add it to `SubCategoryId`.

## Step 3b: Path B, n8n workflow

The n8n MCP server may need authorising before Claude can build or edit workflows
directly. If it isn't available, produce the workflow spec/JSON for the user to import.

1. **API key** (one per workflow/client):
   `yarn webhook-key create "n8n <source>" --description "…" --expire-days 365`
   and set limits with `yarn webhook-key update <id> --max-per-minute … --max-per-hour … --max-per-day …`.
   That script loads `.env.dev`, so the key lands in whatever database that file
   points at. For the live AWS backend, run it against the **live** `DATABASE_URL`
   (e.g. `npx dotenv -e <live env file> -- tsx src/scripts/webhook-api-key.ts create …`),
   or the key will 403 on live. Set `WEBHOOK_KEY_OUTPUT_FILE` so the raw key isn't printed.
   Store it as an n8n **credential** (Header Auth, header `X-Webhook-Api-Key`).
   Never put it inline in a node.
2. **Workflow shape:** Schedule Trigger → HTTP Request (source) → Code node (map to
   payload) → filter out empties → HTTP Request `POST {ALRT_API}/api/webhook/hazards`.
   Use HTTPS to the API hostname, not the raw IP shown in older docs.
3. **Payload:** see `references/webhook-payload.md`. Requirements:
   - `sourceId` = the id registered in Step 2 (must exist or that item 400s)
   - `id` = `<sourceId>-<nativeEventId>`. **Always send it.** Without it the backend
     hashes title+description+coords+severity, so every wording change creates a
     new alert plus a new push notification.
   - `description` is required (≤5000 chars). Include the native warning level in it.
   - coordinates **or** `locationName`
   - batch many hazards per request (rate limits are per request: default 10/min,
     100/h, 1000/day per key)
   - `syncOption`: leave the default `ignoreExisting` (updates only when the description
     changes). Never use `deleteExisting`/`replaceExisting` on a schedule, because they
     re-notify users.
   - `allowedSeverityBands` to suppress low-severity noise for new items
4. **Response handling:** `201` all OK, `207` partial (inspect `errors[]`), `400` all
   invalid, `429` back off. Route non-2xx to an n8n error branch/alert. Don't silently drop.

## Step 4: Dedupe and update rules (both paths)

- The hazard `id` **is** the dedupe key (`prisma.hazard.findUnique({ where: { id } })`).
  It must stay stable across polls and updates of the same source event.
- With `ignoreExisting`, an existing id is re-processed only when `description`
  changes, and that update **sends push notifications again**. So keep volatile
  text (fetch timestamps, "updated 3 min ago") out of `description`.
- With `severityBandFilter`/`allowedSeverityBands`, an existing hazard that drops
  below the minimum gets expired immediately.

## Step 5: Verify, then go live

New sources go **straight to the live backend on AWS**. There is no test stage for
ingestion. The first real run creates live hazards and sends **real push
notifications** to every subscribed user nearby, and nothing reviews them first.
So prove the output offline before anything reaches the live API, and get the
user's explicit go-ahead before the first live run.

**Offline (no DB writes, no notifications):**
1. Dry-run the mapping against the saved fixture and against a fresh fetch:
   - Path A: a throwaway `tsx` script that calls the new parse function and prints
     the hazards. Don't call `summarizeAndPostHazards`.
   - Path B: run the n8n workflow manually with the final webhook node **disabled**
     and inspect the Code node's output.
2. Check every item:
   - ids are stable and prefixed. Fetch twice and diff the id sets.
   - coords are in range and lat/lng aren't swapped.
   - category isn't just `other`, and severity/band match the source's own level.
   - nothing has expired, and there are no invented calls to action.
3. Path A: `yarn build` (tsc) must pass.
4. Show the user the item count and the severity-band breakdown, and say how many
   would notify (anything not filtered out by the severity filter). Get a yes.

**First live run:**
5. Start conservative. Set the severity filter (`severityBandFilter` /
   `allowedSeverityBands`) to `action` + `critical`, and only widen it after a
   clean run.
6. Make sure the `HazardSource` row exists on live **before** the first run. Path A
   seeds it on deploy. For Path B, create it through the Admin API, or the webhook
   400s every item.
7. Trigger one run:
   - Path A: `POST /api/admin/hazards/sync-external` with
     `{ "sourceIds": ["newSource"], "syncOption": "ignoreExisting" }`.
     Always pass `ignoreExisting` explicitly.
   - Path B: re-enable the webhook node and run the workflow once.
8. Check the result:
   - the created count matches the dry run, and the hazards show the right source
     attribution and licence badge;
   - run it a **second** time and confirm nothing new is created and no
     notifications are sent;
   - watch the backend logs for the `[<sourceId>]` lines.
9. Only then enable the schedule (Path B), or leave it to the 15-minute cron (Path A).

**Rollback:** remove the entry from `externalSources[]` and redeploy, or deactivate
the n8n workflow. Disable its webhook key with `yarn webhook-key disable <id>`. Bad
hazards can be expired or deleted from the Admin Portal. Notifications already sent
can't be recalled. That's why the offline checks above are mandatory.

Cloudflare Pages checks on this repo's PRs are not part of the backend deploy and
say nothing about ingestion.

## Step 6: Record it

- Add the source to the source catalogue with the `SOURCE_REGISTRY.md` fields
  (the intake template maps 1:1).
- Tick or extend the relevant items in `V1_SOURCE_REGISTRY_BACKLOG.md` if this work
  closes any of them.
- In the PR description, state the path (A/B), licence status, sample counts from
  the fixture, and anything you couldn't verify.

## Known gaps vs the V1 contract (tell the user when they matter)

The current backend does **not** yet do several things `V1_SOURCE_PIPELINE.md`
requires. Don't claim a new source meets them:
- No raw-payload/provenance store and no source-native severity/symbol fields. The
  native level survives only as text inside `description`.
- Fetch/parse failures are `console.error`'d and return `[]`. There is no
  quarantine, health status or stale-source alerting.
- Unmatched categories silently fall back to `other` instead of being flagged.
- Ingested hazards are auto-`accepted` with no human review, so a bad parser goes
  straight to users. That's why Step 5 is mandatory.

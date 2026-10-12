# Production Readiness Gate — Safety ALRT

Status: **Not signed off**. This checklist is evidence-driven. A source appearing in configuration, a successful build, or a green unit-test suite does not alone prove production readiness.

## Release rules

- Do not deploy to production from this branch.
- Validate in TEST first; promote only through the existing reviewed release process.
- Never publish unregistered or unvalidated source data as an official alert.
- Keep source-native severity, event ID, URL, issue/update/effective/expiry timestamps and geography wherever supplied.
- Do not silently assign unknown categories or unknown severity mappings. Quarantine them for review.
- AI enrichment is optional: an AI outage must not silently discard a valid official warning. AI must not invent instructions or override explicit source lifecycle/severity without a documented rule.
- Every alert surface must use the canonical stored alert and the same category/severity/source-trust mapping.

## P0 — safety and correctness

- [ ] Run `backend/src/__tests__/severity-classification-regression.test.ts` in CI.
- [ ] Verify official AWS source-native levels are preserved and mapped consistently.
- [ ] Verify non-AWS critical phrases cannot be downgraded by incidental words such as “latest”, “protest” or “exercise caution”.
- [ ] Verify drill/test and resolved-incident overrides are phrase-based and cannot downgrade text explicitly stating “not a drill”.
- [ ] Verify AI provider/model compatibility against the deployed TEST configuration and real provider response.
- [ ] Validate AI output schema and enforce the no-invented-instructions policy.
- [ ] Verify official, community, GDACS and ALRT Intel source trust/visual rules separately.

## P0 — source pipeline

- [ ] Every enabled source has a stable source ID, owner/publisher, jurisdiction, coverage, endpoint, format, authority, access method, licence status, update cadence and review date.
- [ ] Each adapter has fixture tests using a representative payload from the publisher.
- [ ] Record retrieval time, source event ID, source timestamps, response status and safe error metadata.
- [ ] Preserve raw payloads with bounded retention and restricted access; do not store credentials in payload logs.
- [ ] Validate payload schema, event identity, timestamps and geography before publication.
- [ ] Deduplicate by source ID + source event ID; updates modify the existing event rather than creating duplicates.
- [ ] Quarantine malformed payloads, unknown categories, ambiguous mappings and events lacking required publication fields.
- [ ] Track last successful fetch, last attempt, failure count, freshness/staleness and source lifecycle status.
- [ ] Retry transient failures with backoff; avoid retry storms and ensure one source failure does not stop other sources.
- [ ] Add a safe preview/test-run action to Admin before a source can be enabled in production.
- [ ] Require review of licence/terms and attribution before enabling each source.

## P0 — app and notifications

- [ ] Map, list, details, search, filters, widgets, push and admin use one canonical alert model.
- [ ] Test shared category IDs, labels, icon names and severity colour tokens across Flutter and backend.
- [ ] Confirm source trust is visible: official alerts cannot be confused with community reports or AI-generated advisories.
- [ ] Apply per-source push policy and per-user category/location settings.
- [ ] Test area warnings without point coordinates, expired/withdrawn warnings, duplicate updates and escalation events.
- [ ] Bound push payload size; push should carry an alert ID/deep link and fetch full content securely.
- [ ] Ensure false/no-recipient notification messages are not shown when no notification was sent.

## P0 — platform and deployment

- [ ] Compare deployed TEST and production commits/build numbers to intended release commits.
- [ ] Verify API routes, database migrations, environment variables by name, scheduled jobs, webhook auth and third-party provider health.
- [ ] Verify secrets are in managed secret storage, never in source control or client bundles.
- [ ] Verify authentication, role-based admin access, database access policies, rate limits and audit logging.
- [ ] Run backend build/tests, admin tests/build, Flutter tests/analyzers and Android/iOS release builds.
- [ ] Test on physical iOS and Android devices: login, map, location permissions, push, deep links, offline/error states and billing.
- [ ] Test rollback and confirm monitoring/alerts for ingestion lag, provider errors, API failures and push delivery failures.

## Source onboarding acceptance

A source is **not production-enabled** until it passes: connection test → fixture/parse test → normalized event preview → category/severity review → duplicate/update/expiry tests → TEST end-to-end display → notification policy test → licence/attribution approval → monitored enablement.

## Sign-off record

For every gate, record the test run/build commit, environment, result, evidence link, reviewer and date. Mark an item complete only when evidence exists. Secrets, production credentials, external dashboards and physical-device behavior must be verified by an authorised operator; code inspection cannot prove those conditions.

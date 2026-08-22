# V1 Source Registry — Outstanding Work

This backlog tracks the remaining implementation work required to make the Source Registry operational rather than documentation-only.

## P0 — Required for V1

- [ ] Define the persistent source-record schema in the application/backend data model.
- [ ] Implement source CRUD with stable `source_id` values.
- [ ] Implement source status lifecycle: active, monitoring, degraded, suspended, retired.
- [ ] Implement source health checks and record `last_health_check`.
- [ ] Implement review/expiry controls and surface overdue sources in Admin Portal.
- [ ] Implement country/jurisdiction onboarding and coverage metadata.
- [ ] Implement source endpoint/feed configuration and ingestion adapter selection.
- [ ] Implement source attribution/provenance through canonical alerts.
- [ ] Implement source-event deduplication and update handling.
- [ ] Implement classification and severity mappings as explicit configuration/rules.
- [ ] Preserve source-native severity and official source-native symbols where applicable.
- [ ] Implement quarantine/failure states for unknown or invalid source data.
- [ ] Connect canonical alerts to notification, map and alert-card consumers.
- [ ] Add audit logging for source configuration changes.

## P1 — Required to make onboarding scalable

- [ ] Create an initial authoritative-source catalogue for V1 target countries/regions.
- [ ] Record licensing/access constraints per source.
- [ ] Add machine-readable source discovery/validation where possible.
- [ ] Add source freshness monitoring and stale-source thresholds.
- [ ] Add schema-change detection for feeds.
- [ ] Add test fixtures for representative source payloads.
- [ ] Add regression tests covering duplicate, update, expired and malformed events.

## Admin Portal acceptance criteria

A source administrator can:

1. Create a source with authority, jurisdiction, coverage, endpoint and access metadata.
2. Edit source configuration without changing its stable ID.
3. Disable/retire a source without deleting historical provenance.
4. See source health and last successful ingestion.
5. See review and expiry dates and identify overdue records.
6. Configure warning types and source-native severity mappings.
7. View the source's downstream ingestion/classification status.
8. See audit history for configuration changes.

## Operational acceptance criteria

- An unknown source cannot silently produce an authoritative ALRT alert.
- Every canonical alert can be traced to a registered source and source event.
- A source update does not create a duplicate alert.
- A stale/degraded source is visible to administrators.
- Source-native values remain available after ALRT normalisation.
- A parsing or feed failure is observable without generating a false alert.

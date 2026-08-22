# ALRT V1 Source Registry

## Purpose

The Source Registry is the authoritative catalogue of external information sources ALRT can ingest, evaluate, attribute and monitor for alert generation.

## Registry principles

- Prefer authoritative government, emergency-management, meteorological, health, transport, diplomatic and other official sources.
- Preserve source-native attribution and links through the ingestion pipeline.
- Record the jurisdiction, geography, source type, alert/warning capability and expected update mechanism.
- Treat source availability, licensing, authentication and terms as explicit operational metadata rather than assumptions.
- Record review and health status so stale or broken sources can be identified before they affect alert production.
- Do not infer severity solely from a source's existence; classification and severity are downstream decisions based on source content and ALRT rules.

## Required registry fields

| Field | Purpose |
|---|---|
| `source_id` | Stable ALRT identifier for the source. |
| `name` | Human-readable source name. |
| `publisher` | Organisation responsible for the information. |
| `country` | Primary country/jurisdiction. |
| `region` | State, territory, province, national or other relevant scope. |
| `coverage` | Geographic area covered by the source. |
| `source_type` | Government, emergency management, weather, health, transport, diplomatic, etc. |
| `authority_level` | Official / statutory / trusted secondary / other. |
| `url` | Canonical source landing page. |
| `feed_url` | Machine-readable feed where available. |
| `format` | API, RSS, CAP, Atom, JSON, XML, HTML, email, etc. |
| `access_method` | Public, API key, authenticated, subscription, manual, etc. |
| `licensing` | Known licence or usage restriction. |
| `update_frequency` | Expected update cadence. |
| `warning_types` | Warning/event types the source publishes. |
| `source_native_severity` | Severity terminology used by the publisher, if any. |
| `source_native_symbol` | Official source-native warning symbol where meaningful. |
| `status` | Active, monitoring, degraded, suspended, retired. |
| `last_reviewed` | Date the source configuration was reviewed. |
| `last_health_check` | Latest technical health check. |
| `expiry_review` | Date for mandatory configuration review. |
| `notes` | Implementation or attribution notes. |

## Source lifecycle

1. **Discover** — identify a credible source and its machine-readable or scrapeable endpoint.
2. **Assess** — verify authority, geography, warning scope, licensing and technical accessibility.
3. **Register** — create a stable source record with explicit metadata.
4. **Connect** — configure ingestion and preserve source attribution.
5. **Validate** — test parsing, deduplication, classification inputs and failure handling.
6. **Monitor** — track freshness, failures and source changes.
7. **Review** — periodically confirm authority, endpoint, licence, coverage and mapping remain valid.
8. **Retire** — disable sources that are obsolete, superseded or no longer trustworthy/usable.

## Downstream pipeline contract

`source registry → ingestion → source validation → event extraction → classification → severity → safety/instruction extraction → canonical alert → notification → map/card`

The source registry supplies source identity and trust/operational metadata. It should not itself manufacture alert severity or user-facing instructions that are absent from the source unless an explicitly defined ALRT transformation rule applies.

## V1 administrative requirements

The Admin Portal should support:

- Source creation, editing and retirement.
- Country/jurisdiction onboarding.
- Source status and health visibility.
- Licensing/access-status recording.
- Review and expiry dates.
- Source endpoint/feed configuration.
- Warning-type and source-native severity mapping.
- Source-native symbol configuration where an official recognisable warning symbol exists.
- Auditability of configuration changes.

## Severity and visual treatment

ALRT severity remains distinct from source-native terminology. V1 severity levels are:

- Info
- Monitor
- Action
- Critical

Source-native symbols should only be incorporated where the official warning system has a meaningful, recognisable symbol. Otherwise ALRT's standard professional geometric/outlined icon system should be used rather than inventing source-specific symbols.

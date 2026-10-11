# Source intake: <source name>

Fill in every row before writing code. The fields mirror `SOURCE_REGISTRY.md`.
Write `unknown` rather than guessing, and resolve unknowns with the user.

| Field | Value |
|---|---|
| `source_id` (ExternalSourceId, camelCase, permanent) | |
| `name` | |
| `publisher` | |
| `country` | |
| `region` | |
| `coverage` | |
| `source_type` (emergency mgmt / weather / health / transport / diplomatic / …) | |
| `authority_level` (official / statutory / trusted secondary / other) | |
| `url` (landing page, used as `HazardSource.url`) | |
| `feed_url` | |
| `format` (GeoJSON / JSON / RSS / Atom / CAP-AU / XML / HTML) | |
| `access_method` (public / API key / authenticated / manual) | |
| `licensing` → `HazardSourceLicense` badge (`ccBy4` / `ccBy3` / `licensed` / `permission` / `pending`) | |
| `copyrightText` / `copyrightLink` / `advisoryText` | |
| `update_frequency` | |
| `warning_types` | |
| `source_native_severity` | |
| `source_native_symbol` (only if official and recognisable) | |
| `status` | monitoring (until verified), then active |
| `last_reviewed` | |
| `expiry_review` | |
| `notes` | |

## Ingestion decisions

| Decision | Value |
|---|---|
| Path | A (in-code adapter) / B (n8n → webhook) |
| Why this path | |
| Stable native event-ID field | |
| Hazard id pattern | `<source_id>-<nativeId>` |
| Geography field(s) | point / polygon → bbox / place name only |
| Category mapping | fixed category id / keyword-derived / per-field map |
| Severity mapping (native → `severity` + `severityBand`) | |
| Is the AWS warning system used? (`isAwsCompliant`) | |
| Expiry source | feed field / severity default |
| Severity filter for new items | none / monitor+ / action+ |
| Instructions present in source? (for `callsToAction`) | |
| Sample fixture path + item count | |

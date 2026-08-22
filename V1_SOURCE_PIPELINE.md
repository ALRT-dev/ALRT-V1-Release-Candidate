# ALRT V1 Source-to-Alert Pipeline

## Objective

Define the V1 contract for turning an external authoritative source event into a canonical ALRT alert without losing provenance or source meaning.

## Pipeline

```text
Source Registry
      ↓
Ingestion
      ↓
Source Validation
      ↓
Event / Warning Extraction
      ↓
Normalisation
      ↓
Classification
      ↓
Severity Mapping
      ↓
Safety / Instruction Extraction
      ↓
Canonical Alert
      ↓
Notification + Map/Card
```

## 1. Source Registry

Resolve the incoming endpoint to a registered `source_id`. Reject or quarantine unknown sources rather than silently treating them as authoritative.

## 2. Ingestion

Support the source's declared transport/format where implemented (API, CAP, RSS/Atom, JSON/XML, HTML or other approved method). Capture the raw source timestamp, retrieval timestamp and canonical source URL.

## 3. Source validation

Validate that the payload:

- originates from the registered endpoint;
- is parseable;
- contains a usable source/event identifier where available;
- has sufficient time/geographic information for downstream processing;
- has not already been processed as the same source event.

Failed validation should create an observable ingestion failure/quarantine state, not a user-facing alert.

## 4. Event extraction and normalisation

Extract the source-native event title, description, issue/update time, effective/expiry time, affected area, coordinates where available, warning type, source-native severity and source-native symbol.

Normalisation must retain the original source values alongside the ALRT-normalised values.

## 5. Classification

Map the source event to an ALRT alert category using explicit rules. Classification must be deterministic and auditable. Unknown mappings should be flagged for review rather than silently assigned to an unrelated category.

## 6. Severity

Map source information to ALRT severity using explicit source/category rules and the content of the warning. V1 levels are `Info`, `Monitor`, `Action` and `Critical`.

Source-native severity must remain available for display/traceability even when the ALRT severity differs.

## 7. Safety and instruction extraction

Extract actionable safety advice, evacuation/protection instructions, official contacts, restrictions and relevant source guidance. Preserve source wording/provenance where required; do not invent instructions.

## 8. Canonical alert

A canonical alert should contain at minimum:

- stable alert ID;
- source ID and publisher;
- source event ID;
- source URL;
- title and summary;
- ALRT category;
- ALRT severity;
- source-native warning type/severity;
- issued, updated, effective and expiry timestamps where available;
- affected geography;
- safety/actions;
- source attribution;
- processing status and timestamps.

## 9. Notification / map / card

Only validated canonical alerts should reach user-facing notification, map and alert-card surfaces. Presentation layers consume the canonical alert rather than reinterpreting raw source payloads independently.

## Deduplication and updates

The preferred deduplication key is the publisher/source ID plus source event ID. Where a source lacks a stable event ID, use a documented fallback based on canonical URL and relevant event attributes. Updates to an existing source event should update the canonical alert rather than create duplicate alerts unless the source explicitly establishes a new event.

## Failure handling

The pipeline must distinguish:

- source unavailable;
- authentication/access failure;
- malformed payload;
- schema/format change;
- stale source;
- unknown classification;
- ambiguous severity;
- missing geography;
- duplicate event.

Each state should be observable and attributable to the affected source.

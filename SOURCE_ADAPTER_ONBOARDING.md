# Registry-backed source onboarding

This release adds a guarded onboarding path for two common public-feed formats. It does **not** make arbitrary endpoints safe to ingest automatically.

## Supported generic adapters

| Adapter key | Input contract | Behavior |
| --- | --- | --- |
| `geojson` | A valid GeoJSON FeatureCollection with usable point geometry and event properties | Uses the existing GeoJSON parser and ALRT's existing category/severity heuristics |
| `rss` | A public RSS/Atom feed accepted by the existing RSS parser | Uses the existing RSS parser and ALRT's existing category/severity heuristics |

Built-in sources continue to use their dedicated parsers. A registry source ID cannot shadow a built-in source. Unsupported adapter keys are ignored; they are not interpreted as arbitrary code.

## Safe onboarding workflow

1. In Admin → Sources, choose **Add source**.
2. Supply a stable ID, publisher name, publisher website, feed URL, adapter and jurisdiction.
3. The source is created in **monitoring** status. Registry-backed adapters only ingest rows whose lifecycle status is explicitly **active**. The backend rejects activation unless a feed URL, format, last-reviewed date, future next-review date and licence record or licensing notes are present.
4. Verify the publisher terms/licence, feed schema, event identity, locations, category/severity outcomes and attribution in TEST.
5. Configure the source's review date and health ownership. Promote to active only after review.
6. Monitor source health and app surfaces after activation. Suspend a source immediately if it is stale, malformed or misclassified.

## Important current limitations

- The global ingestion scheduler controls the maximum polling frequency. `scheduleMinutes` is honoured at that scheduler's tick cadence; a configured one-minute interval cannot run more frequently than the scheduler itself.
- The generic adapter reuses the existing classification heuristics. If an event maps to the catch-all `other` category or has no category, the feed is withheld and its source health is marked failing rather than publishing an unclassified event.
- This path does not yet provide a persistent raw-payload archive, per-event quarantine queue, schema-drift diffing, per-source native-severity mapping rules, or an Admin connection-test/preview action.
- A feed can be syntactically valid but semantically incompatible. The source must be tested with representative fixtures and the TEST app before activation.
- Feed URLs must not contain credentials or tokens. Store credentials in managed secret storage and use `secretRef`; the generic adapters described here are for public feeds and do not currently resolve secret references.

## Production acceptance

Do not mark a source production-ready based on successful HTTP retrieval alone. Require a representative fixture, parse and classification tests, duplicate/update/expiry checks, licensing and attribution approval, TEST end-to-end verification, notification verification and an owner/review date. If any required field is unknown, keep the source out of active publication.

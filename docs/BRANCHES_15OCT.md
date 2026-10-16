# Branch state, 15 Oct 2026

Two lines of work split from `51dab92` on 13 Oct and were developed in
parallel by two sessions, each taking the owner's phone reviews:

- **B** `claude/compassionate-franklin-512so7`: every TEST phone build
  since 14 Oct. Event icon set, GDACS icons, info-only category caps,
  What we know / What to do rules, filters with Show all, report severity
  cards.
- **A** `codex/alert-template-controls` -> `claude/map-alerts-fixes-14oct`
  -> `claude/phone-review-14oct-pm`: alert templates and source extraction
  (backend + admin), map grouping, Alerts tab = list of the map view,
  plain-terms title parsing, fact cleaning, map search keyboard fix,
  WAQI pollutant and ingestion await fix. Never built before 15 Oct.

**`claude/combined-15oct`** is B with A merged in. Where both changed the
same feature, the later owner instruction won; the merge commit lists
each call. Checked: backend tsc + 132 tests, admin tsc + 83 tests,
Flutter analyze + full test suite (workflow
`flutter-check-combined.yml`, no publishing).

Work should continue on `claude/combined-15oct`. Changes pushed to B
after 12:41 on 15 Oct need merging in. Delete
`.github/workflows/flutter-check-combined.yml` when this branch merges.

# Smoke bulletin extraction and display follow-up — 8 November 2026

Development only; not deployed or published. User reference: Karragullen/Roleystone smoke bulletin screenshots supplied in this chat.

## Root cause

The deterministic DFES warning parser required a `Warning Type:` first line. The distributed DBCA smoke bulletin starts `Region:` and fell through. The generic extraction fallback selects facts using numeric/status signals and accepts blank-line-separated blocks containing any action verb as instructions. An entire bulletin with no blank lines can therefore enter `officialActions`. Its original source was rendered again as an expanded section. Editing a prompt alone cannot fix this source-specific path or old stored content.

## Candidate changes

- Recognise the DFES-distributed smoke bulletin format before the old warning/model path. Take up to four fact bullets before `WHAT TO DO`, omitting publisher/date/footer fragments. Preserve complete instruction bullets and driving conditions; keep the genuine separate road instruction. Contacts/footer remain in the original bulletin.
- Use the explicitly named Parks and Wildlife Service (DBCA) as issuer; retain DFES source attribution. No invented status, severity, geometry or update time.
- Repair recognised stored records at the public-read boundary without database writes, category-ID changes, lifecycle changes or lost source history.
- Unknown audience headings cause the adapter to decline, rather than weaken the next instruction. Conditional If/When/For headings remain attached to their following points.
- Mobile shows four agency instructions initially; remaining instructions remain accessible in an explicit expander. Full original source is collapsed once. Sparse extraction says instructions are unavailable in this view, never that the agency published none.
- Calmer smoke/alarm/leak titles and specific incident labels, with original titles and category IDs retained. This is not a completed category-taxonomy repair.
- Source/time details follow the practical content. Guides follow selected-only For You guidance. Sharing uses separate accessible action rows; existing consent and group-delivery handlers retained.
- Fuel leaks/alarms cannot borrow fuel-shortage or broad weather guidance. They still require specifically reviewed libraries before tailored content can be provided.

## Prompt contract for subsequent review (draft, not saved live)

Retain the owner's rules: concise plain terms; up to four relevant source-supported facts; genuine agency instructions first and complete, retaining conditions; reviewed separately labelled non-directive ALRT suggestions to supplement toward 2–4 useful points; selected-only hazard-relevant local profile guidance. The model must not supply category/severity/artwork or a person's profile. Ignore source boilerplate, contact lists, headings and publisher fragments when choosing facts. Do not treat a whole bulletin as a single action. Never infer absence of agency advice from empty extraction. Preserve the original source separately. An invalid extraction must visibly identify its limitation rather than claim successful summarisation.

## Verification and limits

- Backend: 220 source tests in 28 files pass, including the reproduced smoke failure, stored-read repair and conditional-heading regressions.
- Flutter: 24 targeted tests passed; after the final empty-state wording change, the affected subset of 22 passed. Three actual full-screen fixture renders pass (smoke, bushfire, fire).
- Targeted Dart analysis: no issues. Local backend TypeScript check reports only the pre-existing missing `serviceAccountKey.json`; no credential was copied or created.
- Initial unrestricted Vitest command also discovered ignored compiled `dist` tests: three duplicate tests failed because they tried to open `.ts` files inside `dist`. Explicit source-suite run passes as above.
- Fixtures omit native Google Maps; real phone maps and category-to-symbol consistency are not certified. Fixtures use source text supplied by the user, not a fresh live API fetch. Live admin prompt rows were not re-read or changed in this pass.
- No new APK/TestFlight build, backend rollout or production change in this pass. TEST remains at the previous deployed revision until a subsequent rollout/build.

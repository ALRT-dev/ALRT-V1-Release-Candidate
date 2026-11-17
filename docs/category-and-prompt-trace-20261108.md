# Main category, prompts and extraction trace — 8 November 2026

Owner clarification: category means the seven main groups, not the incident subtype. Health & Air; Safety & Crime; Weather & Environment; Utilities & Infrastructure; Other; Transport & Traffic; Community / Information.

## Verified in development code

1. `hazard_category.service.ts` seeds those seven stable IDs. Subcategories have `parentId`. Initialisation only populates an empty database; editing seed keywords does not automatically migrate an existing installation. Current live parent relationships/keywords need a database read.
2. Official ingestion usually assigns a subcategory BEFORE summarisation, using source-specific adapters and `getHazardAttributesFromDescription`. DFES incidents use explicit incident type where available; DFES warning parsing tries the title first, then broader source text. The seven-category AI classifier is not used for this path.
3. Generic keyword classification tries exact matches, then substrings. Multiple matches favour AWS-supported hazards; then main-group precedence Safety/Crime, Health/Air, Weather/Environment, Transport/Traffic, Utilities/Infrastructure, Community/Info, Other. This can prefer incidental text over the incident when a source adapter feeds the entire bulletin. Ties within a group use available-category order. These are audit risks, not evidence that every existing record is wrong.
4. Smoke has an explicit October routing rule: asthma/respiratory/health terms route smoke to `airQualityAlert` (Health & Air); residual smoke terms may route to `otherFire` (Weather & Environment). The owner has clarified the main category naming, not revoked that specific sorting rule. It has not been changed.
5. Community create/update controllers call `getSuggestedCategory` with main categories, before report review. The classification prompt is hard-coded in `hazard.service.ts`, not one of the editable admin summary rows. It supplies ID/description and asks to retain a roughly suitable existing category. It validates returned ID against the available list. A database with extra root categories could therefore expand that list; exact seven-ID enforcement and reason/provenance are proposed follow-ups.
6. Official summarisation selects source-specific prompt, then subcategory-specific prompt, then official/AWS severity prompt. A published template release adds the extraction contract and selects reviewed guidance. Certain recognised source formats bypass model prompts entirely. Changing an admin prompt therefore does not change all source extraction or category assignment.
7. The extraction contract explicitly excludes category, severity, colours, icons and personal profile data. The extracted facts/actions cannot by themselves correct a wrong prior category. Generic fallback still risks accepting a whole bulletin as instructions; the preceding smoke-format fix addresses the reproduced bulletin, not all possible sources.
8. Backend normal detail/feed responses include subcategory plus parent object/ID. The mobile detail pill used the subcategory's `displayCategoryName` rather than the main group. This explains the screenshot's Air Quality Alert label, even if its underlying main group is correctly Health & Air.
9. Mobile main palette already names all seven groups by stable ID. The new candidate detail pill resolves the parent ID and draws that category's glyph/colour. Incident title, source type, exact map hazard artwork and guidance matching remain distinct. Missing parent/category metadata is shown as unavailable rather than guessed.

## Candidate UI changes in this pass

- Main category pill follows parent ID, using the seven existing canonical names. Source titles stay intact in stored data.
- One Send alert to group action. Existing send confirmation is followed by explicit optional check-in consent after successful delivery; failed/cancelled sends never trigger a check-in. Share externally remains separate.
- Header labels the ALRT creation time Posted. It does not relabel agency event time as Posted if creation time is absent. Source updated remains based on explicit agency update evidence; refresh/detection time is not falsely presented as a source update. Technical times remain collapsed.

## Remaining audit/repair work

- Re-read TEST and production category tables, parent relationships, source overrides, saved prompt text/configuration and published-template state. TEST AWS SSO expired during this pass; no current live row claims are made.
- Run representative raw source fixtures through every routing path, recording selected subcategory, parent group, rule/match and effective prompt. Include boilerplate collisions, missing explicit types, alarms/leaks, transport disruption, scheduled events, smoke/air quality and agency cancellations.
- Propose a reviewed seven-group mapping matrix before changing sorting rules. Preserve exact incident type as a separate field; do not change classification by changing a label.
- Add explicit category-decision provenance and admin preview of raw source → assigned subtype/main group → effective extraction route/prompt → final card. This is a proposed follow-up, not implemented here.
- Draft/admin prompt text must be reconciled with its consuming route and current library, with separate save/publish effects explained. No live prompt, sorting rules, database categories or production settings were changed.

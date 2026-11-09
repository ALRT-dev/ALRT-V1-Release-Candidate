# Owner clarification — 9 November 2026

This supersedes the earlier supplementation rule in the 5–8 November plans.

- What we know: up to four relevant, understandable source-supported facts. No publisher fragments, footer information, duplicate location/timestamp padding or invented facts.
- What to do: target 2–4 practical, hazard-relevant points. Agency advice is used when provided. Preserve essential conditions and source directions; do not invent a second agency point to satisfy a count. Additional essential agency instructions must remain accessible.
- ALRT advice is only a fallback when no agency advice exists. It is not mixed in to top up a short agency list. It must come from reviewed hazard-specific content and remain non-directive. An empty extraction does not prove the source gave no advice.
- Safety Profile: relevant selected needs only, matched locally. No invented or unrelated cohort advice.
- Seven main category pills: Health & Air, Safety & Crime, Weather & Environment, Utilities & Infrastructure, Other, Transport & Traffic, Community / Information. Incident/subcategory names remain separate. Current database sorting and source-specific rules require validation before any mapping changes.
- Section outlines must be visible: blue-grey facts, orange advice, existing orange profile card and purple sharing. Category/severity colours remain the existing locked system.
- Sharing: one group-send action, optional check-in within that flow, external share separate. Failed/cancelled sends cannot initiate check-in; location remains explicitly consented.
- Posted uses ALRT creation time. Source updated uses actual source-update evidence. Detection/refresh/expiry metadata remains clearly distinct.
- Official-source street names, street numbers, road names and precise source coordinates may be displayed. Community-report public location privacy is separate; it must not redact official source detail.

## Screenshot repair follow-up

Exact metadata-only smoke reports and road crashes now receive dated, referenced ALRT fallback guidance only if agency actions are absent. Smoke/bushfire incidents publish generic neutral profile planning rows, so existing clients receive the corrected wording without selecting stale bundled rows. Actual selected-profile matching stays local. Other incident types publish an explicit empty list rather than borrowing unrelated guidance. Incident limitations explain what a report alone cannot establish, without denying a road name or impact supplied in the source. Original source disclosure follows sharing; metadata-only headers have no grey severity strip. Seven parent categories and lifecycle rules are unchanged.

Validation: backend 228 tests across 28 files; 33 focused Flutter checks including seven full-screen fixtures and existing-client profile mapper/content parity; targeted Dart analysis clean. New smoke/crash fixtures use the adapter's extracted output. Native maps and actual device/provider delivery are excluded from these renders. Rollout and replacement-phone-build status is tracked separately; build 277 predates the visual corrections.

## Review findings still blocking a complete release claim

- Seed-library inspection: 255 entries, but approved non-profile general guidance is only one entry for each of the seven parent categories; exact child-category matching cannot provide 2–4 practical fallback points for most hazards. Most standing entries remain drafts. The TEST registry was re-read on 9 November and this coverage gap was confirmed. The exact DFES adapters above cover their named incident kinds separately.
- The legacy mobile GeneralGuidance library contains directive movement/sheltering wording. The detail screen no longer uses this unverified fallback or labels unprefixed legacy text as agency instructions. Legacy records still need source-backed re-extraction before they can reliably meet the practical-advice target. This is a release gap, not completed content coverage.
- Real push delivery, server-side Follow, actual store purchase/restore/webhook acceptance, native maps/phone interactions and the current saved prompts/categories remain separate release gates. Existing simulated checks do not certify these connections.
- Production unchanged. These edits are development candidates, not a new phone build or TEST rollout.

## Owner direction, 9 November 2026 (evening): supersedes the What we know and ALRT fallback rules above

- What we know: 2 to 4 plain-language, practical points. Each must be grounded in an exact source quote (evidence); no added causes, predictions, numbers or places. Fewer only when the source supports fewer.
- What to do: agency instructions summarised into short practical points, keeping every condition, place, time and exception and the agency's strength of wording. Each carries its exact source instruction as evidence. All essential instructions stay accessible.
- ALRT safety advice: What to do holds 2 to 4 points. When the agency gives fewer than two instructions, ALRT safety advice makes up the difference; when it gives two or more, at most two ALRT points that add something new. Always labelled as ALRT's. Calibrated to the level (Info or Monitor: aware and prepare; Action: get ready, keep away; Critical: follow official directions, call the local emergency number if in danger). None on test, exercise, cancellation or resolved alerts.
- ALRT never originates a leave, evacuate, shelter, stay or return direction; it may only repeat one the agency gave. No numbers in ALRT advice.
- Level: a designated scale (Australian Warning System, health or air quality, humanitarian such as GDACS, or the agency's own label) is copied exactly. Otherwise the level is the existing ALRT keyword wordbank level, which already sets the outer-shape colour. The AI is given that level and never changes it.
- Source instructions the model failed to extract are kept as written, never replaced by ALRT wording.
- Smartraveller is not used (copyright).

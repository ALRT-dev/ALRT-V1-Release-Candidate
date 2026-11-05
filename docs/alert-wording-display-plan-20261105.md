# Alert wording and display fixes Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans task by task.

**Goal:** Prepare development fixes for Sarah's approved 5 November wording and display rules, without publishing.
**Architecture:** Keep original source records; derive grounded presentation separately. Reviewed library suggestions supplement sparse agency actions. Mobile and admin keep authorship distinct; guidance matching stays specific.
**Tech Stack:** TypeScript/Vitest, React, Flutter.
**Spec:** Owner answers in this chat, 5 November 2026; ALRT-clean-alert-and-prompt-proposal-05nov.md in audit outputs.

## Global Constraints
- Production unchanged. Admin layout is a review proposal only.
- Two source-supported facts where available; never fabricate a second fact.
- Agency actions first and complete. Target 2–4 advice points using reviewed, non-directive ALRT suggestions; retain essential agency actions even above four.
- Safety Profile guidance only for selected needs. No matching published learning guide means no guide strip.

## Review Focus
- Sparse source facts: no padding or metadata dumps.
- Long conditional agency instructions: preserve every condition.
- One agency action: supplement only enough to reach two, labelled separately.
- Structural fire: cannot inherit a bushfire guide through a shared parent.
- Empty safety profile: no profile guidance or setup promotion on alert detail.

### Task 1: Grounded extraction and supplemental advice
Files: backend/src/utils/agency_extraction.util.ts; backend/src/__tests__/alert-templates.test.ts.
- [x] Add failing tests for supplementation and compact source-only fallback.
- [x] Run failures, implement and rerun targeted tests.

### Task 2: Specific guide matching
Files: backend/src/services/guide.service.ts and backend/src/__tests__/guide-matching.test.ts.
- [x] Test exact category wins; unrelated parent guide is hidden.
- [x] Implement exact category lookup and verify.

### Task 3: Mobile presentation and profile selection
Files: agency_content_sections.dart; for_you_card.dart; frontend/test/alert_content_rules_test.dart.
- [x] Test agency-first separate supplemental advice, two facts, empty-profile silence.
- [x] Implement preserving existing colours and layout; run targeted Flutter tests.

### Task 4: Draft prompts and admin preview proposal
Files: docs/alert-prompt-draft-20261105.md; existing admin template page and content preview.
- [x] Prepare compatible draft contract and route/migration checklist, not a production update.
- [x] Make preview attribution consistent; explain draft/version and review limitations.
- [x] Run relevant admin checks and backend suite, inspect diff and record remaining risks.

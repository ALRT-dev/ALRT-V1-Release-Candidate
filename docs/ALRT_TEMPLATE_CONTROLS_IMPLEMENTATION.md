# ALRT editable alert templates: TEST implementation

Date: 15 October 2026. Status: pushed; newer source/icon changes integrated and under final checks. Template changes are not yet deployed.

The product owner authorised TEST changes and deployment, and later clarified public stores as the final destination. This deployment phase remains TEST-only. AWS TEST access is restored and account 488658242173 verified. The app/browser connector currently returns `Transport closed`; shell, GitHub and AWS work.

## What changed

| Area | Implementation |
| --- | --- |
| Reusable templates | Shared default, country, source and country-plus-source overrides. Only overridden fields are copied. |
| Prompts | Existing AI Prompts remain the editable records. Publishing freezes prompt text, model and routing with the template version. A mandatory extraction contract is appended after editable instructions. |
| Source extraction | Selects up to three complete source blocks, affected place names and the native warning label. Evidence must match actual source blocks. The server retains the source title. |
| Agency instructions | Dedicated source instruction fields are retained in full. If an instruction is selected from free text, the full description is retained as its context. Essential instructions are not shortened to three bullets. |
| ALRT suggestions | Approved library entries fill a gap when no official actions exist. They are labelled as ALRT suggestions and use suggestive wording. A failed extraction falls back to source text rather than inventing advice. |
| Severity | Existing deterministic classification remains the baseline. Native AWS levels are protected. Exact native-level mappings cannot lower the agency baseline. The editable phrase wordbank applies only when no native level exists. Tests and resolved incidents remain Info. |
| Always-on warnings | Active AWS Advice, Watch and Act and Emergency Warnings bypass optional category/band filters. Official critical alerts retain their exemption. Info lifecycle updates and community claims are excluded from the AWS exemption. Backend ingestion, list/push rules and the mobile map are covered. |
| Icons and colours | Existing artwork is reused. AWS and current community artwork stay protected. Humanitarian uses a diamond; no square is introduced. Editable ALRT colours affect eligible markers. Category pill colours stay in Categories / Icons and are independent of severity. |
| Safety profiles | Matching happens on the phone. Profile choices are not sent to the extraction model or included in preview requests. All matching rows are retained. An empty published library does not silently fall back to bundled old advice. |
| Existing guidance | All 243 bundled Standing For You entries across 27 hazards are imported verbatim as unapproved drafts. Their old hazard labels remain in the reference field. Category, country, band and wording review is required before activation. Twelve scoped starter entries are also included. |
| Preview and restore | Preview creates no hazard and sends no notification. Draft save, publication, last ten versions and restore are separate operations with revision checks and audit entries. |
| Source updates | A persisted content hash detects changes to instructions, native label, jurisdiction, severity, time, location and template version even when the description is unchanged. |
| n8n contract | Optional nativeWarningLevel, jurisdictionCountry and sourceInstructions fields are accepted. The test-workflow helper includes the new fields. Existing incoming severity/band overrides remain stripped by the backend validator. Published extraction ignores upstream generated summaries/actions. |

## Important operating details

- Template locale is metadata. This implementation retains original source wording and language; it does not promise translated warnings.
- Exact extraction may produce longer paragraphs than a rewritten summary. Keeping instruction conditions takes priority over the short display target.
- WAQI numeric AQI remains deterministic, with readings at or below 100 suppressed by its established route. This is not a universal threshold for every country's air-quality scale. Other agency air-quality warnings can use source extraction.
- Country means the affected destination, not necessarily the publisher's home country. A global source with no known destination does not inherit the publisher's country. Current ISO country names are normalised.
- A new country can reuse the template. A new feed format still needs a source adapter and sample validation. The Sources page alone does not turn a feed on.
- Built-in Smartraveller parsing retains complete update notes and regional exceptions, but that built-in poller is disabled in the current code. This change does not activate it.
- Existing image assets contain their own colours. The ALRT colour picker does not recolour approved PNG artwork. Existing fire-status artwork is retained.
- The emergency-number exception is source-specific and requires an administrator to identify a verified emergency-service source. Road, exit, gate, room and date numbers have regression cases. This is text validation, not independent verification of an issuing agency.
- Authentication of a webhook establishes the caller, not the truth of a source. sourceInstructions must contain original agency text, never a workflow's generated advice.
- A published template does not edit historical alert text immediately. Reprocessing a source applies the new version. Restoring a version also affects future processing.
- These controls do not edit deployed private n8n workflows, activate sources, replace the Ask ALRT systems, or distribute a new mobile build automatically.

## Files and state

- Branch: codex/alert-template-controls, based on 51dab9267c2ffddc0de8e647cdec420a009b61cf.
- Admin route: /alert-templates.
- Admin API: GET/PUT /api/admin/alert-templates and POST /api/admin/alert-templates/preview.
- Registry: reserved alertTemplatesV1 key within Configuration.aiPrompts, preserving unrelated configuration.
- Additive migration: 20261013210000_hazard_content_details adds contentDetails, nativeWarningLevel, jurisdictionCountry and sourceContentHash to Hazard.
- Build-only local serviceAccountKey.json is an ignored fixture, not a deployment credential. It must never enter the release image.
- Template, widget and upstream integration changes are pushed in 0341147, 0b92317, a62f4cb, 3989b01 and 43b645b. TEST backend deployment and the additive migration succeeded on 15 October. No production writes or public store submission have been made. The shared TEST checkout remains b15bdf9; deployed images are built separately from reviewed revisions.

## TEST rollout checklist

1. Re-verify account 488658242173 with profile alrt-test immediately before deployment. Never use production account 082258816984 for this TEST deployment.
2. Inspect the current TEST instance and checkout before changing them. Record running revision/image and take a database/configuration backup with a checked restore path.
3. Review the additive migration against TEST schema history. Deploy the backend from this reviewed branch without the local credential fixture. Check migrations and health before publishing configuration.
4. Verify TEST Sources, category IDs and current prompt records. Preview representative real source items against the actual configured model. Review the starter guidance and activate only the intended mappings/library rows.
5. Publish a version on TEST. Confirm draft/publish/restore and source reprocessing on a disposable TEST source, including unchanged description with changed instructions. Confirm no production notifications are sent.
6. Update only verified TEST n8n workflows to send raw source text, native labels, destination country and complete instruction fields. Inspect active versions and executions; the helper workflow alone does not prove feed coverage.
7. Verify Cloudflare project and domain bindings before publishing Admin. The candidate pages.dev host is pinned to api-test; a shared project's custom domains still need inspection. Do not assume the project's production branch is safe to overwrite.
8. Build and distribute a TEST mobile build to inspect map markers, long agency instructions, profile selection and all three always-on AWS levels on a device.

## Rollback

Restore the previous published template through version history for prompt/routing/guidance changes. For application rollback, return to the recorded prior TEST image and Admin deployment. Keep the additive nullable columns during rollback; do not drop them while any instance may still use them. Restore a database backup only through the checked TEST recovery procedure, accounting for alerts received since backup.

## Verification boundaries

Automated checks use mocks and synthetic examples. They do not prove that every production source, every private n8n workflow, or every deployed model response conforms. Remote migration and reviewed backend updates succeeded. Live previews at 43b645b extracted nine real stored examples and one synthetic example without fallback. A native-level preview mapping issue found in those checks is covered by the next fix. Signed-in Admin behavior, TEST n8n coverage and physical-device rendering remain to be verified. The earlier production audit remains relevant for workflow-specific defects that have not been changed in production.

## Live-source review, 15 October 2026

- AI selection now uses explicit source block IDs, validated against the exact server-built list. Closed metadata records can produce short factual points. Prose with conditions or uncertainty remains intact; long warnings can therefore still have long factual points and need further readability review.
- Ordinary enquiry numbers are retained. They must never be transformed into emergency-call instructions. A named emergency number and its numeric annotation are replaced together when the source has no configured exception.
- The ingestion processing identity has a renderer version and raw source digest. Unchanged-source rendering refreshes are quiet, including after template changes; genuine source/native-level/instruction changes remain notification candidates. Decisions are carried per input, including colliding IDs in one batch.
- TEST has 22 prompts and 19 sources. All 152 default source/band/AWS routes resolved. The registry contains 12 reviewed starter entries and 243 older unapproved guidance drafts. It has no TEST webhook API keys or recent webhook calls; a separate TEST n8n connection is not yet evidenced.
- Android TEST build 38696937645 at a62f4cb succeeded with billing bypass. Apple Dev build 38697481822 stopped because com.safetyalrt.alrt.dev.AlrtWidget is not registered with Apple; group.com.safetyalrt.alrt.dev must be shared with the Dev app. No widget TestFlight upload is claimed.

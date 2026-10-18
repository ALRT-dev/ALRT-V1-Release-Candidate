# Alert template controls implementation plan

Goal: Update the TEST Admin and TEST ingestion with editable, reusable agency extraction templates and country/source overrides, as approved in the conversation on 13 October 2026.

Scope: Existing Admin and backend. Preserve source attribution, current community artwork, mandatory AWS assets, code-assigned severity, source-grounded official instructions and local profile choices. No square icon. No production deployment. New configuration is versioned with optimistic concurrency, draft preview, publish and restore. The existing AI prompt records remain the editable prompt authority; template settings select a prompt and add scoped instructions.

1. Add a validated template registry in the existing Configuration.aiPrompts JSON document under a reserved alertTemplatesV1 key. Resolve shared defaults, country overrides and source overrides. Preserve every unrelated configuration key. Add bounded history and optimistic concurrency. Add admin-authenticated routes and audit entries.
2. Add grounded extraction of up to three facts, affected areas and official actions. Require source evidence for extracted facts/instructions. Select ALRT suggestions and profile guidance from an editable reviewed library. Keep profile values out of ingestion. Preserve essential official instructions even when more than three exist. Add optional structured Hazard content so the legacy summary/action fields remain compatible.
3. Connect published mappings and templates to ingestion and summary cache identity. Keep AWS mappings protected, tests/resolved Info, AQI deterministic, community moderation unchanged. Enforce typed model responses. Add a preview endpoint that neither publishes alerts nor sends notifications.
4. Add an Admin Alert Templates page: inherited/default settings, country/source scopes, prompt selection, extra instructions, native-level mappings, band colours, existing category/icon selection, reviewed suggestion/profile library, sample preview, draft save, publish and restore. Expose structured sections in alert detail. Link from AI Prompts and Sources.
5. Verify focused tests, existing suites and builds; inspect changes. Publish only to the verified TEST backend and TEST Pages project, with a rollback record and pre-deployment DB backup. Report any server/mobile rendering limitations honestly.

Checks: inheritance precedence; stale update conflict; no square shape creation; AWS levels preserved; profile choices never change severity; ungrounded model output refused; source conditions and locations retained; no advice attributed to an agency without evidence; unpublished drafts do not affect ingestion; immutable history restores; previews have no hazard writes.

User explicitly requested the TEST update and editable settings. Earlier local guidance forbidding deployment is superseded for TEST only. Existing production services remain outside this change.

Progress, 13 October 2026: steps 1-4 implemented locally. Local verification and visual preview completed; TEST deployment portion of step 5 remains blocked by expired AWS SSO and locked Windows. See docs/ALRT_TEMPLATE_CONTROLS_IMPLEMENTATION.md for current scope, limitations and rollout/rollback steps. Existing 243 profile-library rows are preserved as unapproved drafts, with no automatic broad-category activation.

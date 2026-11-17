# ALRT extraction and configuration repair implementation plan

**Goal:** Prepare the first verified repair batch from the production/new-app audit; no deployment is included.

**Architecture:** Keep Bedrock requests compatible with its union schema. Extract source excerpts and complete scoped agency instructions, retaining deterministic fallback. Fetch public app configuration within the selected Riverpod environment.

**Tech stack:** TypeScript, AWS Converse SDK, Vitest, Flutter, Dio, Riverpod.

**Requirements:** Sarah's sourced concise card content and TEST/production separation; 4 November direct rulings: remove separate Unverified badge while retaining community-source wording; free trial for personal ALRT+ only, subject to store eligibility. Do not change source shapes, category colours, screening, prices, accounts or deployed services.

## Tasks and evidence

- [x] Isolate at base 1f91dcca in managed worktree; preserve original checkout's untracked files.
- [x] Reproduce invalid system block through actual Converse SDK serialization and a fake HTTP transport. Restore text-only block. Both request/empty-response tests pass; no AWS AI invocation.
- [x] Run baseline backend suite: 137 pass, three existing grounding failures. Preserve fire-ban facts, reject unsupported rewrites, keep full scoped instructions, cap facts at four without padding, and align fallback evidence/actions.
- [x] Reproduce reviewer-found multi-paragraph scope loss; shared context helper retains the lead-in and intervening paragraphs. Remove contradictory 20-word instruction example.
- [x] Change fallback SI prompt to 2–4 sourced facts with no generic padding. Prompt wording is changed; live model quality is not certified by unit tests.
- [x] Add Dio transport regression tests for TEST config origin and offline behavior. Read base URL from provider scope; remove context-free bootstrap call. Start configuration fetch from app wrapper.
- [x] Record direct community/trial rulings; align onboarding and alert-key copy. Current community card already says Community report; no screening or uncertainty-tone removal.
- [x] Full backend suite: 145 pass, 21 files. A prior parallel run had a five-second RevenueCat route-import timeout; rerun with two workers passed without relaxing tests.
- [x] Full Flutter suite: 578 pass, 33 skipped. Targeted config tests: 2 pass. Analyzer exits 1 for five info-level issues in unchanged files; zero error/warning-level diagnostics reported.
- [ ] Full backend type check: blocked only by absent backend/serviceAccountKey.json in this credential-free checkout. No secret copied, dummy credential created or suppression added.
- [x] Independent review: two findings corrected and regression verified; targeted re-review 18/18 template tests pass.

## Review focus and limits

- Source excerpts are intentionally conservative: unsupported paraphrases fall back rather than being accepted as grounded facts.
- Colon-led action scope is retained conservatively across intervening paragraphs; this can repeat context. This is not a general semantic proof of every source's instructions.
- Existing production without a published template snapshot follows a different extraction path. This patch alone does not migrate/edit its database prompts or certify rendered cards.
- Automated tests replace network/provider boundaries; real push, stores, phone UI and AI output remain separate acceptance work.
- Existing Intel/Official filter coupling is explicitly covered by old tests; no behavior change made without reconciling that decision.

## Remaining audit remediation

CFS replacement CAP feed responds XML 200 while current JSON URL responds HTML 200. Port and verify its cancellation/lifecycle parser separately; do not cherry-pick a mixed historic commit. n8n public host currently returns Cloudflare Tunnel error 530. Local Docker daemon is unavailable, blocking isolated PostGIS scheduler takeover tests. TEST release alignment, duplicate scheduler ownership, Intel delivery, Firebase workload authentication, admin helper, store/update policy and physical acceptance remain open. No production, TEST, account, billing or credential changes have been made by this batch.

## Second repair batch — 4 November

- CFS current CAP-AU adapter ported separately from historic mixed commit; explicit fast-xml-parser 5.5.8 dependency already resolved in both locks. Twenty-six synthetic cases cover official bands, test/resolved lifecycle, area-specific instructions, cancellation references/newer updates, stable IDs and transient fields. Current public feed read-only smoke: 19,377 characters, three CFS rows, finite coordinates, no cancellations. No records ingested.
- Firebase TEST IMDS role credential JSON normalization is limited to successful text/plain role-credential responses on AWS link-local metadata. Uses real GoogleAuth signing flow in isolated tests. Admin ADC identity retained; Firestore explicitly gets the same configured auth before use. Reviewer-found Firestore regression reproduced and repaired.
- Backend full suite 179 passed across 23 files. Type check still blocked only by absent serviceAccountKey.json. No credentials copied or checks suppressed.
- TEST impersonates fcm-sender@alrt-test.iam.gserviceaccount.com against project alrt-a6539. Existing validate-only probe gets cloudmessaging.messages.create permission denied after authentication normalization. Production credential cannot read project IAM policy (403); no permissions granted.
- Neither repair is deployed. Physical push, Firestore writes, provider IAM acceptance, clean install and release gates remain open.

## Live admin host alignment

Verified the actual live JavaScript forces relay on the AWS/nginx-hosted admin; its Pages origin helper returns404. Production build now selects the configured live API directly. Pages hostnames retain relay selection automatically; a future custom-domain Pages deployment explicitly sets VITE_USE_RELAY=true and API_ORIGIN. No hosting/domain change.

New origin regression failed on old configuration, then passed. Corrected three stale test selectors while retaining pagination/filter and inherited-settings assertions; existing Accepted default and product behavior unchanged. Full admin84 passed/19 files; production tsc/Vite build passed. Independent review cleared the connection change. Backend clean npm ci --ignore-scripts succeeded in isolated directory (778 packages), not a native/container build.

## Production mobile workflow configuration

Root production Android and iOS workflows created .env but omitted --dart-define-from-file=.env, unlike their nested copies. Env.dart uses compile-time constants: this could leave Dart Google sign-in, RevenueCat and API-key consumers blank despite a successful binary build. Added the missing flag to both root build commands. Expanded the existing environment regression to inspect actual root workflows too. Observed Flutter regression fail with old root configuration, then5/5 pass after restoration of the fix. Independent review found no regression.

Build-only Android run41816308023 and no-upload iPhone simulator run41816590313 were started at prior commitdf8f861. Android artifact from that revision is signing evidence only and must not be promoted as the corrected runtime candidate. Neither run publishes a store build.

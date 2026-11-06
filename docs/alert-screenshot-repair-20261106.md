# Screenshot-driven alert repair — 6 November 2026

Owner: screenshots Scarborough bushfire, Bassendean generic Fire, Melaleuca bushfire. Existing approved design/rules remain binding; no new approval cycle or production changes.

## Acceptance checks
- In plain terms is a concise sourced incident statement; never infer agency has not published advice from an empty extracted array. Generic Other Fire reads as fire.
- What we know contains up to4 relevant readable facts, not metadata labels/RFC timestamps or repeated source/title text.
- What to do remains present for these recognised fire cases: complete actual agency instructions first, reviewed non-directive ALRT planning suggestions separately, practical target2–4 with no filler.
- Original metadata is available in a collapsed source disclosure for recognised metadata-only incidents. Unclassified extraction failures must preserve access to full agency text and any essential instructions.
- Source time details are secondary/collapsed; DB updatedAt alone never claims new source information. Latest actual source change appears above main card when verified diff/history exists.
- Sharing becomes compact: selected group, Send alert, Send & check in, Share externally. Remove oversized invitation/promotion banner. Do not falsely promise a check-in was sent by an alert-only handler.
- Generic Fire and structural fire cannot receive a bushfire-only learning guide. Selected Safety Profile guidance remains local and hazard-relevant.
- Mini map focuses on incident coordinates, not a whole-state zoom7.
- Live admin AI Prompts is read-only during inspection. Confirmed22 rows updated20Oct and NO published template in live Alert Templates; current Save may affect agency alerts immediately. Development UI must accurately show this rather than promise draft isolation.

## Ownership/progress
Parent: Dart components and main detail integration, API read normalisation of stored DFES records, real source-update discrimination, guide matching integration, fixtures/rendered QA.
incident_content_repair: new backend DFES structured parser + tests only; reviewed official-source suggestions. Initial200tests passed; refining friendly time/Other Fire/profile metadata.
review_repairs: AIPromptsPage.tsx + tests only. Conditional save-effect notices implemented; checking full admin suite.
firebase_permission_read: completed read-only report; Google refresh still fails despite user reporting ready. No IAM changes.

## Root causes confirmed
1. Strict quote-only model contract + metadata-only incidents falls back to labels, then UI shows entire sourceDescription as a large card.
2. Reviewed guidance library lacks exact child fire matches so What to do vanishes; changing fact count cannot fix this.
3. Plain-terms UI generates unsupported absence-of-advice sentence from callsToAction emptiness.
4. Updated banner uses Prisma updatedAt-createdAt>5min, not source change evidence.
5. Old expanded timeline, duplicate attribution footer and promotional sharing section were never replaced with the approved compact layout.
6. Broad guide database associations can still name a bushfire guide for generic Fire despite exact category query.

No deploy/release until representative Scarborough and Bassendean fixtures are rendered and reviewed, not merely test counts.

## Development checkpoint (6 November, evening)
Implemented locally, not deployed or published:
- Source-aware live-save warnings in AI Prompts (92 admin tests and build passed).
- Recognised waDfes incident-field adapter plus API read repair of stored rows. Raw source, official instructions, presentation and lifecycle retained. Two reviewed, separately labelled suggestions for exact Bushfire or generic Fire; no invented absence-of-advice claim.
- Facts/advice subtle outlines, one What to do section, recognised raw feed disclosure collapsed; selected Bushfire profile fallback explicitly permitted; mini-map zoom13.
- Compact group-send/external-share panel, external share available without a group. Removed misleading old check-in promise; real combined flow STILL TO IMPLEMENT.
- Duplicate normal-layout attribution footer removed; expandable source/time details. Latest sourceUpdate rendering above main card requires explicit source evidence, never DB updatedAt. End-to-end source-history creation STILL TO IMPLEMENT.
- Wrongly linked Bushfire-only guide suppressed for other categories.
Validation: backend26files/207tests; focused Flutter34tests including actual component render; targeted Dart analysis of screen/content had no issues. Local backend typecheck has only pre-existing missing serviceAccountKey.json. No secret added to satisfy it.
Preview is the actual content component rendered with Scarborough fixture, not a full rebuilt app or proof of map/share end-to-end behaviour: outputs/alert-content-development-06nov.png in audit workspace.
Outstanding: canonical map/detail icon diagnosis, consistent actual title/category formatting, real source-update history and follow lifecycle validation, real combined send/check-in flow, complete-screen visual QA and TEST deployment/build. No new build claimed ready. AWS session expiry and TEST96% disk need resolving before deployment. Google IAM policy remains unverified because CLI refresh still fails; no IAM grant made.

## 7 November continuation
Implemented and verified locally:
- Missing official bushfire/fire-alarm artwork added to map loader allowlist; correct existing artwork retained. Native map rendering still requires device QA.
- Canonical presentation-only fire/crash titles and Other Fire -> Fire label/plain terms; original source title retained. DFES WA abbreviation in header/summary, full agency attribution retained.
- Real send-and-check-in flow added: successful alert send, explicit check-in/status/location consent, named-group-only check-in, truthful partial-failure messages. Removed legacy 404 -> broadcast check-in fallback; widget regression reproduces old failure and now passes.
- DFES source snapshots at ingestion before model processing. Per-feed channel baselines prevent warning/incident-feed alternation masquerading as changes. Records original instruction-only changes too. First poll establishes baseline; no invented historical backfill. Latest change above header, detection time labelled honestly, expandable older history. Other sources deliberately retain prior behaviour until identifier semantics are verified.
- History-only metadata cannot hide legacy alert content. Read repair preserves original agency actions, including unedited raw-source numbers; displayed advice continues existing number policy.
- Real screen fixture tests found/fixed duplicate update box and unsafe provider access during alert-screen disposal.
- Follow remains device-local; no server-side follow notification registration was added. Current source history on refresh does not prove background follow delivery.
Verification: backend27files/215tests; focused mobile82tests incl privacy, failed-share404, profile matching, source text, maps and sharing URLs; two actual full-screen and phone viewport fixture tests pass using deterministic Roboto fallback. Native Google Maps omitted from desktop fixture on purpose. Targeted Dart analysis: no issues. Admin prompt editor7targeted tests pass; prior full admin92tests/build green. Local backend typecheck still blocked only by pre-existing missing serviceAccountKey.json; no credential was created/copied.
Independent review found three material issues (404 fallback, instruction-only history, raw instruction overwrite); all fixed and reviewer rechecked with no unresolved material issue in those fixes.
Deployment: production unchanged; no new TEST deployment/phone build. AWS test session expired; new login opened but timed out awaiting completion. Last observed TEST disk96percent used; current free space cannot be rechecked without AWS access. Google CLI refresh/IAM inspection still blocked as documented separately.
Previews in audit outputs: 07nov-alert-fire-phone-top.png; 07nov-alert-bushfire-phone-share.png. These are fixtures, not screenshots of a deployed app; map and exact downloaded primary typeface still require phone QA.

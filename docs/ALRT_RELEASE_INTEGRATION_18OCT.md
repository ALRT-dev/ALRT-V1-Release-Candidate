# ALRT TEST integration checkpoint

## Scope

Continue the requested public-release preparation through the isolated TEST environment first. Production account 082258816984 remains read-only. No prices, bank/tax details or live billing changes are included.

The original checkout at `C:/Users/sarah/Documents/Codex/work/alrt-app-testbranch` has five unrelated local changes. They were preserved. Integration checks use `C:/Users/sarah/Documents/Codex/work/alrt-release-integration-18oct`, branch `codex/release-integration-18oct`.

## Integrated work

- Preserves template/CFS changes through 6f5a87e and map antimeridian fixes in 5083e1c.
- Integrates remote TEST through 4d4bfc0, including the Test Store offering fix, alert action formatting, upload compression and rollout verification corrections.
- Protects category and official agency artwork from the upload compressor. Only known user-photo destinations opt in, and converted files use the correct extension.
- Preserves every character of agency instructions when highlighting them. Conditional instructions retain uniform emphasis. Negation stays with the highlighted phrase.
- Removes conflicting instruction-shortening and three-action limits from default prompts. Existing editable prompt records are not reset or silently replaced.

## Evidence

- Backend: 202 tests passed, 27 files. TypeScript check passed.
- Mobile: 532 tests passed, 33 skipped. Targeted map, billing and formatting tests: 41 passed.
- Admin: 85 tests passed, 18 files. TEST build passed.
- Regression tests reproduced artwork conversion, text-spacing/emphasis errors and contradictory prompt limits before their fixes.
- Independent review found no remaining blockers in those corrections and no map SQL parameter-binding blocker.

## Deployment status and remaining work

The TEST health endpoint responds 200. The Admin relay points at `https://api-test.safetyalrt.com`, but its alert-template route currently returns 404. Do not describe the template controls as available until the combined backend is deployed and authenticated Admin checks pass.

AWS TEST SSO expired. Before deployment, refresh authentication, confirm account 488658242173, inspect the live checkout/image and current migration ledger, and rerun the guarded rollout. Never reuse the old expected b15bdf9/image values. The rollout script fetches `codex/alert-template-controls`; its remote tip must equal the reviewed pin. Do not republish template version 1 blindly: check the existing registry and audit first.

External Edge is not visible to the browser tools. The owner's Apple link did not itself establish that connection. A reconnect request is pending.

Android run 38998444372 produced TEST APK 0b43b4a in Test Store mode. This is not a Play Store release. Apple run 38997407445 uploaded Dev build 225 at 3064840; its Xcode project contains no AlrtWidget extension. Later run 39019631509 was a simulator-only check, with signing/upload skipped. Neither establishes that the new widget is available in TestFlight. The Apple TEST RevenueCat key is now present in repository secrets; device purchases remain unverified.

After deployment: verify CFS live ingestion and source metadata, template version 1 processing, authenticated Admin edit/preview/publish/restore, source schedules/n8n, then notifications, widgets, login, reports, family and sandbox purchase/restore on real devices. Public store signing, declarations and release readiness remain outstanding. Do not claim all bugs are gone.

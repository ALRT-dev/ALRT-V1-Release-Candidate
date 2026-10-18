# Connected ALRT TEST releases

> Execute inline using the existing isolated checkout. This continues Sarah's approved request to connect and fix the existing app, including alerts, widgets and sandbox billing.

**Goal:** Validate the connected TEST backend/admin and Apple/Android builds, then prepare the requested public store release. Sarah clarified the final destination with “I mean a public store release”. Device and store evidence remain required.

**Architecture:** Preserve the existing dev flavour and isolated TEST account. Reuse the existing mobile workflows, widget sources and billing services. Build on cloud runners so dispatched jobs continue while the local computer sleeps.

**Spec:** Sarah's 13 October request in this chat, plus the settled alert/template rules in `docs/ALRT_TEMPLATE_CONTROLS_IMPLEMENTATION.md` if present. Current source code takes priority over older product handoffs.

## Constraints

- TEST AWS account 488658242173 only for deployment. Production account 082258816984 remains read-only.
- Validate with Google Play internal testing and the separate Apple ALRT Dev app, bundle com.safetyalrt.alrt.dev. The public release destination is requested; production publication waits for verified builds/configuration and any genuinely missing owner declarations.
- Keep agency AWS symbols and native warning levels; no humanitarian square.
- Billing tests must use sandbox/test products. A bypass build cannot establish billing readiness.
- Preserve uncommitted work belonging to others. No secrets in artifacts or reports.
- Report actual checks; a build or unit test cannot prove push delivery, store purchase or installed widgets.

## Tasks

- [x] Fix the obsolete square-icon assertion and run the complete Flutter suite.
- [x] Attach the existing Swift widget sources to an extension target with the dev App Group, matching version numbers and embedding. Add repeatability/configuration tests and run a cloud iPhone simulator build.
- [ ] Extend TEST Android packaging for a signed app bundle and internal-track-only publishing. Keep virtual Test Store keys out of release bundles. Check publish credentials without exposing values.
- [ ] Run Android and iOS cloud builds from the reviewed commit and retain installation/diagnostic links.
- [ ] Restore TEST AWS authentication, apply pending migrations, deploy backend and admin, check source ingestion and configurable templates.
- [ ] Verify RevenueCat app IDs, entitlement/offerings and TEST webhook against current code. Connect missing sandbox configuration, then exercise purchase, restore and expiry on both stores.
- [ ] Audit alerts/maps, login, reports, family, notifications, widgets and safety profiles. Fix reproducible failures and rerun relevant regression checks.
- [ ] Publish the tested versions to Google Play internal testing and ALRT Dev TestFlight. Record remaining real-device checks honestly.
- [ ] Verify production signing, backend, RevenueCat and store declarations; submit the requested public release only with the required evidence.

## 15 October integration

Commits 0341147 and 0b92317 are pushed. Simulator run 38419415106 and Android TEST APK run 38419421103 passed. Neither is a public store submission. AWS TEST access is restored. Newer work on `claude/compassionate-franklin-512so7` through b15bdf9 is being merged before deployment, preserving event icons and newer database migrations.

Review corrections preserve full DFES instruction context, native warning levels, information-only caps, deterministic WAQI/GDACS content and event artwork when templates are published. Full agency warnings can be longer than the three summary facts; instruction safety takes priority over a three-point action cap.

## Review focus

1. Dev data must never share a widget App Group or backend URL with production.
2. App extensions must be embedded, signed with their own profile and carry the same build/version as Runner.
3. Store SDK configuration and server billing enforcement must agree; bypass is labelled clearly.
4. Native agency instructions and severity must survive long, messy and updated source messages.
5. Alert/widget freshness, logout and multi-user transitions must not expose stale personal data.

## Background continuation

Hourly thread heartbeat `finish-alrt-test-releases` is active. Local execution needs an awake host; already dispatched GitHub jobs run in the cloud. Follow-ups should be quiet unless progress changes or user action is needed.

# Production ingestion and admin visibility

Owner requirements: preserve the designated phone layout; list supplied elements is not a new structure. Official street detail stays. Attribute official incidents to the real source. Always retain facts/advice headings. Relevant selected-profile guidance only, full official source on expansion, category/icon/time/location/distance/follow/source updates required.

## Evidence collected 13 November

- Both AWS profiles authenticate. Production Firebase project alrt-a6539 dry-run succeeds; TEST sender remains denied. Google safety-alrt is a distinct project; no connection removed.
- n8n:44 workflows,28 active; service/Redis healthy, but feed category reads time out and error-email authentication fails. A successful webhook-auth log is not ingestion proof.
- n8n database is alrt_db; production backend is alrt_rc_db on the same private RDS host. n8n and RDS use different VPCs; no peering. Shared n8n credential is used by read and write workflows. Do not blindly repoint it or open connectivity for legacy writes.
- Production registry has18 sources. Built-in DFES/NSW/ACT/USGS feeds are receiving data; GDACS also has receipts. CFS last updated23Oct. Several n8n source IDs (mrwa,transvic,tasalert,sases,qlddm,ntes,alrt) are absent. Each needs correct source identity/governance, not a fabricated agency.

## Work

- [x] Attribution and extraction guards prepared. Merged incoming branch features while rejecting reversed negation, dropped instructions, model advice and automatic approval of draft library rows. Backend263/35 passes; Flutter606 passes,40opt-in skipped; seven full-screen alert fixtures rendered separately. Not deployed.
- [x] Admin-only all-retained preset and source-filter links, preserving current default/app visibility/retirement/privacy. Full admin105/22 and build pass; no production changes.
- [x] Honest source observation status, timestamps and visible errors; no n8n delivery claim from authentication or service health alone.
- [x] Protected read-only taxonomy API prepared with all existing webhook quota guards, avoiding private database write access. Live CFS query additionally requires isFireRelated; included and regression-tested. Workflow source cfs is registered. No pilot activated.
- [ ] Stage a source-specific workflow correction with backup, current-version guard and dry-run evidence. No wholesale activation of unregistered feeds or legacy SQL writers.
- [ ] Reconcile prompts/templates without changing live output schemas prematurely. Published TEST snapshot remainsversion1; draft4. Production has legacy prompt rows. Preserve source-only model actions and reviewed server fallback.
- [ ] Production readiness and exact deployment/rollback scope must be verified; store/provider acceptance and server Follow remain release gates. No claim of a complete launch from health200.

TEST capacity: bounded disposable build-cache cleanup recovered4.8GB, leaving6GB free. Running image e9119cba and zero restarts unchanged; rollback images, volumes and DB backups retained.

Verification notes: first bare backend run found stale compiled dist tests; source-relative fixture tests were executed twice and the dist copies failed. Vitest now explicitly excludes dist; all263 source tests pass. First full admin run timed out under concurrent compilation; focused12 checks and a clean sequential full105 rerun pass without relaxed timeouts. Local tsc reports only the known missing private Firebase serviceAccountKey.json; no credential copied from production.

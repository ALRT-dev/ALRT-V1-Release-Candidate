# Production ingestion and admin visibility

Owner requirements: preserve the designated phone layout; list supplied elements is not a new structure. Official street detail stays. Attribute official incidents to the real source. Always retain facts/advice headings. Relevant selected-profile guidance only, full official source on expansion, category/icon/time/location/distance/follow/source updates required.

## Evidence collected 13 November

- Both AWS profiles authenticate. Production Firebase project alrt-a6539 dry-run succeeds; TEST sender remains denied. Google safety-alrt is a distinct project; no connection removed.
- n8n:44 workflows,28 active; service/Redis healthy, but feed category reads time out and error-email authentication fails. A successful webhook-auth log is not ingestion proof.
- n8n database is alrt_db; production backend is alrt_rc_db on the same private RDS host. n8n and RDS use different VPCs; no peering. Shared n8n credential is used by read and write workflows. Do not blindly repoint it or open connectivity for legacy writes.
- Production registry has18 sources. Built-in DFES/NSW/ACT/USGS feeds are receiving data; GDACS also has receipts. CFS last updated23Oct. Several n8n source IDs (mrwa,transvic,tasalert,sases,qlddm,ntes,alrt) are absent. Each needs correct source identity/governance, not a fabricated agency.

## Work

- [x] Attribution patch and guarded extraction wording prepared; backend229 tests and focusedFlutter38 checks pass. Empty extraction retains an honest facts heading. Not deployed.
- [ ] Admin-only all-retained preset and source-filter links, preserving current default/app visibility/retirement/privacy. Agent owns admin pages/API/helper/tests; no production changes.
- [ ] Honest source observation status, timestamps and visible errors; do not label n8n delivery healthy from authentication or service health alone.
- [ ] Prepare least-privilege API taxonomy read for existing webhook integrations, avoiding opening private database write access. Verify workflow item shape and registered source before any pilot.
- [ ] Stage a source-specific workflow correction with backup, current-version guard and dry-run evidence. No wholesale activation of unregistered feeds or legacy SQL writers.
- [ ] Reconcile prompts/templates without changing live output schemas prematurely. Published TEST snapshot remainsversion1; draft4. Production has legacy prompt rows. Preserve source-only model actions and reviewed server fallback.
- [ ] Production readiness and exact deployment/rollback scope must be verified; store/provider acceptance and server Follow remain release gates. No claim of a complete launch from health200.

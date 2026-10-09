# Admin Portal — Release-Candidate Verification

**Date:** 2026-10-09  
**Branch:** `release-candidate` (commit b604b2b)  
**Portal path:** `admin/`

---

## Build Verification

| Check | Result |
|-------|--------|
| TypeScript compilation (`tsc -b --noEmit`) | CLEAN — no errors |
| Production build (`npm run build`) | PASS — 315KB JS, 6KB CSS |
| Test build (`npm run build:test`) | PASS — 319KB JS, 6KB CSS |
| Lint (`npm run lint`) | Not run (oxlint, optional) |

## Test Suite

| Metric | Value |
|--------|-------|
| Test files | 17 |
| Tests | 77 |
| Result | **ALL PASS** |
| Framework | Vitest 4.1.11 + @testing-library/react |

Test files cover: auth context, login, change password, role gating,
alerts page, test alert picker, moderation page, sources & audit log,
categories page, Ask ALRT content pages, Ask ALRT AI switch, list
filters & paging, pagination logic, API client, missing route handling,
n8n workflow, pages relay.

## Pages & Routes (14 screens)

| Route | Page | Role gate |
|-------|------|-----------|
| `/` | Dashboard | all |
| `/alerts` | Alerts | all |
| `/moderation` | Moderation | all |
| `/sources` | Sources | all |
| `/categories` | Categories / Icons | all |
| `/users` | Users | all |
| `/admin-accounts` | Admin Accounts | all |
| `/ai-prompts` | AI Prompts | all |
| `/configuration` | Configuration | all |
| `/webhook-keys` | Webhook API Keys | all |
| `/ask-alrt` | Ask ALRT | all |
| `/ask-alrt-library` | Ask ALRT Answers | all |
| `/emergency-numbers` | Emergency Numbers | all |
| `/audit-log` | Audit Log | admin, superAdmin |
| `/change-password` | Change Password | all (outside layout) |
| `/login` | Login | unauthenticated |

## Deployment Configuration

- **Stack:** Vite + React 19 + TypeScript + react-router-dom
- **Hosting:** Cloudflare Pages (static `dist/` output + Pages Function relay)
- **API relay:** `functions/api/[[path]].ts` proxies `/api/*` to the backend
- **Production API:** Set via `API_ORIGIN` env var on the Cloudflare Pages project
- **Current CI deployment:** `alrt-v1-release-candidate.pages.dev` (test API)

### Production deployment steps

1. Cloudflare Pages → Create → Connect to Git: `ALRT-dev/ALRT-V1-Release-Candidate`, production branch `release-candidate`.
2. Build settings: root directory `admin`, build command `npm run build`, output directory `dist`.
3. Environment variables (Production): `API_ORIGIN=https://api.safetyalrt.com`.
4. Custom domain: `admin-new.safetyalrt.com` (beside the existing old portal at `admin.safetyalrt.com`).

## P0 Fix Impact on Admin Portal

None of the 8 P0 fixes (R-01 through R-08) change the Admin API surface. The admin portal calls the same endpoints, with the same request/response shapes. No admin portal code changes are required for the P0 fixes.

| P0 Fix | Admin portal impact |
|--------|-------------------|
| R-01/R-02: OAuth email_verified | None — mobile app auth only |
| R-03: AI summarisation fallback | None — ingestion is backend-internal; alerts appear the same in admin |
| R-04: Invalid model seed | None — AI service config, no admin API change |
| R-05: .env not bundled | None — Flutter mobile only |
| R-06: Encrypted token storage | None — Flutter mobile only |
| R-07: RevenueCat timing-safe auth | None — webhook controller, not admin API |
| R-08: Migration rehearsal | None — documentation only |

## Changes in This PR

1. **README.md:** Updated Cloudflare Pages deployment branch from `claude/compassionate-franklin-512so7` (old development branch) to `release-candidate`.

## Known Limitations (unchanged, not blocking)

Per `admin/README.md` "Known V1 limitations" and `V1_RECONCILIATION_REPORT.md` §24:

- No hazard map view (the old portal has one; the new one does not)
- No ALRT+/subscription stats on the dashboard (backend endpoint doesn't query plan data)
- Category icon image upload not supported (text fields only)
- AI Prompt create/delete and Configuration value editing intentionally unexposed
- Source registry: feed URL/adapter/schedule are reference-only, not operational
- Paging shows "Page X" (not "Page X of Y") on most screens

## Conclusion

The admin portal builds, tests pass, and is ready to deploy from `release-candidate` alongside the backend release. No code changes are needed — only the deployment branch reference in the README was stale.

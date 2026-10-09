# 04 -- Way Forward

Audit date: 2026-10-09
Scope: READ ONLY. No edits, deployments, or writes to any live environment.

This document provides a sequenced plan for moving from the current state (production
running backendV2 at commit 5ce3825, Flutter app pointing at it, prototype on a
mock backend) to a shipped release-candidate with the redesigned UI.

---

## 1. Current State Summary

| Layer | State | Reference |
|---|---|---|
| Production backend | backendV2 (July 2026), 82 migrations, ~60-70 endpoints | 02_BACKEND_CONNECTIONS.md section 1 |
| Release-candidate backend | 116 migrations, 120+ endpoints, 54 Prisma models | 02_BACKEND_CONNECTIONS.md section 2 |
| Flutter app | 50 GoRouter routes, 90+ REST calls, all SDKs present | 01_TEST_APP_CONNECTIONS.md |
| Prototype | 85 UI states on mock backend, 204/204 checks passed | 03_NEW_UI_DEPENDENCY_MAP.md |
| TEST environment | AWS account 488658242173, api-test.safetyalrt.com | 01_TEST_APP_CONNECTIONS.md section 9 |

**Key gaps**: 34 unapplied migrations, 19 new Prisma models, 7 unresolved conflicts,
8 backend gaps, 22 undesigned screens, 25 route path differences, and 3 store-
blocking missing screens.

---

## 2. Decision Gate: Resolve Conflicts First

Before any code changes, these 7 conflicts must have a single canonical answer.
Each affects API contracts or business logic that downstream work depends on.

| # | Conflict | Recommended resolution | Rationale |
|---|---|---|---|
| 1 | Tab count (6 vs 5) | Adopt 5 tabs from prototype | Cleaner nav; search merges into alerts header |
| 2 | Streaks (backend has them, design says no) | Keep streaks in backend, hide in UI for V1 launch | No data loss; can re-enable later |
| 3 | SOS 4-hour cap | Add cap in code to match docs | Safety feature; indefinite SOS is a liability |
| 4 | Who ends SOS | Allow host to end, matching docs | Host needs ability in emergency scenarios |
| 5 | Ask ALRT counting | Exempt library/emergency from daily count | Aligns with product intent; safety queries should not be rationed |
| 6 | Group capacity defaults | Use the documented tier values from CLAUDE.md | Schema defaults are easily overridden; docs are the product spec |
| 7 | Community push timing | Confirm immediate push (do not implement R08 delay) | Proposal was not approved; current behavior is correct |

**Action**: Sarah and Matt review and sign off on each row. Record decisions in
a DECISIONS.md file in `docs/`. All downstream work references that file.

---

## 3. Sequenced Work Phases

### Phase A: Backend deployment to TEST (no Flutter changes)

**Goal**: Get the release-candidate backend running on the TEST environment so
the Flutter app can be tested against real (not mock) endpoints.

| Step | Task | Depends on | Estimate |
|---|---|---|---|
| A1 | Resolve all 7 conflicts (section 2) | Sarah + Matt sign-off | 1 day |
| A2 | Prepare TEST `.env.test` with all new env vars (02_BACKEND_CONNECTIONS.md section 3.2) | A1 | 0.5 day |
| A3 | Set up Bedrock IAM role on TEST account (or explicit creds) | -- | 0.5 day |
| A4 | Set up RevenueCat sandbox webhook at `api-test.safetyalrt.com/api/revenuecat/webhook` | -- | 0.5 day |
| A5 | Deploy release-candidate to TEST EC2; run `prisma migrate deploy` (34 new migrations) | A2 | 1 day |
| A6 | Smoke test: health check, sign-in, alert load, push, Ask ALRT, SOS start/stop | A5 | 1 day |
| A7 | Implement backend changes for conflicts (SOS cap, host-end, Ask ALRT counting exemption, group capacity) | A1 | 2 days |
| A8 | Implement backend gap #12/#77: add `minimumBand` field to `UserPushNotificationSetting` | A1 | 1 day |
| A9 | Implement backend gap #83: timezone-aware scheduled check-ins | -- | 1 day |
| A10 | Re-smoke-test after A7-A9 | A7, A8, A9 | 0.5 day |

**Phase A total**: ~8-9 days elapsed (some steps run in parallel).

### Phase B: Flutter UI -- store-blocking and core screens

**Goal**: Build the minimum set of screens required for App Store / Play Store
submission, plus the new tab structure.

| Step | Task | Depends on | Estimate |
|---|---|---|---|
| B1 | Restructure to 5 tabs (Alerts, Ready, Report, Family, Me) | A1 (tab decision) | 2 days |
| B2 | Update push notification deep-link routing for new tab structure | B1 | 1 day |
| B3 | Build Report/Block sheet (missing #22) -- store compliance | A5 (real flag endpoint) | 1 day |
| B4 | Build Blocked Accounts into Me tab (missing #62) -- store compliance | A5 | 0.5 day |
| B5 | Build Delete Account flow into Me tab (missing #64) -- store compliance | A5 | 0.5 day |
| B6 | Build alert filters bottom sheet (missing #18) | -- | 1 day |
| B7 | Build notification priming sheet (missing #57) | -- | 0.5 day |
| B8 | Restyle COVERED screens (24 screens) to new design palette | -- | 3-4 days |
| B9 | Build Ready tab with Learn, Drill, Plan sections | -- | 2 days |
| B10 | Fix Me tab: add links to My ALRTs, child mode, support, delete, widget, share, language, legal, logout | B4, B5 | 2 days |
| B11 | Restyle onboarding flow; add alert level step (needs A8 for backend) | A8 | 1.5 days |
| B12 | Wire access refusal sheet with all 11 codes | A5 | 1 day |
| B13 | Fix route path differences: correct any mock paths used in Flutter (see 03 section 3) | A5 | 0.5 day |

**Phase B total**: ~12-14 days elapsed (steps within B can parallel with 2 developers).

### Phase C: Flutter UI -- Family and subscription screens

**Goal**: Complete the family feature screens and subscription flows.

| Step | Task | Depends on | Estimate |
|---|---|---|---|
| C1 | Design and build 15 missing family screens (check-in consent, location request, group settings, switch group, circle profile, sharing level, family places, SOS lists, SOS resolved, shared journey, group paused, leave, transfer, FamilySafeStrip, SOS history) | A5, A7 | 5-6 days |
| C2 | Complete PARTIAL family screens (hub member detail, invite QR scanner, SOS receiver, journey recipient picker) | A5 | 2-3 days |
| C3 | Build upgrade/downgrade flow for group paywall (partial #69) | A5 | 1 day |
| C4 | Build billing issue / bind-unbound states for ALRT+ manage (partial #70) | A5 | 1 day |
| C5 | Build onboarding complete screen with 20pt endowed progress (missing #11) | -- | 0.5 day |
| C6 | Fix widgets: correct 'ALL CLEAR' wording, fix iOS family widget state check | -- | 0.5 day |
| C7 | Build language picker sheet (missing #66) | -- | 0.5 day |
| C8 | Build accessible alerts section (missing #58) | -- | 0.5 day |

**Phase C total**: ~10-12 days elapsed (parallel work possible).

### Phase D: Integration testing on TEST

**Goal**: Full end-to-end testing of Flutter app against release-candidate backend
on TEST environment.

| Step | Task | Depends on | Estimate |
|---|---|---|---|
| D1 | Connect Flutter dev build to api-test.safetyalrt.com | B, C complete | 0.5 day |
| D2 | Test all auth flows (Google, Apple, email) | D1 | 0.5 day |
| D3 | Test onboarding flow end to end | D1 | 0.5 day |
| D4 | Test alert lifecycle: create, view, vote, flag, block, delete | D1 | 1 day |
| D5 | Test family lifecycle: create circle, invite, check-in, SOS, journey, places | D1 | 2 days |
| D6 | Test subscription lifecycle: purchase, reconcile, sponsor, bind, downgrade | D1 | 1 day |
| D7 | Test push notifications (all 16 types) with correct deep links | D1 | 1 day |
| D8 | Test scheduled jobs: hazard sync, check-in cron, SOS cron | D1 | 0.5 day |
| D9 | Test force update gate | D1 | 0.5 day |
| D10 | Regression: run through all 87 traceability entries | D2-D9 | 2 days |

**Phase D total**: ~7-8 days elapsed.

### Phase E: Production deployment

**Goal**: Deploy release-candidate backend to PROD and ship the app.

Follow the 10-step switch-on order from `docs/LIVE_CONNECTIONS.md:43-96`:

| Step | Task | Gate |
|---|---|---|
| E1 | Back up RDS snapshot + copy `.env.prod` | -- |
| E2 | Prepare `.env.prod` using `fill-env-prod-from-aws.sh` and `check-env-prod.sh` | E1 |
| E3 | Deploy backend: `prisma migrate deploy` (34 migrations on PROD) | E2 |
| E4 | Health check: `/api/test` answers, sign-in works, alerts arrive | E3 |
| E5 | RevenueCat: set `REVENUECAT_WEBHOOK_AUTH`, send test event, confirm 200 | E4 |
| E6 | Admin portal: build and host at `admin-new.safetyalrt.com` | E4 |
| E7 | Ask ALRT: now in-backend; keep Firebase function until all clients update | E4 |
| E8 | n8n: confirm webhook key still works | E4 |
| E9 | App release: ship Flutter production build | E4 |
| E10 | Turn on billing: set `BILLING_ENABLED=true` after one real purchase verified | E9 |

**Critical reminders** (LIVE_CONNECTIONS.md:90-97):
- Confirm RDS `alrt-app-db-dev` holds real users before migration (ask Matt)
- Never put `alrt_dev_*` products in `RC_PRODUCT_TIERS`
- Never set `RC_EXPECTED_ENVIRONMENT=SANDBOX` on live
- Do not change JWT secrets during upgrade
- Do not commit credentials to this repository

**Phase E total**: ~2-3 days elapsed (mostly verification).

---

## 4. Items NOT in Scope for V1 Launch

These can be deferred without blocking the release:

| Item | Reason to defer |
|---|---|
| Apple Watch (backend gap #75) | No watch target in repo; significant effort; not store-blocking |
| Daily digest (backend gap #85) | Not store-blocking; can ship as a post-launch update |
| Admin review push/XP (backend gap #84) | Nice-to-have; reporters still see approval in My ALRTs |
| Microsoft Sign-In | Code exists but UI is commented out; not needed for launch |
| Voice priming/listening (missing #24) | Not in new design |
| Spanish localization | easy_localization is set up; strings not yet translated |
| Google Routes key proxy (backend gap #87) | Mitigate by restricting the client key; full proxy is a larger effort |
| Streaks in XP UI | Hidden in UI; backend keeps calculating silently |

---

## 5. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| 34 migrations fail on PROD RDS | Low | High -- blocks deployment | Test migrations on a PROD snapshot first (step E1) |
| RevenueCat webhook still 404s after deploy | Low | Medium -- subscriptions fail silently | Smoke test in Phase A; monitor webhook dashboard |
| `gpt-5-nano` model name rejected by OpenAI | Medium | Low -- Bedrock is default provider | Only hit if AI_PROVIDER switched to openai; fix model name proactively |
| Tab restructure breaks deep links | Medium | Medium -- push notifications go to wrong screen | Dedicated testing in Phase D7; update routing table in B2 |
| RDS named `alrt-app-db-dev` is not actually production | Low | Critical -- data loss if wrong DB migrated | Confirm with Matt before any PROD migration |
| Firebase owner access needed (Matt only) | Low | Medium -- can't change APNs key or project settings | Document Matt as sole Firebase owner; no action needed unless key rotation |
| Prototype-to-Flutter translation errors | High | Medium -- screens don't match design | Use traceability matrix row-by-row during Phase B and C |

---

## 6. Estimated Timeline

Assuming 1-2 developers working in parallel:

| Phase | Duration | Cumulative |
|---|---|---|
| A: Backend to TEST | 8-9 days | Week 1-2 |
| B: Flutter core + store-blocking | 12-14 days | Week 3-5 |
| C: Flutter family + subscriptions | 10-12 days | Week 4-6 (overlaps with B) |
| D: Integration testing | 7-8 days | Week 7-8 |
| E: Production deployment | 2-3 days | Week 8-9 |

**Total estimate**: 7-9 weeks from decision sign-off to production.

With one developer, add 3-4 weeks (Phases B and C cannot overlap).

---

## 7. Recommended Next Steps (Immediate)

1. **Sarah + Matt**: Review and sign off on the 7 conflicts (section 2). Record
   in `docs/DECISIONS.md`.
2. **Sarah**: Confirm RDS `alrt-app-db-dev` is the real production database (ask
   Matt directly).
3. **Developer**: Set up TEST environment with new env vars (Phase A2-A4) while
   conflict decisions are made.
4. **Designer/Developer**: Begin prototype designs for the 22 MISSING screens,
   prioritizing the 3 store-blocking items (#22 Report/Block, #62 Blocked
   Accounts, #64 Delete Account).

---

## End of Phase 4 Audit

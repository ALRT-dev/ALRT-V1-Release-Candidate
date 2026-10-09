# ALRT V1 Release-Candidate — Feature Audit

**Repo:** ALRT-dev/alrt-v1-release-candidate  
**Branch:** `release-candidate`  
**Commit:** `495a764f` (2026-10-08)  
**Auditor:** Claude (automated analysis + sandbox probe)  
**Date:** 2026-10-09  
**Prior audit:** [ALRT V1 Baseline Audit](https://claude.ai/code/artifact/e790f20e-118f-4fb9-83cb-bc2c89d61202) (14 deliverables, NO-GO with 8 P0 items)

---

## Section A — Feature Freeze Checklist (9-Point)

The engineering brief requires each of the nine items below to be assessed against the release-candidate code.

### A1. Hazard Ingestion Coverage

| Column | Detail |
|--------|--------|
| **Feature** | External hazard data ingestion — 15-minute cron sync from 16 configured sources via `ingestion.service.ts`; n8n webhook ingest via `POST /api/webhook/hazards` |
| **Works in prod?** | YES (production runs backendV2 which has the same ingestion architecture, minus newer sources). 14 of 16 sources active in prod codebase. |
| **Works in sandbox?** | PARTIALLY — TEST server at `api-test.safetyalrt.com` is running release-candidate code. Webhook route responds (CORS error from browser = route exists). Hazard sync requires valid API keys for each feed. WAQI, NSW Transport, QLD Traffic need API keys. |
| **Broken element** | (1) BoM (Bureau of Meteorology) feed **commented out** in ingestion service — Australian weather alerts not flowing. (2) Smartraveller feed **commented out** — travel advisories not flowing. (3) AI summarisation failure **silently drops hazards** (`ingestion.service.ts` ~line 896 returns null, hazard filtered out). |
| **Severity** | **P0** (R-03: AI failure drops hazards), **P2** (BoM and Smartraveller disconnected) |
| **Proposed fix** | R-03: On AI failure, pass hazard through with raw title/description, log error, retry once. BoM/Smartraveller: uncomment and test. |
| **Risk to prod** | R-03 is critical — emergency alerts could be silently lost if AI service is down. |
| **Cost impact** | Ingestion runs every 15 min. AI calls per cycle depend on new-hazard volume. Bedrock Claude Haiku pricing applies. |

### A2. Categorisation Accuracy

| Column | Detail |
|--------|--------|
| **Feature** | AI-driven hazard categorisation via Bedrock (Claude Haiku) or OpenAI fallback. Admin-editable prompts. 7 parent categories (Weather, Health, Security, Traffic, Utilities, Community, Other). |
| **Works in prod?** | YES (production uses OpenAI for categorisation). |
| **Works in sandbox?** | **BLOCKED** — DB seed contains invalid model `gpt-5-nano` in `AIPrompt.model` field. AI enrichment will fail on first run with a fresh database. |
| **Broken element** | (1) `gpt-5-nano` invalid model in DB seed (R-04). (2) If AI fails, the categorisation fails silently (tied to R-03). |
| **Severity** | **P0** (R-04: invalid model seed) |
| **Proposed fix** | Replace seed model with valid Bedrock model name (`global.anthropic.claude-haiku-4-5-20251001-v1:0`) or valid OpenAI model (`gpt-4o-mini`). |
| **Risk to prod** | Medium — fresh deployment with seed data would have broken AI. Admin portal can override at runtime. |
| **Cost impact** | None beyond normal AI call costs. |

### A3. Information Accuracy

| Column | Detail |
|--------|--------|
| **Feature** | AI confidence scoring (`aiConfidence` enum), severity banding (Info/Monitor/Action/Critical), source attribution (`HazardSource` model, `isAwsCompliant` flag), community corroboration (`corroborationCount`), user voting, AI review pipeline with `mapAiReviewStatus` gating. |
| **Works in prod?** | PARTIALLY — production has basic severity and source attribution but not the AI confidence scoring or review pipeline (those are new in release-candidate). |
| **Works in sandbox?** | UNTESTED — depends on AI pipeline functioning (blocked by R-03, R-04). Source attribution and severity banding are code-level features that work independently of AI. |
| **Broken element** | AI confidence scoring untestable while AI pipeline is broken. |
| **Severity** | P1 (dependent on P0 fixes R-03, R-04) |
| **Proposed fix** | Fix R-03 and R-04 first, then verify AI confidence scores are populated correctly. |
| **Risk to prod** | Low — fallback paths exist (hazards display without AI enrichment). |
| **Cost impact** | None additional. |

### A4. Map Quality

| Column | Detail |
|--------|--------|
| **Feature** | Google Maps SDK (`google_maps_flutter 2.13.1`), client-side clustering (`google_maps_cluster_manager_2`), hazard corridor detection, navigation overlay with route hazard avoidance, bypass waypoint planner. 2645-line map provider. |
| **Works in prod?** | YES — map with clustering is operational in production app. |
| **Works in sandbox?** | PARTIALLY — map rendering works if Google Maps API key is valid. Backend maps proxy (`/api/maps/geocode`, `/places/autocomplete`, `/places/details`) returned 404 in browser test (path structure may differ or require auth). |
| **Broken element** | (1) Speed calculation bug: map provider divides distance by 1.0, assuming 1-second GPS intervals regardless of actual update interval. (2) Maps proxy 404 needs investigation. |
| **Severity** | P2 (speed calc), P1 (maps proxy 404) |
| **Proposed fix** | Speed calc: use actual time delta between GPS updates. Maps proxy: verify route registration and API key configuration. |
| **Risk to prod** | Low — speed display is cosmetic. Maps proxy 404 could break place search in app. |
| **Cost impact** | Google Maps Platform: per-request pricing for Geocoding ($5/1K), Places ($17-40/1K), Routes v2 ($5-10/1K). Routes API called client-side (not proxied). |

### A5. Proximity Notifications

| Column | Detail |
|--------|--------|
| **Feature** | Location subscriptions via PostGIS GiST index. FCM push notifications with two Android channels (normal + urgent). Severity-based actions, foreground TTS for ACTION/CRITICAL. Emergency alerts bypass notification cooldown. Configurable radius. Home screen widget for alerts. |
| **Works in prod?** | YES — push notifications operational in production. |
| **Works in sandbox?** | UNTESTED from sandbox directly. FCM requires valid `FIREBASE_PROJECT_ID` and credentials. |
| **Broken element** | (1) `push_notification_provider.dart` is an **empty file** (dead code). (2) Redis NX dedup uses unbounded local Map fallback — in multi-instance deployment, Map doesn't sync across instances. |
| **Severity** | P2 (empty provider file — cosmetic), P1 (Redis dedup fallback in multi-instance) |
| **Proposed fix** | Remove empty provider file. For multi-instance: ensure Redis/Valkey is configured, or document single-instance constraint. |
| **Risk to prod** | Low for single-instance deployment. Medium if scaled to multiple instances without Redis. |
| **Cost impact** | FCM: free tier covers most usage. Redis/Valkey (ElastiCache): ~$13/month for cache.t3.micro. |

### A6. XP Calculation

| Column | Detail |
|--------|--------|
| **Feature** | XP/gamification system with `XpEvent` model, audit trail, badges (`UserBadge`), leaderboard, points breakdown. Backend endpoints: `/api/xp/summary`, `/breakdown`, `/leaderboard`, `/badges`. Cron awards XP for expired community reports every 10 min. |
| **Works in prod?** | YES — XP system exists in production. |
| **Works in sandbox?** | UNTESTED — requires active users and hazard interactions to generate XP events. |
| **Broken element** | None identified in code analysis. |
| **Severity** | — |
| **Proposed fix** | — |
| **Risk to prod** | None identified. |
| **Cost impact** | None — purely database-driven. |

### A7. Safety Tips Matched to Hazards

| Column | Detail |
|--------|--------|
| **Feature** | Learn Hub with `SafetyGuideTopic` and `SafetyGuide` models. Category-matched guides via `GET /api/guides/for-category/{categoryId}`. Phase-based guide progression. Completion tracking (`UserGuideProgress`). "For You" card on profile. |
| **Works in prod?** | UNTESTED — guide content depends on seed data or admin-created entries. |
| **Works in sandbox?** | UNTESTED — requires guide content in database. |
| **Broken element** | None in code. Depends on content being populated via admin portal. |
| **Severity** | P2 (content dependency) |
| **Proposed fix** | Seed initial safety guides via admin portal or migration seed. Verify category matching works. |
| **Risk to prod** | Low — empty guides show no content, no crash. |
| **Cost impact** | None. |

### A8. Hazard Reporting

| Column | Detail |
|--------|--------|
| **Feature** | Community hazard reports with multi-layer safety: AI category → rate limiting (3/hr, 10/day per user) → geographic dedup (500m) → Sightengine media moderation → S3 upload → AI review → PII detection (phone, email, address, plates, URLs). Voting, flagging, duplicate detection UI. Voice dictation via `speech_to_text`. Child mode blocks reporting route. |
| **Works in prod?** | YES — community reporting works in production (without media, which is disabled). |
| **Works in sandbox?** | PARTIALLY — report submission works. Media uploads disabled (`COMMUNITY_REPORT_MEDIA_ENABLED=false`). Sightengine moderation path exists but is feature-flagged off. |
| **Broken element** | Media upload path is disabled for V1. Not a bug — intentional feature flag. |
| **Severity** | — (intentional) |
| **Proposed fix** | None needed for V1. Media can be enabled post-launch. |
| **Risk to prod** | None. |
| **Cost impact** | Sightengine: $9/month base when enabled. S3: negligible for media storage. AI review per report: ~$0.001/report via Bedrock Haiku. |

### A9. Family Mode

| Column | Detail |
|--------|--------|
| **Feature** | Comprehensive family system: circles (create/join/leave/transfer), SOS (send/receive/resolve/extend with 1-hour duration, preset lists, trail, history), check-in (request/respond/roll call/scheduled), location sharing (manual/live with exact/suburb levels), journeys (start/stop/extend/share/track), saved places with geofence preferences. 50+ backend routes under `/api/family/*`. Socket.IO for live updates. QR code invite via `mobile_scanner`/`qr_flutter`. 19 screen files in frontend. |
| **Works in prod?** | NO — Family mode is **new** in release-candidate. Not in production backendV2. |
| **Works in sandbox?** | UNTESTED — requires multiple test accounts, active Socket.IO, and valid FCM for push. |
| **Broken element** | None identified in code analysis. Feature-complete implementation. |
| **Severity** | — |
| **Proposed fix** | End-to-end testing required with multiple accounts before release. |
| **Risk to prod** | Medium — large new feature surface area, untested in production environment. |
| **Cost impact** | FCM for family push notifications. PostGIS queries for location. Socket.IO connections per concurrent user. |

---

## Section B — Full Feature Register

Every feature in the release-candidate, beyond the 9-point checklist.

| # | Feature | Status | Works in Prod? | Works in Sandbox? | Broken Element | Severity | Proposed Fix | Risk to Prod | Cost Impact |
|---|---------|--------|---------------|-------------------|---------------|----------|-------------|-------------|-------------|
| B1 | **Email/password auth** | Existing | YES | UNTESTED | — | — | — | None | None |
| B2 | **Google OAuth** | Existing | YES | UNTESTED | — | — | — | None | None |
| B3 | **Apple Sign-In** | Existing | YES | UNTESTED | `email_verified` not checked (R-01) | **P0** | Reject sign-ins where `email_verified` is false/absent | **HIGH** — unverified emails can create accounts | None |
| B4 | **Microsoft OAuth** | Existing | YES | UNTESTED | `email_verified` not checked (R-02) | **P0** | Same fix as R-01 for Microsoft flow | **HIGH** | None |
| B5 | **Onboarding flow** | Existing | YES | UNTESTED | — | — | — | None | None |
| B6 | **User profile** | Existing | YES | UNTESTED | — | — | — | None | None |
| B7 | **Account deletion** | Existing | YES | UNTESTED | — | — | — | None | None |
| B8 | **Child mode** | Existing | YES | UNTESTED | — | — | — | None | None |
| B9 | **Blocked accounts** | Existing | YES | UNTESTED | — | — | — | None | None |
| B10 | **Support requests** | Existing | YES | UNTESTED | — | — | — | None | None |
| B11 | **ALRT+ subscription (RevenueCat)** | New | NO (not in prod) | **BROKEN** — webhook returns 404 on prod backend (R-07) | Webhook 404, `BILLING_ENABLED=false` | **P0** | Deploy release-candidate backend with webhook route. Configure RevenueCat auth token. | **HIGH** — subscriptions can't sync | RevenueCat: free < $2.5M revenue |
| B12 | **Access/entitlement system** | New | NO | UNTESTED | Depends on RevenueCat (R-07) | P1 | Fix R-07 first | Medium | None |
| B13 | **Ask ALRT (AI chatbot)** | Modified | YES (via Firebase Function) | UNTESTED | Now runs in-backend via Bedrock. Old Firebase function still exists. | P1 | Verify Bedrock config. Keep old function until all users update. | Medium | Bedrock Haiku: ~$0.001/query |
| B14 | **Admin portal (new)** | New | NO (old portal at admin.safetyalrt.com) | YES — login page serves at `alrt-v1-release-candidate.pages.dev` | Two portals coexist. New lacks hazard map from old. | P2 | Migrate hazard map to new portal. Redirect old domain. | Low | Cloudflare Pages: free |
| B15 | **Admin 3-tier RBAC** | New | NO | UNTESTED | — | — | — | None | None |
| B16 | **Admin AI prompt management** | New | NO | UNTESTED | — | — | — | None | None |
| B17 | **Admin audit log** | New | NO | UNTESTED | — | — | — | None | None |
| B18 | **Admin moderation queue** | New | NO | UNTESTED | — | — | — | None | None |
| B19 | **Admin hazard source management** | New | NO | UNTESTED | — | — | — | None | None |
| B20 | **Admin configuration panel** | New | NO | UNTESTED | — | — | — | None | None |
| B21 | **Admin webhook key management** | New | NO | UNTESTED | — | — | — | None | None |
| B22 | **Admin Ask ALRT management** | New | NO | UNTESTED | — | — | — | None | None |
| B23 | **Admin stats dashboard** | New | NO | UNTESTED | — | — | — | None | None |
| B24 | **Notification feed** | Existing | YES | UNTESTED | — | — | — | None | None |
| B25 | **Alert view/share pages** | Existing | YES | UNTESTED | — | — | — | None | None |
| B26 | **Corroboration system** | New | NO | UNTESTED | — | — | — | None | None |
| B27 | **App version policy** | Existing | YES | UNTESTED | — | — | — | None | None |
| B28 | **Home screen widget** | New | NO | UNTESTED | — | — | iOS/Android widget rendering | None |
| B29 | **Navigation/route avoidance** | New | NO | UNTESTED | — | — | Uses Routes API v2 (cost-per-call) | Google Routes: $5-10/1K |
| B30 | **Voice dictation for reports** | New | NO | UNTESTED | — | — | — | None | None |

---

## Section C — Security Findings (from Baseline Audit)

| ID | Finding | Severity | Status |
|----|---------|----------|--------|
| **R-01** | Apple OAuth does not check `email_verified` — unverified Apple emails can create accounts | **P0** | OPEN |
| **R-02** | Microsoft OAuth does not check `email_verified` — same issue | **P0** | OPEN |
| **R-03** | AI summarisation failure silently drops hazards — emergency alerts could be lost | **P0** | OPEN |
| **R-04** | `gpt-5-nano` invalid model in DB seed — AI enrichment fails on fresh DB | **P0** | OPEN |
| **R-05** | `.env` bundled as Flutter asset — API keys exposed in app binary | **P0** | OPEN |
| **R-06** | Auth tokens stored in SharedPreferences (unencrypted) — readable on rooted device | **P0** | OPEN |
| **R-07** | RevenueCat webhook returning 404 — subscriptions cannot sync | **P0** | OPEN |
| **R-08** | Database migration rehearsal needed — 115 migrations, 34+ new since prod | **P0** | OPEN |

---

## Section D — Paywall / Entitlement Gates

| Feature | Gate Mechanism | Free Tier | ALRT+ Tier | Sandbox Status |
|---------|---------------|-----------|------------|----------------|
| Saved locations | `SavedLocationGate` | 1 saved place | Unlimited | UNTESTED (`BILLING_ENABLED=false` means all gates open) |
| Ask ALRT daily limit | Backend `/api/ask-alrt/allowance` | 3/day | 10/day | UNTESTED |
| Family group connections | Backend 402/409/422 responses | Limited | Full access | UNTESTED |
| ALRT+ onboarding offer | Optional screen in onboarding flow | Skippable | — | UNTESTED |

**Note:** With `BILLING_ENABLED=false` on TEST, all entitlement checks default to YES. Gates cannot be tested until billing is enabled with test RevenueCat credentials.

---

## Section E — Dead Code, Unused Dependencies, Duplicated Logic

| Item | Type | Location | Impact |
|------|------|----------|--------|
| `push_notification_provider.dart` | Empty file | `frontend/lib/features/notification/providers/` | Dead code — provider declared but contains no implementation |
| Old admin portal | Duplication | `admin.safetyalrt.com` (separate repo) vs new admin in this repo | Two admin portals coexist. Old has hazard map the new one lacks. |
| `GET /api/test` | Test endpoint | `backend/src/index.ts` line 139 | Trivial test route left in production code. Low risk. |
| 43 verify scripts | Test harness accumulation | `backend/src/scripts/` | One-off verification scripts. Not dead code per se but could be cleaned up. |
| Sightengine integration | Feature-flagged OFF | `backend/src/services/image_video_detection.service.ts` | Code and env vars wired but `COMMUNITY_REPORT_MEDIA_ENABLED=false`. Intentional for V1. |
| `ALERT_EDITS_ENABLED` flag | Feature-flagged OFF | `backend/src/controllers/hazard.controller.ts` line 741 | Gates a hazard edit feature that appears off by default. |
| Old Ask ALRT Firebase Function | Legacy | Exists externally (Firebase project `alrt-a6539`) | Replaced by in-backend Ask ALRT. Old function should be kept until all users update app. |
| Speed calculation in map | Bug | `frontend/lib/features/map/` — divides distance by 1.0 | Assumes 1-second GPS intervals. Cosmetic bug. |

---

## Section F — Cost-per-Call Services

| Service | Trigger | Estimated Volume | Unit Cost | Monthly Estimate |
|---------|---------|-----------------|-----------|-----------------|
| **AWS Bedrock (Claude Haiku)** | Every new hazard (AI summary), Ask ALRT fallback | ~100-500 hazards/day + Ask ALRT queries | ~$0.001/call | $3-$15/month |
| **Google Geocoding API** | Every new hazard (suburb label), user search | ~100-500/day ingestion + user searches | $5/1,000 calls | $15-$75/month |
| **Google Places API** | User location search (proxied through backend) | Depends on user base | $17-40/1,000 calls | Variable |
| **Google Routes API v2** | Navigation/route planning (client-side) | Per user navigation session | $5-10/1,000 calls | Variable |
| **Firebase Cloud Messaging** | Push notifications for hazards, family events | Per notification | Free (< 500M/month) | $0 |
| **Sightengine** | Media moderation (currently OFF) | 0 (disabled) | $9/month base | $0 (disabled) |
| **WAQI API** | Air quality data, 15-min sync | 96/day | Free tier | $0 |
| **Redis/Valkey (ElastiCache)** | Notification dedup, caching | Always-on | cache.t3.micro | ~$13/month |

---

## Section G — Scheduled Tasks Inventory

| Interval | Task | Service | Status |
|----------|------|---------|--------|
| Every 15 min | Sync hazards from external sources | `ingestion.service.ts` | Active |
| Daily 2 AM | Process scheduled account deletions | `user.service.ts` | Active |
| Every 5 min | Purge expired family locations, end lapsed journeys, prune pings | `family_alert.service.ts`, `family_journey.service.ts` | Active |
| Every 10 min | Award XP for expired community reports | `xp_ledger.service.ts` | Active |
| Every 1 min | Fire due scheduled check-ins | `family.service.ts` | Active |
| Every 1 min | End lapsed SOS events + remind SOS ending soon | `family.service.ts` | Active |

All jobs disabled when `NODE_ENV=test` (unless `RUN_SCHEDULED_JOBS_IN_TEST=true`).

---

## Section H — Migration Status

- **Total migrations:** 115 directories
- **Key new migrations (post-production):** `v1_access_model`, `v1_subscription_changes`, `v1_review_followup`, `trial_record`, `ask_alrt_in_backend`, `sos_ending_soon_marker`, `sos_history_survives_sender_leaving`
- **Rehearsal status:** NOT DONE (R-08). Must be run against a copy of the production database before deployment.
- **Risk:** Schema conflicts, data loss, or downtime if migrations fail on production data.

---

## Summary — Items Requiring Action Before Release

### P0 — Must Fix (8 items, all from baseline audit)

| ID | Item | Category |
|----|------|----------|
| R-01 | Apple OAuth `email_verified` check | Security |
| R-02 | Microsoft OAuth `email_verified` check | Security |
| R-03 | AI failure silently drops hazards | User Safety |
| R-04 | `gpt-5-nano` invalid model in DB seed | Reliability |
| R-05 | `.env` bundled as Flutter asset | Security |
| R-06 | Auth tokens in SharedPreferences (unencrypted) | Security |
| R-07 | RevenueCat webhook 404 | Integration |
| R-08 | Database migration rehearsal | Reliability |

### P1 — Should Fix Before Release (5 items)

| ID | Item | Category |
|----|------|----------|
| P1-01 | Maps proxy returning 404 — investigate route registration | Integration |
| P1-02 | Redis dedup fallback uses unbounded Map (multi-instance risk) | Reliability |
| P1-03 | Ask ALRT migration from Firebase to in-backend — verify Bedrock config | Integration |
| P1-04 | Access/entitlement system end-to-end test with RevenueCat | Integration |
| P1-05 | Family mode end-to-end testing with multiple accounts | Testing |

### P2 — Should Fix Post-Release (6 items)

| ID | Item | Category |
|----|------|----------|
| P2-01 | BoM hazard feed commented out | Coverage |
| P2-02 | Smartraveller feed commented out | Coverage |
| P2-03 | Speed calculation bug (divides by 1.0) | Cosmetic |
| P2-04 | Empty `push_notification_provider.dart` | Dead code |
| P2-05 | Old admin portal consolidation + hazard map migration | Admin |
| P2-06 | Seed initial safety guide content | Content |

---

## Verdict

**This audit identifies 8 P0 items (unchanged from baseline audit), 5 P1 items, and 6 P2 items.** All P0 items must be resolved before the release-candidate can ship. The P0 list is identical to the baseline audit — none have been resolved yet.

The 9-point feature freeze checklist shows:
- **3 of 9 items have code-level issues** (hazard ingestion, categorisation, information accuracy — all tied to R-03/R-04)
- **2 of 9 items need sandbox testing** (proximity notifications, XP calculation)
- **1 item is entirely new and untested** (family mode)
- **3 of 9 items appear code-complete** (map quality, safety tips, hazard reporting)

**Awaiting Sarah's review and approval of fix list before proceeding to Phase 3.**

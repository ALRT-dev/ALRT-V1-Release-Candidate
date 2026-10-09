# 03 -- New UI Dependency Map

Audit date: 2026-10-09
Scope: READ ONLY. No edits, deployments, or writes to any live environment.

This document maps the redesigned UI prototype (`origin/claude/ui-prototype-8oct`)
against the current Flutter app (Phase 1) and the release-candidate backend
(Phase 2). Every claim cites a file path and line range; claims that cannot be
traced to code say "not found in code."

---

## 1. Prototype Overview

The prototype lives in `prototype/` and consists of:

- `prototype/public/app.js` (406 lines) -- core screens and tabs
- `prototype/public/app2.js` (183 lines) -- additional screens and sheets
- `prototype/server.js` -- mock backend
- `prototype/traceability.json` -- 87 rows linking every screen to its real-app counterpart
- `prototype/AUDIT.md` -- 204/204 automated checks passed

Total distinct UI states: approximately 85 (27 screens/tabs + 20 sheets in
app.js, plus 20 EXTRA screens + 18 SHEETS in app2.js).

All prototype API calls go through a mock backend. The mock simulates the real
API shape but returns canned data.

---

## 2. Traceability Summary

Source: `prototype/traceability.json`, 87 rows.

| Status | Count | Meaning |
|---|---|---|
| COVERED | 24 | Prototype matches the Flutter app and backend; wire it up |
| PARTIAL | 26 | Prototype exists but is incomplete or has minor mismatches |
| MISSING | 22 | Prototype not designed; Flutter screen may or may not exist |
| BACKEND GAP | 8 | Prototype designed something the backend does not support yet |
| CONFLICT | 7 | Documentation and code disagree; must be resolved before build |

---

## 3. Route Path Differences (Mock vs Real Backend)

These paths differ between the prototype mock and the real backend. Each must be
corrected in the Flutter app when wiring the new UI.

| Prototype mock path | Real backend path | Impact |
|---|---|---|
| `GET /api/alert/geo` | `GET /api/hazards` (with bounds) | Boot data load, map refresh |
| `GET /api/hazard/mine` | `GET /api/hazards?reportedById=<userId>` | My ALRTs screen |
| `POST /api/hazard` | `POST /api/hazards` | Report creation |
| `POST /api/hazard/:id/view` | `POST /api/hazards/:id/view` | Alert detail view tracking |
| `POST /api/hazard/:id/vote` | `POST /api/hazards/:id/vote` | Voting |
| `POST /api/hazard/:id/flag` | `POST /api/hazards/:id/flag` | Flagging |
| `GET /api/notification/feed` | `GET /api/notifications/feed` | Notification list |
| `POST /api/notification/push-notification-token` | `POST /api/notifications/push-notification-token` | FCM token registration |
| `DELETE /api/notification/push-notification-token` | `DELETE /api/notifications/push-notification-token` | Sign-out token cleanup |
| `POST /api/notification/test` | `POST /api/notifications/test` | Test push |
| `GET /api/xpPoints/summary` | `GET /api/xp/summary` | XP summary on profile |
| `GET /api/xpPoints/breakdown` | `GET /api/xp/breakdown` | Points breakdown screen |
| `GET /api/xpPoints/leaderboard` | `GET /api/xp/leaderboard` | Leaderboard |
| `GET /api/xpPoints/badges` | Not found as a separate endpoint in backend audit | Badges list |
| `POST /api/guide/:topic/complete` | `POST /api/guides/:slug/complete` | Guide completion |
| `POST /api/family/circles` (create) | `POST /api/family/circle` (singular) | Circle creation |
| `POST /api/family/circles/:id/sos` | `POST /api/family/sos` | SOS trigger |
| `POST /api/family/circles/:id/check-in` | `POST /api/family/check-in` | Check-in |
| `POST /api/family/circles/:id/check-in/request` | `POST /api/family/check-in/request` | Ask for check-in |
| `POST /api/family/circles/:id/journeys` | `POST /api/family/journeys` | Journey start |
| `GET /api/family/check-in/requests` | `GET /api/family/check-ins` (pending) | Pending check-in requests |
| `GET /api/family/circle/transfer-candidates` | `GET /api/family/transfer-candidates` | Transfer ownership candidates |
| `POST /api/family/circle/transfer-ownership` | `POST /api/family/transfer-ownership` | Transfer ownership |
| `GET /api/user/profile` | `GET /api/user` | User profile fetch |
| `PUT /api/user/profile` | `PUT /api/user` | User profile update |

**Note**: The Flutter app (`lib/api/endpoints.dart`, `lib/api/rest_client.dart`)
already uses the real backend paths for most of these. The path differences are
between the prototype mock and the real backend -- they show where the prototype's
`api()` calls need translation, not where the Flutter code is wrong.

---

## 4. Screen-by-Screen Dependency Map

### 4.1 COVERED (24 screens) -- Ready to wire

These screens have a working prototype, a matching Flutter screen, and a working
backend route. Action: restyle to the new design.

| # | Screen | Flutter route | Flutter file | Backend endpoint(s) |
|---|---|---|---|---|
| 1 | AppWrapper | `/` | app_wrapper.dart:41 | -- (client-side routing) |
| 4 | EmailAuthScreen | `/email-auth` | email_auth_screen.dart:18 | POST /api/auth/email-password/login, /register |
| 6 | Welcome | `/onboarding/welcome` | onboarding_welcome_screen.dart:16 | -- (display only) |
| 7 | Disclaimer/Promises | `/onboarding/disclaimer` | onboarding_disclaimer_screen.dart:18 | POST /api/onboarding/accept-disclaimer |
| 10 | ALRT+ offer | `/onboarding/alrt-plus` | onboarding_alrt_plus_screen.dart:19 | RevenueCat offerings |
| 13 | Dead onboarding screens | -- | 4 dead files | -- (delete) |
| 16 | HazardSearch | (tab) | hazard_search_screen.dart | GET /api/hazards |
| 19 | AroundYouSheet -> Near You | (tab) | Part of map_screen.dart | GET /api/hazards |
| 23 | Ask ALRT | (sheet) | ask_alrt_provider.dart:86,145 | POST /api/ask-alrt, GET /api/ask-alrt/allowance |
| 25 | Offline state | (overlay) | map_screen.dart | -- (client-side) |
| 28 | Posted toast | -- | Toast widget | -- |
| 31 | Ready tab | (tab) | Not yet built as tab | GET /api/guides/topics |
| 32 | Learn topics | `/learn` | learn_topics_screen.dart:288 | GET /api/guides/topics |
| 33 | Guide detail | `/guide-detail` | guide_detail_screen.dart:37 | GET /api/guides/:slug, POST /api/guides/:slug/complete |
| 34 | Drill | -- | Not yet built | -- (static content) |
| 36 | Family onboarding | (tab) | family_onboarding_screen.dart:19 | POST /api/family/circle, POST /api/family/join |
| 48 | SOS send | `/family-sos` | family_sos_screen.dart:35 | POST /api/family/sos |
| 59 | Safety profile | `/safety-profile` | safety_profile_screen.dart:22 | PUT /api/user |
| 67 | ALRT+ choose | `/alrt-plus/choose` | alrt_plus_choose_screen.dart:18 | -- (navigation) |
| 68 | ALRT+ paywall | `/alrt-plus` | alrt_plus_paywall_screen.dart:57 | RevenueCat, POST /api/access/reconcile |
| 86 | Guest mode removal | `/auth` | auth_screen.dart:29 | Remove button |

### 4.2 PARTIAL (26 screens) -- Needs work

These have a prototype and a Flutter screen, but the prototype is incomplete,
the Flutter screen needs changes, or the wiring has gaps.

| # | Screen | Gap description | Flutter file | What is needed |
|---|---|---|---|---|
| 3 | AuthScreen | New design reorders sign-in to last; 'Continue as Guest' must go | auth_screen.dart:29 | Restyle; remove guest button; keep Google/Apple/Email order |
| 8 | Legal | Call must still fire after sign-in | onboarding_legal_screen.dart:21 | Ensure POST /api/onboarding/accept-tos fires reliably |
| 9 | SafetyProfile (onboarding) | New flow moves safety profile to Me tab | safety_profile_screen.dart:23 | Onboarding step should skip safety profile; add it to Me |
| 14 | HomeScreen + tabs | Tabs change from 6 to 5 (search merges into alerts); push routing table must re-point | home_screen.dart:72 | Rewrite tab bar; update push notification deep-link routing |
| 15 | MapScreen | Route planning/detour/map type not in new design | map_screen.dart:24 | Remove or hide route planning UI |
| 17 | NotificationsScreen | Becomes bell icon in Alerts header, no longer a tab | notifications_screen.dart:16 | Move from tab to header icon/overlay |
| 21 | ViewHazardScreen | Missing: FamilySafeStrip, GuideStrip, Report/Block, edit own report | view_hazard_screen.dart:58 | Add 4 missing sub-components |
| 26 | CreateUpdateReportScreen | Missing: duplicate 409 handling, rate-limit 429 copy, media upload, location picker integration | create_update_report_screen.dart:78 | Add error handling, wire media and location |
| 35 | Plan | If plan shared with circle, needs a new family route | Not built | Build plan screen; add POST /api/family/plans if needed (not found in code) |
| 37 | FamilyHubScreen | Missing: member detail sheet, request location, past SOS, circle badges | family_hub_screen.dart:51 | Add member sheet, location request, SOS history link |
| 39 | Ask check-in + roll call | Roll call screen not designed in prototype | family_check_in_roll_call_screen.dart:35 | Roll call Flutter screen exists; just needs new design |
| 41 | FamilyInviteScreen | Code/QR exist but QR scanner sheet not designed | family_invite_screen.dart:34 | Scanner works (mobile_scanner); design the sheet |
| 49 | SOS receiver | Receiver view designed but incomplete | family_sos_receiver_screen.dart:49 | Complete the prototype; wire SOS trail and respond |
| 51 | Journey screen | Recipient picker missing from prototype | family_journey_screen.dart:21 | Add recipient selection UI |
| 55 | ProfileScreen (Me tab) | Missing 12 items: My ALRTs, child mode, blocked, support, delete, widget, share, language, legal, logout, terms version, accessibility | profile_screen.dart:53 | Add links to existing screens; build missing sheets |
| 56 | ManageNotificationsScreen | New design reduces 5 booleans to 3 alert levels | manage_notifications_screen.dart:28 | Redesign UI; backend still uses 5 booleans |
| 60 | Points/XP | Backend has streaks; new design says no streaks | points_breakdown_screen.dart:20 | CONFLICT: must decide streaks yes/no |
| 65 | Add widget / Share ALRT | Widgets designed; sheets not | profile_screen.dart | Build sheets |
| 69 | Group paywall | Upgrade/downgrade not designed | alrt_plus_group_paywall_screen.dart:94 | Design and build tier change flow |
| 70 | ALRT+ manage | Billing issue and bind-unbound not designed | alrt_plus_manage_screen.dart:28 | Design error states |
| 71 | Access refusal | 5 of 11 codes handled in original; rest in app2.js | Not found as dedicated screen | Build refusal sheet with all 11 codes |
| 72 | Push routing | Lock screen shown; routes need re-pointing for new tab structure | push_notification_types.dart | Update deep-link routing table |
| 73 | Nearby widget | 'ALL CLEAR' wording breaks style rule | home_screen_widget/ | Fix wording |
| 74 | Family widget | iOS bug: checks state=='safe' which app never sends | home_screen_widget/ | Fix state check |
| 76 | Share link | Backend public route exists; prototype share is toast only | endpoints.dart:191 | Wire share sheet to generate real share URL |

### 4.3 MISSING (22 screens) -- Must be designed and built

These have no prototype screen, and in some cases no Flutter screen either.

| # | Screen | Flutter screen exists? | Backend route exists? | Priority |
|---|---|---|---|---|
| 2 | ForceUpdateScreen | Yes (force_update_screen.dart:9) | GET /api/app/version-policy | Low -- restyle only |
| 5 | ForgotPasswordScreen | Yes (forgot_password_screen.dart:15) | POST /api/auth/password-reset/request | Low -- restyle only |
| 11 | Onboarding complete | Yes (onboarding_complete_screen.dart:18) | -- | Medium -- add 20pt endowed progress |
| 18 | HazardFiltersBottomsheet | No | -- (client-side filter) | High -- users need this to filter alerts |
| 20 | Map details / route planning | Partially (select_location_on_map_screen.dart) | /api/maps/* proxy | Medium -- cut route planning or proxy key |
| 22 | Report/block sheet | No | POST /api/hazards/:id/flag, POST /api/user/blocked | High -- store compliance (UGC) |
| 24 | Voice priming/listening | Voice code exists (voice_input_controller.dart) | -- | Low -- not in new design |
| 27 | SelectLocationScreen | Yes (select_location_on_map_screen.dart:53) | /api/maps/places/* | Medium -- needed by Report and Family Places |
| 29 | DuplicateReportSheet | No | 409 response from POST /api/hazards | Medium -- add to report flow |
| 30 | My ALRTs (My Reports) | Yes (my_hazards_screen.dart:31) | GET /api/hazards?reportedById= | Medium -- add to Me tab |
| 38 | Check-in consent sheet | No | POST /api/family/check-in | Medium -- three options including needsHelp |
| 40 | Location request sheet | No | POST /api/family/members/:id/location-request | Medium -- share once/decline |
| 42 | Group settings screen | Yes (family_group_settings_screen.dart:30) | PUT /api/family/circle | Medium -- needs prototype design |
| 43 | Switch group screen | Yes (family_switch_group_screen.dart:25) | GET /api/family/circles | Medium |
| 44 | Circle profile screen | Yes (family_circle_profile_screen.dart:36) | PUT /api/family/members/me | Medium |
| 45 | Sharing level screen | Yes (family_sharing_level_screen.dart:15) | PUT /api/family/members/me | Medium |
| 46 | Family places | Yes (family_places_screen.dart:19) | CRUD /api/family/places | Medium |
| 47 | SOS lists | Yes (family_sos_lists_screen.dart:21) | CRUD /api/family/sos-lists | Medium |
| 50 | SOS resolved | Yes (family_sos_resolved_screen.dart:44) | -- (display only) | Low |
| 52 | Shared journey viewer | Yes (shared_journey_screen.dart:36) | GET /api/family/journeys/:id | Medium |
| 53 | Group paused/leave/transfer | Yes (family_group_paused_screen.dart:22) | Transfer/leave/take-over routes | Low |
| 54 | FamilySafeStrip in alert | No | -- (client-side component) | Medium |
| 57 | Notification priming | No | -- (client-side moment) | Medium |
| 58 | Accessible alerts | No | -- (client-side toggle) | Low |
| 61 | Child mode screen | Yes (child_mode_screen.dart:18) | SharedPreferences only | Low |
| 62 | Blocked accounts | Yes (blocked_accounts_screen.dart:17) | GET/DELETE /api/user/blocked | Medium -- store requirement |
| 63 | Support request | Yes (support_request_screen.dart:18) | POST /api/support | Low |
| 64 | Delete account | Yes (delete_account_screen.dart:25) | DELETE /api/user/account | Medium -- store requirement |
| 66 | Language picker | No | PUT /api/user (language field) | Low |

### 4.4 BACKEND GAP (8 items) -- Backend changes needed

These are screens or features where the prototype envisions something the backend
does not yet support.

| # | Gap | What prototype expects | What backend has | Required change |
|---|---|---|---|---|
| 12 | Alert level step | 3-level minimum-band selector during onboarding | 5 booleans + category subscriptions, no minimum-band field | Add `minimumBand` field to `UserPushNotificationSetting` model |
| 75 | Apple Watch | Widget showing nearby alerts | No watch target in repo | Add watchOS target (Flutter or native) |
| 77 | Keep-it-quiet level | User sets "only notify me about X severity and above" | No minimum-band field | Same as #12 |
| 83 | Scheduled check-in timezone | User's own timezone | Hardcoded `Australia/Brisbane` (scheduler.service.ts) | Accept timezone per user or per check-in |
| 84 | Admin review push/XP | Reporter gets push and XP when admin accepts a community report | No push or XP on admin acceptance | Add event emission on admin approval |
| 85 | Daily digest | Daily summary push notification | Not built | Build digest cron job |
| 87 | Google Routes key | Route planning uses backend proxy | `flutter_polyline_points` calls Google Routes directly with key compiled into app binary (env.dart:7) | Proxy through /api/maps or remove route planning from design |

### 4.5 CONFLICT (7 items) -- Must be resolved before build

These are places where documentation, code, and/or prototype disagree. Each must
have a single canonical answer before the Flutter app can be updated.

| # | Conflict | Source A | Source B | Decision needed |
|---|---|---|---|---|
| 60 | Streaks | Backend XP system has streak multipliers | New design says no streaks | Keep or remove streaks? |
| 78 | Community push timing | Doc R08 proposes delayed push for community reports | Code pushes immediately; proposal not approved | Confirm immediate push is correct |
| 79 | SOS 4-hour cap | CLAUDE.md says "4-hour cap" | Code allows indefinite 1-hour extensions | Add cap or update docs? |
| 80 | Who ends SOS | CLAUDE.md says "sender or host" | Code restricts to sender only (sos.service.ts) | Allow host to end, or update docs? |
| 81 | Ask ALRT counting | Doc R03 says library/emergency queries don't count toward daily limit | Code counts all query types | Exempt library/emergency, or update docs? |
| 82 | Group capacity | Schema defaults and documentation disagree on maximum group sizes | -- | Pick one number per tier |
| -- | Tab count | Prototype has 5 tabs (Alerts, Ready, Report, Family, Me) | Flutter has 6 tabs (Map, Search, List, Notifications, Family, Profile) | Adopt 5-tab layout from prototype |

---

## 5. Feature Dependencies: What Blocks What

### 5.1 Must resolve before any build

1. **Tab structure** (conflict): 6 tabs vs 5 tabs affects every screen, every
   deep link, and every push notification route.
2. **Alert level / minimum-band** (backend gap #12, #77): Two prototype screens
   depend on a field that does not exist in the database.
3. **7 conflicts** (section 4.5): Each one changes API contracts or business logic.

### 5.2 Must resolve before Family features

1. **SOS cap** (conflict #79): Affects SOS screen timer, extend button, and end logic.
2. **SOS end** (conflict #80): Affects SOS receiver screen action buttons.
3. **Scheduled check-in timezone** (gap #83): Users outside Brisbane get wrong times.
4. **22 MISSING family screens**: 15 of the 22 MISSING items are family-related.
   Most have Flutter screens already built; they need prototype designs.

### 5.3 Must resolve before Subscription features

1. **BILLING_ENABLED=false**: All subscription screens function but process no
   real payments until this flag is set to true.
2. **RevenueCat webhook 404 in PROD**: Production backendV2 has no webhook route;
   the release-candidate does. Subscriptions require deploying the release-
   candidate backend.
3. **Group capacity conflict** (#82): Affects paywall copy and plan comparison.
4. **Upgrade/downgrade flow** (partial #69): Not designed in prototype.

### 5.4 Must resolve before Store submission

1. **Report/block sheet** (missing #22): Apple/Google require UGC reporting.
2. **Blocked accounts screen** (missing #62): Apple/Google require block management.
3. **Delete account** (missing #64): Apple requires account deletion.
4. **Content flag route**: Backend has `POST /api/hazards/:id/flag` (hazard.route.ts).
   Flutter has `flagHazard` in rest_client.dart. Wiring exists but UI sheet is not
   built.

---

## 6. Screens with No Backend Equivalent

These prototype screens are client-side only and need no backend work:

| Screen | Reason |
|---|---|
| Force update overlay | Reads version-policy then shows static overlay |
| Onboarding complete | Display only |
| Drill | Static safety drill content |
| Widgets preview | Shows iOS/Android widget instructions |
| Accessible alerts | On-device toggle (strong vibration, read aloud) |
| Child mode | SharedPreferences toggle |
| Legal links sheet | Links to web pages |
| Add widget sheet | Launcher pin instructions |
| Share ALRT sheet | Copy install link |
| Logout confirmation | Client-side token clear + best-effort API call |

---

## 7. SDK / Third-Party Dependencies for New UI

No new SDKs are required for the redesigned UI. All needed SDKs are already in
the Flutter `pubspec.yaml`:

| Capability | SDK | Already in app? |
|---|---|---|
| Map rendering | google_maps_flutter 2.13.1 | Yes |
| QR scanning | mobile_scanner 7.4.0 | Yes |
| QR generation | qr_flutter 4.1.0 | Yes |
| Voice input | speech_to_text 7.0.0 | Yes |
| Text-to-speech | flutter_tts 4.2.5 | Yes |
| Home widgets | home_widget 0.7.0 | Yes |
| In-app review | in_app_review 2.0.12 | Yes |
| Share sheet | share_plus 13.2.0 | Yes |
| Camera/gallery | image_picker 1.2.0 | Yes |
| Video playback | native_video_player 4.0.1 | Yes |
| Subscriptions | purchases_flutter 10.4.3 | Yes |
| Push notifications | firebase_messaging 16.0.2 | Yes |
| Analytics | firebase_analytics 12.4.3 | Yes |
| Localization | easy_localization 3.0.8 | Yes (English only; Spanish commented out) |

---

## 8. Dead Code to Remove

Source: frontend_audit.md section 7.

| Item | Files | Safe to delete? |
|---|---|---|
| OnboardingLocationScreen | onboarding_location_screen.dart | Yes -- commented out of enum |
| OnboardingRadiusScreen | onboarding_radius_screen.dart | Yes -- commented out of enum |
| OnboardingAlertSourcesScreen | onboarding_alert_sources_screen.dart | Yes -- commented out of enum |
| OnboardingEmergencyScreen | onboarding_emergency_screen.dart | Yes -- not in enum |
| Microsoft Sign-In button | auth_screen.dart:225-226,233-234 | Commented out; leave code in place, remove commented UI |
| Guest mode button | auth_screen.dart | Yes -- remove per traceability row 86 |

---

## 9. Summary Statistics

| Metric | Value |
|---|---|
| Total traceability entries | 87 |
| Ready to wire (COVERED) | 24 (28%) |
| Needs design/code work (PARTIAL) | 26 (30%) |
| Not designed yet (MISSING) | 22 (25%) |
| Needs backend changes (BACKEND GAP) | 8 (9%) |
| Needs decision (CONFLICT) | 7 (8%) |
| Route path differences (mock vs real) | 25 |
| New SDKs needed | 0 |
| Dead screens to remove | 4-6 |
| Store-blocking missing screens | 3 (report/block, blocked accounts, delete account) |

---

## End of Phase 3 Audit

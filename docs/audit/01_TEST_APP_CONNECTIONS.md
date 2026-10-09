# 01 - TEST App Connection Inventory

Audit date: 2026-10-09
Scope: Release-candidate monorepo, branch `claude/compassionate-franklin-512so7` (commit 2895f82)
Method: Read-only static analysis of frontend/, backend/, admin/, prototype/

---

## 1. Architecture Overview

The ALRT test app is a Flutter mobile client that talks to a single Express/Node backend over HTTPS. The backend manages all external service credentials server-side. The frontend holds only client-side SDK keys (Google Maps, RevenueCat, Firebase project config for FCM).

| Layer | Tech | Base URL |
|---|---|---|
| Mobile app (Flutter/Dart) | Dio + Retrofit, GoRouter, Riverpod | prod: `https://api.safetyalrt.com` (endpoints.dart:1), dev: `http://192.168.1.67:9000` (endpoints.dart:3) |
| Backend (Node/Express/TypeScript) | Prisma ORM, PostgreSQL + PostGIS | Listens on PORT (default 3000, config.ts:39) |
| Admin portal (React/Vite) | Plain fetch, react-router-dom | prod: `https://api.safetyalrt.com` (.env.production:6), test: `https://api-test.safetyalrt.com` (.env.test:11) |

---

## 2. Screen-to-Endpoint Wiring (Every Screen)

### 2.1 Auth Flow

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| AuthScreen | `/auth` | `POST /api/auth/oauth/google`, `POST /api/auth/oauth/apple` | auth_screen.dart:29, rest_client.dart:32-46 |
| AuthScreen (Microsoft) | `/auth` | `POST /api/auth/oauth/microsoft` | auth_screen.dart:225-226 (COMMENTED OUT) |
| EmailAuthScreen | `/email-auth` | `POST /api/auth/email-password/login` or `/register` | email_auth_screen.dart:18 |
| ForgotPasswordScreen | `/forgot-password` | `POST /api/auth/password-reset/request` | forgot_password_screen.dart:15 |

Auth gating: AppWrapper._checkAuthState() at app_wrapper.dart:133-166.
JWT tokens stored in SharedPreferences (auth_interceptor.dart:129,204). Bearer token in Authorization header (auth_interceptor.dart:115). Refresh via `POST /api/auth/refresh-token` with coalescing (auth_interceptor.dart:161-169). 401 retry once, then session expiry (auth_interceptor.dart:42-55).

### 2.2 Onboarding Flow

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| OnboardingWelcomeScreen | `/onboarding/welcome` | None (display only) | onboarding_welcome_screen.dart:16 |
| OnboardingDisclaimerScreen | `/onboarding/disclaimer` | `POST /api/onboarding/accept-disclaimer` | onboarding_disclaimer_screen.dart:18 |
| OnboardingLegalScreen | `/onboarding/legal` | `POST /api/onboarding/accept-tos` | onboarding_legal_screen.dart:21 |
| SafetyProfileScreen (onboarding) | `/onboarding/safety-profile` | `PUT /api/user` | safety_profile_screen.dart:23 |
| OnboardingAlrtPlusScreen | `/onboarding/alrt-plus` | RevenueCat SDK offerings (client-side) | onboarding_alrt_plus_screen.dart:19 |
| OnboardingCompleteScreen | `/onboarding/complete` | None (navigates to /home) | onboarding_complete_screen.dart:18 |

Note: No location permission or location use during onboarding. The four dead onboarding screens (Location, Radius, Alert Sources, Emergency) are commented out of OnboardingStep enum at onboarding_step_types.dart:16-18 and not registered in app_router.dart.

### 2.3 Home Tabs

| Tab | Screen | Endpoints Called | File Reference |
|---|---|---|---|
| Map | MapScreen | `GET /api/hazards` (with search/bounds), `GET /api/hazard-categories/*`, `POST /api/ask-alrt`, `GET /api/ask-alrt/allowance` | map_screen.dart:24 |
| Search | HazardSearchScreen | `GET /api/hazards` | hazard_search_screen.dart |
| Notifications | NotificationsScreen | `GET /api/notifications/feed` | notifications_screen.dart:16 |
| Family | FamilyTabView | See Section 2.5 | family_tab_view.dart:12 |
| Profile | ProfileScreen | `GET /api/user`, `GET /api/xp/summary`, `GET /api/access` | profile_screen.dart:53 |

Home tabs enum: map, search, list, notifications, family, profile (home_tab_types.dart:4-10). Child mode hides the `list` tab (home_tabbar.dart:56-58).

### 2.4 Alert / Hazard Screens

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| ViewHazardScreen | `/view-hazard` | `POST /api/hazards/{id}/view`, `POST /api/hazards/{id}/vote`, `POST /api/hazards/{id}/flag`, `GET /api/guides/for-category/{categoryId}` | view_hazard_screen.dart:58 |
| CreateUpdateReportScreen (create) | `/report/create` | `POST /api/hazards` (multipart), `GET /api/hazard-categories/*` | create_update_report_screen.dart:78 |
| CreateUpdateReportScreen (update) | `/report/update` | `PUT /api/hazards/{id}` (multipart) | create_update_report_screen.dart:79 |
| MyHazardsScreen | `/my-hazards` | `GET /api/hazards` (filtered), `DELETE /api/hazards/{id}` | my_hazards_screen.dart:31 |
| SelectLocationScreen | (programmatic) | `GET /api/maps/places/autocomplete`, `GET /api/maps/places/details` | app_router.dart:126-131 |
| SelectLocationOnMapScreen | `/select-location-on-map` | Google Maps SDK (client-side only) | select_location_on_map_screen.dart:53 |

Community reports are anonymous and carry no severity. Reports are child-mode gated: `/report/create` redirects to `/home` when child mode is active (app_router.dart:329).

### 2.5 Family Feature Screens

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| FamilyOnboardingScreen | (embedded in FamilyTabView) | `POST /api/family/circle`, `POST /api/family/join` | family_onboarding_screen.dart:19 |
| FamilyHubScreen | (embedded in FamilyTabView) | `GET /api/family/circle`, `GET /api/family/circles`, `POST /api/family/location`, `POST /api/family/check-in`, `POST /api/family/check-in/request`, `GET /api/family/sos/active`, `GET /api/family/check-ins` | family_hub_screen.dart:51 |
| FamilyInviteScreen | `/family-invite` | `POST /api/family/invites`, `GET /api/family/invites`, `POST /api/family/invites/{id}/revoke` | family_invite_screen.dart:34 |
| FamilyGroupSettingsScreen | `/family-group-settings` | `PUT /api/family/circle`, `DELETE /api/family/circle`, `PUT /api/family/circle/photo`, `DELETE /api/family/circle/photo`, `GET /api/family/circle/transfer-candidates`, `POST /api/family/circle/transfer-ownership` | family_group_settings_screen.dart:30 |
| FamilySwitchGroupScreen | `/family-switch-group` | `GET /api/family/circles` | family_switch_group_screen.dart:25 |
| FamilySosListsScreen | `/family-sos-lists` | `GET /api/family/sos-lists`, `DELETE /api/family/sos-lists/{id}` | family_sos_lists_screen.dart:21 |
| FamilySosListEditScreen | `/family-sos-list-edit` | `POST /api/family/sos-lists`, `PUT /api/family/sos-lists/{id}` | family_sos_list_edit_screen.dart:29 |
| FamilySosScreen | `/family-sos` | `POST /api/family/sos`, `GET /api/family/sos/preview`, `GET /api/family/sos-recipients` | family_sos_screen.dart:35 |
| FamilySosReceiverScreen | `/family-sos-receiver` | `POST /api/family/sos/{id}/respond`, `GET /api/family/sos/{id}/trail` | family_sos_receiver_screen.dart:49 |
| FamilySosResolvedScreen | `/family-sos-resolved` | None (receives data via args) | family_sos_resolved_screen.dart:44 |
| FamilyCheckInRollCallScreen | `/family-check-in-roll-call` | `GET /api/family/check-ins` | family_check_in_roll_call_screen.dart:35 |
| FamilyJourneyScreen | `/family-journey` | `POST /api/family/journeys`, `GET /api/family/journeys/me`, `POST /api/family/journeys/{id}/stop`, `POST /api/family/journeys/{id}/extend`, `POST /api/family/journeys/{id}/point` | family_journey_screen.dart:21 |
| SharedJourneyScreen | `/shared-journey` | `GET /api/family/journeys/{id}`, `GET /api/family/journeys/shared` | shared_journey_screen.dart:36 |
| FamilyPlacesScreen | `/family-places` | `GET /api/family/places` | family_places_screen.dart:19 |
| FamilyPlaceEditScreen | `/family-place-edit` | `POST /api/family/places`, `PUT /api/family/places/{id}`, `DELETE /api/family/places/{id}`, `PUT /api/family/places/{id}/prefs` | family_place_edit_screen.dart:26 |
| FamilySharingLevelScreen | `/family-sharing` | `PUT /api/family/members/me` | family_sharing_level_screen.dart:15 |
| FamilyCircleProfileScreen | `/family-circle-profile` | `PUT /api/family/members/me`, `PUT /api/family/members/me/photo` | family_circle_profile_screen.dart:36 |
| FamilyGroupPausedScreen | `/family-group-paused` | None (display only) | family_group_paused_screen.dart:22 |
| FamilyShareEndingScreen | `/family-share-ending` | None (countdown timer) | family_share_ending_screen.dart:41 |

### 2.6 Profile / Settings Screens

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| SafetyProfileScreen | `/safety-profile` | `PUT /api/user` | safety_profile_screen.dart:22 |
| ManageNotificationsScreen | `/manage-notifications` | `GET /api/user/push-notification-settings`, `PUT /api/user/push-notification-settings`, `POST /api/notifications/test` | manage_notifications_screen.dart:28 |
| SupportRequestScreen | `/support-request` | `POST /api/support` | support_request_screen.dart:18 |
| DeleteAccountScreen | `/delete-account` | `DELETE /api/user/account` | delete_account_screen.dart:25 |
| DeletedAccountInfoScreen | `/deleted-account-info` | `POST /api/user/account/cancel-deletion` | deleted_account_info_screen.dart:18 |
| BlockedAccountsScreen | `/blocked-accounts` | `GET /api/user/blocked`, `DELETE /api/user/blocked/{userId}` | blocked_accounts_screen.dart:17 |
| ChildModeScreen | `/child-mode` | None (SharedPreferences only) | child_mode_screen.dart:18 |
| HowPointsWorkScreen | `/how-points-work` | None (static) | how_points_work_screen.dart:15 |
| LeaderboardScreen | `/leaderboard` | `GET /api/xp/leaderboard` | leaderboard_screen.dart:14 |
| PointsBreakdownScreen | `/points-breakdown` | `GET /api/xp/breakdown` | points_breakdown_screen.dart:20 |

### 2.7 Subscription / ALRT+ Screens

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| AlrtPlusChooseScreen | `/alrt-plus/choose` | None (navigation only) | alrt_plus_choose_screen.dart:18 |
| AlrtPlusPaywallScreen | `/alrt-plus` | RevenueCat offerings, `POST /api/access/reconcile` | alrt_plus_paywall_screen.dart:57 |
| AlrtPlusGroupPaywallScreen | `/alrt-plus/groups` | RevenueCat offerings, `POST /api/access/sponsorship-intents`, `POST /api/access/reconcile`, `POST /api/access/sponsorships/{id}/bind` | alrt_plus_group_paywall_screen.dart:94 |
| AlrtPlusManageScreen | `/alrt-plus/manage` | `GET /api/access`, RevenueCat customer info, `POST /api/access/groups/{id}/individual-funding` | alrt_plus_manage_screen.dart:28 |

### 2.8 Learn / Guide Screens

| Screen | Route | Endpoints Called | File Reference |
|---|---|---|---|
| LearnTopicsScreen | `/learn` | `GET /api/guides/topics`, `GET /api/xp/summary` | learn_topics_screen.dart:288 |
| GuideDetailScreen | `/guide-detail` | `GET /api/guides/{slugOrId}`, `POST /api/guides/{slugOrId}/complete` | guide_detail_screen.dart:37 |

### 2.9 System / Overlay Screens

| Screen | Trigger | Endpoints Called | File Reference |
|---|---|---|---|
| SplashScreen | `/splash` | None | splash_screen.dart:10 |
| ForceUpdateScreen | Overlay when version below minimum | `GET /api/app/version-policy` (via provider) | force_update_screen.dart:9, app.dart:100-101 |
| _UnreachableScreen | Backend unreachable at startup | None (retry loop) | app_wrapper.dart:196 |

---

## 3. External Service Dependencies

### 3.1 Services the Frontend Talks to Directly (Client-side SDKs)

| Service | SDK | Config Source | Purpose | File Reference |
|---|---|---|---|---|
| Firebase (FCM only) | firebase_messaging 16.0.2 | firebase_options.dart (project alrt-a6539) | Push notification token registration | app_bootstrap.dart:131-135 |
| Firebase Analytics | firebase_analytics 12.4.3 | Same project | 10 event types (fire-and-forget) | analytics_service.dart:11-23 |
| Google Maps | google_maps_flutter 2.13.1 | .env GOOGLE_MAPS_API_KEY | Map rendering, marker clustering | env.dart:7 |
| Google Routes | flutter_polyline_points 3.1.0 | .env GOOGLE_MAPS_API_KEY | Route/direction polylines (client key directly) | env.dart:7 |
| Google Sign-In | google_sign_in 7.2.0 | .env GOOGLE_OAUTH_SERVER_CLIENT_ID | OAuth, sends idToken to backend | env.dart:4, auth_screen.dart:230 |
| Apple Sign-In | sign_in_with_apple 7.0.1 | iOS only | OAuth, sends identityToken to backend | auth_screen.dart:223 |
| RevenueCat | purchases_flutter 10.4.3 | .env REVENUECAT_API_KEY_APPLE, REVENUECAT_API_KEY_GOOGLE | Subscription offerings, purchase flow | revenuecat_service.dart:58-80, env.dart:30-34 |
| Socket.IO | socket_io_client 3.1.2 | Same base URL as REST API | Real-time hazard/XP/badge events (6 event types) | socket_service.dart:94-110 |

Firebase is used for push notifications (FCM) and analytics ONLY. ALRT does NOT use Firebase Auth, Firestore, App Check, Cloud Functions, or Remote Config. The Firebase Admin SDK on the backend (firebase_admin_client.util.ts:1-32) is used exclusively for FCM sendEachForMulticast.

### 3.2 Services the Backend Talks to (Server-side)

| Service | Purpose | Env Vars | File Reference |
|---|---|---|---|
| PostgreSQL + PostGIS | Primary database (54 Prisma models) | DATABASE_URL | config.ts:91, schema.prisma (1640 lines) |
| Firebase Admin / FCM | Push notifications (500-token chunking) | FIREBASE_PROJECT_ID, GOOGLE_APPLICATION_CREDENTIALS | firebase_admin_client.util.ts:1-32, notification.service.ts (592 lines) |
| AWS Bedrock (Claude Haiku 4.5) | Default AI provider for Ask ALRT and alert summaries | AWS_BEDROCK_REGION, AWS_BEDROCK_ACCESS_KEY_ID (optional) | bedrock.service.ts:1-243, ai.service.ts:1-126 |
| OpenAI | Fallback AI provider (when AI_PROVIDER=openai) | OPENAI_API_KEY | open-ai.service.ts:1-145 |
| AWS S3 | Media storage (hazards, profiles, circles, categories) | AWS_S3_REGION, AWS_S3_BUCKET_NAME | s3.service.ts:1-393 |
| AWS CloudFront | CDN for S3 media (optional) | AWS_CLOUDFRONT_DOMAIN | s3.service.ts:44-47 |
| Google Maps API | Server-side geocoding + places proxy | GOOGLE_MAPS_API_KEY | google_map.service.ts:1-72, maps_proxy.service.ts:1-71 |
| Sightengine | Photo/video content moderation | SIGHTENGINE_API_USER, SIGHTENGINE_API_SECRET, SIGHTENGINE_WORKFLOW_ID | image_video_detection.service.ts:1-404 |
| RevenueCat | Subscription webhook + server reconciliation | REVENUECAT_WEBHOOK_AUTH, REVENUECAT_SECRET_API_KEY (optional) | entitlement.service.ts:1-1426 |
| SMTP | Password reset emails, support tickets | SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, EMAIL_FROM_ADDRESS | support.service.ts:1-87 |
| ElastiCache / Valkey | Notification cooldown, Ask ALRT caching | CACHE_URL, CACHE_TLS | cache_client.util.ts (non-blocking, app works without) |
| n8n webhook | ALRT Global Intel Advisory ingestion | WEBHOOK_API_KEY | webhook.route.ts:1-39 |
| 16 hazard ingestion feeds | External alert data (NSW RFS, USGS, WAQI, etc.) | NSW_TRANSPORT_API_KEY, WAQI_API_TOKEN, QLD_TRAFFIC_API_KEY | ingestion.service.ts (1148 lines) |

### 3.3 Services NOT Used (Confirmed Absent)

| Service | Status | Evidence |
|---|---|---|
| Firebase Auth | Not used. App uses its own JWT auth. | Not in pubspec.yaml, not imported anywhere in frontend |
| Firestore | Not used. Retired comment at index.ts:135-137. | Not in pubspec.yaml |
| Firebase App Check | Not used. | Not in pubspec.yaml |
| Firebase Cloud Functions | Not used. Ask ALRT moved to backend (migration 20261006000000). | Comment at index.ts:135-137 |
| Firebase Remote Config | Not used. | Not in pubspec.yaml |

---

## 4. Environment Variable Inventory

### 4.1 Frontend .env Keys (10 keys)

| Key | Purpose | File Reference |
|---|---|---|
| GOOGLE_OAUTH_SERVER_CLIENT_ID | Google Sign-In server client ID | env.dart:4 |
| GOOGLE_MAPS_API_KEY | Maps SDK + Routes API key | env.dart:7 |
| GOOGLE_MAPS_ANDROID_PACKAGE_NAME | Android key restriction | env.dart:15 |
| GOOGLE_MAPS_ANDROID_CERT_SHA1 | Android key restriction | env.dart:18 |
| GOOGLE_MAPS_IOS_BUNDLE_ID | iOS key restriction | env.dart:21 |
| MICROSOFT_CLIENT_ID | MSAL client ID (UI commented out) | env.dart:24 |
| MICROSOFT_TENANT_ID | MSAL tenant ID (UI commented out) | env.dart:25 |
| REVENUECAT_API_KEY_APPLE | RevenueCat iOS key | env.dart:30 |
| REVENUECAT_API_KEY_GOOGLE | RevenueCat Android key | env.dart:33 |
| DEV_BASE_URL | Override dev API URL | base_url_provider.dart:13 |

### 4.2 Backend Environment Variables (33 required + 40+ optional)

See full inventory in backend audit. Key required vars:
DATABASE_URL, JWT secrets (4), admin JWT secrets (4), Google OAuth client IDs (3), APPLE_OAUTH_AUDIENCE, OPENAI_API_KEY, AWS_S3_REGION, AWS_S3_BUCKET_NAME, AWS_BEDROCK_REGION, NSW_TRANSPORT_API_KEY, WAQI_API_TOKEN, GOOGLE_MAPS_API_KEY, SIGHTENGINE credentials (3), SMTP credentials (5).

### 4.3 Admin Portal Environment Variables

| Key | Purpose | File Reference |
|---|---|---|
| VITE_API_BASE_URL | Backend API URL | .env.example:5, .env.production:6, .env.test:11 |
| VITE_USE_RELAY | Enable Cloudflare Pages relay | .env.production:19 |
| VITE_ENABLE_DUMMY_ALERTS | Dev-only dummy alerts | .env.production:9 (empty = disabled) |
| VITE_ENABLE_REAL_SOURCE_SYNC | Dev-only source sync | .env.production:10 (empty = disabled) |
| API_ORIGIN | Pages Function: backend origin | functions/api/[[path]].ts:27-34 |

---

## 5. Feature Flags and Conditional UI

| Flag | Type | Default | Effect | File Reference |
|---|---|---|---|---|
| ALRT_EMAIL_AUTH | Compile-time (--dart-define) | false | Shows/hides email sign-in button | auth_screen.dart:216,238 |
| Child Mode | Runtime (SharedPreferences) | off | Hides list tab, blocks /report/create | child_mode_provider.dart:95, home_tabbar.dart:56-58, app_router.dart:329 |
| Microsoft Sign-In | Code present, UI commented out | hidden | Button not shown; backend 501s if env not set | auth_screen.dart:225-226, microsoft_oauth_client.util.ts:79 |
| BILLING_ENABLED | Runtime env var | "false" | Master toggle for subscription system | entitlement.service.ts:35 |
| RUN_SCHEDULED_JOBS_IN_TEST | Runtime env var | "false" | Allows cron jobs in test environment | scheduled_jobs.util.ts:16-23 |
| COMMUNITY_REPORT_MEDIA_ENABLED | Runtime env var | "false" | Allows photo/video on community reports | config.ts:75-76 |
| Dark mode | Dormant | not active | Code exists but not active | not found in code as active |
| Spanish localization | Dormant | English only | easy_localization configured, Spanish commented out | app_bootstrap.dart:47-49 |

---

## 6. Dead / Unreachable Code in Test App

| Item | Status | File Reference |
|---|---|---|
| OnboardingLocationScreen | DEAD: commented out of enum, not in router | onboarding_location_screen.dart:25, onboarding_step_types.dart:16 |
| OnboardingRadiusScreen | DEAD: commented out of enum | onboarding_radius_screen.dart:31, onboarding_step_types.dart:17 |
| OnboardingAlertSourcesScreen | DEAD: commented out of enum | onboarding_alert_sources_screen.dart:37, onboarding_step_types.dart:18 |
| OnboardingEmergencyScreen | DEAD: not in enum, not in router | onboarding_emergency_screen.dart:17 |
| Microsoft Sign-In button | COMMENTED OUT in UI (code + SDK remain) | auth_screen.dart:225-226,233-234 |
| Guest mode | Not in code (prototype references removing it) | not found in code |
| 4 unused Sightengine functions | Private, unreachable URL/file input variants | image_video_detection.service.ts:168,253,294,373 |
| sosToWholeGroup column | Retired, explicitly discarded | family.service.ts:786-787 |
| hasActiveSubscription alias | Deprecated, alias for hasIndividualAccess | entitlement.service.ts:221 |
| BOM ingestion source | Commented out | ingestion.service.ts:65,161-163 |
| Smartraveller ingestion source | Commented out | ingestion.service.ts:74,315-320 |

---

## 7. Credential Safety Check

No credentials found committed in the repository:
- Backend secrets loaded via AWS Secrets Manager Agent (config.ts:11, `loadSecretsFromAgent()`)
- Frontend keys loaded from .env file (not committed; .env.example exists)
- Firebase service account key expected at repo root as `serviceAccountKey.json` (firebase_admin_client.util.ts:3) but file is not committed
- Admin portal: README explicitly states "no secrets" (README.md:7-8)
- .gitignore confirmed to exclude .env and credential files

---

## 8. Socket.IO Real-time Events

| Event | Direction | Trigger | File Reference |
|---|---|---|---|
| newHazard | Server -> Client | New hazard created (ingestion or community) | socket_event_types.dart:1-9, socket.service.ts:38-106 |
| updateHazard | Server -> Client | Hazard updated | socket_event_types.dart |
| deleteHazard | Server -> Client | Hazard deleted/expired | socket_event_types.dart |
| updateUserXp | Server -> Client | XP awarded | socket_event_types.dart |
| badgeEarned | Server -> Client | New badge earned | socket_event_types.dart |
| updateUserUpvotesReceivedCount | Server -> Client | Report upvoted | socket_event_types.dart |

Connection: WebSocket first, polling fallback (socket_service.dart:100). Auth via JWT (socket_service.dart:106-110). User rooms: "user_" + userId (socket_client.util.ts:19).

---

## 9. Scheduled Backend Jobs

| Schedule | Purpose | File Reference |
|---|---|---|
| Every 15 min | Sync hazards from 16 external sources | scheduler.service.ts:21-31 |
| Daily 2 AM | Process scheduled account deletions | scheduler.service.ts:34-44 |
| Every 5 min | Purge expired family data, end lapsed journeys | scheduler.service.ts:48-63 |
| Every 10 min | Award XP for expired community reports | scheduler.service.ts:66-72 |
| Every 1 min | Fire due scheduled check-ins | scheduler.service.ts:75-81 |
| Every 1 min | End lapsed SOS events, remind SOS ending soon | scheduler.service.ts:89-100 |

Gate: prod always runs; test only when RUN_SCHEDULED_JOBS_IN_TEST=true; dev never runs (scheduled_jobs.util.ts:16-23).

---

## 10. Summary Statistics

- **Frontend routes**: 50 GoRouter routes + 5 tab screens + 2 sub-screens + 2 overlays = 59 distinct screen states
- **Frontend API endpoints called**: ~90+ REST endpoints across 12 domain groups
- **Backend API routes**: ~120+ endpoints across 19 user-facing + 11 admin sub-routers
- **External services**: 12 distinct server-side integrations + 8 client-side SDKs
- **Prisma models**: 54 (schema.prisma, 1640 lines)
- **Environment variables**: 33 required backend + 40+ optional backend + 10 frontend + 5 admin
- **Dead screens**: 4 (all onboarding-related)
- **Feature flags**: 8 identified (2 compile-time, 6 runtime)
- **Scheduled jobs**: 6 cron schedules
- **Packages**: 60+ production Flutter packages, 6 dev packages

# iOS TEST build (com.safetyalrt.alrt.dev) - what is separate, and what you must create

The iOS TEST build is the `dev` flavour, bundle id `com.safetyalrt.alrt.dev`,
built by the root workflow `.github/workflows/ios-test-testflight.yml` and
uploaded only to the separate App Store Connect app **"ALRT Dev"**. This file
lists exactly which values live where, which ones do not exist yet, and the
Apple / Firebase / Google console steps that create them. Nothing here is
done by code; every item is a console action by a person with the right
role.

## What the repo already keeps separate (no console action needed)

| Concern | Production (`prod` flavour) | TEST (`dev` flavour) | Where |
|---|---|---|---|
| Bundle id | `com.safetyalrt.alrt` | `com.safetyalrt.alrt.dev` | `Runner.xcodeproj` build configurations |
| Display name | ALRT | [Dev] ALRT | `APP_DISPLAY_NAME` per configuration |
| Info.plist | `Runner/Info.plist` (has production Google Sign-In client id + URL scheme) | `Runner/Info-dev.plist` (no Google Sign-In values at all) | `INFOPLIST_FILE` per configuration |
| Entitlements / App Group | `Runner/Runner.entitlements`, `group.com.safetyalrt.alrt` | `Runner/Runner-dev.entitlements`, `group.com.safetyalrt.alrt.dev` | `CODE_SIGN_ENTITLEMENTS` per configuration; widget: `AlrtWidget-dev.entitlements`, `AlrtWidgetConfig.appGroup`; Dart: `HomeWidgetKeys.appGroupId` |
| Backend | `https://api.safetyalrt.com` | `https://api-test.safetyalrt.com` (hardcoded in the workflow) | `.env` `DEV_BASE_URL` |
| Billing | RevenueCat Apple key from secrets | `ALRT_PLUS_TEST_UNLOCK=true`, both RevenueCat keys blank, RevenueCat never initialised | workflow `.env` |
| Google Sign-In (Dart) | `GOOGLE_OAUTH_SERVER_CLIENT_ID` from secrets | blank | workflow `.env` |
| Google Maps | `GOOGLE_MAPS_API_KEY` from the production secret (Dart + `Maps.xcconfig`) | `TEST_GOOGLE_MAPS_API_KEY_IOS` repository Secret (does not exist yet, see §2); blank = Maps disabled, never the production key | workflow `.env` + `ios/Flutter/Maps.xcconfig` |
| Signing | `ci_certs` lane, profile `match AppStore com.safetyalrt.alrt`, `ExportOptionsCI.plist` | `ci_certs_dev` lane, profile `match AppStore com.safetyalrt.alrt.dev`, `ExportOptionsCI-dev.plist` | `ios/fastlane/Fastfile` |
| TestFlight upload | `ci_upload` lane (Appfile default app, the live ALRT) | `ci_upload_dev` lane: `app_identifier` pinned to `com.safetyalrt.alrt.dev` and refuses any other ipa | `ios/fastlane/Fastfile` |
| Export/upload secrets | `APP_STORE_CONNECT_*`, `MATCH_*` (shared team credentials) | same six secrets, nothing else | GitHub `test` Environment / repository |

Both flavours still bundle `Runner/GoogleService-Info.plist` (the production
Firebase iOS app file). Firebase is initialised from Dart options, not from
that file, so the value that matters is `lib/firebase_options_dev.dart` - see
§1.

## 1. Firebase: iOS app for the TEST bundle (NOT created yet)

Today `lib/firebase_options_dev.dart`'s `ios` block still holds the
production iOS app's values (`appId 1:705221000399:ios:42910fba9ef33a48858bba`,
`iosBundleId com.safetyalrt.alrt`), inherited from before the flavour split.
Until this is fixed the iOS TEST build cannot receive APNs push (its bundle id
has no APNs registration under that Firebase app) and its analytics and
Crashlytics land on the live app. No placeholder was inserted because Firebase
assigns these values at registration.

Console steps (Firebase Console, project `alrt-a6539`, Owner or Editor):

1. Project settings → Your apps → Add app → iOS.
2. Apple bundle ID: `com.safetyalrt.alrt.dev`. App nickname: `ALRT Dev (iOS)`.
   App Store ID: leave blank.
3. Download the generated `GoogleService-Info.plist` and rename it
   `GoogleService-Info-dev.plist` (keep it out of git until a per-flavour copy
   step exists; the Dart values below are what the app actually uses).
4. Cloud Messaging tab → Apple app configuration for the new app → upload the
   team's APNs authentication key (.p8) with its Key ID and Team ID
   `JR89M7CYPR`. The same .p8 may be attached to both iOS apps.
5. Copy these values from the new app into `lib/firebase_options_dev.dart`
   `ios` block, replacing the production ones:

   | Field | Value |
   |---|---|
   | `apiKey` | the new app's `API_KEY` |
   | `appId` | the new app's `GOOGLE_APP_ID` (form `1:705221000399:ios:<new>`) |
   | `messagingSenderId` | `705221000399` (unchanged, project-level) |
   | `projectId` | `alrt-a6539` (unchanged) |
   | `storageBucket` | `alrt-a6539.firebasestorage.app` (unchanged) |
   | `iosBundleId` | `com.safetyalrt.alrt.dev` |

   Then remove the KNOWN GAP comment above that block.

## 2. Google Maps: iOS TEST key (NOT created yet)

Google Cloud Console, the project that owns the existing Maps keys:

1. APIs & Services → Credentials → Create credentials → API key. Name it
   `ALRT TEST iOS Maps`.
2. Application restrictions: **iOS apps** → add bundle identifier
   `com.safetyalrt.alrt.dev` only.
3. API restrictions: **Maps SDK for iOS** only (add Routes API only if the
   TEST build must compute routes; Geocoding/Places go through the backend
   proxy and need no client key).
4. GitHub → repository Settings → Secrets and variables → Actions → Secrets →
   New repository secret `TEST_GOOGLE_MAPS_API_KEY_IOS` with that key.

The workflow already reads that Secret into both the Dart `.env` and
`ios/Flutter/Maps.xcconfig`. While it is absent, Maps is disabled on the TEST
build; it never falls back to the production key.

## 3. Apple Developer Portal (developer.apple.com, Account Holder or Admin)

1. Certificates, Identifiers & Profiles → Identifiers → App Groups →
   register `group.com.safetyalrt.alrt.dev` (description `ALRT Dev widget
   group`). Do not touch `group.com.safetyalrt.alrt`.
2. Identifiers → App IDs → confirm `com.safetyalrt.alrt.dev` exists (explicit,
   not wildcard). Enable exactly these capabilities to match
   `Runner-dev.entitlements`: **Push Notifications**, **App Groups** (assign
   `group.com.safetyalrt.alrt.dev`), **Sign in with Apple**. Do not enable
   anything not in the entitlements file.
3. Certificates: **no new distribution certificate**. `fastlane match`
   reuses the team's existing Apple Distribution certificate from the match
   git repo.
4. Profiles: **one new App Store provisioning profile is required** for
   `com.safetyalrt.alrt.dev`. Do not create it by hand: the first workflow
   run with `generate_certs: true` makes match create it as
   `match AppStore com.safetyalrt.alrt.dev` and commit it to the match repo
   (additive; the production profile is untouched). Every later run uses
   `generate_certs: false` (read-only). If step 1 or 2 changes capabilities
   after the profile exists, run once more with `generate_certs: true`.

## 4. App Store Connect (appstoreconnect.apple.com, Admin or App Manager)

1. Apps → confirm **ALRT Dev** exists with bundle ID
   `com.safetyalrt.alrt.dev` under team `JR89M7CYPR`. If not: + → New App →
   iOS, name `ALRT Dev`, primary language, that bundle ID, SKU `alrt-dev`.
2. ALRT Dev → TestFlight → Internal Testing → create a group (e.g. `ALRT
   internal`) and add at least one tester by their App Store Connect user.
3. Users and Access → Integrations → App Store Connect API → the key whose
   ID is stored as `APP_STORE_CONNECT_API_KEY_ID` must have role **Admin**
   or **App Manager**. If it is scoped to selected apps, add ALRT Dev.
4. Sandbox test accounts are **not** needed for this build (billing is
   bypassed).

## 5. GitHub

1. The root workflow must be registered by GitHub before it can be
   dispatched (it appears under Actions → "iOS Dev TestFlight"). A commit
   touching the file on `test` triggers registration.
2. Confirm the `test` Environment exists and the six shared secrets resolve
   for it: `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
   `APP_STORE_CONNECT_API_KEY_CONTENT`, `MATCH_GIT_URL`,
   `MATCH_GIT_BASIC_AUTHORIZATION`, `MATCH_PASSWORD`.
3. Optional: `TEST_GOOGLE_MAPS_API_KEY_IOS` (§2).

## 6. First run, when everything above is confirmed

Dispatch `iOS Dev TestFlight` on branch `test` with `generate_certs: true`
and an empty build number, and watch it. Expected: match creates the `.dev`
App Store profile, `flutter build ipa --flavor dev` signs with it,
`ci_upload_dev` uploads to ALRT Dev only. A build then appears under ALRT Dev
→ TestFlight after Apple processes it; the live ALRT app is never touched.

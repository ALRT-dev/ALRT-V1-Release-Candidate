# Deployment handoff — Navigation, Leaderboard & Voice

Branch: `integrate/navigation-update` (21 commits ahead of `main`).
Built and verified on **Flutter 3.38.10** · `flutter analyze` → **0 errors**.

## TL;DR for deploying safely
- ✅ **No backend deploy required.** Every endpoint the app calls already exists in `alrtap-backend` `main`.
- ✅ **No breaking API changes.** All changes are additive on the app side; older app versions keep working.
- ⚠️ **One Google Cloud setting to verify** (Routes API — see below).
- ⚠️ **Voice needs one on-device smoke test** (static analysis can't exercise the mic).

## What's in this branch
1. **Navigation upgrade** — in-map navigation mode (state-driven, no separate screen), travel modes, alternate routes, hazard-avoiding corridors, route simulation. Plus server-driven hazard category images. (Merged from the finished `feature/navigation-update`, rebased conflicts resolved, obsolete `NavigationScreen` route removed.)
2. **Leaderboard & points breakdown** — two new profile screens consuming existing endpoints `GET /api/xp/leaderboard` and `GET /api/xp/breakdown`.
3. **Voice search** — on-device tap-to-talk dictation in the map + Search search bars (no wake word, nothing recorded). Adds `speech_to_text`; iOS/Android mic permissions included.
4. **Tooling fix** — `.fvmrc` corrected from `3.35.3` (which cannot resolve the current dependencies) to `3.38.10`, matching `pubspec.lock` (`flutter >=3.38.1`).

## Backend impact: none
The only new endpoints the app references are `/api/xp/leaderboard` and `/api/xp/breakdown` — both already live in backend `main`. Navigation computes routes client-side via Google's Routes API; voice is fully on-device. **Nothing to deploy on the server.**

## Pre-deploy checklist (app build)
- [ ] Build with **Flutter 3.38.10** (now pinned in `.fvmrc`).
- [ ] `flutter pub get` — pulls the two new deps (`speech_to_text`, `auto_size_text`).
- [ ] Generated files are committed; if regenerating: `dart run build_runner build --delete-conflicting-outputs`.
- [ ] `flutter analyze` — expect 0 errors (3 pre-existing `color`→`colorFilter` infos + the runtime-created `.env` warning are unrelated).
- [ ] `.env` present at build time with a valid `GOOGLE_MAPS_API_KEY` (unchanged requirement).
- [ ] **Google Cloud:** the Maps API key must have **Routes API**, **Places API** and **Geocoding API** enabled. Navigation route-planning uses the Routes API — if it isn't enabled on the key, routing fails at runtime.
- [ ] iOS: new `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` are present (required or App Store review rejects).
- [ ] Android: `RECORD_AUDIO` permission + `RecognitionService` query added.
- [ ] Bump `version:` in `pubspec.yaml` for the store release (currently `1.0.3+33`).
- [ ] On a real device: tap the mic in search, confirm dictation fills the box and the priming card appears on first use.

## Getting this branch into `SafetyALRT/alrtap-frontend`
The branch currently lives on `ALRT-dev/V2-Claude` (a copy, since forking is disabled on the org). To land it upstream, from a clone of `SafetyALRT/alrtap-frontend` with write access:

```bash
git remote add v2 https://github.com/ALRT-dev/V2-Claude.git
git fetch v2 integrate/navigation-update
git checkout -b integrate/navigation-update v2/integrate/navigation-update
git push -u origin integrate/navigation-update
# then open a PR into SafetyALRT/alrtap-frontend:main
```

(Requires access to `ALRT-dev/V2-Claude` — add the deployer as a collaborator on that repo, or export a patch bundle instead.)

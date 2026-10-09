# ALRT V2 — Master Handoff

Everything built in this round, where it lives, what's verified, and the exact
steps to ship it. Two audiences: **Matt** (deploy) and **Sarah** (store/billing
config).

---

## TL;DR
- **5 things built**, across two repos, all on **your** GitHub (`ALRT-dev`).
- **Nothing is on the live app** — it's all on review branches.
- Frontend compiles clean (0 errors). Backend + payments + login need real
  verification (a Node build, and on-device / store-sandbox testing).

## Where everything lives
| Repo | Branch | Contents |
|---|---|---|
| `ALRT-dev/V2-Claude` (frontend) | `integrate/navigation-update` (24 commits) | Navigation upgrade, Leaderboard/points, Voice search, ALRT+ paywall, Email login |
| `ALRT-dev/backendV2` | `claude/safety-alert-repo-audit-8exgvn` | ALRT+ entitlement fields + migration `add_alrt_plus_entitlement` + `POST /api/revenuecat/webhook` (rebuilt Aug 2026 — the original was lost with the old `backend-` repo). Type-checked with `prisma generate && tsc`. |

Backup: a `alrtap-frontend-v2-changes.bundle` patch file was also provided.

---

## What was built (feature by feature)

### 1. Navigation upgrade  — ✅ compiles
Merged the finished `feature/navigation-update` (in-map navigation mode, travel
modes, alternate routes, route simulation) + server-driven hazard icons.
- **To ship:** enable **Routes API** on the Google Maps key (Google Cloud).

### 2. Leaderboard + points breakdown  — ✅ compiles
Two profile screens on existing endpoints `/api/xp/leaderboard` + `/breakdown`.
- **To ship:** nothing extra — backend already serves these.

### 3. Voice search (tap-to-talk)  — ✅ compiles
On-device dictation in the map + Search bars. iOS/Android mic permissions added.
- **To ship:** **on-device test** (mic can't be tested by the compiler).

### 4. ALRT+ subscription  — ✅ frontend compiles / ⚠️ backend needs Node build
Paywall (store prices, monthly $9.99 / yearly $99.99, 1-month free trial),
RevenueCat wiring, gate on **hosting** a family circle (joining stays free).
Backend: entitlement fields + migration + `POST /api/revenuecat/webhook`.
- **To ship:** follow **`ALRT_PLUS_SETUP.md`** (store products, banking,
  RevenueCat). Backend must be `prisma generate && tsc`-checked before deploy.

### 5. Email + password login  — ✅ compiles
"Continue with Email" enabled; new sign-in/create-account screen wired to the
existing backend `/api/auth/email-password/*` endpoints.
- **To ship:** on-device test against the live backend.

---

## Matt's deploy checklist

### Frontend (`V2-Claude` → into `SafetyALRT/alrtap-frontend`)
1. Pull the branch (see `DEPLOYMENT_HANDOFF.md` for exact git commands, or use
   the bundle) and open a PR into `SafetyALRT/alrtap-frontend`.
2. Build with **Flutter 3.38.10** (`.fvmrc` is now correct), `flutter pub get`.
3. `flutter analyze` → expect 0 errors.
4. Add to the build `.env`: `REVENUECAT_API_KEY_APPLE`, `REVENUECAT_API_KEY_GOOGLE`
   (public keys), plus the existing `GOOGLE_MAPS_API_KEY`.
5. Google Cloud: Maps key needs **Routes API + Places + Geocoding** enabled.
6. Bump `version:` in `pubspec.yaml`.
7. Build + upload to **TestFlight / Play internal testing** for Sarah to try.

### Backend (`backendV2` → into `SafetyALRT/alrtap-backend`)
1. Pull branch `claude/safety-alert-repo-audit-8exgvn` — it contains the rebuilt
   ALRT+ entitlement fields, migration `add_alrt_plus_entitlement`, and
   `POST /api/revenuecat/webhook` (the old `backend-` repo version was lost).
2. `npm/yarn install && npx prisma generate && npx tsc --noEmit` — already
   verified clean on the branch; re-check after merging.
3. Set env `REVENUECAT_WEBHOOK_AUTH` (matches the RevenueCat dashboard).
4. Deploy — runs migration `add_alrt_plus_entitlement`.

## Sarah's config checklist (ALRT+ — see `ALRT_PLUS_SETUP.md` for detail)
- [ ] App Store Connect: create the two subscription products + 1-month free
      trial; enrol in the **Small Business Program** (15%).
- [ ] Google Play Console: same products + free trial.
- [ ] **Banking + tax** in both consoles (this is how you get paid).
- [ ] RevenueCat: project, entitlement **`plus`**, offering, webhook →
      `https://api.safetyalrt.com/api/revenuecat/webhook`.

---

## Known issues / outstanding
- **Microsoft login** is disabled (button commented out) because the backend has
  no `/oauth/microsoft` route. Google, Apple, and now Email work. Add the backend
  route if Microsoft is wanted.
- **The app calls Google Maps directly** (not the backend proxy that exists), so
  the Maps key still ships in the app for those calls. Consider routing through
  the proxy to protect the key/quota.
- **Confidence Score (0–100)** is computed by the backend but not shown to users
  — a small frontend add if you want it surfaced.
- **Verification gaps** (can't be done on Sarah's Windows machine): backend Node
  build, and on-device/store-sandbox testing of voice, payments, and login.

## Reference docs (all delivered)
| Doc | Covers |
|---|---|
| `MASTER_HANDOFF.md` (this) | The whole picture + who-does-what |
| `DEPLOYMENT_HANDOFF.md` | Frontend deploy steps + how to land the branch upstream |
| `ALRT_PLUS_SETUP.md` | ALRT+ store + RevenueCat + banking setup |
| ALRT system reference (sent as a file) | How alerts/AI work + what customers see |

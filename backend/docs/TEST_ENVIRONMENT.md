# Isolated Internal-Test Environment (Stage A)

Architecture and deployment reference for the isolated internal-test environment described in `V1_RECONCILIATION_REPORT.md`. Stage A prepares the **code and configuration** for this environment. It does not stand up any externally-reachable infrastructure — no cloud database, no hosting, no domain exists yet as a result of Stage A. Every command below must actually be run, by a human, against a real host, before a "test backend" exists in any reachable sense.

## Why this exists

The only pre-existing "test" build (`android-apk.yml`'s dev-flavor APK) points `DEV_BASE_URL` at `https://api.safetyalrt.com` — the real production backend. Anyone using that build today creates real rows in the production database. This environment exists to give internal testers a genuinely separate backend, database, and Admin Portal that cannot write to, read from, or send notifications to anything production uses.

## Architecture

```
┌─────────────────────────┐         ┌─────────────────────────┐
│   PRODUCTION (unchanged) │         │   ISOLATED TEST (Stage A)│
│                          │         │                          │
│  api.safetyalrt.com      │         │  api-test.safetyalrt.com │
│  (prod backend)          │         │  (test backend, new)     │
│         │                │         │         │                │
│  production Postgres     │         │  test Postgres (new,     │
│  (real users)             │         │  own instance)           │
│         │                │         │         │                │
│  Admin Portal (prod,     │         │  Admin Portal (test,     │
│  not deployed yet - §30)  │         │  own build/deploy)       │
│                          │         │                          │
│  [Dev] ALRT APK           │         │  ALRT Test APK (new)      │
│  (android-apk.yml,       │         │  (android-test.yml,       │
│   still points at prod)  │         │   points at test backend) │
└─────────────────────────┘         └─────────────────────────┘
        Shared: same Firebase project (alrt-a6539), reached via each
        environment's OWN app registration - not a shared boundary
        for data, only for FCM/App Check plumbing (see note below).
```

Firebase is intentionally **not** duplicated into a second project. The isolation boundary that actually matters — "can a test action reach a production user" — is the backend + database, not the Firebase project. As long as the test backend only ever knows about `UserDevice` rows in its own database, it cannot address a production device token, regardless of which Firebase project sent the underlying FCM message.

## What Stage A actually built (code/config only)

| File | Purpose |
|---|---|
| `backend/.env.test.example` | Template for the test backend's environment variables. Copy to `.env.test` (gitignored) and fill in real values. |
| `backend/docker-compose.test.yml` | A local reference deployment: its own Postgres+PostGIS container (`postgres-test`, port 5433, volume `pgdata_test`), fully separate from the existing `dev`/`prod` compose files' containers/ports/volumes. |
| `backend/.gitignore` | Added `.env.test` so a real one, once created locally, is never accidentally committed. |
| `admin/.env.test` | Committed (not gitignored — see its own header comment for why a base URL is safe to commit). Points the Admin Portal's test build at `https://api-test.safetyalrt.com` — a **proposed**, not-yet-real domain. |
| `admin/.gitignore` | Added `!.env.test` exception alongside the existing `!.env.example` one. |
| `admin/package.json` | Added `"build:test": "tsc -b && vite build --mode test"` — verified this turn to actually embed the test URL and leave the regular `build` script's output completely unaffected. |
| `frontend/.github/workflows/android-test.yml` | New, manually-triggered CI workflow: same `dev` flavor as `android-apk.yml`, but `DEV_BASE_URL` comes from a `test`-Environment-scoped secret instead of the hardcoded production URL. Does not touch `android-apk.yml` or `android-release.yml`. |

## Exact commands to actually deploy the test backend

None of this has been run. This is the reference procedure.

```bash
# 1. Provision a real Postgres+PostGIS instance somewhere (any provider -
#    the Dockerfile is cloud-agnostic). Do NOT reuse the production instance
#    or database, even as a separate schema. Get its connection string.

# 2. On a real host (or locally to smoke-test first):
cd backend
cp .env.test.example .env.test
# Fill in .env.test: DATABASE_URL (step 1's connection string), fresh JWT
# secrets (do not reuse production's), SUPER_ADMIN_* (a clearly-test-only
# email), and the other required vars per .env.test.example's own comments.

# 3. FIRST TIME ONLY, against a brand-new empty database: baseline it.
#    prisma/migrations has a known, unfixable-by-renaming ordering defect
#    (see "Prisma migration-ordering defect" section below) - a plain
#    `prisma migrate deploy` replay FAILS on an empty database. Do not skip
#    this step for a fresh database.
#
#    Local smoke test, via Docker Compose (the "baseline" profile never
#    runs automatically - it must be invoked explicitly, exactly once):
docker compose -f docker-compose.test.yml up -d postgres
docker compose -f docker-compose.test.yml --profile baseline run --rm migrate-baseline

#    Real deployment, or running the script directly against any reachable
#    Postgres (no Docker required - just needs DATABASE_URL in .env.test):
cd backend
./scripts/provision-test-db.sh --yes

# 4. THEN, and on every subsequent start, normal startup is safe - the
#    database is already baselined, so `prisma migrate deploy` only ever
#    needs to apply genuinely new migrations, exactly like production:
docker compose -f docker-compose.test.yml up
# - or, for a real (non-Docker-Compose) deployment of the existing image:
docker build -t alrt-backend-test .
docker run --env-file .env.test -p 9000:9000 alrt-backend-test \
  sh -c "npx prisma migrate deploy && yarn start"
# (Substitute your actual hosting platform's deploy mechanism if not
# running the container directly - the point is: same image, .env.test
# only, a database that has never been production's, already baselined
# per step 3 above before this is ever run against it for the first time.)

# 5. Seed the dedicated test super-admin (run once, against .env.test):
NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/create-super-admin.ts

# 6. Point DNS/your hosting platform's routing at this deployment under
#    whatever domain you choose (api-test.safetyalrt.com is proposed in
#    admin/.env.test - change both if you pick something else).
```

### Prisma migration-ordering defect — why a persistent TEST database needs baselining, not a plain `migrate deploy`

Two migrations, `20250317000000_add_category_images` and `20250317100000_remove_url_from_hazard_category_image`, are misdated — they were actually authored in March **2026** (a year-typo in their hand-authored timestamp prefix; `backend/CLAUDE.md` confirms migrations here are hand-authored SQL, not `prisma migrate dev`-generated), but their filenames sort them before `20251004073622_init`, the migration that creates the tables they depend on. `prisma migrate deploy` applies migrations strictly in filename order, so against a brand-new, empty database it fails immediately with `P3018` (`relation "HazardCategory" does not exist`) — reproduced and confirmed during this project's investigation (`V1_RECONCILIATION_REPORT.md` §33.1).

**This is never fixed by renaming, reordering, editing, deleting, or squashing any migration file.** Production's `_prisma_migrations` table almost certainly already has these two migrations recorded under their current names (they applied successfully in production because `HazardCategory` already existed by the time they were actually written, five months after `init`) — renaming a migration folder would desync any database, including a freshly-provisioned TEST one, from that history.

**The safe approach for a persistent TEST database is baselining**, not a plain `migrate deploy` replay: `scripts/provision-test-db.sh` builds the schema directly via `prisma db push` (bypassing migration replay entirely, so the ordering bug never triggers), then records every existing migration as already applied — in the corrected dependency order — via `prisma migrate resolve --applied`, which only writes ledger rows and never re-runs any migration's SQL. This is Prisma's own documented pattern for baselining a database against a known-good schema. Verified end-to-end against a disposable local database before this script was written: all 101 migrations resolved with zero failures, `prisma migrate status` reported the database up to date, and a genuine new dummy migration applied cleanly afterwards via ordinary `prisma migrate deploy` — confirming this leaves the database in a state where all FUTURE migrations apply completely normally, exactly like production's own `docker-compose.yml` boot command already assumes.

Run `scripts/provision-test-db.sh --yes` (or the Docker Compose `migrate-baseline` service) exactly **once**, against a brand-new, empty TEST database, before the `app` service is ever started against it. It is not safe to re-run against a database that already has data — see the script's own header comment for the safety checks it performs.

### Important operational note: scheduled jobs (ingestion) need `NODE_ENV=prod`, not `NODE_ENV=test`

`backend/src/index.ts` only starts the in-process cron jobs (hazard ingestion every 15 min, account-deletion sweep, expiry sweep, check-in firing) when `config.env === "prod"` (`NODE_ENV=prod`) — this is hardcoded (`runScheduledTasksInDev = false` in source), not configurable via env var. `.env.test.example` deliberately sets `NODE_ENV=test`, which means **the test backend will not automatically ingest real-world hazards**.

This is a genuine tradeoff, not an oversight, and changing it is out of Stage A's scope (it would mean editing `index.ts`'s scheduling gate, a small application-code change to shared production code — not something to do without your explicit sign-off). Two ways to get real hazard data on the test backend without that code change:
- Use the existing manual trigger: Admin Portal → Sources → Sync (calls `POST /api/admin/hazards/sync-external`, already built, works regardless of `NODE_ENV`).
- Create hazards directly (community report flow, or via the seeded test super-admin's own account) for whatever specific scenario you're testing.

If you'd rather have real automatic ingestion on the test backend, that's a small, separate follow-up (either loosen the `NODE_ENV=prod` gate to also accept a new, explicit flag, or genuinely run the test backend with `NODE_ENV=prod` — its `.env` file would then need to be named `.env.prod` on that host specifically, since the loader is `.env.${NODE_ENV}`; this is purely a same-code, different-deployment naming detail, not a collision with the real production server's own `.env.prod`, which lives on a completely different host). Flagging this rather than deciding it for you.

## Isolation verification (what was actually checked, and how)

| Property | Verified how | Result |
|---|---|---|
| Test backend → test database | Code inspection: `DATABASE_URL` is the sole database connection var (`config.ts:52`), sourced from whichever `.env.${NODE_ENV}` file is loaded — `.env.test` for this environment, pointed at a database that has never held production data by construction (a fresh instance, per the deploy procedure above). No code path reads a second/fallback database connection string. | **Verified in code.** Cannot be verified as "actually connected to a real separate database" until the real deployment exists — see the honesty note below. |
| Test Admin Portal → test backend | Empirically built this turn: `npm run build:test` (Vite `--mode test`) embeds `https://api-test.safetyalrt.com` in the compiled bundle (`grep` confirmed it present); the regular `npm run build` (no mode flag, what any production build would use) was rebuilt immediately after and confirmed to **not** contain that string at all. | **Empirically verified**, both directions. |
| Android test build → test backend | Code inspection: `android-test.yml`'s only difference from `android-apk.yml` is `DEV_BASE_URL` sourced from `secrets.TEST_BACKEND_URL` (environment-scoped) instead of the hardcoded production URL string; the app's own `providerOfBaseUrlDev` (`base_url_provider.dart`) reads `DEV_BASE_URL` from `.env` with no other override path. | **Verified in code and CI YAML.** Not run — see below. |
| No test component → production database | `android-apk.yml`, `android-release.yml`, `frontend/lib/api/endpoints.dart`'s `kUrlBase` (hardcoded, no env override — confirmed in an earlier audit this project), and every file in the "production configuration" list in the stop condition were read again this turn and confirmed **unchanged** (see the diff-based proof below). | **Verified — nothing touched.** |
| No test notification can target production users through the test database | The push-send path (`notification.service.ts`) queries `UserDevice` rows by user id, resolved entirely within whatever database the running backend process is connected to — there is no cross-database or cross-environment lookup anywhere in that code path. A test backend with its own, separate database structurally cannot enumerate or address a production device token. | **Verified in code.** This is an architectural guarantee (no shared code path exists to cross environments), not something that needs a live test to confirm — but real device delivery is still unverified, see below. |

### What cannot be verified in this environment

- **No real test backend has been deployed.** Nothing above proves an externally-reachable test API exists — only that the code/config, once deployed correctly, will behave as designed. This distinction matters: a locally-run `docker-compose.test.yml` on this machine is not "a deployed test environment" either, and wasn't attempted as a substitute for one.
- **No real device has installed the test APK.** `android-test.yml` was authored and YAML-syntax-validated (`python3 -c "import yaml; ..."`) but never executed — no Flutter/Android SDK toolchain exists in this environment (same limitation as every prior stage of this project).
- **No real push notification was sent or received** — the architectural guarantee above (separate database ⇒ no addressable production tokens) is a code-level fact, not something exercised end-to-end here.
- **DNS for `api-test.safetyalrt.com` does not exist.** It is a proposed name only, matching this repo's `api.safetyalrt.com`/`admin.safetyalrt.com` convention (`config.ts`'s `CORS_ALLOWED_ORIGINS` default).

Classify accordingly: **CODE VERIFIED** and, for the Admin Portal build split, **BUILD VERIFIED** (an actual `npm run build`/`build:test` pair was run and diffed) — nothing here is **REAL DEVICE VERIFIED** or **DEPLOYED-INFRASTRUCTURE VERIFIED**.

## External actions you still need to perform

1. Provision a real Postgres+PostGIS instance for the test backend (any provider) — not the production instance, not a schema within it.
2. Deploy the backend Docker image somewhere reachable, with `.env.test` (never `.env.dev`/`.env.prod`) as its environment.
3. Register/point a domain at it (`api-test.safetyalrt.com` proposed, or your own choice — update `admin/.env.test` and this doc if you pick something else).
4. In GitHub: Settings → Environments → New environment → name it exactly `test`. Add one secret to it: `TEST_BACKEND_URL` = the real URL from step 3.
5. Run `create-super-admin.ts` against `.env.test` once the backend is live (command above) to get your first test-environment admin login.
6. Deploy the Admin Portal test build (`npm run build:test` output) to a static host of your choice, and add that host's domain to the test backend's `CORS_ALLOWED_ORIGINS`.
7. Once 1–4 are done, run `android-test.yml` manually (Actions → Android Test Build → Run workflow) to produce the first isolated test APK.

No Google Cloud, Firebase, or RevenueCat configuration is required for Stage A specifically — those remain deferred per the stop condition.

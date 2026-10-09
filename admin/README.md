# ALRT Admin Portal

Internal operational web app for ALRT administrators (moderator / admin /
super admin). A thin client over the existing backend Admin API
(`backend/src/routes/admin/*`) - it holds no database credentials, no
service-account credentials, no Google API keys, and no webhook API keys.
Every privileged operation goes through the backend, which remains the
sole authority on authorization; nothing here should ever be treated as a
security control on its own.

Built Stage 7C, against the backend as it stood after Stage 7B (see
`V1_RECONCILIATION_REPORT.md` §22-§24 for the audit/hardening history this
portal is built on).

## Stack

Vite + React + TypeScript, `react-router-dom` for routing, plain `fetch`
(no HTTP client library), plain CSS (no UI framework), `oxlint` for
linting, `vitest` + `@testing-library/react` for tests. No state-management
library, no CSS framework, no component library - the app is a handful of
list/detail screens, which doesn't justify the extra dependencies.

No existing web tooling was found anywhere else in this monorepo or the
other ALRT repositories to reuse (see §22.5 of the report) - this is a
from-scratch scaffold, deliberately minimal.

## Development setup

```bash
cd admin
npm install
cp .env.example .env.local   # then edit VITE_API_BASE_URL if needed
npm run dev
```

The backend must be running separately (see `backend/README.md` /
`backend/CLAUDE.md`) with `CORS_ALLOWED_ORIGINS` including this app's
origin, or simply running in a non-production `NODE_ENV`, where
`localhost`/`127.0.0.1` origins are allowed automatically
(`backend/src/utils/cors.util.ts`).

## Environment variables

Only one, and it is not a secret - see `.env.example`:

| Variable | Meaning |
|---|---|
| `VITE_API_BASE_URL` | Base URL of the backend Admin API, no trailing slash. Defaults to `http://localhost:3000` in `.env.example`. |

Vite only exposes variables prefixed `VITE_` to client code, so nothing
else in the backend's own `.env` can leak into this app's bundle even by
accident.

## Authentication

Uses the backend's existing admin JWT system
(`POST /api/admin/auth/login`, `/refresh-token`, `/logout`) - there is no
second authentication system. Access and refresh tokens are stored in
`localStorage` (the only realistic option given the backend issues bearer
JWTs rather than an httpOnly session cookie; see `src/api/tokenStorage.ts`,
the one file that touches storage). A 401 from any authenticated request
triggers a single silent refresh-and-retry; if the refresh itself fails,
tokens are cleared and every screen is returned to `/login`. The backend
has no server-side token revocation yet (Stage 7B finding, unchanged) - so
"logout" is client-side token clearing plus a best-effort call to
`POST /api/admin/auth/logout`.

First login: a new admin account has `mustChangePassword` set. When login
(or `GET /api/admin/users/me`) reports it, or when any request comes back
403 with `code: "PASSWORD_CHANGE_REQUIRED"`, every route sends the admin to
`/change-password` (no sidebar) until `POST /api/admin/auth/change-password`
succeeds; then they continue to the page they asked for. The backend
refuses every other admin route meanwhile, so this is not only a UI gate.

Role (`moderator` / `admin` / `superAdmin`) is read from the authenticated
admin's own profile (`GET /api/admin/users/me`) and used only to hide
controls the role cannot use - `src/auth/AuthContext.tsx`'s `hasRole()` is
explicitly documented as UX-only. Every screen still has to handle a 403
from the API gracefully, because the frontend check is never trusted as
the real gate.

## Build / lint / test commands

```bash
npm run build       # tsc -b && vite build -> dist/
npm run lint        # oxlint
npm run test         # vitest run (single pass, CI-friendly)
npm run test:watch   # vitest watch mode
npm run dev          # local dev server
npm run preview      # preview a production build locally
```

## Deployment requirements (not done this stage - see the report's stop condition)

- Static hosting for the `dist/` build output (any static host/CDN).
- `VITE_API_BASE_URL` set at build time to the real backend's public URL.
- The backend's `CORS_ALLOWED_ORIGINS` env var must include this app's
  real deployed origin (`backend/CLAUDE.md`'s CORS section).
- Recommended: an internal-only domain/path given the sensitivity of the
  operations here (AI prompt editing, webhook key minting), not the same
  public domain as the marketing site without additional access control.
- No new backend environment variables are required - this app only calls
  the existing Admin API.

### Cloudflare Pages (`*.pages.dev`) and which backend it talks to

On any `*.pages.dev` address the browser calls the portal's own `/api`, and
the Pages Function in `functions/api/[[path]].ts` relays it to the backend.
The relay picks the backend in this order:

1. The Pages environment variable `API_ORIGIN` (Pages project, Settings,
   Environment variables, Production). **For production set
   `API_ORIGIN=https://api.safetyalrt.com`.** For the TEST project set
   `API_ORIGIN=https://api-test.safetyalrt.com` (or leave it unset).
2. Otherwise the TEST backend, `https://api-test.safetyalrt.com`. The live
   backend is only ever reached through `API_ORIGIN`; nothing the browser
   sends can choose it, so a TEST portal can never end up on live data.

Set both `API_ORIGIN` (runtime) and `VITE_API_BASE_URL` (build time) to the
same backend so they cannot disagree. The Webhook API Keys page asks the
relay (`GET /api/__alrt-relay-origin`) which backend it resolved, so the n8n
test workflow download always names the backend the portal really uses.

## Known V1 limitations

See `V1_RECONCILIATION_REPORT.md` §24 for the full list with reasoning.
Summary:

- Audit Log viewer (admin and super admin only, hidden from moderators'
  navigation) reads `GET /api/admin/audit-log`; source create, update and
  delete are recorded with before/after of the changed fields.
- Paging: Alerts, Moderation, Sources, Users and Audit Log page 50 rows at a
  time. Only the Users endpoint returns a `total`, so only Users can show
  "Page X of Y" up front; the hazard, source and audit-log endpoints return
  a bare array, so those screens show "Page X" and treat a short page as
  the last one.
- Ask ALRT AI switch (Ask ALRT and Ask ALRT Answers pages) reads and sets
  `/api/admin/ask-alrt/config`. Admin and super admin can change it;
  moderators see it read-only. When the server's environment config forces
  AI off, the switch is shown disabled.
- The n8n test workflow posts to the dedicated `test-dummy` source, never
  a real feed. The webhook rejects unknown source ids, so downloading the
  workflow as an admin creates that source first.
- No Emergency Information screen - no backend model exists.
- Category icon image upload is not supported (text fields only); the
  backend supports multipart image upload but it wasn't built into V1.
- AI Prompt create/delete and Configuration `value` editing are
  intentionally not exposed - both are backend-supported but high-risk to
  expose in a first version with no operational track record yet.
- Source registry: lifecycle status, health, review dates, licensing notes
  and source-native severity/symbol are editable or shown on Sources.
  Suspended or retired sources are skipped by ingestion. Feed URL, adapter
  and schedule are recorded for reference only: the ingestion code
  (`backend/src/services/ingestion.service.ts`) still has a fixed list of
  feeds and a fixed 15-minute timer, so a new source needs an adapter added
  in code before it ingests.
- ALRT+/subscription entitlement and family-circle membership are not
  shown on the Users screen because the Admin API doesn't currently expose
  either for app users.

### Putting the new portal on live data next to the old console

The old console stays at `admin.safetyalrt.com`, untouched. The new portal
goes on its own address first:

1. Cloudflare, Workers & Pages, Create, Pages, Connect to Git: repository
   `ALRT-dev/ALRT-V1-Release-Candidate`, production branch
   `release-candidate`.
2. Build settings: root directory `admin`, build command `npm run build`,
   output directory `dist`.
3. Settings, Environment variables, Production:
   `API_ORIGIN=https://api.safetyalrt.com`.
4. Custom domains: add `admin-new.safetyalrt.com`.

`npm run build` reads `.env.production` (live API, `VITE_USE_RELAY=true`),
so every call goes through the Pages relay and the live backend needs no
CORS change. Pages the live server does not support yet show "This part of
the portal needs the server update" instead of an error. Move
`admin.safetyalrt.com` across only after the live backend is updated.

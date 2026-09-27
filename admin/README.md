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

## Known V1 limitations

See `V1_RECONCILIATION_REPORT.md` §24 for the full list with reasoning.
Summary:

- No Audit Log viewer - `AdminAuditLog` rows are written (Stage 7B) but no
  read endpoint exists yet on the backend.
- No Emergency Information screen - no backend model exists.
- Category icon image upload is not supported (text fields only); the
  backend supports multipart image upload but it wasn't built into V1.
- AI Prompt create/delete and Configuration `value` editing are
  intentionally not exposed - both are backend-supported but high-risk to
  expose in a first version with no operational track record yet.
- Source enable/disable and source-health metrics are not shown because
  the backend schema doesn't track either.
- ALRT+/subscription entitlement and family-circle membership are not
  shown on the Users screen because the Admin API doesn't currently expose
  either for app users.

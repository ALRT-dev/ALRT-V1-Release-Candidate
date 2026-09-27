#!/usr/bin/env bash
#
# First-time provisioning for the isolated internal-TEST database ONLY.
#
# Why this exists (see V1_RECONCILIATION_REPORT.md §33.1 for the full
# investigation): two migrations in prisma/migrations are misdated -
# `20250317000000_add_category_images` and
# `20250317100000_remove_url_from_hazard_category_image` were actually
# authored in March 2026 (a year-typo in their hand-authored timestamp
# prefix - see backend/CLAUDE.md, migrations are hand-authored SQL, not
# `prisma migrate dev`-generated), but their filenames sort them before
# `20251004073622_init`, the migration that creates the tables they depend
# on. `prisma migrate deploy` applies migrations strictly in filename order,
# so run against a brand-new, empty database it fails immediately with
# P3018 ("relation HazardCategory does not exist").
#
# This is NOT fixed by renaming/reordering/editing/deleting/squashing any
# migration file - production's `_prisma_migrations` table already has
# these two migrations recorded under their current names (they applied
# successfully in production because HazardCategory already existed on
# that database by the time they were actually written), and renaming a
# migration folder would desync any database - including this one, once
# provisioned - from that history. No migration file is touched by this
# script or should ever be touched to solve this.
#
# Instead, this script BASELINES a fresh database: it builds the current
# schema directly (bypassing migration replay entirely, so the ordering
# bug never triggers), then records every existing migration as already
# applied - in the CORRECT dependency order - without re-running any of
# their SQL. This is Prisma's own documented pattern for baselining an
# existing/target database against a known-good schema.
# https://www.prisma.io/docs/guides/database/baselining
#
# Verified end-to-end against a disposable local database before this
# script was written: all migrations resolved with zero failures,
# `prisma migrate status` reported the database up to date, and a genuine
# new dummy migration applied cleanly afterwards via ordinary
# `prisma migrate deploy` - confirming this leaves the database in a state
# where all FUTURE migrations apply completely normally.
#
# Run this ONCE, against a brand-new, empty TEST database, before the
# `app` service is ever started against it. It is NOT safe to re-run
# against a database that already has data or an existing schema -
# `prisma db push` will alter the live schema to match prisma/schema.prisma,
# which can drop or rewrite columns if the two have diverged. This script
# refuses to run unless you pass --yes, and best-effort checks (when psql
# is available) whether the target database has already been provisioned.
#
# Usage:
#   cd backend
#   cp .env.test.example .env.test   # fill in DATABASE_URL etc. first
#   ./scripts/provision-test-db.sh --yes
#
# Or, via Docker Compose (see docker-compose.test.yml's "migrate-baseline"
# service, gated behind the "baseline" profile so `docker compose up` never
# runs this automatically):
#   docker compose -f docker-compose.test.yml --profile baseline run --rm migrate-baseline

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

ENV_FILE="${ENV_FILE:-.env.test}"
CONFIRM=false
for arg in "$@"; do
  if [ "$arg" = "--yes" ]; then
    CONFIRM=true
  fi
done

if [ ! -f "$ENV_FILE" ]; then
  echo "::error:: $ENV_FILE not found. Copy .env.test.example to $ENV_FILE and fill in real values first." >&2
  exit 1
fi

# Refuse to run against anything that isn't explicitly NODE_ENV=test - this
# script must never be pointed at a production or dev env file.
if ! grep -qE '^NODE_ENV=test\s*$' "$ENV_FILE"; then
  echo "::error:: $ENV_FILE does not have NODE_ENV=test. Refusing to run - this script is for the isolated TEST database only." >&2
  exit 1
fi

set -o allexport
# shellcheck disable=SC1090
source "$ENV_FILE"
set +o allexport

if [ -z "${DATABASE_URL:-}" ]; then
  echo "::error:: DATABASE_URL is empty in $ENV_FILE." >&2
  exit 1
fi

# Mask credentials when printing the target for confirmation.
MASKED_URL=$(echo "$DATABASE_URL" | sed -E 's#(://[^:]+):[^@]+@#\1:****@#')
echo "Target database: $MASKED_URL"

if command -v psql >/dev/null 2>&1; then
  EXISTING=$(psql "$DATABASE_URL" -tAc "SELECT count(*) FROM _prisma_migrations" 2>/dev/null || echo "")
  if [ -n "$EXISTING" ] && [ "$EXISTING" != "0" ]; then
    echo "::error:: This database already has $EXISTING row(s) in _prisma_migrations - it looks already provisioned." >&2
    echo "This script is for FIRST-TIME provisioning of an empty database only. Refusing to run." >&2
    exit 1
  fi
else
  echo "Note: psql not found - skipping the already-provisioned check. Make sure this is really a fresh, empty database."
fi

if [ "$CONFIRM" != true ]; then
  echo
  echo "This will run 'prisma db push' against the database above, which builds"
  echo "the schema directly from prisma/schema.prisma. Only do this against a"
  echo "brand-new, empty database that has never held production data."
  echo
  echo "Re-run with --yes to proceed."
  exit 1
fi

echo
echo "== Step 1/4: building the schema (prisma db push) =="
npx prisma db push --skip-generate --schema=prisma/schema.prisma

echo
echo "== Step 2/4: applying raw SQL for migrations not representable in schema.prisma =="
#
# 'prisma db push' above builds the schema purely from prisma/schema.prisma,
# so any migration whose SQL does something the Prisma schema DSL cannot
# express - e.g. a partial unique index - is silently never created. Step
# 3 below then marks that migration "applied" without ever running its SQL,
# so the constraint would otherwise never exist in TEST at all (see
# 20260202080000_add_partial_unique_index_own_location - its
# `CREATE UNIQUE INDEX ... WHERE "isOwnLocation" = true` is a partial
# index, which schema.prisma's @@index/@@unique cannot represent). Run
# each such migration's SQL directly against the datasource before it is
# recorded as applied.
RAW_SQL_MIGRATIONS=(
  "20260202080000_add_partial_unique_index_own_location"
)

for name in "${RAW_SQL_MIGRATIONS[@]}"; do
  echo "Applying $name..."
  npx prisma db execute \
    --file "prisma/migrations/$name/migration.sql" \
    --schema=prisma/schema.prisma
done

echo
echo "== Step 3/4: recording migration history (prisma migrate resolve --applied) =="

# The two migrations misdated a year early (see header comment above) -
# never renamed in the repo, only repositioned here, in memory, for the
# order this script marks them applied in.
ANOMALOUS_1="20250317000000_add_category_images"
ANOMALOUS_2="20250317100000_remove_url_from_hazard_category_image"
INIT_ANCHOR="20251004073622_init"

mapfile -t ALL_MIGRATIONS < <(find prisma/migrations -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

ORDERED=()
for m in "${ALL_MIGRATIONS[@]}"; do
  if [ "$m" = "$ANOMALOUS_1" ] || [ "$m" = "$ANOMALOUS_2" ]; then
    continue
  fi
  ORDERED+=("$m")
  if [ "$m" = "$INIT_ANCHOR" ]; then
    ORDERED+=("$ANOMALOUS_1" "$ANOMALOUS_2")
  fi
done

echo "${#ORDERED[@]} migrations to record, in corrected dependency order."

count=0
for name in "${ORDERED[@]}"; do
  npx prisma migrate resolve --applied "$name" --schema=prisma/schema.prisma
  count=$((count + 1))
done
echo "Recorded $count migrations as applied."

echo
echo "== Step 4/4: verifying =="
npx prisma migrate status --schema=prisma/schema.prisma

echo
echo "Done. This database is now baselined - any FUTURE new migration will"
echo "apply normally via ordinary 'prisma migrate deploy' (which is what the"
echo "app service's normal startup command already runs)."

#!/bin/bash
# prod-migrate.sh — safe migration runner for ALRT prod/test deploys.
#
# Problem: migration 20250317000000_add_category_images has an earlier
# timestamp than 20251004073622_init (which creates HazardCategory), so on a
# completely fresh database "prisma migrate deploy" runs it first and fails
# with P3018 / relation "HazardCategory" does not exist.
#
# Fix: if the _prisma_migrations table doesn't exist yet (brand new DB), mark
# all migrations from before the init as resolved-applied so Prisma skips
# them. "prisma db push" already applied the full current schema, so the
# tables those early migrations create ARE present — we're just syncing the
# migration ledger to match.
#
# On an existing database (one that already has a migration ledger) this
# script is a no-op: it detects the table exists and goes straight to
# "prisma migrate deploy".
set -e

SCHEMA_TABLE_COUNT=$(npx prisma db execute --stdin 2>/dev/null <<'SQL'
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = '_prisma_migrations';
SQL
)

if echo "$SCHEMA_TABLE_COUNT" | grep -q "^ *0 *$\| 0 "; then
  echo "[prod-migrate] Fresh database — pre-marking bootstrap migrations as applied..."
  # These migrations predate the init migration but their tables are created
  # by the init. Mark them applied so migrate deploy doesn't try to run them
  # before the init.
  npx prisma migrate resolve --applied 20250317000000_add_category_images 2>/dev/null || true
  npx prisma migrate resolve --applied 20250317100000_remove_url_from_hazard_category_image 2>/dev/null || true
  echo "[prod-migrate] Bootstrap migrations marked. Running migrate deploy..."
else
  echo "[prod-migrate] Existing database — running migrate deploy directly..."
fi

npx prisma migrate deploy

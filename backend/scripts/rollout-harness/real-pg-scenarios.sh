#!/usr/bin/env bash
# Runs the rollout script's DATABASE path for real against a local PostgreSQL: ledger queries, column checks, pg_dump,
# createdb, pg_restore --exit-on-error, fingerprint comparison, dropdb, and the post-start proof after the two approved
# migrations are applied. Docker, git, curl and IMDS stay stand-ins. Needs: PGHOST/PGUSER/PGPASSWORD for a role with
# CREATEDB, and a source database REAL_SOURCE_DB that already has the approved migrations applied (a local dev DB).
#
# It creates a throwaway copy of the source, strips the three approved columns and the two ledger rows from the copy
# (so the copy looks like TEST before the rollout), points the script at the copy, and drops the copy at the end.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SCRIPT="$HERE/../alrt-test-rollout.sh"
BACKEND=$(cd "$HERE/../.." && pwd)
: "${REAL_SOURCE_DB:?set REAL_SOURCE_DB}"
export REAL_APP_DB="alrt_rollout_harness_$$"
export REAL_MIGRATIONS="$BACKEND/prisma/migrations"
export FAKE_PIN="2222222222222222222222222222222222222222"
FAILS=0

FAKE_REPO=$(mktemp -d); export FAKE_REPO
mkdir -p "$FAKE_REPO/.git" "$FAKE_REPO/backend"; cp "$BACKEND/docker-compose.test.yml" "$FAKE_REPO/backend/"; printf 'NODE_ENV=test\n' > "$FAKE_REPO/backend/.env.test"
for f in src/services/family.service.ts src/controllers/family.controller.ts src/scripts/verify_family_location_consent.ts src/scripts/verify_targeted_check_in_request.ts src/scripts/verify_push_notification_settings.ts src/services/notification.service.ts src/services/user.service.ts package.json \
         prisma/migrations/20260904000000_family_check_in_request_targets/migration.sql prisma/migrations/20260905000000_family_host_transition/migration.sql; do
  mkdir -p "$FAKE_REPO/backend/$(dirname "$f")"; cp "$BACKEND/$f" "$FAKE_REPO/backend/$f"
done

cleanup() { dropdb --if-exists "$REAL_APP_DB" 2>/dev/null; }
trap cleanup EXIT
createdb -T "$REAL_SOURCE_DB" "$REAL_APP_DB" || { echo "could not copy $REAL_SOURCE_DB"; exit 1; }
psql -d "$REAL_APP_DB" -v ON_ERROR_STOP=1 -q <<'SQL'
alter table "FamilyCheckInRequest" drop column "targetMemberIds";
alter table "FamilyCircle" drop column "hostTransitionStartedAt", drop column "hostTransitionHostName";
delete from _prisma_migrations where migration_name in ('20260904000000_family_check_in_request_targets','20260905000000_family_host_transition');
-- the local dev ledger may carry an abandoned/rolled-back attempt from earlier local work; TEST's ledger is clean, and the copy must look like TEST
delete from _prisma_migrations where finished_at is null or rolled_back_at is not null;
SQL
# a local dev ledger can hold names that no longer exist as folders; TEST's ledger was built from the repo's folders
# (provision-test-db.sh resolves each folder), so the copy is trimmed to names that have a folder.
for name in $(psql -Atc "select migration_name from _prisma_migrations" -d "$REAL_APP_DB"); do
  [ -d "$REAL_MIGRATIONS/$name" ] || psql -d "$REAL_APP_DB" -Atq -c "delete from _prisma_migrations where migration_name = '$name'"
done
echo "harness app db: $REAL_APP_DB (copy of $REAL_SOURCE_DB, approved columns removed)"
echo "databases before: $(psql -Atc 'select count(*) from pg_database' -d "$REAL_APP_DB")"

base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"
ENV="ALRT_REPO=$FAKE_REPO ALRT_ROLLOUT_BASE=$base/rollout ALRT_DOCKER=$HERE/bin/real-pg-docker ALRT_GIT=$HERE/bin/fake-git ALRT_CURL=$HERE/bin/fake-curl ALRT_IMDS=http://imds ALRT_SLEEP_AFTER_UP=0"
check() { if printf '%s' "$2" | grep -q -- "$4"; then echo "PASS [$1] exit=$3 :: $(printf '%s' "$2" | grep -- "$4" | tail -1 | cut -c1-160)"; else echo "FAIL [$1] exit=$3 (expected: $4)"; printf '%s\n' "$2" | tail -12 | sed 's/^/    /'; FAILS=$((FAILS+1)); fi; }

out=$(env $ENV SCENARIO= bash "$SCRIPT" preflight --pin "$FAKE_PIN" 2>&1); check "preflight (real ledger + schema)" "$out" $? "approved columns present: 0"
out=$(env $ENV SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" 2>&1); check "record (real ledger clean check)" "$out" $? "rollback point recorded"
rd=$(cat "$base/rollout/current-run"); echo "     ledger-before head: $(head -2 "$rd/ledger-before.txt" | tr '\n' '|')"
# an update attempted BEFORE the first rollout must stop at the gate with nothing changed
out=$(env $ENV SCENARIO= bash "$SCRIPT" deploy --pin "$FAKE_PIN" --no-new-migrations 2>&1); check "update mode refused while the two migrations are pending (real ledger)" "$out" $? "unexpected pending migrations found"
[ "$(psql -Atc "select count(*) from pg_database where datname like 'alrt_restore_check_%'" -d "$REAL_APP_DB")" = "0" ] && echo "PASS [no scratch made before the gate]" || { echo "FAIL [scratch made before the gate]"; FAILS=$((FAILS+1)); }
out=$(env $ENV SCENARIO= bash "$SCRIPT" deploy --pin "$FAKE_PIN" --apply-approved-migrations 2>&1); check "deploy (real dump/restore/migrate/proof)" "$out" $? "deployed $FAKE_PIN"
echo "     $(cat "$rd/restore-check.txt")"
echo "     $(cat "$rd/schema-columns-after.txt")"
echo "     migrations: $(tr '\n' ' ' < "$rd/migrations-applied.txt")"
echo "     dump: $(ls -l "$rd"/*.dump | awk '{print $1, $5, $9}')"
echo "     scratch db created: $(cat "$rd/scratch-db.txt")"
left=$(psql -Atc "select count(*) from pg_database where datname like 'alrt_restore_check_%'" -d "$REAL_APP_DB")
[ "$left" = "0" ] && echo "PASS [no scratch database left behind]" || { echo "FAIL [scratch databases left: $left]"; FAILS=$((FAILS+1)); }
before=$(grep -c . "$rd/databases-before.txt"); now=$(psql -Atc 'select count(*) from pg_database' -d "$REAL_APP_DB")
[ "$before" = "$now" ] && echo "PASS [database count unchanged: $now]" || { echo "FAIL [database count $before -> $now]"; FAILS=$((FAILS+1)); }
out=$(env $ENV SCENARIO= bash "$SCRIPT" verify 2>&1); check "verify (real ledger/columns, stand-in scripts)" "$out" $? "verification passed"
# a second deploy attempt against the now-migrated real DB must be refused by the run guard; a fresh run must stop at the schema gate
out=$(env $ENV SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" 2>&1); check "record on migrated db" "$out" $? "rollback point recorded"
out=$(env $ENV SCENARIO=stale-status bash "$SCRIPT" deploy --pin "$FAKE_PIN" --apply-approved-migrations 2>&1); check "deploy refuses when columns already exist" "$out" $? "approved columns already exist"
out=$(env $ENV SCENARIO=next-image bash "$SCRIPT" deploy --pin "$FAKE_PIN" --apply-approved-migrations 2>&1); check "first-rollout mode refused on the migrated db" "$out" $? "use --no-new-migrations"
ledger_before=$(psql -Atc "select string_agg(migration_name, ',' order by migration_name) from _prisma_migrations" -d "$REAL_APP_DB")
out=$(env $ENV SCENARIO=next-image bash "$SCRIPT" deploy --pin "$FAKE_PIN" --no-new-migrations 2>&1); check "update deploy (real ledger/columns/dump/restore, nothing applied)" "$out" $? "deployed $FAKE_PIN (mode no-new)"
rd=$(cat "$base/rollout/current-run")
echo "     gate: $(tr '\n' '|' < "$rd/pending-migrations.txt")"; echo "     $(cat "$rd/restore-check.txt")"
ledger_after=$(psql -Atc "select string_agg(migration_name, ',' order by migration_name) from _prisma_migrations" -d "$REAL_APP_DB")
[ "$ledger_before" = "$ledger_after" ] && echo "PASS [ledger unchanged by the update]" || { echo "FAIL [ledger changed by the update]"; FAILS=$((FAILS+1)); }
left=$(psql -Atc "select count(*) from pg_database where datname like 'alrt_restore_check_%'" -d "$REAL_APP_DB")
[ "$left" = "0" ] && echo "PASS [no scratch database left behind after the update]" || { echo "FAIL [scratch databases left: $left]"; FAILS=$((FAILS+1)); }
out=$(env $ENV SCENARIO= bash "$SCRIPT" verify 2>&1); check "verify after the update" "$out" $? "verification passed"
echo; [ "$FAILS" -eq 0 ] && echo "ALL REAL-POSTGRES SCENARIOS PASSED" || { echo "$FAILS FAILURE(S)"; exit 1; }

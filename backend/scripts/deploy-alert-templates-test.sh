#!/usr/bin/env bash
# One scoped TEST rollout. Arguments: reviewed commit, observed checkout HEAD,
# observed running image ID. Uses a separate release directory, never resets
# the shared checkout, never changes the database volume or production.
set -euo pipefail
umask 077
export LC_ALL=C
PIN=${1:?reviewed commit required}
PREVIOUS_HEAD=${2:?observed checkout HEAD required}
PREVIOUS_IMAGE=${3:?observed running image ID required}
[[ "$PIN" =~ ^[a-f0-9]{40}$ && "$PREVIOUS_HEAD" =~ ^[a-f0-9]{40}$ && "$PREVIOUS_IMAGE" =~ ^sha256:[a-f0-9]{64}$ ]]
REPO=/opt/alrt-test/repo
MIGRATION=20261013210000_hazard_content_details
TOKEN=$(curl -fsS --max-time 10 -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 60' http://169.254.169.254/latest/api/token)
IDENTITY=$(curl -fsS --max-time 10 -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document)
printf '%s' "$IDENTITY" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert (d["accountId"],d["instanceId"],d["region"]) == ("488658242173","i-0045a41694e315d45","ap-southeast-2")'
exec 9>/var/tmp/alrt-template-rollout.lock
flock -n 9
gitrepo() { git -c safe.directory="$REPO" -C "$REPO" "$@"; }
assert_unchanged() {
  test "$(gitrepo rev-parse HEAD)" = "$PREVIOUS_HEAD"
  test "$(docker inspect --format '{{.Image}}' app-test)" = "$PREVIOUS_IMAGE"
  test "$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' app-test)" = backend
  test "$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/var/lib/postgresql/data"}}{{.Name}}{{end}}{{end}}' postgres-test)" = backend_pgdata_test
  docker exec app-test node -e 'if(process.env.NODE_ENV!=="test" || process.env.RC_EXPECTED_ENVIRONMENT!=="SANDBOX")process.exit(1)'
}
assert_unchanged
RUN=$(mktemp -d /var/tmp/alrt-template-rollout.XXXXXXXX)
echo "Release evidence: $RUN"
printf '%s\n' "$PIN" > "$RUN/revision.txt"
printf '%s\n' "$PREVIOUS_HEAD" > "$RUN/previous-checkout.txt"
printf '%s\n' "$PREVIOUS_IMAGE" > "$RUN/previous-image.txt"
trap 'rc=$?; printf "exit=%s\n" "$rc" >> "$RUN/status.txt"; if [ "$rc" -ne 0 ]; then echo "Rollout stopped; inspect private evidence at $RUN" >&2; fi' EXIT
gitrepo fetch origin codex/alert-template-controls > "$RUN/fetch.log" 2>&1
test "$(gitrepo rev-parse FETCH_HEAD)" = "$PIN"
gitrepo merge-base --is-ancestor "$PREVIOUS_HEAD" "$PIN"
gitrepo archive "$PIN" backend | tar -xf - -C "$RUN"
cp "$REPO/backend/.env.test" "$RUN/backend/.env.test"
cp "$REPO/backend/serviceAccountKey.json" "$RUN/backend/serviceAccountKey.json"
chmod 600 "$RUN/backend/.env.test" "$RUN/backend/serviceAccountKey.json"
python3 - "$RUN/backend/serviceAccountKey.json" <<'PY'
import json,sys
v=json.load(open(sys.argv[1]))
assert not v.get('_local_build_fixture')
assert v.get('type') == 'external_account'
assert v.get('audience') == '//iam.googleapis.com/projects/1013709404616/locations/global/workloadIdentityPools/aws-test/providers/aws-provider'
assert v.get('token_url') == 'https://sts.googleapis.com/v1/token'
assert v.get('service_account_impersonation_url') == 'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/fcm-sender@alrt-test.iam.gserviceaccount.com:generateAccessToken'
assert v.get('credential_source', {}).get('environment_id') == 'aws1'
PY
IMAGE="alrt-test-templates:$PIN"
docker tag "$PREVIOUS_IMAGE" "alrt-test-rollback:$PIN"
docker build --label "org.opencontainers.image.revision=$PIN" -t "$IMAGE" "$RUN/backend" > "$RUN/build.log" 2>&1
docker run --rm --network none --entrypoint node "$IMAGE" -e 'const fs=require("fs"); if(fs.readdirSync("/app").some(x=>x.startsWith(".env")||x.endsWith(".dump")||x.includes("placeholder-bak")))process.exit(1)'
APPDB=$(docker exec postgres-test sh -c 'printf %s "$POSTGRES_DB"')
run_new() { docker run --rm --network backend_default --env-file "$RUN/backend/.env.test" -e "ALRT_EXPECTED_TEST_DATABASE=$APPDB" --entrypoint "$1" "$IMAGE" "${@:2}"; }
run_new node -e 'const u=new URL(process.env.DATABASE_URL); if(process.env.NODE_ENV!=="test"||process.env.RC_EXPECTED_ENVIRONMENT!=="SANDBOX"||process.env.FIREBASE_PROJECT_ID!=="alrt-test"||u.hostname!=="postgres"||(u.port&&u.port!=="5432")||decodeURIComponent(u.pathname.slice(1))!==process.env.ALRT_EXPECTED_TEST_DATABASE)process.exit(1)'
psql_db() { docker exec -i -e TARGET_DB="$1" postgres-test sh -c 'psql -U "$POSTGRES_USER" -d "$TARGET_DB" -Atq -v ON_ERROR_STOP=1'; }
test "$(printf 'select count(*) from _prisma_migrations where finished_at is null or rolled_back_at is not null;' | psql_db "$APPDB")" = 0
printf 'select migration_name from _prisma_migrations order by migration_name;' | psql_db "$APPDB" > "$RUN/ledger-before.txt"
find "$RUN/backend/prisma/migrations" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort > "$RUN/image-migrations.txt"
comm -23 "$RUN/ledger-before.txt" "$RUN/image-migrations.txt" > "$RUN/missing-from-image.txt"
test ! -s "$RUN/missing-from-image.txt"
comm -13 "$RUN/ledger-before.txt" "$RUN/image-migrations.txt" > "$RUN/pending.txt"
test "$(cat "$RUN/pending.txt")" = "$MIGRATION"
test "$(printf 'select count(*) from information_schema.columns where table_name = '\''Hazard'\'' and column_name in ('\''contentDetails'\'','\''nativeWarningLevel'\'','\''jurisdictionCountry'\'','\''sourceContentHash'\'');' | psql_db "$APPDB")" = 0
# Custom archive, then actual restore to an absent scratch database. Existing
# backups and application data are never overwritten by this verification.
SCRATCH="alrt_template_restore_$(date -u +%Y%m%d%H%M%S)_$$"
test "$SCRATCH" != "$APPDB"
test "$(printf "select count(*) from pg_database where datname='%s';" "$SCRATCH" | psql_db "$APPDB")" = 0
printf '%s\n' "$SCRATCH" > "$RUN/scratch-db.txt"
docker exec postgres-test sh -c 'pg_dump -U "$POSTGRES_USER" -Fc "$POSTGRES_DB"' > "$RUN/database.dump"
test -s "$RUN/database.dump"
docker exec -e SCRATCH="$SCRATCH" postgres-test sh -c 'createdb -U "$POSTGRES_USER" "$SCRATCH"'
docker exec -i -e SCRATCH="$SCRATCH" postgres-test sh -c 'pg_restore -U "$POSTGRES_USER" -d "$SCRATCH" --no-owner --exit-on-error' < "$RUN/database.dump" > "$RUN/restore.log" 2>&1
fingerprint() {
  printf 'select (select count(*) from "FamilyCircle") || '\'', '\'' || (select count(*) from "FamilyMember") || '\'', '\'' || (select count(*) from "User") || '\'', '\'' || (select count(*) from information_schema.tables where table_schema='\''public'\'') || '\'', '\'' || (select count(*) from _prisma_migrations);' | psql_db "$1"
}
fingerprint "$APPDB" > "$RUN/source-counts.txt"
fingerprint "$SCRATCH" > "$RUN/restored-counts.txt"
# The live app may receive new rows after pg_dump's consistent snapshot.
# Counts are diagnostic only. Require successful full restore and identical
# schema/ledger, which ordinary app writes do not change.
schema_fingerprint() {
  printf 'select table_name || '\'':'\'' || column_name || '\'':'\'' || data_type || '\'':'\'' || is_nullable from information_schema.columns where table_schema='\''public'\'' order by table_name, ordinal_position;' | psql_db "$1"
}
schema_fingerprint "$APPDB" > "$RUN/source-schema.txt"
schema_fingerprint "$SCRATCH" > "$RUN/restored-schema.txt"
cmp "$RUN/source-schema.txt" "$RUN/restored-schema.txt"
printf 'select migration_name from _prisma_migrations order by migration_name;' | psql_db "$SCRATCH" > "$RUN/restored-ledger.txt"
cmp "$RUN/ledger-before.txt" "$RUN/restored-ledger.txt"
test "$(cat "$RUN/scratch-db.txt")" = "$SCRATCH"
docker exec -e SCRATCH="$SCRATCH" postgres-test sh -c 'dropdb -U "$POSTGRES_USER" "$SCRATCH"'
echo 'Database backup restored and checked.'
assert_unchanged
printf 'select migration_name from _prisma_migrations order by migration_name;' | psql_db "$APPDB" > "$RUN/ledger-recheck.txt"
cmp "$RUN/ledger-before.txt" "$RUN/ledger-recheck.txt"
# Apply only the reviewed additive migration. No application process or jobs
# run in this temporary container. The new image then replaces app-test only.
run_new npx prisma migrate deploy > "$RUN/migrate.log" 2>&1
assert_unchanged
printf 'services:\n  app:\n    image: %s\n' "$IMAGE" > "$RUN/image.yml"
docker compose -p backend -f "$RUN/backend/docker-compose.test.yml" -f "$RUN/image.yml" up -d --no-build --no-deps app > "$RUN/start.log" 2>&1
for attempt in $(seq 1 30); do
  if curl -fsS --max-time 5 http://127.0.0.1:3010/api/test > "$RUN/health.json"; then break; fi
  sleep 2
done
curl -fsS --max-time 10 http://127.0.0.1:3010/api/test > "$RUN/health.json"
test "$(docker inspect --format '{{.Image}}' app-test)" = "$(docker image inspect --format '{{.Id}}' "$IMAGE")"
test "$(docker inspect --format '{{.RestartCount}}' app-test)" = 0
test "$(printf 'select count(*) from information_schema.columns where table_name = '\''Hazard'\'' and column_name in ('\''contentDetails'\'','\''nativeWarningLevel'\'','\''jurisdictionCountry'\'','\''sourceContentHash'\'');' | psql_db "$APPDB")" = 4
printf 'select migration_name from _prisma_migrations where finished_at is not null and rolled_back_at is null order by migration_name;' | psql_db "$APPDB" > "$RUN/ledger-after.txt"
cmp "$RUN/image-migrations.txt" "$RUN/ledger-after.txt"
docker inspect --format 'image={{.Image}} started={{.State.StartedAt}} restarts={{.RestartCount}}' app-test > "$RUN/running.txt"
echo "TEST rollout verified: $PIN; evidence $RUN"
# Rollback is application-only: start the recorded previous image with the
# same TEST env/project. Retain additive columns. Never restore the database
# over newer data as an automatic rollback.

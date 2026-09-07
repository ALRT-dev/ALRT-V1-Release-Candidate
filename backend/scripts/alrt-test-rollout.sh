#!/usr/bin/env bash
# ALRT TEST rollout, revision 5.
#
# Usage on the TEST host (alrt-test-api, i-0045a41694e315d45, ap-southeast-2), in the operator's SSM shell, one step
# per call, waiting for each step's output before the next:
#
#   bash alrt-test-rollout.sh preflight [--pin SHA]       read-only: environment, server revision, running image, ledger,
#                                                         existing backup, remote head (judged against --pin if given)
#   bash alrt-test-rollout.sh record --pin SHA            rollback tag + exact image ID, ledger snapshot; creates the run dir
#   bash alrt-test-rollout.sh deploy --pin SHA --apply-approved-migrations
#                                                         HTTPS fetch pinned to SHA, build, migration gate, fresh
#                                                         restore-tested backup, start, then prove migrations + image
#   bash alrt-test-rollout.sh verify                      image content, tooling, strict 40-check consent run, six regression
#                                                         scripts (stops at the first failure), health, ledger, container
#   bash alrt-test-rollout.sh inspect                     read-only state dump for failure reports
#
# --pin is the full 40-hex commit the owner approved for this rollout. It is an argument, not a constant, because the
# approved revision advances with approved UI commits; record writes it into the run directory and deploy/verify refuse
# to proceed against any other value.
#
# Guarantees: every step re-checks instance, region, repository and env before any write; preflight writes only into
# its own private directory and never touches the current run; every other write goes to a private (umask 077)
# per-run directory under /var/tmp/alrt-test-rollout; existing backups and earlier rollback records are never
# modified; scratch databases are uniquely named, verified absent beforehand and distinct from the app database, and
# only the one this run created is dropped; every exit code is recorded before the script stops; verification stops
# at the first failed script; nothing here rolls back, restores, or "fixes" anything.
set -euo pipefail
umask 077

# ----------------------------------------------------------------------------- fixed authorisation scope (not overridable)
readonly EXPECTED_INSTANCE="i-0045a41694e315d45"
readonly EXPECTED_REGION="ap-southeast-2"
readonly REPO="${ALRT_REPO:-/opt/alrt-test/repo}"
readonly REPO_URL="https://github.com/ALRT-dev/ALRT-V1-Release-Candidate.git"
readonly APPROVED_MIGRATIONS="20260904000000_family_check_in_request_targets 20260905000000_family_host_transition"
readonly EXISTING_BACKUP="/var/tmp/alrt-test-backup.IdoP62/database.dump"
readonly BASE="${ALRT_ROLLOUT_BASE:-/var/tmp/alrt-test-rollout}"
readonly EXTERNAL_HEALTH_URL="https://api-test.safetyalrt.com/api/test"
readonly INTERNAL_HEALTH_URL="http://127.0.0.1:3010/api/test"
# Files whose content must be byte-identical between the checked-out revision and the running image.
readonly CONTENT_FILES="src/services/family.service.ts src/controllers/family.controller.ts src/scripts/verify_family_location_consent.ts package.json prisma/migrations/20260904000000_family_check_in_request_targets/migration.sql prisma/migrations/20260905000000_family_host_transition/migration.sql"
readonly REGRESSION_SCRIPTS="verify_checkin_request_location_privacy verify_sos_history verify_stage9a_journey_recipient verify_targeted_check_in_request verify_circle_list_state verify_seat_rule"

# ----------------------------------------------------------------------------- tool shims (stand-in testing only)
DOCKER="${ALRT_DOCKER:-sudo docker}"
GIT="${ALRT_GIT:-git}"
CURL="${ALRT_CURL:-curl}"
IMDS="${ALRT_IMDS:-http://169.254.169.254}"
SLEEP_AFTER_UP="${ALRT_SLEEP_AFTER_UP:-12}"

RUN_DIR=""
PIN=""
APPLY_MIGRATIONS=0

# Always to stderr; also to the run log once a run directory exists. Never fails when there is no directory yet.
log() {
  local line; line="$(date -u +%FT%TZ) $*"
  printf '%s\n' "$line" >&2
  if [ -n "$RUN_DIR" ] && [ -d "$RUN_DIR" ]; then printf '%s\n' "$line" >> "$RUN_DIR/rollout.log"; fi
}
note() { [ -n "$RUN_DIR" ] && [ -d "$RUN_DIR" ] && printf '%s\n' "$*" >> "$RUN_DIR/status.txt"; return 0; }
# Any command that fails under set -e is recorded with its exit code, line and command text before the script dies.
on_err() { local rc=$1 line=$2 cmd=$3; note "ERR exit=$rc line=$line cmd=$cmd"; log "ERR: exit $rc at line $line: $cmd"; }
trap 'on_err $? $LINENO "$BASH_COMMAND"' ERR
stop() { note "STOP $*"; log "STOP: $*"; exit 1; }
dc()   { (cd "$REPO/backend" && $DOCKER compose -f docker-compose.test.yml "$@"); }

# psql against a named database inside postgres-test; SQL arrives on stdin so no shell-level quoting is ever needed.
psql_db() { $DOCKER exec -i -e TARGET_DB="$1" postgres-test sh -c 'psql -U "$POSTGRES_USER" -d "$TARGET_DB" -Atq -v ON_ERROR_STOP=1'; }
app_db()  { $DOCKER exec postgres-test sh -c 'printf %s "$POSTGRES_DB"'; }

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --pin) [ -n "${2:-}" ] || stop "--pin needs a value"; PIN="$2"; shift 2 ;;
      --apply-approved-migrations) APPLY_MIGRATIONS=1; shift ;;
      *) stop "unknown argument: $1" ;;
    esac
  done
  if [ -n "$PIN" ]; then
    printf '%s' "$PIN" | grep -qE '^[0-9a-f]{40}$' || stop "--pin must be the full 40-hex commit SHA, got '$PIN'"
  fi
}
require_pin() { [ -n "$PIN" ] || stop "this step requires --pin <full 40-hex approved commit SHA>"; }

# ----------------------------------------------------------------------------- environment enforcement (before any write)
enforce_environment() {
  local token iid region
  token=$($CURL -sS -m 5 -X PUT "$IMDS/latest/api/token" -H 'X-aws-ec2-metadata-token-ttl-seconds: 60') || stop "IMDS token unavailable; cannot prove which instance this is"
  iid=$($CURL -sS -m 5 -H "X-aws-ec2-metadata-token: $token" "$IMDS/latest/meta-data/instance-id") || stop "IMDS instance-id unavailable"
  region=$($CURL -sS -m 5 -H "X-aws-ec2-metadata-token: $token" "$IMDS/latest/meta-data/placement/region") || stop "IMDS region unavailable"
  [ "$iid" = "$EXPECTED_INSTANCE" ] || stop "this is instance $iid, not $EXPECTED_INSTANCE"
  [ "$region" = "$EXPECTED_REGION" ] || stop "this is region $region, not $EXPECTED_REGION"
  [ -d "$REPO/.git" ] || stop "repository $REPO not found"
  [ -f "$REPO/backend/docker-compose.test.yml" ] || stop "docker-compose.test.yml missing"
  [ -f "$REPO/backend/.env.test" ] || stop ".env.test missing"
  grep -qE '^NODE_ENV=test[[:space:]]*$' "$REPO/backend/.env.test" || stop ".env.test is not NODE_ENV=test"
  $DOCKER inspect --format '{{.Name}}' app-test >/dev/null 2>&1 || stop "container app-test not found"
  $DOCKER inspect --format '{{.Name}}' postgres-test >/dev/null 2>&1 || stop "container postgres-test not found"
}

# A private directory for this invocation. Only 'record' registers it as the current run; preflight's directory is
# never registered, so preflight can be re-run at any time without disturbing a run in progress.
new_private_dir() {  # $1 = prefix
  mkdir -p "$BASE"; chmod 700 "$BASE"
  RUN_DIR="$BASE/$1-$(date -u +%Y%m%d%H%M%S)-$$"
  mkdir "$RUN_DIR"; chmod 700 "$RUN_DIR"
  log "$1 directory: $RUN_DIR (mode 700)"
}
register_current_run() { printf '%s\n' "$RUN_DIR" > "$BASE/current-run"; chmod 600 "$BASE/current-run"; }
current_run_dir() {
  [ -s "$BASE/current-run" ] || stop "no current run; run 'record --pin SHA' first"
  RUN_DIR=$(cat "$BASE/current-run"); [ -d "$RUN_DIR" ] || stop "run directory $RUN_DIR missing"
}
recorded_pin() { [ -s "$RUN_DIR/pin.txt" ] || stop "no pin recorded in $RUN_DIR; run 'record --pin SHA' first"; cat "$RUN_DIR/pin.txt"; }

remote_head() {
  local head
  head=$($GIT ls-remote "$REPO_URL" refs/heads/test | awk '{print $1}') || stop "HTTPS ls-remote failed"
  [ -n "$head" ] || stop "could not read refs/heads/test over HTTPS"
  printf '%s\n' "$head"
}
remote_head_must_equal_pin() {
  local head; head=$(remote_head)
  printf '%s\n' "$head" > "$RUN_DIR/remote-head.txt"
  [ "$head" = "$PIN" ] || stop "remote test head is $head, not the approved $PIN. Newer commits exist; nothing was changed."
  log "remote test head = approved revision $PIN"
}

ledger_snapshot() {  # $1 = output file
  psql_db "$(app_db)" > "$1" <<'SQL'
select migration_name, finished_at is not null as finished, rolled_back_at is not null as rolled_back, applied_steps_count
from _prisma_migrations order by started_at desc nulls last limit 8;
SQL
}
ledger_must_be_clean() {  # no failed or rolled-back migrations
  local bad
  bad=$(psql_db "$(app_db)" <<'SQL'
select count(*) from _prisma_migrations where finished_at is null or rolled_back_at is not null;
SQL
)
  [ "$bad" = "0" ] || stop "migration ledger has $bad failed or rolled-back entries; unexpected database state"
}
# The two approved migrations, as ledger rows: name:finished:not_rolled_back:steps
approved_rows() {
  psql_db "$1" <<'SQL'
-- explicit t/f: a boolean concatenated with || renders as 'true'/'false', not psql's bare t/f (found by the real-Postgres harness)
select migration_name || ':' || case when finished_at is not null then 't' else 'f' end
    || ':' || case when rolled_back_at is null then 't' else 'f' end || ':' || applied_steps_count
from _prisma_migrations
where migration_name in ('20260904000000_family_check_in_request_targets','20260905000000_family_host_transition')
order by migration_name;
SQL
}
# The three columns those migrations add. 3 = both applied and present, 0 = neither.
approved_columns_present() {
  psql_db "$1" <<'SQL'
select count(*) from information_schema.columns
where table_schema = 'public'
  and ((table_name = 'FamilyCheckInRequest' and column_name = 'targetMemberIds')
    or (table_name = 'FamilyCircle' and column_name in ('hostTransitionStartedAt', 'hostTransitionHostName')));
SQL
}
# Row counts + table count + ledger size, for comparing a restore against its source.
db_fingerprint() {
  psql_db "$1" <<'SQL'
select (select count(*) from "FamilyCircle") || ',' || (select count(*) from "FamilyMember") || ',' || (select count(*) from "User")
    || ',' || (select count(*) from information_schema.tables where table_schema = 'public')
    || ',' || (select count(*) from _prisma_migrations);
SQL
}

container_state() { $DOCKER inspect --format 'status={{.State.Status}} image={{.Image}} started={{.State.StartedAt}} restarts={{.RestartCount}} exit={{.State.ExitCode}}' app-test; }

# ============================================================================= preflight (read-only)
preflight() {
  enforce_environment; new_private_dir preflight; note "step=preflight pin=${PIN:-none}"
  local head; head=$(remote_head); printf '%s\n' "$head" > "$RUN_DIR/remote-head.txt"
  if [ -n "$PIN" ]; then
    [ "$head" = "$PIN" ] && log "remote test head = approved revision $PIN" || log "WARNING: remote test head is $head, not the given pin $PIN (newer commits exist; deploy will refuse)"
  else
    log "remote test head is $head (no --pin given, not judged)"
  fi
  ( cd "$REPO"; $GIT rev-parse HEAD; $GIT log -1 --format='%h %ci %s'; $GIT status --short ) > "$RUN_DIR/server-revision.txt" 2>&1 || true
  container_state > "$RUN_DIR/running-container.txt"
  ledger_snapshot "$RUN_DIR/ledger-before.txt"
  printf 'approved columns present (expect 0 before, 3 after): %s\n' "$(approved_columns_present "$(app_db)")" > "$RUN_DIR/schema-columns.txt"
  if [ -e "$EXISTING_BACKUP" ]; then
    { ls -l "$EXISTING_BACKUP"; ls -ld "$(dirname "$EXISTING_BACKUP")"; } > "$RUN_DIR/existing-backup.txt" 2>&1
    if [ ! -r "$EXISTING_BACKUP" ]; then
      printf 'not readable by %s; pg_restore --list not attempted. Restore-tested: NO.\n' "$(id -un)" >> "$RUN_DIR/existing-backup.txt"
    elif $DOCKER exec -i postgres-test sh -c 'pg_restore --list >/dev/null' < "$EXISTING_BACKUP" 2>>"$RUN_DIR/existing-backup.txt"; then
      printf 'pg_restore --list: readable custom-format archive. Restore-tested: NO (this run does not restore it; deploy restore-tests a FRESH dump).\n' >> "$RUN_DIR/existing-backup.txt"
    else
      printf 'pg_restore --list: not a readable custom-format archive (plain SQL, or corrupt). Restore-tested: NO.\n' >> "$RUN_DIR/existing-backup.txt"
    fi
  else
    printf 'not present at %s\n' "$EXISTING_BACKUP" > "$RUN_DIR/existing-backup.txt"
  fi
  log "preflight complete; nothing was changed (current run, if any, untouched)"
  echo "---- remote test head";               cat "$RUN_DIR/remote-head.txt"
  echo "---- server revision / status";       cat "$RUN_DIR/server-revision.txt"
  echo "---- running container";              cat "$RUN_DIR/running-container.txt"
  echo "---- migration ledger (newest first)"; cat "$RUN_DIR/ledger-before.txt"
  echo "---- schema";                          cat "$RUN_DIR/schema-columns.txt"
  echo "---- existing backup $EXISTING_BACKUP"; cat "$RUN_DIR/existing-backup.txt"
}

# ============================================================================= record (rollback point)
record() {
  require_pin
  enforce_environment; new_private_dir run; register_current_run; note "step=record pin=$PIN"
  printf '%s\n' "$PIN" > "$RUN_DIR/pin.txt"
  remote_head_must_equal_pin
  cd "$REPO"
  $GIT rev-parse HEAD | tee "$RUN_DIR/rev.txt"
  $GIT log -1 --format='%h %ci %s' | tee -a "$RUN_DIR/rev.txt"
  $GIT status --short | tee "$RUN_DIR/status-short.txt"
  [ ! -s "$RUN_DIR/status-short.txt" ] || stop "local changes present in $REPO; report before continuing"
  dc ps | tee "$RUN_DIR/ps.txt"
  local running_id stamp tag
  running_id=$($DOCKER inspect --format '{{.Image}}' app-test)
  stamp=$(date -u +%Y%m%d%H%M%S)
  tag="alrt-app-test:rollback-$stamp"
  $DOCKER tag "$running_id" "$tag"
  printf '%s\n' "$tag" > "$RUN_DIR/rollback-tag.txt"
  $DOCKER inspect --format '{{.Id}}' "$tag" > "$RUN_DIR/rollback-image-id.txt"
  [ "$(cat "$RUN_DIR/rollback-image-id.txt")" = "$running_id" ] || stop "rollback tag does not resolve to the running image"
  container_state > "$RUN_DIR/container-before.txt"
  dc logs --tail=200 app > "$RUN_DIR/app-before.log" 2>&1 || true
  ledger_snapshot "$RUN_DIR/ledger-before.txt"
  ledger_must_be_clean
  printf 'approved columns present before: %s\n' "$(approved_columns_present "$(app_db)")" | tee "$RUN_DIR/schema-columns-before.txt"
  log "rollback point recorded: $tag = $running_id (ledger + schema state alongside it)"
  echo "run dir: $RUN_DIR"; echo "rollback tag: $tag"; echo "rollback image id: $running_id"; echo "ledger (newest first):"; cat "$RUN_DIR/ledger-before.txt"
}

# ============================================================================= deploy
deploy() {
  require_pin
  [ "$APPLY_MIGRATIONS" = 1 ] || stop "deploy requires --apply-approved-migrations (owner-approved list: $APPROVED_MIGRATIONS)"
  enforce_environment; current_run_dir; note "step=deploy pin=$PIN"
  [ "$(recorded_pin)" = "$PIN" ] || stop "--pin $PIN differs from the pin recorded in this run ($(recorded_pin)); run 'record' again for a new pin"
  [ -s "$RUN_DIR/rollback-tag.txt" ] && [ -s "$RUN_DIR/rollback-image-id.txt" ] || stop "record has not completed in this run directory"
  grep -q '^deploy=ok$' "$RUN_DIR/status.txt" && stop "deploy already completed in this run; start a new run with 'record' if a redeploy is intended"
  remote_head_must_equal_pin
  cd "$REPO"
  [ -z "$($GIT status --short)" ] || stop "local changes present"
  local rollback_id; rollback_id=$(cat "$RUN_DIR/rollback-image-id.txt")
  [ "$($DOCKER inspect --format '{{.Image}}' app-test)" = "$rollback_id" ] || stop "running image changed since record; re-run record"

  # ---- 4a pin over HTTPS; the SSH origin remote is never used or edited
  $GIT fetch "$REPO_URL" test
  local fetched; fetched=$($GIT rev-parse FETCH_HEAD)
  [ "$fetched" = "$PIN" ] || stop "FETCH_HEAD is $fetched, expected $PIN"
  $GIT log --oneline "HEAD..FETCH_HEAD" > "$RUN_DIR/incoming.txt" || true
  $GIT checkout --detach "$PIN"
  [ "$($GIT rev-parse HEAD)" = "$PIN" ] || stop "checkout did not land on the approved revision"
  $GIT diff --stat "$(head -1 "$RUN_DIR/rev.txt")" HEAD -- backend > "$RUN_DIR/backend-diff.txt" || true
  local f; for f in $CONTENT_FILES; do [ -f "$REPO/backend/$f" ] || stop "expected file missing from the checked-out revision: backend/$f"; done
  log "checked out $PIN (detached)"

  # ---- 4b build; both pipeline statuses captured before anything can exit
  local build_started; build_started=$(date -u +%s)
  set +e
  dc build app 2>&1 | tee "$RUN_DIR/build.log"
  local build_status=("${PIPESTATUS[@]}")
  set -e
  local build_exit=${build_status[0]} tee_exit=${build_status[1]}
  printf 'build exit=%s tee exit=%s\n' "$build_exit" "$tee_exit" >> "$RUN_DIR/build.log"
  note "build exit=$build_exit tee exit=$tee_exit"
  if [ "$build_exit" -ne 0 ] || [ "$tee_exit" -ne 0 ]; then
    container_state >> "$RUN_DIR/status.txt" 2>&1 || true
    stop "image build failed (build exit $build_exit, log exit $tee_exit); nothing deployed, running container unchanged (still $rollback_id)"
  fi
  # The NEW image: resolved by the image name compose gives the app service, never by the old container's image.
  local image_name built_id built_created
  image_name=$(dc config --images app 2>/dev/null | head -1)
  [ -n "$image_name" ] || stop "could not resolve the app service's image name from compose config"
  built_id=$($DOCKER image inspect --format '{{.Id}}' "$image_name") || stop "built image $image_name not found after build"
  built_created=$($DOCKER image inspect --format '{{.Created}}' "$image_name")
  printf 'image name=%s id=%s created=%s build started=%s\n' "$image_name" "$built_id" "$built_created" "$(date -u -d "@$build_started" +%FT%TZ 2>/dev/null || echo "$build_started")" | tee "$RUN_DIR/built-image.txt"
  [ "$built_id" != "$rollback_id" ] || stop "the build produced the very image already running ($built_id); nothing new to deploy — report before continuing"
  local created_epoch; created_epoch=$(date -u -d "$built_created" +%s 2>/dev/null || echo 0)
  if [ "$created_epoch" -gt 0 ] && [ "$created_epoch" -lt "$((build_started - 60))" ]; then
    stop "image $image_name was created at $built_created, before this build started; refusing to treat it as the new image"
  fi
  printf '%s\n' "$built_id" > "$RUN_DIR/built-image-id.txt"
  log "built image: $image_name = $built_id"

  # ---- 4c migration gate: status AND list, read from the new image without applying anything
  set +e
  dc run --rm --no-deps app node_modules/.bin/prisma migrate status > "$RUN_DIR/migrate-status.txt" 2>&1
  local status_exit=$?
  set -e
  note "migrate status exit=$status_exit"
  grep -qiE "P1001|P1000|Can't reach database|connection refused|ECONNREFUSED|Authentication failed" "$RUN_DIR/migrate-status.txt" && stop "prisma could not reach or authenticate to the database (see migrate-status.txt)"
  grep -qiE "failed migration|migration.*failed|rolled back" "$RUN_DIR/migrate-status.txt" && stop "prisma reports failed or rolled-back migrations (see migrate-status.txt)"
  grep -qiE "database schema is up to date" "$RUN_DIR/migrate-status.txt" && stop "image reports no pending migrations but the approved list expects two"
  local pending expected
  pending=$(awk '/have not yet been applied/{f=1;next} f&&/^[0-9]{14}_/{print $1} f&&/^[[:space:]]*$/{f=0}' "$RUN_DIR/migrate-status.txt" | sort | tr '\n' ' ' | sed 's/ $//')
  expected=$(printf '%s\n' $APPROVED_MIGRATIONS | sort | tr '\n' ' ' | sed 's/ $//')
  printf 'pending=[%s]\napproved=[%s]\n' "$pending" "$expected" | tee "$RUN_DIR/pending-migrations.txt"
  [ -n "$pending" ] || stop "could not parse a pending-migration list from migrate status (exit $status_exit)"
  [ "$pending" = "$expected" ] || stop "pending migrations differ from the approved list; nothing applied"
  ledger_must_be_clean
  local appdb; appdb=$(app_db); [ -n "$appdb" ] || stop "could not read the application database name"
  [ "$(approved_columns_present "$appdb")" = "0" ] || stop "some approved columns already exist although the ledger says the migrations are pending; unexpected schema state"
  log "migration gate passed: exactly the approved migrations are pending"

  # ---- 4d fresh backup, restore-tested into a uniquely named scratch database (the app database is only read)
  local scratch backup existing
  scratch="alrt_restore_check_$(date -u +%Y%m%d%H%M%S)_$$"
  [ "$scratch" != "$appdb" ] || stop "scratch name collides with the application database"
  existing=$(psql_db "$appdb" <<'SQL'
select datname from pg_database;
SQL
)
  printf '%s\n' "$existing" | grep -qx "$scratch" && stop "scratch database $scratch already exists; refusing to touch it"
  printf '%s\n' "$existing" > "$RUN_DIR/databases-before.txt"
  backup="$RUN_DIR/alrt-test-backup-$(date -u +%Y%m%d%H%M%S).dump"
  $DOCKER exec postgres-test sh -c 'pg_dump -U "$POSTGRES_USER" -Fc "$POSTGRES_DB"' > "$backup"
  [ -s "$backup" ] || stop "fresh dump is empty"
  chmod 600 "$backup"; printf '%s\n' "$backup" > "$RUN_DIR/backup-file.txt"; ls -l "$backup" | tee -a "$RUN_DIR/status.txt"
  printf '%s\n' "$scratch" > "$RUN_DIR/scratch-db.txt"
  $DOCKER exec -e SCRATCH="$scratch" postgres-test sh -c 'createdb -U "$POSTGRES_USER" "$SCRATCH"'
  local restore_exit
  set +e
  $DOCKER exec -i -e SCRATCH="$scratch" postgres-test sh -c 'pg_restore -U "$POSTGRES_USER" -d "$SCRATCH" --no-owner --exit-on-error' < "$backup" > "$RUN_DIR/restore.log" 2>&1
  restore_exit=$?
  set -e
  note "restore exit=$restore_exit"
  local orig copy
  orig=$(db_fingerprint "$appdb")
  copy=$(db_fingerprint "$scratch" 2>>"$RUN_DIR/restore.log" || echo "unreadable")
  printf 'restore check (FamilyCircle,FamilyMember,User,tables,ledger rows): original=%s restored=%s restore exit=%s\n' "$orig" "$copy" "$restore_exit" | tee "$RUN_DIR/restore-check.txt"
  # drop only the scratch database this run created (name recorded above, verified absent before and distinct from the app db)
  [ "$(cat "$RUN_DIR/scratch-db.txt")" = "$scratch" ] && [ "$scratch" != "$appdb" ] && \
    $DOCKER exec -e SCRATCH="$scratch" postgres-test sh -c 'dropdb -U "$POSTGRES_USER" "$SCRATCH"'
  [ "$restore_exit" -eq 0 ] || stop "pg_restore exited $restore_exit (see restore.log); the fresh backup is not trustworthy"
  [ "$orig" = "$copy" ] || stop "restore test mismatch; the fresh backup is not trustworthy"
  printf '%s\n' "$existing" | grep -qx "$scratch" && stop "internal: scratch listed before creation"
  log "fresh backup $backup restore-tested (fingerprint $copy) and scratch database $scratch dropped"

  # ---- 4e start (container command runs prisma migrate deploy first)
  set +e
  dc up -d app 2>&1 | tee "$RUN_DIR/up.log"
  local up_status=("${PIPESTATUS[@]}")
  set -e
  local up_exit=${up_status[0]}
  sleep "$SLEEP_AFTER_UP"
  set +e
  container_state > "$RUN_DIR/container-after.txt" 2>&1
  $DOCKER inspect --format '{{.Image}}' app-test > "$RUN_DIR/deployed-image-id.txt" 2>/dev/null
  dc logs --tail=150 app > "$RUN_DIR/app-after.log" 2>&1
  $CURL -sf -m 10 "$INTERNAL_HEALTH_URL" > "$RUN_DIR/health-internal.txt" 2>&1; local health_exit=$?
  grep -q "server is running at PORT:9000" "$RUN_DIR/app-after.log"; local ready_exit=$?
  ledger_snapshot "$RUN_DIR/ledger-after.txt" 2>>"$RUN_DIR/status.txt"; local ledger_exit=$?
  set -e
  printf 'up exit=%s health exit=%s ready-line exit=%s ledger exit=%s\n' "$up_exit" "$health_exit" "$ready_exit" "$ledger_exit" | tee "$RUN_DIR/start-status.txt" | tee -a "$RUN_DIR/status.txt"
  cat "$RUN_DIR/container-after.txt"
  if [ "$up_exit" -ne 0 ] || [ "$health_exit" -ne 0 ] || [ "$ready_exit" -ne 0 ] || [ "$ledger_exit" -ne 0 ]; then
    log "running image: $(cat "$RUN_DIR/deployed-image-id.txt" 2>/dev/null || echo unknown); rollback image: $rollback_id; built image: $built_id"
    stop "startup failed after 'up' (build succeeded). The previous container may already have been replaced. Do not roll back automatically; run 'inspect' and report."
  fi

  # ---- post-start proof: both migrations finished and not rolled back, columns present, running image is the built image
  local rows
  rows=$(approved_rows "$appdb")
  printf '%s\n' "$rows" | tee "$RUN_DIR/migrations-applied.txt"
  [ "$(printf '%s\n' "$rows" | grep -c .)" = "2" ] || stop "expected both approved migrations in the ledger; found: $rows"
  printf '%s\n' "$rows" | grep -qvE ':t:t:[0-9]+$' && stop "a migration is unfinished or rolled back: $rows"
  local cols; cols=$(approved_columns_present "$appdb"); printf 'approved columns present after: %s\n' "$cols" | tee "$RUN_DIR/schema-columns-after.txt"
  [ "$cols" = "3" ] || stop "expected the 3 approved columns after migration, found $cols"
  set +e
  dc exec -T app node_modules/.bin/prisma migrate status > "$RUN_DIR/migrate-status-after.txt" 2>&1; local after_exit=$?
  set -e
  note "migrate status after exit=$after_exit"
  grep -qi "database schema is up to date" "$RUN_DIR/migrate-status-after.txt" || stop "prisma does not report an up-to-date schema after deploy (see migrate-status-after.txt)"
  local running_id; running_id=$(cat "$RUN_DIR/deployed-image-id.txt")
  [ "$running_id" = "$built_id" ] || stop "running image $running_id is not the image built this run ($built_id)"
  grep -E "Scheduled jobs are OFF for TEST|Scheduled tasks|scheduled" "$RUN_DIR/app-after.log" | head -3 > "$RUN_DIR/scheduler-observed.txt" || true
  note "deploy=ok"
  log "deployed $PIN; running image = built image $built_id; both migrations finished; 3 columns present; scheduler line: $(head -1 "$RUN_DIR/scheduler-observed.txt")"
}

# ============================================================================= verify
verify() {
  enforce_environment; current_run_dir; note "step=verify"
  grep -q '^deploy=ok$' "$RUN_DIR/status.txt" || stop "deploy did not complete in this run"
  local pin; pin=$(recorded_pin)
  [ "$(cd "$REPO" && $GIT rev-parse HEAD)" = "$pin" ] || stop "server checkout is not the recorded pin $pin"
  local V="$RUN_DIR/verify"; mkdir -p "$V"; chmod 700 "$V"
  : > "$V/summary.txt"

  # image content matches the checked-out revision for the files this rollout changed (not just a phrase)
  local f local_sum image_sum
  for f in $CONTENT_FILES; do
    local_sum=$( (cd "$REPO/backend" && sha256sum "$f") | awk '{print $1}')
    image_sum=$(dc exec -T app sha256sum "$f" | awk '{print $1}')
    printf '%s local=%s image=%s\n' "$f" "$local_sum" "$image_sum" >> "$V/image-content.txt"
    [ "$local_sum" = "$image_sum" ] || stop "image content differs from the checked-out revision for $f"
  done
  [ "$($DOCKER inspect --format '{{.Image}}' app-test)" = "$(cat "$RUN_DIR/built-image-id.txt")" ] || stop "running image is no longer the built image"
  dc exec -T app sh -c 'test -x node_modules/.bin/tsx && node -e "require.resolve(\"socket.io-client\"); require.resolve(\"@prisma/client\")"' || stop "verification tooling missing from the image"
  log "image content and tooling verified"

  # strict 40-check consent run; exit code captured and recorded, then judged immediately
  local consent_exit
  set +e
  dc exec -T -e NODE_ENV=test -e TEST_SERVER_URL=http://localhost:9000 -e EXPECT_SUBURB_LABEL=1 app node_modules/.bin/tsx src/scripts/verify_family_location_consent.ts > "$V/consent.log" 2>&1
  consent_exit=$?
  set -e
  printf 'consent exit=%s last=%s\n' "$consent_exit" "$(tail -1 "$V/consent.log")" | tee -a "$V/summary.txt" | tee -a "$RUN_DIR/status.txt"
  if [ "$consent_exit" -ne 0 ] || ! grep -q "All 40 checks passed." "$V/consent.log"; then
    tail -25 "$V/consent.log"
    stop "consent verification failed (exit $consent_exit); stopping before any regression script. Privacy on TEST is NOT verified. Report before any recovery."
  fi

  local s r_exit
  for s in $REGRESSION_SCRIPTS; do
    set +e
    dc exec -T -e NODE_ENV=test -e TEST_SERVER_URL=http://localhost:9000 app node_modules/.bin/tsx "src/scripts/$s.ts" > "$V/$s.log" 2>&1
    r_exit=$?
    set -e
    printf '%s exit=%s last=%s\n' "$s" "$r_exit" "$(tail -1 "$V/$s.log")" | tee -a "$V/summary.txt" | tee -a "$RUN_DIR/status.txt"
    if [ "$r_exit" -ne 0 ] || ! grep -qE "checks passed\." "$V/$s.log"; then
      tail -25 "$V/$s.log"
      stop "$s failed (exit $r_exit); stopping at the first failure. Privacy on TEST is NOT verified. Report before any recovery."
    fi
  done

  # health, migration state, schema, running image, scheduler: all recorded, then judged
  set +e
  $CURL -sf -m 10 "$INTERNAL_HEALTH_URL" > "$V/health-internal.txt" 2>&1; local hi=$?
  $CURL -s -m 15 -o "$V/health-external.txt" -w '%{http_code}' "$EXTERNAL_HEALTH_URL" > "$V/health-external-code.txt" 2>&1; local he=$?
  set -e
  printf 'internal health exit=%s external health curl exit=%s http=%s\n' "$hi" "$he" "$(cat "$V/health-external-code.txt" 2>/dev/null)" | tee -a "$V/summary.txt" | tee -a "$RUN_DIR/status.txt"
  ledger_snapshot "$V/ledger.txt"
  local appdb; appdb=$(app_db)
  approved_rows "$appdb" > "$V/migrations-applied.txt"
  printf 'approved columns present: %s\n' "$(approved_columns_present "$appdb")" > "$V/schema-columns.txt"
  cp "$RUN_DIR/scheduler-observed.txt" "$V/scheduler-observed.txt" 2>/dev/null || true
  container_state > "$V/container.txt"

  local fail=0
  [ "$hi" -eq 0 ] || fail=1
  [ "$(cat "$V/health-external-code.txt" 2>/dev/null)" = "200" ] || fail=1
  [ "$(grep -c . "$V/migrations-applied.txt")" = "2" ] && ! grep -qvE ':t:t:[0-9]+$' "$V/migrations-applied.txt" || fail=1
  grep -q 'present: 3$' "$V/schema-columns.txt" || fail=1
  grep -q 'status=running' "$V/container.txt" || fail=1
  echo "==== summary ($V/summary.txt)"; cat "$V/summary.txt"; echo "==== migrations"; cat "$V/migrations-applied.txt"; cat "$V/schema-columns.txt"; echo "==== container"; cat "$V/container.txt"; echo "==== scheduler"; cat "$V/scheduler-observed.txt" 2>/dev/null
  [ "$fail" -eq 0 ] || stop "verification incomplete or failed; see $V. Privacy on TEST is NOT verified. Report before any recovery."
  note "verify=ok"
  log "verification passed: 40/40 consent checks, six regression scripts exit 0, internal and external health OK, migrations finished, columns present"
}

# ============================================================================= inspect (read-only)
inspect() {
  enforce_environment
  if [ -s "$BASE/current-run" ]; then RUN_DIR=$(cat "$BASE/current-run"); fi
  echo "run dir: ${RUN_DIR:-none}"; [ -n "$RUN_DIR" ] && { echo "---- status.txt"; cat "$RUN_DIR/status.txt" 2>/dev/null; }
  echo "---- compose"; dc ps
  echo "---- container"; container_state
  [ -n "$RUN_DIR" ] && { echo "pin: $(cat "$RUN_DIR/pin.txt" 2>/dev/null || echo none)"; echo "rollback image: $(cat "$RUN_DIR/rollback-image-id.txt" 2>/dev/null || echo none)"; echo "built image: $(cat "$RUN_DIR/built-image-id.txt" 2>/dev/null || echo none)"; }
  echo "---- ledger (newest first)"; ledger_snapshot /dev/stdout
  echo "---- approved columns present"; approved_columns_present "$(app_db)"
  echo "---- last 120 log lines"; dc logs --tail=120 app
  echo "---- internal health"; $CURL -s -o /dev/null -m 10 -w 'http=%{http_code}\n' "$INTERNAL_HEALTH_URL" || true
  # deliberately no writes: inspect is safe to run at any point, including after a stop
}

STEP="${1:-}"; shift || true
case "$STEP" in
  preflight|record|deploy|verify|inspect) parse_args "$@"; "$STEP" ;;
  *) echo "usage: bash $0 {preflight [--pin SHA]|record --pin SHA|deploy --pin SHA --apply-approved-migrations|verify|inspect}"; exit 2 ;;
esac

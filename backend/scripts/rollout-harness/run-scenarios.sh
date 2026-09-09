#!/usr/bin/env bash
# Exercises alrt-test-rollout.sh against stand-ins (control flow only; no docker, no network, nothing touches TEST).
# Usage: bash run-scenarios.sh            (prints PASS/FAIL per scenario, exits 1 on any FAIL)
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SCRIPT="$HERE/../alrt-test-rollout.sh"
BACKEND=$(cd "$HERE/../.." && pwd)
export FAKE_PIN="2222222222222222222222222222222222222222"
FAILS=0

# A fake repo with exactly the files the script reads, copied from the real backend so sha256 checks are meaningful.
FAKE_REPO=$(mktemp -d); export FAKE_REPO
mkdir -p "$FAKE_REPO/.git" "$FAKE_REPO/backend"
cp "$BACKEND/docker-compose.test.yml" "$FAKE_REPO/backend/"
printf 'NODE_ENV=test\n' > "$FAKE_REPO/backend/.env.test"
for f in src/services/family.service.ts src/controllers/family.controller.ts src/scripts/verify_family_location_consent.ts src/scripts/verify_targeted_check_in_request.ts src/scripts/verify_push_notification_settings.ts src/scripts/verify_family_leave_and_alert_link.ts src/scripts/verify_alert_filter_matrix.ts src/services/notification.service.ts src/services/user.service.ts src/utils/hazard.util.ts src/validators/family.validator.ts package.json \
         prisma/migrations/20260904000000_family_check_in_request_targets/migration.sql prisma/migrations/20260905000000_family_host_transition/migration.sql; do
  mkdir -p "$FAKE_REPO/backend/$(dirname "$f")"; cp "$BACKEND/$f" "$FAKE_REPO/backend/$f"
done

envfor() { # base
  echo "ALRT_REPO=$FAKE_REPO ALRT_ROLLOUT_BASE=$1/rollout ALRT_DOCKER=$HERE/bin/fake-docker ALRT_GIT=$HERE/bin/fake-git ALRT_CURL=$HERE/bin/fake-curl ALRT_IMDS=http://imds ALRT_SLEEP_AFTER_UP=0"
}
check() { # name, output, rc, expect
  if printf '%s' "$2" | grep -q -- "$4"; then echo "PASS [$1] exit=$3 :: $(printf '%s' "$2" | grep -- "$4" | tail -1 | cut -c1-150)"
  else echo "FAIL [$1] exit=$3 (expected: $4)"; printf '%s\n' "$2" | tail -6 | sed 's/^/    /'; FAILS=$((FAILS+1)); fi
}
one() { # name scenario expect step args...
  local name=$1 scen=$2 expect=$3; shift 3
  local base; base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"
  local out rc; out=$(env $(envfor "$base") SCENARIO="$scen" bash "$SCRIPT" "$@" 2>&1); rc=$?
  check "$name" "$out" "$rc" "$expect"; LAST_BASE="$base"
}
flow() { # name scenario expect  (record with pin, then deploy)
  local name=$1 scen=$2 expect=$3
  local base; base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"
  env $(envfor "$base") SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" >/dev/null 2>&1 || { echo "FAIL [$name] record"; FAILS=$((FAILS+1)); return; }
  local out rc; out=$(env $(envfor "$base") SCENARIO="$scen" bash "$SCRIPT" deploy --pin "$FAKE_PIN" "${MODE_FLAG:---apply-approved-migrations}" 2>&1); rc=$?
  check "$name" "$out" "$rc" "$expect"
  local rd; rd=$(cat "$base/rollout/current-run")
  echo "     status: $(tr '\n' '|' < "$rd/status.txt" | cut -c1-200)"
  [ -f "$FAKE_STATE/running" ] && echo "     running image now: $(cat "$FAKE_STATE/running")" || echo "     running image: unchanged (old)"
  [ -s "$FAKE_STATE/dbs" ] && { echo "     scratch database LEFT BEHIND: $(cat "$FAKE_STATE/dbs")"; FAILS=$((FAILS+1)); }
  LAST_BASE="$base"
}
uflow() { # name scenario expect [mode flags]  (database ALREADY migrated: record, then deploy under scenario)
  local name=$1 scen=$2 expect=$3; shift 3
  local base; base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"; touch "$FAKE_STATE/migrated"
  env $(envfor "$base") SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" >/dev/null 2>&1 || { echo "FAIL [$name] record"; FAILS=$((FAILS+1)); return; }
  local -a args; if [ $# -eq 0 ]; then args=(--no-new-migrations); elif [ "$1" = NOMODE ]; then args=(); else args=("$@"); fi
  local out rc; out=$(env $(envfor "$base") SCENARIO="$scen" bash "$SCRIPT" deploy --pin "$FAKE_PIN" "${args[@]}" 2>&1); rc=$?
  check "$name" "$out" "$rc" "$expect"
  local rd; rd=$(cat "$base/rollout/current-run")
  echo "     status: $(tr '\n' '|' < "$rd/status.txt" | cut -c1-200)"
  [ -f "$FAKE_STATE/running" ] && echo "     running image now: $(cat "$FAKE_STATE/running")" || echo "     running image: unchanged (old)"
  [ -s "$FAKE_STATE/dbs" ] && { echo "     scratch database LEFT BEHIND: $(cat "$FAKE_STATE/dbs")"; FAILS=$((FAILS+1)); }
  [ -f "$FAKE_STATE/applied-on-up" ] && [ "$scen" != "reapplied" ] && { echo "     a migration was applied during an update: BAD"; FAILS=$((FAILS+1)); }
  LAST_BASE="$base"
}
vflow() { # name scenario expect  (record + deploy clean, then verify under scenario)
  local name=$1 scen=$2 expect=$3
  local base; base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"
  env $(envfor "$base") SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" >/dev/null 2>&1 && env $(envfor "$base") SCENARIO= bash "$SCRIPT" deploy --pin "$FAKE_PIN" --apply-approved-migrations >/dev/null 2>&1 || { echo "FAIL [$name] setup"; FAILS=$((FAILS+1)); return; }
  local out rc; out=$(env $(envfor "$base") SCENARIO="$scen" bash "$SCRIPT" verify 2>&1); rc=$?
  check "$name" "$out" "$rc" "$expect"
  local rd; rd=$(cat "$base/rollout/current-run")
  echo "     summary: $(tr '\n' '|' < "$rd/verify/summary.txt" 2>/dev/null | cut -c1-220)"
  echo "     regression logs present: $(ls "$rd/verify" | grep -c '^verify_.*\.log$')"
  LAST_BASE="$base"
}

echo "== environment enforcement"
FAKE_INSTANCE=i-000wrong one "wrong instance" "" "this is instance i-000wrong" preflight
[ -e "$LAST_BASE/rollout" ] && { echo "     run dir created before the stop: BAD"; FAILS=$((FAILS+1)); } || echo "     no directory created before the stop: OK"
FAKE_REGION=us-east-1 one "wrong region" "" "this is region us-east-1" preflight

echo "== arguments"
one "record without pin" "" "requires --pin" record
one "record short pin" "" "must be the full 40-hex" record --pin 2961d2d
one "deploy without a mode" "" "requires a mode" deploy --pin "$FAKE_PIN"
one "unknown argument" "" "unknown argument" preflight --bogus

echo "== preflight is read-only"
one "preflight (no pin) reports head" "" "no --pin given, not judged" preflight
[ -e "$LAST_BASE/rollout/current-run" ] && { echo "     preflight wrote current-run: BAD"; FAILS=$((FAILS+1)); } || echo "     preflight did not write current-run: OK"
echo "     preflight dir perms: $(stat -c '%a' "$LAST_BASE"/rollout/preflight-* 2>/dev/null)"
one "preflight with moved head warns" "head-moved" "WARNING: remote test head is abc1234" preflight --pin "$FAKE_PIN"
base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"
env $(envfor "$base") SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" >/dev/null 2>&1; before=$(cat "$base/rollout/current-run")
env $(envfor "$base") SCENARIO= bash "$SCRIPT" preflight --pin "$FAKE_PIN" >/dev/null 2>&1; after=$(cat "$base/rollout/current-run")
[ "$before" = "$after" ] && echo "PASS [preflight after record leaves current-run untouched]" || { echo "FAIL [preflight overwrote current-run]"; FAILS=$((FAILS+1)); }

echo "== record"
one "remote head moved" "head-moved" "Newer commits exist" record --pin "$FAKE_PIN"
one "local changes" "dirty" "local changes present" record --pin "$FAKE_PIN"
one "record ok" "" "rollback point recorded" record --pin "$FAKE_PIN"
echo "     pin recorded: $(cat "$(cat "$LAST_BASE/rollout/current-run")/pin.txt")"

echo "== deploy"
base=$(mktemp -d); export FAKE_STATE="$base/state"; mkdir -p "$FAKE_STATE"
env $(envfor "$base") SCENARIO= bash "$SCRIPT" record --pin "$FAKE_PIN" >/dev/null 2>&1
out=$(env $(envfor "$base") SCENARIO= bash "$SCRIPT" deploy --pin 3333333333333333333333333333333333333333 --apply-approved-migrations 2>&1); check "deploy pin differs from recorded" "$out" $? "differs from the pin recorded"
flow "build failure" "build-fail" "image build failed (build exit 17"
echo "== app image identification (compose lists postgres first; app has build: and no image:)"
flow "cached build: image created long before this build still deploys (content proves it)" "cached-build" "deployed $FAKE_PIN"
flow "baseline service also listed: still the app image" "with-baseline" "deployed $FAKE_PIN"
flow "app image missing after the build" "image-missing" "app image backend-app not found after the build"
flow "image content differs from the pinned checkout" "image-content-mismatch" "does not contain the pinned checkout"
flow "build named a different image than the app service" "naming-mismatch" "refusing to guess"
rd=$(cat "$LAST_BASE/rollout/current-run"); echo "     $(cat "$rd/app-image-name.txt" | tr '\n' '|')"
flow "build produced the old image" "same-image" "very image already running"
flow "db unreachable" "db-unreachable" "could not reach or authenticate"
flow "migration list mismatch" "migration-mismatch" "differ from the approved list"
flow "restore fails" "restore-fail" "pg_restore exited 1"
flow "restore fingerprint mismatch" "restore-mismatch" "restore test mismatch"
flow "startup failure" "startup-fail" "startup failed after 'up' (build succeeded)"
flow "deploy ok" "" "deployed $FAKE_PIN"
rd=$(cat "$LAST_BASE/rollout/current-run")
echo "     $(cat "$rd/app-image-name.txt" | tr '\n' '|')"
echo "     $(grep -c local= "$rd/built-image-content.txt") content files matched in the image"
out=$(env $(envfor "$LAST_BASE") SCENARIO= bash "$SCRIPT" deploy --pin "$FAKE_PIN" --apply-approved-migrations 2>&1); check "second deploy in same run refused" "$out" $? "deploy already completed"
echo "     files: $(ls "$rd" | tr '\n' ' ')"
echo "     perms: $(stat -c '%a %n' "$rd" "$rd"/*.dump | sed "s|$rd||" | tr '\n' ' ')"

echo "== deploy: update with no new migration (database already migrated)"
uflow "no mode given" "" "requires a mode" NOMODE
uflow "both modes given" "" "exactly one mode" --apply-approved-migrations --no-new-migrations
uflow "first-rollout mode on an already-migrated database" "" "use --no-new-migrations" --apply-approved-migrations
MODE_FLAG=--no-new-migrations flow "update mode on a database with the two migrations pending" "" "unexpected pending migrations found"; unset MODE_FLAG
uflow "status command fails" "status-fail" "prisma migrate status exited 1 in --no-new-migrations mode"
uflow "db unreachable" "db-unreachable" "could not reach or authenticate"
uflow "ledger has a failed entry" "ledger-dirty" "failed or rolled-back entries"
uflow "columns missing although ledger says applied" "schema-inconsistent" "schema and ledger disagree"
uflow "ledger has a migration the image lacks" "ledger-extra" "differ from the image's migration folders"
uflow "start applied a migration anyway" "reapplied" "during a --no-new-migrations deploy"
uflow "restore fails" "restore-fail" "pg_restore exited 1"
uflow "update ok" "next-image" "deployed $FAKE_PIN (mode no-new)"
rd=$(cat "$LAST_BASE/rollout/current-run")
echo "     files: $(ls "$rd" | tr '\n' ' ')"
echo "     gate: $(tr '\n' '|' < "$rd/pending-migrations.txt")"
echo "     ledger before/after identical: $(cmp -s "$rd/ledger-names-before.txt" "$rd/ledger-names-after.txt" && echo yes || echo NO)"
out=$(env $(envfor "$LAST_BASE") SCENARIO= bash "$SCRIPT" verify 2>&1); check "verify after update" "$out" $? "verification passed"

echo "== verify"
vflow "consent fails -> stops before regressions" "consent-fail" "stopping before any regression script"
vflow "regression fails -> stops at first failure" "regress-fail" "verify_sos_history failed (exit 1); stopping at the first failure"
vflow "image drift" "image-drift" "image content differs"
vflow "external health fails" "external-fail" "Privacy on TEST is NOT verified"
vflow "verify ok" "" "verification passed"

echo "== inspect"
out=$(env $(envfor "$LAST_BASE") SCENARIO= bash "$SCRIPT" inspect 2>&1); check "inspect" "$out" $? "approved columns present"

echo; [ "$FAILS" -eq 0 ] && echo "ALL SCENARIOS PASSED" || { echo "$FAILS FAILURE(S)"; exit 1; }

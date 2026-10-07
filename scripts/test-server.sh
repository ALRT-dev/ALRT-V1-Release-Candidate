#!/usr/bin/env bash
# ALRT TEST server helper for AWS CloudShell (same as test-server.ps1).
# Never touches the LIVE server (safety-alrt-prod / i-0c7a10c5b1d74310d) or
# any instance named like "prod".
#
#   Find (read only):  bash test-server.sh
#   Update TEST only:  bash test-server.sh update <instance-id> <folder>
set -uo pipefail
export AWS_PAGER=""
REGION="${AWS_REGION:-ap-southeast-2}"
BRANCH="claude/compassionate-franklin-512so7"
LIVE_ID="i-0c7a10c5b1d74310d"

ssm() { # ssm <instance> <timeout> <command...>
  local id="$1" t="$2"; shift 2
  local params; params=$(python3 -c 'import json,sys; print(json.dumps({"commands": sys.argv[2:], "executionTimeout": [sys.argv[1]]}))' "$t" "$@")
  local cid; cid=$(aws ssm send-command --region "$REGION" --instance-ids "$id" --document-name AWS-RunShellScript \
    --parameters "$params" --query Command.CommandId --output text) || return 1
  local st=""
  while :; do
    sleep 5
    st=$(aws ssm get-command-invocation --region "$REGION" --command-id "$cid" --instance-id "$id" --query Status --output text 2>/dev/null)
    case "$st" in Pending|InProgress|Delayed|"") continue;; esac; break
  done
  aws ssm get-command-invocation --region "$REGION" --command-id "$cid" --instance-id "$id" \
    --query "[Status,StandardOutputContent,StandardErrorContent]" --output text
}

if [ "${1:-}" != "update" ]; then
  echo "account: $(aws sts get-caller-identity --query Account --output text)"
  aws ec2 describe-instances --region "$REGION" --filters Name=instance-state-name,Values=running \
    --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name']|[0].Value,PublicIpAddress]" --output text |
  while IFS=$'\t' read -r id name ip; do
    echo "- $id  $name  $ip"
    if [ "$id" = "$LIVE_ID" ] || [[ "$name" == *prod* ]]; then echo "  LIVE server: skipped"; continue; fi
    ping=$(aws ssm describe-instance-information --region "$REGION" --filters "Key=InstanceIds,Values=$id" \
      --query "InstanceInformationList[0].PingStatus" --output text 2>/dev/null)
    [ "$ping" = "Online" ] || { echo "  not reachable through SSM ($ping)"; continue; }
    ssm "$id" 120 \
      "docker ps --format '{{.Names}}  {{.Image}}  {{.Status}}'" \
      'for d in /home/*/* /home/*/*/* /opt/* /opt/*/* /srv/* /root/*; do if [ -f "$d/docker-compose.test.yml" ]; then echo TEST_COMPOSE_AT $d; git -C "$d" log --oneline -1; git -C "$d" branch --show-current; ls "$d/prisma/migrations" | tail -2; fi; done 2>/dev/null'
  done
  echo; echo "If a server shows TEST_COMPOSE_AT <folder>, run:  bash test-server.sh update <instance-id> <folder>"
  exit 0
fi

ID="${2:?instance id}"; DIR="${3:?folder}"
[ "$ID" = "$LIVE_ID" ] && { echo "Refusing: LIVE server."; exit 1; }
NAME=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$ID" --query "Reservations[0].Instances[0].Tags[?Key=='Name']|[0].Value" --output text)
[[ "$NAME" == *prod* ]] && { echo "Refusing: '$NAME' looks like production."; exit 1; }
echo "Updating TEST server $ID ($NAME), $DIR, to $BRANCH"
ssm "$ID" 1500 \
  "set -e" "cd '$DIR'" \
  "[ -f docker-compose.test.yml ] || { echo 'No docker-compose.test.yml here, stopping'; exit 1; }" \
  'ROOT=$(git rev-parse --show-toplevel)' \
  "git -C \"\$ROOT\" fetch origin '$BRANCH'" \
  "git -C \"\$ROOT\" checkout -B '$BRANCH' 'origin/$BRANCH'" \
  'git -C "$ROOT" log --oneline -1' \
  'cp .env.test .env.test.bak-$(date +%Y%m%d%H%M%S)' \
  "grep -q '^RUN_SCHEDULED_JOBS_IN_TEST=' .env.test && sed -i 's/^RUN_SCHEDULED_JOBS_IN_TEST=.*/RUN_SCHEDULED_JOBS_IN_TEST=true/' .env.test || echo 'RUN_SCHEDULED_JOBS_IN_TEST=true' >> .env.test" \
  "grep -q '^EMAIL_PASSWORD_AUTH_ENABLED=' .env.test && sed -i 's/^EMAIL_PASSWORD_AUTH_ENABLED=.*/EMAIL_PASSWORD_AUTH_ENABLED=true/' .env.test || echo 'EMAIL_PASSWORD_AUTH_ENABLED=true' >> .env.test" \
  'P=https://alrt-v1-release-candidate.pages.dev; C=$(grep "^CORS_ALLOWED_ORIGINS=" .env.test | cut -d= -f2-); case ",$C," in *",$P,"*) ;; *) sed -i "/^CORS_ALLOWED_ORIGINS=/d" .env.test; echo "CORS_ALLOWED_ORIGINS=${C:+$C,}$P" >> .env.test;; esac' \
  "docker compose -f docker-compose.test.yml up -d --build app" \
  "sleep 25" \
  "docker logs --tail 40 app-test 2>&1 | grep -viE 'secret|password|token|key=' || true" \
  'for p in /api/app/version-policy /api/hazard-categories; do printf "%s " $p; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3010$p; done' \
  'echo "Settings still blank in .env.test (names only):"; for k in EMAIL_PASSWORD_AUTH_ENABLED GOOGLE_OAUTH_CLIENT_ID_WEB GOOGLE_OAUTH_CLIENT_ID_IOS GOOGLE_OAUTH_CLIENT_ID_ANDROID APPLE_OAUTH_AUDIENCE AWS_S3_BUCKET_NAME AWS_S3_REGION AWS_S3_ACCESS_KEY_ID AWS_BEDROCK_REGION GOOGLE_MAPS_API_KEY TRIAL_LEDGER_SECRET; do v=$(grep "^$k=" .env.test | cut -d= -f2-); [ -z "$v" ] && echo "  $k"; done; true'
echo; echo "Expect /api/app/version-policy 200 and /api/hazard-categories 401."

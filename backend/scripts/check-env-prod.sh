#!/usr/bin/env bash
# Lists which live (production) settings are filled in .env.prod and which
# are still missing, blank or placeholders. NEVER prints a value - names only.
#
# Usage (on the live server, from backend/):
#   bash scripts/check-env-prod.sh            # checks ./.env.prod
#   ENV_FILE=/path/.env.prod bash scripts/check-env-prod.sh
#
# Exit code 0 = every startup-required setting is filled; 1 = something is
# missing (the backend will refuse to start until it is fixed).
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env.prod}"
if [ ! -f "$ENV_FILE" ]; then
  echo "Not found: $ENV_FILE  (copy .env.prod.example to .env.prod first)" >&2
  exit 1
fi

# The backend refuses to start without these (getRequiredEnv in
# src/utils/config.ts). Keep in sync with that file.
REQUIRED=(
  DATABASE_URL
  JWT_ACCESS_SECRET JWT_ACCESS_EXP_M JWT_REFRESH_SECRET JWT_REFRESH_EXP_D
  ADMIN_JWT_ACCESS_SECRET ADMIN_JWT_ACCESS_EXP_M ADMIN_JWT_REFRESH_SECRET ADMIN_JWT_REFRESH_EXP_D
  SUPER_ADMIN_EMAIL SUPER_ADMIN_PASSWORD SUPER_ADMIN_NAME
  GOOGLE_OAUTH_CLIENT_ID_WEB GOOGLE_OAUTH_CLIENT_ID_IOS GOOGLE_OAUTH_CLIENT_ID_ANDROID
  APPLE_OAUTH_AUDIENCE
  OPENAI_API_KEY AWS_BEDROCK_REGION
  AWS_S3_REGION AWS_S3_ACCESS_KEY_ID AWS_S3_SECRET_ACCESS_KEY AWS_S3_BUCKET_NAME
  NSW_TRANSPORT_API_KEY WAQI_API_TOKEN
  GOOGLE_MAPS_API_KEY
  SIGHTENGINE_API_USER SIGHTENGINE_API_SECRET SIGHTENGINE_WORKFLOW_ID
  SMTP_HOST SMTP_PORT SMTP_USER SMTP_PASSWORD EMAIL_FROM_ADDRESS EMAIL_SUPPORT_ADDRESS
)

# Not needed to start, but a feature stays off until they are set.
FEATURE=(
  "REVENUECAT_WEBHOOK_AUTH|subscriptions: RevenueCat webhook is refused (503)"
  "RC_PRODUCT_TIERS|subscriptions: purchases are recorded but grant nothing"
  "RC_APP_IDS|subscriptions: events from unexpected apps are not filtered"
  "RC_EXPECTED_ENVIRONMENT|subscriptions: sandbox purchases could reach live"
  "REVENUECAT_SECRET_API_KEY|subscriptions: server-side re-check is skipped"
  "QLD_TRAFFIC_API_KEY|feeds: Queensland traffic is skipped"
  "CORS_ALLOWED_ORIGINS|admin portal: browser calls from the portal are blocked"
  "PASSWORD_RESET_BASE_URL|email: reset links use the request host"
)

# Values that are clearly not real.
PLACEHOLDER_RE='^(|changeme|change_me|placeholder|your[-_].*|xxx+|todo|tbd|not[-_]configured.*|dummy.*|test|example.*)$'

value_of() {
  # Last assignment wins, like dotenv. Strips surrounding quotes.
  local line
  line="$(grep -E "^[[:space:]]*$1=" "$ENV_FILE" | tail -n 1 || true)"
  [ -z "$line" ] && { printf '%s' "__MISSING__"; return; }
  line="${line#*=}"
  line="${line%\"}"; line="${line#\"}"
  line="${line%\'}"; line="${line#\'}"
  printf '%s' "$line"
}

state_of() {
  local v lower
  v="$(value_of "$1")"
  [ "$v" = "__MISSING__" ] && { echo "missing"; return; }
  # Trim whitespace; an empty value is blank (grep never matches empty input).
  v="$(printf '%s' "$v" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  [ -z "$v" ] && { echo "blank"; return; }
  lower="$(printf '%s\n' "$v" | tr '[:upper:]' '[:lower:]')"
  if printf '%s\n' "$lower" | grep -Eq "$PLACEHOLDER_RE"; then
    echo "placeholder"
    return
  fi
  echo "set"
}

fail=0
echo "Checking $ENV_FILE (names only, no values shown)"
echo
echo "Required to start:"
for name in "${REQUIRED[@]}"; do
  s="$(state_of "$name")"
  if [ "$s" = "set" ]; then
    printf '  ok      %s\n' "$name"
  else
    printf '  %-7s %s\n' "$s" "$name"
    fail=1
  fi
done

echo
echo "Feature switches:"
for entry in "${FEATURE[@]}"; do
  name="${entry%%|*}"; effect="${entry#*|}"
  s="$(state_of "$name")"
  if [ "$s" = "set" ]; then
    printf '  ok      %s\n' "$name"
  else
    printf '  %-7s %s  -> %s\n' "$s" "$name" "$effect"
  fi
done

echo
nodeenv="$(value_of NODE_ENV)"
billing="$(value_of BILLING_ENABLED)"
rcenv="$(value_of RC_EXPECTED_ENVIRONMENT | tr '[:lower:]' '[:upper:]')"
[ "$nodeenv" = "prod" ] || { echo "  WARNING NODE_ENV is not 'prod' - scheduled jobs and source sync will not run"; fail=1; }
[ "$billing" = "true" ] && echo "  note    BILLING_ENABLED=true - paid features are enforced" \
                        || echo "  note    BILLING_ENABLED is not 'true' - everyone is treated as ALRT+"
[ "$rcenv" = "SANDBOX" ] && echo "  WARNING RC_EXPECTED_ENVIRONMENT=SANDBOX on the live server"
if grep -Eq '^[[:space:]]*RC_PRODUCT_TIERS=.*alrt_dev_' "$ENV_FILE"; then
  echo "  WARNING RC_PRODUCT_TIERS contains alrt_dev_* (Dev app) products"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "Result: all startup settings are filled."
else
  echo "Result: some startup settings are missing - fix them before restarting."
fi
exit "$fail"

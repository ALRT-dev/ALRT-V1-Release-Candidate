#!/usr/bin/env bash
# Fills BLANK settings in .env.prod from the live AWS Secrets Manager secrets
# (account 082258816984, ap-southeast-2). Never overwrites a value that is
# already set, never prints a secret value, and leaves the file chmod 600.
#
# Run on the live server (its instance role, or credentials with
# secretsmanager:GetSecretValue on these secrets), from backend/:
#   bash scripts/fill-env-prod-from-aws.sh
#   ENV_FILE=.env.prod AWS_REGION=ap-southeast-2 bash scripts/fill-env-prod-from-aws.sh
#
# Covers only what AWS holds today (DB, Maps, S3 credentials). Everything
# else lives only in the existing server .env.prod or the provider
# dashboards - see docs/LIVE_CONNECTIONS.md. Run check-env-prod.sh after.
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env.prod}"
REGION="${AWS_REGION:-ap-southeast-2}"
DB_SECRET="${DB_SECRET_ID:-safetyalrt/db/postgres}"
MAPS_SECRET="${MAPS_SECRET_ID:-GOOGLE_MAPS_API_KEY}"
S3_SECRET="${S3_SECRET_ID:-safety-alert/aws-credentials}"

command -v aws >/dev/null || { echo "aws CLI not found" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 not found" >&2; exit 1; }
[ -f "$ENV_FILE" ] || { echo "Not found: $ENV_FILE (cp .env.prod.example .env.prod)" >&2; exit 1; }

cp -p "$ENV_FILE" "$ENV_FILE.bak.$(date +%Y%m%d%H%M%S)"
chmod 600 "$ENV_FILE"

fetch() {
  aws secretsmanager get-secret-value --region "$REGION" --secret-id "$1" \
    --query SecretString --output text 2>/dev/null || true
}

DB_JSON="$(fetch "$DB_SECRET")" \
MAPS_RAW="$(fetch "$MAPS_SECRET")" \
S3_JSON="$(fetch "$S3_SECRET")" \
ENV_FILE="$ENV_FILE" python3 - <<'PY'
import json, os, re, urllib.parse

path = os.environ["ENV_FILE"]
lines = open(path, encoding="utf-8").read().splitlines()

def current(name):
    val = None
    for l in lines:
        m = re.match(rf"\s*{name}=(.*)$", l)
        if m:
            val = m.group(1).strip().strip('"').strip("'")
    return val

def put(name, value, source):
    if value in (None, ""):
        print(f"  skipped  {name}  ({source}: no usable value)")
        return
    cur = current(name)
    if cur:
        print(f"  kept     {name}  (already set)")
        return
    done = False
    for i, l in enumerate(lines):
        if re.match(rf"\s*{name}=", l):
            lines[i] = f"{name}={value}"
            done = True
    if not done:
        lines.append(f"{name}={value}")
    print(f"  filled   {name}  (from {source})")

def as_json(raw):
    try:
        return json.loads(raw) if raw else None
    except ValueError:
        return None

def pick(d, *keys):
    if not isinstance(d, dict):
        return None
    lower = {k.lower(): v for k, v in d.items()}
    for k in keys:
        if k.lower() in lower and lower[k.lower()] not in (None, ""):
            return str(lower[k.lower()])
    return None

# Database: plain URL, {"DATABASE_URL": ...}, or RDS-style parts.
raw = os.environ.get("DB_JSON", "")
d = as_json(raw)
url = None
if raw.startswith("postgres"):
    url = raw
elif d:
    url = pick(d, "DATABASE_URL", "url", "connectionString")
    if not url:
        user, pw, host = pick(d, "username", "user"), pick(d, "password"), pick(d, "host", "hostname")
        port = pick(d, "port") or "5432"
        db = pick(d, "dbname", "database", "dbName") or "postgres"
        if user and pw and host:
            url = (f"postgresql://{urllib.parse.quote(user, safe='')}:"
                   f"{urllib.parse.quote(pw, safe='')}@{host}:{port}/{db}?schema=public")
put("DATABASE_URL", url, "secret safetyalrt/db/postgres")

# Maps: plain string or {"GOOGLE_MAPS_API_KEY": ...}.
raw = os.environ.get("MAPS_RAW", "")
d = as_json(raw)
put("GOOGLE_MAPS_API_KEY", pick(d, "GOOGLE_MAPS_API_KEY", "apiKey", "key") if d else raw,
    "secret GOOGLE_MAPS_API_KEY")

# S3 credentials.
d = as_json(os.environ.get("S3_JSON", ""))
put("AWS_S3_ACCESS_KEY_ID", pick(d, "AWS_S3_ACCESS_KEY_ID", "AWS_ACCESS_KEY_ID", "accessKeyId", "access_key_id"),
    "secret safety-alert/aws-credentials")
put("AWS_S3_SECRET_ACCESS_KEY", pick(d, "AWS_S3_SECRET_ACCESS_KEY", "AWS_SECRET_ACCESS_KEY", "secretAccessKey", "secret_access_key"),
    "secret safety-alert/aws-credentials")

open(path, "w", encoding="utf-8").write("\n".join(lines) + "\n")
PY

chmod 600 "$ENV_FILE"
echo
echo "Done. A backup of the previous file was saved next to it."
echo "Next: bash scripts/check-env-prod.sh"

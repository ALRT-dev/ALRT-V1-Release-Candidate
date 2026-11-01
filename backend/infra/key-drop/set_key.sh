#!/usr/bin/env bash
# Puts the real GDACS Prod owner webhook key into the Secrets Manager secret.
# The key is read with `read -s`, so it never appears on screen, in shell
# history, or in process arguments visible to other users (passed via a
# temp file that is shredded afterwards).
#   bash set_key.sh
set -euo pipefail
cd "$(dirname "$0")"

STACK="${STACK_NAME:-gdacs-key-drop}"
REGION="${AWS_REGION:-ap-southeast-2}"
command -v aws >/dev/null || { echo "aws CLI not found" >&2; exit 1; }

SECRET_ID="$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query 'Stacks[0].Outputs[?OutputKey==`SecretArn`].OutputValue' --output text)"
[ -n "$SECRET_ID" ] && [ "$SECRET_ID" != "None" ] || { echo "Stack $STACK has no SecretArn output; run deploy.sh first" >&2; exit 1; }

printf 'Paste the GDACS Prod owner webhook key (hidden), then Enter: '
read -rs KEY; echo
printf 'Paste it again to confirm: '
read -rs KEY2; echo
[ "$KEY" = "$KEY2" ] || { echo "Keys do not match; nothing changed" >&2; exit 1; }
[ "${#KEY}" -ge 16 ] || { echo "Key looks too short (${#KEY} chars); nothing changed" >&2; exit 1; }

TMP="$(mktemp)"; chmod 600 "$TMP"
trap 'shred -u "$TMP" 2>/dev/null || rm -f "$TMP"' EXIT
KEY="$KEY" python3 -c 'import json,os,sys; sys.stdout.write(json.dumps({"X-Webhook-Api-Key": os.environ["KEY"]}))' > "$TMP"
unset KEY KEY2

aws secretsmanager put-secret-value --region "$REGION" --secret-id "$SECRET_ID" \
  --secret-string "file://$TMP" --query 'VersionId' --output text >/dev/null
echo "Secret updated: $SECRET_ID"
echo "Issue a link with: python3 issue_link.py"

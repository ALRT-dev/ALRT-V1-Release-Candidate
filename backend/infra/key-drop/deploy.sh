#!/usr/bin/env bash
# Deploys (or updates) the one-time key drop stack. Account 082258816984,
# ap-southeast-2 by default. Idempotent: re-run after editing template.yaml.
#   bash deploy.sh
#   AUTH_MODE=AWS_IAM bash deploy.sh      # also require SigV4 on the link
set -euo pipefail
cd "$(dirname "$0")"

STACK="${STACK_NAME:-gdacs-key-drop}"
REGION="${AWS_REGION:-ap-southeast-2}"
AUTH_MODE="${AUTH_MODE:-NONE}"

command -v aws >/dev/null || { echo "aws CLI not found" >&2; exit 1; }
echo "Deploying $STACK to $REGION (account $(aws sts get-caller-identity --query Account --output text))"

aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$STACK" \
  --template-file template.yaml \
  --capabilities CAPABILITY_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides "AuthMode=$AUTH_MODE"

echo
aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query 'Stacks[0].Outputs[].[OutputKey,OutputValue]' --output table
echo
echo "Next: bash set_key.sh   (paste the GDACS key when prompted; nothing is echoed)"
echo "Then: python3 issue_link.py   (prints a single-use link valid 15 minutes)"

# One-time key drop (GDACS Prod owner webhook key)

A single-use, short-lived link for handing a secret to someone (or an agent)
without putting it in chat, email, or a ticket. Built on AWS in account
`082258816984`, region `ap-southeast-2`, matching the rest of the backend.

```
Secrets Manager  safetyalrt/gdacs-prod/webhook-key   <- the key, set once by set_key.sh
DynamoDB         gdacs_key_access                     <- one row per issued link, TTL-expired
Lambda           gdacs-get-key                        <- checks + consumes the token atomically
HTTP API         GET /prod/gdacs/key?request_id=...   <- the link you share
```

Each link is a 256-bit random token that works **once** and dies after 15
minutes (configurable). A replayed, expired, or guessed link gets `410` and
nothing else. The Lambda logs the token prefix and caller IP for every release
or refusal, never the secret.

## Runbook

All commands run from this directory with AWS credentials for the account
(the same credentials `backend/scripts/fill-env-prod-from-aws.sh` uses).

1. **Deploy** the stack (idempotent, ~2 minutes):

   ```bash
   bash deploy.sh
   ```

2. **Set the key.** You are prompted twice; input is hidden and never written
   to shell history or the screen:

   ```bash
   bash set_key.sh
   ```

   Until this runs the secret holds a placeholder and the endpoint answers
   `409` without burning any token.

3. **Issue a link** and send it over a private channel (vault share, a DM
   that auto-deletes). Put a note on it so the audit row says who it was for:

   ```bash
   python3 issue_link.py --note "Claude - GDACS Prod onboarding"
   ```

   The recipient opens the link once and receives
   `{"X-Webhook-Api-Key": "..."}`. Use `--ttl 60` for a longer window.

4. **Check or revoke:**

   ```bash
   python3 issue_link.py --list
   python3 issue_link.py --revoke <request_id>
   ```

5. **After onboarding**, either leave the stack for future drops (the secret
   is still protected by IAM, and no link exists until you issue one) or
   remove everything:

   ```bash
   aws cloudformation delete-stack --region ap-southeast-2 --stack-name gdacs-key-drop
   ```

   Secrets Manager keeps the deleted secret recoverable for 30 days.

## Options

| Variable / flag | Default | Meaning |
|---|---|---|
| `STACK_NAME` | `gdacs-key-drop` | CloudFormation stack name |
| `AWS_REGION` | `ap-southeast-2` | Region for every script |
| `AUTH_MODE=AWS_IAM` (deploy.sh) | `NONE` | Also require SigV4 on the link. Use when every recipient has IAM access; it stops a leaked link from being usable by anyone outside the account. |
| `--ttl` (issue_link.py) | `15` minutes | Link lifetime, 1 to 1440 |

## Security notes

- The link is the credential. `NONE` mode is the right choice when the
  recipient has no AWS identity; the token is unguessable and single-use, and
  the stage is throttled to 2 requests/second with a burst of 5.
- Consumption is a conditional `UpdateItem`, so concurrent requests on the
  same token yield exactly one `200`. `tests/test_handler.py` proves this
  with eight parallel callers.
- The Lambda role can only read this one secret and update this one table.
  Reserved concurrency is 2.
- Rotate the GDACS key in the Admin Portal (Webhook API Keys page) after
  onboarding if the link was ever sent somewhere you no longer trust, then
  re-run `set_key.sh`.

## Tests

```bash
pip install "moto[dynamodb,secretsmanager]" pyyaml boto3 pytest
python3 -m pytest backend/infra/key-drop/tests -q
cfn-lint backend/infra/key-drop/template.yaml
```

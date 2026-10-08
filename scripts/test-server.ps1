<#
  ALRT TEST server helper (Windows PowerShell, uses your AWS CLI profiles).

  Never touches the LIVE server (safety-alrt-prod, i-0c7a10c5b1d74310d) or
  any instance whose Name contains "prod": it refuses outright.

  1) Find the TEST server (read only):
       .\scripts\test-server.ps1
     Lists every AWS CLI profile's account and running servers, and for each
     non-live server looks (read only, via SSM) for docker-compose.test.yml
     and the code version it runs.

  2) Update the TEST server to the new code (only after step 1 shows it):
       .\scripts\test-server.ps1 -Update -AwsProfile <profile> -InstanceId <i-...> -Path <folder from step 1>
     On that one server: fetches branch claude/compassionate-franklin-512so7,
     turns on scheduled jobs (real alerts) and email sign-in and allows the TEST Admin Portal
     in CORS in .env.test (a backup copy is kept), rebuilds and restarts the
     TEST app container (it applies database changes on start), then checks
     the new endpoints answer. Prints setting NAMES that are still blank,
     never their values.
#>
param(
  [switch]$Update,
  [string]$AwsProfile,
  [string]$InstanceId,
  [string]$Path,
  [string]$Region = "ap-southeast-2",
  [string]$Branch = "claude/compassionate-franklin-512so7"
)

# Native AWS CLI calls write warnings to stderr; "Stop" would turn those into
# terminating errors on Windows PowerShell, so failures are checked explicitly.
$ErrorActionPreference = "Continue"
$env:AWS_PAGER = ""
$LiveId = "i-0c7a10c5b1d74310d"

function Invoke-Ssm($prof, $id, [string[]]$commands, [int]$timeout = 900) {
  $paramFile = Join-Path $env:TEMP "alrt-ssm-$([guid]::NewGuid()).json"
  @{ commands = $commands; executionTimeout = @("$timeout") } | ConvertTo-Json -Depth 3 | Set-Content -Encoding ascii $paramFile
  $cid = aws ssm send-command --profile $prof --region $Region --instance-ids $id `
    --document-name AWS-RunShellScript --parameters "file://$paramFile" `
    --query Command.CommandId --output text
  Remove-Item $paramFile -ErrorAction SilentlyContinue
  do {
    Start-Sleep -Seconds 5
    $st = aws ssm get-command-invocation --profile $prof --region $Region --command-id $cid --instance-id $id --query Status --output text 2>$null
  } while ($st -in @("Pending", "InProgress", "Delayed", $null, ""))
  aws ssm get-command-invocation --profile $prof --region $Region --command-id $cid --instance-id $id --query "[Status,StandardOutputContent,StandardErrorContent]" --output text
}

if (-not $Update) {
  $profiles = aws configure list-profiles
  if (-not $profiles) { $profiles = @("default") }
  foreach ($p in $profiles) {
    Write-Host "`n===== profile: $p" -ForegroundColor Cyan
    $acct = aws sts get-caller-identity --profile $p --query Account --output text 2>$null
    if (-not $acct) { Write-Host "  (not signed in / no access)"; continue }
    Write-Host "  account: $acct"
    $rows = aws ec2 describe-instances --profile $p --region $Region `
      --filters Name=instance-state-name,Values=running `
      --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name']|[0].Value,PublicIpAddress]" --output text
    if (-not $rows) { Write-Host "  no running servers in $Region"; continue }
    foreach ($r in ($rows -split "`n")) {
      $f = $r -split "`t"; $id = $f[0]; $name = $f[1]
      Write-Host "  - $id  $name  $($f[2])"
      if ($id -eq $LiveId -or $name -match "prod") { Write-Host "    LIVE server: skipped"; continue }
      $managed = aws ssm describe-instance-information --profile $p --region $Region `
        --filters "Key=InstanceIds,Values=$id" --query "InstanceInformationList[0].PingStatus" --output text 2>$null
      if ($managed -ne "Online") { Write-Host "    not reachable through SSM ($managed)"; continue }
      Invoke-Ssm $p $id @(
        "docker ps --format '{{.Names}}  {{.Image}}  {{.Status}}'",
        "for d in /home/*/* /home/*/*/* /opt/* /opt/*/* /srv/* /root/*; do if [ -f `"`$d/docker-compose.test.yml`" ]; then echo TEST_COMPOSE_AT `$d; git -C `"`$d`" log --oneline -1; git -C `"`$d`" branch --show-current; ls `"`$d/prisma/migrations`" | tail -2; fi; done 2>/dev/null"
      ) 120 | Write-Host
    }
  }
  Write-Host "`nIf a server shows TEST_COMPOSE_AT <folder>, run:" -ForegroundColor Yellow
  Write-Host "  .\scripts\test-server.ps1 -Update -AwsProfile <profile> -InstanceId <id> -Path <folder>"
  exit 0
}

# ---------------- Update ----------------
if (-not ($AwsProfile -and $InstanceId -and $Path)) { throw "Give -AwsProfile, -InstanceId and -Path (from the find step)." }
if ($InstanceId -eq $LiveId) { throw "Refusing: that is the LIVE server." }
$name = aws ec2 describe-instances --profile $AwsProfile --region $Region --instance-ids $InstanceId --query "Reservations[0].Instances[0].Tags[?Key=='Name']|[0].Value" --output text
if ($name -match "prod") { throw "Refusing: instance '$name' looks like production." }
Write-Host "Updating TEST server $InstanceId ($name), folder $Path, to $Branch" -ForegroundColor Cyan

$commands = @(
  "set -e",
  "cd '$Path'",
  "[ -f docker-compose.test.yml ] || { echo 'No docker-compose.test.yml here, stopping'; exit 1; }",
  "ROOT=`$(git rev-parse --show-toplevel)",
  "git -C `"`$ROOT`" fetch origin '$Branch'",
  "git -C `"`$ROOT`" checkout -B '$Branch' 'origin/$Branch'",
  "git -C `"`$ROOT`" log --oneline -1",
  "cp .env.test .env.test.bak-`$(date +%Y%m%d%H%M%S)",
  "grep -q '^RUN_SCHEDULED_JOBS_IN_TEST=' .env.test && sed -i 's/^RUN_SCHEDULED_JOBS_IN_TEST=.*/RUN_SCHEDULED_JOBS_IN_TEST=true/' .env.test || echo 'RUN_SCHEDULED_JOBS_IN_TEST=true' >> .env.test",
  "grep -q '^EMAIL_PASSWORD_AUTH_ENABLED=' .env.test && sed -i 's/^EMAIL_PASSWORD_AUTH_ENABLED=.*/EMAIL_PASSWORD_AUTH_ENABLED=true/' .env.test || echo 'EMAIL_PASSWORD_AUTH_ENABLED=true' >> .env.test",
  "P=https://alrt-v1-release-candidate.pages.dev; C=`$(grep '^CORS_ALLOWED_ORIGINS=' .env.test | cut -d= -f2-); case `",`$C,`" in *`",`$P,`"*) ;; *) sed -i '/^CORS_ALLOWED_ORIGINS=/d' .env.test; echo `"CORS_ALLOWED_ORIGINS=`${C:+`$C,}`$P`" >> .env.test;; esac",
  "docker compose -f docker-compose.test.yml up -d --build app",
  "sleep 25",
  "docker logs --tail 40 app-test 2>&1 | grep -viE 'secret|password|token|key=' || true",
  "for p in /api/app/version-policy /api/hazard-categories; do printf '%s ' `$p; curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3010`$p; done",
  "echo 'Settings still blank in .env.test (names only):'",
  "for k in EMAIL_PASSWORD_AUTH_ENABLED GOOGLE_OAUTH_CLIENT_ID_WEB GOOGLE_OAUTH_CLIENT_ID_IOS GOOGLE_OAUTH_CLIENT_ID_ANDROID APPLE_OAUTH_AUDIENCE AWS_S3_BUCKET_NAME AWS_S3_REGION AWS_S3_ACCESS_KEY_ID AWS_BEDROCK_REGION GOOGLE_MAPS_API_KEY TRIAL_LEDGER_SECRET; do v=`$(grep `"^`$k=`" .env.test | cut -d= -f2-); [ -z `"`$v`" ] && echo `"  `$k`"; done; true"
)
Invoke-Ssm $AwsProfile $InstanceId $commands 1500 | Write-Host
Write-Host "`nDone. Expect /api/app/version-policy 200 (new code) and /api/hazard-categories 401 (signed-out request)." -ForegroundColor Green

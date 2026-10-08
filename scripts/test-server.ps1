<#
  ALRT TEST server helper (Windows PowerShell, uses your AWS CLI profiles).

  Never touches the LIVE server (safety-alrt-prod, i-0c7a10c5b1d74310d) or any
  instance whose Name contains "prod": it refuses outright.

  1) Find the TEST server (read only):
       .\scripts\test-server.ps1
     For every AWS profile on this PC: the account it reaches, its servers, and
     for each non-live server a read-only look (through SSM) for
     docker-compose.test.yml and the code version it runs.

  2) Update the TEST server to the new code (only after step 1 shows it):
       .\scripts\test-server.ps1 -Update -ProfileName <profile> -InstanceId <i-...> -Path <folder from step 1>
     On that one server: fetches the branch below, turns on scheduled jobs (real
     alerts), turns on email sign-in, allows the TEST Admin Portal in CORS in
     .env.test (a backup copy is kept), rebuilds and restarts the TEST app
     container (it applies database changes on start), then checks the new
     endpoints answer. Prints setting NAMES that are still blank, never values.

  Written for Windows PowerShell 5.1: the AWS CLI writes progress and warnings
  to the error stream, so this script must not run with ErrorActionPreference
  "Stop" (5.1 turns any such line into a fatal error). Exit codes are checked
  instead.
#>
param(
  [switch]$Update,
  [Alias("Profile")]
  [string]$ProfileName,
  [string]$InstanceId,
  [string]$Path,
  [string[]]$Region = @("ap-southeast-2"),
  [string]$Branch = "claude/compassionate-franklin-512so7"
)

$ErrorActionPreference = "Continue"
$env:AWS_PAGER = ""
$LiveId = "i-0c7a10c5b1d74310d"

# Runs the AWS CLI and returns its output, or $null when the call failed.
# Keeps stderr on the console so a real problem is still visible.
function Invoke-Aws {
  param([string[]]$Arguments)
  $out = & aws @Arguments
  if ($LASTEXITCODE -ne 0) { return $null }
  if ($null -eq $out) { return "" }
  return ($out -join "`n")
}

function Invoke-Ssm {
  param(
    [string]$ProfileName,
    [string]$InstanceId,
    [string[]]$Commands,
    [int]$TimeoutSeconds = 900,
    [string]$InRegion
  )
  $paramFile = Join-Path $env:TEMP ("alrt-ssm-" + [guid]::NewGuid().ToString() + ".json")
  $payload = @{ commands = $Commands; executionTimeout = @("$TimeoutSeconds") } | ConvertTo-Json -Depth 3
  Set-Content -Path $paramFile -Value $payload -Encoding ascii

  $cid = Invoke-Aws @("ssm","send-command","--profile",$ProfileName,"--region",$InRegion,
    "--instance-ids",$InstanceId,"--document-name","AWS-RunShellScript",
    "--parameters","file://$paramFile","--query","Command.CommandId","--output","text")
  Remove-Item $paramFile -Force -ErrorAction SilentlyContinue
  if (-not $cid) { Write-Host "    could not start the remote command"; return }
  $cid = $cid.Trim()

  # Poll, with a ceiling so a stuck command can never loop forever.
  $maxChecks = [int][math]::Ceiling(($TimeoutSeconds + 60) / 5)
  $status = ""
  for ($i = 0; $i -lt $maxChecks; $i++) {
    Start-Sleep -Seconds 5
    $status = Invoke-Aws @("ssm","get-command-invocation","--profile",$ProfileName,"--region",$InRegion,
      "--command-id",$cid,"--instance-id",$InstanceId,"--query","Status","--output","text")
    if ($null -eq $status) { $status = "" } else { $status = $status.Trim() }
    if ($status -and $status -notin @("Pending","InProgress","Delayed")) { break }
  }
  if (-not $status) { Write-Host "    no answer from the remote command"; return }
  Write-Host "    status: $status"
  $body = Invoke-Aws @("ssm","get-command-invocation","--profile",$ProfileName,"--region",$InRegion,
    "--command-id",$cid,"--instance-id",$InstanceId,
    "--query","[StandardOutputContent,StandardErrorContent]","--output","text")
  if ($body) { Write-Host $body }
}

# ---------------------------------------------------------------- find
if (-not $Update) {
  $profiles = & aws configure list-profiles
  if ($LASTEXITCODE -ne 0 -or -not $profiles) { $profiles = @("default") }

  foreach ($p in $profiles) {
    $p = "$p".Trim()
    if (-not $p) { continue }
    Write-Host ""
    Write-Host "===== profile: $p" -ForegroundColor Cyan

    $acct = Invoke-Aws @("sts","get-caller-identity","--profile",$p,"--query","Account","--output","text")
    if (-not $acct) {
      Write-Host "  cannot sign in with this profile (expired or invalid). For a single-sign-on profile run: aws sso login --profile $p"
      continue
    }
    Write-Host "  account: $($acct.Trim())"

    foreach ($r in $Region) {
      $rows = Invoke-Aws @("ec2","describe-instances","--profile",$p,"--region",$r,
        "--query","Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key=='Name']|[0].Value,PublicIpAddress]",
        "--output","text")
      if ($null -eq $rows) { Write-Host "  $r : no access"; continue }
      if (-not $rows.Trim()) { Write-Host "  $r : no servers"; continue }
      Write-Host "  $r :"

      foreach ($line in ($rows -split "`n")) {
        if (-not $line.Trim()) { continue }
        $f = $line -split "`t"
        $id = $f[0]; $state = $f[1]; $name = $f[2]; $ip = $f[3]
        Write-Host "  - $id  $state  $name  $ip"

        if ($state -ne "running") { continue }
        if ($id -eq $LiveId -or $name -match "prod") {
          Write-Host "    LIVE server: skipped, never touched"
          continue
        }

        $ping = Invoke-Aws @("ssm","describe-instance-information","--profile",$p,"--region",$r,
          "--filters","Key=InstanceIds,Values=$id",
          "--query","InstanceInformationList[0].PingStatus","--output","text")
        if ($null -eq $ping -or $ping.Trim() -ne "Online") {
          Write-Host "    not reachable through SSM"
          continue
        }

        $look = @(
          "docker ps --format '{{.Names}}  {{.Image}}  {{.Status}}'",
          'for d in /home/*/* /home/*/*/* /opt/* /opt/*/* /srv/* /root/*; do if [ -f "$d/docker-compose.test.yml" ]; then echo "TEST_COMPOSE_AT $d"; git -C "$d" log --oneline -1; git -C "$d" branch --show-current; ls "$d/prisma/migrations" 2>/dev/null | tail -2; fi; done 2>/dev/null'
        )
        Invoke-Ssm -ProfileName $p -InstanceId $id -Commands $look -TimeoutSeconds 120 -InRegion $r
      }
    }
  }

  Write-Host ""
  Write-Host "If a server showed TEST_COMPOSE_AT <folder>, run:" -ForegroundColor Yellow
  Write-Host "  .\scripts\test-server.ps1 -Update -ProfileName <profile> -InstanceId <id> -Path <folder>"
  exit 0
}

# -------------------------------------------------------------- update
if (-not ($ProfileName -and $InstanceId -and $Path)) {
  Write-Host "Give -ProfileName, -InstanceId and -Path (from the find step)." -ForegroundColor Red
  exit 1
}
if ($InstanceId -eq $LiveId) {
  Write-Host "Refusing: that is the LIVE server." -ForegroundColor Red
  exit 1
}

$updateRegion = $Region[0]
$name = Invoke-Aws @("ec2","describe-instances","--profile",$ProfileName,"--region",$updateRegion,
  "--instance-ids",$InstanceId,
  "--query","Reservations[0].Instances[0].Tags[?Key=='Name']|[0].Value","--output","text")
if ($null -eq $name) {
  Write-Host "Could not read that instance with profile '$ProfileName' in $updateRegion. Stopping." -ForegroundColor Red
  exit 1
}
$name = $name.Trim()
if ($name -match "prod") {
  Write-Host "Refusing: instance '$name' looks like production." -ForegroundColor Red
  exit 1
}

Write-Host "Updating TEST server $InstanceId ($name) in $updateRegion, folder $Path, to $Branch" -ForegroundColor Cyan

$script = @'
set -e
cd "__PATH__"
[ -f docker-compose.test.yml ] || { echo "No docker-compose.test.yml here, stopping"; exit 1; }
ROOT=$(git rev-parse --show-toplevel)
git -C "$ROOT" fetch origin "__BRANCH__"
git -C "$ROOT" checkout -B "__BRANCH__" "origin/__BRANCH__"
git -C "$ROOT" log --oneline -1
cp .env.test ".env.test.bak-$(date +%Y%m%d%H%M%S)"
set_env() {
  if grep -q "^$1=" .env.test; then
    sed -i "s|^$1=.*|$1=$2|" .env.test
  else
    echo "$1=$2" >> .env.test
  fi
}
set_env RUN_SCHEDULED_JOBS_IN_TEST true
set_env EMAIL_PASSWORD_AUTH_ENABLED true
PORTAL=https://alrt-v1-release-candidate.pages.dev
CURRENT=$(grep "^CORS_ALLOWED_ORIGINS=" .env.test | cut -d= -f2-)
case ",$CURRENT," in
  *",$PORTAL,"*) ;;
  *) if [ -n "$CURRENT" ]; then set_env CORS_ALLOWED_ORIGINS "$CURRENT,$PORTAL"; else set_env CORS_ALLOWED_ORIGINS "$PORTAL"; fi ;;
esac
docker compose -f docker-compose.test.yml up -d --build app
sleep 25
docker logs --tail 40 app-test 2>&1 | grep -viE "secret|password|token|key=" || true
for p in /api/app/version-policy /api/hazard-categories /api/ask-alrt/allowance; do
  printf "%s " "$p"
  curl -s -o /dev/null -w "%{http_code}\n" "http://localhost:3010$p"
done
echo "Settings still blank in .env.test (names only):"
for k in GOOGLE_OAUTH_CLIENT_ID_WEB GOOGLE_OAUTH_CLIENT_ID_IOS GOOGLE_OAUTH_CLIENT_ID_ANDROID \
         APPLE_OAUTH_AUDIENCE AWS_S3_BUCKET_NAME AWS_S3_REGION AWS_S3_ACCESS_KEY_ID \
         AWS_BEDROCK_REGION GOOGLE_MAPS_API_KEY TRIAL_LEDGER_SECRET BILLING_ENABLED \
         REVENUECAT_WEBHOOK_AUTH RC_PRODUCT_TIERS RC_EXPECTED_ENVIRONMENT REVENUECAT_SECRET_API_KEY; do
  v=$(grep "^$k=" .env.test | cut -d= -f2-)
  if [ -z "$v" ]; then echo "  $k"; fi
done
true
'@

$script = $script.Replace("__PATH__", $Path).Replace("__BRANCH__", $Branch)
$commands = @($script -split "`r?`n")

Invoke-Ssm -ProfileName $ProfileName -InstanceId $InstanceId -Commands $commands -TimeoutSeconds 1500 -InRegion $updateRegion

Write-Host ""
Write-Host "Done. Expect /api/app/version-policy 200 (new code), /api/hazard-categories 401 and /api/ask-alrt/allowance 401 (signed-out requests)." -ForegroundColor Green

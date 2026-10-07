"""Print the newest TestFlight crash reports for ALRT Dev to the job log.

Uses the App Store Connect API key the TestFlight upload already uses
(APP_STORE_CONNECT_API_KEY_ID / _ISSUER_ID / _KEY_CONTENT, base64 .p8).
Crash reports appear here when a tester shares one from TestFlight (the
"ALRT Dev crashed, share?" prompt, or TestFlight > ALRT Dev > Send Beta
Feedback after a crash). Read only: nothing is changed in App Store Connect.
"""
import base64
import json
import os
import sys
import time
import urllib.parse
import urllib.request

import jwt

BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.safetyalrt.alrt.dev")
API = "https://api.appstoreconnect.apple.com"


def token() -> str:
    key = base64.b64decode(os.environ["APP_STORE_CONNECT_API_KEY_CONTENT"]).decode()
    now = int(time.time())
    return jwt.encode(
        {"iss": os.environ["APP_STORE_CONNECT_ISSUER_ID"], "iat": now,
         "exp": now + 900, "aud": "appstoreconnect-v1"},
        key, algorithm="ES256",
        headers={"kid": os.environ["APP_STORE_CONNECT_API_KEY_ID"]},
    )


TOKEN = token()


def get(path: str, params: dict | None = None) -> dict:
    url = API + path + ("?" + urllib.parse.urlencode(params) if params else "")
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {TOKEN}"})
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as err:
        print(f"HTTP {err.code} for {path}: {err.read()[:500]!r}")
        return {}


apps = get("/v1/apps", {"filter[bundleId]": BUNDLE_ID}).get("data", [])
if not apps:
    sys.exit(f"No app found for {BUNDLE_ID}")
app_id = apps[0]["id"]
print(f"App {BUNDLE_ID} = {app_id}")

builds_list = get("/v1/builds", {"filter[app]": app_id, "sort": "-uploadedDate", "limit": "8",
                                 "fields[builds]": "version,uploadedDate,processingState,expired"})
print("Newest builds in App Store Connect:")
for b in builds_list.get("data", []):
    a = b["attributes"]
    print(f"  build {a.get('version')}  uploaded {a.get('uploadedDate')}  {a.get('processingState')}  expired={a.get('expired')}")
print()

subs = get(f"/v1/apps/{app_id}/betaFeedbackCrashSubmissions",
           {"sort": "-createdDate", "limit": "5", "include": "build"})
items = subs.get("data", [])
builds = {b["id"]: b["attributes"].get("version")
          for b in subs.get("included", []) if b.get("type") == "builds"}
print(f"{len(items)} shared crash report(s), newest first\n")
for item in items:
    a = item.get("attributes", {})
    build_id = (item.get("relationships", {}).get("build", {}).get("data") or {}).get("id")
    print("=" * 78)
    print(f"Submitted {a.get('createdDate')}  build {builds.get(build_id, '?')}  "
          f"{a.get('deviceModel')} iOS {a.get('osVersion')}  "
          f"comment: {a.get('comment')!r}")
    log = get(f"/v1/betaFeedbackCrashSubmissions/{item['id']}/crashLog")
    text = (log.get("data") or {}).get("attributes", {}).get("logText") or ""
    lines = text.splitlines()
    print(f"--- crash log ({len(lines)} lines; first 220) ---")
    print("\n".join(lines[:220]))

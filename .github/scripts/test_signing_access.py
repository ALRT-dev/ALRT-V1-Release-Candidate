"""Prepare the owner-approved read-only key for the isolated iPhone TEST build."""

import json
import os
from pathlib import Path
import shlex
import subprocess
import urllib.request


REPOSITORY = "git@github.com:ALRT-dev/ios-certificates.git"
KEY_NAME = "alrt-test-signing-key"


def main():
    secret = os.environ.get("TEST_IOS_CERTS_SSH_KEY", "").strip()
    if not secret.startswith("-----BEGIN OPENSSH PRIVATE KEY-----"):
        raise SystemExit("TEST-only signing key is missing or has an invalid format")
    if os.environ.get("GENERATE_CERTS", "false").lower() == "true":
        raise SystemExit("Certificate generation is disabled for read-only TEST signing")

    key = Path(os.environ["RUNNER_TEMP"]) / KEY_NAME
    ssh_dir = Path.home() / ".ssh"
    ssh_dir.mkdir(mode=0o700, exist_ok=True)
    # Fetch public host keys over verified HTTPS rather than trusting ssh-keyscan.
    request = urllib.request.Request(
        "https://api.github.com/meta", headers={"User-Agent": "ALRT-TEST-signing"}
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        host_keys = json.load(response).get("ssh_keys", [])
    if not host_keys or not all(k.startswith(("ssh-", "ecdsa-")) for k in host_keys):
        raise SystemExit("GitHub public host-key metadata was missing or invalid")
    known_hosts = Path(os.environ["RUNNER_TEMP"]) / "alrt-test-signing-known-hosts"
    known_hosts.write_text("".join("github.com " + k + "\n" for k in host_keys))
    key.write_text(secret + "\n")
    key.chmod(0o600)

    # Fastlane's git_private_key option builds its own SSH command, so install
    # the verified public keys in the conventional file as well.
    with (ssh_dir / "known_hosts").open("a") as destination:
        destination.write(known_hosts.read_text())

    ssh = (
        "ssh -i " + shlex.quote(str(key))
        + " -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes"
        + " -o UserKnownHostsFile=" + shlex.quote(str(known_hosts))
    )
    result = subprocess.run(
        ["git", "-c", "core.sshCommand=" + ssh, "ls-remote", "--exit-code", REPOSITORY, "HEAD"],
        stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True,
        env={**os.environ, "GIT_TERMINAL_PROMPT": "0"}, timeout=60,
    )
    if result.returncode:
        key.unlink(missing_ok=True)
        raise SystemExit("TEST signing repository read check failed: " + result.stderr[:400])

    with open(os.environ["GITHUB_ENV"], "a") as destination:
        destination.write("MATCH_GIT_URL=" + REPOSITORY + "\n")
        destination.write("MATCH_GIT_PRIVATE_KEY=" + str(key) + "\n")
    print("TEST-only signing key can read the certificate repository.")


if __name__ == "__main__":
    main()

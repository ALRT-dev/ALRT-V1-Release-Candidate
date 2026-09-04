/**
 * Group-list state verification - real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres.
 *
 * Covers listCirclesForUser() (2026-09-04): GET /api/family/circles now
 * carries one-glance state per group - who has checked in today (count),
 * who has not (names), and the SOS running there, if any (who and when) -
 * so the hub can show "2 of 3 · waiting on Amy" or "SOS live · Tom" for a
 * group that is NOT open. Never a location.
 *
 * Proves:
 *   1. A fresh circle: nobody checked in, waitingOn names everyone, no SOS.
 *   2. After Amy checks in: checkedInCount 1, waitingOn no longer has Amy.
 *   3. While Tom's SOS is active: activeSos names Tom with a time and
 *      carries no latitude/longitude, for every member's view of the list.
 *   4. After Tom stands down: activeSos is null again.
 *   5. A member of two circles gets each circle's own state (a check-in
 *      is per circle, never carried across).
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_circle_list_state.ts
 */

import assert from "node:assert/strict";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

const api = async (
  path: string,
  opts: { method?: string; token?: string; body?: unknown } = {},
) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: opts.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}),
    },
    ...(opts.body !== undefined ? { body: JSON.stringify(opts.body) } : {}),
  });
  let json: unknown = null;
  try {
    json = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body: json };
};

const registerUser = async (label: string) => {
  const uniqueSuffix = crypto.randomUUID().slice(0, 8);
  const email = `circle-state-${label}-${uniqueSuffix}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = (res.body as any).accessToken as string;
  const nameRes = await api("/api/user", { method: "PUT", token, body: { name: label } });
  assert.equal(nameRes.status, 200, JSON.stringify(nameRes.body));
  return { token, label };
};

const listAs = async (token: string) => {
  const res = await api("/api/family/circles", { token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body as any[];
};

const joinCircle = async (hostToken: string, memberToken: string) => {
  const invite = await api("/api/family/invites", { method: "POST", token: hostToken });
  assert.equal(invite.status, 201, JSON.stringify(invite.body));
  const join = await api("/api/family/join", {
    method: "POST",
    token: memberToken,
    body: { code: (invite.body as any).code },
  });
  assert.equal(join.status, 200, JSON.stringify(join.body));
};

async function main() {
  console.log("Group-list state verification (real HTTP + real DB)\n");

  console.log("setup - Sarah hosts Nixon Family with Amy and Tom");
  const sarah = await registerUser("Sarah");
  const amy = await registerUser("Amy");
  const tom = await registerUser("Tom");
  const created = await api("/api/family/circle", {
    method: "POST",
    token: sarah.token,
    body: { name: "Nixon Family" },
  });
  assert.equal(created.status, 201, JSON.stringify(created.body));
  const circleId = (created.body as any).id as string;
  await joinCircle(sarah.token, amy.token);
  await joinCircle(sarah.token, tom.token);
  console.log("  setup - done\n");

  console.log("§1 - a fresh circle");
  await check("nobody checked in, waitingOn names all three, no SOS", async () => {
    const [row] = (await listAs(sarah.token)).filter((c) => c.circleId === circleId);
    assert.ok(row, "circle row present");
    assert.equal(row.checkedInCount, 0);
    assert.deepEqual([...row.waitingOn].sort(), ["Amy", "Sarah", "Tom"]);
    assert.equal(row.activeSos, null);
  });
  console.log();

  console.log("§2 - Amy checks in");
  await check("checkedInCount 1 and Amy leaves waitingOn", async () => {
    const res = await api("/api/family/check-in", {
      method: "POST",
      token: amy.token,
      body: { status: "safe" },
    });
    assert.equal(res.status, 201, JSON.stringify(res.body));
    const [row] = (await listAs(tom.token)).filter((c) => c.circleId === circleId);
    assert.equal(row.checkedInCount, 1);
    assert.deepEqual([...row.waitingOn].sort(), ["Sarah", "Tom"]);
  });
  console.log();

  console.log("§3 - Tom's SOS is live");
  const sos = await api("/api/family/sos", {
    method: "POST",
    token: tom.token,
    body: { latitude: -31.89441, longitude: 115.75999, isLive: false },
  });
  assert.equal(sos.status, 201, JSON.stringify(sos.body));
  await check("activeSos names Tom with a time, and carries no location, for everyone", async () => {
    for (const t of [sarah.token, amy.token, tom.token]) {
      const [row] = (await listAs(t)).filter((c) => c.circleId === circleId);
      assert.equal(row.activeSos?.id, (sos.body as any).id);
      assert.equal(row.activeSos?.memberName, "Tom");
      assert.ok(typeof row.activeSos?.createdAt === "string");
      for (const key of ["latitude", "longitude", "locationLabel", "geom"]) {
        assert.ok(!(key in row.activeSos), `activeSos must not carry ${key}`);
      }
    }
  });
  console.log();

  console.log("§4 - Tom stands down");
  await check("activeSos is null again", async () => {
    const res = await api(`/api/family/sos/${(sos.body as any).id}/resolve`, {
      method: "POST",
      token: tom.token,
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const [row] = (await listAs(sarah.token)).filter((c) => c.circleId === circleId);
    assert.equal(row.activeSos, null);
  });
  console.log();

  console.log("§5 - two circles, each with its own state");
  await check("Amy's second circle reports independently", async () => {
    const otherHost = await registerUser("Kim");
    const other = await api("/api/family/circle", {
      method: "POST",
      token: otherHost.token,
      body: { name: "Netball" },
    });
    assert.equal(other.status, 201);
    await joinCircle(otherHost.token, amy.token);
    const rows = await listAs(amy.token);
    const nixon = rows.find((c) => c.circleId === circleId);
    const netball = rows.find((c) => c.circleId === (other.body as any).id);
    assert.equal(nixon.checkedInCount, 1);
    // A check-in is per circle: Amy checked in to Nixon Family, not to
    // Netball, so Netball is still waiting on her there.
    assert.equal(netball.checkedInCount, 0);
    assert.deepEqual([...netball.waitingOn].sort(), ["Amy", "Kim"]);
    assert.equal(netball.activeSos, null);
  });

  console.log(`\n${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exitCode = 1;
});

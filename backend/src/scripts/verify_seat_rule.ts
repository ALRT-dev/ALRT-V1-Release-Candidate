/**
 * Seat rule verification script — real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres+PostGIS
 * database.
 *
 * Product-owner rule (2026-09-03): the paying host never uses a seat;
 * invited non-paying full members (adults/children) use one seat each;
 * guests use none. 8 seats across up to 4 owned circles.
 *
 * Proves, via GET /api/family/circles (the seat ledger the app reads):
 *   1. A freshly created circle shows seatCount 0 for its owner - the
 *      host's own membership is free.
 *   2. After one invited adult joins, seatCount is 1.
 *   3. After one guest joins, seatCount is still 1 - guests are free.
 *   4. memberCount still counts everyone (3), so the two numbers differ
 *      exactly as the rule says they should.
 *   5. The joiner's own view of the same circle reports isOwned false and
 *      never charges the joiner a seat (their own owned-seat total is 0).
 *   6. Creating a second circle is allowed for the host regardless of the
 *      ledger (seat checks happen on join, not on creation).
 *
 * Setup: same throwaway pattern as verify_sos_history.ts.
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_seat_rule.ts
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
  const email = `seat-rule-${label}-${uniqueSuffix}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = (res.body as any).accessToken as string;
  const nameRes = await api("/api/user", {
    method: "PUT",
    token,
    body: { name: label },
  });
  assert.equal(nameRes.status, 200);
  return { token };
};

const ledgerFor = async (token: string, circleId: string) => {
  const res = await api("/api/family/circles", { token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  const row = (res.body as any[]).find((c) => c.circleId === circleId);
  assert.ok(row, "circle present in ledger");
  return row as { seatCount: number; memberCount: number; isOwned: boolean };
};

const invite = async (token: string, isGuestInvite: boolean) => {
  const res = await api("/api/family/invites", {
    method: "POST",
    token,
    body: { isGuestInvite },
  });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return (res.body as any).code as string;
};

const join = async (token: string, code: string) => {
  const res = await api("/api/family/join", {
    method: "POST",
    token,
    body: { code },
  });
  assert.equal(res.status, 200, JSON.stringify(res.body));
};

async function main() {
  console.log("Seat rule verification (real HTTP + real DB)\n");

  const host = await registerUser("Host");
  const adult = await registerUser("Adult");
  const guest = await registerUser("Guest");

  const circleRes = await api("/api/family/circle", {
    method: "POST",
    token: host.token,
    body: { name: "Seat rule circle" },
  });
  assert.equal(circleRes.status, 201, JSON.stringify(circleRes.body));
  const circleId = (circleRes.body as any).id as string;

  console.log("§1 - the host's own membership is free");
  await check("new circle: seatCount 0, memberCount 1", async () => {
    const row = await ledgerFor(host.token, circleId);
    assert.equal(row.isOwned, true);
    assert.equal(row.memberCount, 1);
    assert.equal(row.seatCount, 0);
  });

  console.log("§2 - an invited adult uses one seat");
  await join(adult.token, await invite(host.token, false));
  await check("after an adult joins: seatCount 1, memberCount 2", async () => {
    const row = await ledgerFor(host.token, circleId);
    assert.equal(row.memberCount, 2);
    assert.equal(row.seatCount, 1);
  });

  console.log("§3 - a guest uses no seat");
  await join(guest.token, await invite(host.token, true));
  await check("after a guest joins: seatCount still 1, memberCount 3", async () => {
    const row = await ledgerFor(host.token, circleId);
    assert.equal(row.memberCount, 3);
    assert.equal(row.seatCount, 1);
  });

  console.log("§4 - joining never charges the joiner");
  await check("the adult's ledger shows the circle as not owned, 0 seats of theirs", async () => {
    const row = await ledgerFor(adult.token, circleId);
    assert.equal(row.isOwned, false);
    const res = await api("/api/family/circles", { token: adult.token });
    const ownedSeats = (res.body as any[])
      .filter((c) => c.isOwned)
      .reduce((sum, c) => sum + c.seatCount, 0);
    assert.equal(ownedSeats, 0);
  });

  console.log("§5 - creating another circle is not seat-gated");
  await check("host can open a second circle (4-circle cap is the only limit)", async () => {
    const res = await api("/api/family/circle", {
      method: "POST",
      token: host.token,
      body: { name: "Second circle" },
    });
    assert.equal(res.status, 201, JSON.stringify(res.body));
    const row = await ledgerFor(host.token, (res.body as any).id);
    assert.equal(row.seatCount, 0);
  });

  console.log(`\nAll ${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exit(1);
});

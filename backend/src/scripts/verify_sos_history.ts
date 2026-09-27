/**
 * SOS acknowledgment + retained history verification script — real HTTP
 * requests against a running instance of this backend, backed by a real
 * local Postgres+PostGIS database.
 *
 * Covers the product-owner rules of 2026-09-03 for SOS acknowledgments:
 *   1. A recipient's explicit "seen" response is stored and returned on the
 *      active event with the responder's name and a timestamp (the sender's
 *      "who acknowledged" list).
 *   2. The sender cannot acknowledge their own SOS (400).
 *   3. After stand-down, a late acknowledgment is refused (400) - the
 *      response list is a closed record.
 *   4. GET /api/family/sos/history returns the stood-down event WITH its
 *      responses (names, times) and WITHOUT latitude/longitude/
 *      locationLabel, even though the purge job has not run.
 *   5. GET /api/family/sos/active no longer lists it.
 *   6. A user outside the circle gets nothing from /sos/history (403 via
 *      requireMembership when they have no circle at all).
 *
 * Setup: same throwaway pattern as verify_checkin_request_location_privacy.ts.
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_sos_history.ts
 * against a server started from the same .env.test (TEST_SERVER_URL to
 * override the default http://localhost:4123).
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
  const email = `sos-history-${label}-${uniqueSuffix}@test.local`;
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
  assert.equal(nameRes.status, 200, `name ${label}: ${JSON.stringify(nameRes.body)}`);

  const meRes = await api("/api/user", { token });
  assert.equal(meRes.status, 200);
  return { token, userId: (meRes.body as any).id as string };
};

const LOCATION_KEYS = ["latitude", "longitude", "locationLabel"];

async function main() {
  console.log("SOS acknowledgment + retained history verification (real HTTP + real DB)\n");

  console.log("setup - sender (S), recipient (R) in one circle; outsider (O) in none");
  const s = await registerUser("Sender");
  const r = await registerUser("Recipient");
  const o = await registerUser("Outsider");

  const circleRes = await api("/api/family/circle", {
    method: "POST",
    token: s.token,
    body: { name: "SOS history circle" },
  });
  assert.equal(circleRes.status, 201, JSON.stringify(circleRes.body));

  const inviteRes = await api("/api/family/invites", {
    method: "POST",
    token: s.token,
  });
  assert.equal(inviteRes.status, 201, JSON.stringify(inviteRes.body));
  const code = (inviteRes.body as any).code as string;

  const joinRes = await api("/api/family/join", {
    method: "POST",
    token: r.token,
    body: { code },
  });
  assert.equal(joinRes.status, 200, JSON.stringify(joinRes.body));

  console.log("§1 - trigger with a location, recipient acknowledges by explicit action");
  const sosRes = await api("/api/family/sos", {
    method: "POST",
    token: s.token,
    body: { latitude: -31.89441, longitude: 115.75999, isLive: false },
  });
  assert.equal(sosRes.status, 201, JSON.stringify(sosRes.body));
  const sosId = (sosRes.body as any).id as string;

  await check("recipient's 'seen' is accepted and carries their name + time", async () => {
    const res = await api(`/api/family/sos/${sosId}/respond`, {
      method: "POST",
      token: r.token,
      body: { type: "seen" },
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const body = res.body as any;
    assert.equal(body.type, "seen");
    assert.equal(body.member.user.name, "Recipient");
    assert.ok(typeof body.createdAt === "string" && body.createdAt.length > 0);
  });

  await check("the active event lists the acknowledgment for the sender", async () => {
    const res = await api("/api/family/sos/active", { token: s.token });
    assert.equal(res.status, 200);
    const event = (res.body as any[]).find((e) => e.id === sosId);
    assert.ok(event, "active SOS present");
    assert.equal(event.responses.length, 1);
    assert.equal(event.responses[0].member.user.name, "Recipient");
  });

  console.log("§2 - sender cannot acknowledge their own SOS");
  await check("sender 'seen' on own SOS is refused (400)", async () => {
    const res = await api(`/api/family/sos/${sosId}/respond`, {
      method: "POST",
      token: s.token,
      body: { type: "seen" },
    });
    assert.equal(res.status, 400, JSON.stringify(res.body));
  });

  console.log("§3 - stand down, then late acknowledgment is refused");
  const resolveRes = await api(`/api/family/sos/${sosId}/resolve`, {
    method: "POST",
    token: s.token,
  });
  assert.equal(resolveRes.status, 200, JSON.stringify(resolveRes.body));

  await check("late 'seen' after stand-down is refused (400, closed record)", async () => {
    const res = await api(`/api/family/sos/${sosId}/respond`, {
      method: "POST",
      token: r.token,
      body: { type: "seen" },
    });
    assert.equal(res.status, 400, JSON.stringify(res.body));
    assert.match(JSON.stringify(res.body), /ended|no longer/i);
  });

  console.log("§4 - retained history keeps who/when, never where");
  await check("history returns the ended event with its responses and no location", async () => {
    const res = await api("/api/family/sos/history", { token: s.token });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const event = (res.body as any[]).find((e) => e.id === sosId);
    assert.ok(event, "ended SOS present in history");
    assert.equal(event.status, "resolved");
    assert.ok(event.resolvedAt, "resolvedAt kept");
    assert.equal(event.responses.length, 1, "acknowledgment retained");
    assert.equal(event.responses[0].member.user.name, "Recipient");
    for (const key of LOCATION_KEYS) {
      assert.equal(event[key], null, `${key} must be null in history`);
    }
  });

  await check("the recipient sees the same history entry", async () => {
    const res = await api("/api/family/sos/history", { token: r.token });
    assert.equal(res.status, 200);
    assert.ok((res.body as any[]).some((e) => e.id === sosId));
  });

  console.log("§5 - the ended event is no longer active");
  await check("/sos/active omits the stood-down event", async () => {
    const res = await api("/api/family/sos/active", { token: s.token });
    assert.equal(res.status, 200);
    assert.ok(!(res.body as any[]).some((e) => e.id === sosId));
  });

  console.log("§6 - nobody outside the circle can read its history");
  await check("outsider gets no history for a circle they are not in", async () => {
    const res = await api("/api/family/sos/history", { token: o.token });
    assert.ok(
      res.status === 403 || res.status === 404,
      `expected 403/404, got ${res.status}: ${JSON.stringify(res.body)}`,
    );
  });

  console.log(`\nAll ${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exit(1);
});

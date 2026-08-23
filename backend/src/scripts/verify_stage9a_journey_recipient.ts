/**
 * Stage 9A verification script — real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres+PostGIS
 * database. Covers the Journey Sharing recipient experience added this
 * stage:
 *
 *   - GET /api/family/journeys/:journeyId (new): a picked recipient can
 *     retrieve the journey; an in-circle member who was NOT picked gets
 *     403; someone with no membership in that circle at all gets 404;
 *     the traveller themselves can always retrieve their own journey.
 *   - The same endpoint still works once the journey has ended - a
 *     recipient's notification can be tapped late and still show the
 *     final read-only state (times kept, location cleared), matching the
 *     locked "snapshots keep the event log, delete the location" rule.
 *   - 15-minute journeys (the shortest offered duration) work end to end.
 *   - Live-journey position updates posted by the traveller are visible to
 *     the recipient through the same endpoint (the "live updates" this
 *     stage wires the recipient viewer up to), and are gone once stopped.
 *
 * Setup: same throwaway Postgres+PostGIS pattern as
 * verify_stage7b_admin_hardening.ts / verify_stage8_release_audit.ts - see
 * those files' header comments and V1_RECONCILIATION_REPORT.md §26 for the
 * exact commands. Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_stage9a_journey_recipient.ts
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
  const email = `stage9a-${label}-${uniqueSuffix}@test.local`;
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

async function main() {
  console.log("Stage 9A verification (real HTTP + real DB)\n");

  console.log("setup");

  // A owns a circle, invites B (the picked recipient) and C (a member who
  // will NOT be picked), and D stays in a circle of their own entirely.
  const a = await registerUser("traveller");
  const b = await registerUser("recipient");
  const c = await registerUser("bystander");
  const d = await registerUser("unrelated");

  const circleRes = await api("/api/family/circle", {
    method: "POST",
    token: a.token,
    body: { name: "The Travellers" },
  });
  assert.equal(circleRes.status, 201);

  const joinAs = async (token: string) => {
    const invite = await api("/api/family/invites", {
      method: "POST",
      token: a.token,
    });
    assert.equal(invite.status, 201);
    const join = await api("/api/family/join", {
      method: "POST",
      token,
      body: { code: (invite.body as any).code },
    });
    assert.equal(join.status, 200, JSON.stringify(join.body));
  };
  await joinAs(b.token);
  await joinAs(c.token);

  await api("/api/family/circle", {
    method: "POST",
    token: d.token,
    body: { name: "A Different Circle" },
  });

  const circle = (await api("/api/family/circle", { token: a.token }))
    .body as any;
  const memberIdOf = (userId: string) =>
    (circle.members as any[]).find((m) => m.userId === userId).id as string;
  const bMemberId = memberIdOf(b.userId);
  const cMemberId = memberIdOf(c.userId);
  console.log("  setup - one circle (A owns, B and C joined), D is unrelated\n");

  console.log("§26 access control - GET /api/family/journeys/:journeyId");

  const start = await api("/api/family/journeys", {
    method: "POST",
    token: a.token,
    body: {
      durationMinutes: 15,
      recipientMemberIds: [bMemberId],
      isLive: false,
    },
  });
  assert.equal(start.status, 201, JSON.stringify(start.body));
  const journeyId = (start.body as any).id as string;

  await check("15-minute journey started with the exact requested duration", () => {
    assert.equal((start.body as any).grantedMinutes, 15);
    assert.equal((start.body as any).status, "active");
    assert.equal((start.body as any).canExtend, true);
  });

  await check("the picked recipient (B) can retrieve the journey", async () => {
    const res = await api(`/api/family/journeys/${journeyId}`, { token: b.token });
    assert.equal(res.status, 200);
    assert.equal((res.body as any).id, journeyId);
    assert.equal((res.body as any).memberName, "traveller");
  });

  await check("the traveller (A) can retrieve their own journey", async () => {
    const res = await api(`/api/family/journeys/${journeyId}`, { token: a.token });
    assert.equal(res.status, 200);
  });

  await check(
    "an in-circle member who was NOT picked (C) is denied (403), not just filtered client-side",
    async () => {
      const res = await api(`/api/family/journeys/${journeyId}`, { token: c.token });
      assert.equal(res.status, 403);
    },
  );

  await check(
    "someone with no membership in that circle at all (D) is denied (404)",
    async () => {
      const res = await api(`/api/family/journeys/${journeyId}`, { token: d.token });
      assert.equal(res.status, 404);
    },
  );

  await check("an unknown journey id 404s for the traveller too", async () => {
    const res = await api(
      `/api/family/journeys/00000000-0000-0000-0000-000000000000`,
      { token: a.token },
    );
    assert.equal(res.status, 404);
  });

  await check("unauthenticated requests are rejected (401), not routed at all", async () => {
    const res = await api(`/api/family/journeys/${journeyId}`);
    assert.equal(res.status, 401);
  });

  console.log();
  console.log("§26 ended journey stays visible, read-only, with location cleared");

  const stop = await api(`/api/family/journeys/${journeyId}/stop`, {
    method: "POST",
    token: a.token,
  });
  assert.equal(stop.status, 200);

  await check(
    "the recipient can still open the notification after it ends and sees the final state",
    async () => {
      const res = await api(`/api/family/journeys/${journeyId}`, { token: b.token });
      assert.equal(res.status, 200);
      assert.equal((res.body as any).status, "ended");
      assert.equal((res.body as any).latitude, null);
      assert.equal((res.body as any).longitude, null);
      assert.ok((res.body as any).endedAt, "endedAt should be set");
    },
  );

  await check(
    "the non-picked bystander (C) is still denied after the journey ended",
    async () => {
      const res = await api(`/api/family/journeys/${journeyId}`, { token: c.token });
      assert.equal(res.status, 403);
    },
  );

  await check(
    "an ended journey drops out of the shared-with-me list (still running only)",
    async () => {
      const res = await api("/api/family/journeys/shared", { token: b.token });
      assert.equal(res.status, 200);
      assert.ok(
        !(res.body as any[]).some((j) => j.id === journeyId),
        "ended journey should not appear in the running-only list",
      );
    },
  );

  console.log();
  console.log("§26 live position updates reach the recipient, and stop when the journey stops");

  const liveStart = await api("/api/family/journeys", {
    method: "POST",
    token: a.token,
    body: {
      durationMinutes: 30,
      recipientMemberIds: [bMemberId],
      isLive: true,
    },
  });
  assert.equal(liveStart.status, 201);
  const liveJourneyId = (liveStart.body as any).id as string;

  const point = await api(`/api/family/journeys/${liveJourneyId}/point`, {
    method: "POST",
    token: a.token,
    body: { latitude: -27.4698, longitude: 153.0251, locationLabel: "Brisbane" },
  });
  assert.equal(point.status, 200);

  await check(
    "the recipient sees the position the traveller just posted (reusing the same read path, not a second stream)",
    async () => {
      const res = await api(`/api/family/journeys/${liveJourneyId}`, {
        token: b.token,
      });
      assert.equal(res.status, 200);
      assert.equal((res.body as any).latitude, -27.4698);
      assert.equal((res.body as any).longitude, 153.0251);
      assert.equal((res.body as any).isLive, true);
    },
  );

  await check(
    "the non-picked bystander (C) never sees that live position either",
    async () => {
      const res = await api(`/api/family/journeys/${liveJourneyId}`, {
        token: c.token,
      });
      assert.equal(res.status, 403);
    },
  );

  await api(`/api/family/journeys/${liveJourneyId}/stop`, {
    method: "POST",
    token: a.token,
  });

  await check(
    "once stopped, the recipient's next read shows it ended with the position cleared",
    async () => {
      const res = await api(`/api/family/journeys/${liveJourneyId}`, {
        token: b.token,
      });
      assert.equal(res.status, 200);
      assert.equal((res.body as any).status, "ended");
      assert.equal((res.body as any).latitude, null);
    },
  );

  console.log(`\n${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exitCode = 1;
});

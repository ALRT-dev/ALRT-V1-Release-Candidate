/**
 * Family location consent verification script — real HTTP requests and
 * real Socket.IO connections against a running instance of this backend,
 * backed by a throwaway local Postgres+PostGIS database. Synthetic
 * accounts and a fixed fictional coordinate only; never run against
 * production.
 *
 * Policy under test (approved, "Option A"): a member's saved sharing level
 * is a CEILING for check-ins and snapshots.
 *   precise      -> a check-in may carry coordinates; snapshot pin shown
 *   approximate  -> no coordinates on the check-in row; snapshot gives a
 *                   suburb label only (serializeMember downgrades it)
 *   alertsOnly   -> nothing shared through a check-in
 *   off          -> nothing shared through a check-in
 * SOS live-location consent is deliberately OUT of scope: an SOS's own
 * position and trail are an explicit share and are not changed here. Only
 * the nested member row that rides along with SOS payloads is projected to
 * identity fields, and stand-down now wipes the trigger position.
 *
 * Proves, over HTTP and over the socket events other members receive:
 *   P1  createCheckIn honours the ceiling (rows, responses, familyCheckIn)
 *   P2  nested member rows carry no location keys anywhere they ride along
 *       (check-ins, scheduled check-ins, SOS active/history/trigger/respond)
 *   P3  check-in coordinates expire at read time after one hour, with the
 *       scheduler OFF (RUN_SCHEDULED_JOBS_IN_TEST unset)
 *   P5  manual stand-down nulls the SOS trigger position on the row
 *   OK  positive controls: a precise member's coordinates DO reach the
 *       circle over HTTP and socket, an approximate member's suburb label
 *       DOES reach it, journey recipient gating and SOS trail access are
 *       unchanged, and a former member receives nothing.
 *
 * Run with the backend up on TEST_SERVER_URL (default http://localhost:4123):
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_family_location_consent.ts
 * P3 and P5 use direct SQL through Prisma (same DATABASE_URL) to age a row
 * and to read a column the API never exposes.
 *
 * EXPECT_SUBURB_LABEL=1 (set it on TEST, where reverse geocoding is
 * configured) makes the approximate-level checks STRICT: the suburb label
 * must be present for the circle while precise coordinates stay null. Left
 * unset, a null label is tolerated (no geocoding key on a laptop).
 */

import assert from "node:assert/strict";
import { io as socketClient, type Socket } from "socket.io-client";
import prisma from "../utils/prisma_client.util.js";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const LAT = -27.4705;
const LNG = 153.026;
const LOCATION_KEYS = [
  "latitude",
  "longitude",
  "locationLabel",
  "locationUpdatedAt",
  "locationExpiresAt",
  "locationSharedVia",
  "batteryLevel",
  "isMoving",
  "currentPlaceId",
];

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
  let json: any = null;
  try {
    json = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body: json };
};

const registerUser = async (label: string) => {
  const email = `consent-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  const nameRes = await api("/api/user", { method: "PUT", token, body: { name: label } });
  assert.equal(nameRes.status, 200, `name ${label}`);
  return { label, token };
};

const noLocationKeys = (obj: any, what: string) => {
  assert.ok(obj && typeof obj === "object", `${what} must be an object`);
  for (const key of LOCATION_KEYS) {
    assert.ok(!(key in obj), `${what} must not carry "${key}" (got ${JSON.stringify(obj[key])})`);
  }
  assert.equal(typeof obj.id, "string", `${what}.id`);
  assert.ok(obj.user && typeof obj.user.name === "string", `${what}.user.name`);
};

const setLevel = async (token: string, sharingLevel: string) => {
  const res = await api("/api/family/members/me", { method: "PUT", token, body: { sharingLevel } });
  assert.equal(res.status, 200, `set level ${sharingLevel}: ${JSON.stringify(res.body)}`);
};

const checkInWithCoords = async (token: string) => {
  const res = await api("/api/family/check-in", {
    method: "POST",
    token,
    body: { status: "safe", latitude: LAT, longitude: LNG },
  });
  assert.equal(res.status, 201, `check-in: ${JSON.stringify(res.body)}`);
  return res.body;
};

const latestCheckInFor = async (token: string, memberId: string) => {
  const res = await api("/api/family/check-ins?limit=20", { token });
  assert.equal(res.status, 200);
  const row = (res.body as any[]).find((r) => r.memberId === memberId);
  assert.ok(row, "expected a check-in row for the member");
  return row;
};

const memberFromCircle = async (token: string, memberId: string) => {
  const res = await api("/api/family/circle", { token });
  assert.equal(res.status, 200);
  return (res.body.members as any[]).find((m) => m.id === memberId);
};

/** Connects a socket as `token` and records every family event it receives. */
const listen = (token: string) =>
  new Promise<{ socket: Socket; events: { event: string; data: any }[] }>((resolve, reject) => {
    const events: { event: string; data: any }[] = [];
    const socket = socketClient(BASE_URL, { auth: { token }, transports: ["websocket"] });
    for (const event of [
      "familyCheckIn",
      "familyLocationUpdate",
      "familySos",
      "familySosResponse",
      "familySosResolved",
      "familyJourneyShared",
      "familyCircleUpdate",
    ]) {
      socket.on(event, (data: any) => events.push({ event, data }));
    }
    socket.on("connect", () => resolve({ socket, events }));
    socket.on("connect_error", (err) => reject(err));
  });

const settle = (ms = 700) => new Promise((r) => setTimeout(r, ms));
const lastEvent = (events: { event: string; data: any }[], name: string) =>
  [...events].reverse().find((e) => e.event === name)?.data;

const main = async () => {
  console.log("setup - owner A, members B and C in one circle; sockets for A and C");
  const a = await registerUser("owner-A");
  const b = await registerUser("member-B");
  const c = await registerUser("member-C");

  const circleRes = await api("/api/family/circle", {
    method: "POST",
    token: a.token,
    body: { name: "Consent Verify Circle" },
  });
  assert.equal(circleRes.status, 201, JSON.stringify(circleRes.body));
  for (const u of [b, c]) {
    const invite = await api("/api/family/invites", { method: "POST", token: a.token });
    assert.equal(invite.status, 201, JSON.stringify(invite.body));
    const join = await api("/api/family/join", { method: "POST", token: u.token, body: { code: invite.body.code } });
    assert.equal(join.status, 200, JSON.stringify(join.body));
  }
  const bCircle = await api("/api/family/circle", { token: b.token });
  const bMemberId = bCircle.body.myMemberId as string;
  const cCircle = await api("/api/family/circle", { token: c.token });
  const cMemberId = cCircle.body.myMemberId as string;
  assert.ok(bMemberId && cMemberId);

  const aSock = await listen(a.token);
  const cSock = await listen(c.token);
  await settle(300);
  console.log("  setup done\n");

  // ------------------------------------------------------------------ P1
  console.log("P1 - the saved sharing level is a ceiling for check-in coordinates");
  for (const level of ["off", "alertsOnly", "approximate"]) {
    await setLevel(b.token, level);
    aSock.events.length = 0;
    const created = await checkInWithCoords(b.token);
    await settle();
    await check(`${level}: the sender's own response carries no coordinates`, () => {
      assert.equal(created.latitude, null);
      assert.equal(created.longitude, null);
    });
    await check(`${level}: GET /check-ins shows the check-in with null coordinates to A`, async () => {
      const row = await latestCheckInFor(a.token, bMemberId);
      assert.equal(row.latitude, null);
      assert.equal(row.longitude, null);
    });
    await check(`${level}: the familyCheckIn socket event A received carries no coordinates`, () => {
      const ev = lastEvent(aSock.events, "familyCheckIn");
      assert.ok(ev, "A must receive familyCheckIn");
      assert.equal(ev.memberId, bMemberId);
      assert.equal(ev.latitude, null);
      assert.equal(ev.longitude, null);
      noLocationKeys(ev.member, "socket familyCheckIn.member");
    });
    await check(`${level}: A's circle view shows B with no precise pin`, async () => {
      const m = await memberFromCircle(a.token, bMemberId);
      assert.equal(m.latitude, null);
      assert.equal(m.longitude, null);
      if (level === "approximate") {
        // Authorised suburb-only sharing: the label reaches the circle, the
        // pin never does. Strict on TEST (EXPECT_SUBURB_LABEL=1), tolerant
        // locally where no geocoding key exists.
        if (process.env.EXPECT_SUBURB_LABEL === "1") {
          assert.equal(typeof m.locationLabel, "string", "approximate: suburb label expected");
          assert.ok(m.locationLabel.length > 0, "approximate: suburb label expected");
          assert.equal(typeof m.locationExpiresAt, "string", "approximate: snapshot expiry expected");
        }
      } else {
        assert.equal(m.locationLabel, null);
      }
    });
  }

  console.log("\nOK - positive control: a precise member's deliberate share still reaches the circle");
  await setLevel(b.token, "precise");
  aSock.events.length = 0;
  const preciseCreated = await checkInWithCoords(b.token);
  await settle();
  await check("precise: the check-in row carries the coordinates B sent", async () => {
    assert.equal(preciseCreated.latitude, LAT);
    const row = await latestCheckInFor(a.token, bMemberId);
    assert.equal(row.latitude, LAT);
    assert.equal(row.longitude, LNG);
  });
  await check("precise: A's familyCheckIn socket event carries the coordinates, member still identity-only", () => {
    const ev = lastEvent(aSock.events, "familyCheckIn");
    assert.equal(ev.latitude, LAT);
    noLocationKeys(ev.member, "socket familyCheckIn.member");
  });
  await check("precise: A's circle view shows B's snapshot pin (serializeMember, precise)", async () => {
    const m = await memberFromCircle(a.token, bMemberId);
    assert.equal(m.latitude, LAT);
    assert.equal(m.longitude, LNG);
  });
  await check("precise: A received familyLocationUpdate with the pin (existing snapshot path unchanged)", () => {
    const ev = lastEvent(aSock.events, "familyLocationUpdate");
    assert.ok(ev, "familyLocationUpdate expected");
    assert.equal(ev.latitude, LAT);
  });

  // ------------------------------------------------------------------ P2
  console.log("\nP2 - nested member rows are identity-only everywhere they ride along");
  await setLevel(b.token, "approximate");
  const snap = await api("/api/family/location", {
    method: "POST",
    token: b.token,
    body: { latitude: LAT, longitude: LNG },
  });
  assert.equal(snap.status, 200, JSON.stringify(snap.body));
  await check("approximate + POST /location: circle sees B's suburb label, never the pin", async () => {
    const m = await memberFromCircle(a.token, bMemberId);
    assert.equal(m.latitude, null);
    assert.equal(m.longitude, null);
    if (process.env.EXPECT_SUBURB_LABEL === "1") {
      assert.ok(typeof m.locationLabel === "string" && m.locationLabel.length > 0, "suburb label expected");
    }
    const ev = lastEvent(aSock.events, "familyLocationUpdate");
    assert.ok(ev, "A must receive familyLocationUpdate for B's snapshot");
    assert.equal(ev.latitude, null, "socket familyLocationUpdate must not carry a precise pin for approximate");
  });
  await check("GET /check-ins: member has no location keys", async () => {
    const row = await latestCheckInFor(a.token, bMemberId);
    noLocationKeys(row.member, "check-in.member");
  });
  const sched = await api("/api/family/scheduled-check-ins", {
    method: "POST",
    token: b.token,
    body: { timeOfDay: "09:00", mode: "prompted" },
  });
  assert.equal(sched.status, 201, JSON.stringify(sched.body));
  await check("GET /scheduled-check-ins: member has no location keys", async () => {
    const res = await api("/api/family/scheduled-check-ins", { token: a.token });
    assert.equal(res.status, 200);
    const row = (res.body as any[]).find((r) => r.memberId === bMemberId);
    assert.ok(row);
    noLocationKeys(row.member, "scheduled.member");
  });

  aSock.events.length = 0;
  cSock.events.length = 0;
  const sosRes = await api("/api/family/sos", {
    method: "POST",
    token: b.token,
    body: { isLive: true, latitude: LAT, longitude: LNG },
  });
  assert.equal(sosRes.status, 201, JSON.stringify(sosRes.body));
  const sosId = sosRes.body.id as string;
  await settle();
  await check("POST /sos response: SOS position kept (explicit share), member identity-only", () => {
    assert.equal(sosRes.body.latitude, LAT);
    noLocationKeys(sosRes.body.member, "sos.member");
  });
  await check("familySos socket event: SOS position kept, member identity-only", () => {
    const ev = lastEvent(aSock.events, "familySos");
    assert.ok(ev, "A must receive familySos");
    assert.equal(ev.latitude, LAT);
    noLocationKeys(ev.member, "socket familySos.member");
  });
  await check("GET /sos/active: member and responses[].member identity-only", async () => {
    const res = await api("/api/family/sos/active", { token: a.token });
    assert.equal(res.status, 200);
    const ev = (res.body as any[]).find((e) => e.id === sosId);
    assert.ok(ev);
    assert.equal(ev.latitude, LAT, "the SOS's own position is unchanged by this work");
    noLocationKeys(ev.member, "active.member");
  });
  aSock.events.length = 0;
  const respond = await api(`/api/family/sos/${sosId}/respond`, {
    method: "POST",
    token: c.token,
    body: { type: "seen" },
  });
  assert.ok([200, 201].includes(respond.status), JSON.stringify(respond.body));
  await settle();
  await check("POST /sos/:id/respond response and familySosResponse event: member identity-only", () => {
    noLocationKeys(respond.body.member, "respond.member");
    const ev = lastEvent(aSock.events, "familySosResponse");
    assert.ok(ev, "A must receive familySosResponse");
    noLocationKeys(ev.member, "socket familySosResponse.member");
  });
  await check("GET /sos/active responses[].member identity-only", async () => {
    const res = await api("/api/family/sos/active", { token: a.token });
    const ev = (res.body as any[]).find((e) => e.id === sosId);
    assert.ok(ev.responses.length >= 1);
    noLocationKeys(ev.responses[0].member, "active.responses[0].member");
  });
  await check("GET /sos/:id/trail still readable by a circle member (unchanged)", async () => {
    const res = await api(`/api/family/sos/${sosId}/trail`, { token: a.token });
    assert.equal(res.status, 200);
  });

  // ------------------------------------------------------------------ P5
  console.log("\nP5 - manual stand-down wipes the trigger position");
  const resolve = await api(`/api/family/sos/${sosId}/resolve`, { method: "POST", token: b.token });
  assert.equal(resolve.status, 200, JSON.stringify(resolve.body));
  await check("resolve response has null position", () => {
    assert.equal(resolve.body.latitude, null);
    assert.equal(resolve.body.longitude, null);
    assert.equal(resolve.body.locationLabel, null);
  });
  await check("DB row has null position immediately (no purge job needed)", async () => {
    const row = await prisma.familySosEvent.findUnique({ where: { id: sosId } });
    assert.ok(row);
    assert.equal(row.latitude, null);
    assert.equal(row.longitude, null);
    assert.equal(row.status, "resolved");
  });
  await check("GET /sos/history: position null, member and responses[].member identity-only", async () => {
    const res = await api("/api/family/sos/history", { token: a.token });
    assert.equal(res.status, 200);
    const ev = (res.body as any[]).find((e) => e.id === sosId);
    assert.ok(ev);
    assert.equal(ev.latitude, null);
    noLocationKeys(ev.member, "history.member");
    noLocationKeys(ev.responses[0].member, "history.responses[0].member");
  });

  // ------------------------------------------------------------------ P3
  console.log("\nP3 - check-in coordinates expire at read time after one hour (scheduler OFF)");
  await setLevel(c.token, "precise");
  const cCheckIn = await checkInWithCoords(c.token);
  await check("fresh precise check-in is readable with coordinates", async () => {
    const row = await latestCheckInFor(a.token, cMemberId);
    assert.equal(row.latitude, LAT);
  });
  await prisma.familyCheckIn.update({
    where: { id: cCheckIn.id },
    data: { createdAt: new Date(Date.now() - 61 * 60 * 1000) },
  });
  await check("the same row read 61 minutes later has null coordinates", async () => {
    const res = await api("/api/family/check-ins?limit=50", { token: a.token });
    const row = (res.body as any[]).find((r) => r.id === cCheckIn.id);
    assert.ok(row, "row still listed");
    assert.equal(row.latitude, null);
    assert.equal(row.longitude, null);
  });

  // ------------------------------------------------------------------ recipients / former member
  console.log("\nOK - recipient permissions and former-member isolation are unchanged");
  const journey = await api("/api/family/journeys", {
    method: "POST",
    token: a.token,
    body: { durationMinutes: 15, recipientMemberIds: [bMemberId], isLive: false },
  });
  assert.equal(journey.status, 201, JSON.stringify(journey.body));
  const journeyId = journey.body.id as string;
  await check("a picked recipient can read the journey; an unpicked member cannot", async () => {
    const asB = await api(`/api/family/journeys/${journeyId}`, { token: b.token });
    assert.equal(asB.status, 200);
    const asC = await api(`/api/family/journeys/${journeyId}`, { token: c.token });
    assert.equal(asC.status, 403);
  });
  await check("journey payload never carries a raw member row", () => {
    assert.ok(!("member" in journey.body) || journey.body.member == null || !("latitude" in journey.body.member));
  });

  const leave = await api("/api/family/circle/leave", { method: "POST", token: c.token });
  assert.equal(leave.status, 200, JSON.stringify(leave.body));
  cSock.events.length = 0;
  await checkInWithCoords(b.token);
  await settle();
  await check("former member: GET /circle no longer returns the circle (onboarding state, no members)", async () => {
    const res = await api("/api/family/circle", { token: c.token });
    assert.ok(res.status === 404 || res.status === 200, `GET /circle -> ${res.status}`);
    const bodyText = JSON.stringify(res.body ?? null);
    assert.ok(!bodyText.includes(circleRes.body.id), "former member must not see the circle id");
    assert.ok(!bodyText.includes(bMemberId), "former member must not see other members");
  });
  await check("former member: check-ins and active SOS are gone (404)", async () => {
    for (const path of ["/api/family/check-ins", "/api/family/sos/active"]) {
      const res = await api(path, { token: c.token });
      assert.equal(res.status, 404, `${path} -> ${res.status}`);
    }
  });
  await check("former member: SOS trail is 403 and journey is 404", async () => {
    assert.equal((await api(`/api/family/sos/${sosId}/trail`, { token: c.token })).status, 403);
    assert.equal((await api(`/api/family/journeys/${journeyId}`, { token: c.token })).status, 404);
  });
  await check("former member: no familyCheckIn socket event after leaving", () => {
    assert.equal(cSock.events.filter((e) => e.event === "familyCheckIn").length, 0);
  });

  aSock.socket.close();
  cSock.socket.close();
  await prisma.$disconnect();
  console.log(`\nAll ${passed} checks passed.`);
};

main().catch(async (error) => {
  console.error("\nFAILED:", error);
  await prisma.$disconnect().catch(() => undefined);
  process.exit(1);
});

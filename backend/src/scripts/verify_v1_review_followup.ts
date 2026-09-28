/**
 * Review follow-up (29 Sep 2026): SOS validation before any location side
 * effect, per-SOS location modes and precision, SOS-only live points,
 * preview matching backend eligibility, journey precision, effective-time
 * tier changes, Restore product matching and ambiguous-upgrade recovery.
 *
 * Real HTTP against a local backend (BILLING_ENABLED=true), simulated
 * RevenueCat webhooks and a fake RevenueCat server API served here. Reads
 * the database directly (same DATABASE_URL) to prove nothing was written.
 * Backend behaviour only: NOT store-sandbox, deployed TEST or device
 * evidence.
 *
 * Run:
 *   TEST_SERVER_URL=http://localhost:55450 DATABASE_URL=... \
 *     npx tsx src/scripts/verify_v1_review_followup.ts
 */

import http from "node:http";
import { PrismaClient } from "@prisma/client";
import { io as socketClient, type Socket } from "socket.io-client";
import assert from "node:assert/strict";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const RC_AUTH = process.env.RC_TEST_AUTH || "Bearer local-rc-test";

let passed = 0;
const failures: string[] = [];
const check = async (label: string, fn: () => Promise<void>) => {
  try {
    await fn();
    passed += 1;
    console.log(`  ok - ${label}`);
  } catch (error) {
    failures.push(label);
    console.log(`  FAIL - ${label}\n      ${(error as Error).message}`);
  }
};

const api = async (
  path: string,
  opts: { method?: string; token?: string; body?: unknown; auth?: string } = {},
) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: opts.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}),
      ...(opts.auth ? { Authorization: opts.auth } : {}),
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

interface TestUser {
  token: string;
  id: string;
  name: string;
}

const register = async (name: string): Promise<TestUser> => {
  const email = `v1access-${name}-${crypto.randomUUID().slice(0, 8)}@localtest.invalid`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "LocalTest!2345Xx" },
  });
  assert.equal(res.status, 201, `register ${name}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  await api("/api/user", { method: "PUT", token, body: { name } });
  const me = await api("/api/user", { token });
  const id = (me.body?.id ?? me.body?.user?.id) as string;
  assert.ok(id, `no id for ${name}: ${JSON.stringify(me.body)}`);
  return { token, id, name };
};

let clock = Date.now();
const DAY = 24 * 60 * 60 * 1000;

/** Sends one authenticated RevenueCat event. */
const rc = async (event: Record<string, unknown>) => {
  clock += 1000;
  return api("/api/revenuecat/webhook", {
    method: "POST",
    auth: RC_AUTH,
    body: {
      event: {
        id: crypto.randomUUID(),
        environment: "SANDBOX",
        store: "APP_STORE",
        event_timestamp_ms: clock,
        period_type: "NORMAL",
        ...event,
      },
    },
  });
};

const buy = async (
  user: TestUser,
  tier: "individual" | "family" | "group20" | "group50",
  extra: Record<string, unknown> = {},
) => {
  const tx = `tx-${crypto.randomUUID()}`;
  const res = await rc({
    type: "INITIAL_PURCHASE",
    app_user_id: user.id,
    product_id: `test.${tier}.monthly`,
    original_transaction_id: tx,
    expiration_at_ms: Date.now() + 30 * DAY,
    ...extra,
  });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  assert.equal(res.body.action, "applied", JSON.stringify(res.body));
  return tx;
};

const createGroup = async (user: TestUser, name: string) => {
  const res = await api("/api/family/circle", {
    method: "POST",
    token: user.token,
    body: { name },
  });
  assert.equal(res.status, 201, `create ${name}: ${JSON.stringify(res.body)}`);
  return res.body.id as string;
};

const inviteCode = async (host: TestUser, circleId: string) => {
  const res = await api(`/api/family/invites?circleId=${circleId}`, {
    method: "POST",
    token: host.token,
    body: {},
  });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return res.body.code as string;
};

const join = (user: TestUser, code: string) =>
  api("/api/family/join", { method: "POST", token: user.token, body: { code } });

const joinOk = async (user: TestUser, code: string) => {
  const res = await join(user, code);
  assert.ok(res.status === 200 || res.status === 201, `join: ${res.status} ${JSON.stringify(res.body)}`);
};

const checkIn = (user: TestUser, circleId: string) =>
  api(`/api/family/check-in?circleId=${circleId}`, {
    method: "POST",
    token: user.token,
    body: {},
  });

const sos = (user: TestUser, circleId: string, body: Record<string, unknown> = {}) =>
  api(`/api/family/sos?circleId=${circleId}`, {
    method: "POST",
    token: user.token,
    body: { isLive: false, ...body },
  });

const savePlace = (user: TestUser, n: number) =>
  api("/api/user/subscribe-location", {
    method: "POST",
    token: user.token,
    body: {
      northeastLat: -27.4 + n * 0.01,
      northeastLng: 153.1,
      southwestLat: -27.5 + n * 0.01,
      southwestLng: 153.0,
      name: `Place ${n}`,
    },
  });

const access = async (user: TestUser) => {
  const res = await api("/api/access", { token: user.token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body;
};

const bindViaIntent = async (payer: TestUser, circleId: string, tier: "family" | "group20" | "group50") => {
  const intent = await api("/api/access/sponsorship-intents", {
    method: "POST",
    token: payer.token,
    body: { circleId, tier },
  });
  assert.equal(intent.status, 201, JSON.stringify(intent.body));
  return buy(payer, tier);
};

const prisma = new PrismaClient();

// ---- Fake RevenueCat server API -------------------------------------------
const RC_API_PORT = Number(process.env.RC_API_PORT || 55460);
const storeRecords = new Map<string, Record<string, unknown>>();
let storeApiFails = false;
const fakeApi = http.createServer((req, res) => {
  const match = req.url?.match(/^\/v1\/subscribers\/([^/?]+)/);
  if (req.headers.authorization !== "Bearer local-rc-api" || !match) {
    res.writeHead(401).end();
    return;
  }
  if (storeApiFails) {
    res.writeHead(503).end();
    return;
  }
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ subscriber: { subscriptions: storeRecords.get(decodeURIComponent(match[1]!)) ?? {} } }));
});
const storeHas = (user: TestUser, product: string) =>
  storeRecords.set(user.id, {
    ...(storeRecords.get(user.id) ?? {}),
    [product]: {
      purchase_date: new Date(Date.now() - 1000).toISOString(),
      expires_date: new Date(Date.now() + 30 * DAY).toISOString(),
      is_sandbox: true,
    },
  });

// ---- Sockets ----------------------------------------------------------------
const listen = (token: string) =>
  new Promise<{ socket: Socket; events: { event: string; data: any }[] }>((resolve, reject) => {
    const events: { event: string; data: any }[] = [];
    const socket = socketClient(BASE_URL, { auth: { token }, transports: ["websocket"] });
    for (const event of ["familyLocationUpdate", "familySos", "familySosLocation"]) {
      socket.on(event, (data: any) => events.push({ event, data }));
    }
    socket.on("connect", () => resolve({ socket, events }));
    socket.on("connect_error", (err) => reject(err));
  });
const settle = (ms = 600) => new Promise((r) => setTimeout(r, ms));

const LAT = -27.4698;
const LNG = 153.0251;

const memberOf = async (user: TestUser, circleId: string) =>
  (await prisma.familyMember.findFirst({ where: { userId: user.id, circleId } }))!;

const setLevel = async (user: TestUser, circleId: string, sharingLevel: string) => {
  const res = await api(`/api/family/members/me?circleId=${circleId}`, {
    method: "PUT",
    token: user.token,
    body: { sharingLevel },
  });
  assert.equal(res.status, 200, JSON.stringify(res.body));
};

/** Nothing about [sender] was written to the group's location channel. */
const assertNoGroupWrite = async (sender: TestUser, circleId: string) => {
  const m = await memberOf(sender, circleId);
  assert.equal(m.latitude, null, "group snapshot latitude written");
  assert.equal(m.locationUpdatedAt, null, "group snapshot time written");
  const pings = await prisma.familyLocationPing.count({ where: { memberId: m.id, sosEventId: null } });
  assert.equal(pings, 0, "group location ping written");
};

const sosList = async (owner: TestUser, circleId: string, name: string, memberIds: string[]) => {
  const res = await api(`/api/family/sos-lists?circleId=${circleId}`, {
    method: "POST",
    token: owner.token,
    body: { name, memberIds },
  });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return res.body.id as string;
};

const preview = async (user: TestUser, circleId: string, sosListId?: string) => {
  const res = await api(
    `/api/family/sos/preview?circleId=${circleId}${sosListId ? `&sosListId=${sosListId}` : ""}`,
    { token: user.token },
  );
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body;
};

const main = async () => {
  await new Promise<void>((r) => fakeApi.listen(RC_API_PORT, "127.0.0.1", () => r()));
  console.log("V1 review follow-up (local backend, simulated store)");

  // Group: host H (Individual), selected S (Individual), unselected U
  // (Individual), lapsed L (Free: not eligible in an unsponsored group).
  const H = await register("Host");
  const S = await register("Selected");
  const U = await register("Unselected");
  const L = await register("Lapsed");
  for (const u of [H, S, U]) await buy(u, "individual");
  const g = await createGroup(H, "Mixed");
  for (const u of [S, U, L]) await joinOk(u, await inviteCode(H, g));
  const sId = (await memberOf(S, g)).id;
  const uSock = await listen(U.token);
  const sSock = await listen(S.token);

  console.log("SOS: validation before any location side effect");

  await check("zero eligible recipients: 422, nothing written or broadcast", async () => {
    const lone = await register("Lone");
    await buy(lone, "individual");
    const g2 = await createGroup(lone, "Lone group");
    const free = await register("FreeOnly");
    await joinOk(free, await inviteCode(lone, g2));
    const r = await sos(lone, g2, { latitude: LAT, longitude: LNG, isLive: true, locationMode: "live" });
    assert.equal(r.status, 422);
    assert.equal(r.body.code, "NO_SOS_RECIPIENTS");
    assert.equal(r.body.details.hasCandidates, true);
    await assertNoGroupWrite(lone, g2);
    assert.equal(await prisma.familySosEvent.count({ where: { circleId: g2 } }), 0);
  });

  await check("denied access: 402, nothing written", async () => {
    uSock.events.length = 0;
    const r = await sos(L, g, { latitude: LAT, longitude: LNG, locationMode: "once" });
    assert.equal(r.status, 402);
    assert.equal(r.body.code, "INDIVIDUAL_REQUIRED");
    await assertNoGroupWrite(L, g);
    await settle();
    assert.equal(uSock.events.length, 0, "unselected member told something");
  });

  await check("cross-group preset: 422 naming the preset, nothing written", async () => {
    const other = await createGroup(H, "Other");
    const X = await register("OtherGroup");
    await buy(X, "individual");
    await joinOk(X, await inviteCode(H, other));
    const list = await sosList(H, g, "Mixed list", [sId, (await memberOf(X, other)).id]).catch(
      async () => null,
    );
    // The list API may refuse mixed groups itself; if so, write one the
    // way an old app could have, to prove the send refuses it too.
    const listId =
      list ??
      (
        await prisma.familySosList.create({
          data: { ownerUserId: H.id, name: "Mixed list", memberIds: [sId, (await memberOf(X, other)).id] },
        })
      ).id;
    const r = await sos(H, g, { sosListId: listId, latitude: LAT, longitude: LNG, locationMode: "once" });
    assert.equal(r.status, 422);
    assert.equal(r.body.code, "SOS_PRESET_OTHER_GROUP");
    assert.equal(r.body.details.sosListId, listId);
    await assertNoGroupWrite(H, g);
    const p = await preview(H, g, listId);
    assert.equal(p.state, "presetInvalid");
    assert.equal(p.preset.state, "otherGroup");
  });

  await check("preset with only people from another group: presetInvalid, never 'invite someone'", async () => {
    const other = await createGroup(S, "S other");
    const Y = await register("OnlyOther");
    await buy(Y, "individual");
    await joinOk(Y, await inviteCode(S, other));
    const listId = (
      await prisma.familySosList.create({
        data: { ownerUserId: H.id, name: "Wrong group", memberIds: [(await memberOf(Y, other)).id] },
      })
    ).id;
    const p = await preview(H, g, listId);
    assert.equal(p.state, "presetInvalid");
    assert.equal(p.preset.state, "otherGroup");
  });

  await check("selected vs unselected: only the preset hears it; the group channel is untouched", async () => {
    uSock.events.length = 0;
    sSock.events.length = 0;
    const listId = await sosList(H, g, "Just S", [sId]);
    const p = await preview(H, g, listId);
    assert.equal(p.state, "ok");
    assert.deepEqual(p.recipients.map((r: any) => r.name), ["Selected"]);
    const r = await sos(H, g, { sosListId: listId, latitude: LAT, longitude: LNG, locationMode: "once" });
    assert.equal(r.status, 201, JSON.stringify(r.body));
    assert.deepEqual(r.body.recipientUserIds, [S.id]);
    assert.equal(r.body.locationMode, "once");
    assert.equal(r.body.latitude, LAT);
    await settle();
    assert.ok(sSock.events.some((e) => e.event === "familySos"), "selected member told");
    assert.equal(uSock.events.length, 0, "unselected member received an event");
    await assertNoGroupWrite(H, g);
    const active = await api(`/api/family/sos/active?circleId=${g}`, { token: U.token });
    assert.ok(!(active.body as any[]).some((e) => e.id === r.body.id), "unselected can read it");
    await api(`/api/family/sos/${r.body.id}/resolve`, { method: "POST", token: H.token });
  });

  console.log("SOS: location modes and precision");

  await check("No location: coordinates sent anyway are not stored", async () => {
    const r = await sos(H, g, { latitude: LAT, longitude: LNG, locationMode: "none" });
    assert.equal(r.status, 201);
    assert.equal(r.body.locationMode, "none");
    assert.equal(r.body.latitude, null);
    assert.equal(r.body.locationLabel, null);
    assert.equal(await prisma.familyLocationPing.count({ where: { sosEventId: r.body.id } }), 0);
    const live = await api(`/api/family/sos/${r.body.id}/location`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG },
    });
    assert.equal(live.status, 409, "live points refused when live was not chosen");
    await api(`/api/family/sos/${r.body.id}/resolve`, { method: "POST", token: H.token });
  });

  await check("Share location once: one point, its real capture time, no live points", async () => {
    const at = new Date(Date.now() - 12 * 60 * 1000).toISOString(); // last known, 12 min
    const r = await sos(H, g, {
      latitude: LAT,
      longitude: LNG,
      locationMode: "once",
      locationCapturedAt: at,
      locationAccuracyM: 35,
    });
    assert.equal(r.status, 201);
    assert.equal(r.body.isLive, false);
    assert.equal(new Date(r.body.locationCapturedAt).toISOString(), at, "age disclosed");
    assert.equal(r.body.locationAccuracyM, 35);
    await api(`/api/family/sos/${r.body.id}/resolve`, { method: "POST", token: H.token });
  });

  await check("location choice must agree with isLive; future capture times refused", async () => {
    assert.equal((await sos(H, g, { isLive: false, locationMode: "live", latitude: LAT, longitude: LNG })).status, 400);
    const future = new Date(Date.now() + 10 * 60 * 1000).toISOString();
    assert.equal(
      (await sos(H, g, { locationMode: "once", latitude: LAT, longitude: LNG, locationCapturedAt: future })).status,
      400,
    );
  });

  await check("Share live location: points go to the SOS audience only; stale points refused", async () => {
    uSock.events.length = 0;
    sSock.events.length = 0;
    const listId = await sosList(H, g, "S again", [sId]);
    const r = await sos(H, g, { sosListId: listId, isLive: true, locationMode: "live", latitude: LAT, longitude: LNG });
    assert.equal(r.status, 201);
    const ok = await api(`/api/family/sos/${r.body.id}/location`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT + 0.001, longitude: LNG, accuracy: 12, capturedAt: new Date().toISOString() },
    });
    assert.equal(ok.status, 200, JSON.stringify(ok.body));
    const stale = await api(`/api/family/sos/${r.body.id}/location`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG, capturedAt: new Date(Date.now() - 10 * 60 * 1000).toISOString() },
    });
    assert.equal(stale.status, 400);
    const notMine = await api(`/api/family/sos/${r.body.id}/location`, {
      method: "POST",
      token: S.token,
      body: { latitude: LAT, longitude: LNG },
    });
    assert.equal(notMine.status, 404);
    await settle();
    assert.ok(sSock.events.some((e) => e.event === "familySosLocation"), "audience got the point");
    assert.equal(uSock.events.length, 0, "unselected member got an event");
    await assertNoGroupWrite(H, g);
    const trail = await api(`/api/family/sos/${r.body.id}/trail`, { token: S.token });
    assert.equal(trail.body.points.length, 2, "trail = the SOS's own points");
    // An ordinary snapshot during the SOS is NOT trail data.
    await api(`/api/family/location?circleId=${g}`, { method: "POST", token: H.token, body: { latitude: LAT, longitude: LNG } });
    const trail2 = await api(`/api/family/sos/${r.body.id}/trail`, { token: S.token });
    assert.equal(trail2.body.points.length, 2);
    await api(`/api/family/sos/${r.body.id}/resolve`, { method: "POST", token: H.token });
    await prisma.familyMember.update({
      where: { id: (await memberOf(H, g)).id },
      data: { latitude: null, longitude: null, locationUpdatedAt: null, locationExpiresAt: null, locationLabel: null },
    });
    await prisma.familyLocationPing.deleteMany({ where: { memberId: (await memberOf(H, g)).id } });
  });

  await check("approximate sender: coordinates never stored or delivered, live or once", async () => {
    await setLevel(H, g, "approximate");
    const r = await sos(H, g, { isLive: true, locationMode: "live", latitude: LAT, longitude: LNG });
    assert.equal(r.status, 201);
    assert.equal(r.body.latitude, null);
    assert.equal(r.body.locationPrecision, "approximate");
    const p = await api(`/api/family/sos/${r.body.id}/location`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG },
    });
    assert.equal(p.body.precision, "approximate");
    const row = await prisma.familySosEvent.findUnique({ where: { id: r.body.id } });
    assert.equal(row!.latitude, null);
    assert.equal(await prisma.familyLocationPing.count({ where: { sosEventId: r.body.id } }), 0);
    await api(`/api/family/sos/${r.body.id}/resolve`, { method: "POST", token: H.token });
    await setLevel(H, g, "precise");
  });

  console.log("SOS preview matches backend eligibility");

  await check("preview: eligible names, lapsed excluded with reason, delivery flagged not promised", async () => {
    const p = await preview(H, g);
    assert.equal(p.state, "ok");
    assert.deepEqual(p.recipients.map((r: any) => r.name).sort(), ["Selected", "Unselected"]);
    assert.ok(p.recipients.every((r: any) => r.deliveryLimited === true), "no devices registered here");
    assert.deepEqual(p.excluded, [{ memberId: (await memberOf(L, g)).id, name: "Lapsed", reason: "needs_individual" }]);
  });

  await check("preview: no people, and people but none eligible", async () => {
    const lone = await register("Alone2");
    await buy(lone, "individual");
    const g3 = await createGroup(lone, "Empty");
    assert.equal((await preview(lone, g3)).state, "noPeople");
    const free = await register("Free2");
    await joinOk(free, await inviteCode(lone, g3));
    const p = await preview(lone, g3);
    assert.equal(p.state, "noneEligible");
    assert.equal(p.excluded[0].reason, "needs_individual");
  });

  await check("preview: a removed member makes the preset outdated, or empty when nobody is left", async () => {
    const R = await register("Leaver");
    await buy(R, "individual");
    await joinOk(R, await inviteCode(H, g));
    const rId = (await memberOf(R, g)).id;
    const both = (await prisma.familySosList.create({ data: { ownerUserId: H.id, name: "Both", memberIds: [sId, rId] } })).id;
    const only = (await prisma.familySosList.create({ data: { ownerUserId: H.id, name: "Only R", memberIds: [rId] } })).id;
    await prisma.familyMember.delete({ where: { id: rId } }); // removed without the prune running
    let p = await preview(H, g, both);
    assert.equal(p.preset.state, "outdated");
    assert.equal(p.state, "ok");
    p = await preview(H, g, only);
    assert.equal(p.state, "presetInvalid");
    assert.equal(p.preset.state, "empty");
    const r = await sos(H, g, { sosListId: only, locationMode: "none" });
    assert.equal(r.status, 422);
    assert.equal(r.body.details.presetState, "empty");
    assert.equal(r.body.details.sosListId, only);
  });

  console.log("Journey precision");

  await check("an approximate traveller's journey never stores or delivers coordinates", async () => {
    await setLevel(H, g, "approximate");
    const start = await api(`/api/family/journeys?circleId=${g}`, {
      method: "POST",
      token: H.token,
      body: { durationMinutes: 15, recipientMemberIds: [sId], isLive: true },
    });
    assert.equal(start.status, 201, JSON.stringify(start.body));
    const id = start.body.id;
    const pt = await api(`/api/family/journeys/${id}/point`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG },
    });
    assert.equal(pt.status, 200, JSON.stringify(pt.body));
    const seen = await api(`/api/family/journeys/${id}`, { token: S.token });
    assert.equal(seen.body.latitude, null);
    const row = await prisma.familyJourney.findUnique({ where: { id } });
    assert.equal(row!.latitude, null);
    await api(`/api/family/journeys/${id}/stop`, { method: "POST", token: H.token });
    await setLevel(H, g, "precise");
  });

  console.log("Subscription changes at their effective time");

  await check("advance renewal: tier and capacity stay until the new period starts, then change", async () => {
    const p = await register("Advance");
    await buy(p, "individual");
    const g4 = await createGroup(p, "Advance team");
    const tx = await bindViaIntent(p, g4, "group20");
    const startsAt = Date.now() + 4000;
    const r = await rc({
      type: "RENEWAL",
      app_user_id: p.id,
      product_id: "test.family.monthly",
      original_transaction_id: tx,
      purchased_at_ms: startsAt,
      expiration_at_ms: startsAt + 30 * DAY,
    });
    assert.equal(r.body.action, "applied");
    let grp = (await access(p)).groups.find((x: any) => x.circleId === g4);
    assert.equal(grp.sponsorship.tier, "group20", "changed before its period");
    assert.equal(grp.capacity, 20);
    assert.equal(grp.sponsorship.pendingTier, "family");
    assert.ok(grp.sponsorship.pendingEffectiveAt);
    while (Date.now() < startsAt + 200) await settle(200);
    const a = await access(p);
    grp = a.groups.find((x: any) => x.circleId === g4);
    assert.equal(grp.sponsorship.tier, "family", "not changed at its effective time");
    assert.equal(grp.capacity, 6);
    assert.equal(grp.sponsorship.pendingTier, null);
    assert.equal(a.personal.plan, "individual", "Individual independent");
  });

  await check("duplicate and out-of-order events after a dated change change nothing", async () => {
    const p = await register("Dupes");
    const g5 = await createGroup(p, "Dupes team");
    const tx = await bindViaIntent(p, g5, "group50");
    const startsAt = Date.now() + 60 * 60 * 1000;
    const id = crypto.randomUUID();
    const body = {
      id,
      type: "RENEWAL",
      app_user_id: p.id,
      product_id: "test.group20.monthly",
      original_transaction_id: tx,
      purchased_at_ms: startsAt,
      expiration_at_ms: startsAt + 30 * DAY,
    };
    await rc(body);
    const dup = await rc(body);
    assert.equal(dup.body.action, "duplicate");
    // An older event arriving late (clock goes back) is ignored.
    clock -= 60_000;
    const late = await rc({ type: "RENEWAL", app_user_id: p.id, product_id: "test.group50.monthly", original_transaction_id: tx });
    assert.equal(late.body.action, "ignored");
    clock += 120_000;
    const grp = (await access(p)).groups.find((x: any) => x.circleId === g5);
    assert.equal(grp.sponsorship.tier, "group50");
    assert.equal(grp.sponsorship.pendingTier, "group20");
  });

  console.log("Restore matches the specific purchases");

  await check("active Individual + restored Family whose webhook hasn't landed: partial, not 'restored'", async () => {
    const u = await register("Partial");
    await buy(u, "individual");
    storeHas(u, "test.individual.monthly");
    storeHas(u, "test.family.monthly");
    const r = await api("/api/access/reconcile", {
      method: "POST",
      token: u.token,
      body: { productIds: ["test.individual.monthly", "test.family.monthly"] },
    });
    assert.equal(r.status, 200, JSON.stringify(r.body));
    const byId = Object.fromEntries(r.body.store.products.map((x: any) => [x.productId, x.status]));
    assert.equal(byId["test.individual.monthly"], "confirmed");
    assert.equal(byId["test.family.monthly"], "pending");
  });

  await check("server outage or no key never counts as a comparison", async () => {
    const u = await register("Outage");
    await buy(u, "individual");
    storeApiFails = true;
    const r = await api("/api/access/reconcile", {
      method: "POST",
      token: u.token,
      body: { productIds: ["test.individual.monthly", "test.group20.monthly"] },
    });
    storeApiFails = false;
    assert.equal(r.body.store.checked, false);
    const byId = Object.fromEntries(r.body.store.products.map((x: any) => [x.productId, x.status]));
    assert.equal(byId["test.individual.monthly"], "confirmed", "ALRT's own verified record");
    assert.equal(byId["test.group20.monthly"], "unchecked");
  });

  await check("client ids never grant: unknown, not on the server, and valid unbound", async () => {
    const u = await register("Claims");
    const r = await api("/api/access/reconcile", {
      method: "POST",
      token: u.token,
      body: { productIds: ["test.group50.monthly", "made.up.product"] },
    });
    const byId = Object.fromEntries(r.body.store.products.map((x: any) => [x.productId, x.status]));
    assert.equal(byId["test.group50.monthly"], "notFound");
    assert.equal(byId["made.up.product"], "unknown");
    assert.equal(r.body.access.personal.plan, "free");
    await buy(u, "group50"); // verified, but no intent: unbound
    const again = await api("/api/access/reconcile", {
      method: "POST",
      token: u.token,
      body: { productIds: ["test.group50.monthly"] },
    });
    assert.deepEqual(again.body.store.products[0], {
      productId: "test.group50.monthly",
      tier: "group50",
      status: "confirmed",
      bound: false,
    });
  });

  console.log("Ambiguous upgrade: complete payer recovery");

  await check("payer explicitly replaces their own smaller plan; others and smaller plans refused", async () => {
    const p = await register("Recover");
    await buy(p, "individual");
    const g1 = await createGroup(p, "One");
    const g2 = await createGroup(p, "Two");
    await bindViaIntent(p, g1, "family");
    const oldTx2 = await bindViaIntent(p, g2, "family");
    assert.equal((await intent(p, g1, "group20")).status, 201);
    assert.equal((await intent(p, g2, "group20")).status, 201);
    await rc({ type: "INITIAL_PURCHASE", store: "PLAY_STORE", app_user_id: p.id, product_id: "test.group20.monthly", original_transaction_id: `gpa-${crypto.randomUUID()}`, expiration_at_ms: Date.now() + 30 * DAY });
    let a = await access(p);
    assert.equal(a.unboundSponsorships.length, 1, "left unbound, not guessed");
    const subId = a.unboundSponsorships[0].id;
    // Plain bind is refused, and says the payer may replace.
    const plain = await api(`/api/access/sponsorships/${subId}/bind`, { method: "POST", token: p.token, body: { circleId: g2 } });
    assert.equal(plain.status, 409);
    assert.equal(plain.body.details.replaceable, true);
    // Someone else can't use it.
    const thief = await register("NotPayer");
    const stolen = await api(`/api/access/sponsorships/${subId}/bind`, { method: "POST", token: thief.token, body: { circleId: g2, replaceExisting: true } });
    assert.equal(stolen.status, 403);
    // The payer chooses Two explicitly.
    const ok = await api(`/api/access/sponsorships/${subId}/bind`, { method: "POST", token: p.token, body: { circleId: g2, replaceExisting: true } });
    assert.equal(ok.status, 200, JSON.stringify(ok.body));
    assert.equal(ok.body.replaced.tier, "family");
    assert.equal(ok.body.replaced.mayStillRenew, true, "the old store plan may still renew");
    a = await access(p);
    assert.equal(a.groups.find((x: any) => x.circleId === g2).sponsorship.tier, "group20");
    assert.equal(a.groups.find((x: any) => x.circleId === g1).sponsorship.tier, "family");
    assert.equal(a.unboundSponsorships.length, 0);
    assert.equal(a.personal.plan, "individual");
    // The replaced plan ending later changes nothing.
    await rc({ type: "EXPIRATION", app_user_id: p.id, product_id: "test.family.monthly", original_transaction_id: oldTx2, expiration_at_ms: Date.now() - 1000 });
    assert.equal((await access(p)).groups.find((x: any) => x.circleId === g2).sponsorship.tier, "group20");
  });

  await check("replacement refused when the plan is not bigger, or the group is someone else's", async () => {
    const p = await register("Recover2");
    const g1 = await createGroup(p, "G");
    await bindViaIntent(p, g1, "group20");
    await buy(p, "family"); // unbound Family
    const sub = (await access(p)).unboundSponsorships[0].id;
    const smaller = await api(`/api/access/sponsorships/${sub}/bind`, { method: "POST", token: p.token, body: { circleId: g1, replaceExisting: true } });
    assert.equal(smaller.status, 409);
    assert.equal(smaller.body.code, "PLAN_TOO_SMALL");
    const other = await register("OtherPayer");
    const og = await createGroup(other, "Theirs");
    await bindViaIntent(other, og, "family");
    await joinOk(p, await inviteCode(other, og));
    await buy(p, "group50");
    const big = (await access(p)).unboundSponsorships.find((x: any) => x.tier === "group50").id;
    const theirs = await api(`/api/access/sponsorships/${big}/bind`, { method: "POST", token: p.token, body: { circleId: og, replaceExisting: true } });
    assert.equal(theirs.status, 409);
    assert.equal(theirs.body.code, "GROUP_ALREADY_COVERED");
  });

  uSock.socket.close();
  sSock.socket.close();
  fakeApi.close();
  await prisma.$disconnect();
  console.log(`\n${passed} passed, ${failures.length} failed`);
  if (failures.length) {
    console.log(failures.map((f) => `  - ${f}`).join("\n"));
    process.exit(1);
  }
  process.exit(0);
};

const intent = (user: TestUser, circleId: string, tier: string) =>
  api("/api/access/sponsorship-intents", { method: "POST", token: user.token, body: { circleId, tier } });

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

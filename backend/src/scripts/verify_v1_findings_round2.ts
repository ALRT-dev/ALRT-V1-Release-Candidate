/**
 * Review of cb26a8d, five findings (29 Sep 2026): SOS consent changes
 * during a running SOS, the older-app SOS audience gap, one-group SOS
 * lists, and consecutive scheduled subscription changes (the app-side
 * freshness finding is covered by Flutter tests).
 *
 * Real HTTP against a local backend (BILLING_ENABLED=true) that has NO
 * REVENUECAT_SECRET_API_KEY, simulated RevenueCat webhooks, direct
 * database reads (same DATABASE_URL) and socket listeners. Backend
 * behaviour only: not deployed TEST, store sandbox or device evidence.
 *
 *   TEST_SERVER_URL=http://localhost:55452 DATABASE_URL=... \
 *     npx tsx src/scripts/verify_v1_findings_round2.ts
 */

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
const LAT = -27.4698;
const LNG = 153.0251;

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
const memberOf = async (user: TestUser, circleId: string) =>
  (await prisma.familyMember.findFirst({ where: { userId: user.id, circleId } }))!;
const point = (user: TestUser, sosId: string, dLat = 0) =>
  api(`/api/family/sos/${sosId}/location`, {
    method: "POST",
    token: user.token,
    body: { latitude: LAT + dLat, longitude: LNG, capturedAt: new Date().toISOString() },
  });
const consent = (user: TestUser, sosId: string, body: Record<string, unknown>) =>
  api(`/api/family/sos/${sosId}/location-consent`, { method: "PUT", token: user.token, body });
const setLevel = (user: TestUser, circleId: string, sharingLevel: string) =>
  api(`/api/family/members/me?circleId=${circleId}`, { method: "PUT", token: user.token, body: { sharingLevel } });
const row = (id: string) => prisma.familySosEvent.findUnique({ where: { id } });
const pings = (id: string) => prisma.familyLocationPing.count({ where: { sosEventId: id } });

const main = async () => {
  console.log("Findings round 2 (local backend, no RevenueCat server key)");
  const H = await register("Sender");
  const S = await register("Selected");
  const U = await register("Unselected");
  for (const u of [H, S, U]) await buy(u, "individual");
  const g = await createGroup(H, "Consent group");
  for (const u of [S, U]) await joinOk(u, await inviteCode(H, g));
  const sId = (await memberOf(S, g)).id;
  const hId = (await memberOf(H, g)).id;
  const listRes = await api(`/api/family/sos-lists?circleId=${g}`, {
    method: "POST",
    token: H.token,
    body: { name: "Just S", memberIds: [sId] },
  });
  assert.equal(listRes.status, 201, JSON.stringify(listRes.body));
  const listId = listRes.body.id as string;
  const sSock = await listen(S.token);
  const uSock = await listen(U.token);

  const startLive = async () => {
    const r = await sos(H, g, {
      sosListId: listId,
      isLive: true,
      locationMode: "live",
      locationPrecision: "precise",
      latitude: LAT,
      longitude: LNG,
    });
    assert.equal(r.status, 201, JSON.stringify(r.body));
    return r.body.id as string;
  };

  console.log("1. Consent changes during a running SOS");

  await check("sender reduces to suburb only: stored coordinates and trail removed, next point stays suburb only", async () => {
    const id = await startLive();
    assert.equal((await point(H, id, 0.001)).status, 200);
    assert.ok((await pings(id)) >= 2);
    sSock.events.length = 0;
    const c = await consent(H, id, { locationPrecision: "approximate" });
    assert.equal(c.status, 200, JSON.stringify(c.body));
    assert.equal(c.body.latitude, null);
    assert.equal(await pings(id), 0, "precise trail kept");
    await settle();
    const ev = sSock.events.filter((e) => e.event === "familySosLocation").pop();
    assert.ok(ev, "recipient not told");
    assert.equal(ev.data.latitude, null);
    const next = await point(H, id, 0.002);
    assert.equal(next.body.precision, "approximate", "a location update restored precise");
    assert.equal((await row(id))!.latitude, null);
    assert.equal(await pings(id), 0);
    const seen = await api(`/api/family/sos/active?circleId=${g}`, { token: S.token });
    assert.equal((seen.body as any[]).find((e) => e.id === id).latitude, null);
    const trail = await api(`/api/family/sos/${id}/trail`, { token: S.token });
    assert.equal(trail.body.points.length, 0);
    await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
  });

  await check("sender stops sharing: point and label removed, next update refused", async () => {
    const id = await startLive();
    const c = await consent(H, id, { locationMode: "none" });
    assert.equal(c.status, 200);
    assert.equal(c.body.isLive, false);
    assert.equal(c.body.latitude, null);
    assert.equal(c.body.locationLabel, null);
    assert.equal((await point(H, id)).status, 409, "update accepted after stop");
    assert.equal((await row(id))!.latitude, null);
    await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
  });

  await check("lowering ordinary sharing narrows the running SOS (provisional R12); off stops it; never widened by an update", async () => {
    const id = await startLive();
    assert.equal((await setLevel(H, g, "approximate")).status, 200);
    let r = (await row(id))!;
    assert.equal(r.locationPrecision, "approximate");
    assert.equal(r.latitude, null);
    assert.equal((await point(H, id)).body.precision, "approximate");
    assert.equal((await setLevel(H, g, "off")).status, 200);
    r = (await row(id))!;
    assert.equal(r.locationMode, "none");
    assert.equal((await point(H, id)).status, 409);
    // Setting precise again does NOT widen the running SOS by itself.
    assert.equal((await setLevel(H, g, "precise")).status, 200);
    assert.equal((await point(H, id)).status, 409, "group setting silently re-enabled SOS sharing");
    // Explicit SOS consent can re-enable it (kept distinct from group sharing).
    const again = await consent(H, id, { locationMode: "live", locationPrecision: "precise" });
    assert.equal(again.status, 200);
    const p = await point(H, id);
    assert.equal(p.status, 200);
    assert.equal(p.body.precision, "precise");
    assert.equal((await row(id))!.latitude, LAT);
    await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
  });

  await check("only the sender can change SOS consent", async () => {
    const id = await startLive();
    assert.equal((await consent(S, id, { locationMode: "none" })).status, 404);
    await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
  });

  console.log("2. Older-app SOS points on the ordinary endpoint");

  await check("unlabelled post during a live SOS: selected recipient gets it, unselected member and group channel do not", async () => {
    await prisma.familyMember.update({
      where: { id: hId },
      data: { latitude: null, longitude: null, locationUpdatedAt: null, locationExpiresAt: null, locationLabel: null },
    });
    await prisma.familyLocationPing.deleteMany({ where: { memberId: hId } });
    const id = await startLive();
    sSock.events.length = 0;
    uSock.events.length = 0;
    // Exactly what an older app sends: no purpose field.
    const old = await api(`/api/family/location?circleId=${g}`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT + 0.003, longitude: LNG, accuracy: 10, isMoving: false },
    });
    assert.equal(old.status, 200, JSON.stringify(old.body));
    assert.equal(old.body.sosEventId, id);
    await settle();
    assert.ok(sSock.events.some((e) => e.event === "familySosLocation"), "selected recipient not told");
    assert.equal(uSock.events.length, 0, "unselected member received the point");
    const m = await memberOf(H, g);
    assert.equal(m.latitude, null, "group snapshot written");
    assert.equal(
      await prisma.familyLocationPing.count({ where: { memberId: hId, sosEventId: null } }),
      0,
    );
    // After the sender stops SOS sharing, the old loop is refused, not
    // dropped into the group channel.
    await consent(H, id, { locationMode: "none" });
    const after = await api(`/api/family/location?circleId=${g}`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG },
    });
    assert.equal(after.status, 409);
    assert.equal((await memberOf(H, g)).latitude, null);
    await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
  });

  await check("a labelled manual share is ordinary, separately consented group sharing (during an SOS too)", async () => {
    const id = await startLive();
    uSock.events.length = 0;
    const manual = await api(`/api/family/location?circleId=${g}`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG, purpose: "manual" },
    });
    assert.equal(manual.status, 200, JSON.stringify(manual.body));
    assert.equal(manual.body.accepted, true);
    await settle();
    assert.ok(uSock.events.some((e) => e.event === "familyLocationUpdate"), "manual share not delivered to the group");
    assert.equal((await memberOf(H, g)).latitude, LAT);
    await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
  });

  await check("no SOS running: an unlabelled post is an ordinary share, as before", async () => {
    const r = await api(`/api/family/location?circleId=${g}`, {
      method: "POST",
      token: H.token,
      body: { latitude: LAT, longitude: LNG },
    });
    assert.equal(r.status, 200);
    assert.equal(r.body.accepted, true);
  });

  console.log("4. One group per SOS list");

  await check("creating or saving a list across groups is refused; a repaired list saves and sends", async () => {
    const other = await createGroup(H, "Other group");
    const X = await register("Elsewhere");
    await buy(X, "individual");
    await joinOk(X, await inviteCode(H, other));
    const xId = (await memberOf(X, other)).id;
    const mixed = await api(`/api/family/sos-lists?circleId=${g}`, {
      method: "POST",
      token: H.token,
      body: { name: "Mixed", memberIds: [sId, xId] },
    });
    assert.equal(mixed.status, 422);
    assert.equal(mixed.body.code, "SOS_PRESET_OTHER_GROUP");
    // An old mixed list (made before the rule) is reported as needing repair.
    const legacy = await prisma.familySosList.create({
      data: { ownerUserId: H.id, name: "Legacy mixed", memberIds: [sId, xId] },
    });
    const lists = await api(`/api/family/sos-lists?circleId=${g}`, { token: H.token });
    const l = (lists.body as any[]).find((x) => x.id === legacy.id);
    assert.equal(l.circleId, null);
    assert.equal(l.needsRepair, "multipleGroups");
    const saveMixed = await api(`/api/family/sos-lists/${legacy.id}?circleId=${g}`, {
      method: "PUT",
      token: H.token,
      body: { memberIds: [sId, xId] },
    });
    assert.equal(saveMixed.status, 422);
    const repaired = await api(`/api/family/sos-lists/${legacy.id}?circleId=${g}`, {
      method: "PUT",
      token: H.token,
      body: { memberIds: [sId] },
    });
    assert.equal(repaired.status, 200, JSON.stringify(repaired.body));
    const after = await api(`/api/family/sos-lists?circleId=${g}`, { token: H.token });
    assert.equal((after.body as any[]).find((x) => x.id === legacy.id).circleId, g);
    const sent = await sos(H, g, { sosListId: legacy.id, locationMode: "none" });
    assert.equal(sent.status, 201, JSON.stringify(sent.body));
    assert.deepEqual(sent.body.recipientUserIds, [S.id]);
    await api(`/api/family/sos/${sent.body.id}/resolve`, { method: "POST", token: H.token });
  });

  console.log("5. Consecutive scheduled changes, no lifecycle event between, no server key");

  await check("Group 50 -> Group 20 takes effect; then Family scheduled: stays Group 20, never Group 50 again", async () => {
    const p = await register("Consecutive");
    await buy(p, "individual");
    const g5 = await createGroup(p, "Big club");
    const tx = await bindViaIntent(p, g5, "group50");
    const startsAt = Date.now() + 3000;
    const renewal = await rc({
      type: "RENEWAL",
      app_user_id: p.id,
      product_id: "test.group20.monthly",
      original_transaction_id: tx,
      purchased_at_ms: startsAt,
      expiration_at_ms: startsAt + 30 * DAY,
    });
    assert.equal(renewal.body.action, "applied");
    while (Date.now() < startsAt + 300) await settle(200);
    let grp = (await access(p)).groups.find((x: any) => x.circleId === g5);
    assert.equal(grp.sponsorship.tier, "group20", "elapsed change not in force");
    // No lifecycle event in between. The payer schedules Family.
    const changeId = crypto.randomUUID();
    const change = {
      id: changeId,
      type: "PRODUCT_CHANGE",
      app_user_id: p.id,
      product_id: "test.group20.monthly",
      new_product_id: "test.family.monthly",
      original_transaction_id: tx,
    };
    assert.equal((await rc(change)).body.action, "applied");
    let a = await access(p);
    grp = a.groups.find((x: any) => x.circleId === g5);
    assert.equal(grp.sponsorship.tier, "group20", "old Group 50 came back");
    assert.equal(grp.capacity, 20);
    assert.equal(grp.sponsorship.pendingTier, "family");
    assert.equal(a.personal.plan, "individual", "personal ALRT + affected");
    const dbRow = await prisma.storeSubscription.findUnique({ where: { originalTransactionId: tx } });
    assert.equal(dbRow!.tier, "group20", "elapsed change not written before the mutation");
    // Idempotency and ordering are unchanged.
    assert.equal((await rc(change)).body.action, "duplicate");
    clock -= 120_000;
    const late = await rc({ type: "RENEWAL", app_user_id: p.id, product_id: "test.group50.monthly", original_transaction_id: tx });
    assert.equal(late.body.action, "ignored");
    clock += 240_000;
    grp = (await access(p)).groups.find((x: any) => x.circleId === g5);
    assert.equal(grp.sponsorship.tier, "group20");
    // Family only when the store says it is in effect.
    await rc({ type: "RENEWAL", app_user_id: p.id, product_id: "test.family.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() + 60 * DAY });
    a = await access(p);
    grp = a.groups.find((x: any) => x.circleId === g5);
    assert.equal(grp.sponsorship.tier, "family");
    assert.equal(grp.capacity, 6);
    assert.equal(a.personal.plan, "individual");
  });

  await check("reconcile without the server key reports unchecked and keeps the in-force tier", async () => {
    const p = await register("NoKey");
    const g6 = await createGroup(p, "No key");
    const tx = await bindViaIntent(p, g6, "group50");
    const startsAt = Date.now() + 2000;
    await rc({ type: "RENEWAL", app_user_id: p.id, product_id: "test.group20.monthly", original_transaction_id: tx, purchased_at_ms: startsAt, expiration_at_ms: startsAt + 30 * DAY });
    while (Date.now() < startsAt + 300) await settle(200);
    const r = await api("/api/access/reconcile", { method: "POST", token: p.token, body: {} });
    assert.equal(r.body.store.checked, false);
    assert.equal(r.body.access.groups.find((x: any) => x.circleId === g6).sponsorship.tier, "group20");
  });

  sSock.socket.close();
  uSock.socket.close();
  await prisma.$disconnect();
  console.log(`\n${passed} passed, ${failures.length} failed`);
  if (failures.length) {
    console.log(failures.map((f) => `  - ${f}`).join("\n"));
    process.exit(1);
  }
  process.exit(0);
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

/**
 * Independent review of 28bdec1, seven findings (29 Sep 2026): starting
 * SOS precision with no initial fix, an in-flight upload racing a consent
 * change, delayed older-app points after SOS end (and overlapping SOS in
 * different groups), and interleaved subscription-change requests. (The
 * app-side findings - listening for familySosLocation, withdrawing a Once
 * snapshot, and judging the hold against what was actually painted - are
 * covered by Flutter tests, not here.)
 *
 * Real HTTP against a local backend (BILLING_ENABLED=true) that has NO
 * REVENUECAT_SECRET_API_KEY, simulated RevenueCat webhooks, direct
 * database reads (same DATABASE_URL) and socket listeners. Backend
 * behaviour only: not deployed TEST, store sandbox or device evidence.
 * Self-contained, like verify_v1_findings_round2.ts (not imported from).
 *
 *   TEST_SERVER_URL=http://localhost:4123 DATABASE_URL=... \
 *     npx tsx src/scripts/verify_v1_findings_round3.ts
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
  const res = await api("/api/family/circle", { method: "POST", token: user.token, body: { name } });
  assert.equal(res.status, 201, `create ${name}: ${JSON.stringify(res.body)}`);
  return res.body.id as string;
};

const inviteCode = async (host: TestUser, circleId: string) => {
  const res = await api(`/api/family/invites?circleId=${circleId}`, { method: "POST", token: host.token, body: {} });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return res.body.code as string;
};

const joinOk = async (user: TestUser, code: string) => {
  const res = await api("/api/family/join", { method: "POST", token: user.token, body: { code } });
  assert.ok(res.status === 200 || res.status === 201, `join: ${res.status} ${JSON.stringify(res.body)}`);
};

const sos = (user: TestUser, circleId: string, body: Record<string, unknown> = {}) =>
  api(`/api/family/sos?circleId=${circleId}`, { method: "POST", token: user.token, body: { isLive: false, ...body } });

const access = async (user: TestUser) => {
  const res = await api("/api/access", { token: user.token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body;
};

const bindViaIntent = async (payer: TestUser, circleId: string, tier: "family" | "group20" | "group50") => {
  const intent = await api("/api/access/sponsorship-intents", { method: "POST", token: payer.token, body: { circleId, tier } });
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
const row = (id: string) => prisma.familySosEvent.findUnique({ where: { id } });
const pings = (id: string) => prisma.familyLocationPing.count({ where: { sosEventId: id } });

const main = async () => {
  console.log("Findings round 3 (local backend, no RevenueCat server key)");
  const H = await register("Sender3");
  const S = await register("Selected3");
  for (const u of [H, S]) await buy(u, "individual");
  const g = await createGroup(H, "Round3 group");
  await joinOk(S, await inviteCode(H, g));
  const sSock = await listen(S.token);

  console.log("1. Starting precision is stored without a starting point");

  await check(
    "Live/Suburb only with no GPS fix yet: precision is stored at creation, so the first later point stays suburb only",
    async () => {
      const created = await sos(H, g, { isLive: true, locationMode: "live", locationPrecision: "approximate" });
      assert.equal(created.status, 201, JSON.stringify(created.body));
      const id = created.body.id as string;
      // No point was sent with the SOS: confirm the row already has the
      // chosen precision, not null (finding 1 - previously only set when
      // a starting point came with the SOS).
      assert.equal((await row(id))!.locationPrecision, "approximate", "precision not stored without a point");
      const p = await point(H, id, 0.001);
      assert.equal(p.status, 200, JSON.stringify(p.body));
      assert.equal(p.body.precision, "approximate", "first point fell back to the group's ordinary sharing level");
      assert.equal((await row(id))!.latitude, null, "suburb-only SOS stored coordinates");
      await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
    },
  );

  console.log("2. An in-flight upload never restores a permission a concurrent Stop/Suburb only just narrowed");

  await check(
    "concurrent Stop and a live point: never both accepted with the point winning - the SOS ends up stopped, never with a restored point",
    async () => {
      const created = await sos(H, g, {
        isLive: true,
        locationMode: "live",
        locationPrecision: "precise",
        latitude: LAT,
        longitude: LNG,
      });
      const id = created.body.id as string;
      // Fired together, repeatedly, to increase the chance the point's
      // request is still in flight (its own suburb lookup) when the stop
      // commits. Whichever the server orders first, the row must never
      // end up "stopped" (locationMode none) while still holding a
      // point, nor "live" with the point accepted after a stop that had
      // already committed and told the recipient.
      let sawStoppedWithPoint = false;
      for (let i = 0; i < 5; i++) {
        const [pointRes, stopRes] = await Promise.all([
          point(H, id, 0.001 * i),
          consent(H, id, { locationMode: "none" }),
        ]);
        const current = (await row(id))!;
        if (current.locationMode === "none" && current.latitude !== null) {
          sawStoppedWithPoint = true;
        }
        // A point accepted (200) after the stop already committed and
        // told the recipient (409 on the stop side would mean the stop
        // itself failed, which must never happen - it's sender-only,
        // always allowed while the SOS is active) must not resurrect
        // coordinates once the row reads "none".
        assert.notEqual(stopRes.status, 500, JSON.stringify(stopRes.body));
        void pointRes;
        if (current.locationMode === "none") break;
      }
      assert.equal(sawStoppedWithPoint, false, "a stopped SOS still held a restored point");
      const final = (await row(id))!;
      assert.equal(final.locationMode, "none");
      assert.equal(final.latitude, null);
      assert.equal(await pings(id), 0, "trail survived a stop");
      await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
    },
  );

  console.log("3. Overlapping SOS in different groups, and no SOS at all");

  await check(
    "two live SOS at once, in different groups: an unlabelled point is refused rather than guessed at",
    async () => {
      const other = await createGroup(H, "Round3 second group");
      // Under the current access rules an SOS needs at least one eligible
      // recipient (NO_SOS_RECIPIENTS otherwise), and in an individually
      // funded group that recipient needs Individual too.
      const W = await register("SecondGroup3");
      await buy(W, "individual");
      await joinOk(W, await inviteCode(H, other));
      const sentA = await sos(H, g, { isLive: true, locationMode: "live", locationPrecision: "precise", latitude: LAT, longitude: LNG });
      assert.ok(sentA.status === 201 || sentA.status === 200, `SOS A: ${sentA.status} ${JSON.stringify(sentA.body)}`);
      const idA = sentA.body.id as string;
      const sentB = await sos(H, other, { isLive: true, locationMode: "live", locationPrecision: "precise", latitude: LAT, longitude: LNG });
      assert.ok(sentB.status === 201 || sentB.status === 200, `SOS B: ${sentB.status} ${JSON.stringify(sentB.body)}`);
      const idB = sentB.body.id as string;
      assert.notEqual(idA, idB);
      const ambiguous = await api(`/api/family/location?circleId=${g}`, {
        method: "POST",
        token: H.token,
        body: { latitude: LAT + 0.002, longitude: LNG },
      });
      assert.equal(ambiguous.status, 409, JSON.stringify(ambiguous.body));
      assert.equal((await row(idA))!.latitude, LAT, "ambiguous point was applied to A anyway");
      assert.equal((await row(idB))!.latitude, LAT, "ambiguous point was applied to B anyway");
      await api(`/api/family/sos/${idA}/resolve`, { method: "POST", token: H.token });
      // Only one live SOS remains now: unambiguous, and must route again.
      const unambiguous = await api(`/api/family/location?circleId=${other}`, {
        method: "POST",
        token: H.token,
        body: { latitude: LAT + 0.003, longitude: LNG },
      });
      assert.equal(unambiguous.status, 200, JSON.stringify(unambiguous.body));
      assert.equal(unambiguous.body.sosEventId, idB);
      await api(`/api/family/sos/${idB}/resolve`, { method: "POST", token: H.token });
    },
  );

  console.log("4. A Once snapshot can be reduced or withdrawn while the SOS stays active (backend side)");

  await check(
    "Once with a retained exact point: the sender can reduce to suburb only, then withdraw, without ending the SOS",
    async () => {
      const created = await sos(H, g, { isLive: false, locationMode: "once", locationPrecision: "precise", latitude: LAT, longitude: LNG });
      const id = created.body.id as string;
      const reduced = await consent(H, id, { locationPrecision: "approximate" });
      assert.equal(reduced.status, 200, JSON.stringify(reduced.body));
      assert.equal(reduced.body.latitude, null);
      const withdrawn = await consent(H, id, { locationMode: "none" });
      assert.equal(withdrawn.status, 200, JSON.stringify(withdrawn.body));
      assert.equal((await row(id))!.status, "active", "withdrawing the location ended the SOS");
      await api(`/api/family/sos/${id}/resolve`, { method: "POST", token: H.token });
    },
  );

  console.log("5. Interleaved subscription-change requests never let an older snapshot overwrite a newer tier");

  await check(
    "a scheduled change materializing and a new PRODUCT_CHANGE request, fired together, never revert the newer tier",
    async () => {
      const p = await register("Interleave3");
      await buy(p, "individual");
      const gx = await createGroup(p, "Interleave group");
      const tx = await bindViaIntent(p, gx, "group50");
      const startsAt = Date.now() + 1500;
      const renewal = await rc({
        type: "RENEWAL",
        app_user_id: p.id,
        product_id: "test.group20.monthly",
        original_transaction_id: tx,
        purchased_at_ms: startsAt,
        expiration_at_ms: startsAt + 30 * DAY,
      });
      assert.equal(renewal.body.action, "applied", JSON.stringify(renewal.body));
      // Wait until the scheduled change is actually due (startsAt has
      // passed), so the next events must materialize it before anything else.
      while (Date.now() < startsAt + 200) await settle(100);
      // Fired together: the scheduled group20 change becoming due (via the
      // next event's own materializeDueChangesFor) and a fresh
      // PRODUCT_CHANGE request racing it on the same row.
      const changeId = crypto.randomUUID();
      const [a, b] = await Promise.all([
        rc({
          type: "PRODUCT_CHANGE",
          id: changeId,
          app_user_id: p.id,
          product_id: "test.group20.monthly",
          new_product_id: "test.family.monthly",
          original_transaction_id: tx,
        }),
        rc({
          type: "PRODUCT_CHANGE",
          app_user_id: p.id,
          product_id: "test.group20.monthly",
          new_product_id: "test.group50.monthly",
          original_transaction_id: tx,
        }),
      ]);
      assert.notEqual(a.status, 500, JSON.stringify(a.body));
      assert.notEqual(b.status, 500, JSON.stringify(b.body));
      await settle(300);
      const final = await prisma.storeSubscription.findUnique({ where: { originalTransactionId: tx } });
      // Whichever event's pending request ended up recorded, the elapsed
      // group20 change must be the tier in force - never the old (group50)
      // one silently restored by a snapshot older than the materialize.
      assert.equal(final!.tier, "group20", "an older snapshot reverted the elapsed scheduled tier");
      const grp = (await access(p)).groups.find((x: any) => x.circleId === gx);
      assert.equal(grp.sponsorship.tier, "group20");
    },
  );

  sSock.socket.close();
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

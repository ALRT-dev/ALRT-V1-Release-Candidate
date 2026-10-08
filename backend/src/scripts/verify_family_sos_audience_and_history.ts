/**
 * Family SOS audience, lifecycle and history fixes - direct service calls
 * against a real Postgres, with Firebase intercepted at
 * `sendEachForMulticast` and the Socket.IO server replaced by a recorder,
 * so the exact pushes and socket events are inspected and nothing leaves
 * this process. Users and the group are set up over HTTP.
 *
 * Proves:
 *   1. Someone who left or was removed gets no live SOS point and no
 *      "ended" push, and comes off the running SOS's stored recipients.
 *   2. A second SOS ends the first like a stand-down: its audience gets
 *      familySosResolved and its trail is deleted.
 *   3. Extending emits familySos with the new liveUntil to the audience.
 *   4. An SOS past liveUntil is gone from /sos/active before the sweep;
 *      the sweep's push says "This SOS has expired."
 *   5. The acknowledgment push matches what the SOS shares; "onMyWay"
 *      and "called" responses push nothing.
 *   6. The host leaving announces nothing by push (socket only).
 *   7. A sender who leaves keeps their SOS in "Past SOS", named; leaving
 *      ends their running SOS.
 *   8. Invites default to the group cap (20); a member cannot revoke the
 *      host's invite; a negative SOS accuracy is accepted as unknown; the
 *      removal push names the user when there is no nickname.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_family_sos_audience_and_history.ts
 * against a server started from the same .env.test (TEST_SERVER_URL to
 * override the default http://localhost:4123).
 */

import assert from "node:assert/strict";
import { PrismaClient } from "@prisma/client";
import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";
import { initSocket } from "../utils/socket_client.util.js";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

type Msg = {
  tokens: string[];
  notification?: { title?: string; body?: string };
  data?: Record<string, string>;
};
const pushes: Msg[] = [];
Object.defineProperty(firebaseAdmin, "messaging", {
  value: () => ({
    sendEachForMulticast: async (message: Msg) => {
      pushes.push(message);
      return {
        responses: message.tokens.map(() => ({ success: true })),
        successCount: message.tokens.length,
        failureCount: 0,
      } as any;
    },
  }),
  writable: true,
  configurable: true,
});

type Emitted = { userId: string; event: string; data: any };
const sockets: Emitted[] = [];
initSocket({
  on: () => undefined,
  to: (room: string) => ({
    emit: (event: string, data: any) => {
      sockets.push({ userId: room.replace(/^user_/, ""), event, data });
    },
  }),
} as any);

const api = async (path: string, opts: { method?: string; token?: string; body?: unknown } = {}) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: opts.method ?? "GET",
    headers: { "Content-Type": "application/json", ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}) },
    ...(opts.body !== undefined ? { body: JSON.stringify(opts.body) } : {}),
  });
  let json: unknown = null;
  try { json = await res.json(); } catch { /* no body */ }
  return { status: res.status, body: json as any };
};

type U = { token: string; id: string; label: string; device: string };
const registerUser = async (label: string): Promise<U> => {
  const email = `sos-fixes-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", { method: "POST", body: { email, password: "TestPass123!Xx" } });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  const token = res.body.accessToken as string;
  await api("/api/user", { method: "PUT", token, body: { name: label } });
  const me = await api("/api/user", { token });
  const u = { token, id: (me.body.data ?? me.body).id as string, label, device: `fake-fcm-${label}-${crypto.randomUUID().slice(0, 6)}` };
  await prisma.userDevice.create({ data: { userId: u.id, deviceToken: u.device, platform: "android" } });
  return u;
};

const makeGroup = async (host: U, members: U[], name: string) => {
  const circle = await api("/api/family/circle", { method: "POST", token: host.token, body: { name } });
  assert.equal(circle.status, 201, JSON.stringify(circle.body));
  const circleId = circle.body.id as string;
  for (const m of members) {
    const invite = await api(`/api/family/invites?circleId=${circleId}`, { method: "POST", token: host.token });
    assert.equal(invite.status, 201, JSON.stringify(invite.body));
    const join = await api("/api/family/join", { method: "POST", token: m.token, body: { code: invite.body.code } });
    assert.equal(join.status, 200, JSON.stringify(join.body));
  }
  return circleId;
};

const pushedTo = (u: U, type?: string) =>
  pushes.filter((m) => m.tokens.includes(u.device) && (!type || m.data?.notificationType === type));
const socketTo = (u: U, event: string) => sockets.filter((s) => s.userId === u.id && s.event === event);
const reset = () => { pushes.length = 0; sockets.length = 0; };

async function main() {
  console.log("Family SOS audience, lifecycle and history (real DB, intercepted FCM + socket)\n");
  const svc = await import("../services/family.service.js");

  const host = await registerUser("Host");
  const amy = await registerUser("Amy");
  const ben = await registerUser("Ben");
  const cat = await registerUser("Cat");
  const circleId = await makeGroup(host, [amy, ben, cat], "SOS fixes group");
  const memberIdOf = async (u: U, cid = circleId) =>
    (await prisma.familyMember.findFirstOrThrow({ where: { circleId: cid, userId: u.id } })).id;

  try {
    console.log("§1 people who left or were removed hear nothing more");
    const sos = await svc.triggerSos(amy.id, { latitude: -27.47, longitude: 153.02, isLive: true, locationMode: "live" }, circleId);
    assert.ok(sos.recipientUserIds.includes(ben.id) && sos.recipientUserIds.includes(cat.id));
    reset();
    await svc.leaveCircle(ben.id, circleId);
    await svc.removeMember(host.id, await memberIdOf(cat));
    await check("they come off the running SOS's stored recipients", async () => {
      const row = await prisma.familySosEvent.findUniqueOrThrow({ where: { id: sos.id } });
      assert.ok(!row.recipientUserIds.includes(ben.id), "leaver still a recipient");
      assert.ok(!row.recipientUserIds.includes(cat.id), "removed member still a recipient");
      assert.ok(row.recipientUserIds.includes(host.id));
    });
    await check("the removal push names the user when there is no nickname", () => {
      const bodies = pushedTo(host, "familyCircleUpdate").map((m) => m.notification?.body);
      assert.ok(bodies.includes("Cat was removed from your family circle"), JSON.stringify(bodies));
    });
    reset();
    await svc.recordSosLocation(amy.id, sos.id, { latitude: -27.471, longitude: 153.021 });
    await check("a live point reaches the remaining audience only", () => {
      assert.equal(socketTo(host, "familySosLocation").length, 1);
      assert.equal(socketTo(ben, "familySosLocation").length, 0, "leaver got a live point");
      assert.equal(socketTo(cat, "familySosLocation").length, 0, "removed member got a live point");
    });

    console.log("§2 a second SOS ends the first like a stand-down");
    reset();
    const second = await svc.triggerSos(amy.id, { isLive: false, locationMode: "none" }, circleId);
    await check("the old SOS is cancelled, its audience told, its trail wiped", async () => {
      const old = await prisma.familySosEvent.findUniqueOrThrow({ where: { id: sos.id } });
      assert.equal(old.status, "cancelled");
      assert.equal(old.latitude, null);
      const ended = socketTo(host, "familySosResolved");
      assert.ok(ended.some((e) => e.data.id === sos.id && e.data.status === "cancelled"), JSON.stringify(ended));
      assert.equal(socketTo(ben, "familySosResolved").length, 0);
      const trail = await prisma.familyLocationPing.count({ where: { sosEventId: sos.id } });
      assert.equal(trail, 0, "old SOS trail kept");
    });

    console.log("§5 acknowledgment push wording");
    reset();
    await svc.respondToSos(host.id, second.id, "seen");
    await check("a no-location SOS never claims a live location", () => {
      const ack = pushedTo(amy, "familySosResponse");
      assert.equal(ack.length, 1);
      assert.equal(ack[0]!.notification?.title, "Host has seen your SOS");
      assert.equal(ack[0]!.notification?.body, "Your location is not being shared.");
    });
    reset();
    await svc.respondToSos(host.id, second.id, "onMyWay");
    await svc.respondToSos(host.id, second.id, "called");
    await check("onMyWay and called responses push nothing", () => {
      assert.equal(pushes.length, 0, JSON.stringify(pushes.map((m) => m.notification)));
    });

    console.log("§3 extend tells every open screen");
    // A stale stored audience (as rows from before the departure cleanup
    // still carry) must be narrowed to who is in the group now.
    await prisma.familySosEvent.update({
      where: { id: second.id },
      data: { recipientUserIds: { push: [ben.id, cat.id] } },
    });
    reset();
    const extended = await svc.extendSos(amy.id, second.id);
    await check("familySos with the new liveUntil goes to the sender and the audience", () => {
      for (const u of [amy, host]) {
        const ev = socketTo(u, "familySos");
        assert.equal(ev.length, 1, `${u.label}: ${JSON.stringify(ev)}`);
        assert.equal(new Date(ev[0]!.data.liveUntil).getTime(), extended.liveUntil!.getTime());
        assert.equal(ev[0]!.data.id, second.id);
      }
      assert.equal(socketTo(ben, "familySos").length, 0);
    });

    console.log("§4 expiry");
    await prisma.familySosEvent.update({ where: { id: second.id }, data: { liveUntil: new Date(Date.now() - 1000) } });
    await check("an SOS past liveUntil is not active before the sweep runs", async () => {
      const active = await svc.getActiveSos(host.id, circleId);
      assert.ok(!active.some((e: any) => e.id === second.id));
      const res = await api(`/api/family/sos/active?circleId=${circleId}`, { token: host.token });
      assert.equal(res.status, 200);
      assert.ok(!(res.body as any[]).some((e) => e.id === second.id));
    });
    reset();
    await svc.endLapsedSosEvents();
    await check('the sweep push says "This SOS has expired."', () => {
      const p = pushedTo(host, "familySosResolved").filter((m) => JSON.parse(m.data?.payload ?? "{}").sosEventId === second.id);
      assert.equal(p.length, 1);
      assert.equal(p[0]!.notification?.body, "This SOS has expired.");
      assert.ok(!/1 hour/.test(p[0]!.notification?.body ?? ""));
      // Still named in the stale stored list, but no longer in the group.
      assert.equal(pushedTo(ben).length + pushedTo(cat).length, 0, "a former member got the ended push");
      assert.equal(socketTo(ben, "familySosResolved").length + socketTo(cat, "familySosResolved").length, 0);
    });

    console.log("§7 Past SOS survives the sender leaving");
    const third = await svc.triggerSos(amy.id, { isLive: false, locationMode: "none" }, circleId);
    reset();
    await svc.leaveCircle(amy.id, circleId);
    await check("leaving ends the sender's running SOS and tells its audience", async () => {
      const row = await prisma.familySosEvent.findUniqueOrThrow({ where: { id: third.id } });
      assert.equal(row.status, "resolved");
      assert.equal(row.memberId, null, "memberId should be cleared, not the row deleted");
      assert.equal(row.senderName, "Amy");
      assert.ok(socketTo(host, "familySosResolved").some((e) => e.data.id === third.id));
    });
    await check("the host's Past SOS still lists every one of Amy's SOS, named", async () => {
      const res = await api(`/api/family/sos/history?circleId=${circleId}`, { token: host.token });
      assert.equal(res.status, 200, JSON.stringify(res.body));
      for (const id of [sos.id, second.id, third.id]) {
        const e = (res.body as any[]).find((x) => x.id === id);
        assert.ok(e, `history lost ${id}`);
        assert.equal(e.member.nickname, "Amy");
        assert.equal(typeof e.memberId, "string");
        assert.equal(e.latitude, null);
      }
    });

    console.log("§6 the host leaving announces nothing by push");
    const dan = await registerUser("Dan");
    const eve = await registerUser("Eve");
    const g2 = await makeGroup(dan, [eve], "Host leaves group");
    reset();
    const out = await svc.leaveCircle(dan.id, g2);
    assert.equal(out.outcome, "hostTransition");
    await check("no push to the group, the socket refresh still goes", () => {
      assert.equal(pushedTo(eve).length, 0, JSON.stringify(pushes.map((m) => m.notification)));
      assert.equal(socketTo(eve, "familyCircleUpdate").length, 1);
    });

    console.log("§8 invites and accuracy");
    const fay = await registerUser("Fay");
    const gus = await registerUser("Gus");
    const g3 = await makeGroup(fay, [gus], "Invite group");
    const invite = await api(`/api/family/invites?circleId=${g3}`, { method: "POST", token: fay.token });
    await check("an invite code can fill the group (maxUses 20)", () => {
      assert.equal(invite.body.maxUses, 20);
    });
    await check("a member cannot revoke the host's invite (403 HOST_ONLY)", async () => {
      const res = await api(`/api/family/invites/${invite.body.id}/revoke`, { method: "POST", token: gus.token });
      assert.equal(res.status, 403, JSON.stringify(res.body));
      assert.equal(res.body.code, "HOST_ONLY");
      const host = await api(`/api/family/invites/${invite.body.id}/revoke`, { method: "POST", token: fay.token });
      assert.ok(host.status === 200 || host.status === 204, JSON.stringify(host.body));
    });
    await check("an SOS with accuracy -1 is accepted and stores no accuracy", async () => {
      const res = await api(`/api/family/sos?circleId=${g3}`, {
        method: "POST",
        token: gus.token,
        body: { latitude: -27.47, longitude: 153.02, isLive: true, locationMode: "live", locationAccuracyM: -1 },
      });
      assert.equal(res.status, 201, JSON.stringify(res.body));
      assert.equal(res.body.locationAccuracyM, null);
      const pt = await api(`/api/family/sos/${res.body.id}/location`, {
        method: "POST",
        token: gus.token,
        body: { latitude: -27.471, longitude: 153.021, accuracy: -1 },
      });
      assert.equal(pt.status, 200, JSON.stringify(pt.body));
      await api(`/api/family/sos/${res.body.id}/resolve`, { method: "POST", token: gus.token });
    });
  } finally {
    await prisma.$disconnect();
  }

  console.log(`\nAll ${passed} checks passed.`);
  process.exit(0);
}

main().catch(async (error) => {
  console.error("\nFAILED:", error);
  await prisma.$disconnect();
  process.exit(1);
});

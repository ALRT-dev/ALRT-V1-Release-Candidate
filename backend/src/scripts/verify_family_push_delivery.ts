/**
 * Family push delivery rules (device acceptance item 12) - direct service
 * calls against a real Postgres, Firebase intercepted at
 * `sendEachForMulticast`, so the exact FCM message is inspected and
 * nothing leaves this process.
 *
 * Proves, per event type, keeping their rules separate:
 *   1. SOS start: goes to every other member (never the sender), on the
 *      urgent Android channel, time-sensitive on iOS with sound, opens by
 *      sosEventId, and the lock-screen body carries no suburb.
 *   2. Check-in "safe": ordinary channel; the member's free-text message
 *      is not in the body; recipients exclude the person checking in.
 *   3. Check-in "needs help": urgent channel.
 *   4. Check-in request: ordinary channel, opens by requestId, aimed
 *      recipients only.
 *   5. SOS stand-down: "SOS resolved" to the others only, ordinary channel.
 *   6. A departed member receives nothing after leaving.
 *   7. Test notification: reaches the caller's own devices only.
 *
 * NOT covered (needs a phone): the tray, the lock screen, the sound and
 * the vibration themselves.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_family_push_delivery.ts
 */

import assert from "node:assert/strict";
import { PrismaClient } from "@prisma/client";
import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";

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
  android?: { priority?: string; notification?: { channelId?: string; visibility?: string } };
  apns?: { payload?: { aps?: Record<string, unknown> } };
};
const captured: Msg[] = [];
Object.defineProperty(firebaseAdmin, "messaging", {
  value: () => ({
    sendEachForMulticast: async (message: Msg) => {
      captured.push(message);
      return { responses: message.tokens.map(() => ({ success: true })), successCount: message.tokens.length, failureCount: 0 } as any;
    },
  }),
  writable: true,
  configurable: true,
});

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

const registerUser = async (label: string) => {
  const email = `push-delivery-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", { method: "POST", body: { email, password: "TestPass123!Xx" } });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  const token = res.body.accessToken as string;
  await api("/api/user", { method: "PUT", token, body: { name: label } });
  const me = await api("/api/user", { token });
  return { token, id: (me.body.data ?? me.body).id as string, label, device: `fake-fcm-${label}-${crypto.randomUUID().slice(0, 6)}` };
};

const of = (type: string) => captured.filter((m) => m.data?.notificationType === type);
const tokensOf = (type: string) => new Set(of(type).flatMap((m) => m.tokens));

async function main() {
  console.log("Family push delivery rules (real DB, intercepted FCM)\n");
  const { triggerSos, resolveSos, createCheckIn: checkIn, requestCheckIn, leaveCircle } = await import("../services/family.service.js");

  const host = await registerUser("Host");
  const amy = await registerUser("Amy");
  const tom = await registerUser("Tom");
  const users = [host, amy, tom];
  for (const u of users) {
    await prisma.userDevice.create({ data: { userId: u.id, deviceToken: u.device, platform: "android" } });
  }
  const circle = await api("/api/family/circle", { method: "POST", token: host.token, body: { name: "Delivery circle" } });
  assert.equal(circle.status, 201, JSON.stringify(circle.body));
  const circleId = circle.body.id as string;
  for (const m of [amy, tom]) {
    const invite = await api("/api/family/invites", { method: "POST", token: host.token });
    const join = await api("/api/family/join", { method: "POST", token: m.token, body: { code: invite.body.code } });
    assert.equal(join.status, 200, JSON.stringify(join.body));
  }
  const memberIdOf = async (u: { id: string }) =>
    (await prisma.familyMember.findFirstOrThrow({ where: { circleId, userId: u.id } })).id;

  try {
    console.log("§1 SOS start");
    captured.length = 0;
    const sos = await triggerSos(amy.id, { latitude: -27.47, longitude: 153.02, isLive: false }, circleId);
    await check("everyone else is pushed, never the sender", () => {
      const t = tokensOf("familySos");
      assert.ok(t.has(host.device) && t.has(tom.device));
      assert.ok(!t.has(amy.device));
    });
    await check("urgent Android channel, time-sensitive iOS with sound, private visibility", () => {
      for (const m of of("familySos")) {
        assert.equal(m.android?.notification?.channelId, "alrt_alerts_urgent");
        assert.equal(m.android?.priority, "high");
        assert.equal(m.android?.notification?.visibility, "private");
        assert.equal(m.apns?.payload?.aps?.sound, "default");
        assert.equal(m.apns?.payload?.aps?.["interruption-level"], "time-sensitive");
        assert.equal(m.data?.urgent, "1");
      }
    });
    await check("opens by sosEventId; the body names no suburb or coordinates", () => {
      for (const m of of("familySos")) {
        const p = JSON.parse(m.data!.payload as string);
        assert.equal(p.sosEventId, sos.id);
        assert.equal(p.circleId, circleId);
        assert.ok(!("latitude" in p) && !("locationLabel" in p));
        assert.doesNotMatch(m.notification?.body ?? "", /near /);
        assert.match(m.notification?.title ?? "", /Amy/);
      }
    });

    console.log("\n§2 Check-in safe / needs help");
    captured.length = 0;
    await checkIn(tom.id, { status: "safe", message: "At the pub with Dave, all good" }, circleId);
    await check("safe: ordinary channel, the free-text message stays out of the lock-screen body", () => {
      const msgs = of("familyCheckIn");
      assert.ok(msgs.length > 0);
      for (const m of msgs) {
        assert.equal(m.android?.notification?.channelId, "alrt_alerts");
        assert.doesNotMatch(m.notification?.body ?? "", /Dave/);
        assert.match(m.notification?.title ?? "", /Tom is safe/);
      }
      const t = tokensOf("familyCheckIn");
      assert.ok(!t.has(tom.device), "the person checking in is not pushed");
      assert.ok(t.has(host.device) && t.has(amy.device));
    });
    captured.length = 0;
    await checkIn(tom.id, { status: "needsHelp" as any }, circleId);
    await check("needs help: urgent channel", () => {
      const msgs = of("familyCheckIn");
      assert.ok(msgs.length > 0);
      for (const m of msgs) assert.equal(m.android?.notification?.channelId, "alrt_alerts_urgent");
    });

    console.log("\n§3 Check-in request");
    captured.length = 0;
    const amyMember = await memberIdOf(amy);
    const ask = await requestCheckIn(host.id, { memberIds: [amyMember], message: "Storm near you?" }, circleId);
    await check("aimed at Amy only, ordinary channel, opens by requestId", () => {
      const t = tokensOf("familyCheckInRequest");
      assert.ok(t.has(amy.device));
      assert.ok(!t.has(tom.device) && !t.has(host.device));
      for (const m of of("familyCheckInRequest")) {
        assert.equal(m.android?.notification?.channelId, "alrt_alerts");
        assert.equal(JSON.parse(m.data!.payload as string).requestId, ask.id);
      }
    });

    console.log("\n§4 SOS stand-down");
    captured.length = 0;
    await resolveSos(amy.id, sos.id);
    await check("\"SOS resolved\" goes to the others only, ordinary channel, opens by sosEventId", () => {
      const t = tokensOf("familySosResolved");
      assert.ok(t.has(host.device) && t.has(tom.device));
      assert.ok(!t.has(amy.device));
      for (const m of of("familySosResolved")) {
        assert.equal(m.android?.notification?.channelId, "alrt_alerts");
        assert.equal(JSON.parse(m.data!.payload as string).sosEventId, sos.id);
      }
    });

    console.log("\n§5 A departed member");
    await leaveCircle(tom.id, circleId);
    captured.length = 0;
    await checkIn(amy.id, { status: "safe" }, circleId);
    await check("receives nothing after leaving", () => {
      assert.ok(!tokensOf("familyCheckIn").has(tom.device));
      assert.ok(tokensOf("familyCheckIn").has(host.device));
    });

    console.log("\n§6 Test notification");
    captured.length = 0;
    const test = await api("/api/notifications/test", { method: "POST", token: host.token, body: { urgent: true } });
    await check("the endpoint answers sent:true with the caller's device count", () => {
      assert.equal(test.status, 200, JSON.stringify(test.body));
      assert.equal(test.body.sent, true);
      assert.equal(test.body.devices, 1);
      assert.equal(test.body.urgent, true);
    });
    // The endpoint's send happens in the server process; the same send,
    // made here, shows what Firebase is handed.
    const { sendPushNotificationToUser } = await import("../services/notification.service.js");
    const { PushNotificationType } = await import("../models/push_notification_types.js");
    captured.length = 0;
    await sendPushNotificationToUser({
      userId: host.id,
      title: "ALRT test (urgent channel)",
      body: "If you can see this, ALRT alerts reach this phone. Nothing was sent to anyone else.",
      data: { test: true, urgent: true },
      type: PushNotificationType.testNotification,
      urgent: true,
    });
    await check("reaches the caller's own devices only, on the urgent channel when asked", () => {
      const t = tokensOf("testNotification");
      assert.ok(t.has(host.device));
      assert.ok(!t.has(amy.device) && !t.has(tom.device));
      for (const m of of("testNotification")) assert.equal(m.android?.notification?.channelId, "alrt_alerts_urgent");
    });
    await check("sign-out removes this phone's token and a later push skips it", async () => {
      const del = await api("/api/notifications/push-notification-token", { method: "DELETE", token: host.token, body: { token: host.device } });
      assert.equal(del.status, 200, JSON.stringify(del.body));
      captured.length = 0;
      await checkIn(amy.id, { status: "safe" }, circleId);
      assert.ok(!tokensOf("familyCheckIn").has(host.device));
    });
  } finally {
    await prisma.familyCircle.deleteMany({ where: { id: circleId } }).catch(() => undefined);
    await prisma.userDevice.deleteMany({ where: { userId: { in: users.map((u) => u.id) } } });
  }

  console.log(`\n${passed} checks passed.`);
}

main()
  .catch((error) => { console.error("\nFAILED:", error); process.exitCode = 1; })
  .finally(async () => { await prisma.$disconnect(); });

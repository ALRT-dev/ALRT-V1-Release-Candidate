/**
 * Push notification settings and delivery verification - real HTTP requests
 * against a running instance of this backend plus direct service calls,
 * backed by a real local Postgres. Firebase is intercepted at the exact
 * `firebaseAdmin.messaging().sendEachForMulticast` call the real send path
 * makes, so no push leaves this process and the exact FCM message object
 * is inspected instead.
 *
 * Covers the notification changes of build 43/44 (phone QA 2026-09-09):
 *
 *   1. Defaults: an account with no settings row is given the real defaults
 *      (every alert type on, every main category) and the row is created
 *      once, so the push query, which needs a row, can match. A second
 *      read returns the same row: nothing is re-created or rewritten.
 *   2. Opt-outs are never overwritten: a row saved with switches off (via
 *      the API, and via a row that predates this build) comes back exactly
 *      as saved, from the API and from the service the API calls, with an
 *      unchanged updatedAt.
 *   3. The switches are enforced on delivery: with Advice, Official and
 *      Community off, that user receives an Emergency Warning push but no
 *      Advice, Official (non-AWS) or Community push, while an all-on user
 *      in the same area receives all four.
 *   4. Android channel routing: every hazard push is high priority and
 *      names the urgent channel (alrt_alerts_urgent) only for the action
 *      and critical bands; every other band names the normal channel
 *      (alrt_alerts). The app creates the urgent channel only while strong
 *      vibration is on, so this is what makes the user's switch hold for
 *      background pushes.
 *   5. Cooldown exemption (only when a cache is connected): a user already
 *      at the 15-minute cooldown limit is still sent an Emergency Warning
 *      but not an Advice push. Without CACHE_URL the cooldown is inactive
 *      and this section is reported as skipped, not passed.
 *
 * NOT covered here (needs a phone): the tray rendering, the vibration
 * pattern itself and Android's own per-app notification permission.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_push_notification_settings.ts
 */

import assert from "node:assert/strict";
import {
  HazardReviewStatus,
  HazardSeverity,
  HazardSeverityBand,
  PrismaClient,
} from "@prisma/client";
import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();

let passed = 0;
let skipped = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};
const skip = (label: string, why: string) => {
  skipped += 1;
  console.log(`  skipped - ${label} (${why})`);
};

type CapturedMessage = {
  tokens: string[];
  notification?: { title?: string; body?: string };
  data?: Record<string, string>;
  android?: { priority?: string; notification?: { channelId?: string } };
};
const captured: CapturedMessage[] = [];

// Intercept the exact call the real send path makes, without touching any
// real Firebase project.
Object.defineProperty(firebaseAdmin, "messaging", {
  value: () => ({
    sendEachForMulticast: async (message: CapturedMessage) => {
      captured.push(message);
      return { responses: [], successCount: 0, failureCount: 0 } as any;
    },
  }),
  writable: true,
  configurable: true,
});

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
  return { status: res.status, body: json as any };
};

const registerUser = async (label: string) => {
  const email = `push-settings-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  const me = await api("/api/user", { token });
  assert.equal(me.status, 200, JSON.stringify(me.body));
  const id = (me.body.data ?? me.body).id as string;
  assert.ok(id, `user id for ${label}: ${JSON.stringify(me.body)}`);
  return { token, id, label };
};

const settingsBody = (body: any) => body?.data ?? body;
const FLAGS = ["awsEmergency", "awsWatchAndAct", "awsAdvice", "officialNonAws", "userReported"] as const;

// A point nobody else's saved location covers, so only this script's
// subscriptions match.
const LAT = -61.2345;
const LNG = 101.2345;
const boxAround = (lat: number, lng: number) => ({
  northeastLat: lat + 0.05,
  northeastLng: lng + 0.05,
  southwestLat: lat - 0.05,
  southwestLng: lng - 0.05,
});

async function main() {
  console.log("Push notification settings and delivery verification\n");

  const { getUserPushNotificationSettings } = await import("../services/user.service.js");
  const { sendPushNotificationAboutNewHazard } = await import(
    "../services/notification.service.js"
  );
  const { getCacheClient, initCacheClient } = await import("../utils/cache_client.util.js");
  const { getAllMainHazardCategoryIds } = await import(
    "../services/hazard_category.service.js"
  );

  const mainCategoryIds = await getAllMainHazardCategoryIds();
  assert.ok(mainCategoryIds.length > 0, "seed data must include main hazard categories");
  const categoryId = mainCategoryIds[0] as string;

  const fresh = await registerUser("fresh");
  const optedOut = await registerUser("optedout");
  const allOn = await registerUser("allon");
  const legacy = await registerUser("legacy");
  const reporter = await registerUser("reporter");

  const suffix = crypto.randomUUID().slice(0, 8);
  const created: { hazards: string[]; devices: string[]; subs: string[]; rows: string[] } = {
    hazards: [],
    devices: [],
    subs: [],
    rows: [],
  };

  try {
    // ------------------------------------------------------------ 1. defaults
    console.log("1. Defaults for an account with no settings row");
    let firstRead: any;
    await check("no row before the first read", async () => {
      const rows = await prisma.userPushNotificationSetting.count({ where: { userId: fresh.id } });
      assert.equal(rows, 0);
    });
    await check("first read returns every alert type on and every main category", async () => {
      const res = await api("/api/user/push-notification-settings", { token: fresh.token });
      assert.equal(res.status, 200, JSON.stringify(res.body));
      firstRead = settingsBody(res.body);
      for (const k of FLAGS) assert.equal(firstRead[k], true, k);
      assert.deepEqual([...firstRead.subscribedCategoryIds].sort(), [...mainCategoryIds].sort());
    });
    await check("exactly one row was created", async () => {
      const rows = await prisma.userPushNotificationSetting.findMany({ where: { userId: fresh.id } });
      assert.equal(rows.length, 1);
      created.rows.push(rows[0]!.id);
    });
    await check("a second read returns the same row, untouched", async () => {
      const before = await prisma.userPushNotificationSetting.findFirstOrThrow({ where: { userId: fresh.id } });
      const res = await api("/api/user/push-notification-settings", { token: fresh.token });
      assert.equal(res.status, 200);
      const again = settingsBody(res.body);
      assert.deepEqual(again.subscribedCategoryIds, firstRead.subscribedCategoryIds);
      const after = await prisma.userPushNotificationSetting.findMany({ where: { userId: fresh.id } });
      assert.equal(after.length, 1);
      assert.equal(after[0]!.id, before.id);
      assert.equal(after[0]!.updatedAt.getTime(), before.updatedAt.getTime());
    });

    // ------------------------------------------------------------ 2. opt-outs
    console.log("\n2. Existing opt-outs are never overwritten");
    const optOut = {
      awsEmergency: true,
      awsWatchAndAct: true,
      awsAdvice: false,
      officialNonAws: false,
      userReported: false,
      subscribedCategoryIds: [categoryId],
    };
    await check("saving switches off is accepted", async () => {
      const res = await api("/api/user/push-notification-settings", {
        method: "PUT",
        token: optedOut.token,
        body: optOut,
      });
      assert.equal(res.status, 200, JSON.stringify(res.body));
      const row = await prisma.userPushNotificationSetting.findFirstOrThrow({ where: { userId: optedOut.id } });
      created.rows.push(row.id);
    });
    await check("the API reads back exactly what was saved", async () => {
      const res = await api("/api/user/push-notification-settings", { token: optedOut.token });
      assert.equal(res.status, 200);
      const b = settingsBody(res.body);
      for (const k of FLAGS) assert.equal(b[k], optOut[k], k);
      assert.deepEqual(b.subscribedCategoryIds, [categoryId]);
    });
    await check("the service behind the API returns the row unchanged (same updatedAt)", async () => {
      const before = await prisma.userPushNotificationSetting.findFirstOrThrow({ where: { userId: optedOut.id } });
      const s = await getUserPushNotificationSettings(optedOut.id);
      for (const k of FLAGS) assert.equal(s[k], optOut[k], k);
      const after = await prisma.userPushNotificationSetting.findFirstOrThrow({ where: { userId: optedOut.id } });
      assert.equal(after.updatedAt.getTime(), before.updatedAt.getTime());
      assert.equal(await prisma.userPushNotificationSetting.count({ where: { userId: optedOut.id } }), 1);
    });
    await check("a row from before this build with everything off stays everything off", async () => {
      const row = await prisma.userPushNotificationSetting.create({
        data: {
          userId: legacy.id,
          awsEmergency: false,
          awsWatchAndAct: false,
          awsAdvice: false,
          officialNonAws: false,
          userReported: false,
          subscribedCategoryIds: [],
        },
      });
      created.rows.push(row.id);
      const res = await api("/api/user/push-notification-settings", { token: legacy.token });
      assert.equal(res.status, 200);
      const b = settingsBody(res.body);
      for (const k of FLAGS) assert.equal(b[k], false, k);
      assert.deepEqual(b.subscribedCategoryIds, []);
      const after = await prisma.userPushNotificationSetting.findFirstOrThrow({ where: { userId: legacy.id } });
      assert.equal(after.updatedAt.getTime(), row.updatedAt.getTime());
    });

    // ------------------------------------------------------------ 3. delivery
    console.log("\n3. Switches are enforced on delivery; 4. Android channel routing");
    const allOnRes = await api("/api/user/push-notification-settings", {
      method: "PUT",
      token: allOn.token,
      body: { ...optOut, awsAdvice: true, officialNonAws: true, userReported: true },
    });
    assert.equal(allOnRes.status, 200, JSON.stringify(allOnRes.body));
    created.rows.push(
      (await prisma.userPushNotificationSetting.findFirstOrThrow({ where: { userId: allOn.id } })).id,
    );
    const tokenOf: Record<string, string> = {};
    const tok = (id: string) => tokenOf[id] as string;
    for (const u of [optedOut, allOn]) {
      tokenOf[u.id] = `fake-fcm-${u.label}-${suffix}`;
      const d = await prisma.userDevice.create({
        data: { userId: u.id, deviceToken: tok(u.id), platform: "android" },
      });
      created.devices.push(d.id);
      const s = await prisma.locationSubscription.create({
        data: { userId: u.id, name: `push-settings ${u.label} ${suffix}`, ...boxAround(LAT, LNG) },
      });
      created.subs.push(s.id);
    }

    const makeHazard = async (opts: {
      severity: HazardSeverity;
      band: HazardSeverityBand;
      aws: boolean;
      reportedById?: string;
    }) => {
      const h = await prisma.hazard.create({
        data: {
          title: `push-settings ${opts.severity}/${opts.band} ${suffix}`,
          description: "push settings verification hazard",
          categoryId,
          severity: opts.severity,
          severityBand: opts.band,
          isAwsCompliant: opts.aws,
          reportedById: opts.reportedById ?? null,
          reviewStatus: HazardReviewStatus.accepted,
          latitude: LAT,
          longitude: LNG,
        },
      });
      created.hazards.push(h.id);
      return h;
    };
    const sendAndCollect = async (hazard: any) => {
      captured.length = 0;
      await sendPushNotificationAboutNewHazard(hazard);
      const msgs = captured.filter((m) => m.data?.notificationType === "viewHazard");
      const tokens = new Set(msgs.flatMap((m) => m.tokens));
      return { msgs, tokens };
    };
    const expectChannel = (msgs: CapturedMessage[], channel: string) => {
      assert.ok(msgs.length > 0, "expected at least one send");
      for (const m of msgs) {
        assert.equal(m.android?.priority, "high");
        assert.equal(m.android?.notification?.channelId, channel);
      }
    };

    await check("Emergency Warning (critical band): both users, urgent channel", async () => {
      const h = await makeHazard({ severity: HazardSeverity.emergency, band: HazardSeverityBand.critical, aws: true });
      const { msgs, tokens } = await sendAndCollect(h);
      assert.ok(tokens.has(tok(allOn.id)), "all-on user gets it");
      assert.ok(tokens.has(tok(optedOut.id)), "opted-out user still has Emergency on");
      expectChannel(msgs, "alrt_alerts_urgent");
    });
    await check("Watch & Act (action band): both users, urgent channel", async () => {
      const h = await makeHazard({ severity: HazardSeverity.watchAndAct, band: HazardSeverityBand.action, aws: true });
      const { msgs, tokens } = await sendAndCollect(h);
      assert.ok(tokens.has(tok(allOn.id)));
      assert.ok(tokens.has(tok(optedOut.id)));
      expectChannel(msgs, "alrt_alerts_urgent");
    });
    await check("Advice (monitor band): all-on user only, normal channel", async () => {
      const h = await makeHazard({ severity: HazardSeverity.advice, band: HazardSeverityBand.monitor, aws: true });
      const { msgs, tokens } = await sendAndCollect(h);
      assert.ok(tokens.has(tok(allOn.id)));
      assert.ok(!tokens.has(tok(optedOut.id)), "Advice is off for the opted-out user");
      expectChannel(msgs, "alrt_alerts");
    });
    await check("Official non-AWS (info band): all-on user only, normal channel", async () => {
      const h = await makeHazard({ severity: HazardSeverity.info, band: HazardSeverityBand.info, aws: false });
      const { msgs, tokens } = await sendAndCollect(h);
      assert.ok(tokens.has(tok(allOn.id)));
      assert.ok(!tokens.has(tok(optedOut.id)), "Official is off for the opted-out user");
      expectChannel(msgs, "alrt_alerts");
    });
    await check("Community report (info band): all-on user only, normal channel, no band in the title", async () => {
      const h = await makeHazard({
        severity: HazardSeverity.unknown,
        band: HazardSeverityBand.info,
        aws: false,
        reportedById: reporter.id,
      });
      const { msgs, tokens } = await sendAndCollect(h);
      assert.ok(tokens.has(tok(allOn.id)));
      assert.ok(!tokens.has(tok(optedOut.id)), "Community is off for the opted-out user");
      expectChannel(msgs, "alrt_alerts");
      for (const m of msgs) assert.match(m.notification?.title ?? "", /^Community report \| /);
    });
    await check("a critical-band official (non-AWS) alert also names the urgent channel", async () => {
      const h = await makeHazard({ severity: HazardSeverity.info, band: HazardSeverityBand.critical, aws: false });
      const { msgs, tokens } = await sendAndCollect(h);
      assert.ok(tokens.has(tok(allOn.id)));
      expectChannel(msgs, "alrt_alerts_urgent");
    });

    // ------------------------------------------------------------ 5. cooldown
    console.log("\n5. Cooldown exemption for Emergency Warnings");
    if (process.env.CACHE_URL) await initCacheClient();
    const redis = getCacheClient();
    if (!redis) {
      skip("user at the cooldown limit still gets an Emergency Warning but not an Advice push", "no CACHE_URL: the cooldown is inactive in this environment");
    } else {
      const key = `hazard:notifycount:${allOn.id}`;
      try {
        await check("user at the cooldown limit gets no Advice push", async () => {
          await redis.set(key, "10", { EX: 120 });
          const h = await makeHazard({ severity: HazardSeverity.advice, band: HazardSeverityBand.monitor, aws: true });
          const { tokens } = await sendAndCollect(h);
          assert.ok(!tokens.has(tok(allOn.id)), "suppressed by the cooldown");
        });
        await check("the same user still gets an Emergency Warning", async () => {
          await redis.set(key, "10", { EX: 120 });
          const h = await makeHazard({ severity: HazardSeverity.emergency, band: HazardSeverityBand.critical, aws: true });
          const { msgs, tokens } = await sendAndCollect(h);
          assert.ok(tokens.has(tok(allOn.id)), "exempt from the cooldown");
          expectChannel(msgs, "alrt_alerts_urgent");
        });
      } finally {
        await redis.del(key).catch(() => undefined);
      }
    }
  } finally {
    await prisma.hazard.deleteMany({ where: { id: { in: created.hazards } } });
    await prisma.locationSubscription.deleteMany({ where: { id: { in: created.subs } } });
    await prisma.userDevice.deleteMany({ where: { id: { in: created.devices } } });
    await prisma.userPushNotificationSetting.deleteMany({ where: { id: { in: created.rows } } });
    const { disconnectCacheClient } = await import("../utils/cache_client.util.js");
    await disconnectCacheClient().catch(() => undefined);
  }

  console.log(`\n${passed} checks passed.${skipped ? ` ${skipped} skipped.` : ""}`);
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

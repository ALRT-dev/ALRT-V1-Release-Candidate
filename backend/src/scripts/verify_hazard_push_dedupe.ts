/**
 * One public-alert push per person per hazard event, whichever paths
 * qualify them (device acceptance item 12, "no duplicates").
 *
 * A new accepted hazard can reach one person through several paths at
 * once: a saved location covering it (viewHazard), a family member near
 * it and a family saved place near it (familyHazardProximity, one call per
 * member and per place). Before this fix each path sent its own push, so a
 * person in both a covering saved area and a circle with a nearby place
 * got two notifications about one alert, and a circle with two places
 * near it got one per place.
 *
 * Proves, with Firebase intercepted at `sendEachForMulticast`:
 *   1. A person qualifying through a saved area AND a circle with two
 *      nearby places receives exactly one push for the creation event.
 *   2. A person qualifying only through the circle receives exactly one
 *      push even though two places qualify the circle.
 *   3. A person qualifying only through a saved area receives one.
 *   4. Re-running the creation paths (a retry, a replayed job) sends
 *      nothing more for that event.
 *   5. A genuine later event about the same hazard (a new event key) is
 *      not suppressed: the claim is per event, not per hazard.
 *   6. Every hazard push carries the tray key for the hazard (Android tag
 *      and APNs collapse id), so a copy that still slips through replaces
 *      rather than stacks.
 *   7. The socket event still reaches every circle member (dedupe is for
 *      notifications, not live state).
 *
 * NOT covered (needs a phone): what the tray shows.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_hazard_push_dedupe.ts
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
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

type Msg = {
  tokens: string[];
  notification?: { title?: string; body?: string };
  data?: Record<string, string>;
  android?: { notification?: { tag?: string } };
  apns?: { headers?: Record<string, string> };
};
const captured: Msg[] = [];
Object.defineProperty(firebaseAdmin, "messaging", {
  value: () => ({
    sendEachForMulticast: async (message: Msg) => {
      captured.push(message);
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
    /* no body */
  }
  return { status: res.status, body: json as any };
};

const registerUser = async (label: string) => {
  const email = `push-dedupe-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  const token = res.body.accessToken as string;
  await api("/api/user", { method: "PUT", token, body: { name: label } });
  const me = await api("/api/user", { token });
  return {
    token,
    id: (me.body.data ?? me.body).id as string,
    label,
    device: `fake-fcm-${label}-${crypto.randomUUID().slice(0, 6)}`,
  };
};

// A remote point no real subscription covers.
const LAT = -63.1234;
const LNG = 101.4321;
const BOX = {
  northeastLat: LAT + 0.05,
  northeastLng: LNG + 0.05,
  southwestLat: LAT - 0.05,
  southwestLng: LNG - 0.05,
};

const fillGeom = async (id: string, lat: number, lng: number) => {
  const [meta] = await prisma.$queryRawUnsafe<
    { generation_expression: string | null }[]
  >(
    `SELECT generation_expression FROM information_schema.columns WHERE table_name = 'Hazard' AND column_name = 'geom'`,
  );
  if (meta?.generation_expression) return;
  await prisma.$executeRawUnsafe(
    `UPDATE "Hazard" SET geom = ST_SetSRID(ST_MakePoint($1, $2), 4326) WHERE id = $3`,
    lng,
    lat,
    id,
  );
};

const sendsTo = (device: string) =>
  captured.filter((m) => m.tokens.includes(device));

async function main() {
  console.log("Hazard push dedupe (real DB, intercepted FCM)\n");
  const {
    sendPushNotificationAboutNewHazard,
    claimHazardPushRecipients,
    hazardPushEventKey,
  } = await import("../services/notification.service.js");
  const { notifyFamiliesAboutNewHazard } = await import(
    "../services/family_alert.service.js"
  );
  const { getAllMainHazardCategoryIds } = await import(
    "../services/hazard_category.service.js"
  );

  const mainIds = await getAllMainHazardCategoryIds();
  const categoryId = mainIds[0] as string;
  const tag = `push-dedupe-${crypto.randomUUID().slice(0, 8)}`;

  // both: saved area + circle. circleOnly: circle. areaOnly: saved area.
  const both = await registerUser("Both");
  const circleOnly = await registerUser("CircleOnly");
  const areaOnly = await registerUser("AreaOnly");
  const users = [both, circleOnly, areaOnly];

  const officialSource = await prisma.hazardSource.findFirst({
    where: { id: { notIn: ["gdacsGlobal"] }, shape: { not: "shield" } },
    select: { id: true },
  });
  assert.ok(officialSource, "seed data must include an official source");

  const created = {
    hazards: [] as string[],
    devices: [] as string[],
    subs: [] as string[],
    settings: [] as string[],
  };
  let circleId: string | null = null;

  // Socket fan-out is observed through the service's own log line (no
  // socket server runs in this process, so nothing is emitted).
  const socketUsers: string[][] = [];
  const realLog = console.log;
  console.log = (...args: unknown[]) => {
    if (
      typeof args[0] === "string" &&
      args[0].includes("Sending socket event 'familyHazardProximity'") &&
      Array.isArray(args[1])
    ) {
      socketUsers.push(args[1] as string[]);
      return;
    }
    realLog(...args);
  };

  try {
    for (const u of users) {
      created.devices.push(
        (
          await prisma.userDevice.create({
            data: { userId: u.id, deviceToken: u.device, platform: "android" },
          })
        ).id,
      );
      const put = await api("/api/user/push-notification-settings", {
        method: "PUT",
        token: u.token,
        body: {
          awsEmergency: true,
          awsWatchAndAct: true,
          awsAdvice: true,
          officialNonAws: true,
          userReported: true,
          subscribedCategoryIds: mainIds,
        },
      });
      assert.equal(put.status, 200, JSON.stringify(put.body));
    }
    for (const u of [both, areaOnly]) {
      created.subs.push(
        (
          await prisma.locationSubscription.create({
            data: { userId: u.id, name: tag, ...BOX },
          })
        ).id,
      );
    }

    // A circle of Both + CircleOnly with two saved places near the point.
    const circle = await api("/api/family/circle", {
      method: "POST",
      token: both.token,
      body: { name: `${tag} circle` },
    });
    assert.equal(circle.status, 201, JSON.stringify(circle.body));
    circleId = circle.body.id as string;
    const invite = await api("/api/family/invites", {
      method: "POST",
      token: both.token,
    });
    const join = await api("/api/family/join", {
      method: "POST",
      token: circleOnly.token,
      body: { code: invite.body.code },
    });
    assert.equal(join.status, 200, JSON.stringify(join.body));
    for (const name of ["Home", "School"]) {
      const place = await api("/api/family/places", {
        method: "POST",
        token: both.token,
        body: { name, latitude: LAT + 0.01, longitude: LNG + 0.01 },
      });
      assert.equal(place.status, 201, JSON.stringify(place.body));
    }

    const hazard = await prisma.hazard.create({
      data: {
        title: `${tag} Emergency Warning`,
        description: "push dedupe synthetic alert",
        categoryId,
        severity: HazardSeverity.emergency,
        severityBand: HazardSeverityBand.critical,
        isAwsCompliant: true,
        sourceId: officialSource.id,
        reviewStatus: HazardReviewStatus.accepted,
        latitude: LAT,
        longitude: LNG,
      },
    });
    created.hazards.push(hazard.id);
    await fillGeom(hazard.id, LAT, LNG);

    console.log("§1 creation event: every path at once");
    captured.length = 0;
    socketUsers.length = 0;
    await Promise.all([
      sendPushNotificationAboutNewHazard(hazard),
      notifyFamiliesAboutNewHazard(hazard),
    ]);

    await check(
      "saved area + circle with two nearby places: exactly one push",
      () => assert.equal(sendsTo(both.device).length, 1, JSON.stringify(captured)),
    );
    await check("circle only, two nearby places: exactly one push", () =>
      assert.equal(sendsTo(circleOnly.device).length, 1),
    );
    await check("saved area only: exactly one push", () =>
      assert.equal(sendsTo(areaOnly.device).length, 1),
    );
    await check(
      "every hazard push carries the tray key (Android tag, APNs collapse id)",
      () => {
        assert.ok(captured.length > 0);
        for (const m of captured) {
          assert.equal(m.android?.notification?.tag, `hazard:${hazard.id}`);
          assert.equal(m.apns?.headers?.["apns-collapse-id"], `hazard:${hazard.id}`);
        }
      },
    );

    console.log("§2 the same event again (retry, replay)");
    captured.length = 0;
    await Promise.all([
      sendPushNotificationAboutNewHazard(hazard),
      notifyFamiliesAboutNewHazard(hazard),
    ]);
    await check("nothing more is sent for the creation event", () =>
      assert.equal(captured.length, 0, JSON.stringify(captured)),
    );

    console.log("§3 a genuine later event is not suppressed");
    await check("a new event key claims every recipient afresh", async () => {
      const later = await claimHazardPushRecipients(
        hazard.id,
        `updated:${new Date().toISOString()}`,
        [both.id, circleOnly.id, areaOnly.id],
      );
      assert.deepEqual(new Set(later), new Set([both.id, circleOnly.id, areaOnly.id]));
      const again = await claimHazardPushRecipients(
        hazard.id,
        hazardPushEventKey(hazard),
        [both.id],
      );
      assert.deepEqual(again, [], "the creation event stays claimed");
    });

    console.log("§4 live state is untouched");
    await check("the socket event still reaches every circle member", () => {
      const reached = new Set(socketUsers.flat());
      assert.ok(reached.has(both.id) && reached.has(circleOnly.id), JSON.stringify(socketUsers));
    });
  } finally {
    console.log = realLog;
    if (circleId) {
      await prisma.familyCircle.deleteMany({ where: { id: circleId } });
    }
    await prisma.hazard.deleteMany({ where: { id: { in: created.hazards } } });
    await prisma.locationSubscription.deleteMany({ where: { id: { in: created.subs } } });
    await prisma.userDevice.deleteMany({ where: { id: { in: created.devices } } });
    await prisma.userPushNotificationSetting.deleteMany({
      where: { userId: { in: users.map((u) => u.id) } },
    });
  }

  console.log(`\n${passed} checks passed.`);
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

/**
 * Multi-value query params on the alert list endpoints the app calls.
 *
 * The app's Dio client sends a list as repeated keys
 * (?categoryIds=a&categoryIds=b), which Express's query parser turns into
 * a real array; a list of one arrives as a plain string. GET
 * /api/notifications/feed used to accept only the string shape, so the
 * Alerts feed answered 400 "expected string, received array" whenever two
 * or more categories (the default) or two or more saved places were
 * selected. This script proves 1, 2+ categories and 2+ locations answer
 * 200 with the right filtering, in both the repeated-key and the
 * comma-joined shape, and checks /api/hazards,
 * /api/hazards/hazards-with-subscription-id and /api/alerts/geo too.
 *
 * Real HTTP against a running instance of this backend, real Postgres.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_feed_list_query_params.ts
 */

import assert from "node:assert/strict";
import {
  HazardReviewStatus,
  HazardSeverity,
  HazardSeverityBand,
  PrismaClient,
} from "@prisma/client";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

const api = async (path: string, token?: string) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  let json: unknown = null;
  try {
    json = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body: json as any };
};

const registerUser = async () => {
  const email = `feed-params-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await fetch(`${BASE_URL}/api/auth/email-password/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: "TestPass123!Xx" }),
  });
  const body = (await res.json()) as any;
  assert.equal(res.status, 201, `register: ${JSON.stringify(body)}`);
  const token = body.accessToken as string;
  const me = await api("/api/user", token);
  return { token, id: (me.body.data ?? me.body).id as string };
};

/** Three points nobody else's saved location covers, far apart. */
const POINTS = {
  a: { lat: -63.1111, lng: 101.1111 },
  b: { lat: -63.5555, lng: 102.5555 },
  c: { lat: -63.9999, lng: 103.9999 },
};
const box = (p: { lat: number; lng: number }) => ({
  northeastLat: p.lat + 0.05,
  northeastLng: p.lng + 0.05,
  southwestLat: p.lat - 0.05,
  southwestLng: p.lng - 0.05,
});

/** Same as verify_alert_filter_matrix: fill geom unless it is generated. */
const fillGeom = async (id: string, lat: number, lng: number) => {
  const [meta] = await prisma.$queryRawUnsafe<{ generation_expression: string | null }[]>(
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

const idsOf = (body: any): Set<string> => {
  const list: any[] = Array.isArray(body)
    ? body
    : (body?.data ?? body?.hazards ?? body?.features ?? []);
  return new Set(list.map((h) => (h.id ?? h.properties?.id) as string));
};

async function main() {
  console.log("Multi-value query params on the feed and hazard lists (real HTTP, real DB)\n");

  const { getAllMainHazardCategoryIds } = await import("../services/hazard_category.service.js");
  const mainIds = await getAllMainHazardCategoryIds();
  assert.ok(mainIds.length >= 3, "seed data must include at least three main categories");
  const [cat1, cat2, cat3] = mainIds as [string, string, string];
  const tag = `feed-params-${crypto.randomUUID().slice(0, 8)}`;

  // A hazard needs a source (or a reporter) to be listed at all.
  const source = await prisma.hazardSource.findFirst({
    where: { id: { notIn: ["gdacsGlobal"] }, shape: { not: "shield" } },
    select: { id: true },
  });
  assert.ok(source, "seed data must include an official source");

  const user = await registerUser();
  const created = { hazards: [] as string[], subs: [] as string[] };

  try {
    const subA = await prisma.locationSubscription.create({ data: { userId: user.id, name: `${tag}-a`, ...box(POINTS.a) } });
    const subB = await prisma.locationSubscription.create({ data: { userId: user.id, name: `${tag}-b`, ...box(POINTS.b) } });
    const subC = await prisma.locationSubscription.create({ data: { userId: user.id, name: `${tag}-c`, ...box(POINTS.c) } });
    created.subs.push(subA.id, subB.id, subC.id);

    const make = async (key: string, categoryId: string, p: { lat: number; lng: number }) => {
      const h = await prisma.hazard.create({
        data: {
          title: `${tag} ${key}`,
          description: "feed list params synthetic alert",
          categoryId,
          severity: HazardSeverity.advice,
          severityBand: HazardSeverityBand.monitor,
          isAwsCompliant: true,
          sourceId: source.id,
          reviewStatus: HazardReviewStatus.accepted,
          latitude: p.lat,
          longitude: p.lng,
        },
      });
      created.hazards.push(h.id);
      await fillGeom(h.id, p.lat, p.lng);
      return h.id;
    };
    const h = {
      a1: await make("a1", cat1, POINTS.a),
      a2: await make("a2", cat2, POINTS.a),
      a3: await make("a3", cat3, POINTS.a),
      b1: await make("b1", cat1, POINTS.b),
      c1: await make("c1", cat1, POINTS.c),
    };
    const ours = new Set(Object.values(h));

    const feed = async (extra: [string, string][]) => {
      const q = new URLSearchParams([["searchString", tag], ["pageSize", "100"], ...extra]);
      const res = await api(`/api/notifications/feed?${q.toString()}`, user.token);
      assert.equal(res.status, 200, `feed ${q.toString()}: ${JSON.stringify(res.body)}`);
      return new Set([...idsOf(res.body)].filter((id) => ours.has(id)));
    };
    const expectIds = (got: Set<string>, want: string[]) => {
      assert.deepEqual([...got].sort(), [...want].sort());
    };

    await check("feed: one categoryId (plain string) is 200 and filters", async () => {
      expectIds(await feed([["categoryIds", cat1]]), [h.a1, h.b1, h.c1]);
    });
    await check("feed: two categoryIds as repeated keys (the app's shape) is 200 and filters", async () => {
      expectIds(await feed([["categoryIds", cat1], ["categoryIds", cat2]]), [h.a1, h.a2, h.b1, h.c1]);
    });
    await check("feed: three categoryIds as repeated keys is 200 and filters", async () => {
      expectIds(
        await feed([["categoryIds", cat1], ["categoryIds", cat2], ["categoryIds", cat3]]),
        [h.a1, h.a2, h.a3, h.b1, h.c1],
      );
    });
    await check("feed: two categoryIds comma-joined is 200 and filters", async () => {
      expectIds(await feed([["categoryIds", `${cat2},${cat3}`]]), [h.a2, h.a3]);
    });
    await check("feed: one locationId is 200 and only that place's alerts", async () => {
      expectIds(await feed([["locationIds", subA.id]]), [h.a1, h.a2, h.a3]);
    });
    await check("feed: two locationIds as repeated keys is 200 and only those places", async () => {
      expectIds(await feed([["locationIds", subA.id], ["locationIds", subB.id]]), [h.a1, h.a2, h.a3, h.b1]);
    });
    await check("feed: two locationIds comma-joined is 200 and only those places", async () => {
      expectIds(await feed([["locationIds", `${subB.id},${subC.id}`]]), [h.b1, h.c1]);
    });
    await check("feed: 2+ categories and 2+ locations together (the app's default) is 200", async () => {
      expectIds(
        await feed([
          ["categoryIds", cat1],
          ["categoryIds", cat2],
          ["locationIds", subA.id],
          ["locationIds", subC.id],
        ]),
        [h.a1, h.a2, h.c1],
      );
    });
    await check("feed: an unknown locationId only answers [] (no other places leak in)", async () => {
      expectIds(await feed([["locationIds", crypto.randomUUID()]]), []);
    });

    const bounds = {
      northeastLat: String(POINTS.a.lat + 0.05),
      northeastLng: String(POINTS.a.lng + 0.05),
      southwestLat: String(POINTS.a.lat - 0.05),
      southwestLng: String(POINTS.a.lng - 0.05),
    };
    const hazardsList = async (path: string, extra: [string, string][]) => {
      const q = new URLSearchParams([["searchString", tag], ["pageSize", "100"], ...Object.entries(bounds), ...extra]);
      const res = await api(`${path}?${q.toString()}`, user.token);
      assert.equal(res.status, 200, `${path} ${q.toString()}: ${JSON.stringify(res.body)}`);
      return new Set([...idsOf(res.body)].filter((id) => ours.has(id)));
    };
    await check("/api/hazards: one categoryId is 200 and filters", async () => {
      expectIds(await hazardsList("/api/hazards", [["categoryIds", cat1]]), [h.a1]);
    });
    await check("/api/hazards: two categoryIds as repeated keys is 200 and filters", async () => {
      expectIds(await hazardsList("/api/hazards", [["categoryIds", cat1], ["categoryIds", cat2]]), [h.a1, h.a2]);
    });
    await check("/api/hazards: repeated locationIds (sent by the app, ignored there) is still 200", async () => {
      expectIds(
        await hazardsList("/api/hazards", [["categoryIds", cat3], ["locationIds", subA.id], ["locationIds", subB.id]]),
        [h.a3],
      );
    });
    await check("/api/hazards/hazards-with-subscription-id: two categoryIds as repeated keys is 200", async () => {
      const q = new URLSearchParams([["searchString", tag], ["pageSize", "100"], ...Object.entries(bounds), ["categoryIds", cat1], ["categoryIds", cat2]]);
      const res = await api(`/api/hazards/hazards-with-subscription-id?${q.toString()}`, user.token);
      assert.equal(res.status, 200, JSON.stringify(res.body));
    });
    await check("/api/alerts/geo: two categoryIds as repeated keys is 200 and filters", async () => {
      const q = new URLSearchParams([...Object.entries(bounds), ["categoryIds", cat2], ["categoryIds", cat3]]);
      const res = await api(`/api/alerts/geo?${q.toString()}`, user.token);
      assert.equal(res.status, 200, JSON.stringify(res.body));
      const got = new Set([...idsOf(res.body)].filter((id) => ours.has(id)));
      expectIds(got, [h.a2, h.a3]);
    });
  } finally {
    await prisma.hazard.deleteMany({ where: { id: { in: created.hazards } } });
    await prisma.locationSubscription.deleteMany({ where: { id: { in: created.subs } } });
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

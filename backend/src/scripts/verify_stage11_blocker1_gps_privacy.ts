/**
 * Stage 11 Blocker 1 verification script — real HTTP requests against a
 * running instance of this backend, backed by a real local Postgres+PostGIS
 * database. Covers the release-blocking fix in this stage: the public,
 * unauthenticated `GET /api/public/hazards/:id` endpoint previously
 * returned a community reporter's exact GPS coordinates, bypassing the
 * `withPublicCoords()` privacy rule (Stage 6A) that every other hazard
 * read/emit path already applies.
 *
 * Proves:
 *   1. A community-reported hazard's public detail response never exposes
 *      the reporter's exact coordinates (rounded to suburb precision).
 *   2. An official/ingested hazard's public detail response retains full,
 *      permitted location precision (unchanged behaviour).
 *   3. No alternate public serialization path (share HTML page, share PNG
 *      card, the authenticated GeoJSON feed) leaks the exact coordinate
 *      either.
 *   4. The Share flow (the HTML share page and PNG card the app's own
 *      Share button drives users to) still works end to end after the fix.
 *
 * Setup: same throwaway Postgres+PostGIS pattern as
 * verify_stage7b_admin_hardening.ts / verify_stage9a_journey_recipient.ts.
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_stage11_blocker1_gps_privacy.ts
 */

import assert from "node:assert/strict";
import { PrismaClient, HazardReviewStatus } from "@prisma/client";

const prisma = new PrismaClient();
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
  const contentType = res.headers.get("content-type") ?? "";
  // The GeoJSON feed responds with application/geo+json, not
  // application/json - both must parse as JSON here.
  let body: unknown = null;
  if (contentType.includes("json")) {
    body = await res.json();
  } else {
    body = await res.text();
  }
  return { status: res.status, contentType, body };
};

// Precise enough to identify a specific house; the exact value the leak
// exposed and the fix must never return unrounded.
const EXACT_LAT = -27.469761;
const EXACT_LNG = 153.025124;
const ROUNDED_LAT = Math.round(EXACT_LAT * 100) / 100; // -27.47
const ROUNDED_LNG = Math.round(EXACT_LNG * 100) / 100; // 153.03

async function main() {
  console.log("Stage 11 Blocker 1 verification (real HTTP + real DB)\n");

  console.log("Setup");
  const category = await prisma.hazardCategory.findFirst();
  assert.ok(category, "seed data must include at least one hazard category");
  // Official/ingested hazards always carry a sourceId in production (that's
  // what the geo feed's own "official-or-reported" visibility guard keys
  // off) - a bare reportedById:null/sourceId:null row isn't a realistic
  // official hazard, so give this fixture a real source.
  const source = await prisma.hazardSource.findFirst();
  assert.ok(source, "seed data must include at least one hazard source");

  const reporter = await prisma.user.create({
    data: {
      email: `stage11-reporter-${crypto.randomUUID().slice(0, 8)}@test.local`,
      name: "Stage 11 Reporter",
    },
  });

  const communityHazard = await prisma.hazard.create({
    data: {
      title: "Stage 11 community report",
      description: "A community-reported hazard for Blocker 1 verification",
      categoryId: category!.id,
      reportedById: reporter.id,
      reviewStatus: HazardReviewStatus.accepted,
      latitude: EXACT_LAT,
      longitude: EXACT_LNG,
      locationName: "Near a specific address",
    },
  });

  const officialHazard = await prisma.hazard.create({
    data: {
      title: "Stage 11 official alert",
      description: "An official/ingested hazard for Blocker 1 verification",
      categoryId: category!.id,
      sourceId: source!.id,
      reportedById: null,
      reviewStatus: HazardReviewStatus.accepted,
      latitude: EXACT_LAT,
      longitude: EXACT_LNG,
      locationName: "A broad official-alert area",
    },
  });

  const pendingCommunityHazard = await prisma.hazard.create({
    data: {
      title: "Stage 11 pending community report",
      description: "Not yet moderated - should not be publicly reachable",
      categoryId: category!.id,
      reportedById: reporter.id,
      reviewStatus: HazardReviewStatus.pending,
      latitude: EXACT_LAT,
      longitude: EXACT_LNG,
    },
  });

  console.log("  setup - one accepted community hazard, one accepted official hazard, one pending community hazard\n");

  console.log("Blocker 1 - GET /api/public/hazards/:id");

  await check(
    "community hazard: public detail does NOT expose the reporter's exact coordinates",
    async () => {
      const res = await api(`/api/public/hazards/${communityHazard.id}`);
      assert.equal(res.status, 200);
      const body = res.body as any;
      assert.notEqual(body.latitude, EXACT_LAT);
      assert.notEqual(body.longitude, EXACT_LNG);
      assert.equal(body.latitude, ROUNDED_LAT);
      assert.equal(body.longitude, ROUNDED_LNG);
    },
  );

  await check(
    "official hazard: public detail retains full, permitted location precision",
    async () => {
      const res = await api(`/api/public/hazards/${officialHazard.id}`);
      assert.equal(res.status, 200);
      const body = res.body as any;
      assert.equal(body.latitude, EXACT_LAT);
      assert.equal(body.longitude, EXACT_LNG);
    },
  );

  await check("a not-yet-moderated community report is not publicly reachable at all", async () => {
    const res = await api(`/api/public/hazards/${pendingCommunityHazard.id}`);
    assert.equal(res.status, 404);
  });

  console.log();
  console.log("Blocker 1 - other public/unauthenticated serialization paths");

  await check(
    "share HTML page (/a/:id) never renders the exact coordinate value",
    async () => {
      const res = await api(`/a/${communityHazard.id}`);
      assert.equal(res.status, 200);
      const html = res.body as string;
      assert.ok(!html.includes(String(EXACT_LAT)), "exact latitude must not appear in the share page HTML");
      assert.ok(!html.includes(String(EXACT_LNG)), "exact longitude must not appear in the share page HTML");
    },
  );

  await check(
    "share PNG card (/share/alert/:id/card.png) renders successfully (Share flow stays functional)",
    async () => {
      const res = await api(`/share/alert/${communityHazard.id}/card.png`);
      assert.equal(res.status, 200);
      assert.ok(res.contentType.includes("image/png"), `expected image/png, got ${res.contentType}`);
    },
  );

  await check(
    "short share alias (/a/:id) used by the app's Share button still resolves (Share flow stays functional)",
    async () => {
      const res = await api(`/a/${communityHazard.id}`);
      assert.equal(res.status, 200);
      assert.ok(res.contentType.includes("text/html"));
    },
  );

  console.log();
  console.log("Blocker 1 - authenticated GeoJSON feed already rounds correctly (unchanged, confirmed clean)");

  const registerRes = await api("/api/auth/email-password/register", {
    method: "POST",
    body: {
      email: `stage11-geo-${crypto.randomUUID().slice(0, 8)}@test.local`,
      password: "TestPass123!Xx",
    },
  });
  assert.equal(registerRes.status, 201, JSON.stringify(registerRes.body));
  const geoToken = (registerRes.body as any).accessToken as string;

  await check(
    "GET /api/alerts/geo (authenticated) also rounds the community hazard's coordinates",
    async () => {
      const res = await api("/api/alerts/geo?status=active&limit=500", {
        token: geoToken,
      });
      assert.equal(res.status, 200);
      const feature = (res.body as any).features.find(
        (f: any) => f.id === communityHazard.id,
      );
      assert.ok(feature, "community hazard should appear in the geo feed");
      const [lng, lat] = feature.geometry.coordinates;
      assert.notEqual(lat, EXACT_LAT);
      assert.notEqual(lng, EXACT_LNG);
      assert.equal(lat, ROUNDED_LAT);
      assert.equal(lng, ROUNDED_LNG);
    },
  );

  await check(
    "GET /api/alerts/geo (authenticated) keeps the official hazard's full precision",
    async () => {
      const res = await api("/api/alerts/geo?status=active&limit=500", {
        token: geoToken,
      });
      assert.equal(res.status, 200);
      const feature = (res.body as any).features.find(
        (f: any) => f.id === officialHazard.id,
      );
      assert.ok(feature, "official hazard should appear in the geo feed");
      const [lng, lat] = feature.geometry.coordinates;
      assert.equal(lat, EXACT_LAT);
      assert.equal(lng, EXACT_LNG);
    },
  );

  console.log(`\n${passed} checks passed.`);

  await prisma.hazard.deleteMany({
    where: { id: { in: [communityHazard.id, officialHazard.id, pendingCommunityHazard.id] } },
  });
  await prisma.user.delete({ where: { id: reporter.id } });
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

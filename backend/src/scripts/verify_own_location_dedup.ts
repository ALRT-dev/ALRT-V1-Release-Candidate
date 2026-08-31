/**
 * Duplicate "My Location" regression verification — real HTTP requests
 * against a running instance of this backend, backed by a real local
 * Postgres+PostGIS database.
 *
 * Bug: every login/GPS update on the Android app calls PUT /api/user with
 * the device's current coordinates, which calls
 * upsertUserOwnLocationSubscription(). That function used to always try
 * `create()` first and only fell back to an update when the database's own
 * partial unique index (isOwnLocation=true per user) rejected the insert.
 * In TEST, that index was never actually applied (see
 * scripts/provision-test-db.sh), so every call inserted a fresh row and the
 * same user accumulated duplicate "My Location" entries.
 *
 * Fix under test: upsertUserOwnLocationSubscription() now looks for an
 * existing isOwnLocation=true row before creating one, so repeated calls
 * update in place regardless of whether the database constraint exists.
 * The unique-index/P2002 fallback stays as a defence for the genuine race
 * (two concurrent calls both passing the initial check).
 *
 * Proves:
 *   1. Repeated PUT /api/user calls with drifting GPS coordinates (the
 *      real login/app-start pattern) leave exactly one isOwnLocation=true
 *      row for the user, and it reflects the latest coordinates.
 *   2. Calling the service function directly and repeatedly has the same
 *      effect (isolates the fix from the HTTP/controller layer).
 *   3. Concurrent calls (the genuine race the unique index/P2002 fallback
 *      exists for) still converge on exactly one row.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_own_location_dedup.ts
 */

import assert from "node:assert/strict";
import { PrismaClient } from "@prisma/client";
import { upsertUserOwnLocationSubscription } from "../services/location_subscription.service.js";

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
  const body = await res.json().catch(() => null);
  return { status: res.status, body };
};

const ownLocationCountFor = async (userId: string) =>
  prisma.locationSubscription.count({
    where: { userId, isOwnLocation: true },
  });

async function main() {
  console.log("Duplicate 'My Location' regression verification (real HTTP + real DB)\n");

  console.log("Setup: HTTP path (PUT /api/user, mirrors repeated login/app-start)");
  const registerRes = await api("/api/auth/email-password/register", {
    method: "POST",
    body: {
      email: `dedup-http-${crypto.randomUUID().slice(0, 8)}@test.local`,
      password: "TestPass123!Xx",
    },
  });
  assert.equal(registerRes.status, 201, JSON.stringify(registerRes.body));
  const httpUserId = registerRes.body.user.id as string;
  const httpToken = registerRes.body.accessToken as string;

  await check(
    "5 repeated PUT /api/user calls with drifting GPS coords leave exactly one own-location row",
    async () => {
      // Small drift each call - the same pattern that triggers a location
      // update on every real cold start/login (device GPS is never bit-
      // for-bit identical between reads).
      const base = { latitude: -27.4698, longitude: 153.0251 };
      for (let i = 0; i < 5; i += 1) {
        const res = await api("/api/user", {
          method: "PUT",
          token: httpToken,
          body: {
            latitude: base.latitude + i * 0.0001,
            longitude: base.longitude + i * 0.0001,
          },
        });
        assert.equal(res.status, 200, JSON.stringify(res.body));
      }
      const count = await ownLocationCountFor(httpUserId);
      assert.equal(count, 1, `expected exactly 1 own-location row, found ${count}`);
    },
  );

  await check(
    "the single row reflects the most recent coordinates, not the first",
    async () => {
      const row = await prisma.locationSubscription.findFirst({
        where: { userId: httpUserId, isOwnLocation: true },
      });
      assert.ok(row, "own-location row must exist");
      // Last call used latitude -27.4698 + 4*0.0001 = -27.4694; the
      // bounding box must be centred there, not on the first call's coords.
      const expectedCenterLat = -27.4698 + 4 * 0.0001;
      const centerLat = (row!.northeastLat + row!.southwestLat) / 2;
      assert.ok(
        Math.abs(centerLat - expectedCenterLat) < 0.0001,
        `expected bounding box centred near ${expectedCenterLat}, got ${centerLat}`,
      );
    },
  );

  console.log();
  console.log("Service-level path (isolates the fix from the HTTP/controller layer)");
  const serviceUser = await prisma.user.create({
    data: {
      email: `dedup-service-${crypto.randomUUID().slice(0, 8)}@test.local`,
      name: "Dedup Service User",
    },
  });

  await check(
    "10 sequential direct calls to upsertUserOwnLocationSubscription leave exactly one row",
    async () => {
      for (let i = 0; i < 10; i += 1) {
        await upsertUserOwnLocationSubscription({
          userId: serviceUser.id,
          latitude: -33.8688 + i * 0.0001,
          longitude: 151.2093 + i * 0.0001,
        });
      }
      const count = await ownLocationCountFor(serviceUser.id);
      assert.equal(count, 1, `expected exactly 1 own-location row, found ${count}`);
    },
  );

  console.log();
  console.log("Concurrent path (the genuine race the unique-index/P2002 fallback guards)");
  const raceUser = await prisma.user.create({
    data: {
      email: `dedup-race-${crypto.randomUUID().slice(0, 8)}@test.local`,
      name: "Dedup Race User",
    },
  });

  await check(
    "5 concurrent calls to upsertUserOwnLocationSubscription still converge on exactly one row",
    async () => {
      await Promise.all(
        Array.from({ length: 5 }, (_, i) =>
          upsertUserOwnLocationSubscription({
            userId: raceUser.id,
            latitude: -37.8136 + i * 0.0001,
            longitude: 144.9631 + i * 0.0001,
          }),
        ),
      );
      const count = await ownLocationCountFor(raceUser.id);
      assert.equal(count, 1, `expected exactly 1 own-location row after a concurrent race, found ${count}`);
    },
  );

  console.log(`\n${passed} checks passed.`);

  await prisma.locationSubscription.deleteMany({
    where: { userId: { in: [httpUserId, serviceUser.id, raceUser.id] } },
  });
  await prisma.user.deleteMany({
    where: { id: { in: [httpUserId, serviceUser.id, raceUser.id] } },
  });
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

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
 * All fixture accounts this script creates use the email prefixes
 * dedup-http- / dedup-service- / dedup-race- under @test.local. Cleanup
 * (see cleanupFixtureAccounts below) sweeps by that prefix rather than by
 * the specific IDs this run created, so it also removes any leftover
 * fixture account from an earlier run that crashed before reaching its own
 * cleanup (e.g. the response-shape bug this script previously had).
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

/**
 * Registers a fresh account over HTTP and returns its userId + access
 * token. The register endpoint's response is just { accessToken,
 * refreshToken } (see auth.controller.ts's registerWithEmailAndPassword) -
 * it does not echo the user or its id, so the id is read back via the
 * authenticated GET /api/user profile endpoint instead.
 */
const registerAndGetUser = async (
  emailPrefix: string,
): Promise<{ userId: string; token: string }> => {
  const registerRes = await api("/api/auth/email-password/register", {
    method: "POST",
    body: {
      email: `${emailPrefix}${crypto.randomUUID().slice(0, 8)}@test.local`,
      password: "TestPass123!Xx",
    },
  });
  assert.equal(registerRes.status, 201, JSON.stringify(registerRes.body));
  const token = registerRes.body.accessToken as string;
  assert.ok(token, "register response must include an accessToken");

  const profileRes = await api("/api/user", { token });
  assert.equal(profileRes.status, 200, JSON.stringify(profileRes.body));
  const userId = profileRes.body.id as string;
  assert.ok(userId, "GET /api/user response must include an id");

  return { userId, token };
};

/**
 * Removes every fixture account this script's naming convention could have
 * created, by email prefix rather than by this run's own IDs, so a
 * previous run that crashed before its own cleanup (leaving a stray
 * dedup-http-...@test.local account behind, for example) is swept up too.
 * Safe by construction: only ever matches the three prefixes this script
 * itself uses, all under the synthetic @test.local domain.
 */
const cleanupFixtureAccounts = async () => {
  const strayUsers = await prisma.user.findMany({
    where: {
      OR: [
        { email: { startsWith: "dedup-http-", endsWith: "@test.local" } },
        { email: { startsWith: "dedup-service-", endsWith: "@test.local" } },
        { email: { startsWith: "dedup-race-", endsWith: "@test.local" } },
      ],
    },
    select: { id: true },
  });
  const ids = strayUsers.map((u) => u.id);
  if (ids.length === 0) return;

  await prisma.locationSubscription.deleteMany({
    where: { userId: { in: ids } },
  });
  await prisma.user.deleteMany({ where: { id: { in: ids } } });
  console.log(
    `Cleanup: removed ${ids.length} fixture account(s) (dedup-http-/dedup-service-/dedup-race- @test.local) and their location rows.`,
  );
};

async function main() {
  console.log("Duplicate 'My Location' regression verification (real HTTP + real DB)\n");

  console.log("Setup: HTTP path (PUT /api/user, mirrors repeated login/app-start)");
  const { userId: httpUserId, token: httpToken } =
    await registerAndGetUser("dedup-http-");

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
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    // Runs whether main() succeeded, threw partway through, or failed
    // before creating every fixture user - always sweeps by naming
    // convention rather than relying on which local variables got
    // assigned before a failure.
    try {
      await cleanupFixtureAccounts();
    } catch (cleanupError) {
      console.error("Cleanup failed:", cleanupError);
    }
    await prisma.$disconnect();
  });

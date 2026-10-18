/**
 * Verifies the anti-doxing "post only within 1km of your location" rule for
 * community reports (real HTTP against a NODE_ENV=test instance, real DB).
 *
 * Cases:
 *  1. posting for a location < 1 km from the reporter's own position  -> 201
 *  2. posting for a location > 1 km from the reporter's own position  -> 422
 *  3. posting WITHOUT the reporter's own position                     -> 422 (fail-closed)
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_community_post_radius.ts
 */

import assert from "node:assert/strict";
import { PrismaClient } from "@prisma/client";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

const registerUser = async () => {
  const email = `post-radius-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await fetch(`${BASE_URL}/api/auth/email-password/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: "TestPass123!Xx" }),
  });
  const body = (await res.json()) as any;
  assert.equal(res.status, 201, `register: ${JSON.stringify(body)}`);
  const token = body.accessToken as string;
  const me = (await (
    await fetch(`${BASE_URL}/api/user`, { headers: { Authorization: `Bearer ${token}` } })
  ).json()) as any;
  return { token, id: (me.data ?? me).id as string };
};

const post = async (token: string, hazard: Record<string, unknown>) => {
  const form = new FormData();
  form.append("hazard", JSON.stringify({ ...hazard, useDummyAi: true }));
  const res = await fetch(`${BASE_URL}/api/hazards`, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}` },
    body: form,
  });
  let body: any = null;
  try {
    body = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body };
};

async function main() {
  console.log("Community report post-radius (1km anti-doxing) rule\n");

  const { getAllMainHazardCategoryIds } = await import("../services/hazard_category.service.js");
  const [categoryId] = (await getAllMainHazardCategoryIds()) as [string];
  const tag = `post-radius-${crypto.randomUUID().slice(0, 8)}`;
  const user = await registerUser();
  // A random point nobody else posts near, so re-runs never collide with
  // leftovers from a previous run (the duplicate guard is 500 m).
  const lat = -64 - Math.random() * 5;
  const lng = 100 + Math.random() * 30;

  try {
    // 1. Posting for a location essentially AT the reporter's position -> 201.
    await check("posting for a location ~0 km from the reporter is accepted (201)", async () => {
      const res = await post(user.token, {
        title: `${tag} nearby`,
        description: "within 1km",
        categoryId,
        latitude: lat,
        longitude: lng,
        reporterLatitude: lat,
        reporterLongitude: lng,
      });
      assert.equal(res.status, 201, JSON.stringify(res.body));
    });

    // 2. Posting for a location ~0.005 deg lat (~0.55 km) away -> still within 1km -> 201.
    await check("posting for a location ~0.5 km away is accepted (201)", async () => {
      const res = await post(user.token, {
        title: `${tag} half-km`,
        description: "within 1km",
        categoryId,
        latitude: lat + 0.005,
        longitude: lng,
        reporterLatitude: lat,
        reporterLongitude: lng,
      });
      assert.equal(res.status, 201, JSON.stringify(res.body));
    });

    // 3. Posting for a location ~0.02 deg lat (~2.2 km) away -> rejected (422).
    await check("posting for a location ~2 km away is rejected (422)", async () => {
      const res = await post(user.token, {
        title: `${tag} far`,
        description: "outside 1km",
        categoryId,
        latitude: lat + 0.02,
        longitude: lng,
        reporterLatitude: lat,
        reporterLongitude: lng,
      });
      assert.equal(res.status, 422, JSON.stringify(res.body));
      assert.match(
        String((res.body as any)?.message ?? res.body),
        /within .* km of where you are/i,
        JSON.stringify(res.body),
      );
    });

    // 4. Posting without the reporter's own position -> rejected (fail-closed, 422).
    await check("posting without the reporter's position is rejected (422)", async () => {
      const res = await post(user.token, {
        title: `${tag} no-coords`,
        description: "missing reporter position",
        categoryId,
        latitude: lat,
        longitude: lng,
      });
      assert.equal(res.status, 422, JSON.stringify(res.body));
    });

    console.log(`\nAll ${passed} checks passed.`);
  } catch (error) {
    console.error(`\n  NOT ok - ${(error as Error).message}`);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

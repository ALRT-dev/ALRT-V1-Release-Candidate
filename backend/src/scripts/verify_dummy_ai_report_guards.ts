/**
 * A TEST "dummy AI" community report (useDummyAi: true on a NODE_ENV=test
 * server) skips only the AI calls. The abuse guards in
 * assertCanPostCommunityReport still run: the 500 m same-category
 * duplicate check (409) and the per-person hourly limit (429). Before this,
 * a dummy-AI build bypassed both, so TEST could never exercise them.
 *
 * Real HTTP against a running NODE_ENV=test instance of this backend
 * (default limits: 3 an hour, 500 m duplicate radius), real Postgres.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_dummy_ai_report_guards.ts
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
  const email = `dummy-guards-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await fetch(`${BASE_URL}/api/auth/email-password/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: "TestPass123!Xx" }),
  });
  const body = (await res.json()) as any;
  assert.equal(res.status, 201, `register: ${JSON.stringify(body)}`);
  const token = body.accessToken as string;
  const me = (await (await fetch(`${BASE_URL}/api/user`, { headers: { Authorization: `Bearer ${token}` } })).json()) as any;
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
  console.log("Dummy-AI community reports still run the posting guards (real HTTP, real DB)\n");

  const { getAllMainHazardCategoryIds } = await import("../services/hazard_category.service.js");
  const [categoryId] = (await getAllMainHazardCategoryIds()) as [string];
  const tag = `dummy-guards-${crypto.randomUUID().slice(0, 8)}`;
  const user = await registerUser();
  // A point nobody else posts near.
  const lat = -64.2468;
  const lng = 104.1357;

  try {
    const report = (dLat: number) => ({
      title: `${tag} report`,
      description: "dummy ai guard check",
      categoryId,
      latitude: lat + dLat,
      longitude: lng,
    });

    await check("first dummy-AI report is created", async () => {
      const res = await post(user.token, report(0));
      assert.equal(res.status, 201, JSON.stringify(res.body));
    });
    await check("a second one within 500 m, same category, is refused as a duplicate (409)", async () => {
      const res = await post(user.token, report(0.001)); // ~110 m
      assert.equal(res.status, 409, JSON.stringify(res.body));
      assert.ok(res.body?.details?.existingHazardId, "names the existing alert");
    });
    await check("reports far apart are accepted up to the hourly limit", async () => {
      for (const d of [0.1, 0.2]) {
        const res = await post(user.token, report(d));
        assert.equal(res.status, 201, JSON.stringify(res.body));
      }
    });
    await check("the next one is refused by the hourly limit (429)", async () => {
      const res = await post(user.token, report(0.3));
      assert.equal(res.status, 429, JSON.stringify(res.body));
    });
  } finally {
    await prisma.hazard.deleteMany({ where: { reportedById: user.id } });
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

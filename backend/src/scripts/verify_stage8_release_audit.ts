/**
 * Stage 8 verification script — real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres+PostGIS
 * database. Covers the specific defects the Stage 8 release-readiness
 * audit found and fixed:
 *
 *   1. GET /api/hazards and GET /api/notifications/feed both called
 *      validate(schema) with no "query" target (defaults to "body", which
 *      is always {} on a GET) - so their pageSize bounds were never
 *      enforced against the real query string. Same class of bug Stage 7B
 *      fixed for the admin routes; these two public/user routes were
 *      missed at the time. Fixed by adding "query" as the second argument
 *      (hazard.route.ts, notification.route.ts) and, for notifications,
 *      adding the missing bound itself to the schema (it had none at all).
 *   2. POST /api/hazard-categories/ let any authenticated user create
 *      arbitrary hazard categories with zero body validation and no admin
 *      check - confirmed unused by the real mobile app (its generated
 *      REST client never calls it) and removed.
 *   3. /api/revenuecat/webhook was mounted twice under two casings of the
 *      same import; the earlier mount sat before the general rate limiter
 *      and, since Express matches the first registered route, silently
 *      absorbed every request - leaving the webhook completely
 *      unrate-limited despite looking protected. Reduced to one mount,
 *      positioned after the general limiter like every other route.
 *
 * Setup: same as verify_stage7b_admin_hardening.ts - see that file's
 * header comment and V1_RECONCILIATION_REPORT.md §25 for the exact
 * commands. Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_stage8_release_audit.ts
 */

import assert from "node:assert/strict";

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
  let json: unknown = null;
  try {
    json = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body: json };
};

async function main() {
  console.log("Stage 8 verification (real HTTP + real DB)\n");

  const uniqueSuffix = crypto.randomUUID().slice(0, 8);
  const email = `stage8-${uniqueSuffix}@test.local`;
  const password = "TestPass123!Xx";

  const register = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password, name: "Stage 8 smoke user" },
  });
  assert.equal(register.status, 201);
  const token = (register.body as any).accessToken as string;
  console.log("  setup - registered a real user\n");

  console.log("§25 pagination fixes (public routes, not just admin)");

  await check(
    "GET /api/hazards accepts a normal pageSize",
    async () => {
      const res = await api("/api/hazards?pageSize=20", { token });
      assert.equal(res.status, 200);
    },
  );

  await check(
    "GET /api/hazards now REJECTS an oversized pageSize (was silently unbounded)",
    async () => {
      const res = await api("/api/hazards?pageSize=999999999", { token });
      assert.equal(res.status, 400);
    },
  );

  await check(
    "GET /api/notifications/feed accepts a normal pageSize",
    async () => {
      const res = await api("/api/notifications/feed?pageSize=20", { token });
      assert.equal(res.status, 200);
    },
  );

  await check(
    "GET /api/notifications/feed now REJECTS an oversized pageSize (previously had no bound at all)",
    async () => {
      const res = await api("/api/notifications/feed?pageSize=999999999", {
        token,
      });
      assert.equal(res.status, 400);
    },
  );

  console.log();
  console.log("§25 dead/unsafe route removed");

  await check(
    "POST /api/hazard-categories/ no longer exists (was: any authed user, zero validation)",
    async () => {
      const res = await api("/api/hazard-categories/", {
        method: "POST",
        token,
        body: { name: "should not be creatable" },
      });
      assert.equal(res.status, 404);
    },
  );

  await check(
    "GET /api/hazard-categories/ (the routes real callers actually use) still works",
    async () => {
      const res = await api("/api/hazard-categories/", { token });
      assert.equal(res.status, 200);
    },
  );

  console.log();
  console.log("§25 duplicate RevenueCat mount fixed");

  await check(
    "POST /api/revenuecat/webhook reaches the single remaining mount (real response, not 404)",
    async () => {
      const res = await api("/api/revenuecat/webhook", {
        method: "POST",
        body: {},
      });
      // REVENUECAT_WEBHOOK_AUTH is unset in the test env, so the
      // controller refuses loudly (503) rather than accepting an
      // unauthenticated entitlement write - the point here is just that
      // routing reaches a real handler at all, not a stray 404 from a
      // missing mount.
      assert.notEqual(res.status, 404);
    },
  );

  console.log(`\n${passed} checks passed.`);
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  });

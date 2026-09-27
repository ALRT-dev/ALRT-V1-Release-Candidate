/**
 * Stage 7B verification script — real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres+PostGIS
 * database (not mocked). Unlike prior stages' verify_* scripts (which were
 * scoped to dependency-light pure functions because no live DB was
 * available in that environment), this environment has a local
 * postgresql-16 + postgis install, so this script exercises the actual
 * Express route/middleware/Prisma chain end to end: real login, real JWTs,
 * real role checks, real 400/401/403/404 responses, real DB writes.
 *
 * Setup (see also the Stage 7B report section for the exact commands):
 *   1. `service postgresql start`
 *   2. createdb + `CREATE EXTENSION postgis` on a throwaway test database
 *   3. `npx dotenv -e .env.test -- npx prisma db push --skip-generate`
 *   4. Start the server: `NODE_ENV=test npx tsx src/index.ts`
 *   5. Run this script: `NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_stage7b_admin_hardening.ts`
 *
 * .env.test and serviceAccountKey.json are test-only fixtures with fake
 * credentials, never committed (serviceAccountKey.json is gitignored;
 * .env.test is deleted after verification - see the Stage 7B report).
 */

import assert from "node:assert/strict";
import { PrismaClient, AdminRole, HazardReviewStatus } from "@prisma/client";
import { signAccessToken } from "../utils/jwt.util.js";

const prisma = new PrismaClient();
const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";

const SUPER_ADMIN_EMAIL = "superadmin@test.local";
const SUPER_ADMIN_PASSWORD = "TestSuperAdmin123!";

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

const api = async (
  path: string,
  opts: {
    method?: string;
    token?: string;
    body?: unknown;
  } = {},
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
  console.log("Stage 7B verification (real HTTP + real DB)\n");

  // --- Setup ---------------------------------------------------------
  console.log("Setup");

  const superLogin = await api("/api/admin/auth/login", {
    method: "POST",
    body: { email: SUPER_ADMIN_EMAIL, password: SUPER_ADMIN_PASSWORD },
  });
  assert.equal(superLogin.status, 200, "super admin login must succeed");
  const superAdminToken = (superLogin.body as any).accessToken as string;
  console.log("  setup - logged in as seeded super admin");

  const uniqueSuffix = crypto.randomUUID().slice(0, 8);
  const adminEmail = `stage7b-admin-${uniqueSuffix}@test.local`;
  const moderatorEmail = `stage7b-moderator-${uniqueSuffix}@test.local`;
  const testPassword = "TestAdmin123!Xx";

  const createAdminRes = await api("/api/admin/users/create", {
    method: "POST",
    token: superAdminToken,
    body: {
      email: adminEmail,
      password: testPassword,
      name: "Stage 7B Admin",
      role: "admin",
    },
  });
  assert.equal(createAdminRes.status, 201, "creating an admin must succeed");

  const createModeratorRes = await api("/api/admin/users/create", {
    method: "POST",
    token: superAdminToken,
    body: {
      email: moderatorEmail,
      password: testPassword,
      name: "Stage 7B Moderator",
      role: "moderator",
    },
  });
  assert.equal(
    createModeratorRes.status,
    201,
    "creating a moderator must succeed",
  );

  // Seeded admins force a password change on first login - flip that off
  // directly via Prisma so /login can be used for the rest of this script
  // (avoids re-implementing the change-password flow just for test setup).
  await prisma.admin.updateMany({
    where: { email: { in: [adminEmail, moderatorEmail] } },
    data: { mustChangePassword: false },
  });

  const adminLogin = await api("/api/admin/auth/login", {
    method: "POST",
    body: { email: adminEmail, password: testPassword },
  });
  assert.equal(adminLogin.status, 200);
  const adminToken = (adminLogin.body as any).accessToken as string;

  const moderatorLogin = await api("/api/admin/auth/login", {
    method: "POST",
    body: { email: moderatorEmail, password: testPassword },
  });
  assert.equal(moderatorLogin.status, 200);
  const moderatorToken = (moderatorLogin.body as any).accessToken as string;

  const testUser = await prisma.user.create({
    data: {
      email: `stage7b-user-${uniqueSuffix}@test.local`,
      name: "Stage 7B Ordinary User",
    },
  });
  const ordinaryUserToken = signAccessToken({ userId: testUser.id });

  const category = await prisma.hazardCategory.findFirst();
  assert.ok(category, "a seeded hazard category must exist for setup");

  console.log("  setup - created admin/moderator/ordinary-user identities\n");

  // --- §7 Security testing: role matrix -------------------------------
  console.log("§7 Role matrix (real HTTP)");

  await check("ordinary user cannot list AI prompts (admin-only surface)", async () => {
    const res = await api("/api/admin/ai-prompts", { token: ordinaryUserToken });
    assert.equal(res.status, 401);
  });

  await check("ordinary user cannot access the hazards moderation queue", async () => {
    const res = await api("/api/admin/hazards?reviewStatus=pending", {
      token: ordinaryUserToken,
    });
    assert.equal(res.status, 401);
  });

  await check("request with no token at all is rejected", async () => {
    const res = await api("/api/admin/hazards");
    assert.equal(res.status, 401);
  });

  await check("moderator CAN read AI prompts (moderator-appropriate)", async () => {
    const res = await api("/api/admin/ai-prompts", { token: moderatorToken });
    assert.equal(res.status, 200);
  });

  await check("moderator CANNOT create an AI prompt (admin-tier op)", async () => {
    const res = await api("/api/admin/ai-prompts", {
      method: "POST",
      token: moderatorToken,
      body: {
        name: `should-be-rejected-${uniqueSuffix}`,
        content: "test",
        variables: [],
        model: "gpt-4o-mini",
        groupId: "does-not-matter",
      },
    });
    assert.equal(res.status, 403);
  });

  await check("moderator CANNOT modify (create) privileged Configuration", async () => {
    const res = await api("/api/admin/configurations", {
      method: "POST",
      token: moderatorToken,
      body: { key: "aiPrompts", value: {}, title: "should be rejected" },
    });
    assert.equal(res.status, 403);
  });

  await check("moderator CANNOT mint a webhook API key", async () => {
    const res = await api("/api/admin/webhook-api-keys", {
      method: "POST",
      token: moderatorToken,
      body: { name: `should-be-rejected-${uniqueSuffix}` },
    });
    assert.equal(res.status, 403);
  });

  await check("moderator CANNOT create an admin account (superAdmin-only)", async () => {
    const res = await api("/api/admin/users/create", {
      method: "POST",
      token: moderatorToken,
      body: {
        email: `should-not-exist-${uniqueSuffix}@test.local`,
        password: testPassword,
        role: "admin",
      },
    });
    assert.equal(res.status, 403);
  });

  await check("moderator CAN review a community report (moderator-appropriate)", async () => {
    const hazard = await prisma.hazard.create({
      data: {
        title: "Role-matrix probe hazard",
        description: "Created directly for Stage 7B role-matrix testing",
        categoryId: category!.id,
        reportedById: testUser.id,
        reviewStatus: HazardReviewStatus.pending,
      },
    });
    const res = await api(`/api/admin/hazards/${hazard.id}/review`, {
      method: "PATCH",
      token: moderatorToken,
      body: { reviewStatus: "accepted" },
    });
    assert.equal(res.status, 200);
  });

  await check(
    "admin CAN create an AI prompt group (admin-appropriate; the prompt-content " +
      "create/update routes require calling out to the real AI provider to validate " +
      "the model id, which this environment has no live AWS/OpenAI credentials for - " +
      "same class of external dependency as no test runner/no Flutter binary in prior " +
      "stages, so the group route - same requireAdminOrAbove gate, no external call - " +
      "is used to verify the role check itself)",
    async () => {
      const res = await api("/api/admin/ai-prompts/groups", {
        method: "POST",
        token: adminToken,
        body: {
          name: `stage7b-admin-created-group-${uniqueSuffix}`,
          description: "Stage 7B role-matrix probe",
        },
      });
      assert.equal(res.status, 201);
    },
  );

  await check("admin CANNOT create an admin account (superAdmin-only op exists)", async () => {
    const res = await api("/api/admin/users/create", {
      method: "POST",
      token: adminToken,
      body: {
        email: `should-not-exist-2-${uniqueSuffix}@test.local`,
        password: testPassword,
        role: "admin",
      },
    });
    assert.equal(res.status, 403);
  });

  await check("admin CANNOT deactivate an admin account (superAdmin-only op exists)", async () => {
    const targetAdmin = await prisma.admin.findUniqueOrThrow({
      where: { email: moderatorEmail },
    });
    const res = await api(`/api/admin/users/admins/${targetAdmin.id}/active`, {
      method: "PATCH",
      token: adminToken,
      body: { isActive: false },
    });
    assert.equal(res.status, 403);
  });

  await check("super admin CAN mint a webhook API key (full capability)", async () => {
    const res = await api("/api/admin/webhook-api-keys", {
      method: "POST",
      token: superAdminToken,
      body: { name: `stage7b-superadmin-key-${uniqueSuffix}` },
    });
    assert.equal(res.status, 201);
    assert.ok((res.body as any).apiKey, "plaintext key returned exactly once");
  });

  await check("super admin CAN create an admin account (full capability)", async () => {
    const res = await api("/api/admin/users/create", {
      method: "POST",
      token: superAdminToken,
      body: {
        email: `stage7b-created-by-superadmin-${uniqueSuffix}@test.local`,
        password: testPassword,
        role: "moderator",
      },
    });
    assert.equal(res.status, 201);
  });

  console.log();

  // --- §8 Moderation testing ------------------------------------------
  console.log("§8 Moderation behaviour (real HTTP + real DB persistence)");

  let pendingHazard = await prisma.hazard.create({
    data: {
      title: "Community report - moderation test",
      description: "A pending community report awaiting moderation",
      categoryId: category!.id,
      reportedById: testUser.id,
      reviewStatus: HazardReviewStatus.pending,
    },
  });

  await check("pending report appears in the moderation queue (?reviewStatus=pending)", async () => {
    const res = await api(
      `/api/admin/hazards?reviewStatus=pending&pageSize=100`,
      { token: adminToken },
    );
    assert.equal(res.status, 200);
    const ids = (res.body as any[]).map((h) => h.id);
    assert.ok(ids.includes(pendingHazard.id));
  });

  await check("approve changes reviewStatus to accepted and persists it", async () => {
    const res = await api(`/api/admin/hazards/${pendingHazard.id}/review`, {
      method: "PATCH",
      token: adminToken,
      body: { reviewStatus: "accepted" },
    });
    assert.equal(res.status, 200);
    assert.equal(res.body && (res.body as any).reviewStatus, "accepted");

    const row = await prisma.hazard.findUniqueOrThrow({
      where: { id: pendingHazard.id },
    });
    assert.equal(row.reviewStatus, HazardReviewStatus.accepted);
    assert.ok(row.reviewedAt, "reviewedAt must be set on accept");
    assert.ok(row.reviewedById, "reviewedById must be set");
    assert.ok(
      row.expiresAt,
      "expiresAt must be backfilled on accept when previously unset",
    );
  });

  let rejectHazard = await prisma.hazard.create({
    data: {
      title: "Community report - reject test",
      description: "A pending community report to be rejected",
      categoryId: category!.id,
      reportedById: testUser.id,
      reviewStatus: HazardReviewStatus.pending,
    },
  });

  await check("reject without a reason is rejected with 400 (reason required)", async () => {
    const res = await api(`/api/admin/hazards/${rejectHazard.id}/review`, {
      method: "PATCH",
      token: adminToken,
      body: { reviewStatus: "rejected" },
    });
    assert.equal(res.status, 400);
  });

  await check("reject WITH a reason changes reviewStatus and persists the reason", async () => {
    const res = await api(`/api/admin/hazards/${rejectHazard.id}/review`, {
      method: "PATCH",
      token: adminToken,
      body: {
        reviewStatus: "rejected",
        reviewFeedback: "Duplicate of an existing accepted report",
      },
    });
    assert.equal(res.status, 200);

    const row = await prisma.hazard.findUniqueOrThrow({
      where: { id: rejectHazard.id },
    });
    assert.equal(row.reviewStatus, HazardReviewStatus.rejected);
    assert.equal(
      row.reviewFeedback,
      "Duplicate of an existing accepted report",
    );
    assert.ok(row.reviewedAt, "reviewedAt must be set on reject too, not only accept");
    assert.ok(row.reviewedById);
  });

  await check("repeated review (re-review an already-decided report) behaves safely", async () => {
    const res = await api(`/api/admin/hazards/${rejectHazard.id}/review`, {
      method: "PATCH",
      token: adminToken,
      body: { reviewStatus: "accepted" },
    });
    assert.equal(res.status, 200);
    const row = await prisma.hazard.findUniqueOrThrow({
      where: { id: rejectHazard.id },
    });
    assert.equal(row.reviewStatus, HazardReviewStatus.accepted);
  });

  await check("reviewing a non-existent hazard id returns 404", async () => {
    const res = await api(
      "/api/admin/hazards/00000000-0000-0000-0000-000000000000/review",
      {
        method: "PATCH",
        token: adminToken,
        body: { reviewStatus: "accepted" },
      },
    );
    assert.equal(res.status, 404);
  });

  await check("unauthorised (no token) cannot review a report", async () => {
    const res = await api(`/api/admin/hazards/${pendingHazard.id}/review`, {
      method: "PATCH",
      body: { reviewStatus: "accepted" },
    });
    assert.equal(res.status, 401);
  });

  await check("ordinary user cannot review a report", async () => {
    const res = await api(`/api/admin/hazards/${pendingHazard.id}/review`, {
      method: "PATCH",
      token: ordinaryUserToken,
      body: { reviewStatus: "accepted" },
    });
    assert.equal(res.status, 401);
  });

  await check(
    "review endpoint never lets an admin set sourceId (cannot manufacture official attribution)",
    async () => {
      const before = await prisma.hazard.findUniqueOrThrow({
        where: { id: pendingHazard.id },
      });
      assert.equal(before.sourceId, null);
      // The body schema has no sourceId field at all - even if a client
      // sends one, it is silently dropped by the Zod schema (strict shape),
      // never reaching the Prisma update.
      const res = await api(`/api/admin/hazards/${pendingHazard.id}/review`, {
        method: "PATCH",
        token: adminToken,
        body: { reviewStatus: "accepted", sourceId: "some-official-source-id" },
      });
      assert.equal(res.status, 200);
      const after = await prisma.hazard.findUniqueOrThrow({
        where: { id: pendingHazard.id },
      });
      assert.equal(
        after.sourceId,
        null,
        "sourceId must be untouched by a moderation decision",
      );
    },
  );

  console.log();

  // --- §9 Audit log testing --------------------------------------------
  console.log("§9 Audit log");

  await check("a moderation decision writes an AdminAuditLog row with who/what/when/resource", async () => {
    const log = await prisma.adminAuditLog.findFirst({
      where: { action: "hazard.review", targetId: pendingHazard.id },
      orderBy: { createdAt: "desc" },
    });
    assert.ok(log, "expected an AdminAuditLog row for the review action");
    assert.ok(log!.adminId, "who");
    assert.equal(log!.action, "hazard.review"); // what
    assert.ok(log!.createdAt); // when
    assert.equal(log!.targetType, "Hazard"); // affected resource
    assert.equal(log!.targetId, pendingHazard.id);
  });

  await check("a webhook API key creation is audited WITHOUT the key/hash anywhere in the row", async () => {
    const log = await prisma.adminAuditLog.findFirst({
      where: { action: "webhookApiKey.create" },
      orderBy: { createdAt: "desc" },
    });
    assert.ok(log);
    const serialized = JSON.stringify(log);
    assert.ok(
      !/whk_/.test(serialized),
      "plaintext API key prefix must never appear in the audit log",
    );
    assert.ok(
      !("keyHash" in ((log!.after as any) ?? {})) &&
        !("keyHash" in ((log!.before as any) ?? {})),
      "keyHash field must never be logged",
    );
  });

  await check("an admin account creation is audited WITHOUT a password field", async () => {
    const log = await prisma.adminAuditLog.findFirst({
      where: { action: "admin.create" },
      orderBy: { createdAt: "desc" },
    });
    assert.ok(log);
    const serialized = JSON.stringify(log).toLowerCase();
    assert.ok(!serialized.includes(testPassword.toLowerCase()));
    assert.ok(!serialized.includes("passwordhash"));
  });

  await check("a Configuration mutation is audited WITHOUT its `value` payload", async () => {
    // The super admin's mint-key call above didn't touch Configuration; use
    // the seeded aiPrompts configuration update path instead by editing it
    // as super admin, then checking the resulting audit row.
    const existingConfig = await prisma.configuration.findFirst();
    assert.ok(existingConfig, "a seeded Configuration row must exist");
    const res = await api(`/api/admin/configurations/${existingConfig!.id}`, {
      method: "PUT",
      token: superAdminToken,
      body: { title: "Stage 7B audit-log probe title" },
    });
    assert.equal(res.status, 200);

    const log = await prisma.adminAuditLog.findFirst({
      where: { action: "configuration.update", targetId: existingConfig!.id },
      orderBy: { createdAt: "desc" },
    });
    assert.ok(log);
    assert.ok(
      !("value" in ((log!.after as any) ?? {})) &&
        !("value" in ((log!.before as any) ?? {})),
      "Configuration's `value` JSON blob must never be logged verbatim",
    );
  });

  console.log();

  // --- §5 Pagination safety --------------------------------------------
  console.log("§5 Pagination safety");

  await check("GET /admin/hazards rejects a pageSize above the cap (was unbounded)", async () => {
    const res = await api("/api/admin/hazards?pageSize=999999", {
      token: adminToken,
    });
    assert.equal(res.status, 400);
  });

  await check("GET /admin/hazards accepts a pageSize at the cap", async () => {
    const res = await api("/api/admin/hazards?pageSize=100", {
      token: adminToken,
    });
    assert.equal(res.status, 200);
  });

  await check(
    "GET /admin/webhook-api-keys/logs/all rejects a pageSize above the cap (was unbounded)",
    async () => {
      const res = await api("/api/admin/webhook-api-keys/logs/all?pageSize=999999", {
        token: adminToken,
      });
      assert.equal(res.status, 400);
    },
  );

  console.log();

  // --- §6 Validators ------------------------------------------------
  console.log("§6 Previously-unattached validators now reject bad input");

  await check("PUT /admin/hazards/:id rejects an invalid severity before reaching the service layer", async () => {
    const res = await api(`/api/admin/hazards/${pendingHazard.id}`, {
      method: "PUT",
      token: adminToken,
      body: { severity: "not-a-real-severity" },
    });
    assert.equal(res.status, 400);
  });

  await check("POST /admin/hazards/sync-external rejects an invalid syncOption", async () => {
    const res = await api("/api/admin/hazards/sync-external", {
      method: "POST",
      token: adminToken,
      body: { syncOption: "not-a-real-option" },
    });
    assert.equal(res.status, 400);
  });

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

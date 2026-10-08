/**
 * Admin moderation visibility, audit log gaps and dashboard day boundary
 * (real HTTP against a running backend + real local Postgres).
 *
 * 1. GET /api/admin/hazards (admin auth only) shows the exact pin, the
 *    reporter's name and email, and the reviewing admin's email/name.
 * 2. GET /api/hazards (the app route) still hides the reporter and rounds
 *    community coordinates to 2 decimals, even for the same hazard.
 * 3. The admin route refuses an ordinary app user's token and no token.
 * 4. Admin app-user schedule/cancel deletion, hazard delete, hazard sync and
 *    hazard category edit write AdminAuditLog rows.
 * 5. /api/admin/stats/dashboard uses the Australia/Brisbane day start and
 *    its user total excludes deletion-requested users (matches /api/admin/stats).
 *
 * Run: TEST_SERVER_URL=http://localhost:<port> npx tsx src/scripts/verify_admin_moderation_privacy.ts
 * with .env.test loaded.
 */

import assert from "node:assert/strict";
import { PrismaClient, HazardReviewStatus } from "@prisma/client";
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
  let json: any = null;
  try {
    json = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body: json };
};

const login = async (email: string, password: string): Promise<string> => {
  const res = await api("/api/admin/auth/login", {
    method: "POST",
    body: { email, password },
  });
  assert.equal(res.status, 200, `login ${email} must succeed`);
  return res.body.accessToken as string;
};

const latestAudit = (action: string, targetId: string | null) =>
  prisma.adminAuditLog.findFirst({
    where: { action, ...(targetId ? { targetId } : {}) },
    orderBy: { createdAt: "desc" },
  });

async function main() {
  console.log("Admin moderation privacy / audit / dashboard verification\n");

  await prisma.admin.updateMany({
    where: { email: SUPER_ADMIN_EMAIL },
    data: { mustChangePassword: false },
  });
  const superToken = await login(SUPER_ADMIN_EMAIL, SUPER_ADMIN_PASSWORD);

  const suffix = crypto.randomUUID().slice(0, 8);
  const password = "TestAdmin123!Xx";
  const adminEmail = `modpriv-admin-${suffix}@test.local`;
  const moderatorEmail = `modpriv-mod-${suffix}@test.local`;
  for (const [email, role, name] of [
    [adminEmail, "admin", "ModPriv Admin"],
    [moderatorEmail, "moderator", "ModPriv Moderator"],
  ] as const) {
    const res = await api("/api/admin/users/create", {
      method: "POST",
      token: superToken,
      body: { email, password, name, role },
    });
    assert.equal(res.status, 201, `create ${role}`);
  }
  await prisma.admin.updateMany({
    where: { email: { in: [adminEmail, moderatorEmail] } },
    data: { mustChangePassword: false },
  });
  const adminToken = await login(adminEmail, password);
  const moderatorToken = await login(moderatorEmail, password);
  const moderator = await prisma.admin.findUniqueOrThrow({
    where: { email: moderatorEmail },
  });

  const reporterEmail = `modpriv-reporter-${suffix}@test.local`;
  const reporter = await prisma.user.create({
    data: { email: reporterEmail, name: `Reporter ${suffix}` },
  });
  const viewer = await prisma.user.create({
    data: { email: `modpriv-viewer-${suffix}@test.local`, name: "Viewer" },
  });
  const viewerToken = signAccessToken({ userId: viewer.id });

  const category = await prisma.hazardCategory.findFirst({
    where: { parentId: { not: null } },
  });
  assert.ok(category, "a seeded sub-category must exist");

  const exactLat = -27.469812;
  const exactLng = 153.025134;
  const title = `ModPriv probe ${suffix}`;
  const hazard = await prisma.hazard.create({
    data: {
      title,
      description: "Community report created for admin privacy verification",
      categoryId: category!.id,
      reportedById: reporter.id,
      reviewStatus: HazardReviewStatus.pending,
      latitude: exactLat,
      longitude: exactLng,
      locationName: "Brisbane City",
    },
  });

  console.log("§13 Admin sees reporter + exact pin; app route unchanged");

  await check("moderator reviews (accepts) the report", async () => {
    const res = await api(`/api/admin/hazards/${hazard.id}/review`, {
      method: "PATCH",
      token: moderatorToken,
      body: { reviewStatus: "accepted" },
    });
    assert.equal(res.status, 200);
  });

  const search = `searchString=${encodeURIComponent(title)}&ignoreHazardLatLngBounds=true`;

  await check("admin route shows reporter name/email, exact coords and reviewer", async () => {
    const res = await api(`/api/admin/hazards?${search}`, { token: moderatorToken });
    assert.equal(res.status, 200);
    const row = (res.body as any[]).find((h) => h.id === hazard.id);
    assert.ok(row, "probe hazard must be listed on the admin route");
    assert.equal(row.latitude, exactLat);
    assert.equal(row.longitude, exactLng);
    assert.equal(row.reportedBy?.id, reporter.id);
    assert.equal(row.reportedBy?.name, `Reporter ${suffix}`);
    assert.equal(row.reportedBy?.email, reporterEmail);
    assert.equal(row.reviewedById, moderator.id);
    assert.equal(row.reviewedBy?.email, moderatorEmail);
    assert.equal(row.reviewedBy?.name, "ModPriv Moderator");
  });

  await check("app route hides the reporter and rounds coords for another viewer", async () => {
    const res = await api(`/api/hazards?${search}`, { token: viewerToken });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const list = Array.isArray(res.body) ? res.body : res.body?.data ?? res.body?.hazards;
    const row = (list as any[]).find((h) => h.id === hazard.id);
    assert.ok(row, "probe hazard must be listed on the app route");
    assert.equal(row.latitude, Math.round(exactLat * 100) / 100);
    assert.equal(row.longitude, Math.round(exactLng * 100) / 100);
    assert.notEqual(row.latitude, exactLat);
    assert.equal(row.reportedBy?.name, undefined);
    assert.equal(row.reportedBy?.email, undefined);
    assert.equal(row.reportedBy?.id, undefined);
    assert.equal(row.reviewedBy, undefined);
    assert.ok(!JSON.stringify(row).includes(reporterEmail), "no reporter email anywhere");
    assert.ok(!JSON.stringify(row).includes(moderatorEmail), "no reviewer email anywhere");
  });

  await check("admin route refuses an app user's token and no token", async () => {
    assert.equal((await api(`/api/admin/hazards?${search}`, { token: viewerToken })).status, 401);
    assert.equal((await api(`/api/admin/hazards?${search}`)).status, 401);
  });

  console.log("\n§14 Audit log gaps");

  await check("schedule deletion writes appUser.scheduleDeletion", async () => {
    const res = await api(`/api/admin/users/app-users/${viewer.id}`, {
      method: "DELETE",
      token: adminToken,
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const row = await latestAudit("appUser.scheduleDeletion", viewer.id);
    assert.ok(row, "audit row must exist");
    assert.equal(row!.targetType, "User");
    assert.equal(row!.adminId, (await prisma.admin.findUniqueOrThrow({ where: { email: adminEmail } })).id);
  });

  await check("dashboard total excludes deletion-requested users and matches /api/admin/stats", async () => {
    // Other sessions share this database; retry if a user is created
    // between the two reads.
    let ok = false;
    for (let attempt = 0; attempt < 3 && !ok; attempt += 1) {
      const dash = await api("/api/admin/stats/dashboard", { token: adminToken });
      const stats = await api("/api/admin/stats", { token: adminToken });
      assert.equal(dash.status, 200);
      assert.equal(stats.status, 200);
      const expected = await prisma.user.count({ where: { deletionRequestedAt: null } });
      ok = dash.body.users.total === stats.body.users.total && dash.body.users.total === expected;
    }
    assert.ok(ok, "dashboard total must equal non-deleting users");
  });

  await check("cancel deletion writes appUser.cancelDeletion", async () => {
    const res = await api(`/api/admin/users/app-users/${viewer.id}/restore`, {
      method: "POST",
      token: adminToken,
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const row = await latestAudit("appUser.cancelDeletion", viewer.id);
    assert.ok(row);
    assert.equal(row!.targetType, "User");
  });

  await check("hazard category edit writes hazardCategory.update with before/after", async () => {
    const original = category!.description;
    const res = await api(`/api/admin/categories/${category!.id}`, {
      method: "PUT",
      token: adminToken,
      body: { description: `ModPriv edit ${suffix}` },
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const row = await latestAudit("hazardCategory.update", category!.id);
    assert.ok(row);
    assert.equal(row!.targetType, "HazardCategory");
    assert.equal((row!.before as any).description, original);
    assert.equal((row!.after as any).description, `ModPriv edit ${suffix}`);
    await prisma.hazardCategory.update({
      where: { id: category!.id },
      data: { description: original },
    });
  });

  await check("hazard sync writes hazard.sync (no external source fetched)", async () => {
    const before = new Date();
    const res = await api("/api/admin/hazards/sync-external", {
      method: "POST",
      token: adminToken,
      body: { sourceIds: [`modpriv-none-${suffix}`] },
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const row = await prisma.adminAuditLog.findFirst({
      where: { action: "hazard.sync", createdAt: { gte: before } },
      orderBy: { createdAt: "desc" },
    });
    assert.ok(row);
    assert.deepEqual((row!.after as any).sourceIds, [`modpriv-none-${suffix}`]);
    assert.equal((row!.after as any).createdCount, 0);
  });

  await check("admin hazard delete writes hazard.delete with a before snapshot", async () => {
    const res = await api(`/api/admin/hazards/${hazard.id}`, {
      method: "DELETE",
      token: adminToken,
    });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    const row = await latestAudit("hazard.delete", hazard.id);
    assert.ok(row);
    assert.equal(row!.targetType, "Hazard");
    assert.equal((row!.before as any).title, title);
  });

  console.log("\n§15 Dashboard day boundary");

  await check("dashboard 'today' starts at Australia/Brisbane midnight", async () => {
    const res = await api("/api/admin/stats/dashboard", { token: adminToken });
    assert.equal(res.status, 200);
    const now = Date.now();
    const offset = 10 * 60 * 60 * 1000;
    const shifted = new Date(now + offset);
    shifted.setUTCHours(0, 0, 0, 0);
    const expected = new Date(shifted.getTime() - offset).toISOString();
    assert.equal(res.body.dayBoundary?.timezone, "Australia/Brisbane");
    assert.equal(res.body.dayBoundary?.dayStartedAt, expected);
    const stats = await api("/api/admin/stats", { token: adminToken });
    assert.equal(stats.body.dayBoundary.dayStartedAt, expected);
  });

  // Cleanup (best effort).
  await prisma.user.deleteMany({ where: { id: { in: [reporter.id, viewer.id] } } }).catch(() => {});
  await prisma.admin
    .deleteMany({ where: { email: { in: [adminEmail, moderatorEmail] } } })
    .catch(() => {});

  console.log(`\n${passed} checks passed`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());

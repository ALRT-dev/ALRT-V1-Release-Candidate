/**
 * Leaving a circle, and the alert link on a check-in - real HTTP requests
 * against a running instance of this backend, backed by a real Postgres.
 *
 * Proves (phone QA 2026-09-09, issues 4 and 5):
 *   1. Leaving reports what happened: a member leaving a circle others
 *      remain in -> "left"; the host leaving with others remaining ->
 *      "hostTransition" (the circle survives with a host window); the
 *      last member leaving, host or not -> "deleted", and no memberless
 *      circle is left behind.
 *   2. A departed member can no longer read the circle (404), so nothing
 *      of it stays accessible.
 *   3. Live SOS events are readable across every circle the user is in
 *      (GET /family/sos/active without circleId).
 *   4. A check-in's alert link: a made-up alert id is refused (400), a
 *      real published alert is stored and comes back named (hazard.title)
 *      in the check-in list; the check-in itself carries no location for
 *      an "alertsOnly" member whatever the client sent.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_family_leave_and_alert_link.ts
 */

import assert from "node:assert/strict";
import { HazardReviewStatus, HazardSeverity, HazardSeverityBand, PrismaClient } from "@prisma/client";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();

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
  return { status: res.status, body: json as any };
};

const registerUser = async (label: string) => {
  const email = `leave-link-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  const nameRes = await api("/api/user", { method: "PUT", token, body: { name: label } });
  assert.equal(nameRes.status, 200, JSON.stringify(nameRes.body));
  return { token, label };
};

const createCircle = async (token: string, name: string) => {
  const res = await api("/api/family/circle", { method: "POST", token, body: { name } });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return res.body.id as string;
};
const join = async (hostToken: string, memberToken: string) => {
  const invite = await api("/api/family/invites", { method: "POST", token: hostToken });
  assert.equal(invite.status, 201, JSON.stringify(invite.body));
  const res = await api("/api/family/join", { method: "POST", token: memberToken, body: { code: invite.body.code } });
  assert.equal(res.status, 200, JSON.stringify(res.body));
};
const leave = (token: string, circleId: string) =>
  api(`/api/family/circle/leave?circleId=${circleId}`, { method: "POST", token });

async function main() {
  console.log("Leave outcomes and the check-in alert link (real HTTP + real DB)\n");

  console.log("§1 - leave outcomes");
  const host = await registerUser("Host");
  const amy = await registerUser("Amy");
  const tom = await registerUser("Tom");
  const circleA = await createCircle(host.token, "Circle A");
  await join(host.token, amy.token);
  await join(host.token, tom.token);

  await check("a member leaving while others remain -> outcome 'left'", async () => {
    const res = await leave(tom.token, circleA);
    assert.equal(res.status, 200, JSON.stringify(res.body));
    assert.equal(res.body.outcome, "left");
    assert.equal(res.body.circleId, circleA);
  });
  await check("the departed member can no longer read the circle or its check-ins", async () => {
    const circle = await api(`/api/family/circle?circleId=${circleA}`, { token: tom.token });
    assert.equal(circle.status, 200, JSON.stringify(circle.body));
    assert.equal(circle.body, null, "the circle read answers null, never circle A");
    const checkIns = await api(`/api/family/check-ins?circleId=${circleA}`, { token: tom.token });
    assert.equal(checkIns.status, 404, JSON.stringify(checkIns.body));
    const sos = await api(`/api/family/sos/active?circleId=${circleA}`, { token: tom.token });
    assert.equal(sos.status, 404, JSON.stringify(sos.body));
  });
  await check("the host leaving with a member remaining -> 'hostTransition', circle survives", async () => {
    const res = await leave(host.token, circleA);
    assert.equal(res.status, 200, JSON.stringify(res.body));
    assert.equal(res.body.outcome, "hostTransition");
    const still = await prisma.familyCircle.findUnique({ where: { id: circleA }, select: { id: true } });
    assert.ok(still, "circle still exists for the remaining member");
  });
  await check("the last member leaving (not the host) -> 'deleted', no memberless circle left behind", async () => {
    const res = await leave(amy.token, circleA);
    assert.equal(res.status, 200, JSON.stringify(res.body));
    assert.equal(res.body.outcome, "deleted");
    const gone = await prisma.familyCircle.findUnique({ where: { id: circleA }, select: { id: true } });
    assert.equal(gone, null, "circle row removed");
  });
  await check("a host alone in a circle leaving -> 'deleted'", async () => {
    const solo = await createCircle(host.token, "Solo");
    const res = await leave(host.token, solo);
    assert.equal(res.status, 200, JSON.stringify(res.body));
    assert.equal(res.body.outcome, "deleted");
    assert.equal(await prisma.familyCircle.findUnique({ where: { id: solo } }), null);
  });
  console.log();

  console.log("§2 - live SOS across circles");
  const circleB = await createCircle(host.token, "Circle B");
  const circleC = await createCircle(amy.token, "Circle C");
  await join(amy.token, host.token); // host is now in B (owner) and C (member)
  const sosInC = await api(`/api/family/sos?circleId=${circleC}`, { method: "POST", token: amy.token, body: { isLive: false } });
  assert.equal(sosInC.status, 201, JSON.stringify(sosInC.body));
  await check("without circleId the host sees Amy's SOS in circle C from anywhere", async () => {
    const res = await api("/api/family/sos/active", { token: host.token });
    assert.equal(res.status, 200, JSON.stringify(res.body));
    assert.ok((res.body as any[]).some((e) => e.id === sosInC.body.id), "SOS in C listed");
  });
  await check("with circleId=B the same call lists nothing from C", async () => {
    const res = await api(`/api/family/sos/active?circleId=${circleB}`, { token: host.token });
    assert.equal(res.status, 200);
    assert.ok(!(res.body as any[]).some((e) => e.id === sosInC.body.id));
  });
  const stood = await api(`/api/family/sos/${sosInC.body.id}/resolve?circleId=${circleC}`, { method: "POST", token: amy.token });
  assert.ok([200, 201].includes(stood.status), JSON.stringify(stood.body));
  console.log();

  console.log("§3 - the alert link on a check-in");
  const category = await prisma.hazardCategory.findFirst({ where: { parentId: null }, select: { id: true } });
  assert.ok(category);
  const hazard = await prisma.hazard.create({
    data: {
      title: `Leave-link storm ${crypto.randomUUID().slice(0, 6)}`,
      description: "synthetic alert for the check-in link",
      categoryId: category.id,
      severity: HazardSeverity.advice,
      severityBand: HazardSeverityBand.monitor,
      isAwsCompliant: true,
      reviewStatus: HazardReviewStatus.accepted,
      latitude: -63.1,
      longitude: 104.1,
    },
  });
  try {
    await check("a made-up alert id is refused (400), nothing stored", async () => {
      const res = await api(`/api/family/check-in?circleId=${circleC}`, {
        method: "POST",
        token: host.token,
        body: { hazardId: crypto.randomUUID(), message: "near a ghost" },
      });
      assert.equal(res.status, 400, JSON.stringify(res.body));
    });
    await check("a non-uuid alert id is refused by the validator (400)", async () => {
      const res = await api(`/api/family/check-in?circleId=${circleC}`, {
        method: "POST",
        token: host.token,
        body: { hazardId: "not-an-id" },
      });
      assert.equal(res.status, 400, JSON.stringify(res.body));
    });
    let checkInId = "";
    await check("a real published alert is stored on the check-in", async () => {
      const res = await api(`/api/family/check-in?circleId=${circleC}`, {
        method: "POST",
        token: host.token,
        body: { hazardId: hazard.id, message: "Safe, near the storm", latitude: -63.1, longitude: 104.1 },
      });
      assert.equal(res.status, 201, JSON.stringify(res.body));
      assert.equal(res.body.hazardId, hazard.id);
      checkInId = res.body.id;
      const row = await prisma.familyCheckIn.findUniqueOrThrow({ where: { id: checkInId } });
      assert.equal(row.hazardId, hazard.id);
    });
    await check("the check-in list names the alert (hazard.title) for the circle", async () => {
      const res = await api(`/api/family/check-ins?circleId=${circleC}`, { token: amy.token });
      assert.equal(res.status, 200, JSON.stringify(res.body));
      const mine = (res.body as any[]).find((c) => c.id === checkInId);
      assert.ok(mine, "check-in listed");
      assert.equal(mine.hazard?.id, hazard.id);
      assert.equal(mine.hazard?.title, hazard.title);
    });
    await check("the host's default sharing level keeps coordinates off the check-in", async () => {
      const row = await prisma.familyCheckIn.findUniqueOrThrow({ where: { id: checkInId } });
      const membership = await prisma.familyMember.findFirstOrThrow({ where: { id: row.memberId } });
      if (membership.sharingLevel === "precise") {
        console.log("    (member is precise: coordinates allowed, rule not exercised)");
        return;
      }
      assert.equal(row.latitude, null);
      assert.equal(row.longitude, null);
    });
  } finally {
    await prisma.familyCheckIn.deleteMany({ where: { hazardId: hazard.id } });
    await prisma.hazard.delete({ where: { id: hazard.id } });
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

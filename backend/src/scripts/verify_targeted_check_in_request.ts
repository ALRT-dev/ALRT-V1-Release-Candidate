/**
 * Targeted check-in request verification - real HTTP requests against a
 * running instance of this backend, backed by a real local Postgres.
 *
 * Covers requestCheckIn() `memberIds` (2026-09-04): a check-in request can
 * be aimed at specific members ("Ask Amy") instead of the whole circle.
 *
 * Proves:
 *   1. The validator accepts memberIds and still strips unknown fields.
 *   2. Asking one person stores exactly that target and names who asked.
 *   3. Only the target (and the requester, as their tracker) see the ask
 *      as the circle's latestCheckInRequest; a bystander does not.
 *   4. The requester is never a target of their own ask.
 *   5. An id from outside the circle is refused (400), never widened to
 *      everyone.
 *   6. An untargeted ask still means everyone (empty targets, seen by all).
 *   7. The target can answer it with a normal check-in.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_targeted_check_in_request.ts
 */

import assert from "node:assert/strict";
import { familyCheckInRequestSchema } from "../validators/family.validator.js";

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

const registerUser = async (label: string) => {
  const uniqueSuffix = crypto.randomUUID().slice(0, 8);
  const email = `targeted-ask-${label}-${uniqueSuffix}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = (res.body as any).accessToken as string;
  const nameRes = await api("/api/user", { method: "PUT", token, body: { name: label } });
  assert.equal(nameRes.status, 200, JSON.stringify(nameRes.body));
  return { token, label };
};

const circleAs = async (token: string) => {
  const res = await api("/api/family/circle", { token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body as any;
};

async function main() {
  console.log("Targeted check-in request verification (real HTTP + real DB)\n");

  console.log("§1 - validator");
  await check("memberIds is accepted; unknown fields are stripped", () => {
    const parsed = familyCheckInRequestSchema.safeParse({
      memberIds: ["m1", "m2"],
      message: "hi",
      latitude: -27.4,
    });
    assert.ok(parsed.success, JSON.stringify(parsed));
    assert.deepEqual((parsed.data as any).memberIds, ["m1", "m2"]);
    assert.ok(!("latitude" in (parsed.data as object)));
  });
  console.log();

  console.log("setup - host Sarah, members Amy and Tom in one circle");
  const sarah = await registerUser("Sarah");
  const amy = await registerUser("Amy");
  const tom = await registerUser("Tom");
  const created = await api("/api/family/circle", {
    method: "POST",
    token: sarah.token,
    body: { name: "Nixon Family" },
  });
  assert.equal(created.status, 201, JSON.stringify(created.body));
  for (const member of [amy, tom]) {
    const invite = await api("/api/family/invites", { method: "POST", token: sarah.token });
    assert.equal(invite.status, 201, JSON.stringify(invite.body));
    const join = await api("/api/family/join", {
      method: "POST",
      token: member.token,
      body: { code: (invite.body as any).code },
    });
    assert.equal(join.status, 200, JSON.stringify(join.body));
  }
  const sarahMemberId = (await circleAs(sarah.token)).myMemberId as string;
  const amyMemberId = (await circleAs(amy.token)).myMemberId as string;
  const tomMemberId = (await circleAs(tom.token)).myMemberId as string;
  console.log("  setup - done\n");

  console.log("§2 - Sarah asks Amy only");
  const askAmy = await api("/api/family/check-in/request", {
    method: "POST",
    token: sarah.token,
    body: { memberIds: [amyMemberId], message: "Storm near you, all OK?" },
  });
  await check("201 with exactly Amy as the target, and who asked by name", () => {
    assert.equal(askAmy.status, 201, JSON.stringify(askAmy.body));
    const body = askAmy.body as any;
    assert.deepEqual(body.targetMemberIds, [amyMemberId]);
    assert.equal(body.requestedById, sarahMemberId);
    assert.equal(body.requestedBy?.user?.name, "Sarah");
    assert.equal(body.message, "Storm near you, all OK?");
  });
  console.log();

  console.log("§3 - who sees it as the latest ask");
  await check("Amy (target) sees it as latestCheckInRequest", async () => {
    const c = await circleAs(amy.token);
    assert.equal(c.latestCheckInRequest?.id, (askAmy.body as any).id);
    assert.equal(c.latestCheckInRequest?.requestedBy?.user?.name, "Sarah");
  });
  await check("Sarah (requester) sees it too - it is her tracker", async () => {
    const c = await circleAs(sarah.token);
    assert.equal(c.latestCheckInRequest?.id, (askAmy.body as any).id);
  });
  await check("Tom (not asked) does NOT see it", async () => {
    const c = await circleAs(tom.token);
    assert.notEqual(c.latestCheckInRequest?.id, (askAmy.body as any).id);
  });
  console.log();

  console.log("§4 - the requester is never a target of their own ask");
  const askSelfAndTom = await api("/api/family/check-in/request", {
    method: "POST",
    token: sarah.token,
    body: { memberIds: [sarahMemberId, tomMemberId, tomMemberId] },
  });
  await check("own id and duplicates are dropped; Tom alone remains", () => {
    assert.equal(askSelfAndTom.status, 201, JSON.stringify(askSelfAndTom.body));
    assert.deepEqual((askSelfAndTom.body as any).targetMemberIds, [tomMemberId]);
  });
  console.log();

  console.log("§5 - an id from outside the circle is refused, never widened");
  const outsider = await registerUser("Outsider");
  const outsiderCircle = await api("/api/family/circle", {
    method: "POST",
    token: outsider.token,
    body: { name: "Elsewhere" },
  });
  assert.equal(outsiderCircle.status, 201);
  const outsiderMemberId = (await circleAs(outsider.token)).myMemberId as string;
  await check("400 for a member of another circle", async () => {
    const res = await api("/api/family/check-in/request", {
      method: "POST",
      token: sarah.token,
      body: { memberIds: [outsiderMemberId] },
    });
    assert.equal(res.status, 400, JSON.stringify(res.body));
  });
  await check("400 when the only id given is the requester's own", async () => {
    const res = await api("/api/family/check-in/request", {
      method: "POST",
      token: sarah.token,
      body: { memberIds: [sarahMemberId] },
    });
    assert.equal(res.status, 400, JSON.stringify(res.body));
  });
  console.log();

  console.log("§6 - an untargeted ask still means everyone");
  const askAll = await api("/api/family/check-in/request", {
    method: "POST",
    token: sarah.token,
    body: { message: "Everyone please check in" },
  });
  await check("empty targets, and Amy and Tom both see it", async () => {
    assert.equal(askAll.status, 201, JSON.stringify(askAll.body));
    assert.deepEqual((askAll.body as any).targetMemberIds, []);
    for (const t of [amy.token, tom.token]) {
      const c = await circleAs(t);
      assert.equal(c.latestCheckInRequest?.id, (askAll.body as any).id);
    }
  });
  console.log();

  console.log("§7 - a target answers with a normal check-in");
  await check("Amy checks in against the targeted ask, no location", async () => {
    const res = await api("/api/family/check-in", {
      method: "POST",
      token: amy.token,
      body: { status: "safe", requestId: (askAmy.body as any).id },
    });
    assert.equal(res.status, 201, JSON.stringify(res.body));
    assert.equal((res.body as any).requestId, (askAmy.body as any).id);
    assert.equal((res.body as any).latitude ?? null, null);
  });

  console.log(`\n${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exitCode = 1;
});

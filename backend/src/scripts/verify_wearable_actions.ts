/**
 * Apple Watch actions verification - real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres.
 *
 * Covers the backend half of the ALRT Apple Watch companion (2026-10-07):
 *
 *   1. apnsCategoryFor(): with WEARABLE_ACTIONABLE_PUSH off (the default)
 *      no push type gets an APNs category, so every push is unchanged;
 *      with it on, only familyCheckInRequest and familySos do.
 *   2. clientRequestId on POST /family/check-in: the same tap sent twice
 *      (watch + phone, or a retry after a lost answer) is ONE check-in -
 *      same id back, one row stored.
 *   3. Without clientRequestId (every existing app build) nothing changes:
 *      two posts are two check-ins.
 *   4. A check-in only answers an ask from its own circle: another
 *      circle's request id is not linked; its own circle's still is.
 *   5. clientRequestId on POST /family/sos: the same hold sent twice is
 *      ONE SOS - same id, still active, not cancelled and replaced.
 *   6. A malformed clientRequestId is refused (400), never stored.
 *
 * Run with (server started with the same .env.test):
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_wearable_actions.ts
 */

import assert from "node:assert/strict";
import { apnsCategoryFor } from "../services/notification.service.js";
import { PushNotificationType } from "../models/push_notification_types.js";

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
  return { status: res.status, body: json as any };
};

const registerUser = async (label: string) => {
  const email = `wearable-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
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

const myCheckIns = async (token: string, circleId: string) => {
  const res = await api(`/api/family/check-ins?limit=50&circleId=${circleId}`, { token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body as any[];
};

async function main() {
  console.log("Apple Watch actions verification (real HTTP + real DB)\n");

  console.log("§1 - APNs category is opt-in and limited to two push types");
  await check("flag off: no push type carries a category", () => {
    for (const type of Object.values(PushNotificationType)) {
      assert.equal(apnsCategoryFor(type as PushNotificationType, false), undefined, type);
    }
  });
  await check("flag on: check-in request and SOS only", () => {
    assert.equal(
      apnsCategoryFor(PushNotificationType.familyCheckInRequest, true),
      "ALRT_CHECKIN_REQUEST",
    );
    assert.equal(apnsCategoryFor(PushNotificationType.familySos, true), "ALRT_SOS_RECEIVED");
    const others = Object.values(PushNotificationType).filter(
      (t) => t !== PushNotificationType.familyCheckInRequest && t !== PushNotificationType.familySos,
    );
    for (const type of others) {
      assert.equal(apnsCategoryFor(type as PushNotificationType, true), undefined, type);
    }
  });
  console.log();

  console.log("setup - Sarah hosts Home, Amy joins; Outsider has a separate circle");
  const sarah = await registerUser("Sarah");
  const amy = await registerUser("Amy");
  const created = await api("/api/family/circle", {
    method: "POST",
    token: sarah.token,
    body: { name: "Home" },
  });
  assert.equal(created.status, 201, JSON.stringify(created.body));
  const homeId = created.body.id as string;
  const invite = await api("/api/family/invites", { method: "POST", token: sarah.token });
  assert.equal(invite.status, 201, JSON.stringify(invite.body));
  const join = await api("/api/family/join", {
    method: "POST",
    token: amy.token,
    body: { code: invite.body.code },
  });
  assert.equal(join.status, 200, JSON.stringify(join.body));
  console.log("  setup - done\n");

  console.log("§2 - the same watch tap twice is one check-in");
  const tapKey = crypto.randomUUID();
  const first = await api(`/api/family/check-in?circleId=${homeId}`, {
    method: "POST",
    token: amy.token,
    body: { clientRequestId: tapKey },
  });
  const second = await api(`/api/family/check-in?circleId=${homeId}`, {
    method: "POST",
    token: amy.token,
    body: { clientRequestId: tapKey },
  });
  await check("both answers succeed with the same check-in id", () => {
    assert.equal(first.status, 201, JSON.stringify(first.body));
    assert.equal(second.status, 201, JSON.stringify(second.body));
    assert.equal(second.body.id, first.body.id);
  });
  await check("exactly one row is stored for that tap", async () => {
    const rows = (await myCheckIns(amy.token, homeId)).filter((c) => c.id === first.body.id);
    assert.equal(rows.length, 1);
    const all = await myCheckIns(amy.token, homeId);
    assert.equal(all.filter((c) => c.memberId === first.body.memberId).length, 1);
  });
  await check("two racing copies of a new tap still store one row", async () => {
    const raceKey = crypto.randomUUID();
    const [a, b] = await Promise.all(
      [0, 1].map(() =>
        api(`/api/family/check-in?circleId=${homeId}`, {
          method: "POST",
          token: amy.token,
          body: { clientRequestId: raceKey },
        }),
      ),
    );
    assert.equal(a.status, 201, JSON.stringify(a.body));
    assert.equal(b.status, 201, JSON.stringify(b.body));
    assert.equal(a.body.id, b.body.id);
  });
  console.log();

  console.log("§3 - existing apps (no key) are unchanged");
  await check("two posts without a key are two check-ins", async () => {
    const before = (await myCheckIns(amy.token, homeId)).length;
    const p1 = await api(`/api/family/check-in?circleId=${homeId}`, { method: "POST", token: amy.token, body: {} });
    const p2 = await api(`/api/family/check-in?circleId=${homeId}`, { method: "POST", token: amy.token, body: {} });
    assert.equal(p1.status, 201);
    assert.equal(p2.status, 201);
    assert.notEqual(p1.body.id, p2.body.id);
    assert.equal((await myCheckIns(amy.token, homeId)).length, before + 2);
  });
  console.log();

  console.log("§4 - a check-in answers only an ask from its own circle");
  const outsider = await registerUser("Outsider");
  const elsewhere = await api("/api/family/circle", {
    method: "POST",
    token: outsider.token,
    body: { name: "Elsewhere" },
  });
  assert.equal(elsewhere.status, 201, JSON.stringify(elsewhere.body));
  const foreignAsk = await api(`/api/family/check-in/request?circleId=${elsewhere.body.id}`, {
    method: "POST",
    token: outsider.token,
    body: {},
  });
  assert.equal(foreignAsk.status, 201, JSON.stringify(foreignAsk.body));
  await check("another circle's request id is not linked; the check-in stands", async () => {
    const res = await api(`/api/family/check-in?circleId=${homeId}`, {
      method: "POST",
      token: amy.token,
      body: { requestId: foreignAsk.body.id, clientRequestId: crypto.randomUUID() },
    });
    assert.equal(res.status, 201, JSON.stringify(res.body));
    assert.equal(res.body.requestId ?? null, null);
  });
  const homeAsk = await api(`/api/family/check-in/request?circleId=${homeId}`, {
    method: "POST",
    token: sarah.token,
    body: {},
  });
  assert.equal(homeAsk.status, 201, JSON.stringify(homeAsk.body));
  await check("its own circle's request id is still linked", async () => {
    const res = await api(`/api/family/check-in?circleId=${homeId}`, {
      method: "POST",
      token: amy.token,
      body: { requestId: homeAsk.body.id, clientRequestId: crypto.randomUUID() },
    });
    assert.equal(res.status, 201, JSON.stringify(res.body));
    assert.equal(res.body.requestId, homeAsk.body.id);
  });
  console.log();

  console.log("§5 - the same SOS hold twice is one SOS");
  const holdKey = crypto.randomUUID();
  const sosBody = { isLive: false, locationMode: "none", clientRequestId: holdKey };
  const sos1 = await api(`/api/family/sos?circleId=${homeId}`, {
    method: "POST",
    token: amy.token,
    body: sosBody,
  });
  const sos2 = await api(`/api/family/sos?circleId=${homeId}`, {
    method: "POST",
    token: amy.token,
    body: sosBody,
  });
  await check("both answers return the same SOS", () => {
    assert.equal(sos1.status, 201, JSON.stringify(sos1.body));
    assert.equal(sos2.status, 201, JSON.stringify(sos2.body));
    assert.equal(sos2.body.id, sos1.body.id);
  });
  await check("that SOS is still the active one (not cancelled and replaced)", async () => {
    const active = await api("/api/family/sos/active", { token: sarah.token });
    assert.equal(active.status, 200, JSON.stringify(active.body));
    const list = (Array.isArray(active.body) ? active.body : active.body.events ?? []) as any[];
    const amys = list.filter((e) => e.memberId === sos1.body.memberId);
    assert.equal(amys.length, 1, JSON.stringify(list));
    assert.equal(amys[0].id, sos1.body.id);
    assert.equal(amys[0].status, "active");
  });
  await api(`/api/family/sos/${sos1.body.id}/resolve`, { method: "POST", token: amy.token, body: {} });
  console.log();

  console.log("§6 - a malformed key is refused");
  await check("non-UUID clientRequestId on check-in is 400", async () => {
    const res = await api(`/api/family/check-in?circleId=${homeId}`, {
      method: "POST",
      token: amy.token,
      body: { clientRequestId: "not-a-uuid" },
    });
    assert.equal(res.status, 400, JSON.stringify(res.body));
  });
  await check("non-UUID clientRequestId on SOS is 400", async () => {
    const res = await api(`/api/family/sos?circleId=${homeId}`, {
      method: "POST",
      token: amy.token,
      body: { isLive: false, locationMode: "none", clientRequestId: "x" },
    });
    assert.equal(res.status, 400, JSON.stringify(res.body));
  });
  console.log();

  console.log(`All ${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exit(1);
});

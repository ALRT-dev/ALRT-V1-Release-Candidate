/**
 * V1 subscription changes, upgrades, Restore reconciliation and coded
 * refusals. Real HTTP against a locally running backend (BILLING_ENABLED
 * =true) with simulated, authenticated RevenueCat webhooks, plus a FAKE
 * RevenueCat server API this script serves itself. Backend behaviour only:
 * NOT store-sandbox or device evidence. The event sequences the real stores
 * send for each change must still be confirmed in sandbox.
 *
 * Server env: as verify_v1_access_model.ts, plus
 *   REVENUECAT_SECRET_API_KEY=local-rc-api
 *   REVENUECAT_API_BASE=http://127.0.0.1:55460
 * Run:
 *   TEST_SERVER_URL=http://localhost:55450 npx tsx src/scripts/verify_v1_subscription_changes.ts
 */

import http from "node:http";
import assert from "node:assert/strict";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const RC_AUTH = process.env.RC_TEST_AUTH || "Bearer local-rc-test";

let passed = 0;
const failures: string[] = [];
const check = async (label: string, fn: () => Promise<void>) => {
  try {
    await fn();
    passed += 1;
    console.log(`  ok - ${label}`);
  } catch (error) {
    failures.push(label);
    console.log(`  FAIL - ${label}\n      ${(error as Error).message}`);
  }
};

const api = async (
  path: string,
  opts: { method?: string; token?: string; body?: unknown; auth?: string } = {},
) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: opts.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}),
      ...(opts.auth ? { Authorization: opts.auth } : {}),
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

interface TestUser {
  token: string;
  id: string;
  name: string;
}

const register = async (name: string): Promise<TestUser> => {
  const email = `v1access-${name}-${crypto.randomUUID().slice(0, 8)}@localtest.invalid`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "LocalTest!2345Xx" },
  });
  assert.equal(res.status, 201, `register ${name}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  await api("/api/user", { method: "PUT", token, body: { name } });
  const me = await api("/api/user", { token });
  const id = (me.body?.id ?? me.body?.user?.id) as string;
  assert.ok(id, `no id for ${name}: ${JSON.stringify(me.body)}`);
  return { token, id, name };
};

let clock = Date.now();
const DAY = 24 * 60 * 60 * 1000;

/** Sends one authenticated RevenueCat event. */
const rc = async (event: Record<string, unknown>) => {
  clock += 1000;
  return api("/api/revenuecat/webhook", {
    method: "POST",
    auth: RC_AUTH,
    body: {
      event: {
        id: crypto.randomUUID(),
        environment: "SANDBOX",
        store: "APP_STORE",
        event_timestamp_ms: clock,
        period_type: "NORMAL",
        ...event,
      },
    },
  });
};

const buy = async (
  user: TestUser,
  tier: "individual" | "family" | "group20" | "group50",
  extra: Record<string, unknown> = {},
) => {
  const tx = `tx-${crypto.randomUUID()}`;
  const res = await rc({
    type: "INITIAL_PURCHASE",
    app_user_id: user.id,
    product_id: `test.${tier}.monthly`,
    original_transaction_id: tx,
    expiration_at_ms: Date.now() + 30 * DAY,
    ...extra,
  });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  assert.equal(res.body.action, "applied", JSON.stringify(res.body));
  return tx;
};

const createGroup = async (user: TestUser, name: string) => {
  const res = await api("/api/family/circle", {
    method: "POST",
    token: user.token,
    body: { name },
  });
  assert.equal(res.status, 201, `create ${name}: ${JSON.stringify(res.body)}`);
  return res.body.id as string;
};

const inviteCode = async (host: TestUser, circleId: string) => {
  const res = await api(`/api/family/invites?circleId=${circleId}`, {
    method: "POST",
    token: host.token,
    body: {},
  });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return res.body.code as string;
};

const join = (user: TestUser, code: string) =>
  api("/api/family/join", { method: "POST", token: user.token, body: { code } });

const joinOk = async (user: TestUser, code: string) => {
  const res = await join(user, code);
  assert.ok(res.status === 200 || res.status === 201, `join: ${res.status} ${JSON.stringify(res.body)}`);
};

const checkIn = (user: TestUser, circleId: string) =>
  api(`/api/family/check-in?circleId=${circleId}`, {
    method: "POST",
    token: user.token,
    body: {},
  });

const sos = (user: TestUser, circleId: string, body: Record<string, unknown> = {}) =>
  api(`/api/family/sos?circleId=${circleId}`, {
    method: "POST",
    token: user.token,
    body: { isLive: false, ...body },
  });

const savePlace = (user: TestUser, n: number) =>
  api("/api/user/subscribe-location", {
    method: "POST",
    token: user.token,
    body: {
      northeastLat: -27.4 + n * 0.01,
      northeastLng: 153.1,
      southwestLat: -27.5 + n * 0.01,
      southwestLng: 153.0,
      name: `Place ${n}`,
    },
  });

const access = async (user: TestUser) => {
  const res = await api("/api/access", { token: user.token });
  assert.equal(res.status, 200, JSON.stringify(res.body));
  return res.body;
};

const bindViaIntent = async (payer: TestUser, circleId: string, tier: "family" | "group20" | "group50") => {
  const intent = await api("/api/access/sponsorship-intents", {
    method: "POST",
    token: payer.token,
    body: { circleId, tier },
  });
  assert.equal(intent.status, 201, JSON.stringify(intent.body));
  return buy(payer, tier);
};

// ---- Fake RevenueCat server API (GET /v1/subscribers/:id) ----------------
const RC_API_PORT = Number(process.env.RC_API_PORT || 55460);
const storeRecords = new Map<string, Record<string, unknown>>();
let storeApiFails = false;
const fakeApi = http.createServer((req, res) => {
  const match = req.url?.match(/^\/v1\/subscribers\/([^/?]+)/);
  if (req.headers.authorization !== "Bearer local-rc-api" || !match) {
    res.writeHead(401).end();
    return;
  }
  if (storeApiFails) {
    res.writeHead(500).end();
    return;
  }
  const id = decodeURIComponent(match[1]!);
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ subscriber: { subscriptions: storeRecords.get(id) ?? {} } }));
});

const storeHas = (user: TestUser, product: string, startedMsAgo = 1000) => {
  const now = Date.now();
  storeRecords.set(user.id, {
    ...(storeRecords.get(user.id) ?? {}),
    [product]: {
      purchase_date: new Date(now - startedMsAgo).toISOString(),
      expires_date: new Date(now + 30 * DAY).toISOString(),
      is_sandbox: true,
    },
  });
};

const group = async (user: TestUser, circleId: string) =>
  (await access(user)).groups.find((x: any) => x.circleId === circleId);

const intent = (user: TestUser, circleId: string, tier: string) =>
  api("/api/access/sponsorship-intents", {
    method: "POST",
    token: user.token,
    body: { circleId, tier },
  });

const fill = async (host: TestUser, circleId: string, n: number) => {
  for (let i = 0; i < n; i += 1) {
    await joinOk(await register(`M${i}`), await inviteCode(host, circleId));
  }
};

const main = async () => {
  await new Promise<void>((r) => fakeApi.listen(RC_API_PORT, "127.0.0.1", () => r()));
  console.log("V1 subscription changes (local backend, simulated store)");

  await check("scheduled downgrade: tier and capacity stay until the store renews on the new product", async () => {
    const p = await register("Down");
    const g = await createGroup(p, "Down team");
    const tx = await bindViaIntent(p, g, "group20");
    await fill(p, g, 7); // 8 people
    await rc({ type: "PRODUCT_CHANGE", app_user_id: p.id, product_id: "test.group20.monthly", new_product_id: "test.family.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() + 30 * DAY });
    let grp = await group(p, g);
    assert.equal(grp.sponsorship.tier, "group20");
    assert.equal(grp.capacity, 20);
    assert.equal(grp.sponsorship.pendingTier, "family");
    // Still Group 20 before renewal: a 9th person can join.
    await joinOk(await register("Ninth"), await inviteCode(p, g));
    await rc({ type: "RENEWAL", app_user_id: p.id, product_id: "test.family.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() + 60 * DAY });
    grp = await group(p, g);
    assert.equal(grp.sponsorship.tier, "family");
    assert.equal(grp.capacity, 6);
    assert.equal(grp.sponsorship.pendingTier, null);
    assert.equal(grp.peopleCount, 9, "nobody removed");
    const j = await join(await register("Tenth"), await inviteCode(p, g));
    assert.equal(j.status, 409);
    assert.equal(j.body.code, "GROUP_FULL");
    assert.equal(j.body.details.capacity, 6);
  });

  await check("a withdrawn change clears the pending tier", async () => {
    const p = await register("Undo");
    const g = await createGroup(p, "Undo team");
    const tx = await bindViaIntent(p, g, "group20");
    await rc({ type: "PRODUCT_CHANGE", app_user_id: p.id, product_id: "test.group20.monthly", new_product_id: "test.family.monthly", original_transaction_id: tx });
    assert.equal((await group(p, g)).sponsorship.pendingTier, "family");
    await rc({ type: "PRODUCT_CHANGE", app_user_id: p.id, product_id: "test.group20.monthly", new_product_id: "test.group20.monthly", original_transaction_id: tx });
    const grp = await group(p, g);
    assert.equal(grp.sponsorship.pendingTier, null);
    assert.equal(grp.sponsorship.tier, "group20");
  });

  await check("upgrade intents: payer only, bigger tier only, names the product it replaces", async () => {
    const p = await register("Up");
    const other = await register("Other");
    const g = await createGroup(p, "Up team");
    await bindViaIntent(p, g, "family");
    await joinOk(other, await inviteCode(p, g));
    let r = await intent(other, g, "group20");
    assert.equal(r.status, 409);
    assert.equal(r.body.code, "GROUP_ALREADY_COVERED");
    r = await intent(p, g, "family");
    assert.equal(r.body.code, "GROUP_ALREADY_COVERED");
    r = await intent(p, g, "group20");
    assert.equal(r.status, 201, JSON.stringify(r.body));
    assert.equal(r.body.replaces.tier, "family");
    assert.equal(r.body.replaces.productId, "test.family.monthly");
    const pay = (await group(p, g)).sponsorship;
    assert.equal(pay.productId, "test.family.monthly", "payer sees their product");
    const seen = (await group(other, g)).sponsorship;
    assert.equal(seen.productId, undefined, "members never see the payer's product");
    const g50 = await createGroup(p, "Big");
    await bindViaIntent(p, g50, "group50");
    r = await intent(p, g50, "group20");
    assert.equal(r.status, 409);
    assert.equal(r.body.code, "CHANGE_IN_STORE");
  });

  await check("Google replacement: Family -> Group 20 as a new transaction keeps the group and Individual", async () => {
    const p = await register("Android");
    await buy(p, "individual");
    const g = await createGroup(p, "Android team");
    const oldTx = await bindViaIntent(p, g, "family");
    await fill(p, g, 5); // 6 people: full on Family
    assert.equal((await intent(p, g, "group20")).status, 201);
    const newTx = `gpa-${crypto.randomUUID()}`;
    const res = await rc({ type: "INITIAL_PURCHASE", store: "PLAY_STORE", app_user_id: p.id, product_id: "test.group20.monthly:monthly", original_transaction_id: newTx, expiration_at_ms: Date.now() + 30 * DAY });
    assert.equal(res.body.action, "applied");
    let a = await access(p);
    let grp = a.groups.find((x: any) => x.circleId === g);
    assert.equal(grp.sponsorship.tier, "group20");
    assert.equal(grp.capacity, 20);
    assert.equal(a.unboundSponsorships.length, 0, "no stray unbound plan");
    assert.equal(a.personal.plan, "individual", "Individual untouched");
    await joinOk(await register("Seventh"), await inviteCode(p, g));
    // The replaced purchase ends; the group stays covered by Group 20.
    await rc({ type: "EXPIRATION", store: "PLAY_STORE", app_user_id: p.id, product_id: "test.family.monthly", original_transaction_id: oldTx, expiration_at_ms: Date.now() - 1000 });
    a = await access(p);
    grp = a.groups.find((x: any) => x.circleId === g);
    assert.equal(grp.sponsorship.tier, "group20");
    assert.equal(grp.sponsorship.live, true);
    assert.equal(a.personal.plan, "individual");
    // Then Group 20 -> Group 50 the same way.
    assert.equal((await intent(p, g, "group50")).status, 201);
    await rc({ type: "INITIAL_PURCHASE", store: "PLAY_STORE", app_user_id: p.id, product_id: "test.group50.monthly", original_transaction_id: `gpa-${crypto.randomUUID()}`, expiration_at_ms: Date.now() + 30 * DAY });
    grp = await group(p, g);
    assert.equal(grp.sponsorship.tier, "group50");
    assert.equal(grp.capacity, 50);
  });

  await check("App Store upgrade on the same transaction: pending until the store record shows it in effect", async () => {
    const p = await register("Apple");
    const g = await createGroup(p, "Apple team");
    const tx = await bindViaIntent(p, g, "group20");
    assert.equal((await intent(p, g, "group50")).status, 201);
    storeHas(p, "test.group20.monthly", 5 * DAY);
    await rc({ type: "PRODUCT_CHANGE", app_user_id: p.id, product_id: "test.group20.monthly", new_product_id: "test.group50.monthly", original_transaction_id: tx });
    let grp = await group(p, g);
    assert.equal(grp.sponsorship.tier, "group20", "store record does not show Group 50 yet");
    assert.equal(grp.sponsorship.pendingTier, "group50");
    storeHas(p, "test.group50.monthly");
    const r = await api("/api/access/reconcile", { method: "POST", token: p.token });
    assert.equal(r.status, 200, JSON.stringify(r.body));
    assert.equal(r.body.store.checked, true);
    assert.equal(r.body.store.confirmedChanges, 1);
    grp = r.body.access.groups.find((x: any) => x.circleId === g);
    assert.equal(grp.sponsorship.tier, "group50");
    assert.equal(grp.capacity, 50);
    assert.equal(grp.sponsorship.pendingTier, null);
  });

  await check("an old purchase of the new product never counts as the change", async () => {
    const p = await register("Stale");
    const g = await createGroup(p, "Stale team");
    const tx = await bindViaIntent(p, g, "family");
    storeHas(p, "test.group20.monthly", 40 * DAY); // bought long before
    await rc({ type: "PRODUCT_CHANGE", app_user_id: p.id, product_id: "test.family.monthly", new_product_id: "test.group20.monthly", original_transaction_id: tx });
    const grp = await group(p, g);
    assert.equal(grp.sponsorship.tier, "family");
    assert.equal(grp.sponsorship.pendingTier, "group20");
  });

  await check("ambiguous replacement is never guessed: stays unbound for the payer to apply", async () => {
    const p = await register("Two");
    const g1 = await createGroup(p, "One");
    const g2 = await createGroup(p, "Two");
    await bindViaIntent(p, g1, "family");
    await bindViaIntent(p, g2, "family");
    assert.equal((await intent(p, g1, "group20")).status, 201);
    assert.equal((await intent(p, g2, "group20")).status, 201);
    await rc({ type: "INITIAL_PURCHASE", store: "PLAY_STORE", app_user_id: p.id, product_id: "test.group20.monthly", original_transaction_id: `gpa-${crypto.randomUUID()}`, expiration_at_ms: Date.now() + 30 * DAY });
    const a = await access(p);
    assert.equal(a.groups.find((x: any) => x.circleId === g1).sponsorship.tier, "family");
    assert.equal(a.groups.find((x: any) => x.circleId === g2).sponsorship.tier, "family");
    assert.equal(a.unboundSponsorships.length, 1);
  });

  await check("reconcile (Restore): reports an active store purchase ALRT has not recorded, grants nothing from it", async () => {
    const u = await register("Restore");
    storeHas(u, "test.individual.monthly");
    const r = await api("/api/access/reconcile", { method: "POST", token: u.token });
    assert.equal(r.body.store.checked, true);
    assert.deepEqual(r.body.store.unrecorded.map((x: any) => x.tier), ["individual"]);
    assert.equal(r.body.access.personal.plan, "free", "access comes only from the webhook");
    await buy(u, "individual");
    const again = await api("/api/access/reconcile", { method: "POST", token: u.token });
    assert.equal(again.body.store.unrecorded.length, 0);
    assert.equal(again.body.access.personal.plan, "individual");
  });

  await check("reconcile when the store API fails says unchecked, and changes nothing", async () => {
    const u = await register("ApiDown");
    storeApiFails = true;
    const r = await api("/api/access/reconcile", { method: "POST", token: u.token });
    storeApiFails = false;
    assert.equal(r.status, 200);
    assert.equal(r.body.store.checked, false);
    assert.equal(r.body.access.personal.plan, "free");
  });

  await check("refusals carry a code: Individual, ended plan, host only, saved places, SOS recipients", async () => {
    const host = await register("Host");
    const mem = await register("Mem");
    const g = await createGroup(host, "Plain");
    await joinOk(mem, await inviteCode(host, g));
    let r = await checkIn(mem, g);
    assert.equal(r.status, 402);
    assert.equal(r.body.code, "INDIVIDUAL_REQUIRED");
    assert.equal(r.body.details.circleId, g);

    const payer = await register("Payer");
    const m2 = await register("M2");
    const g2 = await createGroup(payer, "Covered");
    const tx = await bindViaIntent(payer, g2, "family");
    await joinOk(m2, await inviteCode(payer, g2));
    await rc({ type: "EXPIRATION", app_user_id: payer.id, product_id: "test.family.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() - 1000 });
    r = await checkIn(m2, g2);
    assert.equal(r.status, 402);
    assert.equal(r.body.code, "GROUP_PLAN_ENDED");

    r = await intent(mem, g, "family");
    assert.equal(r.status, 403);
    assert.equal(r.body.code, "HOST_ONLY");

    const free = await register("Free");
    assert.equal((await savePlace(free, 1)).status, 201);
    r = await savePlace(free, 2);
    assert.equal(r.status, 402);
    assert.equal(r.body.code, "SAVED_PLACE_LIMIT");

    const alone = await register("Alone");
    await buy(alone, "individual");
    const g3 = await createGroup(alone, "Alone");
    r = await sos(alone, g3, { latitude: -27.47, longitude: 153.02 });
    assert.equal(r.status, 422);
    assert.equal(r.body.code, "NO_SOS_RECIPIENTS");
    assert.equal(r.body.details.hasCandidates, false);
  });

  fakeApi.close();
  console.log(`\n${passed} passed, ${failures.length} failed`);
  if (failures.length) {
    console.log(failures.map((f) => `  - ${f}`).join("\n"));
    process.exit(1);
  }
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

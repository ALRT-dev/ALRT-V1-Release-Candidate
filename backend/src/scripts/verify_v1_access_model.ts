/**
 * V1 access model verification (master spec 28 Sep 2026, §20).
 *
 * Real HTTP requests against a locally running backend with
 * BILLING_ENABLED=true and a throwaway Postgres+PostGIS database. Store
 * purchases are simulated with authenticated RevenueCat webhook events,
 * which is exactly the input the backend trusts in production. This proves
 * backend behaviour only: it is NOT store-sandbox or device evidence.
 *
 * Required env for the SERVER under test:
 *   BILLING_ENABLED=true
 *   REVENUECAT_WEBHOOK_AUTH='Bearer local-rc-test'
 *   RC_PRODUCT_TIERS='test.individual.monthly:individual,test.family.monthly:family,test.group20.monthly:group20,test.group50.monthly:group50'
 *   RC_EXPECTED_ENVIRONMENT=SANDBOX
 * Run:
 *   TEST_SERVER_URL=http://localhost:55450 npx tsx src/scripts/verify_v1_access_model.ts
 */

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

const main = async () => {
  const health = await api("/api/access", {});
  assert.equal(health.status, 401, "server not reachable or /api/access not mounted");

  console.log("Webhook contract");
  const w = await register("Webhook");
  await check("unauthenticated webhook is refused", async () => {
    const res = await api("/api/revenuecat/webhook", {
      method: "POST",
      auth: "Bearer wrong",
      body: { event: { type: "INITIAL_PURCHASE", app_user_id: w.id } },
    });
    assert.equal(res.status, 401);
  });
  await check("unmapped product grants nothing", async () => {
    const res = await rc({
      type: "INITIAL_PURCHASE",
      app_user_id: w.id,
      product_id: "legacy.plus.monthly",
      original_transaction_id: `tx-${crypto.randomUUID()}`,
      expiration_at_ms: Date.now() + DAY,
    });
    assert.equal(res.body.action, "ignored");
    assert.equal((await access(w)).personal.plan, "free");
  });
  await check("wrong environment is ignored", async () => {
    const res = await rc({
      type: "INITIAL_PURCHASE",
      environment: "PRODUCTION",
      app_user_id: w.id,
      product_id: "test.individual.monthly",
      original_transaction_id: `tx-${crypto.randomUUID()}`,
      expiration_at_ms: Date.now() + DAY,
    });
    assert.equal(res.body.action, "ignored");
    assert.equal((await access(w)).personal.plan, "free");
  });
  await check("duplicate event id is applied once", async () => {
    const id = crypto.randomUUID();
    const event = {
      id,
      type: "INITIAL_PURCHASE",
      environment: "SANDBOX",
      app_user_id: w.id,
      product_id: "test.individual.monthly",
      original_transaction_id: `tx-${crypto.randomUUID()}`,
      event_timestamp_ms: (clock += 1000),
      expiration_at_ms: Date.now() + DAY,
    };
    const first = await api("/api/revenuecat/webhook", { method: "POST", auth: RC_AUTH, body: { event } });
    const second = await api("/api/revenuecat/webhook", { method: "POST", auth: RC_AUTH, body: { event } });
    assert.equal(first.body.action, "applied");
    assert.equal(second.body.action, "duplicate");
  });
  await check("out-of-order: older RENEWAL after EXPIRATION keeps it expired", async () => {
    const u = await register("OutOfOrder");
    const tx = await buy(u, "individual");
    const expireAt = (clock += 10_000);
    await api("/api/revenuecat/webhook", {
      method: "POST",
      auth: RC_AUTH,
      body: { event: { id: crypto.randomUUID(), type: "EXPIRATION", environment: "SANDBOX", app_user_id: u.id, product_id: "test.individual.monthly", original_transaction_id: tx, event_timestamp_ms: expireAt, expiration_at_ms: Date.now() - 1000 } },
    });
    const late = await api("/api/revenuecat/webhook", {
      method: "POST",
      auth: RC_AUTH,
      body: { event: { id: crypto.randomUUID(), type: "RENEWAL", environment: "SANDBOX", app_user_id: u.id, product_id: "test.individual.monthly", original_transaction_id: tx, event_timestamp_ms: expireAt - 5000, expiration_at_ms: Date.now() + DAY } },
    });
    assert.equal(late.body.action, "ignored");
    assert.equal((await access(u)).personal.plan, "free");
  });
  await check("cancellation keeps access until expiry; refund revokes", async () => {
    const u = await register("Cancel");
    const tx = await buy(u, "individual");
    await rc({ type: "CANCELLATION", cancel_reason: "UNSUBSCRIBE", app_user_id: u.id, product_id: "test.individual.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() + DAY });
    assert.equal((await access(u)).personal.plan, "individual");
    await rc({ type: "BILLING_ISSUE", app_user_id: u.id, product_id: "test.individual.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() + DAY });
    assert.equal((await access(u)).personal.plan, "individual", "billing issue keeps access until expiry");
    await rc({ type: "CANCELLATION", cancel_reason: "CUSTOMER_SUPPORT", app_user_id: u.id, product_id: "test.individual.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() - 1000 });
    assert.equal((await access(u)).personal.plan, "free");
  });
  await check("a transaction never switches owner outside TRANSFER", async () => {
    const a = await register("OwnerA");
    const b = await register("OwnerB");
    const tx = await buy(a, "individual");
    const res = await rc({ type: "RENEWAL", app_user_id: b.id, product_id: "test.individual.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() + DAY });
    assert.equal(res.body.action, "ignored");
    assert.equal((await access(b)).personal.plan, "free");
  });
  await check("11. Individual trial is reported as a trial", async () => {
    const u = await register("Trial");
    await buy(u, "individual", { period_type: "TRIAL" });
    const personal = (await access(u)).personal;
    assert.equal(personal.plan, "individual");
    assert.equal(personal.reason, "trial");
  });

  console.log("Individual and groups");
  const ann = await register("Ann");
  const ben = await register("Ben");
  await buy(ann, "individual");
  await buy(ben, "individual");

  await check("1. Individual joins a fifth and tenth group (no 4-group gate)", async () => {
    for (let i = 1; i <= 10; i++) {
      const host = await register(`Host${i}`);
      const circleId = await createGroup(host, `Host group ${i}`);
      await joinOk(ann, await inviteCode(host, circleId));
    }
    const circles = await api("/api/family/circles", { token: ann.token });
    assert.equal(circles.body.length, 10);
    // And hosts more than four groups herself.
    for (let i = 1; i <= 5; i++) await createGroup(ann, `Ann hosted ${i}`);
  });

  let annGroup = "";
  await check("2. Two Individual subscribers use a group with no group plan", async () => {
    annGroup = await createGroup(ann, "Ann and Ben");
    await joinOk(ben, await inviteCode(ann, annGroup));
    assert.equal((await checkIn(ann, annGroup)).status, 201);
    assert.equal((await checkIn(ben, annGroup)).status, 201);
    const s = await sos(ann, annGroup);
    assert.equal(s.status, 201, JSON.stringify(s.body));
    await api(`/api/family/sos/${s.body.id}/resolve`, { method: "POST", token: ann.token });
  });

  await check("5. Individual lapse pauses only that person", async () => {
    const cal = await register("Cal");
    const calTx = await buy(cal, "individual");
    await joinOk(cal, await inviteCode(ann, annGroup));
    assert.equal((await checkIn(cal, annGroup)).status, 201);
    await rc({ type: "EXPIRATION", app_user_id: cal.id, product_id: "test.individual.monthly", original_transaction_id: calTx, expiration_at_ms: Date.now() - 1000 });
    assert.equal((await checkIn(cal, annGroup)).status, 402, "lapsed person is paused");
    assert.equal((await checkIn(ann, annGroup)).status, 201, "others unaffected");
    const s = await sos(ann, annGroup);
    assert.equal(s.status, 201);
    assert.ok(!s.body.recipientUserIds.includes(cal.id), "lapsed person is not an SOS recipient");
    assert.ok(s.body.recipientUserIds.includes(ben.id));
    await api(`/api/family/sos/${s.body.id}/resolve`, { method: "POST", token: ann.token });
  });

  await check("free person in an individually funded group is refused (402)", async () => {
    const fay = await register("Fay");
    await joinOk(fay, await inviteCode(ann, annGroup));
    assert.equal((await checkIn(fay, annGroup)).status, 402);
  });

  console.log("Sponsorship");
  const payer = await register("Payer");
  const mia = await register("Mia");
  let famGroup = "";
  await check("sponsorship binds to the group chosen before checkout", async () => {
    famGroup = await createGroup(payer, "Payer family");
    await bindViaIntent(payer, famGroup, "family");
    const a = await access(payer);
    const g = a.groups.find((x: any) => x.circleId === famGroup);
    assert.equal(g.fundingMode, "sponsored");
    assert.equal(g.capacity, 6);
    assert.equal(g.sponsorship.youPay, true);
  });
  await check("3. sponsored Free member and sponsor keep Free personal limits", async () => {
    await joinOk(mia, await inviteCode(payer, famGroup));
    assert.equal((await checkIn(mia, famGroup)).status, 201, "member covered in the group");
    for (const u of [mia, payer]) {
      const a = await access(u);
      assert.equal(a.personal.plan, "free");
      assert.equal(a.personal.askPerDay, 3);
      assert.equal(a.personal.extraSavedPlaces, 1);
      assert.equal((await savePlace(u, 1)).status, 201);
      assert.equal((await savePlace(u, 2)).status, 402, "second saved place needs Individual");
    }
  });
  await check("9a. sponsored coverage does not reach another group", async () => {
    const other = await register("OtherHost");
    const otherGroup = await createGroup(other, "Unsponsored");
    await joinOk(mia, await inviteCode(other, otherGroup));
    assert.equal((await checkIn(mia, otherGroup)).status, 402);
  });
  await check("8. capacity 6 counts everyone, including the payer", async () => {
    // payer + mia = 2; four more fill it.
    for (let i = 1; i <= 4; i++) await joinOk(await register(`Fill${i}`), await inviteCode(payer, famGroup));
    const seventh = await join(await register("Seventh"), await inviteCode(payer, famGroup));
    assert.equal(seventh.status, 409, JSON.stringify(seventh.body));
  });
  await check("8a. Group 20 holds 20 people (past the old 10-person record limit), not 21", async () => {
    const host = await register("G20Host");
    const g = await createGroup(host, "Club of twenty");
    await bindViaIntent(host, g, "group20");
    const code = async () => inviteCode(host, g);
    for (let i = 1; i <= 19; i++) await joinOk(await register(`G20m${i}`), await code());
    const extra = await join(await register("G20extra"), await code());
    assert.equal(extra.status, 409, JSON.stringify(extra.body));
  });
  await check("8b. simultaneous joins can't both take the last place", async () => {
    const host = await register("RaceHost");
    const g = await createGroup(host, "Race family");
    await bindViaIntent(host, g, "family");
    for (let i = 1; i <= 4; i++) await joinOk(await register(`Race${i}`), await inviteCode(host, g));
    const code = await inviteCode(host, g);
    const [x, y] = await Promise.all([join(await register("RaceX"), code), join(await register("RaceY"), code)]);
    const ok = [x, y].filter((r) => r.status === 200 || r.status === 201).length;
    assert.equal(ok, 1, `statuses ${x.status}/${y.status}`);
  });
  await check("4. Individual and a group plan coexist; tier change keeps Individual", async () => {
    const dee = await register("Dee");
    await buy(dee, "individual");
    const g = await createGroup(dee, "Dee team");
    const famTx = await bindViaIntent(dee, g, "family");
    await rc({ type: "PRODUCT_CHANGE", app_user_id: dee.id, product_id: "test.family.monthly", new_product_id: "test.group20.monthly", original_transaction_id: famTx, expiration_at_ms: Date.now() + 30 * DAY });
    // A requested change is not in effect until the store says so.
    let grp = (await access(dee)).groups.find((x: any) => x.circleId === g);
    assert.equal(grp.sponsorship.tier, "family", "tier must not move on the request");
    assert.equal(grp.capacity, 6);
    assert.equal(grp.sponsorship.pendingTier, "group20");
    await rc({ type: "RENEWAL", app_user_id: dee.id, product_id: "test.group20.monthly", original_transaction_id: famTx, expiration_at_ms: Date.now() + 60 * DAY });
    const a = await access(dee);
    assert.equal(a.personal.plan, "individual");
    grp = a.groups.find((x: any) => x.circleId === g);
    assert.equal(grp.capacity, 20);
    assert.equal(grp.sponsorship.tier, "group20");
    assert.equal(grp.sponsorship.pendingTier, null);
  });
  await check("6. sponsorship lapse pauses only its group, no silent mode switch", async () => {
    const p2 = await register("P2");
    const q = await register("Q");
    const m = await register("M");
    const g1 = await createGroup(p2, "G1");
    const g3 = await createGroup(q, "G3");
    const tx1 = await bindViaIntent(p2, g1, "family");
    await bindViaIntent(q, g3, "family");
    await joinOk(m, await inviteCode(p2, g1));
    await joinOk(m, await inviteCode(q, g3));
    await rc({ type: "EXPIRATION", app_user_id: p2.id, product_id: "test.family.monthly", original_transaction_id: tx1, expiration_at_ms: Date.now() - 1000 });
    assert.equal((await checkIn(m, g1)).status, 402);
    assert.equal((await checkIn(m, g3)).status, 201, "other sponsorship unaffected");
    const grp = (await access(m)).groups.find((x: any) => x.circleId === g1);
    assert.equal(grp.fundingMode, "sponsored", "stays sponsored (paused)");
    // 7. two sponsored memberships never raise personal limits
    assert.equal((await access(m)).personal.askPerDay, 3);
  });
  await check("a second group plan for a covered group is refused", async () => {
    // The payer may upgrade (verify_v1_subscription_changes.ts); a second
    // plan of the same tier, or anyone else's plan, is refused.
    const same = await api("/api/access/sponsorship-intents", {
      method: "POST",
      token: payer.token,
      body: { circleId: famGroup, tier: "family" },
    });
    assert.equal(same.status, 409);
    assert.equal(same.body.code, "GROUP_ALREADY_COVERED");
    const other = await api("/api/access/sponsorship-intents", {
      method: "POST",
      token: mia.token,
      body: { circleId: famGroup, tier: "group20" },
    });
    assert.equal(other.status, 409);
    assert.equal(other.body.code, "GROUP_ALREADY_COVERED");
  });
  await check("only the host can choose a group plan", async () => {
    const uncovered = await createGroup(payer, "Not covered yet");
    await joinOk(mia, await inviteCode(payer, uncovered));
    const res = await api("/api/access/sponsorship-intents", {
      method: "POST",
      token: mia.token,
      body: { circleId: uncovered, tier: "family" },
    });
    assert.equal(res.status, 403);
    assert.equal(res.body.code, "HOST_ONLY");
  });
  await check("an unmatched purchase stays unbound until its payer applies it", async () => {
    const h = await register("Unbound");
    const g = await createGroup(h, "Later");
    await buy(h, "group50"); // no intent
    const a = await access(h);
    assert.equal(a.unboundSponsorships.length, 1);
    const other = await register("Thief");
    const steal = await api(`/api/access/sponsorships/${a.unboundSponsorships[0].id}/bind`, {
      method: "POST",
      token: other.token,
      body: { circleId: g },
    });
    assert.equal(steal.status, 403);
    const bind = await api(`/api/access/sponsorships/${a.unboundSponsorships[0].id}/bind`, {
      method: "POST",
      token: h.token,
      body: { circleId: g },
    });
    assert.equal(bind.status, 200, JSON.stringify(bind.body));
  });

  console.log("SOS audience and safety");
  await check("no empty SOS", async () => {
    const lone = await register("Lone");
    await buy(lone, "individual");
    const g = await createGroup(lone, "Just me");
    const res = await sos(lone, g);
    assert.equal(res.status, 422);
    assert.match(res.body.error, /Add someone first/);
  });
  await check("9b. SOS preset naming another group is refused", async () => {
    const other = await createGroup(ben, "Ben other");
    const otherMember = await register("OtherMember");
    await buy(otherMember, "individual");
    await joinOk(otherMember, await inviteCode(ben, other));
    const circle = await api(`/api/family/circle?circleId=${other}`, { token: ben.token });
    const outsider = circle.body.members.find((m: any) => m.userId === otherMember.id);
    // Ben is in both groups, so the list itself is valid for him...
    const list = await api("/api/family/sos-lists", {
      method: "POST",
      token: ben.token,
      body: { name: "Mixed", memberIds: [outsider.id] },
    });
    assert.equal(list.status, 201, JSON.stringify(list.body));
    // ...but an SOS from Ann's group can't reach someone outside it.
    const s = await sos(ben, annGroup, { sosListId: list.body.id });
    assert.equal(s.status, 422, JSON.stringify(s.body));
    assert.match(s.body.error, /another group/);
  });
  await check("9c. unselected group members cannot read or answer an SOS", async () => {
    const h = await register("AudHost");
    const sel = await register("Selected");
    const unsel = await register("Unselected");
    for (const u of [h, sel, unsel]) await buy(u, "individual");
    const g = await createGroup(h, "Audience");
    await joinOk(sel, await inviteCode(h, g));
    await joinOk(unsel, await inviteCode(h, g));
    const circle = await api(`/api/family/circle?circleId=${g}`, { token: h.token });
    const selMember = circle.body.members.find((m: any) => m.userId === sel.id);
    const list = await api("/api/family/sos-lists", {
      method: "POST",
      token: h.token,
      body: { name: "Just Sel", memberIds: [selMember.id] },
    });
    assert.equal(list.status, 201, JSON.stringify(list.body));
    const s = await sos(h, g, { sosListId: list.body.id });
    assert.equal(s.status, 201, JSON.stringify(s.body));
    assert.deepEqual(s.body.recipientUserIds, [sel.id]);
    const trail = await api(`/api/family/sos/${s.body.id}/trail`, { token: unsel.token });
    assert.equal(trail.status, 404, "unselected can't read the trail");
    const respond = await api(`/api/family/sos/${s.body.id}/respond`, { method: "POST", token: unsel.token, body: { type: "seen" } });
    assert.equal(respond.status, 404, "unselected can't respond");
    const active = await api(`/api/family/sos/active?circleId=${g}`, { token: unsel.token });
    assert.equal(active.body.length, 0, "unselected doesn't see it");
    const activeSel = await api(`/api/family/sos/active?circleId=${g}`, { token: sel.token });
    assert.equal(activeSel.body.length, 1);
    const end = await api(`/api/family/sos/${s.body.id}/resolve`, { method: "POST", token: h.token });
    assert.equal(end.status, 200);
    assert.ok(end.body.endedByMemberId, "actor recorded");
  });
  await check("SOS never uses stale stored coordinates", async () => {
    const s = await sos(ann, annGroup); // no lat/lng sent
    assert.equal(s.status, 201);
    assert.equal(s.body.latitude, null);
    await api(`/api/family/sos/${s.body.id}/resolve`, { method: "POST", token: ann.token });
  });
  await check("guest invites are retired", async () => {
    const res = await api(`/api/family/invites?circleId=${annGroup}`, {
      method: "POST",
      token: ann.token,
      body: { isGuestInvite: true },
    });
    assert.equal(res.status, 400);
  });

  console.log("Personal limits");
  await check("12. saved places: simultaneous saves can't exceed the Free one", async () => {
    const u = await register("Racer");
    const results = await Promise.all([1, 2, 3, 4, 5].map((n) => savePlace(u, n)));
    assert.equal(results.filter((r) => r.status === 201).length, 1);
  });
  await check("Individual gets unlimited saved places; lapse pauses the extras", async () => {
    const u = await register("Places");
    const tx = await buy(u, "individual");
    for (const n of [1, 2, 3]) assert.equal((await savePlace(u, n)).status, 201);
    await rc({ type: "EXPIRATION", app_user_id: u.id, product_id: "test.individual.monthly", original_transaction_id: tx, expiration_at_ms: Date.now() - 1000 });
    const list = await api("/api/user/location-subscriptions", { token: u.token });
    const saved = list.body.filter((s: any) => !s.isOwnLocation);
    assert.equal(saved.length, 3, "nothing deleted");
    assert.equal(saved.filter((s: any) => s.isPaused).length, 2, "extras paused");
  });

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

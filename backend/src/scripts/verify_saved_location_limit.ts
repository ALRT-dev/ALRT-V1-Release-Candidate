/**
 * Saved-location allowance: client gate versus server enforcement - real
 * HTTP requests against a running instance of this backend, real Postgres.
 *
 * The approved allowance is one saved location on the free plan (the
 * automatic own-location follow never counts); ALRT+ removes the limit.
 * The app gates at that number; the server's gate (403) is live only when
 * BILLING_ENABLED=true. This script reads the mode the server it talks
 * to runs in from its own environment (the rollout runs it inside the app
 * container, so the two agree) and proves the right thing for that mode,
 * saying which it was. It never changes the rule to pass.
 *
 *   BILLING_ENABLED != true  (TEST today): the second saved location is
 *     accepted by the server; only the app stops it. Reported as
 *     "server enforcement OFF", not as a pass of enforcement.
 *   BILLING_ENABLED = true: the second saved location is refused with 403
 *     and the ALRT+ message; a user whose plan is `plus` saves as many as
 *     they like; joining a circle with a code stays free for a free user.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_saved_location_limit.ts
 */

import assert from "node:assert/strict";
import { PrismaClient } from "@prisma/client";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();
const enforced = process.env.BILLING_ENABLED === "true";

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
  const email = `saved-limit-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  const me = await api("/api/user", { token });
  return { token, id: (me.body.data ?? me.body).id as string, label };
};

let n = 0;
const save = (token: string) =>
  api("/api/user/subscribe-location", {
    method: "POST",
    token,
    body: {
      northeastLat: -30 - n * 0.2,
      northeastLng: 120 + n * 0.2,
      southwestLat: -30.1 - n++ * 0.2,
      southwestLng: 119.9,
      name: `saved-limit place ${n}`,
    },
  });

async function main() {
  console.log(`Saved-location allowance (server BILLING_ENABLED=${enforced ? "true" : "not true"})\n`);
  const free = await registerUser("free");
  const plus = await registerUser("plus");
  const host = await registerUser("host");
  const created: string[] = [];

  try {
    await check("the first saved location is accepted for a free account", async () => {
      const res = await save(free.token);
      assert.equal(res.status, 201, JSON.stringify(res.body));
      created.push(res.body.id ?? res.body.data?.id);
    });

    if (!enforced) {
      await check("server enforcement OFF: the second saved location is accepted by the server (the app's gate is the only limit)", async () => {
        const res = await save(free.token);
        assert.equal(res.status, 201, JSON.stringify(res.body));
        created.push(res.body.id ?? res.body.data?.id);
      });
      console.log("  note - BILLING_ENABLED is not true on this server: the 403 path is NOT exercised here");
    } else {
      await check("server enforcement ON: the second saved location is refused with 403 and the ALRT+ message", async () => {
        const res = await save(free.token);
        assert.equal(res.status, 403, JSON.stringify(res.body));
        const message = String(res.body?.message ?? res.body?.error ?? "");
        assert.match(message, /ALRT\+/);
      });
      await check("a plus account saves a second and a third location", async () => {
        await prisma.user.update({ where: { id: plus.id }, data: { plan: "plus", planExpiresAt: null } });
        for (let i = 0; i < 3; i++) {
          const res = await save(plus.token);
          assert.equal(res.status, 201, JSON.stringify(res.body));
          created.push(res.body.id ?? res.body.data?.id);
        }
      });
      await check("a free account still joins a circle with a code (joining is always free)", async () => {
        await prisma.user.update({ where: { id: host.id }, data: { plan: "plus", planExpiresAt: null } });
        const circle = await api("/api/family/circle", { method: "POST", token: host.token, body: { name: "Free join" } });
        assert.equal(circle.status, 201, JSON.stringify(circle.body));
        const invite = await api("/api/family/invites", { method: "POST", token: host.token });
        assert.equal(invite.status, 201, JSON.stringify(invite.body));
        const join = await api("/api/family/join", { method: "POST", token: free.token, body: { code: invite.body.code } });
        assert.equal(join.status, 200, JSON.stringify(join.body));
        await prisma.familyCircle.delete({ where: { id: circle.body.id } });
      });
    }

    await check("the own-location follow never counts against the allowance", async () => {
      const rows = await prisma.locationSubscription.findMany({ where: { userId: free.id } });
      assert.ok(rows.every((r) => !r.isOwnLocation), "no own-location row was created by saving");
    });
  } finally {
    await prisma.locationSubscription.deleteMany({ where: { userId: { in: [free.id, plus.id, host.id] } } });
  }

  console.log(`\n${passed} checks passed.${enforced ? "" : " (server enforcement OFF)"}`);
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

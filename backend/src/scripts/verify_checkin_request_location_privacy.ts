/**
 * Check-in request location privacy verification script — real HTTP
 * requests against a running instance of this backend, backed by a real
 * local Postgres+PostGIS database.
 *
 * Covers the fix in family.service.ts requestCheckIn(): a "request a
 * check-in" broadcast previously included the requester's full
 * FamilyMember row (via an unscoped Prisma `include`), which carries the
 * requester's last-shared location snapshot (latitude/longitude/
 * locationLabel/locationUpdatedAt/locationExpiresAt/batteryLevel). That
 * snapshot rode along to every other circle member over both the HTTP
 * response and the identical `socketData` broadcast payload, even though
 * requesting a check-in has never required or collected the requester's
 * location. Per backend/CLAUDE.md: "Location leaves a phone only by the
 * owner's action."
 *
 * Proves:
 *   1. familyCheckInRequestSchema has no latitude/longitude field at all
 *      (already true - confirming, not re-fixing).
 *   2. Even when the requester has a real, previously-shared location
 *      snapshot on their FamilyMember row (from an earlier check-in),
 *      creating a check-in request never surfaces it: the response's
 *      requestedBy object omits every location-bearing key entirely.
 *   3. The same requestedBy shape is returned regardless of whether the
 *      caller tries to smuggle latitude/longitude into the request body
 *      (the validator strips unknown fields; nothing is persisted).
 *   4. A normal check-in *response* (POST /api/family/check-in) still
 *      works with no location at all - the check-in-request flow doesn't
 *      newly require location anywhere in the loop.
 *   5. requestedBy still carries enough to identify who asked (id,
 *      nickname, user.name) - this is a redaction, not a break.
 *
 * Setup: same throwaway Postgres+PostGIS pattern as
 * verify_stage9a_journey_recipient.ts / verify_stage11_blocker1_gps_privacy.ts.
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_checkin_request_location_privacy.ts
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
  const email = `checkin-privacy-${label}-${uniqueSuffix}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = (res.body as any).accessToken as string;

  const nameRes = await api("/api/user", {
    method: "PUT",
    token,
    body: { name: label },
  });
  assert.equal(nameRes.status, 200, `name ${label}: ${JSON.stringify(nameRes.body)}`);

  const meRes = await api("/api/user", { token });
  assert.equal(meRes.status, 200);
  return { token, userId: (meRes.body as any).id as string };
};

const LOCATION_KEYS = [
  "latitude",
  "longitude",
  "locationLabel",
  "locationUpdatedAt",
  "locationExpiresAt",
  "locationSharedVia",
  "batteryLevel",
  "isMoving",
  "geom",
];

async function main() {
  console.log("Check-in request location privacy verification (real HTTP + real DB)\n");

  console.log("§1 - schema never accepts a location on the request itself");
  await check(
    "familyCheckInRequestSchema has no latitude/longitude field, and strips unknown ones",
    async () => {
      const parsed = familyCheckInRequestSchema.safeParse({
        message: "hi",
        latitude: -27.4, // not a declared field
        longitude: 153.0,
      });
      assert.ok(parsed.success, JSON.stringify(parsed));
      assert.ok(!("latitude" in (parsed.data as object)));
      assert.ok(!("longitude" in (parsed.data as object)));
    },
  );
  console.log();

  console.log("setup - requester (A) with a real location snapshot, recipient (B) in the same circle");
  const a = await registerUser("requester");
  const b = await registerUser("recipient");

  const circleRes = await api("/api/family/circle", {
    method: "POST",
    token: a.token,
    body: { name: "Privacy Check Circle" },
  });
  assert.equal(circleRes.status, 201);

  const invite = await api("/api/family/invites", { method: "POST", token: a.token });
  assert.equal(invite.status, 201);
  const join = await api("/api/family/join", {
    method: "POST",
    token: b.token,
    body: { code: (invite.body as any).code },
  });
  assert.equal(join.status, 200, JSON.stringify(join.body));

  // Give A a genuine, previously-shared location snapshot on their
  // FamilyMember row - the exact data the leak exposed - by having them
  // check in with a real location first, same as a normal user would.
  const REQUESTER_LAT = -27.4839;
  const REQUESTER_LNG = 153.0175;
  const seedCheckIn = await api("/api/family/check-in", {
    method: "POST",
    token: a.token,
    body: { status: "safe", latitude: REQUESTER_LAT, longitude: REQUESTER_LNG },
  });
  assert.equal(seedCheckIn.status, 201, JSON.stringify(seedCheckIn.body));
  console.log("  setup - circle created, B joined, A has a real stored location snapshot\n");

  console.log("§2/§3 - POST /api/family/check-in/request never surfaces the requester's location");

  const attemptSmuggle = await api("/api/family/check-in/request", {
    method: "POST",
    token: a.token,
    body: {
      message: "Everyone please check in",
      // Attempting to smuggle location onto the request itself.
      latitude: REQUESTER_LAT,
      longitude: REQUESTER_LNG,
    },
  });

  await check(
    "check-in request succeeds without requiring/using any location field",
    async () => {
      assert.equal(attemptSmuggle.status, 201, JSON.stringify(attemptSmuggle.body));
    },
  );

  const requestedBy = (attemptSmuggle.body as any).requestedBy;

  await check("requestedBy is present and identifies the requester", async () => {
    assert.ok(requestedBy, "requestedBy must be present so the recipient knows who asked");
    assert.equal(typeof requestedBy.id, "string");
    assert.ok(requestedBy.user, "requestedBy.user must be present");
    assert.equal(requestedBy.user.name, "requester");
  });

  await check(
    "requestedBy omits every location-bearing key entirely (not just null - absent)",
    async () => {
      for (const key of LOCATION_KEYS) {
        assert.ok(
          !(key in requestedBy),
          `requestedBy must not carry "${key}" - found: ${JSON.stringify(requestedBy[key])}`,
        );
      }
    },
  );

  await check(
    "the top-level check-in request payload itself carries no location field either",
    async () => {
      const body = attemptSmuggle.body as any;
      for (const key of ["latitude", "longitude", "locationLabel"]) {
        assert.ok(!(key in body), `check-in request must not carry "${key}"`);
      }
    },
  );
  console.log();

  console.log("§4 - a normal check-in response still works with zero location shared");
  await check(
    "POST /api/family/check-in with only a status (no lat/lng) succeeds",
    async () => {
      const res = await api("/api/family/check-in", {
        method: "POST",
        token: b.token,
        body: { status: "safe", requestId: (attemptSmuggle.body as any).id },
      });
      assert.equal(res.status, 201, JSON.stringify(res.body));
      assert.equal((res.body as any)?.latitude ?? null, null);
      assert.equal((res.body as any)?.longitude ?? null, null);
    },
  );

  console.log(`\n${passed} checks passed.`);
}

main().catch((error) => {
  console.error("\nFAILED:", error);
  process.exitCode = 1;
});

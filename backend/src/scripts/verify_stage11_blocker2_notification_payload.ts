/**
 * Stage 11 Blocker 2 verification script — proves the familyHazardProximity
 * push payload is now encoded exactly once, matching the already-working
 * viewHazard shape, instead of the double-JSON-encoded shape that silently
 * broke deep linking, the urgent-vibration channel, and accessible
 * read-aloud for this safety-relevant notification type.
 *
 * This does NOT talk to real Firebase (no real project credentials exist in
 * this environment) — it intercepts the same `firebaseAdmin.messaging()`
 * call the real send path uses, by redefining that one method on the
 * process-wide firebase-admin module instance before the code under test
 * runs, then calls the real, unmodified `notifyFamiliesAboutNewHazard`
 * (family_alert.service.ts) against a real Postgres-backed circle/member/
 * place, and inspects the exact FCM message object the app would have
 * handed to Firebase.
 *
 * Proves:
 *   1. The outer envelope (`data.payload`) is valid JSON that decodes to an
 *      object containing the hazard's fields directly at the top level
 *      (id, severityBand, title, ...) — exactly one encoding, not nested
 *      under a second `payload` key.
 *   2. `notificationType` is `familyHazardProximity` (the correct type is
 *      received).
 *   3. The decoded hazard id matches the real hazard (the correct hazard is
 *      available for the deep link).
 *   4. `severityBand` is present at the top level of the decoded payload —
 *      the exact field LocalNotificationService reads to decide the urgent/
 *      strong-vibration channel and NotificationService reads for
 *      accessible read-aloud (frontend_service files documented inline).
 *   5. Both call sites (member-near-hazard and place-near-hazard) produce
 *      the same correctly-shaped payload.
 *
 * NOT covered (no Flutter/Android/iOS tooling in this environment — see
 * V1_RECONCILIATION_REPORT.md Stage 11 for the explicit CODE VERIFIED /
 * AUTOMATED TEST VERIFIED / REAL DEVICE VERIFIED breakdown): the actual
 * on-device tray rendering, vibration pattern, and read-aloud audio.
 *
 * Setup: same throwaway Postgres+PostGIS + fake serviceAccountKey.json
 * pattern as the other verify_stage11 scripts. Does not require the HTTP
 * server to be running — this script calls the service function directly.
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_stage11_blocker2_notification_payload.ts
 */

import assert from "node:assert/strict";
import { PrismaClient, HazardReviewStatus, HazardSeverityBand, HazardSeverity } from "@prisma/client";
import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";

const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

type CapturedMessage = { data?: Record<string, string>; notification?: unknown };
const captured: CapturedMessage[] = [];

// Intercept the exact call the real send path makes
// (sendPushNotificationToTokens -> firebaseAdmin.messaging().sendEachForMulticast)
// without touching any real Firebase project.
Object.defineProperty(firebaseAdmin, "messaging", {
  value: () => ({
    sendEachForMulticast: async (message: CapturedMessage) => {
      captured.push(message);
      return { responses: [], successCount: 0, failureCount: 0 } as any;
    },
  }),
  writable: true,
  configurable: true,
});

async function main() {
  console.log("Stage 11 Blocker 2 verification (real service call, intercepted FCM send)\n");

  const { notifyFamiliesAboutNewHazard } = await import(
    "../services/family_alert.service.js"
  );

  console.log("Setup");
  const category = await prisma.hazardCategory.findFirst();
  assert.ok(category, "seed data must include at least one hazard category");

  // Every id created below is prefixed stage11-b2-/"Stage 11 Blocker 2" so a
  // crashed run's leftovers are easy to spot and clean up by hand too - but
  // the try/finally below means a normal (even failing) run always cleans
  // up after itself.
  const suffix = crypto.randomUUID().slice(0, 8);
  const owner = await prisma.user.create({
    data: { email: `stage11-b2-owner-${suffix}@test.local`, name: "Owner" },
  });
  const member = await prisma.user.create({
    data: { email: `stage11-b2-member-${suffix}@test.local`, name: "Member" },
  });
  const memberToken = await prisma.userDevice.create({
    data: { userId: member.id, deviceToken: `fake-fcm-token-${suffix}`, platform: "android" },
  });

  const circle = await prisma.familyCircle.create({
    data: { name: "Stage 11 Blocker 2 Circle", createdById: owner.id },
  });

  const HAZARD_LAT = -27.4698;
  const HAZARD_LNG = 153.0251;

  const familyMember = await prisma.familyMember.create({
    data: {
      circleId: circle.id,
      userId: member.id,
      sharingLevel: "precise",
      latitude: HAZARD_LAT + 0.005, // ~0.5km away, within the 5km member radius
      longitude: HAZARD_LNG + 0.005,
      locationExpiresAt: new Date(Date.now() + 60 * 60 * 1000),
    },
  });

  const savedPlace = await prisma.familySavedPlace.create({
    data: {
      circleId: circle.id,
      name: "Stage 11 Test Place",
      latitude: HAZARD_LAT + 0.01, // within the 10km place radius
      longitude: HAZARD_LNG + 0.01,
      createdById: familyMember.id,
    },
  });

  const hazard = await prisma.hazard.create({
    data: {
      title: "Stage 11 Blocker 2 hazard",
      description: "A serious hazard for family-proximity payload verification",
      categoryId: category!.id,
      reportedById: null,
      reviewStatus: HazardReviewStatus.accepted,
      severity: HazardSeverity.watchAndAct,
      severityBand: HazardSeverityBand.action,
      latitude: HAZARD_LAT,
      longitude: HAZARD_LNG,
      locationName: "Near the test member and place",
    },
  });

  console.log("  setup - one circle with a nearby member and a nearby saved place, one action-band hazard\n");

  try {
    await runChecks({ notifyFamiliesAboutNewHazard, hazard, familyMember, savedPlace, circle });
  } finally {
    await prisma.hazard.delete({ where: { id: hazard.id } });
    await prisma.familySavedPlace.delete({ where: { id: savedPlace.id } });
    await prisma.familyMemberHazardAlert.deleteMany({ where: { memberId: familyMember.id } });
    await prisma.familyMember.delete({ where: { id: familyMember.id } });
    await prisma.familyCircle.delete({ where: { id: circle.id } });
    await prisma.userDevice.delete({ where: { id: memberToken.id } });
    await prisma.user.delete({ where: { id: member.id } });
    await prisma.user.delete({ where: { id: owner.id } });
  }
}

async function runChecks({
  notifyFamiliesAboutNewHazard,
  hazard,
  familyMember,
  savedPlace,
  circle,
}: {
  notifyFamiliesAboutNewHazard: (hazard: any) => Promise<void>;
  hazard: { id: string; title: string };
  familyMember: { id: string };
  savedPlace: { id: string };
  circle: { id: string };
}) {
  console.log("Blocker 2 - familyHazardProximity push payload shape");

  captured.length = 0;
  await notifyFamiliesAboutNewHazard(hazard as any);

  await check(
    "exactly two familyHazardProximity pushes were sent (one member-triggered, one place-triggered)",
    () => {
      const proximityMessages = captured.filter(
        (m) => m.data?.notificationType === "familyHazardProximity",
      );
      assert.equal(proximityMessages.length, 2, JSON.stringify(captured));
    },
  );

  const decode = (m: CapturedMessage) => {
    const raw = m.data?.payload;
    assert.ok(typeof raw === "string" && raw.length > 0, "data.payload must be a non-empty string");
    // Exactly one decode should already produce the hazard object — if the
    // bug regresses, this decodes to {circleId, memberId, payload: "<json
    // string>", distanceKm} instead, and the assertions below fail.
    return JSON.parse(raw as string);
  };

  const proximityDecoded = captured
    .filter((m) => m.data?.notificationType === "familyHazardProximity")
    .map(decode);

  await check(
    "member-triggered push: data.payload decodes ONCE to the hazard itself (id, severityBand at top level)",
    () => {
      const decoded = proximityDecoded.find((d) => d.memberId);
      assert.ok(decoded, "expected a member-triggered familyHazardProximity push");
      assert.equal(decoded.id, hazard.id, "decoded hazard id must match - this is what the deep link opens");
      assert.equal(
        decoded.severityBand,
        "action",
        "severityBand must be at the top level - LocalNotificationService/_maybeSpeak read it from here",
      );
      assert.equal(decoded.title, hazard.title);
      assert.equal(decoded.memberId, familyMember.id);
      assert.equal(decoded.circleId, circle.id);
      assert.ok("payload" in decoded === false, "must not be double-wrapped under a nested payload key");
    },
  );

  await check(
    "place-triggered push: data.payload decodes ONCE to the hazard itself (id, severityBand at top level)",
    () => {
      const decoded = proximityDecoded.find((d) => d.placeId);
      assert.ok(decoded, "expected a place-triggered familyHazardProximity push");
      assert.equal(decoded.id, hazard.id);
      assert.equal(decoded.severityBand, "action");
      assert.equal(decoded.placeId, savedPlace.id);
      assert.equal(decoded.circleId, circle.id);
      assert.ok("payload" in decoded === false, "must not be double-wrapped under a nested payload key");
    },
  );

  await check(
    "shape matches the already-working viewHazard convention (data.notificationType set, single JSON envelope)",
    () => {
      for (const m of captured) {
        assert.equal(typeof m.data?.notificationType, "string");
        assert.equal(typeof m.data?.payload, "string");
        // Only two keys on the FCM data map itself - everything else rides
        // inside the single payload string, same as every other type.
        assert.deepEqual(Object.keys(m.data!).sort(), ["notificationType", "payload"]);
      }
    },
  );

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

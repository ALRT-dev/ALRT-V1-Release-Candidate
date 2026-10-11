/**
 * Community report push timing (HazardSource.pushPolicy).
 *
 * A community report with the `afterConfirmation` policy (the §1 registry
 * default, since community reports carry no HazardSource row) is NOT pushed
 * on AI acceptance; the push goes out the first time another user confirms
 * (upvotes) it, and only once. Any other policy keeps the push on acceptance.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

vi.mock("@prisma/client", () => ({
  HazardSeverity: { unknown: "unknown", advice: "advice", watchAndAct: "watchAndAct", emergency: "emergency" },
  HazardSeverityBand: { info: "info", monitor: "monitor", action: "action", critical: "critical" },
  HazardSourceShape: { triangle: "triangle", diamond: "diamond", square: "square", circle: "circle", shield: "shield" },
  HazardSeveritySystem: { awsLevel: "awsLevel", band: "band", category: "category", gdacsColour: "gdacsColour", advisory: "advisory" },
  SeverityLevelHandling: { verbatim: "verbatim", bandColourOnly: "bandColourOnly", categoryColour: "categoryColour", levelExempt: "levelExempt" },
  SourcePushPolicy: {
    everyLevel: "everyLevel",
    bandThreshold: "bandThreshold",
    afterConfirmation: "afterConfirmation",
    greenExempt: "greenExempt",
    advisoryOnly: "advisoryOnly",
  },
}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    hazardSource: { findUnique: vi.fn() },
    user: { findMany: vi.fn(async () => []) },
    locationSubscription: { findMany: vi.fn(async () => []) },
  },
}));

vi.mock("../utils/firebase_admin_client.util.js", () => ({
  firebaseAdmin: { messaging: () => ({ sendEachForMulticast: vi.fn() }) },
}));
vi.mock("../utils/cache_client.util.js", () => ({
  getCacheClient: () => null,
}));
vi.mock("../services/location_subscription.service.js", () => ({
  pausedSavedPlaceIds: vi.fn(async () => new Set()),
}));
vi.mock("../utils/hazard.util.js", () => ({
  getFormattedHazardSeverity: vi.fn(() => ""),
}));

const notified = new Set<string>();
vi.mock("../services/hazard_cache.service.js", () => ({
  isUnderNotificationCooldown: vi.fn(async () => false),
  wasContentNotified: vi.fn(async (key: string) => notified.has(key)),
  markContentNotified: vi.fn(async (key: string) => {
    notified.add(key);
  }),
}));

import prisma from "../utils/prisma_client.util.js";
import { markContentNotified, wasContentNotified } from "../services/hazard_cache.service.js";
import * as notification from "../services/notification.service.js";

const hazard = (overrides: Record<string, unknown> = {}) =>
  ({
    id: "hz-1",
    title: "Smoke near the oval",
    reportedById: "reporter-1",
    sourceId: null,
    latitude: -31.9,
    longitude: 115.8,
    severity: "unknown",
    isAwsCompliant: false,
    ...overrides,
  }) as any;

describe("community push policy", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    notified.clear();
  });

  it("defaults a community report (no sourceId) to afterConfirmation", async () => {
    expect(await notification.resolveCommunityPushPolicy(hazard())).toBe("afterConfirmation");
    expect(await notification.communityPushWaitsForConfirmation(hazard())).toBe(true);
    expect(prisma.hazardSource.findUnique).not.toHaveBeenCalled();
  });

  it("honours a source whose pushPolicy is not afterConfirmation (push on acceptance)", async () => {
    (prisma.hazardSource.findUnique as any).mockResolvedValue({ pushPolicy: "everyLevel" });
    expect(await notification.communityPushWaitsForConfirmation(hazard({ sourceId: "src-1" }))).toBe(false);
  });

  it("falls back to the community default when the source has no policy", async () => {
    (prisma.hazardSource.findUnique as any).mockResolvedValue({ pushPolicy: null });
    expect(await notification.communityPushWaitsForConfirmation(hazard({ sourceId: "src-1" }))).toBe(true);
  });

  it("sends the confirmation push on the FIRST confirming upvote only", async () => {
    expect(
      await notification.sendCommunityConfirmationPush({ hazard: hazard(), confirmingUpvotes: 0 }),
    ).toBe(false);
    expect(
      await notification.sendCommunityConfirmationPush({ hazard: hazard(), confirmingUpvotes: 2 }),
    ).toBe(false);
    expect(
      await notification.sendCommunityConfirmationPush({ hazard: hazard(), confirmingUpvotes: 1 }),
    ).toBe(true);
    // Remove-then-upvote-again brings the count back to 1: the dedup key stops a second push.
    expect(
      await notification.sendCommunityConfirmationPush({ hazard: hazard(), confirmingUpvotes: 1 }),
    ).toBe(false);

    // The push path ran exactly once: one dedup mark for this hazard, and
    // the second count==1 call was stopped by the mark.
    expect(markContentNotified).toHaveBeenCalledTimes(1);
    expect(markContentNotified).toHaveBeenCalledWith("community-confirmed-push:hz-1");
    expect(wasContentNotified).toHaveBeenCalledTimes(2);
  });
});

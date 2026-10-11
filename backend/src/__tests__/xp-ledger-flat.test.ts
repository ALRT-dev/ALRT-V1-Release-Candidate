/**
 * XP ledger after the streak multiplier and weekly quest were removed
 * (Oct 2026). Points are flat; the summary keeps backward-compatible
 * placeholders (streakDays 0, streakMultiplierActive false, weeklyQuest null)
 * for the app's XpSummary model; nothing writes User.streakDays or
 * User.lastActivityDate any more.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

vi.mock("@prisma/client", () => ({
  HazardReviewStatus: { accepted: "accepted", rejected: "rejected", pending: "pending" },
  XpEventType: {
    reportApproved: "reportApproved",
    reportRejected: "reportRejected",
    guideCompleted: "guideCompleted",
    questCompleted: "questCompleted",
    officialMatch: "officialMatch",
    corroborationReceived: "corroborationReceived",
    onboardingCompleted: "onboardingCompleted",
    firstReportPosted: "firstReportPosted",
    profileCompleted: "profileCompleted",
    familyJoined: "familyJoined",
    savedPlaceAdded: "savedPlaceAdded",
    reportWidelyCorroborated: "reportWidelyCorroborated",
    shareInstall: "shareInstall",
  },
  Prisma: {},
}));

const tx = {
  user: {
    findUniqueOrThrow: vi.fn(async () => ({ xpPoints: 100 })),
    update: vi.fn(async () => ({ id: "u1", xpPoints: 110 })),
  },
  xpEvent: {
    create: vi.fn(async ({ data }: any) => ({ id: "ev-1", ...data })),
  },
};

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    $transaction: vi.fn(async (fn: any) => fn(tx)),
    user: {
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    xpEvent: {
      count: vi.fn(async () => 0),
      findFirst: vi.fn(async () => null),
      findMany: vi.fn(async () => []),
    },
    hazard: {
      count: vi.fn(async () => 0),
      findMany: vi.fn(async () => []),
    },
  },
}));

vi.mock("../services/family.service.js", () => ({
  haversineKm: vi.fn(() => 0),
}));
vi.mock("../services/socket.service.js", () => ({
  sendSocketEventToUsers: vi.fn(),
}));
vi.mock("../models/socket_event_types.js", () => ({
  SocketEvent: { xpUpdated: "xpUpdated" },
}));
vi.mock("../services/badge.service.js", () => ({
  getBadgesFor: vi.fn(async () => ({ badges: [], counts: {} })),
  isWidelyCorroborated: vi.fn(async () => false),
  recordCorroboration: vi.fn(),
}));

import prisma from "../utils/prisma_client.util.js";
import * as ledger from "../services/xp_ledger.service.js";

describe("XP ledger: flat points, no streak, no weekly quest", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("no longer exports the streak or weekly quest machinery", () => {
    expect((ledger as any).touchActivityStreak).toBeUndefined();
    expect((ledger as any).streakMultiplierFor).toBeUndefined();
    expect((ledger as any).WEEKLY_QUEST).toBeUndefined();
  });

  it("getXpSummary returns compatible placeholders and never reads streak columns", async () => {
    (prisma.user.findUnique as any).mockResolvedValue({ xpPoints: 42, reliabilityScore: 0.5 });

    const summary = await ledger.getXpSummary("u1");

    expect(summary).not.toBeNull();
    expect(summary!.xpPoints).toBe(42);
    expect(summary!.streakDays).toBe(0);
    expect(summary!.streakMultiplierActive).toBe(false);
    expect(summary!.weeklyQuest).toBeNull();
    expect(summary!.trustTier).toBeDefined();
    expect(summary!.pointValues).toBe(ledger.XP_POINTS);

    const select = (prisma.user.findUnique as any).mock.calls[0][0].select;
    expect(select.streakDays).toBeUndefined();
    expect(select.lastActivityDate).toBeUndefined();
    // No weekly quest queries either.
    expect(prisma.xpEvent.count).not.toHaveBeenCalled();
    expect(prisma.xpEvent.findFirst).not.toHaveBeenCalled();
  });

  it("recordGuideCompletion writes exactly one ledger row and no quest award", async () => {
    await ledger.recordGuideCompletion({ userId: "u1", guideId: "g1", xpAwarded: 10 });

    expect(tx.xpEvent.create).toHaveBeenCalledOnce();
    expect((tx.xpEvent.create.mock.calls[0] as any)[0].data.type).toBe("guideCompleted");
    // Nothing touched the streak columns on User.
    expect(prisma.user.update).not.toHaveBeenCalled();
    for (const call of tx.user.update.mock.calls) {
      expect((call as any)[0].data.streakDays).toBeUndefined();
      expect((call as any)[0].data.lastActivityDate).toBeUndefined();
    }
  });
});

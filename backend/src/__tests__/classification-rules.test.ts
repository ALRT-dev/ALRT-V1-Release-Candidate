/**
 * Classification and copy rules:
 *
 *  - AWS Advice maps to the `monitor` band, not `info`.
 *  - reviewHazard (community reports) always returns callsToAction: [].
 *  - The webhook validator strips client-supplied severity, severityBand and
 *    isAwsCompliant so the server's own scan decides.
 *  - The scheduled check-in validator requires timezone.
 *  - Ask ALRT copy never hard-codes 000 as the emergency number.
 *  - The leaderboard returns rank and points only for other users.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

vi.mock("@prisma/client", () => ({
  HazardSeverity: {
    unknown: "unknown",
    low: "low",
    medium: "medium",
    high: "high",
    extreme: "extreme",
    advice: "advice",
    watchAndAct: "watchAndAct",
    emergency: "emergency",
  },
  HazardSeverityBand: { info: "info", monitor: "monitor", action: "action", critical: "critical" },
  HazardReviewStatus: { accepted: "accepted", rejected: "rejected", pending: "pending" },
  HazardVoteType: { upvote: "upvote", downvote: "downvote" },
  FireStatus: { going: "going", contained: "contained" },
  XpEventType: {},
  HazardSourceShape: { triangle: "triangle", diamond: "diamond", square: "square", circle: "circle", shield: "shield" },
  HazardSeveritySystem: { awsLevel: "awsLevel", band: "band", category: "category", gdacsColour: "gdacsColour", advisory: "advisory" },
  SeverityLevelHandling: { verbatim: "verbatim", bandColourOnly: "bandColourOnly", categoryColour: "categoryColour", levelExempt: "levelExempt" },
  SourcePushPolicy: { everyLevel: "everyLevel", bandThreshold: "bandThreshold", afterConfirmation: "afterConfirmation", greenExempt: "greenExempt", advisoryOnly: "advisoryOnly" },
}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    user: { findMany: vi.fn(), count: vi.fn(async () => 2) },
  },
}));

// hazard.service dependencies
vi.mock("../services/community_safety.service.js", () => ({ listBlockedUserIds: vi.fn() }));
vi.mock("../utils/user_status.util.js", () => ({ calculateBulkUserReportsStatus: vi.fn() }));
vi.mock("../utils/hazard.util.js", () => ({
  buildHazardInclude: vi.fn(),
  buildHazardsOrderByClauseRaw: vi.fn(),
  buildHazardsWhereClause: vi.fn(),
  buildHazardsWhereClauseRaw: vi.fn(),
  mapAiReviewStatus: (v: unknown) => (v === "accepted" ? "accepted" : v === "rejected" ? "rejected" : "pending"),
  withPublicCoords: vi.fn(),
  toPublicReporter: vi.fn(),
}));
vi.mock("../services/ai-prompt.service.js", () => ({
  getPromptById: vi.fn(async () => ({ content: "prompt", model: "model" })),
}));
vi.mock("../services/configuration.service.js", () => ({
  getAIPromptConfiguration: vi.fn(async () => ({
    userReportedAlertReviewAndSummarizePromptId: { infoPromptId: "p-info" },
  })),
}));
vi.mock("../services/ai.service.js", () => ({ executePrompt: vi.fn() }));
vi.mock("../services/hazard_cache.service.js", () => ({
  hazardContentHash: vi.fn(),
  getCachedAISummary: vi.fn(),
  cacheAISummary: vi.fn(),
}));
vi.mock("../utils/config.js", () => ({ config: { env: "test", ai: {} } }));
vi.mock("../services/hazard_category.service.js", () => ({ MainCategoryId: {}, SubCategoryId: {} }));
vi.mock("../services/ingestion.service.js", () => ({ ExternalSourceId: {} }));
vi.mock("../utils/air_quality_template.util.js", () => ({ getDeterministicAirQualityContent: vi.fn() }));
vi.mock("../utils/gdacs_template.util.js", () => ({ getDeterministicGdacsContent: vi.fn() }));

// xpPoints.controller dependencies
vi.mock("../services/xp_ledger.service.js", () => ({ getXpSummary: vi.fn() }));
vi.mock("../services/badge.service.js", () => ({ getBadgesFor: vi.fn() }));

import prisma from "../utils/prisma_client.util.js";
import { executePrompt } from "../services/ai.service.js";
import { getSeverityBandFromAWSCompliantSeverity } from "../utils/ingestion.severity.util.js";
import { reviewHazard } from "../services/hazard.service.js";
import { createHazardWebhookBodySchema } from "../validators/webhook.validator.js";
import { familyScheduledCheckInSchema } from "../validators/family.validator.js";
import { ASK_ALRT_SYSTEM_PROMPT } from "../services/ask_alrt/system_prompt.js";
import { getXpLeaderboard } from "../controllers/xpPoints.controller.js";

const here = path.dirname(fileURLToPath(import.meta.url));

describe("AWS severity to band", () => {
  it("maps Advice to monitor, Watch and Act to action, Emergency to critical", () => {
    expect(getSeverityBandFromAWSCompliantSeverity("advice" as any)).toBe("monitor");
    expect(getSeverityBandFromAWSCompliantSeverity("watchAndAct" as any)).toBe("action");
    expect(getSeverityBandFromAWSCompliantSeverity("emergency" as any)).toBe("critical");
  });
});

describe("reviewHazard never carries a call to action", () => {
  it("returns callsToAction: [] even when the model supplies some", async () => {
    (executePrompt as any).mockResolvedValue(
      JSON.stringify({
        reviewStatus: "accepted",
        title: "Smoke near the oval",
        summary: "Someone saw smoke.",
        callsToAction: ["Evacuate now", "Call 000"],
        confidence: "medium",
      }),
    );

    const review = await reviewHazard({
      title: "Smoke",
      description: "Smoke near the oval",
      category: { id: "fire", name: "Fire" } as any,
      latitude: -31.9,
      longitude: 115.8,
      severityBand: "info" as any,
    });

    expect(review.callsToAction).toEqual([]);
    expect(review.reviewStatus).toBe("accepted"); // still the model's own decision
  });
});

describe("webhook validator strips client classification", () => {
  it("drops severity, severityBand and isAwsCompliant", () => {
    const parsed = createHazardWebhookBodySchema.parse({
      description: "Bushfire emergency warning for Katoomba",
      sourceId: "rfs",
      severity: "advice",
      severityBand: "critical",
      isAwsCompliant: true,
    });
    expect(parsed).not.toHaveProperty("severity");
    expect(parsed).not.toHaveProperty("severityBand");
    expect(parsed).not.toHaveProperty("isAwsCompliant");
    expect(parsed.sourceId).toBe("rfs");
  });
});

describe("scheduled check-in validator", () => {
  it("accepts an IANA timezone or a UTC offset in minutes (the service refuses neither)", () => {
    // Neither field is required at the validator: the service returns 400
    // when neither is usable, so an older client gets a clear message.
    expect(familyScheduledCheckInSchema.safeParse({ timeOfDay: "08:00" }).success).toBe(true);
    expect(
      familyScheduledCheckInSchema.safeParse({ timeOfDay: "08:00", timezone: "Australia/Perth" }).success,
    ).toBe(true);
    expect(
      familyScheduledCheckInSchema.safeParse({ timeOfDay: "08:00", utcOffsetMinutes: 480 }).success,
    ).toBe(true);
  });

  it("rejects an out-of-range or fractional utcOffsetMinutes", () => {
    expect(
      familyScheduledCheckInSchema.safeParse({ timeOfDay: "08:00", utcOffsetMinutes: 900 }).success,
    ).toBe(false);
    expect(
      familyScheduledCheckInSchema.safeParse({ timeOfDay: "08:00", utcOffsetMinutes: -841 }).success,
    ).toBe(false);
    expect(
      familyScheduledCheckInSchema.safeParse({ timeOfDay: "08:00", utcOffsetMinutes: 12.5 }).success,
    ).toBe(false);
  });
});

describe("Ask ALRT copy never hard-codes 000", () => {
  it("system prompt points to the local emergency number and names no number as a fallback", () => {
    expect(ASK_ALRT_SYSTEM_PROMPT).not.toMatch(/\b000\b/);
    expect(ASK_ALRT_SYSTEM_PROMPT).toContain("call their local emergency number and, when travelling");
    expect(ASK_ALRT_SYSTEM_PROMPT).not.toContain("112 works on most mobiles");
  });

  it("seed entries never say 000", () => {
    const raw = readFileSync(path.join(here, "../constants/ask_alrt_seed_entries.json"), "utf8");
    const entries = JSON.parse(raw) as Array<{ answer: string }>;
    const list = Array.isArray(entries) ? entries : Object.values(entries as object).flat();
    for (const e of list as Array<{ answer?: string }>) {
      if (typeof e?.answer === "string") expect(e.answer).not.toMatch(/\b000\b/);
    }
  });
});

describe("leaderboard: other rows carry rank and points only", () => {
  beforeEach(() => vi.clearAllMocks());

  it("nulls reliabilityScore and hazardsReported for everyone but the caller", async () => {
    (prisma.user.findMany as any).mockResolvedValue([
      { id: "me", name: "Sarah", xpPoints: 120, reliabilityScore: 0.9, _count: { hazardsReported: 7 } },
      { id: "other", name: "Bob", xpPoints: 80, reliabilityScore: 0.4, _count: { hazardsReported: 3 } },
    ]);
    const json = vi.fn();
    const res = { userId: "me", status: vi.fn(() => ({ json })) } as any;

    await getXpLeaderboard({ query: {} } as any, res, vi.fn());

    const { leaderboard } = json.mock.calls[0]![0];
    expect(leaderboard[0]).toMatchObject({
      rank: 1,
      id: "me",
      isSelf: true,
      xpPoints: 120,
      reliabilityScore: 0.9,
      hazardsReported: 7,
    });
    expect(leaderboard[1]).toMatchObject({
      rank: 2,
      id: null,
      name: "Community member",
      isSelf: false,
      xpPoints: 80,
      reliabilityScore: null,
      hazardsReported: null,
    });
    expect(leaderboard[1]).not.toHaveProperty("email");
  });
});

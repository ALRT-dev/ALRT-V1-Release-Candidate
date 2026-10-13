/**
 * Tests for R-03: AI summarisation failure must NOT silently drop hazards.
 *
 * When the AI service is unavailable (network error, model error, malformed
 * response) the ingestion pipeline must still create the hazard using the raw
 * source data, so users are alerted even when AI enrichment is down.
 *
 * The test exercises `summarizeAndPostHazards` with a mocked `summarizeHazard`
 * that throws, and verifies the hazard row is created with the original title
 * and description.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks — must be set up before importing the module under test
// ---------------------------------------------------------------------------

// Mock @prisma/client enums (prisma generate hasn't run in test env)
vi.mock("@prisma/client", () => ({
  Prisma: { DbNull: null },
  HazardReviewStatus: { accepted: "accepted", rejected: "rejected", pending: "pending" },
  HazardSeverity: { unknown: "unknown", low: "low", medium: "medium", high: "high", extreme: "extreme" },
  HazardSeverityBand: { info: "info", action: "action", emergency: "emergency" },
}));

vi.mock('../services/alert_templates.service.js',()=>({getTemplateRegistry:vi.fn().mockResolvedValue({published:null})}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    hazard: {
      findUnique: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      upsert: vi.fn(),
      delete: vi.fn(),
    },
    hazardSource: {
      findUnique: vi.fn(),
    },
  },
}));

// Mock the hazard.service summarizeHazard — this is the function we want to
// make fail to test the fallback path.
vi.mock("../services/hazard.service.js", () => ({
  summarizeHazard: vi.fn(),
}));

// Mock notification services so they don't run
vi.mock("../services/notification.service.js", () => ({
  sendPushNotificationAboutNewHazard: vi.fn(),
}));

vi.mock("../services/socket.service.js", () => ({
  sendSocketEventAboutHazardToSubscribers: vi.fn(),
}));

vi.mock("../models/socket_event_types.js", () => ({
  SocketEvent: { newHazard: "newHazard", updateHazard: "updateHazard" },
}));

vi.mock("../models/http_error.js", () => ({
  HttpError: class HttpError extends Error {
    statusCode: number;
    constructor(statusCode: number, message: string) {
      super(message);
      this.statusCode = statusCode;
    }
  },
}));

vi.mock("../services/family_alert.service.js", () => ({
  notifyFamiliesAboutNewHazard: vi.fn(),
}));

// Mock hazard cache service
vi.mock("../services/hazard_cache.service.js", () => ({
  invalidateHazardListCaches: vi.fn(),
  hazardContentHash: vi.fn().mockReturnValue("mock-hash"),
  wasContentNotified: vi.fn().mockResolvedValue(false),
  markContentNotified: vi.fn().mockResolvedValue(undefined),
}));

// Mock confidence score service
vi.mock("../services/confidence_score.service.js", () => ({
  calculateConfidenceScore: vi.fn().mockReturnValue(75),
}));

// Mock hazard utilities
vi.mock("../utils/hazard.util.js", () => ({
  buildHazardInclude: vi.fn().mockReturnValue({}),
  getHazardExpiryDateFromSeverity: vi
    .fn()
    .mockReturnValue(new Date("2099-01-01")),
}));

// Mock ingestion utilities — just the converter
vi.mock("../utils/ingestion.util.js", () => ({
  convertHazardDataWithRelationsToCreateInput: vi
    .fn()
    .mockImplementation((data: any) => ({
      id: data.id,
      title: data.title,
      description: data.description,
      aiSummary: data.aiSummary,
      aiConfidence: data.aiConfidence,
      callsToAction: data.callsToAction,
      sourceContentHash: data.sourceContentHash,
      latitude: data.latitude,
      longitude: data.longitude,
      severity: data.severity,
      severityBand: data.severityBand,
      reviewStatus: data.reviewStatus,
      confidenceScore: data.confidenceScore,
      category: data.category
        ? { connect: { id: data.category.id } }
        : undefined,
      source: data.source
        ? { connect: { id: data.source.id } }
        : undefined,
    })),
  populateHazardWithGeocoding: vi.fn().mockImplementation((h: any) => h),
  cleanupGeocodingCache: vi.fn(),
  getGeocodingCacheSize: vi.fn().mockReturnValue(0),
  cleanupLocationExtractionCache: vi.fn(),
  getCachedLocationExtraction: vi.fn(),
  setCachedLocationExtraction: vi.fn(),
  parseGeoJsonToHazards: vi.fn().mockReturnValue([]),
  parseRSSFeedToHazards: vi.fn().mockReturnValue([]),
  parseCFSFeedToHazards: vi.fn().mockReturnValue([]),
  parseNTFireAndRescueToHazards: vi.fn().mockReturnValue([]),
  parseWAQIToHazards: vi.fn().mockReturnValue([]),
  parseUVIndexAndPollenToHazards: vi.fn().mockReturnValue([]),
  parseWAWarningsToHazards: vi.fn().mockReturnValue([]),
  parseWAIncidentsToHazards: vi.fn().mockReturnValue([]),
  parseUSGSEarthquakeToHazards: vi.fn().mockReturnValue([]),
  parseQLDTrafficToHazards: vi.fn().mockReturnValue([]),
  parseQLDParkToHazards: vi.fn().mockReturnValue([]),
  parseSESToHazards: vi.fn().mockReturnValue([]),
}));

// Mock AI service (processBatchWithRateLimit must execute items synchronously
// in tests so we can assert on the results)
vi.mock("../services/ai.service.js", () => ({
  executePrompt: vi.fn(),
  processBatchWithRateLimit: vi
    .fn()
    .mockImplementation(
      async <T, R>(
        items: T[],
        processor: (item: T) => Promise<R>,
      ): Promise<R[]> => {
        const results: R[] = [];
        for (const item of items) {
          results.push(await processor(item));
        }
        return results;
      },
    ),
}));

// Mock config
vi.mock("../utils/config.js", () => ({
  config: {
    ai: { provider: "bedrock" },
    nswTransportApi: { apiKey: "" },
    waqiApi: { apiToken: "" },
    qldTrafficApi: { apiKey: "" },
  },
}));

vi.mock("../services/configuration.service.js", () => ({
  getAIPromptConfiguration: vi.fn(),
}));

vi.mock("../services/ai-prompt.service.js", () => ({
  getPromptById: vi.fn(),
}));

vi.mock("../services/hazard_source.service.js", () => ({
  recordSourceFetchResult: vi.fn(),
}));

vi.mock("../services/hazard_category.service.js", () => ({
  getAllSubHazardCategories: vi.fn().mockResolvedValue([]),
  SubCategoryId: { airQualityAlert: "airQualityAlert", pollen: "pollen", uvAlert: "uvAlert", earthquake: "earthquake" },
  MainCategoryId: {},
}));

// ---------------------------------------------------------------------------
// Imports (after mocks)
// ---------------------------------------------------------------------------

import { summarizeAndPostHazards } from "../services/ingestion.service.js";
import { summarizeHazard } from "../services/hazard.service.js";
import prisma from "../utils/prisma_client.util.js";
import { SyncHazardsFromExternalSourceOption } from "../enums/sync_hazards_from_external_source_option_types.js";
import { getTemplateRegistry } from "../services/alert_templates.service.js";
import { defaultTemplatePack } from "../utils/alert_templates.util.js";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const makeHazardData = (overrides: Record<string, unknown> = {}) => ({
  id: "test-hazard-001",
  title: "Bushfire Warning - Blue Mountains",
  description: "A bushfire is burning in the Blue Mountains area near Katoomba.",
  latitude: -33.7,
  longitude: 150.3,
  locationName: "Blue Mountains, NSW",
  severity: "high",
  severityBand: "action",
  category: { id: "bushfire", name: "Bushfire" },
  source: { id: "rfs", name: "NSW RFS" },
  isAwsCompliant: false,
  ...overrides,
});

const fakeCreatedHazard = {
  id: "test-hazard-001",
  title: "Bushfire Warning - Blue Mountains",
  description: "A bushfire is burning in the Blue Mountains area near Katoomba.",
  aiSummary: "A bushfire is burning in the Blue Mountains area near Katoomba.",
  latitude: -33.7,
  longitude: 150.3,
  createdAt: new Date(),
  updatedAt: new Date(),
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe("summarizeAndPostHazards – AI fallback (R-03)", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(getTemplateRegistry).mockResolvedValue({published: null} as any);
    // Default: no existing hazard in DB
    (prisma.hazard.findUnique as any).mockResolvedValue(null);
    // Default: create succeeds
    (prisma.hazard.create as any).mockResolvedValue(fakeCreatedHazard);
  });

  it("creates the hazard with raw data when AI summarisation throws", async () => {
    // AI service throws
    (summarizeHazard as any).mockRejectedValue(
      new Error("Bedrock service unavailable"),
    );

    const result = await summarizeAndPostHazards({
      hazardDatas: [makeHazardData() as any],
      syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting,
      severityBandFilters: new Map(),
    });

    // Hazard must still be created — NOT silently dropped
    expect(result).toHaveLength(1);
    expect(prisma.hazard.create).toHaveBeenCalledOnce();

    // The create call should use the original title (no AI enrichment)
    const createArg = (prisma.hazard.create as any).mock.calls[0][0];
    expect(createArg.data.title).toBe(
      "Bushfire Warning - Blue Mountains",
    );
    // aiSummary should be the raw description (fallback)
    expect(createArg.data.aiSummary).toBe(
      "A bushfire is burning in the Blue Mountains area near Katoomba.",
    );
    // callsToAction should be empty (no AI to generate them)
    expect(createArg.data.callsToAction).toEqual([]);
    // confidence should be "low" (we couldn't verify with AI)
    expect(createArg.data.aiConfidence).toBe("low");
  });

  it("creates the hazard when AI returns malformed JSON", async () => {
    // Simulate the HttpError that summarizeHazard throws on bad JSON
    (summarizeHazard as any).mockRejectedValue(
      new Error("AI summarization failed: Invalid response format"),
    );

    const result = await summarizeAndPostHazards({
      hazardDatas: [makeHazardData() as any],
      syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting,
      severityBandFilters: new Map(),
    });

    expect(result).toHaveLength(1);
    expect(prisma.hazard.create).toHaveBeenCalledOnce();
  });
  it("does not let a webhook band filter discard active AWS Advice", async () => {
    vi.mocked(summarizeHazard).mockRejectedValue(new Error("Use source fallback"));
    const result = await summarizeAndPostHazards({
      hazardDatas: [makeHazardData({isAwsCompliant:true,severity:"advice",severityBand:"monitor"}) as any],
      syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting,
      severityBandFilters: new Map([["rfs",["critical"]]]) as any,
    });
    expect(result).toHaveLength(1);
    expect(prisma.hazard.create).toHaveBeenCalledOnce();
  });
  it("preserves complete source instructions and the last paragraph when published extraction fails", async () => {
    vi.mocked(getTemplateRegistry).mockResolvedValue({published: {version: 1, pack: defaultTemplatePack()}} as any);
    vi.mocked(summarizeHazard).mockRejectedValue(new Error("Model unavailable"));
    const instruction = "If you are in Example Town and it is safe, use Exit 112 via Route 911. Keep clear of Example Road.";
    const description = "First paragraph.\n\nSecond paragraph.\n\nThird paragraph.\n\nLast essential condition.";
    const result = await summarizeAndPostHazards({hazardDatas: [makeHazardData({description, sourceInstructionBlocks: [instruction]}) as any], syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting, severityBandFilters: new Map()});
    expect(result).toHaveLength(1);
    expect(vi.mocked(summarizeHazard).mock.calls[0]![0].sourceActions).toEqual([instruction]);
    const data = (prisma.hazard.create as any).mock.calls[0][0].data;
    expect(data.callsToAction).toEqual([`NSW RFS advises: ${instruction}`]);
    expect(data.aiSummary).toContain("Last essential condition.");
  });
  it("keeps processing when the template registry cannot be read", async () => {
    vi.mocked(getTemplateRegistry).mockRejectedValueOnce(new Error("Malformed registry"));
    vi.mocked(summarizeHazard).mockRejectedValue(new Error("Model unavailable"));
    const result = await summarizeAndPostHazards({hazardDatas: [makeHazardData() as any], syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting, severityBandFilters: new Map()});
    expect(result).toHaveLength(1);
  });
  it("processes an instruction-only update when the source description is unchanged", async () => {
    vi.mocked(getTemplateRegistry).mockResolvedValue({published: {version: 1, pack: defaultTemplatePack()}} as any);
    (prisma.hazard.findUnique as any).mockResolvedValue({...fakeCreatedHazard,sourceContentHash:"old-source-identity"});
    (prisma.hazard.upsert as any).mockResolvedValue(fakeCreatedHazard);
    vi.mocked(summarizeHazard).mockRejectedValue(new Error("Use safe fallback"));
    const result=await summarizeAndPostHazards({hazardDatas:[makeHazardData({sourceInstructionBlocks:["If you are in Example Town, follow the revised closure."]}) as any],syncOption:SyncHazardsFromExternalSourceOption.ignoreExisting,severityBandFilters:new Map(),calledFromWebhook:true});
    expect(result).toHaveLength(1);
    expect(prisma.hazard.upsert).toHaveBeenCalledOnce();
    const data=(prisma.hazard.upsert as any).mock.calls[0][0].update;
    expect(data.sourceContentHash).toBe("mock-hash");
    expect(data.callsToAction[0]).toContain("revised closure");
  });

  it("still uses AI data when summarisation succeeds", async () => {
    // AI works normally
    (summarizeHazard as any).mockResolvedValue({
      title: "AI-Enhanced Title",
      summary: "AI-generated summary of the bushfire.",
      callsToAction: ["Stay away from the area", "Follow RFS updates"],
      confidence: "high",
    });

    const result = await summarizeAndPostHazards({
      hazardDatas: [makeHazardData() as any],
      syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting,
      severityBandFilters: new Map(),
    });

    expect(result).toHaveLength(1);
    const createArg = (prisma.hazard.create as any).mock.calls[0][0];
    // Should use the AI-enhanced title
    expect(createArg.data.title).toBe("AI-Enhanced Title");
    expect(createArg.data.aiConfidence).toBe("high");
  });

  it("processes a mix of successful and failed AI calls", async () => {
    // First hazard: AI succeeds. Second hazard: AI fails.
    (summarizeHazard as any)
      .mockResolvedValueOnce({
        title: "AI Title",
        summary: "AI summary",
        callsToAction: ["Stay safe"],
        confidence: "high",
      })
      .mockRejectedValueOnce(new Error("Model timeout"));

    (prisma.hazard.create as any)
      .mockResolvedValueOnce({ ...fakeCreatedHazard, id: "h1" })
      .mockResolvedValueOnce({ ...fakeCreatedHazard, id: "h2" });

    const result = await summarizeAndPostHazards({
      hazardDatas: [
        makeHazardData({ id: "h1" }) as any,
        makeHazardData({
          id: "h2",
          title: "Flood Warning - Hawkesbury",
          description: "Moderate flooding expected.",
        }) as any,
      ],
      syncOption: SyncHazardsFromExternalSourceOption.ignoreExisting,
      severityBandFilters: new Map(),
    });

    // Both hazards must be created
    expect(result).toHaveLength(2);
    expect(prisma.hazard.create).toHaveBeenCalledTimes(2);
  });
});

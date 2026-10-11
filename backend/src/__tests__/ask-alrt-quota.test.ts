/**
 * Ask ALRT daily allowance (ruling 3 Oct 2026).
 *
 * Only an answer that goes to the AI model counts against the daily quota.
 * Library answers and emergency-number lookups never count and are never
 * refused with 429, even when the person is already at the cap. The refund
 * on a model failure is kept.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks (before importing the module under test)
// ---------------------------------------------------------------------------

vi.mock("@prisma/client", () => ({
  Prisma: { sql: (...args: unknown[]) => args },
}));

const usageRow = { aiCount: 0 };

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    askAlrtUsage: {
      findUnique: vi.fn(async () => usageRow),
    },
    askAlrtZone: {
      findUnique: vi.fn(async () => ({ timeZone: "UTC", setAt: new Date() })),
      upsert: vi.fn(),
    },
    askAlrtEntry: { findMany: vi.fn(async () => []) },
    askAlrtConfig: { findUnique: vi.fn(async () => null) },
    $queryRaw: vi.fn(),
    $executeRaw: vi.fn(async () => 1),
  },
}));

vi.mock("../services/entitlement.service.js", () => ({
  getPersonalAccess: vi.fn(async () => ({ plan: "free" })),
}));

vi.mock("../services/bedrock.service.js", () => ({
  executeChat: vi.fn(),
}));

vi.mock("../services/ask_alrt/matching.js", () => ({
  localAnswer: vi.fn(),
}));

vi.mock("../services/ask_alrt/rules.js", () => ({
  aliasesFromNames: vi.fn(() => ({})),
  contextBlock: vi.fn(() => ({ text: "", sentAlertIds: [] })),
  emergencyAnswer: vi.fn(() => "Call 110."),
  mergeEntries: vi.fn(() => []),
  readSavedEmergency: vi.fn(() => ({ numbers: {}, names: {} })),
  resolveEmergency: vi.fn(() => ({ table: {}, names: {} })),
}));

vi.mock("../services/ask_alrt/citations.js", () => ({
  extractUsedAlertIds: vi.fn((text: string) => ({ answer: text, usedAlertIds: [] })),
}));

vi.mock("../services/ask_alrt/system_prompt.js", () => ({
  ASK_ALRT_SYSTEM_PROMPT: "system",
}));

// ---------------------------------------------------------------------------
// Imports (after mocks)
// ---------------------------------------------------------------------------

import prisma from "../utils/prisma_client.util.js";
import { localAnswer } from "../services/ask_alrt/matching.js";
import { executeChat } from "../services/bedrock.service.js";
import { askAlrt, clearAskAlrtCache } from "../services/ask_alrt.service.js";
import { AI_DAILY_LIMIT, ASK_LIMIT_CODE } from "../services/ask_alrt/quota.js";

const USER = "user-1";

describe("Ask ALRT quota: only AI answers count", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    clearAskAlrtCache();
    usageRow.aiCount = AI_DAILY_LIMIT.free; // at the cap
    // consumeQuota: at the cap the INSERT ... WHERE aiCount < limit returns no row
    (prisma.$queryRaw as any).mockResolvedValue([]);
  });

  it("answers from the library at the cap, without counting or 429", async () => {
    (localAnswer as any).mockReturnValue({
      source: "library",
      entry: { id: "e1", answer: "Library answer." },
    });

    const res = await askAlrt(USER, { question: "What is ALRT?" } as any);

    expect(res.source).toBe("library");
    expect(res.answer).toBe("Library answer.");
    expect(res.remainingToday).toBe(0);
    expect(prisma.$queryRaw).not.toHaveBeenCalled(); // nothing consumed
  });

  it("answers an emergency-number lookup at the cap, without counting or 429", async () => {
    (localAnswer as any).mockReturnValue({
      source: "emergency_lookup",
      iso: "JP",
      answer: "In Japan call 110.",
    });

    const res = await askAlrt(USER, { question: "number in Japan" } as any);

    expect(res.source).toBe("emergency_lookup");
    expect(res.remainingToday).toBe(0);
    expect(prisma.$queryRaw).not.toHaveBeenCalled();
  });

  it("does not consume quota for a library answer below the cap", async () => {
    usageRow.aiCount = 1;
    (localAnswer as any).mockReturnValue({
      source: "library",
      entry: { id: "e1", answer: "Library answer." },
    });

    const res = await askAlrt(USER, { question: "What is ALRT?" } as any);

    expect(res.remainingToday).toBe(AI_DAILY_LIMIT.free - 1);
    expect(prisma.$queryRaw).not.toHaveBeenCalled();
  });

  it("refuses an AI answer at the cap with 429 and the ask_limit code", async () => {
    (localAnswer as any).mockReturnValue(null);

    await expect(askAlrt(USER, { question: "Something novel" } as any)).rejects.toMatchObject({
      statusCode: 429,
      code: ASK_LIMIT_CODE,
    });
    expect(prisma.$queryRaw).toHaveBeenCalledOnce();
    expect(executeChat).not.toHaveBeenCalled();
  });

  it("counts an AI answer and refunds it when the model fails", async () => {
    usageRow.aiCount = 0;
    (localAnswer as any).mockReturnValue(null);
    (prisma.$queryRaw as any).mockResolvedValue([{ aiCount: 1 }]);
    (executeChat as any).mockRejectedValue(new Error("model down"));

    await expect(askAlrt(USER, { question: "Something novel" } as any)).rejects.toMatchObject({
      statusCode: 502,
    });
    expect(prisma.$queryRaw).toHaveBeenCalledOnce(); // counted
    expect(prisma.$executeRaw).toHaveBeenCalledOnce(); // refunded
  });

  it("counts a successful AI answer once", async () => {
    usageRow.aiCount = 0;
    (localAnswer as any).mockReturnValue(null);
    (prisma.$queryRaw as any).mockResolvedValue([{ aiCount: 1 }]);
    (executeChat as any).mockResolvedValue({ refused: false, text: "AI says hi" });

    const res = await askAlrt(USER, { question: "Something novel" } as any);

    expect(res.source).toBe("ai");
    expect(res.remainingToday).toBe(AI_DAILY_LIMIT.free - 1);
    expect(prisma.$queryRaw).toHaveBeenCalledOnce();
    expect(prisma.$executeRaw).not.toHaveBeenCalled();
  });
});

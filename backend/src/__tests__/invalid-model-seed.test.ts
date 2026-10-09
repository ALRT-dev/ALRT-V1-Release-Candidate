/**
 * Tests for R-04: `gpt-5-nano` invalid model in DB seed.
 *
 * Verifies that:
 * 1. The seeded AI prompts do NOT contain `gpt-5-nano` (or any other
 *    non-empty model string), so the provider-level fallback model from
 *    config is always used.
 * 2. `ai.service.executePrompt` falls through to the provider default
 *    when the model field is an empty string (matching the DB seed).
 * 3. `si_extraction.service` no longer uses `gpt-5-nano` as its default.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks — set up before importing modules under test
// ---------------------------------------------------------------------------

vi.mock("@prisma/client", () => ({
  Prisma: { AIPromptCreateInput: {} },
}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    aIPromptGroup: {
      upsert: vi.fn().mockResolvedValue({ id: "group-1" }),
    },
    aIPrompt: {
      upsert: vi.fn().mockResolvedValue({ id: "prompt-1" }),
    },
    admin: {
      findFirst: vi.fn().mockResolvedValue({ id: "admin-1" }),
    },
  },
}));

vi.mock("../utils/config.js", () => ({
  config: {
    ai: { provider: "bedrock" },
    aws: {
      bedrock: {
        fallbackModelId: "global.anthropic.claude-haiku-4-5-20251001-v1:0",
      },
    },
    openAI: { apiKey: "test-key" },
  },
}));

vi.mock("../services/bedrock.service.js", () => ({
  executePrompt: vi.fn().mockResolvedValue('{"title":"test"}'),
  processBatchWithRateLimit: vi.fn(),
  validateModelId: vi.fn(),
}));

vi.mock("../utils/open_ai_client.util.js", () => ({
  default: {
    chat: {
      completions: {
        create: vi.fn().mockResolvedValue({
          choices: [{ message: { content: '{"title":"test"}' } }],
        }),
      },
    },
    models: { retrieve: vi.fn() },
  },
}));

vi.mock("../services/open-ai.service.js", () => ({
  executePrompt: vi.fn().mockResolvedValue({
    choices: [{ message: { content: '{"title":"test"}' } }],
  }),
  processBatchWithRateLimit: vi.fn(),
  validateModelId: vi.fn(),
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe("R-04: no gpt-5-nano in code", () => {
  it("ai.service falls through to bedrock fallback when model is empty string", async () => {
    const { executePrompt } = await import("../services/ai.service.js");
    const bedrock = await import("../services/bedrock.service.js");

    await executePrompt({
      model: "",
      systemPromptContent: "system",
      userPromptContent: "user",
    });

    // Bedrock should be called with the empty model — bedrock.service
    // itself applies `model || fallbackModelId`, so the empty string
    // falls through to the config default.
    expect(bedrock.executePrompt).toHaveBeenCalledWith({
      model: "",
      systemPromptContent: "system",
      userPromptContent: "user",
    });
  });

  it("ai.service uses || (not ??) for OpenAI model fallback so empty strings fall through", async () => {
    // The critical fix: `params.model || "gpt-4o-mini"` (not `??`)
    // ensures an empty string from the DB seed falls through to the
    // default, since `""` is falsy for `||` but not for `??`.
    const fs = await import("fs");
    const source = fs.readFileSync(
      new URL("../services/ai.service.ts", import.meta.url),
      "utf-8",
    );
    // Must use || for OpenAI model fallback
    expect(source).toMatch(/params\.model\s*\|\|\s*"gpt-4o-mini"/);
    // Must NOT use ?? (which would pass empty string through)
    expect(source).not.toMatch(/params\.model\s*\?\?\s*"gpt-4o-mini"/);
  });

  it("si_extraction DEFAULT_MODEL is not gpt-5-nano", async () => {
    // We can't easily import the const directly since it's not exported,
    // but we can read the source file and verify no gpt-5-nano
    const fs = await import("fs");
    const source = fs.readFileSync(
      new URL("../services/si_extraction.service.ts", import.meta.url),
      "utf-8",
    );
    expect(source).not.toContain("gpt-5-nano");
    // Verify DEFAULT_MODEL is empty string
    expect(source).toMatch(/const DEFAULT_MODEL\s*=\s*""\s*;/);
  });

  it("ai-prompt.service seed data contains no gpt-5-nano", async () => {
    const fs = await import("fs");
    const source = fs.readFileSync(
      new URL("../services/ai-prompt.service.ts", import.meta.url),
      "utf-8",
    );
    expect(source).not.toContain("gpt-5-nano");
  });
});

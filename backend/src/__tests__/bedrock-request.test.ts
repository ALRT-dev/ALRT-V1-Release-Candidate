import { describe, expect, it, vi } from "vitest";

const transport = vi.hoisted(() => ({ text: '{"facts":["Road closed."]}', requests: [] as Record<string, unknown>[] }));
vi.mock("../utils/config.js", () => ({ config: { aws: { bedrock: { fallbackModelId: "test-model" } } } }));
vi.mock("../utils/bedrock_client.util.js", async () => {
  const { BedrockRuntimeClient } = await import("@aws-sdk/client-bedrock-runtime");
  return { default: new BedrockRuntimeClient({
    region: "ap-southeast-2",
    credentials: { accessKeyId: "test-only", secretAccessKey: "test-only" },
    requestHandler: { handle: async (request: { body: string; path: string }) => {
      const body = JSON.parse(request.body);
      // Provider contract: each SystemContentBlock is a union with one member.
      for (const block of body.system ?? []) {
        if (Object.keys(block).length !== 1) throw new Error("Invalid SystemContentBlock union");
      }
      transport.requests.push({ ...body, path: request.path });
      return { response: { statusCode: 200, headers: { "content-type": "application/json" }, body: Buffer.from(JSON.stringify({
        output: { message: { role: "assistant", content: [{ text: transport.text }] } },
        stopReason: "end_turn", usage: { inputTokens: 1, outputTokens: 1, totalTokens: 2 }, metrics: { latencyMs: 1 },
      })) } };
    } },
  }) };
});

import { executePrompt } from "../services/bedrock.service.js";

describe("Bedrock extraction request", () => {
  it("sends an SDK-serializable union request and returns the extracted JSON", async () => {
    transport.text = '```json\n{"facts":["Road closed."]}\n```';
    transport.requests.length = 0;
    const result = await executePrompt({ systemPromptContent: "Extract source facts.", userPromptContent: "Road closed." });
    expect(JSON.parse(result)).toEqual({ facts: ["Road closed."] });
    expect(transport.requests).toHaveLength(1);
    expect(transport.requests[0]).toMatchObject({ path: "/model/test-model/converse", system: [{ text: "Extract source facts." }], messages: [{ role: "user", content: [{ text: "Road closed." }] }] });
  });

  it("surfaces an empty model response instead of treating it as extraction success", async () => {
    transport.text = "";
    await expect(executePrompt({ model: "explicit-model", systemPromptContent: "Extract.", userPromptContent: "Report." })).rejects.toThrow("Bedrock returned an empty response");
  });
});

import { describe, expect, test } from "vitest";
import { buildN8nTestWorkflow, testWebhookBody, webhookUrl } from "../lib/n8nWorkflow";

describe("n8n test workflow", () => {
  test("points at this environment's webhook and never contains a key", () => {
    expect(webhookUrl("https://api-test.safetyalrt.com/")).toBe(
      "https://api-test.safetyalrt.com/api/webhook/hazards",
    );
    const text = JSON.stringify(buildN8nTestWorkflow("https://api-test.safetyalrt.com"));
    expect(text).toContain("https://api-test.safetyalrt.com/api/webhook/hazards");
    expect(text).not.toMatch(/whk_/);
    expect(text).toContain("httpHeaderAuth");
  });

  test("sends one valid-looking test alert that expires in an hour", () => {
    const now = new Date("2026-10-06T00:00:00.000Z");
    const body = testWebhookBody(now);
    expect(body.hazards).toHaveLength(1);
    const alert = body.hazards[0]!;
    expect(alert.sourceId).toBe("gdacsGlobal");
    expect(alert.latitude).toBeGreaterThanOrEqual(-90);
    expect(alert.expiresAt).toBe("2026-10-06T01:00:00.000Z");
    expect(alert.description.length).toBeLessThanOrEqual(5000);
  });
});

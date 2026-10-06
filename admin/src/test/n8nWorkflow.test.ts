import { beforeEach, describe, expect, test } from "vitest";
import { buildN8nTestWorkflow, testWebhookBody, webhookUrl } from "../lib/n8nWorkflow";
import { TEST_SOURCE_ID, ensureTestSource } from "../lib/testSource";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";

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
    // The dedicated disposable test source, never a real feed's id.
    expect(alert.sourceId).toBe("test-dummy");
    expect(JSON.stringify(buildN8nTestWorkflow("https://x", now))).not.toContain("gdacsGlobal");
    expect(alert.latitude).toBeGreaterThanOrEqual(-90);
    expect(alert.expiresAt).toBe("2026-10-06T01:00:00.000Z");
    expect(alert.description.length).toBeLessThanOrEqual(5000);
  });
});

describe("ensureTestSource", () => {
  beforeEach(() => {
    localStorage.clear();
    saveTokens({ accessToken: "t", refreshToken: "r" });
  });

  test("creates the test-dummy source and ignores 'already exists'", async () => {
    const { calls } = installMockFetch([
      jsonRoute("/api/admin/hazard-sources", "POST", 400, {
        error: "A hazard source with this ID already exists",
      }),
    ]);
    await expect(ensureTestSource()).resolves.toBeUndefined();
    expect(calls[0]?.body).toMatchObject({ id: TEST_SOURCE_ID });
    expect(TEST_SOURCE_ID).toBe("test-dummy");
  });

  test("still fails on any other error", async () => {
    installMockFetch([jsonRoute("/api/admin/hazard-sources", "POST", 403, { error: "Forbidden" })]);
    await expect(ensureTestSource()).rejects.toThrow("Forbidden");
  });
});

import { describe, expect, it } from "vitest";
import { buildN8nAssuranceWorkflow, buildN8nFeedWorkflow } from "../lib/n8nWorkflow";

describe("n8n workflows for new sources and daily assurance", () => {
  it("fetches the feed as text and posts it unchanged to the source's feed webhook, never with the key", () => {
    const wf = buildN8nFeedWorkflow("https://api.example.com/", { id: "tasAlert", name: "TasALERT", feedUrl: "https://alert.tas.gov.au/data/cap-au.xml", scheduleMinutes: 5 });
    const send = wf.nodes.find((n) => n.name === "Send to ALRT")!;
    expect(send.parameters).toMatchObject({ url: "https://api.example.com/api/webhook/feeds/tasAlert", contentType: "raw", body: "={{ $json.feed }}", genericAuthType: "httpHeaderAuth" });
    expect(JSON.stringify(wf)).not.toMatch(/X-Webhook-Api-Key"\s*:\s*"[^"]/);
    expect(wf.connections["Fetch feed"].main[0][0].node).toBe("Send to ALRT");
  });
  it("runs assurance at 6am Perth and emails only when something failed", () => {
    const wf = buildN8nAssuranceWorkflow("https://api.example.com");
    expect(wf.settings.timezone).toBe("Australia/Perth");
    expect(wf.nodes[1]!.parameters).toMatchObject({ url: "https://api.example.com/api/webhook/assurance/run", method: "POST" });
    expect(wf.connections["Anything failed?"].main[1]).toEqual([]);
  });
});

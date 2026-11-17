/**
 * n8n connection helper for the Webhook Keys page.
 *
 * n8n pushes alerts into ALRT through POST /api/webhook/hazards using a
 * webhook API key (header X-Webhook-Api-Key). This builds a small n8n
 * workflow, ready to import, that sends ONE clearly labelled test alert to
 * THIS environment's backend. The key is never put in the file: in n8n you
 * create a "Header Auth" credential (name X-Webhook-Api-Key, value = the key
 * shown once when you create it here) and pick it on the HTTP Request node.
 *
 * The test alert is attached to the disposable TEST_SOURCE_ID source
 * (lib/testSource.ts), never a real feed's source id: a real id would make
 * the test alert look like an official alert from that agency. The webhook
 * rejects a sourceId with no HazardSource row, so the Webhook API Keys page
 * creates that source (ensureTestSource) before offering the download.
 */
import { TEST_SOURCE_ID } from "./testSource";

export const WEBHOOK_HEADER_NAME = "X-Webhook-Api-Key";
export const WEBHOOK_PATH = "/api/webhook/hazards";

export const webhookUrl = (apiBase: string): string =>
  `${apiBase.replace(/\/+$/, "")}${WEBHOOK_PATH}`;

/** The body n8n sends: one test alert on the dedicated test source. */
export const testWebhookBody = (now: Date = new Date()) => ({
  syncOption: "ignoreExisting",
  hazards: [
    {
      id: `n8n-test-${now.getTime()}`,
      title: "n8n test alert",
      description:
        "Test alert sent from n8n to check the connection. Safe to delete from the Alerts page.",
      locationName: "Perth WA",
      latitude: -31.9523,
      longitude: 115.8613,
      sourceId: TEST_SOURCE_ID,
      jurisdictionCountry: "AU",
      sourceInstructions: [],
      occurredAt: now.toISOString(),
      expiresAt: new Date(now.getTime() + 60 * 60 * 1000).toISOString(),
    },
  ],
});

export const buildN8nTestWorkflow = (apiBase: string, now: Date = new Date()) => ({
  name: "ALRT test: send one alert",
  nodes: [
    {
      parameters: {},
      id: "a1f0c1d2-0000-4000-8000-000000000001",
      name: "Run test",
      type: "n8n-nodes-base.manualTrigger",
      typeVersion: 1,
      position: [260, 300],
    },
    {
      parameters: {
        method: "POST",
        url: webhookUrl(apiBase),
        authentication: "genericCredentialType",
        genericAuthType: "httpHeaderAuth",
        sendBody: true,
        specifyBody: "json",
        jsonBody: JSON.stringify(testWebhookBody(now), null, 2),
        options: {},
      },
      id: "a1f0c1d2-0000-4000-8000-000000000002",
      name: "Send alert to ALRT",
      type: "n8n-nodes-base.httpRequest",
      typeVersion: 4.2,
      position: [520, 300],
    },
  ],
  connections: {
    "Run test": { main: [[{ node: "Send alert to ALRT", type: "main", index: 0 }]] },
  },
  settings: { executionOrder: "v1" },
});

/**
 * n8n workflow for a feed source (16 Nov 2026): on a schedule, fetch the
 * source's feed as text and post it, unchanged, to
 * POST /api/webhook/feeds/:sourceId. ALRT parses it with the adapter and
 * mapping saved on the source. The key stays in n8n's Header Auth credential.
 */
export const FEED_PATH = (sourceId: string) => `/api/webhook/feeds/${encodeURIComponent(sourceId)}`;

export const buildN8nFeedWorkflow = (apiBase: string, source: { id: string; name: string; feedUrl: string; scheduleMinutes?: number | null }) => ({
  name: `ALRT feed: ${source.name}`,
  nodes: [
    {
      parameters: { rule: { interval: [{ field: "minutes", minutesInterval: Math.max(1, source.scheduleMinutes ?? 10) }] } },
      id: "b2f0c1d2-0000-4000-8000-000000000001",
      name: "Every few minutes",
      type: "n8n-nodes-base.scheduleTrigger",
      typeVersion: 1.2,
      position: [260, 300],
    },
    {
      parameters: { url: source.feedUrl, options: { response: { response: { responseFormat: "text", outputPropertyName: "feed" } }, timeout: 20000 } },
      id: "b2f0c1d2-0000-4000-8000-000000000002",
      name: "Fetch feed",
      type: "n8n-nodes-base.httpRequest",
      typeVersion: 4.2,
      position: [520, 300],
    },
    {
      parameters: {
        method: "POST",
        url: `${apiBase.replace(/\/+$/, "")}${FEED_PATH(source.id)}`,
        authentication: "genericCredentialType",
        genericAuthType: "httpHeaderAuth",
        sendBody: true,
        contentType: "raw",
        rawContentType: "text/plain",
        body: "={{ $json.feed }}",
        options: { timeout: 60000 },
      },
      id: "b2f0c1d2-0000-4000-8000-000000000003",
      name: "Send to ALRT",
      type: "n8n-nodes-base.httpRequest",
      typeVersion: 4.2,
      position: [780, 300],
    },
  ],
  connections: {
    "Every few minutes": { main: [[{ node: "Fetch feed", type: "main", index: 0 }]] },
    "Fetch feed": { main: [[{ node: "Send to ALRT", type: "main", index: 0 }]] },
  },
  settings: { executionOrder: "v1" },
});

/**
 * The daily assurance workflow (D3): 6am Perth time, run the checks, and
 * email the owner only when something failed. Set the email node's
 * credential and address in n8n.
 */
export const buildN8nAssuranceWorkflow = (apiBase: string) => ({
  name: "ALRT daily assurance",
  nodes: [
    {
      parameters: { rule: { interval: [{ field: "cronExpression", expression: "0 6 * * *" }] } },
      id: "c3f0c1d2-0000-4000-8000-000000000001",
      name: "6am Perth",
      type: "n8n-nodes-base.scheduleTrigger",
      typeVersion: 1.2,
      position: [260, 300],
    },
    {
      parameters: {
        method: "POST",
        url: `${apiBase.replace(/\/+$/, "")}/api/webhook/assurance/run`,
        authentication: "genericCredentialType",
        genericAuthType: "httpHeaderAuth",
        options: { timeout: 120000 },
      },
      id: "c3f0c1d2-0000-4000-8000-000000000002",
      name: "Run checks",
      type: "n8n-nodes-base.httpRequest",
      typeVersion: 4.2,
      position: [520, 300],
    },
    {
      parameters: { conditions: { boolean: [{ value1: "={{ $json.notify }}", value2: true }] } },
      id: "c3f0c1d2-0000-4000-8000-000000000003",
      name: "Anything failed?",
      type: "n8n-nodes-base.if",
      typeVersion: 1,
      position: [780, 300],
    },
    {
      parameters: { subject: "={{ 'ALRT daily assurance: ' + $json.failures + ' failed' }}", text: "={{ $json.report }}", options: {} },
      id: "c3f0c1d2-0000-4000-8000-000000000004",
      name: "Email the owner",
      type: "n8n-nodes-base.emailSend",
      typeVersion: 2.1,
      position: [1040, 240],
    },
  ],
  connections: {
    "6am Perth": { main: [[{ node: "Run checks", type: "main", index: 0 }]] },
    "Run checks": { main: [[{ node: "Anything failed?", type: "main", index: 0 }]] },
    "Anything failed?": { main: [[{ node: "Email the owner", type: "main", index: 0 }], []] },
  },
  settings: { executionOrder: "v1", timezone: "Australia/Perth" },
});

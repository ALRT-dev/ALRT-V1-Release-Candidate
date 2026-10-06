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

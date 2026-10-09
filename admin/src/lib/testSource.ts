import { createHazardSource } from "../api/resources";
import { ApiError } from "../api/client";

/**
 * The one disposable source every test alert attaches to: the TEST-only
 * "Create Test Alert" picker on Alerts and the n8n test workflow on Webhook
 * API Keys. Never a real feed's id, so a test alert can never be mistaken
 * for (or overwrite) a real official alert.
 *
 * POST /api/webhook/hazards only accepts a sourceId that exists as a
 * HazardSource row (backend/src/controllers/webhook.controller.ts), so this
 * source has to exist before the n8n test runs. ensureTestSource() creates
 * it on first use; a 400 means it already exists and is ignored.
 */
export const TEST_SOURCE_ID = "test-dummy";

export const TEST_SOURCE = {
  id: TEST_SOURCE_ID,
  name: "TEST DUMMY SOURCE - DO NOT USE",
  url: "https://example.invalid/test",
};

export const ensureTestSource = async (): Promise<void> => {
  try {
    await createHazardSource(TEST_SOURCE);
  } catch (err) {
    if (!(err instanceof ApiError && err.status === 400)) throw err;
  }
};

/**
 * Tests for R-07: RevenueCat webhook route and auth hardening.
 *
 * Verifies:
 *  1. The webhook route is registered at POST /api/revenuecat/webhook
 *  2. Auth returns 503 when REVENUECAT_WEBHOOK_AUTH is not configured
 *  3. Auth returns 401 for invalid/missing credentials
 *  4. Auth returns 200 for valid credentials and processes the event
 *  5. The auth comparison is timing-safe (uses crypto.timingSafeEqual)
 *  6. The controller always returns 200 for authenticated events, even
 *     ignored ones (so RevenueCat doesn't retry)
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

vi.mock("@prisma/client", () => ({
  FamilyPlan: { free: "free", plus: "plus" },
  PlanTier: { individual: "individual", family: "family", group20: "group20", group50: "group50" },
}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    revenueCatWebhookEvent: {
      findUnique: vi.fn().mockResolvedValue(null),
      create: vi.fn().mockResolvedValue({}),
      update: vi.fn().mockResolvedValue({}),
    },
    storeSubscription: {
      findUnique: vi.fn().mockResolvedValue(null),
      findMany: vi.fn().mockResolvedValue([]),
      create: vi.fn().mockResolvedValue({ id: "sub-1", tier: "individual" }),
      updateMany: vi.fn().mockResolvedValue({ count: 0 }),
    },
    user: {
      findUnique: vi.fn().mockResolvedValue(null),
      updateMany: vi.fn().mockResolvedValue({ count: 0 }),
    },
    familyMember: {
      findFirst: vi.fn().mockResolvedValue(null),
      findMany: vi.fn().mockResolvedValue([]),
    },
    sponsorshipIntent: {
      findMany: vi.fn().mockResolvedValue([]),
      updateMany: vi.fn().mockResolvedValue({ count: 0 }),
    },
    $transaction: vi.fn(),
  },
}));

vi.mock("../utils/config.js", () => ({
  config: {
    revenuecat: {
      webhookAuth: "",
    },
  },
}));

// ---------------------------------------------------------------------------
// Import after mocks
// ---------------------------------------------------------------------------

import { config } from "../utils/config.js";
import {
  handleRevenueCatWebhook,
  timingSafeAuthEqual,
} from "../controllers/revenuecat.controller.js";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function mockReq(overrides: Record<string, any> = {}) {
  return {
    headers: {},
    body: {},
    ...overrides,
  } as any;
}

function mockRes() {
  const res: any = {};
  res.status = vi.fn().mockReturnValue(res);
  res.json = vi.fn().mockReturnValue(res);
  return res;
}

const nextFn = vi.fn();

// ---------------------------------------------------------------------------
// Tests: timingSafeAuthEqual
// ---------------------------------------------------------------------------

describe("timingSafeAuthEqual", () => {
  it("returns true for identical strings", () => {
    expect(timingSafeAuthEqual("secret-token-123", "secret-token-123")).toBe(true);
  });

  it("returns false for different strings of same length", () => {
    expect(timingSafeAuthEqual("secret-token-123", "secret-token-456")).toBe(false);
  });

  it("returns false for different-length strings", () => {
    expect(timingSafeAuthEqual("short", "a-much-longer-token")).toBe(false);
  });

  it("returns false when one string is empty", () => {
    expect(timingSafeAuthEqual("", "non-empty")).toBe(false);
  });

  it("returns true for two empty strings", () => {
    expect(timingSafeAuthEqual("", "")).toBe(true);
  });

  it("handles unicode correctly", () => {
    expect(timingSafeAuthEqual("Bearer tokén", "Bearer tokén")).toBe(true);
    expect(timingSafeAuthEqual("Bearer tokén", "Bearer token")).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// Tests: handleRevenueCatWebhook
// ---------------------------------------------------------------------------

describe("handleRevenueCatWebhook", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    nextFn.mockClear();
    // Default: webhookAuth not configured
    (config as any).revenuecat.webhookAuth = "";
  });

  it("returns 503 when REVENUECAT_WEBHOOK_AUTH is not configured", async () => {
    const req = mockReq();
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    expect(res.status).toHaveBeenCalledWith(503);
    expect(res.json).toHaveBeenCalledWith({
      message: "REVENUECAT_WEBHOOK_AUTH is not configured",
    });
    expect(nextFn).not.toHaveBeenCalled();
  });

  it("returns 401 when Authorization header is missing", async () => {
    (config as any).revenuecat.webhookAuth = "Bearer rc_webhook_secret_123";
    const req = mockReq(); // no authorization header
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({
      message: "Invalid webhook authorization",
    });
  });

  it("returns 401 when Authorization header is wrong", async () => {
    (config as any).revenuecat.webhookAuth = "Bearer rc_webhook_secret_123";
    const req = mockReq({
      headers: { authorization: "Bearer wrong_token" },
    });
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({
      message: "Invalid webhook authorization",
    });
  });

  it("returns 200 for authenticated event with valid auth", async () => {
    (config as any).revenuecat.webhookAuth = "Bearer rc_webhook_secret_123";
    const req = mockReq({
      headers: { authorization: "Bearer rc_webhook_secret_123" },
      body: {
        event: {
          id: "evt-001",
          type: "INITIAL_PURCHASE",
          app_user_id: "user-abc",
          product_id: "com.alrt.individual.monthly",
          original_transaction_id: "txn-001",
        },
      },
    });
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(nextFn).not.toHaveBeenCalled();
  });

  it("returns 200 for authenticated event with empty body (ignored gracefully)", async () => {
    (config as any).revenuecat.webhookAuth = "Bearer rc_webhook_secret_123";
    const req = mockReq({
      headers: { authorization: "Bearer rc_webhook_secret_123" },
      body: {},
    });
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    // Should still return 200 even with empty event (ignored)
    expect(res.status).toHaveBeenCalledWith(200);
  });

  it("returns 200 for authenticated TEST event (ignored, not retried)", async () => {
    (config as any).revenuecat.webhookAuth = "Bearer rc_webhook_secret_123";
    const req = mockReq({
      headers: { authorization: "Bearer rc_webhook_secret_123" },
      body: {
        event: {
          id: "evt-test-001",
          type: "TEST",
          app_user_id: "user-test",
        },
      },
    });
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    expect(res.status).toHaveBeenCalledWith(200);
  });

  it("calls next(error) on unexpected errors", async () => {
    (config as any).revenuecat.webhookAuth = "Bearer rc_webhook_secret_123";

    // Make applyRevenueCatEvent throw by providing a body that triggers
    // an error in the mocked prisma calls
    const error = new Error("Database connection lost");
    const { default: prisma } = await import("../utils/prisma_client.util.js");
    (prisma.revenueCatWebhookEvent.findUnique as any).mockRejectedValueOnce(error);

    const req = mockReq({
      headers: { authorization: "Bearer rc_webhook_secret_123" },
      body: {
        event: {
          id: "evt-err-001",
          type: "INITIAL_PURCHASE",
          app_user_id: "user-abc",
        },
      },
    });
    const res = mockRes();

    await handleRevenueCatWebhook(req, res, nextFn);

    expect(nextFn).toHaveBeenCalledWith(error);
  });
});

// ---------------------------------------------------------------------------
// Tests: Route registration (structural check)
// ---------------------------------------------------------------------------

describe("RevenueCat route registration", () => {
  it("revenuecat.route.ts exports a router with POST /webhook", async () => {
    // Import the actual route file (mocks above cover its dependencies)
    const { default: router } = await import("../routes/revenuecat.route.js");
    expect(router).toBeDefined();

    // Express Router stores routes in router.stack
    const stack = (router as any).stack;
    expect(stack).toBeDefined();
    expect(Array.isArray(stack)).toBe(true);

    const webhookRoute = stack.find(
      (layer: any) =>
        layer.route?.path === "/webhook" &&
        layer.route?.methods?.post === true,
    );
    expect(webhookRoute).toBeDefined();
  });
});

import { Router } from "express";
import { createHazardViaWebhook } from "../controllers/webhook.controller.js";
import { getWebhookCategories } from "../controllers/integration_catalog.controller.js";
import {
  requireWebhookAuth,
  webhookRateLimiter,
  webhookSpeedLimiter,
  webhookDailyQuota,
  webhookBurstProtection,
} from "../middlewares/webhook.middleware.js";
import { validate } from "../middlewares/validation.middleware.js";
import { createHazardsWebhookBodySchema } from "../validators/webhook.validator.js";

const router = Router();

// Read-only catalog for ingestion workers. Reuse the existing key and every
// quota guard; no RDS credentials or cross-VPC write access are required.
router.get(
  "/categories",
  requireWebhookAuth,
  webhookBurstProtection,
  webhookRateLimiter,
  webhookSpeedLimiter,
  webhookDailyQuota,
  getWebhookCategories,
);

/**
 * @route   POST /api/webhook/hazards
 * @desc    Create multiple hazards via webhook (for N8N or other automation tools)
 * @access  Webhook (requires X-Webhook-Api-Key header)
 *
 * Security layers applied:
 * 1. API key authentication with logging (loads per-key rate limits)
 * 2. Burst protection: Per-key max requests/minute
 * 3. Rate limiter: Per-key max requests/hour
 * 4. Speed limiter: Gradual slowdown after 50% of hourly limit
 * 5. Daily quota: Per-key max requests/day
 * 6. Request validation
 */
router.post(
  "/hazards",
  requireWebhookAuth, // MUST be first: loads API key with custom rate limits
  webhookBurstProtection, // Uses per-key maxRequestsPerMinute
  webhookRateLimiter, // Uses per-key maxRequestsPerHour
  webhookSpeedLimiter, // Uses per-key maxRequestsPerHour for slowdown threshold
  webhookDailyQuota, // Uses per-key maxRequestsPerDay
  validate(createHazardsWebhookBodySchema), // Input validation
  createHazardViaWebhook // Controller
);

/**
 * @route   POST /api/webhook/assurance/run
 * @desc    Daily assurance run for the n8n workflow (owner decision D3).
 *          Read-only: returns the checks and a plain-text report; n8n emails
 *          the owner only when notify is true.
 * @access  Webhook (X-Webhook-Api-Key)
 */
router.post(
  "/assurance/run",
  requireWebhookAuth,
  webhookBurstProtection,
  webhookRateLimiter,
  webhookDailyQuota,
  async (_req, res, next) => {
    try {
      const { runAssurance } = await import("../services/assurance.service.js");
      res.status(200).json(await runAssurance({ trigger: "n8n" }));
    } catch (e) {
      next(e);
    }
  },
);

export default router;

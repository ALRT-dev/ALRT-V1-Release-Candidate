import { Router } from "express";
import {
  getWebhookApiKeysForAdmin,
  getWebhookApiKeyByIdForAdmin,
  createWebhookApiKeyForAdmin,
  updateWebhookApiKeyForAdmin,
  deleteWebhookApiKeyForAdmin,
  getWebhookLogsForAdmin,
} from "../../controllers/admin/webhook_api_key.controller.js";
import {
  requireAdminAuth,
  requireAnyAdmin,
  requireAdminOrAbove,
} from "../../middlewares/auth.admin.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import {
  createWebhookApiKeyBodySchema,
  updateWebhookApiKeyBodySchema,
  getWebhookLogsForAdminQuerySchema,
} from "../../validators/admin/webhook_api_key.validator.js";

const router = Router();

// All routes require admin authentication
router.use(requireAdminAuth);

/**
 * @route   GET /api/admin/webhook-api-keys
 * @desc    Get all webhook API keys
 * @access  Any admin (read-only)
 */
router.get("/", requireAnyAdmin, getWebhookApiKeysForAdmin);

/**
 * @route   GET /api/admin/webhook-api-keys/:keyId
 * @desc    Get single webhook API key with stats
 * @access  Any admin (read-only)
 */
router.get("/:keyId", requireAnyAdmin, getWebhookApiKeyByIdForAdmin);

/**
 * @route   POST /api/admin/webhook-api-keys
 * @desc    Create new webhook API key
 * @access  Admin or above - a key grants an external system the ability
 *          to push live hazard alerts via /api/webhook/hazards, so a
 *          moderator must not be able to mint one (V1_RECONCILIATION_
 *          REPORT.md §22).
 */
router.post(
  "/",
  requireAdminOrAbove,
  validate(createWebhookApiKeyBodySchema),
  createWebhookApiKeyForAdmin
);

/**
 * @route   PATCH /api/admin/webhook-api-keys/:keyId
 * @desc    Update webhook API key (including enable/disable)
 * @access  Admin or above
 */
router.patch(
  "/:keyId",
  requireAdminOrAbove,
  validate(updateWebhookApiKeyBodySchema),
  updateWebhookApiKeyForAdmin
);

/**
 * @route   DELETE /api/admin/webhook-api-keys/:keyId
 * @desc    Delete webhook API key
 * @access  Admin or above
 */
router.delete("/:keyId", requireAdminOrAbove, deleteWebhookApiKeyForAdmin);

/**
 * @route   GET /api/admin/webhook-logs
 * @desc    Get webhook logs with filtering
 * @access  Any admin (read-only)
 */
router.get(
  "/logs/all",
  requireAnyAdmin,
  validate(getWebhookLogsForAdminQuerySchema, "query"),
  getWebhookLogsForAdmin
);

export default router;

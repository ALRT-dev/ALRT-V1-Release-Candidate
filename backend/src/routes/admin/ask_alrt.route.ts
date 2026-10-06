import { Router } from "express";
import {
  requireAdminAuth,
  requireAdminOrAbove,
  requireAnyAdmin,
} from "../../middlewares/auth.admin.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import { adminAskAlrtTestLimiter } from "../../middlewares/api_rate_limit.middleware.js";
import {
  deleteAskAlrtEntryController,
  importEmergencyDefaultsController,
  listAskAlrtEntriesController,
  listEmergencyNumbersController,
  askAlrtAdminController,
  getAskAlrtConfigController,
  setAskAlrtConfigController,
  removeEmergencyNumberController,
  saveAskAlrtEntryController,
  saveEmergencyNumberController,
} from "../../controllers/admin/ask_alrt.admin.controller.js";
import {
  askAlrtBodySchema,
  askAlrtConfigBodySchema,
  askAlrtEntryIdParamsSchema,
  emergencyNumberIsoParamsSchema,
  saveAskAlrtEntryBodySchema,
  saveEmergencyNumberBodySchema,
} from "../../validators/admin/ask_alrt_content.validator.js";

const adminAskAlrtRouter = Router();

adminAskAlrtRouter.use(requireAdminAuth);

/**
 * @route   POST /api/admin/ask-alrt/ask
 * @desc    Test page: asks the real Ask ALRT engine. Any admin role. Not counted
 *          against anyone's daily allowance, but limited to 50 per admin
 *          per hour (429 after that) so it can't run up the Bedrock bill.
 */
adminAskAlrtRouter.post(
  "/ask",
  requireAnyAdmin,
  adminAskAlrtTestLimiter,
  validate(askAlrtBodySchema),
  askAlrtAdminController,
);

/**
 * AI kill switch (AskAlrtConfig key "agent"). Off stops only the AI fallback;
 * library and emergency-number answers keep working. Env
 * ASK_ALRT_AI_ENABLED=false forces it off regardless (forcedOffByEnv).
 *
 * @route   GET /api/admin/ask-alrt/config   any admin   -> {enabled, forcedOffByEnv}
 * @route   PUT /api/admin/ask-alrt/config   admin or above, body {enabled}, audit-logged
 */
adminAskAlrtRouter.get("/config", requireAnyAdmin, getAskAlrtConfigController);
adminAskAlrtRouter.put(
  "/config",
  requireAdminOrAbove,
  validate(askAlrtConfigBodySchema),
  setAskAlrtConfigController,
);

/**
 * Answer library (database table AskAlrtEntry). Any admin role may read; writes
 * are admin or above, the same split as AI prompts. A change is live straight away.
 *
 * @route   GET    /api/admin/ask-alrt/entries
 * @route   PUT    /api/admin/ask-alrt/entries/:id   upsert (also how a built-in answer is customised or hidden)
 * @route   DELETE /api/admin/ask-alrt/entries/:id   remove a custom answer, or revert a built-in one
 */
adminAskAlrtRouter.get("/entries", requireAnyAdmin, listAskAlrtEntriesController);
adminAskAlrtRouter.put(
  "/entries/:id",
  requireAdminOrAbove,
  validate(askAlrtEntryIdParamsSchema, "params"),
  validate(saveAskAlrtEntryBodySchema),
  saveAskAlrtEntryController,
);
adminAskAlrtRouter.delete(
  "/entries/:id",
  requireAdminOrAbove,
  validate(askAlrtEntryIdParamsSchema, "params"),
  deleteAskAlrtEntryController,
);

/**
 * Emergency numbers (database, AskAlrtConfig).
 *
 * @route   GET    /api/admin/ask-alrt/emergency-numbers
 * @route   POST   /api/admin/ask-alrt/emergency-numbers/import-defaults
 * @route   PUT    /api/admin/ask-alrt/emergency-numbers   save one country
 * @route   DELETE /api/admin/ask-alrt/emergency-numbers/:iso   drop a saved edit
 */
adminAskAlrtRouter.get("/emergency-numbers", requireAnyAdmin, listEmergencyNumbersController);
adminAskAlrtRouter.post(
  "/emergency-numbers/import-defaults",
  requireAdminOrAbove,
  importEmergencyDefaultsController,
);
adminAskAlrtRouter.put(
  "/emergency-numbers",
  requireAdminOrAbove,
  validate(saveEmergencyNumberBodySchema),
  saveEmergencyNumberController,
);
adminAskAlrtRouter.delete(
  "/emergency-numbers/:iso",
  requireAdminOrAbove,
  validate(emergencyNumberIsoParamsSchema, "params"),
  removeEmergencyNumberController,
);

export default adminAskAlrtRouter;

import { Router } from "express";
import {
  requireAdminAuth,
  requireAdminOrAbove,
  requireAnyAdmin,
} from "../../middlewares/auth.admin.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import {
  deleteAskAlrtEntryController,
  importEmergencyDefaultsController,
  listAskAlrtEntriesController,
  listEmergencyNumbersController,
  askAlrtAdminController,
  removeEmergencyNumberController,
  saveAskAlrtEntryController,
  saveEmergencyNumberController,
} from "../../controllers/admin/ask_alrt.admin.controller.js";
import {
  askAlrtBodySchema,
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
 *          against anyone's daily allowance.
 */
adminAskAlrtRouter.post(
  "/ask",
  requireAnyAdmin,
  validate(askAlrtBodySchema),
  askAlrtAdminController,
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

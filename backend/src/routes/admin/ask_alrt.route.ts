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
  mintAdminFirebaseTokenController,
  removeEmergencyNumberController,
  saveAskAlrtEntryController,
  saveEmergencyNumberController,
} from "../../controllers/admin/ask_alrt.admin.controller.js";
import {
  askAlrtEntryIdParamsSchema,
  emergencyNumberIsoParamsSchema,
  saveAskAlrtEntryBodySchema,
  saveEmergencyNumberBodySchema,
} from "../../validators/admin/ask_alrt_content.validator.js";

const adminAskAlrtRouter = Router();

adminAskAlrtRouter.use(requireAdminAuth);

/**
 * @route   POST /api/admin/ask-alrt/firebase-token
 * @desc    Mints a Firebase custom token (uid `admin:<adminId>`) so the
 *          Admin Portal can call the existing askAlrt Cloud Function.
 *          Any authenticated admin role may use Ask ALRT.
 */
adminAskAlrtRouter.post(
  "/firebase-token",
  requireAnyAdmin,
  mintAdminFirebaseTokenController,
);

/**
 * Answer library (Firestore askAlrtEntries). Any admin role may read; writes
 * are admin or above, the same split as AI prompts. A change reaches the app's
 * assistant within about 5 minutes (the Cloud Function caches for 5).
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
 * Emergency numbers (Firestore askAlrtConfig/emergencyNumbers).
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

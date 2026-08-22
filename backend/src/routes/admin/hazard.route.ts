import { Router } from "express";
import {
  createHazardForAdmin,
  deleteHazardForAdmin,
  getHazardsForAdmin,
  getHazardSourcesForAdmin,
  reviewHazardForAdmin,
  syncHazardsFromExternalSourceForAdmin,
  updateHazardForAdmin,
} from "../../controllers/admin/hazard.controller.js";
import {
  requireAdminAuth,
  requireAnyAdmin,
  requireAdminOrAbove,
} from "../../middlewares/auth.admin.middleware.js";
import { validate } from "../../middlewares/validation.middleware.js";
import {
  createHazardForAdminBodySchema,
  getHazardsForAdminQuerySchema,
  reviewHazardForAdminBodySchema,
  reviewHazardForAdminParamsSchema,
  syncHazardsFromExternalSourceForAdminBodySchema,
  updateHazardForAdminBodySchema,
} from "../../validators/admin/hazard.validator.js";

const adminHazardRouter = Router();

// All routes below require admin authentication
adminHazardRouter.use(requireAdminAuth);

// Read operations - any admin role. getHazardsForAdminQuerySchema was
// previously only used as a TS type annotation on req.query, never actually
// run - so its pageSize cap (and every other field) was unenforced. Wiring
// validate() here is what actually applies it, and coerces page/pageSize to
// real numbers before they reach the raw-SQL LIMIT/OFFSET parameters.
adminHazardRouter.get(
  "/",
  requireAnyAdmin,
  validate(getHazardsForAdminQuerySchema, "query"),
  getHazardsForAdmin
);
adminHazardRouter.get("/sources", requireAnyAdmin, getHazardSourcesForAdmin);

// Write operations - admin or above
adminHazardRouter.post(
  "/",
  requireAdminOrAbove,
  validate(createHazardForAdminBodySchema),
  createHazardForAdmin
);
adminHazardRouter.put(
  "/:hazardId",
  requireAdminOrAbove,
  validate(updateHazardForAdminBodySchema),
  updateHazardForAdmin
);

// Community-report moderation decision (approve/reject) - a moderator's
// core function, so gated at requireAnyAdmin like other read/moderation
// work rather than requireAdminOrAbove like the general hazard writes above.
adminHazardRouter.patch(
  "/:hazardId/review",
  requireAnyAdmin,
  validate(reviewHazardForAdminParamsSchema, "params"),
  validate(reviewHazardForAdminBodySchema),
  reviewHazardForAdmin
);
adminHazardRouter.delete(
  "/:hazardId",
  requireAdminOrAbove,
  deleteHazardForAdmin
);
adminHazardRouter.post(
  "/sync-external",
  requireAdminOrAbove,
  validate(syncHazardsFromExternalSourceForAdminBodySchema),
  syncHazardsFromExternalSourceForAdmin
);

export default adminHazardRouter;

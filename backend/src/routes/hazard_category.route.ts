import { Router } from "express";
import {
  getAllHazardCategories,
  getAllParentHazardCategories,
  getAllSubHazardCategories,
} from "../controllers/hazard_category.controller.js";
import { requireAuth } from "../middlewares/auth.middleware.js";

const hazardCategoryRouter = Router();

hazardCategoryRouter.get("/", requireAuth, getAllHazardCategories);
hazardCategoryRouter.get("/parent", requireAuth, getAllParentHazardCategories);
hazardCategoryRouter.get("/sub", requireAuth, getAllSubHazardCategories);
// A public (requireAuth-only, no admin/role check) POST / used to be
// mounted here - any authenticated mobile-app user could create arbitrary
// hazard categories with zero body validation. The mobile app's generated
// REST client (frontend/lib/api/rest_client.g.dart) only ever calls the
// three GET routes above - this had no real caller. Category management
// is an admin-only capability with its own properly role-gated CRUD at
// backend/src/routes/admin/hazard_category.route.ts. Removed rather than
// fixed-in-place, since nothing legitimate depended on it. See
// V1_RECONCILIATION_REPORT.md §25.

export default hazardCategoryRouter;

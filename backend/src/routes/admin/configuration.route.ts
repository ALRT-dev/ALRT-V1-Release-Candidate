import { Router } from "express";
import {
  getAllConfigurations,
  getConfigurationById,
  createConfiguration,
  updateConfiguration,
  deleteConfiguration,
} from "../../controllers/admin/configuration.controller.js";
import {
  requireAdminAuth,
  requireAnyAdmin,
  requireAdminOrAbove,
} from "../../middlewares/auth.admin.middleware.js";

const adminConfigurationRouter = Router();

adminConfigurationRouter.use(requireAdminAuth);

// Read operations - any admin role. Writes are gated requireAdminOrAbove:
// Configuration rows wire the live AI prompt system, so a moderator may
// view but not edit them - see V1_RECONCILIATION_REPORT.md §22.
adminConfigurationRouter.get("/", requireAnyAdmin, getAllConfigurations);
adminConfigurationRouter.get("/:id", requireAnyAdmin, getConfigurationById);
adminConfigurationRouter.post(
  "/",
  requireAdminOrAbove,
  createConfiguration
);
adminConfigurationRouter.put(
  "/:id",
  requireAdminOrAbove,
  updateConfiguration
);
adminConfigurationRouter.delete(
  "/:id",
  requireAdminOrAbove,
  deleteConfiguration
);

export default adminConfigurationRouter;

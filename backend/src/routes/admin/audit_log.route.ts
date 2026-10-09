import { Router } from "express";
import { getAuditLog } from "../../controllers/admin/audit_log.controller.js";
import {
  requireAdminAuth,
  requireAdminOrAbove,
} from "../../middlewares/auth.admin.middleware.js";

const adminAuditLogRouter = Router();

adminAuditLogRouter.use(requireAdminAuth);

// Read-only, admin or super admin. Moderators do not see the audit trail.
adminAuditLogRouter.get("/", requireAdminOrAbove, getAuditLog);

export default adminAuditLogRouter;

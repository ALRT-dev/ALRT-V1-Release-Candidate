import type { NextFunction, Response } from "express";
import type { AdminRequest } from "../../middlewares/auth.admin.middleware.js";
import { HttpError } from "../../models/http_error.js";
import { AdminRole } from "@prisma/client";
import {
  createAdminAccount,
  getAdminProfile,
} from "../../services/user.admin.service.js";
import type { CreateAdminBody } from "../../validators/admin/user.validator.js";
import { recordAdminAuditEntry } from "../../services/admin_audit_log.service.js";

export const getAdminProfileController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.admin) {
      throw new HttpError(401, "Admin authentication required");
    }

    const adminProfile = await getAdminProfile(req.admin.id);

    res.status(200).json(adminProfile);
  } catch (error) {
    next(error);
  }
};

export const createAdmin = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    // Only super admins can create new admin accounts
    if (!req.admin || req.admin.role !== AdminRole.superAdmin) {
      throw new HttpError(403, "Only super admins can create admin accounts");
    }

    const adminData: CreateAdminBody = req.body;
    const newAdmin = await createAdminAccount(adminData);

    // Never log the password - only non-secret account metadata.
    await recordAdminAuditEntry({
      adminId: req.admin.id,
      action: "admin.create",
      targetType: "Admin",
      targetId: newAdmin.id,
      after: { email: newAdmin.email, role: newAdmin.role },
    });

    res.status(201).json({
      success: true,
      data: newAdmin,
      message: "Admin account created successfully",
    });
  } catch (error) {
    next(error);
  }
};

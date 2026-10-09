import type { Request, Response, NextFunction } from "express";
import { HttpError } from "../models/http_error.js";
import { verifyAdminAccessToken } from "../utils/jwt.admin.util.js";
import prisma from "../utils/prisma_client.util.js";
import { AdminRole } from "@prisma/client";

export interface AdminRequest extends Request {
  admin?: {
    id: string;
    email: string;
    role: AdminRole;
    sessionId?: string;
  };
}

/** Admin routes an admin with mustChangePassword=true may still call. */
const ROUTES_ALLOWED_BEFORE_PASSWORD_CHANGE: ReadonlySet<string> = new Set([
  "POST /api/admin/auth/change-password",
  "POST /api/admin/auth/logout",
  "GET /api/admin/users/me",
]);

const isAllowedBeforePasswordChange = (req: Request): boolean => {
  const path = (req.originalUrl ?? req.url ?? "").split("?")[0]!.replace(/\/+$/, "");
  return ROUTES_ALLOWED_BEFORE_PASSWORD_CHANGE.has(`${req.method.toUpperCase()} ${path}`);
};

/// Middleware to check for a valid admin JWT access token
export const requireAdminAuth = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new HttpError(401, "Authorization header missing or malformed");
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
      throw new HttpError(401, "Token missing");
    }

    const decoded = verifyAdminAccessToken(token);
    if (!decoded) {
      throw new HttpError(401, "Invalid or expired token");
    }

    // Verify admin exists and is active
    const admin = await prisma.admin.findUnique({
      where: { id: decoded.adminId },
      select: {
        id: true,
        email: true,
        role: true,
        isActive: true,
        lockedUntil: true,
        mustChangePassword: true,
      },
    });

    if (!admin) {
      throw new HttpError(401, "Admin account not found");
    }

    if (!admin.isActive) {
      throw new HttpError(403, "Admin account is disabled");
    }

    if (admin.lockedUntil && admin.lockedUntil > new Date()) {
      throw new HttpError(403, "Admin account is temporarily locked");
    }

    // A temporary password (new admin, or reset by a super admin) must be
    // changed before anything else: only change-password, the admin's own
    // profile and logout stay open until then. Enforced here, not just in
    // the portal, so a scripted client can't skip it.
    if (admin.mustChangePassword && !isAllowedBeforePasswordChange(req)) {
      throw new HttpError(
        403,
        "Change your temporary password before continuing",
        "PASSWORD_CHANGE_REQUIRED",
      );
    }

    req.admin = {
      id: admin.id,
      email: admin.email,
      role: admin.role,
      ...(decoded.sessionId && { sessionId: decoded.sessionId }),
    };

    next();
  } catch (error) {
    if (error instanceof HttpError) {
      next(error);
    } else {
      next(new HttpError(401, "Authentication failed"));
    }
  }
};

/// Middleware to check admin role permissions
export const requireAdminRole = (allowedRoles: string[]) => {
  return (req: AdminRequest, res: Response, next: NextFunction) => {
    if (!req.admin) {
      return next(new HttpError(401, "Admin authentication required"));
    }

    if (!allowedRoles.includes(req.admin.role)) {
      return next(new HttpError(403, "Insufficient permissions"));
    }

    next();
  };
};

/// Middleware shortcuts for common role checks
export const requireSuperAdmin = requireAdminRole([AdminRole.superAdmin]);
export const requireAdminOrAbove = requireAdminRole([
  AdminRole.superAdmin,
  AdminRole.admin,
]);
export const requireAnyAdmin = requireAdminRole([
  AdminRole.superAdmin,
  AdminRole.admin,
  AdminRole.moderator,
]);

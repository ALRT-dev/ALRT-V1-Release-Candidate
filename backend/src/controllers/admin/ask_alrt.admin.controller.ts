import type { NextFunction, Response } from "express";
import type { AdminRequest } from "../../middlewares/auth.admin.middleware.js";
import { firebaseAdmin } from "../../utils/firebase_admin_client.util.js";
import { HttpError } from "../../models/http_error.js";

/**
 * POST /api/admin/ask-alrt/firebase-token
 *
 * Mints a Firebase custom token for the signed-in admin, so the Admin
 * Portal can sign in to Firebase and call the existing `askAlrt` callable
 * (ALRT-dev/askalrt) - unchanged, never modified by this endpoint.
 *
 * Uses `admin:<adminId>` as the Firebase uid - a distinct namespace from
 * the mobile app's plain `User.id` uids (see
 * user.route.ts/firebase_token.controller.ts), so an admin session can
 * never collide with, or be mistaken for, a real app user's Firebase
 * identity. askAlrt itself only uses the uid for logging and a Firestore
 * quota/entitlement lookup - it never checks that the uid maps to a
 * User row, so this namespacing is safe without any change to that
 * function.
 */
export const mintAdminFirebaseTokenController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const adminId = req.admin?.id;
    if (!adminId) throw new HttpError(401, "Not authenticated");

    const token = await firebaseAdmin.auth().createCustomToken(`admin:${adminId}`);
    res.status(200).json({ token });
  } catch (error) {
    next(error);
  }
};

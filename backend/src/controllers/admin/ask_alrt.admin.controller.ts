import type { NextFunction, Response } from "express";
import type { AdminRequest } from "../../middlewares/auth.admin.middleware.js";
import { firebaseAdmin } from "../../utils/firebase_admin_client.util.js";
import { HttpError } from "../../models/http_error.js";
import { recordAdminAuditEntry } from "../../services/admin_audit_log.service.js";
import {
  deleteAskAlrtEntry,
  importEmergencyDefaults,
  listAskAlrtEntries,
  listEmergencyNumbers,
  removeEmergencyNumber,
  saveAskAlrtEntry,
  saveEmergencyNumber,
} from "../../services/ask_alrt_content.admin.service.js";

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

/**
 * Admin Portal editing for the Ask ALRT answer library and the emergency
 * number list. Thin handlers: rules live in utils/ask_alrt_content.util.ts,
 * Firestore access in services/ask_alrt_content.admin.service.ts. Every change
 * is written to the admin audit log (answer text and numbers are not secrets).
 */
const adminLabel = (req: AdminRequest): string => {
  if (!req.admin) throw new HttpError(401, "Not authenticated");
  return req.admin.email;
};

export const listAskAlrtEntriesController = async (
  _req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    res.status(200).json(await listAskAlrtEntries());
  } catch (error) {
    next(error);
  }
};

export const saveAskAlrtEntryController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const id = String(req.params["id"] ?? "");
    const { before, after } = await saveAskAlrtEntry(id, req.body, adminLabel(req));
    await recordAdminAuditEntry({
      adminId: req.admin?.id ?? null,
      action: before ? "ask_alrt_entry.update" : "ask_alrt_entry.create",
      targetType: "AskAlrtEntry",
      targetId: id,
      before: before ? { answer: before.answer, enabled: before.enabled, origin: before.origin } : null,
      after: { answer: after.answer, enabled: after.enabled, origin: after.origin },
    });
    res.status(200).json(after);
  } catch (error) {
    next(error);
  }
};

export const deleteAskAlrtEntryController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const id = String(req.params["id"] ?? "");
    const { before, revertedToBuiltIn } = await deleteAskAlrtEntry(id);
    await recordAdminAuditEntry({
      adminId: req.admin?.id ?? null,
      action: "ask_alrt_entry.delete",
      targetType: "AskAlrtEntry",
      targetId: id,
      before: before ? { answer: before.answer, enabled: before.enabled, origin: before.origin } : null,
    });
    res.status(200).json({ success: true, revertedToBuiltIn });
  } catch (error) {
    next(error);
  }
};

export const listEmergencyNumbersController = async (
  _req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    res.status(200).json(await listEmergencyNumbers());
  } catch (error) {
    next(error);
  }
};

export const saveEmergencyNumberController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { before, after } = await saveEmergencyNumber(req.body, adminLabel(req));
    await recordAdminAuditEntry({
      adminId: req.admin?.id ?? null,
      action: "emergency_number.save",
      targetType: "EmergencyNumber",
      targetId: after.iso,
      before: before ? { number: before.number, name: before.name } : null,
      after: { number: after.number, name: after.name },
    });
    res.status(200).json(after);
  } catch (error) {
    next(error);
  }
};

export const removeEmergencyNumberController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const iso = String(req.params["iso"] ?? "");
    const { before } = await removeEmergencyNumber(iso, adminLabel(req));
    await recordAdminAuditEntry({
      adminId: req.admin?.id ?? null,
      action: "emergency_number.remove",
      targetType: "EmergencyNumber",
      targetId: before.iso,
      before: { number: before.number, name: before.name },
    });
    res.status(200).json({ success: true });
  } catch (error) {
    next(error);
  }
};

export const importEmergencyDefaultsController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const result = await importEmergencyDefaults(adminLabel(req));
    await recordAdminAuditEntry({
      adminId: req.admin?.id ?? null,
      action: "emergency_number.import_defaults",
      targetType: "EmergencyNumber",
      after: { added: result.added },
    });
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

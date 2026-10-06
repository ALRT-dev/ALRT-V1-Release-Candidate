import type { NextFunction, Response } from "express";
import type { AdminRequest } from "../../middlewares/auth.admin.middleware.js";
import { HttpError } from "../../models/http_error.js";
import { recordAdminAuditEntry } from "../../services/admin_audit_log.service.js";
import {
  deleteAskAlrtEntry,
  getAskAlrtAiConfig,
  setAskAlrtAiConfig,
  importEmergencyDefaults,
  listAskAlrtEntries,
  listEmergencyNumbers,
  removeEmergencyNumber,
  saveAskAlrtEntry,
  saveEmergencyNumber,
} from "../../services/ask_alrt_content.admin.service.js";
import { askAlrt, type AskRequest } from "../../services/ask_alrt.service.js";

/**
 * POST /api/admin/ask-alrt/ask
 *
 * The Admin Portal's Ask ALRT test page. Runs the same engine as the app,
 * but is not counted against any person's daily allowance.
 */
export const askAlrtAdminController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    if (!req.admin) throw new HttpError(401, "Not authenticated");
    res.status(200).json(await askAlrt(null, req.body as AskRequest));
  } catch (error) {
    next(error);
  }
};

/**
 * Admin Portal editing for the Ask ALRT answer library and the emergency
 * number list. Thin handlers: rules live in utils/ask_alrt_content.util.ts,
 * Database access in services/ask_alrt_content.admin.service.ts. Every change
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

/** GET /api/admin/ask-alrt/config - the AI kill switch. Any admin role. */
export const getAskAlrtConfigController = async (
  _req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    res.status(200).json(await getAskAlrtAiConfig());
  } catch (error) {
    next(error);
  }
};

/** PUT /api/admin/ask-alrt/config {enabled} - admin or above, audit-logged. */
export const setAskAlrtConfigController = async (
  req: AdminRequest,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { enabled } = req.body as { enabled: boolean };
    const { before, after } = await setAskAlrtAiConfig(enabled, adminLabel(req));
    await recordAdminAuditEntry({
      adminId: req.admin?.id ?? null,
      action: "ask_alrt_config.update",
      targetType: "AskAlrtConfig",
      targetId: "agent",
      before: { enabled: before.enabled },
      after: { enabled: after.enabled },
    });
    res.status(200).json(after);
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

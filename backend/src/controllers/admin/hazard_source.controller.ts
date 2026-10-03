import type { NextFunction, Request, Response } from "express";
import type {
  GetHazardSourcesForAdminQuery,
  CreateHazardSourceForAdminBody,
  UpdateHazardSourceForAdminBody,
  CreateHazardSourceLicenseForAdminBody,
  UpdateHazardSourceLicenseForAdminBody,
} from "../../validators/admin/hazard_source.validator.js";
import { HttpError } from "../../models/http_error.js";
import type { AdminRequest } from "../../middlewares/auth.admin.middleware.js";
import { recordAdminAuditEntry } from "../../services/admin_audit_log.service.js";
import {
  getHazardSources,
  getHazardSourceById,
  createHazardSource,
  updateHazardSource,
  deleteHazardSource,
  getHazardSourceLicenses,
  getHazardSourceLicenseById,
  createHazardSourceLicense,
  updateHazardSourceLicense,
  deleteHazardSourceLicense,
} from "../../services/hazard_source.service.js";

/**
 * Audit snapshot of a source's registry configuration. `secretRef` is a
 * reference name, not a secret, but is still recorded only as changed/not.
 */
const SOURCE_AUDIT_FIELDS = [
  "name",
  "url",
  "country",
  "region",
  "coverage",
  "sourceType",
  "authorityLevel",
  "feedUrl",
  "format",
  "accessMethod",
  "adapterKey",
  "scheduleMinutes",
  "warningTypes",
  "sourceNativeSeverity",
  "sourceNativeSymbol",
  "lifecycleStatus",
  "licenseId",
  "licensingNotes",
  "lastReviewedAt",
  "expiryReviewAt",
  "advisoryText",
] as const;

const diffSourceForAudit = (
  before: Record<string, unknown>,
  after: Record<string, unknown>,
) => {
  const changedBefore: Record<string, unknown> = {};
  const changedAfter: Record<string, unknown> = {};
  for (const key of SOURCE_AUDIT_FIELDS) {
    if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
      changedBefore[key] = before[key] ?? null;
      changedAfter[key] = after[key] ?? null;
    }
  }
  if (before["secretRef"] !== after["secretRef"]) {
    changedAfter["secretRefChanged"] = true;
  }
  return { before: changedBefore, after: changedAfter };
};

export const getHazardSourcesForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const {
      page = 1,
      pageSize = 20,
      searchString,
    }: GetHazardSourcesForAdminQuery = req.query;

    const sources = await getHazardSources({
      page,
      pageSize,
      ...(searchString && { searchString: searchString }),
    });

    res.status(200).json(sources);
  } catch (error) {
    next(error);
  }
};

export const getHazardSourceByIdForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { sourceId } = req.params;

    if (!sourceId) {
      throw new HttpError(400, "Source ID is required");
    }

    const source = await getHazardSourceById(sourceId);
    res.status(200).json(source);
  } catch (error) {
    next(error);
  }
};

export const createHazardSourceForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const body: CreateHazardSourceForAdminBody = req.body;

    const source = await createHazardSource(body);

    await recordAdminAuditEntry({
      adminId: (req as AdminRequest).admin?.id ?? null,
      action: "hazardSource.create",
      targetType: "HazardSource",
      targetId: source.id,
      after: { name: source.name, url: source.url },
    });

    res.status(201).json(source);
  } catch (error) {
    next(error);
  }
};

export const updateHazardSourceForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { sourceId } = req.params;
    const body: UpdateHazardSourceForAdminBody = req.body;

    if (!sourceId) {
      throw new HttpError(400, "Source ID is required");
    }

    const existing = await getHazardSourceById(sourceId);
    const source = await updateHazardSource(sourceId, body);

    const changes = diffSourceForAudit(
      existing as unknown as Record<string, unknown>,
      source as unknown as Record<string, unknown>,
    );
    if (Object.keys(changes.after).length > 0) {
      await recordAdminAuditEntry({
        adminId: (req as AdminRequest).admin?.id ?? null,
        action: "hazardSource.update",
        targetType: "HazardSource",
        targetId: sourceId,
        before: changes.before,
        after: changes.after,
      });
    }

    res.status(200).json(source);
  } catch (error) {
    next(error);
  }
};

export const deleteHazardSourceForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { sourceId } = req.params;

    if (!sourceId) {
      throw new HttpError(400, "Source ID is required");
    }

    const existing = await getHazardSourceById(sourceId);
    const result = await deleteHazardSource(sourceId);

    await recordAdminAuditEntry({
      adminId: (req as AdminRequest).admin?.id ?? null,
      action: "hazardSource.delete",
      targetType: "HazardSource",
      targetId: sourceId,
      before: { name: existing.name, url: existing.url },
    });

    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

export const getHazardSourceLicensesForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const licenses = await getHazardSourceLicenses();
    res.status(200).json(licenses);
  } catch (error) {
    next(error);
  }
};

export const getHazardSourceLicenseByIdForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { licenseId } = req.params;

    if (!licenseId) {
      throw new HttpError(400, "License ID is required");
    }

    const license = await getHazardSourceLicenseById(licenseId);
    res.status(200).json(license);
  } catch (error) {
    next(error);
  }
};

export const createHazardSourceLicenseForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const body: CreateHazardSourceLicenseForAdminBody = req.body;

    const license = await createHazardSourceLicense(body);
    res.status(201).json(license);
  } catch (error) {
    next(error);
  }
};

export const updateHazardSourceLicenseForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { licenseId } = req.params;
    const body: UpdateHazardSourceLicenseForAdminBody = req.body;

    if (!licenseId) {
      throw new HttpError(400, "License ID is required");
    }

    const license = await updateHazardSourceLicense(licenseId, body);
    res.status(200).json(license);
  } catch (error) {
    next(error);
  }
};

export const deleteHazardSourceLicenseForAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { licenseId } = req.params;

    if (!licenseId) {
      throw new HttpError(400, "License ID is required");
    }

    const result = await deleteHazardSourceLicense(licenseId);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

import type { Prisma } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";

/**
 * Minimum viable admin action audit trail (Stage 7B, §22.4/§22.8 of
 * V1_RECONCILIATION_REPORT.md). A single shared helper, not a framework —
 * call it from a mutating admin controller with whatever before/after
 * snapshot it already has cheaply available.
 *
 * Never pass a secret value (password, plaintext/hashed API key, OAuth or
 * service-account credential) in `before`/`after` — callers must redact
 * those fields themselves before calling this, recording only that the
 * resource changed.
 */
export interface RecordAdminAuditEntryInput {
  adminId: string | null;
  action: string;
  targetType: string;
  targetId?: string | null;
  reason?: string | null;
  before?: Record<string, unknown> | null;
  after?: Record<string, unknown> | null;
}

export const recordAdminAuditEntry = async (
  entry: RecordAdminAuditEntryInput,
): Promise<void> => {
  try {
    await prisma.adminAuditLog.create({
      data: {
        adminId: entry.adminId,
        action: entry.action,
        targetType: entry.targetType,
        targetId: entry.targetId ?? null,
        reason: entry.reason ?? null,
        ...(entry.before !== undefined && entry.before !== null
          ? { before: entry.before as Prisma.InputJsonValue }
          : {}),
        ...(entry.after !== undefined && entry.after !== null
          ? { after: entry.after as Prisma.InputJsonValue }
          : {}),
      },
    });
  } catch (error) {
    // Audit logging must never block or fail the admin action it's
    // describing - log and move on.
    console.error("Failed to record admin audit log entry:", error);
  }
};

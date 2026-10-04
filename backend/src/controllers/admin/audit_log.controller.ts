import type { NextFunction, Request, Response } from "express";
import z from "zod";
import prisma from "../../utils/prisma_client.util.js";

const auditLogQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional(),
  pageSize: z.coerce.number().int().min(1).max(100).optional(),
  targetType: z.string().max(100).optional(),
  targetId: z.string().max(100).optional(),
});

/**
 * Read-only view of AdminAuditLog rows, newest first. The rows themselves
 * are written by the mutating admin controllers and never contain secret
 * values (see admin_audit_log.service.ts).
 */
export const getAuditLog = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { page = 1, pageSize = 50, targetType, targetId } =
      auditLogQuerySchema.parse(req.query);

    const entries = await prisma.adminAuditLog.findMany({
      where: {
        ...(targetType && { targetType }),
        ...(targetId && { targetId }),
      },
      include: { admin: { select: { id: true, email: true, name: true } } },
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    res.status(200).json(entries);
  } catch (error) {
    next(error);
  }
};

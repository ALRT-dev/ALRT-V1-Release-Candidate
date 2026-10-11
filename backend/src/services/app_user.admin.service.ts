import { Prisma } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";

/**
 * Fields safe to expose to the admin console. Deliberately excludes
 * passwordHash and anything else that should never leave the backend.
 */
const APP_USER_SELECT = {
  id: true,
  email: true,
  name: true,
  locationName: true,
  latitude: true,
  longitude: true,
  xpPoints: true,
  reliabilityScore: true,
  streakDays: true,
  isOnboardingCompleted: true,
  lastActivityDate: true,
  deletionRequestedAt: true,
  scheduledDeletionAt: true,
  createdAt: true,
  updatedAt: true,
  _count: { select: { hazardsReported: true, devices: true } },
} satisfies Prisma.UserSelect;

const MAX_PAGE_SIZE = 100;

export const listAppUsers = async (params: {
  search?: string | undefined;
  page?: number | undefined;
  pageSize?: number | undefined;
}) => {
  const page = Math.max(1, params.page ?? 1);
  const pageSize = Math.min(MAX_PAGE_SIZE, Math.max(1, params.pageSize ?? 25));
  const search = params.search?.trim();

  const where: Prisma.UserWhereInput = search
    ? {
        OR: [
          { email: { contains: search, mode: "insensitive" } },
          { name: { contains: search, mode: "insensitive" } },
          { locationName: { contains: search, mode: "insensitive" } },
        ],
      }
    : {};

  const [total, users] = await Promise.all([
    prisma.user.count({ where }),
    prisma.user.findMany({
      where,
      select: APP_USER_SELECT,
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
  ]);

  return { total, page, pageSize, users };
};

export const getAppUser = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: APP_USER_SELECT,
  });

  if (!user) {
    throw new HttpError(404, "User not found");
  }

  return user;
};

/**
 * Only profile-ish fields are editable from the console. Email and password
 * are intentionally not editable here — changing them belongs in an account
 * recovery flow with its own verification, not a bulk admin screen.
 */
export const updateAppUser = async (
  userId: string,
  patch: {
    name?: string | null | undefined;
    locationName?: string | null | undefined;
    ownLocationSubscriptionRadiusKm?: number | undefined;
  },
) => {
  const existing = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true },
  });

  if (!existing) {
    throw new HttpError(404, "User not found");
  }

  return prisma.user.update({
    where: { id: userId },
    data: {
      ...(patch.name !== undefined ? { name: patch.name } : {}),
      ...(patch.locationName !== undefined
        ? { locationName: patch.locationName }
        : {}),
      ...(patch.ownLocationSubscriptionRadiusKm !== undefined
        ? {
            ownLocationSubscriptionRadiusKm:
              patch.ownLocationSubscriptionRadiusKm,
          }
        : {}),
    },
    select: APP_USER_SELECT,
  });
};

/**
 * Soft delete by default: flags the account for deletion after a grace period,
 * matching the existing deletionRequestedAt / scheduledDeletionAt columns.
 * Hard delete is a separate, deliberate action.
 */
export const requestAppUserDeletion = async (
  userId: string,
  graceDays = 30,
) => {
  const existing = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, deletionRequestedAt: true },
  });

  if (!existing) {
    throw new HttpError(404, "User not found");
  }

  const now = new Date();
  const scheduled = new Date(now.getTime() + graceDays * 24 * 60 * 60 * 1000);

  return prisma.user.update({
    where: { id: userId },
    data: { deletionRequestedAt: now, scheduledDeletionAt: scheduled },
    select: APP_USER_SELECT,
  });
};

export const cancelAppUserDeletion = async (userId: string) => {
  const existing = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true },
  });

  if (!existing) {
    throw new HttpError(404, "User not found");
  }

  return prisma.user.update({
    where: { id: userId },
    data: { deletionRequestedAt: null, scheduledDeletionAt: null },
    select: APP_USER_SELECT,
  });
};

export const listAdmins = async () =>
  prisma.admin.findMany({
    select: {
      id: true,
      email: true,
      name: true,
      role: true,
      isActive: true,
      mustChangePassword: true,
      lastLoginAt: true,
      lockedUntil: true,
      createdAt: true,
    },
    orderBy: { createdAt: "asc" },
  });

const ADMIN_SAFE_SELECT = {
  id: true,
  email: true,
  name: true,
  role: true,
  isActive: true,
  mustChangePassword: true,
  lastLoginAt: true,
  createdAt: true,
} as const;

export const setAdminActive = async (adminId: string, isActive: boolean) => {
  const existing = await prisma.admin.findUnique({
    where: { id: adminId },
    select: { id: true, role: true },
  });

  if (!existing) {
    throw new HttpError(404, "Admin not found");
  }

  // Guard against deactivating the last active super admin.
  if (!isActive && existing.role === "superAdmin") {
    const activeSuperAdminCount = await prisma.admin.count({
      where: { role: "superAdmin", isActive: true },
    });
    if (activeSuperAdminCount <= 1) {
      throw new HttpError(
        400,
        "Cannot deactivate the last active super admin",
      );
    }
  }

  return prisma.admin.update({
    where: { id: adminId },
    data: { isActive },
    select: ADMIN_SAFE_SELECT,
  });
};

/**
 * Update an admin's role and/or email. Super-admin only.
 * Guards against demoting the last active super admin.
 */
export const updateAdmin = async (
  adminId: string,
  patch: { role?: string; email?: string },
) => {
  const existing = await prisma.admin.findUnique({
    where: { id: adminId },
    select: { id: true, role: true, email: true },
  });

  if (!existing) {
    throw new HttpError(404, "Admin not found");
  }

  // Guard: demoting the last super admin would lock everyone out.
  if (
    patch.role &&
    patch.role !== "superAdmin" &&
    existing.role === "superAdmin"
  ) {
    const activeSuperAdminCount = await prisma.admin.count({
      where: { role: "superAdmin", isActive: true },
    });
    if (activeSuperAdminCount <= 1) {
      throw new HttpError(
        400,
        "Cannot demote the last active super admin",
      );
    }
  }

  // Check email uniqueness when changing.
  if (patch.email && patch.email !== existing.email) {
    const emailTaken = await prisma.admin.findUnique({
      where: { email: patch.email },
      select: { id: true },
    });
    if (emailTaken) {
      throw new HttpError(409, "An admin with this email already exists");
    }
  }

  return prisma.admin.update({
    where: { id: adminId },
    data: {
      ...(patch.role ? { role: patch.role as "superAdmin" | "admin" | "moderator" } : {}),
      ...(patch.email ? { email: patch.email } : {}),
    },
    select: ADMIN_SAFE_SELECT,
  });
};

/**
 * Force-resets an admin's password flag so they must change it at next login.
 * Super-admin only.
 */
export const forcePasswordReset = async (adminId: string) => {
  const existing = await prisma.admin.findUnique({
    where: { id: adminId },
    select: { id: true },
  });

  if (!existing) {
    throw new HttpError(404, "Admin not found");
  }

  return prisma.admin.update({
    where: { id: adminId },
    data: { mustChangePassword: true },
    select: ADMIN_SAFE_SELECT,
  });
};

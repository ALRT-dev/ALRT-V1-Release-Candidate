import { HazardReviewStatus } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";

// Queensland does not observe daylight saving, so Australia/Brisbane is a
// fixed UTC+10 offset year-round and the day boundary can be computed
// without a timezone library.
const BRISBANE_UTC_OFFSET_MS = 10 * 60 * 60 * 1000;

export const startOfBrisbaneDay = (now: Date): Date => {
  const shifted = new Date(now.getTime() + BRISBANE_UTC_OFFSET_MS);
  shifted.setUTCHours(0, 0, 0, 0);
  return new Date(shifted.getTime() - BRISBANE_UTC_OFFSET_MS);
};

const daysAgo = (days: number): Date =>
  new Date(Date.now() - days * 24 * 60 * 60 * 1000);

/**
 * A hazard counts as "active" when it has been accepted and has not expired.
 * Hazards with no expiry never lapse, so they stay active indefinitely.
 */
const activeHazardWhere = () => ({
  reviewStatus: HazardReviewStatus.accepted,
  OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
});

type NamedCount = { name: string; count: number };

const toNamedCounts = (
  rows: Array<Record<string, unknown>>,
  key: string,
): NamedCount[] =>
  rows
    .map((row) => ({
      name: (row[key] as string | null) ?? "Unknown",
      count:
        (row._count as { _all?: number } | undefined)?._all ??
        (row._count as unknown as number) ??
        0,
    }))
    .filter((row) => row.count > 0);

export const getDashboardStats = async () => {
  // "Today" matches the dashboard footer (Australia/Brisbane), not UTC.
  const todayStart = startOfBrisbaneDay(new Date());

  const [
    totalUsers,
    newUsersToday,
    newUsersLast7Days,
    dailyActiveUsers,
    weeklyActiveUsers,
    pendingDeletionUsers,
    activeHazards,
    pendingHazards,
    hazardsToday,
    totalCategories,
    totalSources,
    severityRows,
    hazardCityRows,
    userCityRows,
    platformRows,
    sourceRows,
  ] = await Promise.all([
    // Users who requested deletion are excluded, matching /api/admin/stats;
    // they are counted separately as pendingDeletion.
    prisma.user.count({ where: { deletionRequestedAt: null } }),
    prisma.user.count({ where: { createdAt: { gte: todayStart } } }),
    prisma.user.count({ where: { createdAt: { gte: daysAgo(7) } } }),
    prisma.user.count({ where: { lastActivityDate: { gte: todayStart } } }),
    prisma.user.count({ where: { lastActivityDate: { gte: daysAgo(7) } } }),
    prisma.user.count({ where: { deletionRequestedAt: { not: null } } }),
    prisma.hazard.count({ where: activeHazardWhere() }),
    prisma.hazard.count({
      where: { reviewStatus: HazardReviewStatus.pending },
    }),
    prisma.hazard.count({ where: { createdAt: { gte: todayStart } } }),
    prisma.hazardCategory.count(),
    prisma.hazardSource.count(),
    prisma.hazard.groupBy({
      by: ["severity"],
      _count: { _all: true },
      where: activeHazardWhere(),
    }),
    prisma.hazard.groupBy({
      by: ["locationName"],
      _count: { _all: true },
      where: { ...activeHazardWhere(), locationName: { not: null } },
      orderBy: { _count: { locationName: "desc" } },
      take: 5,
    }),
    prisma.user.groupBy({
      by: ["locationName"],
      _count: { _all: true },
      where: { locationName: { not: null } },
      orderBy: { _count: { locationName: "desc" } },
      take: 5,
    }),
    prisma.userDevice.groupBy({
      by: ["platform"],
      _count: { _all: true },
    }),
    prisma.hazard.groupBy({
      by: ["sourceId"],
      _count: { _all: true },
      where: { ...activeHazardWhere(), sourceId: { not: null } },
      orderBy: { _count: { sourceId: "desc" } },
      take: 10,
    }),
  ]);

  // Resolve source ids to names in one query rather than N.
  const sourceIds = sourceRows
    .map((row) => row.sourceId)
    .filter((id): id is string => Boolean(id));
  const sources = sourceIds.length
    ? await prisma.hazardSource.findMany({
        where: { id: { in: sourceIds } },
        select: { id: true, name: true },
      })
    : [];
  const sourceNameById = new Map(sources.map((s) => [s.id, s.name]));

  const platforms = toNamedCounts(platformRows, "platform");
  const normalisePlatform = (name: string) => {
    const lower = name.toLowerCase();
    if (lower.includes("ios") || lower.includes("apple")) return "iOS";
    if (lower.includes("android")) return "Android";
    return "Other";
  };
  const platformTotals = platforms.reduce<Record<string, number>>(
    (acc, row) => {
      const key = normalisePlatform(row.name);
      acc[key] = (acc[key] ?? 0) + row.count;
      return acc;
    },
    { iOS: 0, Android: 0, Other: 0 },
  );

  return {
    generatedAt: new Date().toISOString(),
    dayBoundary: {
      timezone: "Australia/Brisbane",
      dayStartedAt: todayStart.toISOString(),
    },
    users: {
      total: totalUsers,
      newToday: newUsersToday,
      newLast7Days: newUsersLast7Days,
      dailyActive: dailyActiveUsers,
      weeklyActive: weeklyActiveUsers,
      pendingDeletion: pendingDeletionUsers,
    },
    hazards: {
      active: activeHazards,
      pendingReview: pendingHazards,
      createdToday: hazardsToday,
      bySeverity: toNamedCounts(severityRows, "severity"),
      topCities: toNamedCounts(hazardCityRows, "locationName"),
      bySource: sourceRows.map((row) => ({
        name: row.sourceId
          ? (sourceNameById.get(row.sourceId) ?? "Unknown source")
          : "Unattributed",
        count: row._count._all,
      })),
    },
    platforms: {
      ios: platformTotals.iOS,
      android: platformTotals.Android,
      other: platformTotals.Other,
      raw: platforms,
    },
    geography: {
      topUserCities: toNamedCounts(userCityRows, "locationName"),
    },
    catalogue: {
      categories: totalCategories,
      sources: totalSources,
    },
  };
};

import { HazardReviewStatus } from "@prisma/client";
import prisma from "./prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { config } from "./config.js";

const EARTH_KM = 6371;
const distanceKm = (aLat: number, aLng: number, bLat: number, bLng: number) => {
  const rad = (d: number) => (d * Math.PI) / 180;
  const h =
    Math.sin(rad(bLat - aLat) / 2) ** 2 +
    Math.cos(rad(aLat)) * Math.cos(rad(bLat)) * Math.sin(rad(bLng - aLng) / 2) ** 2;
  return 2 * EARTH_KM * Math.asin(Math.sqrt(h));
};

/** Phone numbers, emails, number plates and street numbers in free text. */
const RAW_IDENTIFIER_PATTERNS: RegExp[] = [
  /(?:\+?\d[\s().-]?){8,}/, // phone numbers
  /[\w.+-]+@[\w-]+\.[\w.]+/, // emails
  /\b\d{1,5}[a-z]?\s+[A-Za-z]+(?:\s+[A-Za-z]+)?\s+(?:st|street|rd|road|ave|avenue|dr|drive|ln|lane|ct|court|cres|crescent|pl|place|way|tce|terrace|hwy|highway|blvd|boulevard)\b/i, // street address
  /\b(?:rego|plate|registration)\b[\s:]*[A-Z0-9]{3,8}\b/i, // number plates
  /https?:\/\/\S+|www\.\S+/i, // links
];

export const containsRawIdentifiers = (...texts: Array<string | undefined | null>) =>
  texts.some((t) => !!t && RAW_IDENTIFIER_PATTERNS.some((re) => re.test(t)));

const STREET_WORDS =
  /\b(st|street|rd|road|ave|avenue|dr|drive|ln|lane|ct|court|cres|crescent|pl|place|way|tce|terrace|hwy|highway|blvd|boulevard)\b/i;

/**
 * Community reports only ever carry a suburb-level place name: any part that
 * starts with a number or names a street is dropped.
 */
export const toSuburbOnlyLocationName = (name?: string | null): string => {
  if (!name) return "Nearby";
  const parts = name
    .split(",")
    .map((p) => p.trim())
    .filter((p) => p && !/^\d/.test(p) && !STREET_WORDS.test(p));
  return parts.slice(0, 2).join(", ") || "Nearby";
};

/**
 * Rejects a new community report that repeats a live one (same category,
 * within DUPLICATE_RADIUS) or exceeds the per-person posting limits.
 */
export const assertCanPostCommunityReport = async (params: {
  userId: string;
  categoryId: string;
  latitude: number;
  longitude: number;
}) => {
  const { userId, categoryId, latitude, longitude } = params;
  const now = new Date();

  const [lastHour, lastDay] = await Promise.all([
    prisma.hazard.count({
      where: { reportedById: userId, createdAt: { gt: new Date(now.getTime() - 3_600_000) } },
    }),
    prisma.hazard.count({
      where: { reportedById: userId, createdAt: { gt: new Date(now.getTime() - 86_400_000) } },
    }),
  ]);
  if (lastHour >= config.communityReportsPerHour || lastDay >= config.communityReportsPerDay) {
    throw new HttpError(429, "You've posted a lot of alerts recently. Please try again later.");
  }

  const box = (config.communityDuplicateRadiusMeters / 1000 / 111) * 1.5;
  const nearby = await prisma.hazard.findMany({
    where: {
      categoryId,
      reviewStatus: { in: [HazardReviewStatus.accepted, HazardReviewStatus.pending] },
      OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
      latitude: { gte: latitude - box, lte: latitude + box },
      longitude: { gte: longitude - box * 2, lte: longitude + box * 2 },
    },
    select: {
      id: true,
      title: true,
      locationName: true,
      createdAt: true,
      latitude: true,
      longitude: true,
      reviewStatus: true,
      category: { select: { name: true, parent: { select: { name: true } } } },
    },
    take: 50,
  });
  const existing = nearby.find(
    (h) =>
      h.latitude != null &&
      h.longitude != null &&
      distanceKm(latitude, longitude, h.latitude, h.longitude) * 1000 <=
        config.communityDuplicateRadiusMeters,
  );
  if (existing) {
    throw new HttpError(
      409,
      "There's already a live alert like this nearby. You can confirm it instead of posting again.",
      undefined,
      {
        existingHazardId: existing.id,
        existingTitle: existing.title,
        existingLocationName: existing.locationName,
        existingCategoryName: existing.category?.parent?.name ?? existing.category?.name,
        existingCreatedAt: existing.createdAt,
        // A pending alert can't be confirmed by others yet.
        canConfirm: existing.reviewStatus === HazardReviewStatus.accepted,
      },
    );
  }
};

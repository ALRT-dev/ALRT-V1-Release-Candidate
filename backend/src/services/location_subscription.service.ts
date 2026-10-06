import type { LocationSubscription } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { getPersonalAccess } from "./entitlement.service.js";

/**
 * Retrieves all location subscriptions for a user, optionally filtered by bounding box.
 *
 * @param userId - The ID of the user
 * @param northeastLat - The northeast latitude of the bounding box (optional)
 * @param northeastLng - The northeast longitude of the bounding box (optional)
 * @param southwestLat - The southwest latitude of the bounding box (optional)
 * @param southwestLng - The southwest longitude of the bounding box (optional)
 * @returns An array of LocationSubscription objects
 */
export const getUserLocationSubscriptions = async ({
  userId,
  northeastLat,
  northeastLng,
  southwestLat,
  southwestLng,
}: {
  userId: string;
  northeastLat?: number;
  northeastLng?: number;
  southwestLat?: number;
  southwestLng?: number;
}): Promise<(LocationSubscription & { isPaused: boolean })[]> => {
  const subscriptions = await prisma.locationSubscription.findMany({
    where: {
      userId: userId!,
      ...(northeastLat &&
        northeastLng &&
        southwestLat &&
        southwestLng && {
          northeastLat: { lte: northeastLat },
          northeastLng: { lte: northeastLng },
          southwestLat: { gte: southwestLat },
          southwestLng: { gte: southwestLng },
        }),
    },
    orderBy: [
      { isOwnLocation: "desc" }, // Own location subscription first
      { createdAt: "desc" },
    ],
  });

  // Paused places (Free account over its allowance) are listed, flagged,
  // and receive no alerts until Individual is active again.
  const paused = await pausedSavedPlaceIds([userId]);
  return subscriptions.map((s) => ({ ...s, isPaused: paused.has(s.id) }));
};

/**
 * Retrieves a single location subscription for a user by its ID.
 *
 * @param userId - The ID of the user
 * @param subscriptionId - The ID of the location subscription
 * @returns The LocationSubscription object or null if not found
 */
export const getSingleUserLocationSubscriptionById = async ({
  userId,
  subscriptionId,
}: {
  userId: string;
  subscriptionId: string;
}): Promise<LocationSubscription | null> => {
  const subscription = await prisma.locationSubscription.findFirst({
    where: {
      userId: userId!,
      id: subscriptionId,
    },
  });
  return subscription;
};

/**
 * Retrieves a single location subscription for a user that matches the given bounds.
 *
 * @param userId - The ID of the user
 * @param northeastLat - The northeast latitude of the subscription bounds
 * @param northeastLng - The northeast longitude of the subscription bounds
 * @param southwestLat - The southwest latitude of the subscription bounds
 * @param southwestLng - The southwest longitude of the subscription bounds
 * @returns The matching LocationSubscription or null if none found
 */
export const getSingleUserLocationSubscriptionByBounds = async ({
  userId,
  northeastLat,
  northeastLng,
  southwestLat,
  southwestLng,
}: {
  userId: string;
  northeastLat: number;
  northeastLng: number;
  southwestLat: number;
  southwestLng: number;
}): Promise<LocationSubscription | null> => {
  const subscription = await prisma.locationSubscription.findFirst({
    where: {
      userId: userId!,
      northeastLat: { lte: northeastLat },
      northeastLng: { lte: northeastLng },
      southwestLat: { gte: southwestLat },
      southwestLng: { gte: southwestLng },
    },
  });
  return subscription;
};

/**
 * Creates a new location subscription for the user.
 *
 * @param userId - The ID of the user
 * @param northeastLat - The northeast latitude of the subscription bounds
 * @param northeastLng - The northeast longitude of the subscription bounds
 * @param southwestLat - The southwest latitude of the subscription bounds
 * @param southwestLng - The southwest longitude of the subscription bounds
 * @param address - The address of the subscription (optional)
 * @param name - The name of the subscription (optional)
 * @returns The created LocationSubscription
 */
export const createUserLocationSubscription = async ({
  userId,
  northeastLat,
  northeastLng,
  southwestLat,
  southwestLng,
  address,
  name,
}: {
  userId: string;
  northeastLat: number;
  northeastLng: number;
  southwestLat: number;
  southwestLng: number;
  address?: string | undefined;
  name?: string | undefined;
}): Promise<LocationSubscription> => {
  // V1 access model: one extra saved place free, unlimited with personal
  // ALRT + Individual (or its trial) only. Group sponsorship never raises
  // it, for members or the payer. The own-location follow never counts.
  // Dormant until BILLING_ENABLED flips (everyone is unlimited before).
  //
  // Count and insert happen under a per-user transaction lock, so two
  // devices saving at once can't both slip under the limit.
  const personal = await getPersonalAccess(userId);
  return prisma.$transaction(async (tx) => {
    await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${`saved-places:${userId}`}))`;
    if (personal.extraSavedPlaces !== null) {
      const savedCount = await tx.locationSubscription.count({
        where: { userId, isOwnLocation: false },
      });
      if (savedCount >= personal.extraSavedPlaces) {
        throw new HttpError(
          402,
          `ALRT Free includes ${personal.extraSavedPlaces} saved place as well as where you are. ALRT + Individual gives you unlimited saved places.`,
          "SAVED_PLACE_LIMIT",
        );
      }
    }
    return tx.locationSubscription.create({
      data: {
        userId,
        northeastLat,
        northeastLng,
        southwestLat,
        southwestLng,
        ...(address && { address }),
        ...(name && { name }),
      },
    });
  });
};

/**
 * Saved places (never the own-location follow) that are paused for these
 * users: a Free account keeps its allowance of saved places and the rest
 * stop receiving alerts until Individual is active again. Nothing is
 * deleted, so the places come back on resubscribing.
 *
 * PROVISIONAL (open decision R04): which place stays active is not yet
 * decided; until it is, the OLDEST saved place stays active.
 */
export const pausedSavedPlaceIds = async (
  userIds: string[],
): Promise<Set<string>> => {
  const paused = new Set<string>();
  for (const userId of [...new Set(userIds)]) {
    const personal = await getPersonalAccess(userId);
    if (personal.extraSavedPlaces === null) continue;
    const places = await prisma.locationSubscription.findMany({
      where: { userId, isOwnLocation: false },
      orderBy: { createdAt: "asc" },
      select: { id: true },
    });
    for (const place of places.slice(personal.extraSavedPlaces)) {
      paused.add(place.id);
    }
  }
  return paused;
};

/**
 * Deletes a location subscription by its ID.
 *
 * @param subscriptionId - The ID of the location subscription to delete
 */
export const deleteUserLocationSubscription = async (
  subscriptionId: string,
): Promise<void> => {
  await prisma.locationSubscription.delete({
    where: { id: subscriptionId },
  });
};

/**
 * Creates or updates a user's own location subscription when their lat/lng is updated.
 * This creates a subscription area around the user's location for receiving hazard notifications.
 */
export const upsertUserOwnLocationSubscription = async ({
  userId,
  latitude,
  longitude,
  locationName,
}: {
  userId: string;
  latitude: number;
  longitude: number;
  locationName?: string;
}) => {
  // Fetch user's preferred radius for own location subscription
  const radiusResult = await prisma.user.findUnique({
    where: { id: userId },
    select: { ownLocationSubscriptionRadiusKm: true },
  });
  const radiusKm = radiusResult?.ownLocationSubscriptionRadiusKm ?? 5; // Default to 5km if not set

  // Calculate bounding box for the subscription area
  // The frontend calculates radius as distance from center to corner (diagonal)
  // For a square bounding box, corner distance = edge distance * √2
  // So we need to divide the radius by √2 to get the edge distance
  const earthRadiusKm = 6371.0;
  const edgeRadiusKm = radiusKm / Math.sqrt(2);

  // Convert latitude to radians
  const latRad = (latitude * Math.PI) / 180;

  // Calculate angular distance in radians
  const angularDistance = edgeRadiusKm / earthRadiusKm;

  // Calculate latitude delta (same in all directions)
  const latDelta = (angularDistance * 180) / Math.PI;

  // Calculate longitude delta (varies with latitude)
  const lngDelta = (angularDistance * 180) / Math.PI / Math.cos(latRad);

  const northeastLat = latitude + latDelta;
  const northeastLng = longitude + lngDelta;
  const southwestLat = latitude - latDelta;
  const southwestLng = longitude - lngDelta;

  const data = {
    northeastLat,
    northeastLng,
    southwestLat,
    southwestLng,
    name: locationName || "My Location",
    address: locationName || null,
  };

  // Check for an existing own-location row first, so a normal call (every
  // login/GPS update) updates in place instead of relying on the database
  // to reject a duplicate insert.
  const existing = await prisma.locationSubscription.findFirst({
    where: { userId, isOwnLocation: true },
  });
  if (existing) {
    return await prisma.locationSubscription.update({
      where: { id: existing.id },
      data,
    });
  }

  try {
    // No existing row found - create one. The partial unique index still
    // guards the race where two concurrent calls both pass the check above.
    return await prisma.locationSubscription.create({
      data: {
        userId,
        ...data,
        isOwnLocation: true,
      },
    });
  } catch (error: unknown) {
    // Unique constraint violation from the race above - find and update
    // whichever row won instead.
    if (
      error instanceof Error &&
      "code" in error &&
      (error as { code: string }).code === "P2002"
    ) {
      const winner = await prisma.locationSubscription.findFirst({
        where: { userId, isOwnLocation: true },
      });
      if (winner) {
        return await prisma.locationSubscription.update({
          where: { id: winner.id },
          data,
        });
      }
    }
    throw error;
  }
};

/**
 * Updates the user's own location subscription radius preference.
 *
 * @param userId - The ID of the user
 * @param radiusKm - The new radius in kilometers
 */
export const updateUserOwnLocationSubscriptionRadius = async (
  userId: string,
  radiusKm: number,
): Promise<LocationSubscription | null> => {
  const user = await prisma.user.update({
    where: { id: userId },
    data: { ownLocationSubscriptionRadiusKm: radiusKm },
    select: { latitude: true, longitude: true, locationName: true },
  });

  if (user.latitude !== null && user.longitude !== null) {
    // Also update the existing own location subscription to reflect new radius
    return await upsertUserOwnLocationSubscription({
      userId,
      latitude: user.latitude!,
      longitude: user.longitude!,
      locationName: user.locationName || "My Location",
    });
  }

  return null;
};

/**
 * Retrieves user IDs who have location subscriptions within the given bounds.
 *
 * @param northeastLat - The northeast latitude of the bounding box
 * @param northeastLng - The northeast longitude of the bounding box
 * @param southwestLat - The southwest latitude of the bounding box
 * @param southwestLng - The southwest longitude of the bounding box
 * @returns An array of unique user IDs
 */
export const getUserIdsForLocationSubscriptionBounds = async ({
  northeastLat,
  northeastLng,
  southwestLat,
  southwestLng,
}: {
  northeastLat: number;
  northeastLng: number;
  southwestLat: number;
  southwestLng: number;
}): Promise<string[]> => {
  const subscriptions = await prisma.locationSubscription.findMany({
    where: {
      northeastLat: { lte: northeastLat },
      northeastLng: { lte: northeastLng },
      southwestLat: { gte: southwestLat },
      southwestLng: { gte: southwestLng },
    },
    select: {
      userId: true,
    },
  });
  const userIds = subscriptions.map((sub) => sub.userId);
  return [...new Set(userIds)];
};

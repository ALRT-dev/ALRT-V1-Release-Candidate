import { HazardSeverity, type Hazard } from "@prisma/client";
import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";
import prisma from "../utils/prisma_client.util.js";
import { PushNotificationType } from "../models/push_notification_types.js";
import {
  getFormattedHazardSeverity,
  getFormattedHazardSeverityBand,
} from "../utils/hazard.util.js";
import { isUnderNotificationCooldown } from "./hazard_cache.service.js";
import { getCacheClient } from "../utils/cache_client.util.js";

/**
 * A function to get user push notification tokens of a specific user by their user ID.
 * Returns empty array if user has initiated account deletion (scheduledDeletionAt is set).
 */
const getUserPushNotificationTokens = async (
  userId: string
): Promise<string[]> => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        scheduledDeletionAt: true,
        devices: { select: { deviceToken: true } },
      },
    });

    if (!user) {
      console.log("User not found:", userId);
      return [];
    }

    // Don't send notifications to users who have initiated account deletion
    if (user.scheduledDeletionAt) {
      console.log(
        "User has initiated account deletion, skipping notifications:",
        userId
      );
      return [];
    }

    return user.devices.map((device) => device.deviceToken);
  } catch (error) {
    console.error(
      `Error fetching user push notification tokens for ${userId}:`,
      error
    );
    return [];
  }
};

/**
 * A function to get user push notification tokens subscribed to a hazard location and type.
 * Supports both point-based and bounding-box based hazard locations.
 * Uses bounding box intersection to match hazards with subscriptions.
 */
const getUserPushNotificationTokensSubscribedToHazard = async (
  hazard: Hazard
): Promise<string[]> => {
  try {
    const {
      latitude,
      longitude,
      northeastLat,
      northeastLng,
      southwestLat,
      southwestLng,
      reportedById,
      isAwsCompliant,
      severity,
      categoryId,
    } = hazard;

    const isUserReported = reportedById !== null;
    const isOfficialNonAws = !isAwsCompliant && !isUserReported;

    // Determine the hazard's bounding box
    let hazardNortheastLat: number;
    let hazardNortheastLng: number;
    let hazardSouthwestLat: number;
    let hazardSouthwestLng: number;

    if (northeastLat && northeastLng && southwestLat && southwestLng) {
      // Use explicit bounding box if provided (for general/broad locations)
      hazardNortheastLat = northeastLat;
      hazardNortheastLng = northeastLng;
      hazardSouthwestLat = southwestLat;
      hazardSouthwestLng = southwestLng;
    } else if (latitude && longitude) {
      // For point-based hazards, use the exact point
      hazardNortheastLat = latitude;
      hazardNortheastLng = longitude;
      hazardSouthwestLat = latitude;
      hazardSouthwestLng = longitude;
    } else {
      console.log(
        "Hazard does not have valid coordinates or bounding box to send notifications"
      );
      return [];
    }

    // Determine which notification setting field applies to this hazard
    let notificationFilter:
      | { awsEmergency: true }
      | { awsWatchAndAct: true }
      | { awsAdvice: true }
      | { officialNonAws: true }
      | { userReported: true };

    if (isUserReported) {
      notificationFilter = { userReported: true };
    } else if (isOfficialNonAws) {
      notificationFilter = { officialNonAws: true };
    } else if (isAwsCompliant && severity === HazardSeverity.emergency) {
      notificationFilter = { awsEmergency: true };
    } else if (isAwsCompliant && severity === HazardSeverity.watchAndAct) {
      notificationFilter = { awsWatchAndAct: true };
    } else if (isAwsCompliant && severity === HazardSeverity.advice) {
      notificationFilter = { awsAdvice: true };
    } else {
      // Fallback for AWS info/unknown - use awsAdvice
      notificationFilter = { awsAdvice: true };
    }

    // Get the hazard's parent category ID if it exists (for subcategories)
    let parentCategoryId: string | null = null;
    if (categoryId) {
      const category = await prisma.hazardCategory.findUnique({
        where: { id: categoryId },
        select: { parentId: true },
      });
      parentCategoryId = category?.parentId || null;
    }

    // Determine which category ID to check against subscribedCategoryIds
    // If the hazard has a parent category, use that; otherwise use the category itself
    const categoryIdToCheck = parentCategoryId || categoryId;

    // Find subscriptions where the hazard location intersects with the subscription's bounding box
    // For point hazards: check if the point is inside the subscription box
    // For area hazards: check if any part of the hazard area overlaps with the subscription box
    const subscriptions = await prisma.locationSubscription.findMany({
      where: {
        // Bounding box intersection: subscription box overlaps with hazard box
        // Subscription's NE (max) must be >= Hazard's SW (min)
        // Subscription's SW (min) must be <= Hazard's NE (max)
        northeastLat: { gte: hazardSouthwestLat }, // subscription's max lat >= hazard's min lat
        southwestLat: { lte: hazardNortheastLat }, // subscription's min lat <= hazard's max lat
        northeastLng: { gte: hazardSouthwestLng }, // subscription's max lng >= hazard's min lng
        southwestLng: { lte: hazardNortheastLng }, // subscription's min lng <= hazard's max lng

        // don't notify the user who reported the hazard
        ...(reportedById && { userId: { not: reportedById } }),

        // Only get subscriptions for users who have notifications enabled for this hazard type
        // AND have at least one category subscribed (subscribedCategoryIds not empty)
        // AND have NOT initiated account deletion (scheduledDeletionAt is null)
        user: {
          scheduledDeletionAt: null, // Exclude users who have initiated account deletion
          pushNotificationSettings: {
            some: {
              ...notificationFilter,
              subscribedCategoryIds: { has: categoryIdToCheck },
            },
          },
        },
      },
      select: {
        user: {
          select: {
            id: true,
            devices: true,
          },
        },
      },
    });

    // Dedupe by user (a user can have multiple overlapping location
    // subscriptions match the same hazard) before applying the cooldown, so
    // one user with several matching saved locations only spends one slot.
    const uniqueUsers = new Map(
      subscriptions.map((sub) => [sub.user.id, sub.user]),
    );
    // An Emergency Warning is never rate-limited away: the cooldown exists
    // to stop a flood of low-band pushes, not to drop the one that says
    // leave now (phone QA 2026-09-09 review).
    const exemptFromCooldown =
      hazard.isAwsCompliant && hazard.severity === HazardSeverity.emergency;
    const usersUnderCooldown = await Promise.all(
      [...uniqueUsers.values()].map(async (user) => ({
        user,
        underCooldown:
          exemptFromCooldown || (await isUnderNotificationCooldown(user.id)),
      })),
    );

    const eligible = usersUnderCooldown
      .filter(({ underCooldown }) => underCooldown)
      .map(({ user }) => user);
    // One push per person per hazard event, shared with the family
    // proximity paths: whichever path reaches a person first sends.
    const claimed = new Set(
      await claimHazardPushRecipients(
        hazard.id,
        hazardPushEventKey(hazard),
        eligible.map((u) => u.id),
      ),
    );
    const userTokens = eligible
      .filter((u) => claimed.has(u.id))
      .flatMap((user) => user.devices.map((device) => device.deviceToken));

    return userTokens;
  } catch (error) {
    console.error("Error fetching user tokens subscribed to hazardå:", error);
    return [];
  }
};
/**
 * Sends push notifications to a list of device tokens.
 */
/**
 * One push per recipient per hazard EVENT, across every path that may
 * notify about the same hazard (a saved area covering it, a family member
 * or a family saved place near it, two saved places near it). The first
 * path to claim a recipient sends; the others skip that recipient. The
 * claim is keyed by the event, not the hazard alone, so a genuine later
 * event about the same hazard (an escalation, a re-issue) uses a new
 * eventKey and still goes out. Claims live 48 hours in the cache; without
 * a cache they live in this process, which still covers the one creation
 * event whose paths all run here.
 */
const HAZARD_PUSH_CLAIM_TTL_S = 48 * 60 * 60;
const localHazardPushClaims = new Map<string, number>();

export const hazardPushEventKey = (hazard: {
  createdAt?: Date | string | null;
}): string => {
  const at = hazard.createdAt ? new Date(hazard.createdAt) : null;
  return at && !isNaN(at.getTime()) ? `created:${at.toISOString()}` : "created";
};

export const claimHazardPushRecipients = async (
  hazardId: string,
  eventKey: string,
  userIds: string[],
): Promise<string[]> => {
  const unique = [...new Set(userIds)];
  const redis = getCacheClient();
  const claimed: string[] = [];
  const now = Date.now();
  for (const [k, exp] of localHazardPushClaims) {
    if (exp <= now) localHazardPushClaims.delete(k);
  }
  for (const userId of unique) {
    const key = `push:hazard:${hazardId}:${eventKey}:${userId}`;
    let first = false;
    if (redis) {
      try {
        first =
          (await redis.set(key, "1", { NX: true, EX: HAZARD_PUSH_CLAIM_TTL_S })) ===
          "OK";
      } catch {
        first = !localHazardPushClaims.has(key);
        if (first) localHazardPushClaims.set(key, now + HAZARD_PUSH_CLAIM_TTL_S * 1000);
      }
    } else {
      first = !localHazardPushClaims.has(key);
      if (first) localHazardPushClaims.set(key, now + HAZARD_PUSH_CLAIM_TTL_S * 1000);
    }
    if (first) claimed.push(userId);
  }
  return claimed;
};

/**
 * Forgets every claim for a hazard (an operator re-issuing an alert on
 * purpose, and the verification scripts that push one hazard repeatedly
 * under different settings). Never called on the ordinary send path.
 */
export const releaseHazardPushClaims = async (hazardId: string) => {
  const prefix = `push:hazard:${hazardId}:`;
  for (const key of [...localHazardPushClaims.keys()]) {
    if (key.startsWith(prefix)) localHazardPushClaims.delete(key);
  }
  const redis = getCacheClient();
  if (!redis) return;
  try {
    const keys: string[] = [];
    for await (const batch of redis.scanIterator({ MATCH: `${prefix}*`, COUNT: 200 })) {
      // The client yields one key or a batch depending on its version.
      keys.push(...((Array.isArray(batch) ? batch : [batch]) as string[]));
    }
    if (keys.length > 0) await redis.del(keys);
  } catch (error) {
    console.error("Failed to release hazard push claims:", error);
  }
};

/** The tray key for a hazard: a later copy replaces, never stacks. */
export const hazardCollapseKey = (hazardId: string) => `hazard:${hazardId}`;

/**
 * The hazard fields a push may carry. The app opens the alert by id and
 * refetches it, so a push never needs coordinates, the bounding box, the
 * reporter's user id or moderation notes: they are dropped here so a
 * lock-screen preview or a captured payload can never leak a community
 * reporter's precise location (the same rule as the public hazard read).
 */
export const pushSafeHazard = (hazard: Hazard): Record<string, unknown> => {
  const {
    latitude: _lat,
    longitude: _lng,
    northeastLat: _neLat,
    northeastLng: _neLng,
    southwestLat: _swLat,
    southwestLng: _swLng,
    geoLocation: _geo,
    reportedById: _reporter,
    reviewFeedback: _feedback,
    reviewedById: _reviewer,
    ...safe
  } = hazard as Hazard & Record<string, unknown>;
  return { ...safe, reportedById: hazard.reportedById ? "community" : null };
};

/** FCM tokens Firebase reported dead on the last send; removed from UserDevice. */
const pruneDeadTokens = async (
  tokens: string[],
  response: { responses: { success: boolean; error?: { code?: string } | null }[] },
) => {
  const dead = tokens.filter((_, i) => {
    const code = response.responses[i]?.error?.code ?? "";
    return (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token" ||
      code === "messaging/invalid-argument"
    );
  });
  if (dead.length === 0) return;
  try {
    await prisma.userDevice.deleteMany({ where: { deviceToken: { in: dead } } });
    console.log(`Pruned ${dead.length} dead push token(s).`);
  } catch (error) {
    console.error("Failed to prune dead push tokens:", error);
  }
};

const sendPushNotificationToTokens = async ({
  tokens,
  title,
  body,
  data,
  type,
  urgent,
  collapseKey,
}: {
  tokens: string[];
  title: string;
  body: string;
  data: object;
  type: PushNotificationType;
  /** Force the urgent channel (a family SOS, a "needs help" check-in). */
  urgent?: boolean;
  /**
   * Tray key for the event (Android notification tag, APNs collapse id):
   * a second copy about the same event replaces the first instead of
   * stacking, on every app state where the system draws the notification.
   */
  collapseKey?: string;
}) => {
  try {
    // Remove duplicate tokens
    const uniqueTokens = [...new Set(tokens)];

    if (uniqueTokens.length === 0) {
      console.log("No tokens to send notification to.");
      return;
    }

    // Android renders a background/terminated push itself, on the channel
    // named here (else the manifest default). Take-action and critical
    // alerts name the urgent channel, which the app creates with a long,
    // hard vibration pattern only while the user's "strong vibration"
    // setting is on; when it is off the channel does not exist and
    // Android falls back to the normal channel. So the user's choice
    // holds even when the app is not on screen (phone QA 2026-09-09).
    const severityBand = String(
      (data as { severityBand?: unknown })?.severityBand ?? "",
    ).toLowerCase();
    const isUrgent =
      urgent ?? (severityBand === "action" || severityBand === "critical");
    const baseMessage = {
      notification: {
        title,
        body,
      },
      data: {
        payload: JSON.stringify(data),
        notificationType: type.toString(),
        urgent: isUrgent ? "1" : "0",
      },
      android: {
        priority: "high" as const,
        notification: {
          channelId: isUrgent ? "alrt_alerts_urgent" : "alrt_alerts",
          ...(collapseKey && { tag: collapseKey }),
          // PRIVATE: on a locked phone Android shows the app name and hides
          // the text when the user has "sensitive content" hidden; it
          // never forces the body onto the lock screen (PUBLIC) and never
          // hides the notification entirely (SECRET). The user's own
          // lock-screen setting decides.
          visibility: "private" as const,
        },
      },
      // iOS: a sound so an alert is heard, and time-sensitive delivery
      // for urgent ones (honoured only where the app carries the
      // time-sensitive entitlement; otherwise iOS treats it as active).
      // Never critical: that needs Apple's entitlement and would bypass
      // silent mode, which no alert here is allowed to do.
      apns: {
        ...(collapseKey && { headers: { "apns-collapse-id": collapseKey.slice(0, 64) } }),
        payload: {
          aps: {
            sound: "default",
            "interruption-level": isUrgent ? "time-sensitive" : "active",
          },
        },
      },
    };

    // FCM caps sendEachForMulticast at 500 tokens per call. In a densely
    // subscribed area a single hazard can exceed that, and a too-large array
    // throws — meaning NObody in that area gets the safety alert. Chunk it.
    const FCM_MULTICAST_LIMIT = 500;
    const batches = [];
    for (let i = 0; i < uniqueTokens.length; i += FCM_MULTICAST_LIMIT) {
      batches.push(uniqueTokens.slice(i, i + FCM_MULTICAST_LIMIT));
    }

    const responses = await Promise.all(
      batches.map((tokenBatch) =>
        firebaseAdmin
          .messaging()
          .sendEachForMulticast({ ...baseMessage, tokens: tokenBatch })
      )
    );
    // Tokens Firebase says are gone (app uninstalled, data cleared) are
    // dropped so they stop costing a send each time.
    await Promise.all(
      batches.map((tokenBatch, i) => {
        const r = responses[i];
        return r?.responses ? pruneDeadTokens(tokenBatch, r as any) : Promise.resolve();
      }),
    );

    // Return the first batch's response to preserve the previous single-batch
    // return shape for existing callers.
    return responses[0];
  } catch (error) {
    console.error("Error sending push notification:", error);
  }
};

/**
 * Sends a push notification to a specific user by their user ID.
 */
export const sendPushNotificationToUser = async ({
  userId,
  title,
  body,
  data,
  type,
  urgent,
  collapseKey,
}: {
  userId: string;
  title: string;
  body: string;
  data: object;
  type: PushNotificationType;
  urgent?: boolean;
  collapseKey?: string;
}) => {
  try {
    // Fetch user tokens from your database
    const userTokens = await getUserPushNotificationTokens(userId);

    if (userTokens.length === 0) {
      console.log("No tokens found for user:", userId);
      return;
    }

    await sendPushNotificationToTokens({
      tokens: userTokens,
      title,
      body,
      data,
      type,
      ...(urgent !== undefined && { urgent }),
      ...(collapseKey && { collapseKey }),
    });
  } catch (error) {
    console.error("Error sending push notification to user:", error);
  }
};

/**
 * Sends push notifications to users subscribed to the location of a new hazard.
 */
export const sendPushNotificationAboutNewHazard = async (hazard: Hazard) => {
  try {
    const userTokens = await getUserPushNotificationTokensSubscribedToHazard(
      hazard
    );

    await sendPushNotificationToTokens({
      tokens: userTokens,
      title: getNotificationTitleForNewHazard(hazard),
      body: getNotificationBodyForNewHazard(hazard),
      data: pushSafeHazard(hazard),
      type: PushNotificationType.viewHazard,
      collapseKey: hazardCollapseKey(hazard.id),
    });
  } catch (error) {
    console.error(
      "Error sending push notifications to subscribed users:",
      error
    );
  }
};

/**
 * Returns the notification title for a new hazard based on its severity and title.
 *
 * Community reports never carry a severity/band prefix: per the classification
 * standard (§6), a community report has category colour only, never a severity
 * band, and that rule has to hold in the push notification tray too, not just
 * on the card. A prefix like "Info | <title>" on an unverified report both
 * violates that rule and is misleading either way ("Info" undersells a report
 * that might be serious; any other band would overstate one the AI is
 * forbidden from banding at all).
 */
export const getNotificationTitleForNewHazard = (hazard: Hazard): string => {
  const { severity, title, isAwsCompliant, severityBand, reportedById } =
    hazard;

  if (reportedById) {
    return `Community report | ${title}`;
  }

  const formattedSeverity = getFormattedHazardSeverity(severity);
  const foramttedSeverityBand = getFormattedHazardSeverityBand(severityBand);

  const requiredSeverity = isAwsCompliant
    ? formattedSeverity
    : foramttedSeverityBand;

  return `${requiredSeverity} | ${title}`;
};

/**
 * Returns the notification body for a new hazard based on its short description or description.
 */
const getNotificationBodyForNewHazard = (hazard: Hazard): string => {
  const { aiSummary, description } = hazard;
  return aiSummary || description || "New hazard reported.";
};

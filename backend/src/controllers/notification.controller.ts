import { sendPushNotificationToUser } from "../services/notification.service.js";
import { PushNotificationType } from "../models/push_notification_types.js";
import type { DeletePushNotificationTokenInput, TestNotificationInput } from "../validators/notification.validator.js";
import type { Request, Response, NextFunction } from "express";
import type { Hazard } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { getHazardsApplyingFiltersRaw } from "../services/hazard.service.js";
import type {
  GetNotificationsFeedQuery,
  PushNotificationTokenInput,
} from "../validators/notification.validator.js";
import { parseBoolean } from "../utils/parse.util.js";
import { enrichHazardsWithPresignedUrls } from "../services/s3.service.js";
import { getUserLocationSubscriptions } from "../services/location_subscription.service.js";
import {
  buildHazardListCacheKey,
  getCachedHazardList,
  cacheHazardList,
} from "../services/hazard_cache.service.js";

export const getNotificationsFeed = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { userId } = res;
    const {
      searchString,
      categoryIds,
      locationIds,
      awsEmergency,
      awsWatchAndAct,
      awsAdvice,
      officialNonAws,
      userReported,
      reviewStatus,
      showExpired,
      sortSettings,
      page = "1",
      pageSize = "20",
    }: GetNotificationsFeedQuery = req.query;

    const allSubscriptions = await getUserLocationSubscriptions({
      userId: userId!,
    });

    const subscriptions = locationIds
      ? allSubscriptions.filter((sub) =>
          locationIds.split(",").includes(sub.id),
        )
      : allSubscriptions;

    if (subscriptions.length === 0) {
      return res.status(200).json([]);
    }

    const user = await prisma.user.findUnique({
      where: { id: userId! },
      select: { latitude: true, longitude: true },
    });
    const userLat = user?.latitude || undefined;
    const userLng = user?.longitude || undefined;

    const filterParams = {
      searchString,
      categoryIds,
      locationIds: locationIds ?? undefined,
      awsEmergency: parseBoolean(awsEmergency),
      awsWatchAndAct: parseBoolean(awsWatchAndAct),
      awsAdvice: parseBoolean(awsAdvice),
      officialNonAws: parseBoolean(officialNonAws),
      userReported: parseBoolean(userReported),
      reviewStatus,
      userId,
      page: Number(page),
      pageSize: Number(pageSize),
      userLat,
      userLng,
      sortSettings,
      showExpired: parseBoolean(showExpired),
    };

    const cacheKey = await buildHazardListCacheKey(filterParams);
    const cached = await getCachedHazardList<Hazard>(cacheKey);

    let hazards: Hazard[];
    if (cached) {
      hazards = cached;
    } else {
      hazards = await getHazardsApplyingFiltersRaw({
        ...filterParams,
        subscriptions,
      });
      await cacheHazardList(cacheKey, hazards);
    }

    const hazardsWithPresignedUrls =
      await enrichHazardsWithPresignedUrls(hazards);

    res.status(200).json(hazardsWithPresignedUrls);
  } catch (error) {
    next(error);
  }
};

export const sendPushNotificationToken = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { token, platform }: PushNotificationTokenInput = req.body;
    const { userId } = res;

    // delete any existing entries with the same token but different user
    await prisma.userDevice.deleteMany({
      where: {
        deviceToken: token,
        NOT: {
          userId: userId!,
        },
      },
    });

    // upsert the device token for the user
    const newDevice = await prisma.userDevice.upsert({
      where: {
        deviceToken: token,
      },
      create: {
        userId: userId!,
        deviceToken: token,
        platform: platform || null,
      },
      update: {
        platform: platform || null,
      },
    });

    if (!newDevice) {
      throw new HttpError(500, "Failed to register device token");
    }

    res.status(200).json({ message: "Device token registered successfully" });
  } catch (error) {
    next(error);
  }
};


/**
 * Removes this phone's token for the signed-in user, called by the app
 * before it signs out, so a phone that changes hands stops receiving the
 * previous account's family and SOS pushes at once (not only when someone
 * else signs in on it).
 */
export const deletePushNotificationToken = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { token }: DeletePushNotificationTokenInput = req.body;
    const { userId } = res;
    const result = await prisma.userDevice.deleteMany({
      where: { deviceToken: token, userId: userId! },
    });
    res.status(200).json({ removed: result.count });
  } catch (error) {
    next(error);
  }
};

/**
 * A clearly labelled test push to the caller's OWN devices, so delivery,
 * lock-screen display, sound and vibration can be checked on a phone
 * without touching any real alert or any other person. `urgent` sends it
 * on the urgent channel (strong vibration) the way an SOS or a take-action
 * alert would arrive.
 */
export const sendTestNotification = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { urgent = false }: TestNotificationInput = req.body ?? {};
    const { userId } = res;
    const devices = await prisma.userDevice.count({ where: { userId: userId! } });
    if (devices === 0) {
      res.status(200).json({
        sent: false,
        devices: 0,
        message: "No phone is registered for notifications on this account.",
      });
      return;
    }
    const sentAt = new Date().toISOString();
    await sendPushNotificationToUser({
      userId: userId!,
      title: urgent ? "ALRT test (urgent channel)" : "ALRT test notification",
      body: "If you can see this, ALRT alerts reach this phone. Nothing was sent to anyone else.",
      data: { sentAt, urgent, test: true },
      type: PushNotificationType.testNotification,
      urgent,
    });
    res.status(200).json({ sent: true, devices, sentAt, urgent });
  } catch (error) {
    next(error);
  }
};

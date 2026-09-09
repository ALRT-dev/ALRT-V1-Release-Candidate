import { Router } from "express";
import {
  deletePushNotificationToken,
  getNotificationsFeed,
  sendPushNotificationToken,
  sendTestNotification,
} from "../controllers/notification.controller.js";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { validate } from "../middlewares/validation.middleware.js";
import {
  deletePushNotificationTokenSchema,
  getNotificationsFeedSchema,
  pushNotificationTokenSchema,
  testNotificationSchema,
} from "../validators/notification.validator.js";

const notificationRouter = Router();

notificationRouter.get(
  "/feed",
  requireAuth,
  // Second arg matters - see the identical fix/comment in hazard.route.ts.
  validate(getNotificationsFeedSchema, "query"),
  getNotificationsFeed
);
notificationRouter.post(
  "/push-notification-token",
  requireAuth,
  validate(pushNotificationTokenSchema),
  sendPushNotificationToken
);

notificationRouter.delete(
  "/push-notification-token",
  requireAuth,
  validate(deletePushNotificationTokenSchema),
  deletePushNotificationToken
);
// A test push to the caller's own phones only (Manage notifications ›
// "Send a test notification"). Never a hazard, never another recipient.
notificationRouter.post(
  "/test",
  requireAuth,
  validate(testNotificationSchema),
  sendTestNotification
);

export default notificationRouter;

import { Router } from "express";
import {
  getNotificationsFeed,
  sendPushNotificationToken,
} from "../controllers/notification.controller.js";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { validate } from "../middlewares/validation.middleware.js";
import {
  getNotificationsFeedSchema,
  pushNotificationTokenSchema,
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

export default notificationRouter;

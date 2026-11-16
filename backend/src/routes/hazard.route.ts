import { Router } from "express";
import {
  createHazard,
  getHazardById,
  getHazards,
  deleteHazard,
  getHazardsWithSubscriptionId,
  voteHazard,
  viewHazard,
  updateHazard,
} from "../controllers/hazard.controller.js";
import {
  deleteHazardMedia,
  updateHazardMedia,
} from "../controllers/hazard_media.controller.js";
import { flagHazardController } from "../controllers/community_safety.controller.js";
import { flagHazardSchema } from "../validators/community_safety.validator.js";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { followHazard, listFollows, unfollowHazard } from "../services/follow.service.js";
import { validate } from "../middlewares/validation.middleware.js";
import {
  createHazardSchema,
  voteHazardSchema,
  getHazardsQuerySchema,
  updateHazardSchema,
} from "../validators/hazard.validator.js";
import {
  uploadMultiple,
  handleMulterError,
  blockCommunityReportMedia,
} from "../middlewares/upload.middleware.js";
import {
  hazardGetIpLimiter,
  hazardReadUserLimiter,
} from "../middlewares/api_rate_limit.middleware.js";

const hazardRouter = Router();

hazardRouter.use((req, res, next) => {
  if (req.method !== "GET") return next();
  hazardGetIpLimiter(req, res, next);
});

hazardRouter.get(
  "/",
  requireAuth,
  hazardReadUserLimiter,
  // Second arg matters: validate() defaults to target "body", which for a
  // GET request is always {} and never touches the real query string - so
  // getHazardsQuerySchema's pageSize bound (1-5000) was never enforced.
  // Same bug, same fix as backend/src/routes/admin/hazard.route.ts (Stage
  // 7B); this public route was missed at the time. See
  // V1_RECONCILIATION_REPORT.md §25.
  validate(getHazardsQuerySchema, "query"),
  getHazards,
);
hazardRouter.get(
  "/hazards-with-subscription-id",
  requireAuth,
  hazardReadUserLimiter,
  validate(getHazardsQuerySchema, "query"),
  getHazardsWithSubscriptionId,
);
hazardRouter.get("/:id", requireAuth, hazardReadUserLimiter, getHazardById);

hazardRouter.post(
  "/",
  requireAuth,
  uploadMultiple,
  handleMulterError,
  blockCommunityReportMedia,
  validate(createHazardSchema),
  createHazard,
);
hazardRouter.put(
  "/:id",
  requireAuth,
  uploadMultiple,
  handleMulterError,
  blockCommunityReportMedia,
  validate(updateHazardSchema),
  updateHazard,
);
hazardRouter.post(
  "/:id/vote",
  requireAuth,
  validate(voteHazardSchema),
  voteHazard,
);
hazardRouter.post("/:id/view", requireAuth, viewHazard);

// Server-side Follow (owner decision D7, 16 Nov 2026): one push when the
// alert's level changes, one when it ends.
const followHandler = (fn: (userId: string, id: string) => Promise<unknown>) =>
  async (req: import("express").Request, res: import("express").Response, next: import("express").NextFunction) => {
    try {
      const userId = (res as unknown as { userId?: string }).userId;
      if (!userId) return res.status(401).json({ message: "Sign in to follow alerts." });
      res.status(200).json(await fn(userId, String(req.params.id)));
    } catch (e) {
      next(e);
    }
  };
hazardRouter.get("/following/list", requireAuth, followHandler((userId) => listFollows(userId)));
hazardRouter.post("/:id/follow", requireAuth, followHandler(followHazard));
hazardRouter.delete("/:id/follow", requireAuth, followHandler(unfollowHazard));
hazardRouter.delete("/:id", requireAuth, deleteHazard);

hazardRouter.delete(
  "/:hazardId/media/:mediaId",
  requireAuth,
  deleteHazardMedia,
);
hazardRouter.patch("/:hazardId/media/:mediaId", requireAuth, updateHazardMedia);

// Community safety: anyone can flag a community report for review. The
// automated pipeline screens content before it publishes; this covers what
// automation cannot judge.
hazardRouter.post(
  "/:hazardId/flag",
  requireAuth,
  validate(flagHazardSchema),
  flagHazardController,
);

export default hazardRouter;

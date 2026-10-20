import { Router } from "express";
import type { Request, Response, NextFunction } from "express";
import { getAppVersionPolicy } from "../services/app_version_policy.service.js";
import { getSeverityLabels } from "../services/configuration.service.js";

/**
 * Public app metadata (no auth): read before sign-in, so an app too old to
 * be supported can show its update screen first.
 */
const appRouter = Router();

/** GET /api/app/version-policy - minimum version/build per platform. */
appRouter.get("/version-policy", (_req: Request, res: Response) => {
  // Short cache: a raised minimum reaches phones within minutes.
  res.set("Cache-Control", "public, max-age=300");
  res.status(200).json(getAppVersionPolicy());
});

/**
 * GET /api/app/config — public app configuration served to the Flutter app.
 * Currently carries severity labels (editable via the admin portal) so the
 * app can display admin-chosen words without a rebuild.
 * Cache for 5 minutes; an admin change reaches phones quickly.
 */
appRouter.get(
  "/config",
  async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const severityLabels = await getSeverityLabels();
      res.set("Cache-Control", "public, max-age=300");
      res.status(200).json({ severityLabels });
    } catch (err) {
      next(err);
    }
  },
);

export default appRouter;

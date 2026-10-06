import { Router } from "express";
import type { Request, Response } from "express";
import { getAppVersionPolicy } from "../services/app_version_policy.service.js";

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

export default appRouter;

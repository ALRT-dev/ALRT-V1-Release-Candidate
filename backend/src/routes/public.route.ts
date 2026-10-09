import { Router } from "express";
import express from "express";
import type { Request, Response } from "express";
import rateLimit from "express-rate-limit";
import {
  getPublicHazardController,
  passwordResetPageController,
  passwordResetSubmitController,
  shareAlertCardController,
  shareAlertPageController,
} from "../controllers/public.controller.js";
import { config } from "../utils/config.js";
import { authApiRateLimiter } from "../middlewares/api_rate_limit.middleware.js";
import {
  getClientIp,
  normalizeClientIpForRateLimitKey,
} from "../utils/client_ip.util.js";

const limiterValidate = config.rateLimit.trustProxy
  ? { trustProxy: true as const }
  : { xForwardedForHeader: false as const };

/**
 * Lightweight per-IP limiter for the public share endpoints. Kept generous
 * (60/min) because messaging apps unfurl these links automatically.
 */
const publicShareRateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  validate: limiterValidate,
  keyGenerator: (req: Request) =>
    normalizeClientIpForRateLimitKey(getClientIp(req)),
  handler: (_req: Request, res: Response) => {
    res.status(429).json({
      error: "Too many requests",
      message: "Too many requests. Please slow down and try again later.",
    });
  },
});

const publicRouter = Router();

// Exact public paths only — this router is mounted at "/" so nothing else
// may be swallowed here.
publicRouter.get(
  "/api/public/hazards/:id",
  publicShareRateLimiter,
  getPublicHazardController,
);
publicRouter.get(
  "/share/alert/:id",
  publicShareRateLimiter,
  shareAlertPageController,
);
publicRouter.get(
  "/share/alert/:id/card.png",
  publicShareRateLimiter,
  shareAlertCardController,
);
// Short alias used in share sheets — easier to read and type than the
// full /share/alert path.
publicRouter.get("/a/:id", publicShareRateLimiter, shareAlertPageController);

// The password-reset email links here. Same stricter rate limit as the
// rest of the password-reset surface under /api/auth (not the generous
// share-link limiter above) since this is a security-sensitive form, not a
// read-mostly public page.
publicRouter.get(
  "/reset-password",
  authApiRateLimiter,
  passwordResetPageController,
);
publicRouter.post(
  "/reset-password",
  authApiRateLimiter,
  express.urlencoded({ extended: true }),
  passwordResetSubmitController,
);

export default publicRouter;

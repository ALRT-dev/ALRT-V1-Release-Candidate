import type { NextFunction, Request, Response } from "express";
import { config } from "../utils/config.js";

/** Email and password sign-in is switched off unless explicitly enabled. */
export const requireEmailPasswordAuth = (
  _req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (!config.emailPasswordAuthEnabled) {
    return res.status(404).json({ message: "Not found" });
  }
  next();
};

/**
 * Password login stays closed except for the reviewer emails listed in
 * REVIEW_LOGIN_EMAILS (or everyone, when email sign-in is switched on).
 * Registration and password reset use requireEmailPasswordAuth and stay shut.
 */
export const requireEmailLoginAllowed = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (config.emailPasswordAuthEnabled) return next();
  const email = String(req.body?.email ?? "").trim().toLowerCase();
  if (email && config.reviewLoginEmails.includes(email)) return next();
  return res.status(404).json({ message: "Not found" });
};

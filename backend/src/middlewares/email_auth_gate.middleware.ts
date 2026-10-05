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

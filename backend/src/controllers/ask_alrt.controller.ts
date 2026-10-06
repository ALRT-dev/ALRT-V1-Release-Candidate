import type { NextFunction, Request, Response } from "express";
import { HttpError } from "../models/http_error.js";
import { askAlrt, getAskAlrtAllowance, type AskRequest } from "../services/ask_alrt.service.js";
import { zoneFromRequest } from "../services/ask_alrt/quota.js";

/** POST /api/ask-alrt - one question from the signed-in person. */
export const askAlrtController = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = res.userId;
    if (!userId) throw new HttpError(401, "Sign in to use Ask ALRT.");
    res.status(200).json(await askAlrt(userId, req.body as AskRequest));
  } catch (error) {
    next(error);
  }
};

/** GET /api/ask-alrt/allowance - questions left today (no question is counted). */
export const askAlrtAllowanceController = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = res.userId;
    if (!userId) throw new HttpError(401, "Sign in to use Ask ALRT.");
    const zone = zoneFromRequest(req.query["timeZone"], Number(req.query["utcOffsetMinutes"]));
    res.status(200).json(await getAskAlrtAllowance(userId, zone));
  } catch (error) {
    next(error);
  }
};

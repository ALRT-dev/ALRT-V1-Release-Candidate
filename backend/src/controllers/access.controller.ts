import type { NextFunction, Request, Response } from "express";
import { HttpError } from "../models/http_error.js";
import type {
  BindSponsorshipInput,
  CreateSponsorshipIntentInput,
} from "../validators/access.validator.js";
import {
  bindSponsorship,
  confirmPendingChanges,
  createSponsorshipIntent,
  getAccessSummary,
  switchGroupToIndividualFunding,
} from "../services/entitlement.service.js";

const requireUserId = (res: Response): string => {
  const { userId } = res;
  if (!userId) throw new HttpError(400, "Unauthenticated user");
  return userId;
};

/**
 * GET /api/access
 * Personal plan and each group's coverage, separately (master spec §17).
 * The app renders plan state from this; it never decides access itself.
 */
export const getAccessController = async (
  _req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    res.json(await getAccessSummary(requireUserId(res)));
  } catch (error) {
    next(error);
  }
};

/** POST /api/access/sponsorship-intents */
export const createSponsorshipIntentController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { circleId, tier }: CreateSponsorshipIntentInput = req.body;
    const intent = await createSponsorshipIntent(requireUserId(res), circleId, tier);
    res.status(201).json(intent);
  } catch (error) {
    next(error);
  }
};

/** POST /api/access/sponsorships/:subscriptionId/bind */
export const bindSponsorshipController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { circleId, replaceExisting }: BindSponsorshipInput = req.body;
    const subscriptionId = req.params.subscriptionId;
    if (!subscriptionId) throw new HttpError(400, "Missing purchase id");
    const bound = await bindSponsorship(
      subscriptionId,
      circleId,
      requireUserId(res),
      undefined,
      { replaceExisting: replaceExisting === true },
    );
    res.json({
      id: bound.id,
      boundCircleId: bound.boundCircleId,
      tier: bound.tier,
      replaced: bound.replaced ?? null,
    });
  } catch (error) {
    next(error);
  }
};

/** POST /api/access/groups/:circleId/individual-funding */
export const switchToIndividualFundingController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const circleId = req.params.circleId;
    if (!circleId) throw new HttpError(400, "Missing group id");
    const circle = await switchGroupToIndividualFunding(requireUserId(res), circleId);
    res.json({ circleId: circle.id, fundingMode: circle.fundingMode });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/access/reconcile
 * After a purchase or Restore: asks the STORE's server record (never the
 * app) whether pending changes are in effect and whether any active
 * purchase has not reached ALRT yet, then returns the access summary. The
 * app words Restore from this: confirmed, still pending, or not found.
 */
export const reconcileAccessController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    // Product ids Restore found on the phone: looked up, never trusted.
    const claimed: string[] = Array.isArray(req.body?.productIds) ? req.body.productIds : [];
    const store = await confirmPendingChanges(userId, fetch, claimed);
    res.json({
      store: {
        checked: store.checked,
        confirmedChanges: store.confirmedChanges,
        unrecorded: store.unrecorded,
        products: store.products,
      },
      access: await getAccessSummary(userId),
    });
  } catch (error) {
    next(error);
  }
};

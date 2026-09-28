import { Router } from "express";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { validate } from "../middlewares/validation.middleware.js";
import {
  bindSponsorshipSchema,
  createSponsorshipIntentSchema,
} from "../validators/access.validator.js";
import {
  bindSponsorshipController,
  createSponsorshipIntentController,
  getAccessController,
  switchToIndividualFundingController,
} from "../controllers/access.controller.js";

const accessRouter = Router();

accessRouter.use(requireAuth);

/** Personal plan + per-group coverage, computed by the backend. */
accessRouter.get("/", getAccessController);

/** Choose the group a Family/Group purchase will cover, before checkout. */
accessRouter.post(
  "/sponsorship-intents",
  validate(createSponsorshipIntentSchema),
  createSponsorshipIntentController,
);

/** Apply a verified but unbound group purchase to one group, once. */
accessRouter.post(
  "/sponsorships/:subscriptionId/bind",
  validate(bindSponsorshipSchema),
  bindSponsorshipController,
);

/** Explicitly return a lapsed sponsored group to individual funding. */
accessRouter.post(
  "/groups/:circleId/individual-funding",
  switchToIndividualFundingController,
);

export default accessRouter;

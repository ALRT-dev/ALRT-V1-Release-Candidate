import { Router } from "express";
import {
  geocode,
  placeAutocomplete,
  placeDetails,
} from "../controllers/maps.controller.js";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { mapsProxyUserLimiter } from "../middlewares/api_rate_limit.middleware.js";

const mapsRouter = Router();

// Authenticated so the proxy can't be used as an open relay against our Google quota,
// then rate-limited per user since these calls are now the app's live search path.
mapsRouter.get("/geocode", requireAuth, mapsProxyUserLimiter, geocode);
mapsRouter.get(
  "/places/autocomplete",
  requireAuth,
  mapsProxyUserLimiter,
  placeAutocomplete,
);
mapsRouter.get(
  "/places/details",
  requireAuth,
  mapsProxyUserLimiter,
  placeDetails,
);

export default mapsRouter;

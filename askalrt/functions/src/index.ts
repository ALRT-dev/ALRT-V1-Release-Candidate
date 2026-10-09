/**
 * Ask ALRT — function exports.
 *
 * This package hosts ONLY the Ask ALRT assistant. The app's backend
 * (hazards, family, SOS, XP, sharing, proximity) is the REST service in
 * `ALRT-dev/backendV2` (api.safetyalrt.com) — the earlier duplicate
 * implementations of those domains were removed from this repo in the
 * Aug 2026 repo audit.
 *
 * V1 access model (master spec 28 Sep 2026): the separate
 * `revenuecatWebhook` function that used to live here is retired. It was a
 * second interpretation of store events (it removed access on CANCELLATION
 * and BILLING_ISSUE). The backend is now the only RevenueCat consumer and
 * writes a versioned mirror to entitlements/{uid}, which askAlrt reads.
 * Deploy order: backend (mirror writer) first, then this package, then
 * remove the old function's webhook from RevenueCat (see
 * docs/V1_ACCESS_MODEL_IMPLEMENTATION.md).
 */
import * as admin from "firebase-admin";

admin.initializeApp();

// Ask ALRT assistant (library-first, minimal AI).
export { askAlrt } from "./askalrt/askAlrt";

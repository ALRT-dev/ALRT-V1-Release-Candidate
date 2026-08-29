import { Router } from "express";
import {
  requireAdminAuth,
  requireAnyAdmin,
} from "../../middlewares/auth.admin.middleware.js";
import { mintAdminFirebaseTokenController } from "../../controllers/admin/ask_alrt.admin.controller.js";

const adminAskAlrtRouter = Router();

adminAskAlrtRouter.use(requireAdminAuth);

/**
 * @route   POST /api/admin/ask-alrt/firebase-token
 * @desc    Mints a Firebase custom token (uid `admin:<adminId>`) so the
 *          Admin Portal can call the existing askAlrt Cloud Function.
 *          Any authenticated admin role may use Ask ALRT.
 */
adminAskAlrtRouter.post(
  "/firebase-token",
  requireAnyAdmin,
  mintAdminFirebaseTokenController,
);

export default adminAskAlrtRouter;

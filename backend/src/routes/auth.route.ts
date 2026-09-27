import router from "express";
import {
  confirmPasswordResetController,
  loginWithEmailAndPassword,
  refreshToken,
  registerWithEmailAndPassword,
  requestPasswordResetController,
  verifyAppleOAuth,
  verifyGoogleOAuth,
  verifyMicrosoftOAuth,
} from "../controllers/auth.controller.js";
import { validate } from "../middlewares/validation.middleware.js";
import {
  registerSchema,
  loginSchema,
  googleOAuthSchema,
  appleOAuthSchema,
  microsoftOAuthSchema,
  refreshTokenSchema,
  passwordResetRequestSchema,
  passwordResetConfirmSchema,
} from "../validators/auth.validator.js";

const authRouter = router();

authRouter.post(
  "/email-password/register",
  validate(registerSchema),
  registerWithEmailAndPassword
);
authRouter.post(
  "/email-password/login",
  validate(loginSchema),
  loginWithEmailAndPassword
);
authRouter.post(
  "/oauth/google",
  validate(googleOAuthSchema),
  verifyGoogleOAuth
);
authRouter.post("/oauth/apple", validate(appleOAuthSchema), verifyAppleOAuth);
authRouter.post(
  "/oauth/microsoft",
  validate(microsoftOAuthSchema),
  verifyMicrosoftOAuth
);
authRouter.post("/refresh-token", validate(refreshTokenSchema), refreshToken);

authRouter.post(
  "/password-reset/request",
  validate(passwordResetRequestSchema),
  requestPasswordResetController
);
authRouter.post(
  "/password-reset/confirm",
  validate(passwordResetConfirmSchema),
  confirmPasswordResetController
);

export default authRouter;

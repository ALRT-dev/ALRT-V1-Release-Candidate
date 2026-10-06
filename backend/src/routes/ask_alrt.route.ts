import { Router } from "express";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { validate } from "../middlewares/validation.middleware.js";
import { askAlrtAllowanceController, askAlrtController } from "../controllers/ask_alrt.controller.js";
import { askAlrtBodySchema } from "../validators/admin/ask_alrt_content.validator.js";

const askAlrtRouter = Router();

askAlrtRouter.post("/", requireAuth, validate(askAlrtBodySchema), askAlrtController);
askAlrtRouter.get("/allowance", requireAuth, askAlrtAllowanceController);

export default askAlrtRouter;

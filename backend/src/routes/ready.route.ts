import { Router } from "express";
import { requireAuth } from "../middlewares/auth.middleware.js";
import {
  listPlansController,
  getPlanController,
  createPlanController,
  updatePlanController,
  deletePlanController,
  listDrillsController,
  getDrillController,
  createDrillController,
  deleteDrillController,
  getReadySummaryController,
} from "../controllers/ready.controller.js";

const readyRouter = Router();

readyRouter.use(requireAuth);

// Summary endpoint for the Ready tab score
readyRouter.get("/summary", getReadySummaryController);

// --- Emergency Plans -------------------------------------------------------
readyRouter.get("/plans", listPlansController);
readyRouter.get("/plans/:planId", getPlanController);
readyRouter.post("/plans", createPlanController);
readyRouter.patch("/plans/:planId", updatePlanController);
readyRouter.delete("/plans/:planId", deletePlanController);

// --- Emergency Drills ------------------------------------------------------
readyRouter.get("/drills", listDrillsController);
readyRouter.get("/drills/:drillId", getDrillController);
readyRouter.post("/drills", createDrillController);
readyRouter.delete("/drills/:drillId", deleteDrillController);

export default readyRouter;

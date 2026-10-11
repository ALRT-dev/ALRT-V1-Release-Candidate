import type { Request, Response, NextFunction } from "express";
import { HttpError } from "../models/http_error.js";
import * as readyService from "../services/ready.service.js";
import {
  createEmergencyPlanSchema,
  updateEmergencyPlanSchema,
  createEmergencyDrillSchema,
} from "../validators/ready.validator.js";

const requireUserId = (res: Response): string => {
  const { userId } = res;
  if (!userId) throw new HttpError(400, "Unauthenticated user");
  return userId;
};

// ---------------------------------------------------------------------------
// Plans
// ---------------------------------------------------------------------------

export const listPlansController = async (
  _req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const plans = await readyService.listPlans(userId);
    res.status(200).json(plans);
  } catch (error) {
    next(error);
  }
};

export const getPlanController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const { planId } = req.params;
    if (!planId) throw new HttpError(400, "planId is required");
    const plan = await readyService.getPlan(userId, planId);
    res.status(200).json(plan);
  } catch (error) {
    next(error);
  }
};

export const createPlanController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const input = createEmergencyPlanSchema.parse(req.body);
    const plan = await readyService.createPlan(userId, input);
    res.status(201).json(plan);
  } catch (error) {
    next(error);
  }
};

export const updatePlanController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const { planId } = req.params;
    if (!planId) throw new HttpError(400, "planId is required");
    const input = updateEmergencyPlanSchema.parse(req.body);
    const plan = await readyService.updatePlan(userId, planId, input);
    res.status(200).json(plan);
  } catch (error) {
    next(error);
  }
};

export const deletePlanController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const { planId } = req.params;
    if (!planId) throw new HttpError(400, "planId is required");
    await readyService.deletePlan(userId, planId);
    res.status(204).end();
  } catch (error) {
    next(error);
  }
};

// ---------------------------------------------------------------------------
// Drills
// ---------------------------------------------------------------------------

export const listDrillsController = async (
  _req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const drills = await readyService.listDrills(userId);
    res.status(200).json(drills);
  } catch (error) {
    next(error);
  }
};

export const getDrillController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const { drillId } = req.params;
    if (!drillId) throw new HttpError(400, "drillId is required");
    const drill = await readyService.getDrill(userId, drillId);
    res.status(200).json(drill);
  } catch (error) {
    next(error);
  }
};

export const createDrillController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const input = createEmergencyDrillSchema.parse(req.body);
    const drill = await readyService.createDrill(userId, input);
    res.status(201).json(drill);
  } catch (error) {
    next(error);
  }
};

export const deleteDrillController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const { drillId } = req.params;
    if (!drillId) throw new HttpError(400, "drillId is required");
    await readyService.deleteDrill(userId, drillId);
    res.status(204).end();
  } catch (error) {
    next(error);
  }
};

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------

export const getReadySummaryController = async (
  _req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = requireUserId(res);
    const summary = await readyService.getReadySummary(userId);
    res.status(200).json(summary);
  } catch (error) {
    next(error);
  }
};

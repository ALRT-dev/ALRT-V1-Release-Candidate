import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import type {
  CreateEmergencyPlanInput,
  UpdateEmergencyPlanInput,
  CreateEmergencyDrillInput,
} from "../validators/ready.validator.js";

// ---------------------------------------------------------------------------
// Emergency Plan CRUD
// ---------------------------------------------------------------------------

const PLAN_SELECT = {
  id: true,
  title: true,
  meetingPoint: true,
  evacuationRoute: true,
  notes: true,
  items: true,
  createdAt: true,
  updatedAt: true,
  _count: { select: { drills: true } },
} as const;

export const listPlans = async (userId: string) =>
  prisma.emergencyPlan.findMany({
    where: { userId },
    select: PLAN_SELECT,
    orderBy: { updatedAt: "desc" },
  });

export const getPlan = async (userId: string, planId: string) => {
  const plan = await prisma.emergencyPlan.findFirst({
    where: { id: planId, userId },
    select: PLAN_SELECT,
  });
  if (!plan) throw new HttpError(404, "Plan not found");
  return plan;
};

export const createPlan = async (
  userId: string,
  input: CreateEmergencyPlanInput,
) =>
  prisma.emergencyPlan.create({
    data: {
      userId,
      title: input.title,
      ...(input.meetingPoint ? { meetingPoint: input.meetingPoint } : {}),
      ...(input.evacuationRoute
        ? { evacuationRoute: input.evacuationRoute }
        : {}),
      ...(input.notes ? { notes: input.notes } : {}),
      ...(input.items ? { items: input.items } : {}),
    },
    select: PLAN_SELECT,
  });

export const updatePlan = async (
  userId: string,
  planId: string,
  input: UpdateEmergencyPlanInput,
) => {
  const existing = await prisma.emergencyPlan.findFirst({
    where: { id: planId, userId },
    select: { id: true },
  });
  if (!existing) throw new HttpError(404, "Plan not found");

  return prisma.emergencyPlan.update({
    where: { id: planId },
    data: {
      ...(input.title !== undefined ? { title: input.title } : {}),
      ...(input.meetingPoint !== undefined
        ? { meetingPoint: input.meetingPoint }
        : {}),
      ...(input.evacuationRoute !== undefined
        ? { evacuationRoute: input.evacuationRoute }
        : {}),
      ...(input.notes !== undefined ? { notes: input.notes } : {}),
      ...(input.items !== undefined ? { items: input.items } : {}),
    },
    select: PLAN_SELECT,
  });
};

export const deletePlan = async (userId: string, planId: string) => {
  const existing = await prisma.emergencyPlan.findFirst({
    where: { id: planId, userId },
    select: { id: true },
  });
  if (!existing) throw new HttpError(404, "Plan not found");

  await prisma.emergencyPlan.delete({ where: { id: planId } });
};

// ---------------------------------------------------------------------------
// Emergency Drill CRUD
// ---------------------------------------------------------------------------

const DRILL_SELECT = {
  id: true,
  title: true,
  planId: true,
  notes: true,
  completedAt: true,
  durationMinutes: true,
  createdAt: true,
} as const;

export const listDrills = async (userId: string) =>
  prisma.emergencyDrill.findMany({
    where: { userId },
    select: DRILL_SELECT,
    orderBy: { completedAt: "desc" },
  });

export const getDrill = async (userId: string, drillId: string) => {
  const drill = await prisma.emergencyDrill.findFirst({
    where: { id: drillId, userId },
    select: DRILL_SELECT,
  });
  if (!drill) throw new HttpError(404, "Drill not found");
  return drill;
};

export const createDrill = async (
  userId: string,
  input: CreateEmergencyDrillInput,
) => {
  // Verify the linked plan belongs to this user, if provided.
  if (input.planId) {
    const plan = await prisma.emergencyPlan.findFirst({
      where: { id: input.planId, userId },
      select: { id: true },
    });
    if (!plan) throw new HttpError(404, "Plan not found");
  }

  return prisma.emergencyDrill.create({
    data: {
      userId,
      title: input.title,
      ...(input.planId ? { planId: input.planId } : {}),
      ...(input.notes ? { notes: input.notes } : {}),
      ...(input.completedAt
        ? { completedAt: new Date(input.completedAt) }
        : {}),
      ...(input.durationMinutes
        ? { durationMinutes: input.durationMinutes }
        : {}),
    },
    select: DRILL_SELECT,
  });
};

export const deleteDrill = async (userId: string, drillId: string) => {
  const existing = await prisma.emergencyDrill.findFirst({
    where: { id: drillId, userId },
    select: { id: true },
  });
  if (!existing) throw new HttpError(404, "Drill not found");

  await prisma.emergencyDrill.delete({ where: { id: drillId } });
};

// ---------------------------------------------------------------------------
// Ready-tab summary (completion state for the frontend score)
// ---------------------------------------------------------------------------

export const getReadySummary = async (userId: string) => {
  const [planCount, drillCount] = await Promise.all([
    prisma.emergencyPlan.count({ where: { userId } }),
    prisma.emergencyDrill.count({ where: { userId } }),
  ]);

  return {
    hasPlan: planCount > 0,
    hasDrill: drillCount > 0,
    planCount,
    drillCount,
  };
};

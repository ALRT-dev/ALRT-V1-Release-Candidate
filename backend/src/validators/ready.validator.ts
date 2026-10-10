import z from "zod";

// ---------------------------------------------------------------------------
// Emergency Plan
// ---------------------------------------------------------------------------

const planItemSchema = z.object({
  text: z.string().min(1).max(200),
  checked: z.boolean(),
});

export const createEmergencyPlanSchema = z.object({
  title: z.string().min(1).max(100),
  meetingPoint: z.string().max(500).optional(),
  evacuationRoute: z.string().max(500).optional(),
  notes: z.string().max(2000).optional(),
  items: z.array(planItemSchema).max(50).optional(),
});

export type CreateEmergencyPlanInput = z.infer<typeof createEmergencyPlanSchema>;

export const updateEmergencyPlanSchema = createEmergencyPlanSchema.partial();

export type UpdateEmergencyPlanInput = z.infer<typeof updateEmergencyPlanSchema>;

// ---------------------------------------------------------------------------
// Emergency Drill
// ---------------------------------------------------------------------------

export const createEmergencyDrillSchema = z.object({
  title: z.string().min(1).max(100),
  planId: z.string().uuid().optional(),
  notes: z.string().max(2000).optional(),
  completedAt: z.string().datetime().optional(),
  durationMinutes: z.number().int().min(1).max(1440).optional(),
});

export type CreateEmergencyDrillInput = z.infer<typeof createEmergencyDrillSchema>;

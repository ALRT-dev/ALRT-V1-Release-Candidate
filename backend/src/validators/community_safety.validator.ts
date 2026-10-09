import z from "zod";

/**
 * A fixed reason list, deliberately with no free-text field: it keeps flags
 * useful for triage and stops the flag itself becoming a channel for abuse.
 */
export const flagHazardSchema = z.object({
  reason: z.enum([
    "inappropriate",
    "misleading",
    "spam",
    "harassment",
    "other",
  ]),
});

export type FlagHazardInput = z.infer<typeof flagHazardSchema>;

// Alerts hide who posted them, so a person is blocked either by naming an
// account they already know (userId) or from the alert itself (hazardId).
export const blockUserSchema = z
  .object({
    userId: z.string().min(1).optional(),
    hazardId: z.string().min(1).optional(),
  })
  .refine((v) => !!v.userId || !!v.hazardId, {
    message: "userId or hazardId is required",
  });

export type BlockUserInput = z.infer<typeof blockUserSchema>;

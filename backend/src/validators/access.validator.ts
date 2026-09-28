import { z } from "zod";

/** "I'm about to buy this group plan for this group" (before checkout). */
export const createSponsorshipIntentSchema = z.object({
  circleId: z.string().uuid("A group must be chosen"),
  tier: z.enum(["family", "group20", "group50"]),
});

export type CreateSponsorshipIntentInput = z.infer<
  typeof createSponsorshipIntentSchema
>;

/** Apply an already-verified, unbound group purchase to one group. */
export const bindSponsorshipSchema = z.object({
  circleId: z.string().uuid("A group must be chosen"),
});

export type BindSponsorshipInput = z.infer<typeof bindSponsorshipSchema>;

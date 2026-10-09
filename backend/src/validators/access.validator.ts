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
  // Explicit recovery: replace the payer's own smaller plan on that group.
  replaceExisting: z.boolean().optional(),
});

/** After Restore: the product ids the store reported (looked up only). */
export const reconcileSchema = z.object({
  productIds: z.array(z.string().min(1).max(200)).max(20).optional(),
});

export type BindSponsorshipInput = z.infer<typeof bindSponsorshipSchema>;

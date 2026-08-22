import z from "zod";

export const getNotificationsFeedSchema = z.object({
  searchString: z.string().optional(),

  categoryIds: z.string().optional(), // Comma-separated list of UUIDs

  locationIds: z.string().optional(), // Comma-separated list of location subscription UUIDs

  awsEmergency: z
    .string()
    .regex(/^(true|false)$/, "awsEmergency must be 'true' or 'false'")
    .optional(),

  awsWatchAndAct: z
    .string()
    .regex(/^(true|false)$/, "awsWatchAndAct must be 'true' or 'false'")
    .optional(),

  awsAdvice: z
    .string()
    .regex(/^(true|false)$/, "awsAdvice must be 'true' or 'false'")
    .optional(),

  officialNonAws: z
    .string()
    .regex(/^(true|false)$/, "officialNonAws must be 'true' or 'false'")
    .optional(),

  userReported: z
    .string()
    .regex(/^(true|false)$/, "userReported must be 'true' or 'false'")
    .optional(),

  reviewStatus: z.enum(["accepted", "rejected"]).optional(),

  page: z.string().regex(/^\d+$/, "Page must be a number").optional(),

  // Previously no upper bound at all - the feed ultimately calls the same
  // getHazardsApplyingFiltersRaw() as GET /api/hazards, so it gets the same
  // bound that route's schema already uses.
  pageSize: z
    .string()
    .regex(/^\d+$/, "Page size must be a number")
    .refine(
      (val) => {
        const n = parseInt(val, 10);
        return !Number.isNaN(n) && n >= 1 && n <= 5000;
      },
      { message: "Page size must be between 1 and 5000" },
    )
    .optional(),

  showExpired: z
    .string()
    .regex(/^(true|false)$/, "showExpired must be 'true' or 'false'")
    .optional(),

  sortSettings: z
    .array(
      z.object({
        severityBand: z.enum(["asc", "desc"]).optional(),
        distance: z.enum(["asc", "desc"]).optional(),
        createdAt: z.enum(["asc", "desc"]).optional(),
        updatedAt: z.enum(["asc", "desc"]).optional(),
        confidenceScore: z.enum(["asc", "desc"]).optional(),
      }),
    )
    .optional(),
});

export type GetNotificationsFeedQuery = z.infer<
  typeof getNotificationsFeedSchema
>;

export const pushNotificationTokenSchema = z.object({
  token: z.string().min(1, "Device token is required"),

  platform: z.string().optional(),
});

export type PushNotificationTokenInput = z.infer<
  typeof pushNotificationTokenSchema
>;

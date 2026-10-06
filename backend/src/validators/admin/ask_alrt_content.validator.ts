import z from "zod";

/**
 * Shape checks only. The content rules (locked copy: no phone numbers, no en
 * or em dashes, length limits, number format) live in
 * utils/ask_alrt_content.util.ts so the verify script can run them with no
 * server. The controller passes the parsed body straight to that validator.
 */
export const askAlrtEntryIdParamsSchema = z.object({
  id: z.string().min(1, "Id is required").max(60, "Id is too long"),
});

export const saveAskAlrtEntryBodySchema = z.object({
  triggers: z.array(z.string()).optional(),
  keywords: z.array(z.string()).optional(),
  answer: z.string(),
  enabled: z.boolean().optional(),
});

export const saveEmergencyNumberBodySchema = z.object({
  iso: z.string().min(1, "Country code is required"),
  number: z.string().min(1, "Number is required"),
  name: z.string().min(1, "Country name is required"),
});

export const emergencyNumberIsoParamsSchema = z.object({
  iso: z.string().min(2, "Country code is required").max(2, "Country code must be two letters"),
});

/** Body of an Ask ALRT question (app and Admin Portal test page share this). */
export const askAlrtBodySchema = z.object({
  question: z.string().min(1, "A question is required").max(2000, "Question is too long"),
  history: z
    .array(z.object({ role: z.enum(["user", "assistant"]), content: z.string().max(4000) }))
    .max(40)
    .optional(),
  emergencyNumber: z.string().max(8).optional(),
  nearbyAlerts: z
    .array(
      z.object({
        id: z.string().min(1).max(100),
        title: z.string().max(300),
        category: z.string().max(100).optional(),
        severity: z.string().max(100).optional(),
        source: z.string().max(200).optional(),
      }),
    )
    .max(10)
    .optional(),
  context: z.string().max(2000).optional(),
  language: z.string().max(20).optional(),
  timeZone: z.string().max(64).optional(),
  utcOffsetMinutes: z.number().int().min(-720).max(840).optional(),
});

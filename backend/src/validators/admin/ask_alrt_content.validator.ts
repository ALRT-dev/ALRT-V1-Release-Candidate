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

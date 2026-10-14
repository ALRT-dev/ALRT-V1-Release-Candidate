import type { HazardSeverity, HazardSeverityBand } from "@prisma/client";

/**
 * Categories that are information only: whatever the text says, they never
 * rise above Info (owner ruling 2026-10-14: "if it is an information piece it
 * should be capped at the info level"). Planned burns are also forced to Info
 * by the planned override; this makes the cap hold for the category itself.
 * A fire alarm or false alarm needs its own category before it can be listed.
 */
export const INFO_ONLY_CATEGORY_IDS: ReadonlySet<string> = new Set([
  "plannedBurn",
  "fireWeather",
  "fireAlarm",
]);

export const capForInfoOnlyCategory = <T extends { severityBand?: HazardSeverityBand | undefined; severity?: HazardSeverity | undefined }>(
  categoryId: string | null | undefined,
  values: T,
): T =>
  categoryId && INFO_ONLY_CATEGORY_IDS.has(categoryId)
    ? { ...values, severityBand: "info" as HazardSeverityBand, severity: "info" as HazardSeverity }
    : values;

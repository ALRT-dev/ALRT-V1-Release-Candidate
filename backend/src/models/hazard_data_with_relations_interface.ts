import type { HazardCategory, HazardSource, Prisma } from "@prisma/client";

export type HazardDataWithRelations = Omit<
  Prisma.HazardCreateInput,
  "category" | "source"
> & {
  category?: HazardCategory | null;
  source?: HazardSource | null;
  /** Transient verbatim agency instruction fields. Never sent to Prisma directly. */
  sourceInstructionBlocks?: string[];
};

import prisma from "../utils/prisma_client.util.js";
import type { GuidanceKind, GuidanceRow } from "../utils/guidance_library.util.js";

/**
 * Read side of the shared guidance library: approved records only, cached
 * for five minutes. Kept separate from the admin service so Ask ALRT, Learn
 * and alerts can read the library without loading the admin machinery.
 */
let cache: { at: number; rows: GuidanceRow[] } | null = null;

export const approvedRecords = async (kind?: GuidanceKind): Promise<GuidanceRow[]> => {
  if (!cache || Date.now() - cache.at > 5 * 60_000) {
    try {
      const rows = await (prisma as any).guidanceRecord?.findMany({ where: { status: "approved" } });
      cache = { at: Date.now(), rows: Array.isArray(rows) ? rows : [] };
    } catch (err) {
      console.warn("guidance library unavailable", (err as Error)?.message);
      return [];
    }
  }
  return kind ? cache.rows.filter((r) => r.kind === kind) : cache.rows;
};

export const clearGuidanceCache = (): void => {
  cache = null;
};

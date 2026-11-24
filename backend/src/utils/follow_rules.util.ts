/**
 * Server-side Follow (owner decision D7, 16 Nov 2026; widened by the owner
 * 24 Nov 2026: "they should get an alert if they have followed the alert").
 * A followed alert pushes when its agency level changes, when the agency
 * publishes any other update (a new source update, as recorded by
 * withSourceHistory), and once when it ends. These pure rules decide which,
 * so no follower gets a push for an unchanged alert.
 */
export interface FollowedState {
  title: string;
  level: string | null; // the agency's own level only
  ended: boolean;
  /** The newest recorded source update (contentDetails.sourceUpdate). */
  update?: { summary: string; detectedAt: string } | null;
}

export type FollowEvent =
  | { kind: "none" }
  | { kind: "level"; title: string; body: string; level: string }
  | { kind: "update"; title: string; body: string; detectedAt: string }
  | { kind: "ended"; title: string; body: string };

/** The newest source update stored on an alert, if any. */
export const latestUpdateOf = (contentDetails: unknown): { summary: string; detectedAt: string } | null => {
  if (!contentDetails || typeof contentDetails !== "object") return null;
  const u = (contentDetails as { sourceUpdate?: unknown }).sourceUpdate as { summary?: unknown; detectedAt?: unknown } | undefined;
  return u && typeof u.summary === "string" && typeof u.detectedAt === "string" ? { summary: u.summary, detectedAt: u.detectedAt } : null;
};

/**
 * The agency's own level. ALRT never writes a level the source did not set
 * (owner rule, 13 Nov 2026), so an alert without one only pushes when it ends.
 */
export const levelOf = (h: { nativeWarningLevel?: string | null }): string | null =>
  h.nativeWarningLevel?.trim() || null;

const ENDED_WORDS = /\b(no longer a threat|cancelled|canceled|safe to return|all clear|ended|downgraded to no threat)\b/i;

export const isEnded = (h: { expiresAt?: Date | null; nativeWarningLevel?: string | null }, now: Date): boolean =>
  Boolean((h.expiresAt && h.expiresAt.getTime() <= now.getTime()) || (h.nativeWarningLevel && ENDED_WORDS.test(h.nativeWarningLevel)));

/**
 * [lastUpdateAt] is the detectedAt of the last update this follower was told
 * about ("" when the alert had none at follow time). null means the row
 * predates update pushes: it takes a silent baseline instead of a push.
 */
export const followEvent = (lastLevel: string | null, now: FollowedState, lastUpdateAt: string | null = ""): FollowEvent => {
  const title = now.title.slice(0, 80);
  if (now.ended) return { kind: "ended", title: "Alert ended", body: `${title} has ended.` };
  if (now.level && now.level.toLowerCase() !== (lastLevel ?? "").toLowerCase())
    return { kind: "level", title: "Alert updated", body: `${title} is now ${now.level}.`, level: now.level };
  const u = now.update;
  if (u && lastUpdateAt !== null && u.detectedAt !== lastUpdateAt) {
    const summary = u.summary.length > 140 ? `${u.summary.slice(0, 139)}…` : u.summary;
    return { kind: "update", title: "Alert updated", body: `${title}: ${summary}`, detectedAt: u.detectedAt };
  }
  return { kind: "none" };
};

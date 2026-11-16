/**
 * Server-side Follow (owner decision D7, 16 Nov 2026). A followed alert
 * sends one push when its level changes and one when it ends. These pure
 * rules decide which, so no follower gets a push for an unchanged alert.
 */
export interface FollowedState {
  title: string;
  level: string | null; // the agency's own level only
  ended: boolean;
}

export type FollowEvent =
  | { kind: "none" }
  | { kind: "level"; title: string; body: string; level: string }
  | { kind: "ended"; title: string; body: string };

/**
 * The agency's own level. ALRT never writes a level the source did not set
 * (owner rule, 13 Nov 2026), so an alert without one only pushes when it ends.
 */
export const levelOf = (h: { nativeWarningLevel?: string | null }): string | null =>
  h.nativeWarningLevel?.trim() || null;

const ENDED_WORDS = /\b(no longer a threat|cancelled|canceled|safe to return|all clear|ended|downgraded to no threat)\b/i;

export const isEnded = (h: { expiresAt?: Date | null; nativeWarningLevel?: string | null }, now: Date): boolean =>
  Boolean((h.expiresAt && h.expiresAt.getTime() <= now.getTime()) || (h.nativeWarningLevel && ENDED_WORDS.test(h.nativeWarningLevel)));

export const followEvent = (lastLevel: string | null, now: FollowedState): FollowEvent => {
  const title = now.title.slice(0, 80);
  if (now.ended) return { kind: "ended", title: "Alert ended", body: `${title} has ended.` };
  if (now.level && now.level.toLowerCase() !== (lastLevel ?? "").toLowerCase())
    return { kind: "level", title: "Alert updated", body: `${title} is now ${now.level}.`, level: now.level };
  return { kind: "none" };
};

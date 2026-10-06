/**
 * Ask ALRT — structured alert citations.
 *
 * Ported from backendV2's native Ask ALRT port's `referencedAlerts` idea
 * (V1_RECONCILIATION_REPORT S13), reimplemented against this service's own
 * Firebase/Anthropic architecture instead of that port's direct-Postgres
 * grounding, per the audit's recommendation: the client already has the
 * real hazard objects locally, so the model only needs to say WHICH of the
 * alerts it was given it actually used - it never needs to be trusted for
 * their title/source/severity, and the callable never needs its own
 * database access to verify them.
 *
 * The model is asked (see askAlrt.ts's contextBlock) to end its answer with
 * a line `USED_ALERT_IDS: id1,id2` naming which of the alerts it was given
 * it relied on, or omit the line entirely if it used none. This module
 * pulls that line out of the raw response and validates every id against
 * the alerts that were actually sent this turn - an id the model invents
 * is dropped rather than trusted.
 */
const USED_IDS_LINE = /\n?USED_ALERT_IDS:\s*([^\n]*)\s*$/i;

export function extractUsedAlertIds(
  rawText: string,
  sentAlertIds: readonly string[]
): { answer: string; usedAlertIds: string[] } {
  const match = rawText.match(USED_IDS_LINE);
  if (!match) return { answer: rawText.trim(), usedAlertIds: [] };

  const answer = rawText.slice(0, match.index).trim();
  const known = new Set(sentAlertIds);
  const usedAlertIds = match[1]
    .split(",")
    .map((id) => id.trim())
    .filter((id) => id !== "" && known.has(id));

  return { answer, usedAlertIds };
}

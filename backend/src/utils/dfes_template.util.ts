import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";
import { buildDfesSmokeBulletin } from './dfes_bulletin.util.js';

/**
 * Deterministic, zero-AI content for WA DFES warnings. DFES publishes one
 * block that holds the facts and its own "WHAT TO DO" list. The facts become
 * What we know (1 to 3 points) and the agency's own instructions become
 * What to do (up to 3 points), word for word. Nothing is added, softened or
 * invented, so a model failure can no longer leave a warning with raw text
 * in one box and no advice in the other.
 *
 * Returns null when the text is not a DFES warning block (incidents have no
 * level and no instructions), so the caller keeps its normal path.
 */

const MAX_POINTS = 4;

const META_LINE = /^(warning type|region|issued|updated|status)\s*:/i;
const ACTION_HEADING = /^(what to do|what you should do)\s*:?\s*$/i;
const STOP_HEADING =
  /^(road closures?( and conditions)?|keep up to date|extra information|animal welfare|what (emergency services|firefighters) are doing|bushfire behaviour|cyclone details|more information|end)\s*:?\s*$/i;
const BULLET = /^[•·*-]\s*/;

export const parseDfesWarning = (
  description: string,
): { facts: string[]; actions: string[] } | null => {
  if (!/^\s*warning type\s*:/i.test(description)) return null;
  const facts: string[] = [];
  const actions: string[] = [];
  let mode: "facts" | "actions" | "other" = "facts";
  let condition = '';
  for (const raw of description.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line) continue;
    if (ACTION_HEADING.test(line)) {
      mode = "actions";
      continue;
    }
    if (STOP_HEADING.test(line)) {
      mode = "other";
      continue;
    }
    if (mode === 'actions' && !BULLET.test(line) &&
        /^(?:if|when|for)\b/i.test(line) && !/[.!?]$/.test(line)) {
      condition = line;
      continue;
    }
    // Do not silently discard an unrecognised audience heading or wrapped
    // instruction. Leave an ambiguous format to the source-preserving path.
    if (mode === 'actions' && !BULLET.test(line)) return null;
    if (META_LINE.test(line)) continue;
    const text = line.replace(BULLET, "").trim();
    if (!text) continue;
    if (mode === "facts" && facts.length < MAX_POINTS) facts.push(text);
    // Only bulleted lines are instructions; a bare line under WHAT TO DO is a
    // sub-heading such as "If driving".
    else if (mode === "actions" && BULLET.test(line)) {
      actions.push([condition, text].filter(Boolean).join(' '));
    }
  }
  return { facts, actions };
};

/** The Australian Warning System level a DFES warning carries. The feed's own
 * warning type wins; otherwise the level named in the agency title. An AWS
 * warning must always state its level (owner, 9 November 2026). */
export const dfesAwsLevel = (title: string, nativeLevel?: string | null, description = ''): string | null => {
  const warningType = /^\s*warning type\s*:\s*(.+)$/im.exec(description)?.[1] ?? '';
  const pattern = /\b(emergency warning|watch\s+(?:and|&)\s+act|advice)\b/i;
  const match = [(nativeLevel ?? '').trim(), title, warningType].map(text => pattern.exec(text)).find(Boolean);
  if (!match) return nativeLevel?.trim() || null;
  const word = match[1]!.toLowerCase();
  return word.startsWith('emergency') ? 'Emergency Warning' : word.startsWith('watch') ? 'Watch and Act' : 'Advice';
};

export const getDeterministicDfesContent = ({
  title,
  description,
  nativeWarningLevel,
}: {
  title: string;
  description: string;
  nativeWarningLevel?: string | null | undefined;
}): AISummaryResponse | null => {
  const level = dfesAwsLevel(title, nativeWarningLevel, description);
  const smoke = buildDfesSmokeBulletin(title, description);
  if (smoke) return level ? { ...smoke, contentDetails: { ...smoke.contentDetails, nativeLevel: level } } : smoke;
  const parsed = parseDfesWarning(description);
  if (!parsed || parsed.facts.length === 0) return null;
  const contentDetails = {
    schemaVersion: 1, templateVersion: 0, facts: parsed.facts,
    affectedAreas: [], nativeLevel: level, officialActions: parsed.actions,
    alrtSuggestions: [], profileGuidance: [], evidence: parsed.facts,
    originalSourceText: description, extractionMethod: 'dfes-native-warning',
    profileGuidancePolicy: 'bundledFallback',
  };
  return {
    title,
    summary: parsed.facts.map((f) => `• ${f}`).join("\n"),
    callsToAction: parsed.actions,
    confidence: "high",
    contentDetails,
  };
};

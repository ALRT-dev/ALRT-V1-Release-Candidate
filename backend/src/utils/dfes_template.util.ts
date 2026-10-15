import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

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

const MAX_POINTS = 3;

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
    if (META_LINE.test(line)) continue;
    const text = line.replace(BULLET, "").trim();
    if (!text) continue;
    if (mode === "facts" && facts.length < MAX_POINTS) facts.push(text);
    // Only bulleted lines are instructions; a bare line under WHAT TO DO is a
    // sub-heading such as "If driving".
    else if (mode === "actions" && BULLET.test(line) && actions.length < MAX_POINTS) {
      actions.push(text);
    }
  }
  return { facts, actions };
};

export const getDeterministicDfesContent = ({
  title,
  description,
}: {
  title: string;
  description: string;
}): AISummaryResponse | null => {
  const parsed = parseDfesWarning(description);
  if (!parsed || parsed.facts.length === 0) return null;
  return {
    title,
    summary: parsed.facts.map((f) => `• ${f}`).join("\n"),
    callsToAction: parsed.actions,
    confidence: "high",
  };
};

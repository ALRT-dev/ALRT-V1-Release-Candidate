import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

/**
 * Deterministic, zero-AI content for WA DFES warnings. DFES publishes one
 * block that holds the facts and its own "WHAT TO DO" list. The facts become
 * What we know (1 to 3 points) and the agency's own instructions become
 * What to do (all instruction blocks), word for word. Nothing is added, softened or
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

/** The incident adapter's closed metadata format contains no instruction field.
 * Unknown/free-text lines must use the full extraction/fallback path instead.
 */
export const parseDfesIncident = (description: string): string[] | null => {
  const lines = description.split(/\r?\n/).map(x => x.trim()).filter(Boolean);
  if (!/^Incident Type:\s*\S/i.test(lines[0] ?? "")) return null;
  if (lines.some(x => !/^(Incident Type|Location|Local government area|Region|Reported|Source):\s*\S/i.test(x))) return null;
  return lines.filter(x => /^(Incident Type|Location|Local government area):/i.test(x)).slice(0, 3);
};

export const parseDfesWarning = (
  description: string,
): { facts: string[]; actions: string[] } | null => {
  if (!/^\s*warning type\s*:/i.test(description)) return null;
  const facts: string[] = [];
  const actions: string[] = [];
  let instructionBlock: string[] = [];
  const flushInstructions = () => {
    if (instructionBlock.length) actions.push(instructionBlock.join("\n"));
    instructionBlock = [];
  };
  let mode: "facts" | "actions" | "other" = "facts";
  for (const raw of description.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line) continue;
    if (ACTION_HEADING.test(line)) {
      mode = "actions";
      continue;
    }
    if (STOP_HEADING.test(line)) {
      flushInstructions();
      mode = "other";
      continue;
    }
    if (META_LINE.test(line)) continue;
    const text = line.replace(BULLET, "").trim();
    if (!text) continue;
    if (mode === "facts" && facts.length < MAX_POINTS) facts.push(text);
    // Keep conditional headings and every following bullet together. A new
    // conditional heading starts a new block; wrapped text stays in its block.
    else if (mode === "actions") {
      if (!BULLET.test(line)) {
        if (/^(if\b|for\b|people\b|those\b)/i.test(line)) flushInstructions();
        instructionBlock.push(line);
      } else if (instructionBlock.length) {
        instructionBlock.push(line);
      } else {
        actions.push(text);
      }
    }
  }
  flushInstructions();
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
    // Scope may precede WHAT TO DO, including after the three summary facts.
    // Keep the entire agency warning as one instruction block so no condition,
    // road closure or exception is detached from its directions.
    callsToAction: parsed.actions.length ? [description.trim()] : [],
    confidence: "high",
  };
};

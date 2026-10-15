import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

/**
 * Deterministic, zero-AI content for GDACS (Global Disaster Alert and
 * Coordination System) events. GDACS is a pass-through source: its Green,
 * Orange or Red level is carried verbatim and never inferred, softened or
 * raised (classification standard section 7). The card text is a template
 * keyed on the level and the disaster type, so it is reviewed once and
 * rendered every time.
 *
 * Owner rulings applied (2026-10-14): plain English, 2 to 3 points, no
 * ALRT-authored advice (only the standing wording from standard section 7),
 * no emergency phone numbers, no all-clear, "a good idea" never "advisable".
 * If the level or disaster type cannot be read from the text this returns
 * null and the caller falls back to the normal path.
 */

export type GdacsLevel = "Green" | "Orange" | "Red";

const HAZARD_WORDS: Array<{ re: RegExp; label: string }> = [
  { re: /\b(earthquake|quake|seismic)\b/i, label: "earthquake" },
  { re: /\b(tropical cyclone|cyclone|typhoon|hurricane)\b/i, label: "tropical cyclone" },
  { re: /\b(flood|flooding|flash flood)\b/i, label: "flood" },
  { re: /\b(volcano|volcanic|eruption)\b/i, label: "volcano" },
  { re: /\b(wildfire|forest fire|bushfire|wild fire)\b/i, label: "wildfire" },
  { re: /\b(drought)\b/i, label: "drought" },
];

const IMPACT: Record<GdacsLevel, { phrase: string; meaning: string }> = {
  Green: {
    phrase: "low humanitarian impact",
    meaning: "It is not expected to seriously affect people.",
  },
  Orange: {
    phrase: "medium humanitarian impact",
    meaning: "People in the area are affected; others generally are not.",
  },
  Red: {
    phrase: "high humanitarian impact",
    meaning: "It is a serious event affecting many people.",
  },
};

const ACTIONS: Record<GdacsLevel, string[]> = {
  Green: [
    "No action is indicated for most people. Those with connections to the area can stay informed through GDACS.",
    "Check GDACS for updates.",
  ],
  Orange: [
    "Local authority guidance is the reliable reference for anyone in the affected area.",
    "If you have family or contacts in the region, establishing contact is a good idea.",
  ],
  Red: [
    "Local authority instructions are the most reliable guidance for anyone in the affected area.",
    "If you have family or contacts in the region, establishing contact and encouraging them to follow official guidance is a good idea.",
  ],
};

export const parseGdacsLevel = (text: string): GdacsLevel | null => {
  const m =
    /\b(green|orange|red)\s+(?:(?:tropical|cyclone|earthquake|flood|volcano|wildfire|drought|forest|fire)\s+){0,2}(?:alert|level|impact)\b/i.exec(text) ??
    /\balert\s*(?:level)?\s*[:\-]?\s*(green|orange|red)\b/i.exec(text) ??
    /\bGDACS\s+(green|orange|red)\b/i.exec(text);
  const word = m?.[1]?.toLowerCase();
  if (word === "green") return "Green";
  if (word === "orange") return "Orange";
  if (word === "red") return "Red";
  return null;
};

export const parseGdacsHazard = (text: string): string | null => {
  for (const h of HAZARD_WORDS) if (h.re.test(text)) return h.label;
  return null;
};

export const getDeterministicGdacsContent = ({
  title,
  description,
  locationName,
}: {
  title: string;
  description: string;
  locationName?: string | null | undefined;
}): AISummaryResponse | null => {
  const text = `${title}\n${description}`;
  const level = parseGdacsLevel(text);
  const hazard = parseGdacsHazard(text);
  if (!level || !hazard) return null;
  const where = locationName && locationName.trim() ? ` near ${locationName.trim()}` : "";
  const { phrase, meaning } = IMPACT[level];
  return {
    title,
    summary: `GDACS rates this ${hazard}${where} as ${level.toLowerCase()}, ${phrase}. ${meaning}`,
    callsToAction: ACTIONS[level],
    confidence: "high",
  };
};

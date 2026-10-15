import { HazardSeverityBand } from "@prisma/client";
import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

/**
 * Deterministic, zero-AI content for Air Quality Alert category hazards
 * (WAQI-sourced today — see ingestion.service.ts's `airQualityAlert`
 * source). The classification standard's Health and Air Quality Standard
 * (§10) is explicit: "AQI cards use zero AI. Band, title, facts, and What
 * To Do all come from templates... Reviewed once by a human, rendered
 * thousands of times." Before this, AQI hazards went through the same
 * free-form AI call as every other official alert, with the model merely
 * told to "STRICTLY follow" canned example wording rather than the wording
 * being used directly and deterministically.
 *
 * The legacy fallback below now labels ALRT suggestions and defers to
 * local health advice and official fire/evacuation instructions. Published
 * templates select editable suggestions and profile rows from the reviewed
 * library. These statements are never attributed to WAQI as instructions.
 */

/**
 * The summary is the source's statement, in the source's own rating words
 * and never a number (product owner, 16 Oct 2026; purge list, pack file
 * 03): "World Air Quality Index reports that air quality near {station}
 * is {rating}." The rating comes from the description line the parser
 * wrote; the band is the fallback when that line is missing.
 */
const RATING_BY_BAND: Record<HazardSeverityBand, string> = {
  [HazardSeverityBand.info]: "good",
  [HazardSeverityBand.monitor]: "moderate",
  [HazardSeverityBand.action]: "unhealthy for sensitive groups",
  [HazardSeverityBand.critical]: "unhealthy",
};

const summaryFor = ({
  stationName,
  rating,
}: {
  stationName: string;
  rating: string;
}): string =>
  `World Air Quality Index reports that air quality near ${stationName} is ${rating}.`;

/**
 * ALRT's own practical lines, no prefix (product owner, 16 Oct 2026):
 * "Consider ..." wording, or a plain safety statement. The app labels
 * them as general guidance from ALRT under the block.
 */
const CALLS_TO_ACTION_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.info]: [],
  [HazardSeverityBand.monitor]: [
    "Consider keeping an eye on official air quality updates if you are sensitive to air pollution.",
  ],
  [HazardSeverityBand.action]: [
    "Polluted air affects people with heart or lung conditions, older adults and children first. Consider limiting long or strenuous time outdoors.",
    "If you have a breathing condition, consider keeping your usual medication within reach and following your care plan.",
  ],
  [HazardSeverityBand.critical]: [
    "Polluted air at this level can affect anyone. Consider staying indoors with windows closed and limiting time outside.",
    "Any official fire or evacuation directions take priority over this.",
    "If breathing becomes difficult, a health professional can help.",
  ],
};

/** Extracts the numeric AQI value from parseWAQIToHazards's description (machine field "AQI: 87"). Never shown to people; returns null if absent. */
export const parseAqiValueFromDescription = (
  description: string,
): number | null => {
  const match = /AQI:\s*(\d+)/.exec(description);
  if (!match || match[1] === undefined) return null;
  const value = parseInt(match[1], 10);
  return Number.isFinite(value) ? value : null;
};

/** Extracts the station name from parseWAQIToHazards's fixed-format description ("Station: X\n..."). Falls back to the given title if the format ever changes. */
export const parseStationNameFromDescription = (
  description: string,
  fallbackTitle: string,
): string => {
  const match = /Station:\s*(.+)/.exec(description);
  const name = match?.[1]?.trim();
  return name && name.length > 0 ? name : fallbackTitle;
};

/**
 * Builds the deterministic AQI card content. Confidence is always "high" —
 * there is no interpretation step to be uncertain about; the value came
 * directly from the source feed.
 */
export const getDeterministicAirQualityContent = ({
  title,
  description,
  severityBand,
}: {
  title: string;
  description: string;
  severityBand: HazardSeverityBand;
}): AISummaryResponse => {
  const stationName = parseStationNameFromDescription(description, title);
  const ratingLine = /Air quality:\s*(.+?)\s*\(World Air Quality Index rating\)/.exec(
    description,
  )?.[1]?.trim();
  const rating = (ratingLine ?? RATING_BY_BAND[severityBand]).toLowerCase();
  return {
    title,
    summary: summaryFor({ stationName, rating }),
    callsToAction: CALLS_TO_ACTION_BY_BAND[severityBand],
    confidence: "high",
  };
};

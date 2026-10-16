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

const MANDATORY_HEALTH_CLOSE =
  "This is general information. A health professional can help with personal health concerns.";

/**
 * Plain words, no number (owner instruction 2026-10-14). WAQI reports the US
 * AQI scale, so the descriptors are that scale's own: 101 to 150 unhealthy
 * for sensitive groups, 151 to 200 unhealthy, 201 to 300 very unhealthy,
 * above 300 hazardous. The number stays in the source text, not on the card.
 */
const SUMMARY_BY_BAND: Record<
  HazardSeverityBand,
  (params: { stationName: string; aqiValue: number | null }) => string
> = {
  [HazardSeverityBand.info]: ({ stationName }) =>
    `Air quality is good near ${stationName}.`,
  [HazardSeverityBand.monitor]: ({ stationName }) =>
    `Air quality is moderate near ${stationName}.`,
  [HazardSeverityBand.action]: ({ stationName }) =>
    `Air quality near ${stationName} is unhealthy for sensitive groups, as reported by WAQI.`,
  [HazardSeverityBand.critical]: ({ stationName, aqiValue }) =>
    aqiValue !== null && aqiValue > 300
      ? `Air quality near ${stationName} is hazardous, as reported by WAQI.`
      : aqiValue !== null && aqiValue > 200
        ? `Air quality near ${stationName} is very unhealthy, as reported by WAQI.`
        : `Air quality near ${stationName} is unhealthy for everyone, as reported by WAQI.`,
};

/**
 * ALRT is not a health authority, so no ALRT-authored health directives
 * (owner decision 2026-10-14, option b): one generic pointer to the state
 * air quality service, the fixed health close, and for the Critical band
 * only the standing "call your local emergency number" line (no digits).
 */
const CHECK_UPDATES_LINE = "Check your state air quality service for updates.";

const CALLS_TO_ACTION_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.info]: [],
  [HazardSeverityBand.monitor]: [CHECK_UPDATES_LINE, MANDATORY_HEALTH_CLOSE],
  [HazardSeverityBand.action]: [CHECK_UPDATES_LINE, MANDATORY_HEALTH_CLOSE],
  [HazardSeverityBand.critical]: [
    CHECK_UPDATES_LINE,
    "If you have severe breathing difficulty or chest pain, call your local emergency number.",
    MANDATORY_HEALTH_CLOSE,
  ],
};

/** Extracts the numeric AQI value from parseWAQIToHazards's fixed-format description ("...AQI: 87..."). Returns null rather than throwing if the format ever changes. */
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
  const aqiValue = parseAqiValueFromDescription(description);
  const stationName = parseStationNameFromDescription(description, title);
  // Say what is driving the reading when the station feed named it.
  const pollutant = /Main pollutant:\s*(.+)/.exec(description)?.[1]?.trim();
  const base = SUMMARY_BY_BAND[severityBand]({ stationName, aqiValue });
  return {
    title,
    summary: pollutant
      ? `${base} The main pollutant is ${pollutant}.`
      : base,
    callsToAction: CALLS_TO_ACTION_BY_BAND[severityBand],
    confidence: "high",
  };
};

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

const SUMMARY_BY_BAND: Record<
  HazardSeverityBand,
  (params: { stationName: string; aqiValue: number | null }) => string
> = {
  [HazardSeverityBand.info]: ({ stationName, aqiValue }) =>
    aqiValue !== null
      ? `Air quality is good near ${stationName} with AQI at ${aqiValue}.`
      : `Air quality is good near ${stationName}.`,
  [HazardSeverityBand.monitor]: ({ stationName, aqiValue }) =>
    aqiValue !== null
      ? `Air quality is moderate near ${stationName} with AQI at ${aqiValue}.`
      : `Air quality is moderate near ${stationName}.`,
  [HazardSeverityBand.action]: ({ stationName, aqiValue }) =>
    aqiValue !== null
      ? `Air quality is poor near ${stationName} with AQI at ${aqiValue}, as reported by WAQI.`
      : `Air quality is poor near ${stationName}, as reported by WAQI.`,
  [HazardSeverityBand.critical]: ({ stationName, aqiValue }) =>
    aqiValue !== null && aqiValue > 300
      ? `Air quality is hazardous near ${stationName} with AQI at ${aqiValue}, as reported by WAQI.`
      : aqiValue !== null
        ? `Air quality is very poor near ${stationName} with AQI at ${aqiValue}, as reported by WAQI.`
        : `Air quality is very poor near ${stationName}, as reported by WAQI.`,
};

const CALLS_TO_ACTION_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.info]: [],
  [HazardSeverityBand.monitor]: [
    "Staying across official air quality updates is advisable.",
    MANDATORY_HEALTH_CLOSE,
  ],
  [HazardSeverityBand.action]: [
    "ALRT suggests: Consider checking local health advice before strenuous outdoor activity, particularly if a breathing condition applies.",
    MANDATORY_HEALTH_CLOSE,
  ],
  [HazardSeverityBand.critical]: [
    "ALRT suggests: Consider reducing exposure to polluted air and checking local health advice. Any official fire or evacuation directions take priority.",
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

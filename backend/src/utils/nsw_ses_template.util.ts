import { HazardSeverityBand } from "@prisma/client";
import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

/**
 * Deterministic, zero-AI content for NSW State Emergency Service (SES) flood
 * warnings. Content is based on SES's published warning level guidance and
 * standard flood safety messaging. Nothing is invented; the severity band
 * drives the selection. Returns structured content matching the
 * AISummaryResponse shape so the caller keeps the same path as other
 * deterministic sources.
 *
 * Warning levels (high to low):
 *   Emergency Warning  → HazardSeverityBand.critical
 *   Flood Warning      → HazardSeverityBand.action
 *   Flood Watch        → HazardSeverityBand.monitor
 *   Information        → HazardSeverityBand.info
 */

const WHAT_WE_KNOW_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.critical]: [
    "Flood water is rising rapidly. There is an immediate threat to lives in low-lying areas.",
    "Roads in the affected area may already be cut off or flooded.",
    "Emergency services are responding. The situation is dangerous and fast-moving.",
  ],
  [HazardSeverityBand.action]: [
    "Flooding is occurring or is imminent in the area.",
    "Water levels are rising and conditions are deteriorating.",
    "There is a threat to property and possibly to lives.",
  ],
  [HazardSeverityBand.monitor]: [
    "Flooding is possible in the coming hours.",
    "Rainfall and river levels are being monitored closely.",
  ],
  [HazardSeverityBand.info]: [
    "SES is monitoring conditions in the area for possible flooding.",
  ],
};

const CALLS_TO_ACTION_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.critical]: [
    "Leave immediately if you are in a low-lying area. Flood water is rising rapidly.",
    "Do not drive through flooded roads — even shallow water can sweep a car.",
    "Call 132 500 for SES assistance if you are unable to leave.",
  ],
  [HazardSeverityBand.action]: [
    "Move people, pets, and vehicles away from areas likely to flood.",
    "Do not drive through flooded roads — even shallow water can sweep a car.",
    "Follow directions from emergency services and stay informed via this app.",
  ],
  [HazardSeverityBand.monitor]: [
    "Prepare to move valuables and essential items to a higher level.",
    "Know your local evacuation routes and have an emergency kit ready.",
    "Stay informed and monitor conditions through this app and official sources.",
  ],
  [HazardSeverityBand.info]: [
    "Stay informed and follow any directions from emergency services.",
  ],
};

const PLAIN_SUMMARY_BY_BAND: Record<HazardSeverityBand, string> = {
  [HazardSeverityBand.critical]:
    "An Emergency Warning is in place. Flood water is rising rapidly — leave immediately if you are in a low-lying area.",
  [HazardSeverityBand.action]:
    "A Flood Warning is in place. Flooding is occurring or imminent. Move away from flood-prone areas now.",
  [HazardSeverityBand.monitor]:
    "A Flood Watch is in place. Flooding is possible in the coming hours. Prepare now.",
  [HazardSeverityBand.info]:
    "NSW SES is monitoring conditions in the area. No immediate flood threat at this time.",
};

/**
 * Returns deterministic AISummaryResponse content for an NSW SES flood alert.
 * Confidence is always "high" — there is no interpretation step; content
 * comes directly from SES's own published level definitions.
 *
 * The summary field is a bullet-formatted "What we know" block. The
 * PLAIN_SUMMARY_BY_BAND string is available if a caller ever needs a single
 * plain-text line instead (e.g. for a push notification).
 */
export const getDeterministicNSWSESContent = ({
  title,
  severityBand,
}: {
  title: string;
  severityBand: HazardSeverityBand;
}): AISummaryResponse => {
  const facts = WHAT_WE_KNOW_BY_BAND[severityBand];
  return {
    title,
    summary: facts.map((f) => `• ${f}`).join("\n"),
    callsToAction: CALLS_TO_ACTION_BY_BAND[severityBand],
    confidence: "high",
  };
};

/** Plain single-line summary for a given severity band (e.g. for push notifications). */
export const getNSWSESPlainSummary = (severityBand: HazardSeverityBand): string =>
  PLAIN_SUMMARY_BY_BAND[severityBand];

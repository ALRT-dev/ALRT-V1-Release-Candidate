import { HazardSeverityBand } from "@prisma/client";
import type { AISummaryResponse } from "../models/ai_summary_response_interface.js";

/**
 * Deterministic, zero-AI content for NSW Rural Fire Service (RFS) warnings.
 * Content is drawn from RFS's own published warning level descriptions and
 * standard community messaging. Nothing is invented; the severity band drives
 * the selection. Returns structured content matching the AISummaryResponse
 * shape so the caller keeps the same path as other deterministic sources.
 *
 * Warning levels (high to low):
 *   Emergency Warning  → HazardSeverityBand.critical
 *   Watch and Act      → HazardSeverityBand.action
 *   Advice             → HazardSeverityBand.monitor
 *   Not Applicable     → HazardSeverityBand.info
 */

const WHAT_WE_KNOW_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.critical]: [
    "An Emergency Warning has been issued for a fire in the area.",
    "The fire is out of control and fast moving. You may be in danger.",
    "Conditions are changing rapidly. Threat to lives and homes is imminent.",
  ],
  [HazardSeverityBand.action]: [
    "A Watch and Act alert has been issued for a fire in the area.",
    "The fire is active and conditions are changing.",
    "There is a threat to lives and homes. Be ready to act immediately.",
  ],
  [HazardSeverityBand.monitor]: [
    "A fire is burning in the area. It is currently under control.",
  ],
  [HazardSeverityBand.info]: [
    "Firefighters are responding to a fire in the area.",
  ],
};

const CALLS_TO_ACTION_BY_BAND: Record<HazardSeverityBand, string[]> = {
  [HazardSeverityBand.critical]: [
    "Leave now if you are in the area. Do not wait to see what happens.",
    "Take your emergency kit and do not stop to collect belongings.",
    "If you cannot leave, take shelter in a solid building, away from windows.",
  ],
  [HazardSeverityBand.action]: [
    "Be ready to leave immediately if conditions change.",
    "Follow your bushfire survival plan. Know your route and destination.",
    "Stay informed via this app and the NSW RFS website.",
  ],
  [HazardSeverityBand.monitor]: [
    "Stay informed and monitor conditions through this app and official sources.",
  ],
  [HazardSeverityBand.info]: [
    "Stay informed and follow any directions from emergency services.",
  ],
};

const PLAIN_SUMMARY_BY_BAND: Record<HazardSeverityBand, string> = {
  [HazardSeverityBand.critical]:
    "An Emergency Warning has been issued. A fire is out of control in or near your area.",
  [HazardSeverityBand.action]:
    "A Watch and Act alert is in place. A fire is active and conditions may change quickly.",
  [HazardSeverityBand.monitor]:
    "A fire is burning in the area and is currently under control. Stay informed.",
  [HazardSeverityBand.info]:
    "Firefighters are responding to a fire in the area. No immediate threat at this time.",
};

/**
 * Returns deterministic AISummaryResponse content for an NSW RFS alert.
 * Confidence is always "high" — there is no interpretation step; content
 * comes directly from RFS's own published level definitions.
 *
 * The summary field is a bullet-formatted "What we know" block. The
 * PLAIN_SUMMARY_BY_BAND string is available if a caller ever needs a single
 * plain-text line instead (e.g. for a push notification).
 */
export const getDeterministicNSWRFSContent = ({
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
export const getNSWRFSPlainSummary = (severityBand: HazardSeverityBand): string =>
  PLAIN_SUMMARY_BY_BAND[severityBand];

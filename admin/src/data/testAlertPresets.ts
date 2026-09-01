import type { HazardSeverity, HazardSeverityBand } from "../api/types";

// Fixed, non-editable presets for the TEST-only "Create Test Alert" picker
// (AlertsPage.tsx, gated on VITE_ENABLE_DUMMY_ALERTS) - no free-text alert
// creator. Every preset:
//  - has a title starting with "TEST — DO NOT USE" so it's unmistakable
//    anywhere it's displayed (list, detail, push-free but still visible in
//    the app's own hazard feeds)
//  - uses the fixed Scarborough, WA 6019 coordinates the original TEST
//    dummy alert settled on (see git history: 41b2628, 9cd2bb2) - the app's
//    Map tab filters hazards by the device's current GPS-seeded viewport,
//    so these will only appear there on a device/emulator located at or
//    panned to Scarborough; the Alerts/Notifications (bell) tab is not
//    viewport-dependent and is the reliable way to confirm a preset was
//    created and is visible to the app regardless of device location.
//  - uses a real, currently-seeded category id (hazard_category.service.ts)
//    - never an invented one
//  - sets severity/severityBand explicitly so the result is deterministic,
//    not guessed from description text by getHazardAttributesFromDescription
export const SCARBOROUGH_WA_LAT = -31.89441;
export const SCARBOROUGH_WA_LNG = 115.75999;

export const TEST_ALERT_TITLE_PREFIX = "TEST — DO NOT USE";

export interface TestAlertPreset {
  id: string;
  label: string;
  title: string;
  description: string;
  categoryId: string;
  severity: HazardSeverity;
  severityBand: HazardSeverityBand;
  // Only airQualityAlert should be false (omitted) - that category already
  // has its own deterministic, zero-AI template branch inside
  // summarizeHazard, which is more representative of what a real AQI card
  // looks like than the generic passthrough. Every other preset has no
  // such branch, so it needs the explicit no-AI opt-in to avoid a real AI
  // call.
  useDummyAi: boolean;
}

export const TEST_ALERT_PRESETS: TestAlertPreset[] = [
  {
    id: "fire",
    label: "Fire",
    title: `${TEST_ALERT_TITLE_PREFIX} — Fire`,
    description:
      "TEST bushfire alert for TEST environment verification only. Not a real fire. Used to preview the Fire alert card in the app.",
    categoryId: "bushfire",
    severity: "emergency",
    severityBand: "critical",
    useDummyAi: true,
  },
  {
    id: "flood-weather",
    label: "Flood / Weather",
    title: `${TEST_ALERT_TITLE_PREFIX} — Flood/Weather`,
    description:
      "TEST flood alert for TEST environment verification only. Not a real flood. Used to preview the Flood/Weather alert card in the app.",
    categoryId: "flood",
    severity: "watchAndAct",
    severityBand: "action",
    useDummyAi: true,
  },
  {
    id: "road-traffic",
    label: "Road / Traffic",
    title: `${TEST_ALERT_TITLE_PREFIX} — Road/Traffic`,
    description:
      "TEST crash alert for TEST environment verification only. Not a real crash. Used to preview the Road/Traffic alert card in the app.",
    categoryId: "crash",
    severity: "advice",
    severityBand: "monitor",
    useDummyAi: true,
  },
  {
    id: "air-quality",
    label: "Air Quality",
    title: `${TEST_ALERT_TITLE_PREFIX} — Air Quality`,
    // Station:/AQI: lines match parseStationNameFromDescription /
    // parseAqiValueFromDescription in the backend's deterministic AQI
    // template, so this renders as a real AQI card would rather than a
    // generic passthrough - see useDummyAi: false above.
    description:
      "Station: Scarborough Test Station\nAQI: 165\nTEST air quality alert for TEST environment verification only. Not a real air quality reading. Used to preview the Air Quality alert card in the app.",
    categoryId: "airQualityAlert",
    severity: "watchAndAct",
    severityBand: "action",
    useDummyAi: false,
  },
  {
    id: "security-crime",
    label: "Security / Crime",
    title: `${TEST_ALERT_TITLE_PREFIX} — Security/Crime`,
    description:
      "TEST crime alert for TEST environment verification only. Not a real incident. Used to preview the Security/Crime alert card in the app.",
    categoryId: "crime",
    severity: "watchAndAct",
    severityBand: "action",
    useDummyAi: true,
  },
  {
    id: "health",
    label: "Health",
    title: `${TEST_ALERT_TITLE_PREFIX} — Health`,
    description:
      "TEST public health alert for TEST environment verification only. Not a real health advisory. Used to preview the Health alert card in the app.",
    categoryId: "publicHealthAlert",
    severity: "advice",
    severityBand: "monitor",
    useDummyAi: true,
  },
];

// Generous, uniform expiry so a preset stays testable for a while rather
// than expiring (and silently dropping out of every hazard feed query -
// see buildHazardsWhereClauseRaw's expiry filter) mid-session. Computed
// fresh per creation call, not baked into the preset table above.
export const testAlertExpiresAt = (): string => {
  const expiry = new Date();
  expiry.setDate(expiry.getDate() + 30);
  return expiry.toISOString();
};

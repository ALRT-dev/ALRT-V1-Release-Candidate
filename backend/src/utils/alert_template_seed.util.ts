import type { GuidanceEntry } from "./alert_templates.util.js";
import { standingGuidanceDrafts } from "./standing_guidance_drafts.util.js";

// Product-requested ALRT suggestions, reviewed during implementation. These
// are explicitly not attributed to the incident agency. Profile rows are
// scoped narrowly and never ask a person to depart against an official warning.
export const initialGuidance = (): GuidanceEntry[] => {
  const base = {
    countries: [] as string[],
    bands: ["monitor", "action", "critical"] as GuidanceEntry["bands"],
    profileTags: [] as GuidanceEntry["profileTags"],
    approved: true,
    reviewedAt: "2026-10-13",
    reference:
      "ALRT implementation review, 13 October 2026: source-linked, non-directive fallback requested by the product owner.",
  };
  return [
    ...standingGuidanceDrafts(),
    {
      ...base,
      id: "transport-preparation",
      categoryIds: ["trafficAndTransport"],
      text: "If you are travelling around the area, consider your route and allow extra time. Check official sources for updates.",
    },
    {
      ...base,
      id: "utilities-backup",
      categoryIds: ["utilitiesAndInfrastructure"],
      text: "Consider checking the provider's service updates and your backup arrangements for affected services.",
    },
    {
      ...base,
      id: "crime-local-updates",
      categoryIds: ["securityAndCrime"],
      text: "Consider checking police updates before travelling near the affected area. Any directions from police take priority.",
    },
    {
      ...base,
      id: "weather-local-plans",
      categoryIds: ["weatherAndEnvironment"],
      text: "Consider checking whether the affected area overlaps your travel or outdoor plans, and reviewing the latest agency update before setting out.",
    },
    {
      ...base,
      id: "health-advice",
      categoryIds: ["healthAndAir"],
      text: "Consider checking the health authority's advice for the affected place or activity, including any guidance for people in your care.",
    },
    {
      ...base,
      id: "community-service-update",
      categoryIds: ["communityInfo"],
      text: "Consider checking with the named service or organiser before changing your plans.",
    },
    {
      ...base,
      id: "other-source-update",
      categoryIds: ["other"],
      text: "Consider reviewing the linked source and checking whether the affected place or service is part of your plans.",
    },
    {
      ...base,
      id: "smoke-kids",
      categoryIds: ["smoke"],
      countries: ["AU"],
      profileTags: ["kids"],
      reference:
        "https://www.healthywa.wa.gov.au/Articles/S_T/Smoke-hazard-from-bushfires (ALRT suggested wording, reviewed 13 October 2026)",
      text: "Children can be more sensitive to smoke. Consider reducing their exposure while following any official fire or evacuation directions.",
    },
    {
      ...base,
      id: "smoke-medical",
      categoryIds: ["smoke"],
      countries: ["AU"],
      profileTags: ["medical"],
      reference:
        "https://www.healthywa.wa.gov.au/Articles/S_T/Smoke-hazard-from-bushfires (ALRT suggested wording, reviewed 13 October 2026)",
      text: "If a heart or lung condition applies, consider keeping your existing care plan and usual medicines accessible. Follow any official fire or evacuation directions.",
    },
    {
      ...base,
      id: "air-kids",
      categoryIds: ["airQualityAlert"],
      profileTags: ["kids"],
      text: "Consider checking children's outdoor activity plans against current local health advice.",
    },
    {
      ...base,
      id: "air-medical",
      categoryIds: ["airQualityAlert"],
      profileTags: ["medical"],
      text: "If a medical condition applies, consider following your usual care plan and checking current local health advice.",
    },
    {
      ...base,
      id: "outage-medical",
      categoryIds: ["powerOutage"],
      countries: ["AU"],
      profileTags: ["medical"],
      reference:
        "Existing Standing For You library, utility_outage; ALRT implementation review of non-directive planning wording, 13 October 2026",
      text: "If essential medical equipment uses power, consider checking your existing backup plan and the provider's outage advice.",
    },
  ];
};

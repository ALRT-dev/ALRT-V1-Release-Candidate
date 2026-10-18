import { describe, expect, it } from "vitest";
const HazardSeverity = { emergency: "emergency", info: "info", watchAndAct: "watchAndAct" } as never as Record<string, never>;
const HazardSeverityBand = { critical: "critical", info: "info", action: "action" } as never as Record<string, never>;
import { capForInfoOnlyCategory } from "../utils/info_only_category.util.js";

describe("info-only categories", () => {
  it("caps planned burn and fire weather at Info", () => {
    for (const id of ["plannedBurn", "fireWeather"]) {
      const r = capForInfoOnlyCategory(id, { severity: HazardSeverity.emergency, severityBand: HazardSeverityBand.critical });
      expect(r.severityBand).toBe(HazardSeverityBand.info);
      expect(r.severity).toBe(HazardSeverity.info);
    }
  });
  it("leaves other categories alone", () => {
    const v = { severity: HazardSeverity.watchAndAct, severityBand: HazardSeverityBand.action };
    expect(capForInfoOnlyCategory("bushfire", v)).toEqual(v);
    expect(capForInfoOnlyCategory(undefined, v)).toEqual(v);
  });
  it("never treats an active smoke emergency as residual smoke", () => {
    const values = { severity: HazardSeverity.emergency, severityBand: HazardSeverityBand.critical };
    for (const description of [
      "Emergency Warning: toxic smoke from the factory fire. Evacuate immediately.",
      "An active smouldering factory fire is spreading.",
      "Smoke may be visible while the fire spreads.",
    ]) expect(capForInfoOnlyCategory("otherFire", values, description)).toEqual(values);
  });
  it("keeps a native warning above the informational category cap", () => {
    const values = { severity: HazardSeverity.watchAndAct, severityBand: HazardSeverityBand.action };
    expect(capForInfoOnlyCategory("plannedBurn", values, "Watch and Act: the planned burn has escaped.")).toEqual(values);
  });
  it("caps clearly identified residual smoke without a warning", () => {
    expect(capForInfoOnlyCategory("otherFire", { severityBand: HazardSeverityBand.action }, "Residual smoke after the extinguished fire.").severityBand).toBe("info");
  });
});

import { describe, expect, it } from "vitest";
import {
  getDeterministicGdacsContent,
  parseGdacsHazard,
  parseGdacsLevel,
} from "../utils/gdacs_template.util.js";

describe("GDACS template", () => {
  it("reads the level and hazard verbatim", () => {
    expect(parseGdacsLevel("Red earthquake alert in Japan")).toBe("Red");
    expect(parseGdacsLevel("Alert level: Orange")).toBe("Orange");
    expect(parseGdacsLevel("Green alert for flood")).toBe("Green");
    expect(parseGdacsLevel("no level here")).toBeNull();
    expect(parseGdacsHazard("Tropical Cyclone ABC")).toBe("tropical cyclone");
  });
  it("builds level-keyed content with 2 to 3 points", () => {
    const g = getDeterministicGdacsContent({ title: "Green earthquake alert", description: "M5.1", locationName: "Lima" })!;
    expect(g.callsToAction.length).toBeGreaterThanOrEqual(2);
    expect(g.summary).toContain("low humanitarian impact");
    const r = getDeterministicGdacsContent({ title: "Red alert tropical cyclone", description: "", locationName: null })!;
    expect(r.callsToAction.length).toBeLessThanOrEqual(3);
    expect(r.summary).toContain("high humanitarian impact");
  });
  it("never uses banned wording, numbers or all-clear", () => {
    for (const lv of ["Green", "Orange", "Red"]) {
      const c = getDeterministicGdacsContent({ title: `${lv} alert flood`, description: "" })!;
      const all = [c.summary, ...c.callsToAction].join(" ").toLowerCase();
      expect(all).not.toMatch(/advisable|\b000\b|all clear|safe to return|alrt suggest/);
    }
  });
  it("returns null when level or hazard is unreadable", () => {
    expect(getDeterministicGdacsContent({ title: "Something", description: "" })).toBeNull();
  });
});

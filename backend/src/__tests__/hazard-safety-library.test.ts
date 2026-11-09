import { describe, expect, it } from "vitest";
import { hazardSafetyLibrary } from "../utils/hazard_safety_library.util.js";
import { defaultTemplatePack, libraryEntrySchema, selectLibraryGuidance } from "../utils/alert_templates.util.js";

// Owner direction, 9 November 2026 (evening): ALRT safety advice on every alert.
describe("ALRT hazard safety library", () => {
  const library = hazardSafetyLibrary();
  it("is valid, approved and referenced", () => {
    for (const entry of library) expect(() => libraryEntrySchema.parse(entry)).not.toThrow();
    expect(new Set(library.map(x => x.id)).size).toBe(library.length);
  });
  it("never carries a number or an ALRT-originated movement direction", () => {
    for (const { text } of library) {
      expect(text).not.toMatch(/\d/);
      expect(text).not.toMatch(/\b(leave|evacuat\w*|shelter\w*|stay\s+(?:home|indoors|inside)|return\w*|relocat\w*)\b/i);
    }
  });
  it.each(["bushfire", "otherFire", "smoke", "flood", "storm", "extremeHeat", "earthquake", "crash", "roadClosure", "powerOutage", "gasLeak", "chemicalSpill", "boilWaterNotice"])(
    "gives %s at least two points at every level", categoryId => {
      const pack = defaultTemplatePack();
      for (const band of ["info", "monitor", "action", "critical"] as const) {
        const { alrtSuggestions } = selectLibraryGuidance(pack, { categoryId, parentCategoryId: null, country: "AU", band });
        expect(alrtSuggestions.length).toBeGreaterThanOrEqual(2);
        expect(alrtSuggestions.length).toBeLessThanOrEqual(4);
      }
    });
});

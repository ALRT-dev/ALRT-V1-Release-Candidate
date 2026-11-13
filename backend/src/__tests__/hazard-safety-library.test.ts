import { describe, expect, it } from "vitest";
import { hazardSafetyLibrary } from "../utils/hazard_safety_library.util.js";
import { defaultTemplatePack, libraryEntrySchema, selectLibraryGuidance } from "../utils/alert_templates.util.js";

// Draft hazard-specific advice is reviewable without becoming active.
describe("ALRT hazard safety library", () => {
  const library = hazardSafetyLibrary();
  it("is valid, referenced and unapproved until review", () => {
    for (const entry of library) expect(() => libraryEntrySchema.parse(entry)).not.toThrow();
    expect(new Set(library.map(x => x.id)).size).toBe(library.length);
  });
  it("never carries a number or an ALRT-originated movement direction", () => {
    for (const { text } of library) {
      expect(text).not.toMatch(/\d/);
      expect(text).not.toMatch(/\b(leave|evacuat\w*|shelter\w*|stay\s+(?:home|indoors|inside)|return\w*|relocat\w*)\b/i);
    }
  });
  it("does not select draft safety rows at any level", () => {
    const pack = defaultTemplatePack();
    for (const categoryId of ["bushfire", "smoke", "earthquake", "crash", "powerOutage"])
      for (const band of ["info", "monitor", "action", "critical"] as const) {
        const selected = selectLibraryGuidance(pack, { categoryId, country: "AU", band });
        expect(selected.alrtSuggestions).toEqual([]);
      }
  });
});

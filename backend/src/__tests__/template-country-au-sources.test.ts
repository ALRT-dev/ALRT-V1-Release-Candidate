import { describe, expect, it } from "vitest";
import { templateCountry, selectLibraryGuidance } from "../utils/alert_templates.util.js";

// TEST, 24 Nov 2026: Australian agencies with no country on their source
// record got no AU advice lines, so their alerts showed no ALRT advice.
const line = (id: string, categoryIds: string[]) => ({
  id, text: `${id} advice line.`, categoryIds, countries: ["AU"], bands: [], profileTags: [],
  approved: true, reviewedAt: "2026-11-16", reference: "Reviewed library",
});
const pack = { library: [line("lib-bushfire-1", ["bushfire"]), line("lib-crash-1", ["crash"])] } as any;

describe("Australian state agencies count as AU", () => {
  it.each(["actEs", "viceFire", "nswTransport", "cfs", "ntFireAndRescue", "qldFire", "waDfes"])(
    "%s with no source country is AU",
    (id) => expect(templateCountry(null, { id, country: null })).toBe("AU"),
  );

  it("keeps an explicit jurisdiction and an explicit source country", () => {
    expect(templateCountry("NZ", { id: "actEs", country: null })).toBe("NZ");
    expect(templateCountry(null, { id: "actEs", country: "Australia" })).toBe("AU");
  });

  it("global feeds stay without a country", () => {
    for (const id of ["earthquakeUsgs", "gdacsGlobal", "waqi", "canadaGovTra"]) {
      expect(templateCountry(null, { id, country: null })).toBeNull();
    }
  });

  it("an unknown source with no country stays without one", () => {
    expect(templateCountry(null, { id: "someNewFeed", country: null })).toBeNull();
  });

  it("a VIC bushfire alert with no source country now gets the AU advice", () => {
    const country = templateCountry(null, { id: "viceFire", country: null });
    const g = selectLibraryGuidance(pack, { categoryId: "bushfire", country, region: "VIC", band: "monitor" as any });
    expect(g.alrtSuggestions).toEqual(["lib-bushfire-1 advice line."]);
  });
});

import { describe, expect, it } from "vitest";
import { buildUsgsEarthquakeContent, isPlainTemplateCard, templateFirstAgencyCard, TEMPLATE_FIRST_SOURCE_IDS } from "../utils/template_first.util.js";

const quakeAdvice = ["If the ground shakes, Drop, Cover and Hold On until the shaking stops.", "Be ready for aftershocks, which can follow minutes or days later."];

describe("USGS earthquake template", () => {
  it("writes plain facts from the feed fields and ALRT advice, no model", () => {
    const card = buildUsgsEarthquakeContent({
      title: "M 5.2 - 12 km NNE of Meckering, Australia",
      description: "Location: 12 km NNE of Meckering, Australia\nMagnitude: 5.2 (mww)\nDepth: 9.87 km\nStatus: Automatic\nSignificance: 416",
      alrtSuggestions: quakeAdvice, profileGuidance: [], templateVersion: 3,
    })!;
    expect(card.contentDetails.facts).toEqual([
      "A magnitude 5.2 earthquake was recorded 12 km NNE of Meckering, Australia.",
      "It was about 10 km below the surface.",
      "This is an early automatic reading and may be revised.",
    ]);
    expect(card.contentDetails.officialActions).toEqual([]);
    expect(card.contentDetails.alrtSuggestions).toEqual(quakeAdvice);
    expect(card.summary).not.toMatch(/Significance|416/);
  });

  it("says near for a named region and returns null without a magnitude", () => {
    const card = buildUsgsEarthquakeContent({ title: "M 6.1 - Banda Sea", description: "Location: Banda Sea\nMagnitude: 6.1", alrtSuggestions: [], profileGuidance: [], templateVersion: 0 })!;
    expect(card.contentDetails.facts[0]).toBe("A magnitude 6.1 earthquake was recorded near Banda Sea.");
    expect(buildUsgsEarthquakeContent({ title: "Earthquake", description: "Location: Somewhere", alrtSuggestions: [], profileGuidance: [], templateVersion: 0 })).toBeNull();
  });
});

describe("template-first gate", () => {
  it("accepts a short plain card and rejects raw fields, shouting and thin cards", () => {
    const ok = { facts: ["A bushfire is burning near Smithton.", "Crews are working to contain it."], officialActions: ["Stay up to date with conditions."], alrtSuggestions: ["Check official updates often. Fire conditions can change quickly."] };
    expect(isPlainTemplateCard(ok)).toBe(true);
    expect(isPlainTemplateCard({ ...ok, facts: ["Road: Bruce Highway northbound", "A crash is blocking two lanes."] })).toBe(false);
    expect(isPlainTemplateCard({ ...ok, facts: ["A BUSHFIRE IS BURNING NEAR SMITHTON AND MOVING EAST.", "Crews are working to contain it."] })).toBe(false);
    expect(isPlainTemplateCard({ ...ok, facts: ["A bushfire is burning near Smithton."] })).toBe(false);
    expect(isPlainTemplateCard({ ...ok, officialActions: [], alrtSuggestions: ["One point only here."] })).toBe(false);
    expect(isPlainTemplateCard({ ...ok, facts: [ok.facts[0], "x".repeat(260)] })).toBe(false);
  });

  it("builds an agency card from the source text when it reads plainly", () => {
    const description = "A bushfire is burning near Smithton in the north west. Crews are working to contain the fire, which is moving slowly east.\n\nStay up to date with current conditions. If you are travelling in the area, drive with caution.";
    const card = templateFirstAgencyCard({ sourceText: `Bushfire - Smithton\n\n${description}`, sourceTitle: "Bushfire - Smithton", sourceDescription: description, sourceActions: [], agency: "Tasmania Fire Service", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: ["Check official updates often. Fire conditions can change quickly."], profileGuidance: [] });
    expect(card).not.toBeNull();
    expect(card!.contentDetails.facts.length).toBeGreaterThanOrEqual(2);
    expect(card!.title).toBe("Bushfire - Smithton");
    // With one agency point and no reviewed library top-up, What to do would
    // be thin, so the model writes it instead.
    expect(templateFirstAgencyCard({ sourceText: description, sourceTitle: "Bushfire - Smithton", sourceDescription: description, sourceActions: [], agency: "Tasmania Fire Service", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: [], profileGuidance: [] })).toBeNull();
  });

  it("covers the Australian agency and transport feeds, not travel or USGS", () => {
    for (const id of ["bom", "cfs", "viceFire", "qldFire", "ntFireAndRescue", "actEs", "nswTransport", "qldTraffic", "qldPark"]) expect(TEMPLATE_FIRST_SOURCE_IDS.has(id)).toBe(true);
    for (const id of ["smartraveller", "canadaGovTra", "earthquakeUsgs", "openMeteo"]) expect(TEMPLATE_FIRST_SOURCE_IDS.has(id)).toBe(false);
  });
});

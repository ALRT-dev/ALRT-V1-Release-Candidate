import { describe, expect, it } from "vitest";
import { agencyExtractionFallback, isDirectiveText, parseAgencyExtraction } from "../utils/agency_extraction.util.js";

// Owner rules, 9 November 2026 (docs/alert-rules-20261109.md).
const base = { agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, profileGuidance: [] };
const reviewed = ["Consider checking official updates.", "Consider reviewing your emergency plan."];
const empty = { title: "Update", affectedAreas: [], nativeLevel: null, officialActions: [], confidence: "medium" as const };

describe("instruction detection", () => {
  it("treats imperatives and who-should-act sentences as instructions", () => {
    expect(isDirectiveText("Leave now if the path is clear.")).toBe(true);
    expect(isDirectiveText("If you are near the fire, leave now.")).toBe(true);
    expect(isDirectiveText("Residents are advised to stay indoors.")).toBe(true);
    expect(isDirectiveText("• Avoid the area.")).toBe(true);
  });
  it("keeps facts that merely contain an action word as facts", () => {
    expect(isDirectiveText("Roads remain closed in the area.")).toBe(false);
    expect(isDirectiveText("Crews will protect homes overnight.")).toBe(false);
    expect(isDirectiveText("Firefighters are monitoring the fire.")).toBe(false);
    expect(isDirectiveText("Close to 50 homes are without power.")).toBe(false);
    expect(isDirectiveText("Watch and Act")).toBe(false);
  });
});

describe("ALRT advice is only a fallback when the agency gave none", () => {
  it("shows no ALRT suggestions when extraction is empty but the source gives directions", () => {
    const sourceText = "Smoke affects Example Road.\n\nIf you are near the fire, leave now if the path is clear.";
    const value = parseAgencyExtraction(
      { ...empty, facts: [{ text: "Smoke affects Example Road.", evidence: "Smoke affects Example Road." }] },
      { ...base, sourceText, alrtSuggestions: reviewed },
    );
    expect(value.contentDetails.officialActions).toEqual([]);
    expect(value.contentDetails.alrtSuggestions).toEqual([]);
  });
  it("still uses reviewed ALRT suggestions when the source has no directions", () => {
    const sourceText = "Smoke affects Example Road.\n\nCrews are on scene.";
    const value = parseAgencyExtraction(
      { ...empty, facts: [{ text: "Smoke affects Example Road.", evidence: "Smoke affects Example Road." }] },
      { ...base, sourceText, alrtSuggestions: reviewed },
    );
    expect(value.contentDetails.alrtSuggestions).toEqual(reviewed);
  });
});

describe("fallback never labels a fact as agency advice", () => {
  it("keeps 'remain', 'protect' and 'monitoring' sentences in What we know", () => {
    const description = "Roads remain closed in the area.\n\nCrews will protect homes overnight.\n\nFirefighters are monitoring the fire.";
    const result = agencyExtractionFallback({ ...base, sourceText: description, sourceDescription: description, alrtSuggestions: [] });
    expect(result.contentDetails.officialActions).toEqual([]);
    expect(result.contentDetails.facts).toContain("Roads remain closed in the area.");
    expect(result.callsToAction.some(line => /advises: Roads remain/.test(line))).toBe(false);
  });
});

describe("instructions are listed once, not repeated", () => {
  it("does not build cumulative copies under a heading", () => {
    const description = "Fire near Example Road.\n\nWHAT TO DO:\n\nLeave now if the path is clear.\n\nTake your emergency kit.\n\nTell others where you are going.";
    const result = agencyExtractionFallback({ ...base, sourceText: description, sourceDescription: description, alrtSuggestions: [] });
    expect(result.contentDetails.officialActions).toEqual([
      "Leave now if the path is clear.\n\nTake your emergency kit.\n\nTell others where you are going.",
    ]);
    expect(result.contentDetails.facts).toEqual(["Fire near Example Road."]);
  });
  it("never sweeps facts into an instruction's lead-in", () => {
    const sourceText = "Incident details:\n\nFire near Example Road.\n\nAvoid the area.";
    const value = parseAgencyExtraction(
      { ...empty, facts: [], officialActions: [{ text: "Avoid the area.", evidence: "Avoid the area." }] },
      { ...base, sourceText, alrtSuggestions: [] },
    );
    expect(value.contentDetails.officialActions).toEqual(["Avoid the area."]);
  });
  it("keeps a condition with each separately extracted action, once", () => {
    const sourceText = "For Example Town residents only, if the route is safe:\n\nPrepare your vehicle.\n\nLeave via Example Road.";
    const value = parseAgencyExtraction(
      { ...empty, facts: [], officialActions: [
        { text: "Prepare your vehicle.", evidence: "Prepare your vehicle." },
        { text: "Leave via Example Road.", evidence: "Leave via Example Road." },
      ] },
      { ...base, sourceText, alrtSuggestions: [] },
    );
    expect(value.contentDetails.officialActions).toEqual([sourceText]);
  });
});

import { dfesAwsLevel, getDeterministicDfesContent } from "../utils/dfes_template.util.js";
describe("an AWS warning always states its level", () => {
  it("reads the level from the feed's warning type, else the agency title", () => {
    expect(dfesAwsLevel("Bushfire Watch and Act - Example", null)).toBe("Watch and Act");
    expect(dfesAwsLevel("Bushfire - Example", "Emergency Warning")).toBe("Emergency Warning");
    expect(dfesAwsLevel("Bushfire Advice - Example", undefined)).toBe("Advice");
    expect(dfesAwsLevel("Bushfire - Example", null, "Warning Type: Bushfire Emergency Warning")).toBe("Emergency Warning");
    expect(dfesAwsLevel("Smoke alert for Example", null)).toBeNull();
  });
  it("keeps the level on deterministic DFES warning content", () => {
    const description = "Warning Type: Bushfire Watch and Act\nRegion: EXAMPLE\n• Fire near Example Road.\nWHAT TO DO\n• Leave now if the path is clear.";
    const value = getDeterministicDfesContent({ title: "Bushfire - Example", description });
    expect((value?.contentDetails as { nativeLevel?: unknown } | undefined)?.nativeLevel).toBe("Watch and Act");
  });
});

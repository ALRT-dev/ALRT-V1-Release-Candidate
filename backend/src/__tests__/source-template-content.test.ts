import { describe, expect, it } from "vitest";
import { getSourceTemplateContent } from "../utils/source_template_content.util.js";
import { defaultTemplatePack } from "../utils/alert_templates.util.js";
import type { TemplateRelease } from "../services/alert_templates.service.js";

const release: TemplateRelease = { version: 1, publishedAt: "2026-10-15", reason: "test", pack: defaultTemplatePack(), prompts: {}, routes: {} };
const base = { title: "Example warning", description: "Station: Example\nAQI: 320", categoryId: "airQualityAlert", parentCategoryId: null, sourceId: "waqi", sourceName: "WAQI", country: "AU", locationName: "Example", severityBand: "critical" as const, isAwsCompliant: false };
describe("published source templates", () => {
  it("preserves the reviewed WAQI lines and never attributes them to the source", () => {
    const legacy = getSourceTemplateContent(base)!;
    const published = getSourceTemplateContent({ ...base, release })!;
    expect(published.callsToAction).toEqual(legacy.callsToAction);
    expect(published.contentDetails?.alrtSuggestions).toEqual(legacy.callsToAction);
    expect(published.contentDetails?.officialActions).toEqual([]);
    expect(published.callsToAction.join(" ")).toContain("severe breathing difficulty");
    expect(published.callsToAction.join(" ")).toContain("state air quality service");
    expect(published.callsToAction.join(" ")).toContain("general information");
  });
  it("keeps DFES deterministic with the complete conditional actions after publishing", () => {
    const description = "Warning Type: Bushfire Emergency Warning\nFire threatens Example.\nWHAT TO DO\nIf you are east of the bridge\n• Leave now.\nIf you are west of the bridge\n• Stay indoors.";
    const published = getSourceTemplateContent({ ...base, release, description, sourceId: "waDfes", sourceName: "DFES", categoryId: "bushfire", isAwsCompliant: true })!;
    expect(published.contentDetails?.nativeLevel).toBe("Bushfire Emergency Warning");
    expect(published.contentDetails?.officialActions).toEqual([description]);
    expect(published.contentDetails?.alrtSuggestions).toEqual([]);
  });
  it("retains scope outside the three summary facts and outside WHAT TO DO", () => {
    const description = "Warning Type: Bushfire Emergency Warning\nFact one.\nFact two.\nFact three.\nThe following instructions apply only to people east of River Road.\nWHAT TO DO\n• Leave now.\nROAD CLOSURES\nDo not use the bridge.";
    const input = { ...base, sourceId: "waDfes", categoryId: "bushfire", description };
    expect(getSourceTemplateContent(input)!.callsToAction).toEqual([description]);
    expect(getSourceTemplateContent({ ...input, release })!.contentDetails?.officialActions).toEqual([description]);
  });
  it("keeps GDACS native level and fixed lines when published", () => {
    const input = { ...base, sourceId: "gdacsGlobal", categoryId: "earthquake", title: "Green earthquake alert in Japan", description: "GDACS Green earthquake alert" };
    const result = getSourceTemplateContent({ ...input, release })!;
    expect(result.callsToAction).toEqual(getSourceTemplateContent(input)!.callsToAction);
    expect(result.contentDetails?.nativeLevel).toBe("Green");
    expect(result.contentDetails?.officialActions).toEqual([]);
  });
  it("only uses the WAQI adapter for WAQI, never a health-agency smoke warning", () => {
    expect(getSourceTemplateContent({ ...base, sourceId: "waDfes", description: "Smoke is affecting Example" })).toBeNull();
  });
  it("renders structured DFES incident fields without a model inventing advice", () => {
    const description = "Incident Type: Burn Off\nLocation: Example\nLocal government area: Example Shire\nRegion: Great Southern\nReported: Thu, 15 Oct 2026 12:57:32 +0800\nSource: Department of Fire and Emergency Services WA incident feed";
    const result = getSourceTemplateContent({ ...base, sourceId: "waDfes", categoryId: "plannedBurn", severityBand: "info", release, description })!;
    expect(result.contentDetails?.facts).toEqual(["Incident Type: Burn Off", "Location: Example", "Local government area: Example Shire"]);
    expect(result.contentDetails?.officialActions).toEqual([]);
    expect(result.contentDetails?.nativeLevel).toBeNull();
  });
  it("never drops extra unrecognised lines from an incident feed", () => {
    expect(getSourceTemplateContent({ ...base, sourceId: "waDfes", description: "Incident Type: Fire\nLocation: Example\nIf you are east of the road, leave now." })).toBeNull();
  });
});

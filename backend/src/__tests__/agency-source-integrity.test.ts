import { describe, expect, it } from "vitest";
import { agencyExtractionFallback, alrtSafetyAdvice, parseAgencyExtraction } from "../utils/agency_extraction.util.js";
import { defaultTemplatePack, selectLibraryGuidance } from "../utils/alert_templates.util.js";
import { hazardSafetyLibrary } from "../utils/hazard_safety_library.util.js";

const empty = { title: "Update", facts: [], officialActions: [], affectedAreas: [], nativeLevel: null, confidence: "high" };
const options = { agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, profileGuidance: [], alrtSuggestions: [] };

describe("official source integrity", () => {
  it("rejects a model instruction which reverses a source prohibition", () => {
    expect(() => parseAgencyExtraction({ ...empty, officialActions: [{ text: "Use North Road.", evidence: "Do not use North Road." }] }, { ...options, sourceText: "Do not use North Road." })).toThrow();
  });
  it("rejects a fact which removes source negation", () => {
    expect(() => parseAgencyExtraction({ ...empty, facts: [{ text: "Homes are threatened.", evidence: "No homes are threatened." }] }, { ...options, sourceText: "No homes are threatened." })).toThrow();
  });
  it("rejects partial fact excerpts which drop a governing condition", () => {
    expect(() => parseAgencyExtraction({ ...empty, facts: [{ text: "the bridge is closed.", evidence: "If repairs begin, the bridge is closed." }] }, { ...options, sourceText: "If repairs begin, the bridge is closed." })).toThrow();
  });
  it("does not drop a condition when source text wraps onto another line", () => {
    expect(() => parseAgencyExtraction({ ...empty, facts: [{ text: "the bridge is closed.", evidence: "the bridge is closed." }] }, { ...options, sourceText: "If repairs begin,\nthe bridge is closed." })).toThrow();
  });
  it("retains wrapped conditions in model-failure facts too", () => {
    const sourceText = "If repairs begin,\nthe bridge is closed.";
    expect(agencyExtractionFallback({ ...options, sourceText, sourceDescription: sourceText }).contentDetails.facts).toEqual([sourceText]);
  });
  it("recovers instructions without turning a single-newline bulletin into advice", () => {
    const sourceText = "Fire reported in Example.\nWHAT TO DO\nAvoid North Road.\nKEEP UP TO DATE\nVisit Emergency WA.";
    const result = parseAgencyExtraction(empty, { ...options, sourceText });
    expect(result.contentDetails.officialActions).toEqual(["Avoid North Road."]);
  });
  it("keeps a complete separately supplied instruction when evidence covers only part", () => {
    const sourceText = "Avoid North Road.\n\nUse South Road.";
    const result = parseAgencyExtraction({ ...empty, officialActions: [{ text: "Avoid North Road.", evidence: "Avoid North Road." }] }, { ...options, sourceText, sourceActions: ["Avoid North Road. Use South Road."] });
    expect(result.contentDetails.officialActions.join(" ")).toContain("Use South Road.");
  });
  it("tops up with reviewed advice and never lets a model line reverse an agency direction", () => {
    const reviewed = ["Consider checking official updates.", "Consider reviewing your emergency plan."];
    const advice = alrtSafetyAdvice({ actions: ["Do not leave your home."], generated: ["Leave your home immediately."], reviewed });
    expect(advice.join(" ")).not.toMatch(/leave/i);
    expect(advice).toEqual(reviewed);
    expect(alrtSafetyAdvice({ actions: [], generated: ["Keep your phone charged."], reviewed })).toEqual(["Keep your phone charged.", ...reviewed]);
  });
  it("the safety library is approved as drafted (owner, 13 November 2026)", () => {
    expect(hazardSafetyLibrary().every(entry => entry.approved && entry.reviewedAt)).toBe(true);
    const selected = selectLibraryGuidance({ ...defaultTemplatePack(), library: hazardSafetyLibrary() }, { categoryId: "earthquake", parentCategoryId: null, country: "AU", band: "action" });
    expect(selected.alrtSuggestions.length).toBeGreaterThan(0);
  });
});

import { describe, expect, it } from "vitest";
import { previewExtraction } from "../utils/preview_extraction.util.js";
import { HttpError } from "../models/http_error.js";

const text = "A warning for Example.\n\nFor people east of the bridge only:\nLeave now.\n\nDo not use the closed crossing.";
const options = { sourceText: text, sourceTitle: "Example warning", sourceDescription: text, sourceActions: [], agency: "Agency", allowAgencyNumbers: false, templateVersion: 0, alrtSuggestions: ["This must not fill a failed extraction."], profileGuidance: [] };
describe("preview extraction fallback", () => {
  it("retains full source context and marks a failed extraction honestly", async () => {
    const result = await previewExtraction(async () => { throw new Error("Invalid model output"); }, options);
    expect(result.extractionFallback).toBe(true);
    expect(result.summary).toBe(text);
    expect(result.contentDetails?.facts).toEqual([text]);
    expect(result.callsToAction).toEqual([]);
    expect(result.contentDetails?.alrtSuggestions).toEqual([]);
  });
  it("preserves separately supplied official instructions on model failure", async () => {
    const result = await previewExtraction(async () => { throw new HttpError(500, "Model unavailable"); }, { ...options, sourceActions: [text] });
    expect(result.contentDetails?.officialActions).toEqual([text]);
  });
  it("does not conceal missing prompt configuration", async () => {
    await expect(previewExtraction(async () => { throw new HttpError(409, "No published prompt matches"); }, options)).rejects.toThrow("No published prompt");
  });
});

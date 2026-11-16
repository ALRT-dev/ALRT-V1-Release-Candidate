import { describe, expect, it } from "vitest";
import { placeInQuestion, resolvePlace, placeContextLine } from "../services/ask_alrt/place.js";
import { PLACE_CASES } from "../services/ask_alrt/place_cases.js";

describe("Ask ALRT resolves the place before answering (D1)", () => {
  it.each(PLACE_CASES)("$question -> $expected", ({ question, ctx, expected }) => {
    const p = resolvePlace(question, ctx);
    expect(p.askPlace ? null : p.jurisdiction).toBe(expected);
  });

  it("uses Bali's country when asked from Perth (owner example)", () => {
    const p = resolvePlace("road rules in Bali", { deviceCountry: "AU", deviceState: "WA" });
    expect(p).toMatchObject({ jurisdiction: "ID", basis: "question", label: "Indonesia" });
  });

  it("does not read ordinary words as places", () => {
    expect(placeInQuestion("I want to stay in touch with my family")).toBeNull();
    expect(placeInQuestion("Can I cook turkey during a power outage?")).toBeNull();
    expect(placeInQuestion("How do I help a woman who fainted?")).toBeNull();
    expect(placeInQuestion("is this a sa fire")).toBeNull();
  });

  it("tells the model which place to answer for, and never sends coordinates", () => {
    const line = placeContextLine(resolvePlace("speed limit near schools", { deviceCountry: "AU", deviceState: "WA" }));
    expect(line).toContain("Western Australia (AU-WA)");
    expect(line).not.toMatch(/-?\d+\.\d{2,}/);
  });
});

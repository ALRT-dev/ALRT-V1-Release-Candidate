import { describe, expect, it } from "vitest";
import { buildNswTrafficContent, epochMsDate, readNswTrafficFields } from "../utils/nsw_traffic_content.util.js";

// TEST, 24 Nov 2026: NSW Live Traffic made about 8,600 model calls a day and
// nearly all were rejected, so the alerts showed raw feed fields.
const library = ["Expect delays and allow extra travel time.", "Consider another route if you can.", "Follow directions from police and traffic controllers."];
const base = { agency: "Live Traffic NSW", templateVersion: 3, alrtSuggestions: library, profileGuidance: [] };

const WATER = "ADVERSE WEATHER\nIncident Kind: Unplanned\nMain Category: Adverse weather\nSub Category: Water over road\nLocation: Pacific Highway, Raymond Terrace\nAdvice: Reduce speed; Exercise caution\nOther Advice: Water is over the road in both directions. Drive to the conditions.";
const EVENT = "A-League Men\nIncident Kind: Planned\nMain Category: SPECIAL EVENT\nAdvice: Allow extra travel time\nOther Advice: Expect heavy traffic around the stadium before and after the match.";
const BARE = "CHANGED TRAFFIC CONDITIONS\nIncident Kind: Planned\nMain Category: Changed traffic conditions\nSub Category: Load limit";

describe("NSW Live Traffic card without the model", () => {
  it("reads the stored field format", () => {
    const f = readNswTrafficFields(WATER)!;
    expect(f.get("name")).toBe("ADVERSE WEATHER");
    expect(f.get("sub")).toBe("Water over road");
    expect(f.get("advice")).toBe("Reduce speed; Exercise caution");
  });

  it("writes plain facts in the agency's name and keeps its own sentences", () => {
    const c = buildNswTrafficContent({ ...base, title: "ADVERSE WEATHER Water over road", description: WATER })!;
    expect(c.contentDetails.facts).toEqual([
      "Live Traffic NSW lists water over road (adverse weather) at Pacific Highway, Raymond Terrace.",
      "Water is over the road in both directions.",
      "Drive to the conditions.",
    ]);
    expect(c.title).toBe("Adverse Weather Water Over Road");
    expect(c.contentDetails.extractionMethod).toBe("nsw-traffic-fields");
  });

  it("attributes the agency's advice to the agency, then tops up with ALRT lines to four", () => {
    const c = buildNswTrafficContent({ ...base, title: "x", description: WATER })!;
    expect(c.contentDetails.officialActions).toEqual(["Reduce speed.", "Exercise caution."]);
    expect(c.callsToAction.slice(0, 2)).toEqual(["Live Traffic NSW advises: Reduce speed.", "Live Traffic NSW advises: Exercise caution."]);
    expect(c.callsToAction).toHaveLength(4);
    expect(c.callsToAction.slice(2).every((x) => !/advises:/.test(x))).toBe(true);
  });

  it("does not repeat ALRT advice the agency already gave", () => {
    const c = buildNswTrafficContent({ ...base, alrtSuggestions: ["Allow extra travel time.", ...library], title: "A-League Men", description: EVENT })!;
    expect(c.contentDetails.facts[0]).toBe("Live Traffic NSW lists planned special event.");
    expect(c.callsToAction[0]).toBe("Live Traffic NSW advises: Allow extra travel time.");
    expect(c.callsToAction.slice(1).some((x) => /allow extra travel time/i.test(x))).toBe(false);
    expect(c.title).toBe("A-League Men");
  });

  it("still gives two to four points when the feed has no advice", () => {
    const c = buildNswTrafficContent({ ...base, title: "CHANGED TRAFFIC CONDITIONS Load limit", description: BARE })!;
    expect(c.contentDetails.facts).toEqual(["Live Traffic NSW lists planned load limit (changed traffic conditions)."]);
    expect(c.callsToAction.length).toBeGreaterThanOrEqual(2);
    expect(c.callsToAction.length).toBeLessThanOrEqual(4);
  });

  it("returns null for anything not in the field format", () => {
    expect(buildNswTrafficContent({ ...base, title: "x", description: "A plain sentence about a crash on the M1." })).toBeNull();
    expect(buildNswTrafficContent({ ...base, title: "x", description: "ONLY A NAME" })).toBeNull();
  });

  it("never writes a phone number the agency did not attribute", () => {
    const d = WATER.replace("Drive to the conditions.", "For help call 0400 123 456 now.");
    const c = buildNswTrafficContent({ ...base, title: "x", description: d })!;
    expect(c.contentDetails.facts.join(" ")).not.toMatch(/0400 123 456/);
  });
});

describe("NSW Live Traffic time", () => {
  it("reads epoch milliseconds, as a number or a string", () => {
    expect(epochMsDate(1763954400000)?.toISOString()).toBe("2025-11-24T03:20:00.000Z");
    expect(epochMsDate("1763954400000")?.toISOString()).toBe("2025-11-24T03:20:00.000Z");
  });

  it("rejects anything that is not a plausible epoch-ms time", () => {
    for (const v of [null, undefined, "", "soon", 0, 1763954400, Number.NaN]) expect(epochMsDate(v)).toBeNull();
  });
});

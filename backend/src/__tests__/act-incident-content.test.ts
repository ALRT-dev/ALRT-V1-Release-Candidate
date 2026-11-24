import { describe, expect, it } from "vitest";
import { actIncidentTime, buildActIncidentContent, calmCase, canberraOffset } from "../utils/act_incident_content.util.js";

// Real items from https://esa.act.gov.au/feeds/currentincidents.xml, 17 Nov 2026.
const AMBULANCE = "Incident: AMBULANCE RESPONSE - O'CONNOR\r\nLocation: O'CONNOR\r\nStatus: Resource Allocation Pending\r\nSuburb: O'CONNOR\r\nType: AMBULANCE RESPONSE\r\nAgency: Ambulance\r\nIncident Number: 083762-17112026\r\nUpdated: 17 Nov 2026 11:52:14.693\r\nTime of Call: 17 Nov 2026 01:02:50";
const BURN = "Incident: HAZARD REDUCTION BURN - THARWA\r\nLocation: NAAS ROAD, THARWA, 2620\n\n\r\nStatus: Resource Allocation Pending\r\nSuburb: THARWA\r\nType: HAZARD REDUCTION BURN\r\nAgency: Fire\r\nIncident Number: 018236-11112026\r\nUpdated: 15 Nov 2026 22:05:01.93\r\nTime of Call: 11 Nov 2026 10:06:26";
const library = ["Keep clear of the area so emergency crews can work.", "Check the ACT Emergency Services Agency website for updates."];
const base = { agency: "ACT Emergency Services Agency", templateVersion: 7, alrtSuggestions: library, profileGuidance: [] };

describe("ACT ESA incident adapter", () => {
  it("writes plain facts from the fields, with no model call", () => {
    const r = buildActIncidentContent({ ...base, title: "AMBULANCE RESPONSE - O'CONNOR", description: AMBULANCE })!;
    expect(r).not.toBeNull();
    expect(r.title).toBe("Ambulance Response - O'Connor");
    expect(r.contentDetails.facts).toEqual([
      "ACT Emergency Services Agency lists an ambulance response in O'Connor.",
      "Its status is resource allocation pending.",
      "The call was received at 1:02 am on 17 November (Canberra time).",
      "The agency last updated it at 11:52 am on 17 November (Canberra time).",
    ]);
    expect(r.contentDetails.officialActions).toEqual([]);
    expect(r.contentDetails.alrtSuggestions).toEqual(library);
    expect(r.contentDetails.sourceAdviceStatus).toBe("not-in-incident-feed");
  });

  it("names the street when the agency gives one and drops the postcode", () => {
    const r = buildActIncidentContent({ ...base, title: "HAZARD REDUCTION BURN - THARWA", description: BURN })!;
    expect(r.contentDetails.facts[0]).toBe("ACT Emergency Services Agency lists a hazard reduction burn in Naas Road, Tharwa.");
    expect(JSON.stringify(r.contentDetails.facts)).not.toMatch(/2620|018236|Field|:\s*[A-Z]{3}/);
  });

  it("never shows a raw Field: value line, an incident number or shouting", () => {
    const r = buildActIncidentContent({ ...base, title: "AMBULANCE RESPONSE - O'CONNOR", description: AMBULANCE })!;
    for (const fact of r.contentDetails.facts as string[]) {
      expect(fact).not.toMatch(/^[A-Za-z ]+:\s/);
      expect(fact).not.toMatch(/083762/);
      expect(fact).not.toMatch(/[A-Z]{4,}/);
    }
  });

  it("returns null for text that is not the ACT field format, so the normal path runs", () => {
    expect(buildActIncidentContent({ ...base, title: "x", description: "A grass fire is burning near the river. Avoid the area." })).toBeNull();
  });

  it("dates the alert from the call, not the feed's generation time", () => {
    // 17 Nov is daylight saving in Canberra (UTC+11).
    expect(actIncidentTime(AMBULANCE)?.toISOString()).toBe("2026-11-16T14:02:50.000Z");
    expect(canberraOffset(2026, 6, 1)).toBe(10);
    expect(canberraOffset(2026, 10, 17)).toBe(11);
  });

  it("calms shouted names", () => {
    expect(calmCase("O'CONNOR")).toBe("O'Connor");
    expect(calmCase("NAAS ROAD, THARWA")).toBe("Naas Road, Tharwa");
  });
});

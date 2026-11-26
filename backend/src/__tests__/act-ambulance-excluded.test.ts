import { describe, expect, it } from "vitest";
import { isActAmbulanceCallout } from "../utils/act_incident_content.util.js";

// Owner, 24 November 2026: ACT ambulance call-outs are never alerts, they
// could invade privacy.
const AMBULANCE = "Incident: AMBULANCE RESPONSE - O'CONNOR\r\nLocation: O'CONNOR\r\nStatus: Resource Allocation Pending\r\nSuburb: O'CONNOR\r\nType: AMBULANCE RESPONSE\r\nAgency: Ambulance\r\nIncident Number: 083762-17112026\r\nUpdated: 17 Nov 2026 11:52:14.693\r\nTime of Call: 17 Nov 2026 01:02:50";
const BURN = "Incident: HAZARD REDUCTION BURN - THARWA\r\nLocation: NAAS ROAD, THARWA, 2620\n\n\r\nStatus: Resource Allocation Pending\r\nSuburb: THARWA\r\nType: HAZARD REDUCTION BURN\r\nAgency: Fire\r\nIncident Number: 018236-11112026\r\nUpdated: 15 Nov 2026 22:05:01.93\r\nTime of Call: 11 Nov 2026 10:06:26";

describe("ACT ambulance call-outs are excluded", () => {
  it("flags an ambulance call-out", () => {
    expect(isActAmbulanceCallout(AMBULANCE)).toBe(true);
  });

  it("flags it by Agency alone or by Type alone", () => {
    expect(isActAmbulanceCallout("Type: MEDICAL\nAgency: Ambulance")).toBe(true);
    expect(isActAmbulanceCallout("Type: AMBULANCE RESPONSE\nAgency: Other")).toBe(true);
  });

  it("still flags it with the Alert Level line ingestion adds in front", () => {
    expect(isActAmbulanceCallout(`Alert Level: Advice\n${AMBULANCE}`)).toBe(true);
  });

  it("keeps fire, rescue and burn incidents", () => {
    expect(isActAmbulanceCallout(BURN)).toBe(false);
    expect(isActAmbulanceCallout("Type: STRUCTURE FIRE\nAgency: Fire")).toBe(false);
    expect(isActAmbulanceCallout("Type: VEHICLE ACCIDENT\nAgency: Rescue")).toBe(false);
  });

  it("does not trip on the word in an incident name or location", () => {
    expect(isActAmbulanceCallout("Incident: FIRE NEAR AMBULANCE STATION\nType: GRASS FIRE\nAgency: Fire")).toBe(false);
  });
});

import { describe, expect, it } from "vitest";
import { buildVicIncidentContent, isVicNonIncident, readVicFields, vicTime } from "../utils/vic_incident_content.util.js";

// TEST, 24 Nov 2026: Victorian incidents fell back to raw feed text.
// Field layout from the live VicEmergency incident RSS, 25 Nov 2026.
const library = ["Check official updates often. Fire conditions can change quickly.", "Keep clear of the area so crews can work.", "Keep your emergency kit ready."];
const base = { agency: "VicEmergency", templateVersion: 3, alrtSuggestions: library, profileGuidance: [] };

const HTML = "<strong>Incident Name:</strong> BOWDEN ST<br><strong>Territory:</strong> CFA<br><strong>Agency:</strong> CFA<br><strong>Fire District:</strong> Wimmera<br><strong>Incident No:</strong> 303875<br><strong>Date/Time:</strong> 25/11/2026 12:00:00<br><strong>Type:</strong> STRUCTURE<br><strong>Location:</strong> HORSHAM<br><strong>Status:</strong> Not Yet Under Control<br><strong>Size:</strong> SMALL<br><strong>Vehicles:</strong> 3<br><strong>Latitude:</strong> -36.71<br><strong>Longitude:</strong> 142.2<br>";
const LINES = "Incident Name: HATTAM ST\nTerritory: CFA\nAgency: CFA\nFire District: Northern Country\nIncident No: 303760\nDate/Time: 24/11/2026 16:21:00\nType: GRASS\nLocation: GOLDEN SQUARE\nStatus: Under Control\nSize: SMALL\nVehicles: 1";
const RUN_TOGETHER = "Incident Name: OLLERTON AV Territory: FRV Agency: CFA Fire District: West And South Gippsland Incident No: 303867 Date/Time: 25/11/2026 11:34:00 Type: OTHER Location: NEWBOROUGH Status: Under Control Size: SMALL Vehicles: 2";

describe("VicEmergency incident card without the model", () => {
  it("reads the fields from HTML, separate lines, or one run-on line", () => {
    expect(readVicFields(HTML)!.get("status")).toBe("Not Yet Under Control");
    expect(readVicFields(LINES)!.get("location")).toBe("GOLDEN SQUARE");
    expect(readVicFields(RUN_TOGETHER)!.get("fire district")).toBe("West And South Gippsland");
  });

  it("writes plain facts in the agency's name", () => {
    const c = buildVicIncidentContent({ ...base, title: "HORSHAM, BOWDEN ST", description: HTML })!;
    expect(c.contentDetails.facts).toEqual([
      "VicEmergency (CFA) lists a structure fire at Horsham.",
      "Its status is not yet under control and its size is listed as small.",
      "It was reported at 12:00 pm on 25 November (Victorian time).",
    ]);
    expect(c.title).toBe("Horsham, Bowden St");
    expect(c.contentDetails.extractionMethod).toBe("vic-incident-fields");
    expect(c.contentDetails.sourceReportedAt).toBe("2026-11-25T01:00:00.000Z");
  });

  it("gives ALRT advice as ALRT's, two to four points, nothing presented as the agency's", () => {
    const c = buildVicIncidentContent({ ...base, title: "x", description: LINES })!;
    expect(c.contentDetails.officialActions).toEqual([]);
    expect(c.callsToAction).toEqual(library);
    expect(c.contentDetails.facts[0]).toBe("VicEmergency (CFA) lists a grass fire at Golden Square.");
  });

  it("names an OTHER incident plainly, with FRV as the territory", () => {
    const c = buildVicIncidentContent({ ...base, title: "x", description: RUN_TOGETHER })!;
    expect(c.contentDetails.facts[0]).toBe("VicEmergency (FRV) lists an incident at Newborough.");
  });

  it("returns null for text that is not in the field format", () => {
    expect(buildVicIncidentContent({ ...base, title: "x", description: "A grass fire is burning near Horsham." })).toBeNull();
  });

  it("flags false alarms and incidents listed as safe, keeps live ones", () => {
    expect(isVicNonIncident(LINES.replace("Type: GRASS", "Type: FALSE ALARM"))).toBe(true);
    expect(isVicNonIncident(LINES.replace("Status: Under Control", "Status: Safe"))).toBe(true);
    expect(isVicNonIncident(LINES)).toBe(false);
    expect(isVicNonIncident(HTML)).toBe(false);
    expect(isVicNonIncident("Plain text with no fields.")).toBe(false);
  });

  it("converts Victorian local time with daylight saving", () => {
    expect(vicTime("25/11/2026 12:00:00")?.iso).toBe("2026-11-25T01:00:00.000Z");
    expect(vicTime("15/07/2026 09:30:00")?.iso).toBe("2026-07-14T23:30:00.000Z");
    expect(vicTime("31/02/2026 09:30:00")).toBeNull();
  });
});

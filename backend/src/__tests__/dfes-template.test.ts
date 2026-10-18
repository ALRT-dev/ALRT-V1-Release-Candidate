import { describe, expect, it } from "vitest";
import {
  getDeterministicDfesContent,
  parseDfesWarning,
} from "../utils/dfes_template.util.js";

const PALMER = `Warning Type: Bushfire Advice
Region: SOUTH WEST
A Bushfire Advice is in place for people south of Collie Williams Road near Pollard Brook in parts of PALMER in the SHIRE OF COLLIE.
• The alert level for this fire has been downgraded as fire activity has decreased.
• There is no threat to lives or homes.
• There may be smoke in the area.
WHAT TO DO
• The threat of the fire has reduced however you should take care in the area.
• Stay alert for potential dangers such as smoke and fallen trees and power poles.
• If you do not have a plan, make one now on Emergency WA.
If driving
• Turn your headlights on and drive slowly.`;

describe("DFES warning template", () => {
  it("splits facts from the agency's own instructions, verbatim", () => {
    const r = getDeterministicDfesContent({ title: "t", description: PALMER });
    expect(r).not.toBeNull();
    expect(r!.summary.split("\n")).toHaveLength(3);
    expect(r!.summary).toContain("A Bushfire Advice is in place");
    expect(r!.summary).not.toMatch(/WHAT TO DO/i);
    expect(r!.callsToAction).toEqual([PALMER]);
  });

  it("keeps conditional headings with every instruction in their block", () => {
    const r = parseDfesWarning(`Warning Type: Bushfire Emergency Warning
Fire threatens Example Town.
WHAT TO DO
If you are east of the bridge
• Leave now.
• Use Example Road.
If you are west of the bridge
• Stay indoors.
• Close windows.
ROAD CLOSURES
Example Road is open.`);
    expect(r!.actions).toEqual([
      "If you are east of the bridge\n• Leave now.\n• Use Example Road.",
      "If you are west of the bridge\n• Stay indoors.\n• Close windows.",
    ]);
  });

  it("gives no instructions when the agency gave none", () => {
    const r = parseDfesWarning("Warning Type: Smoke Alert\nRegion: X\nSmoke is in the area.");
    expect(r!.facts).toEqual(["Smoke is in the area."]);
    expect(r!.actions).toEqual([]);
  });

  it("ignores incident text", () => {
    expect(getDeterministicDfesContent({ title: "t", description: "Incident Type: Fire\nLocation: Trigg" })).toBeNull();
  });
});

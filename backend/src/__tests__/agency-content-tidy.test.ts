import { describe, expect, it } from "vitest";
import { tidyAgencyContent } from "../utils/agency_extraction.util.js";

// The DFES Storm Advice of 17 November 2026 as it reached the app: whole
// paragraphs with metadata, a heading, sub-bullets, and lines in both boxes.
const facts = [
  "STORM DETAILS\nAt 5:15am on Tuesday 17 November 2026, the Bureau of Meteorology advised severe thunderstorms have eased.",
  "Some roads may be closed.",
  "Road information may also be available from Main Roads WA by visiting the Main Roads Travel Map, calling 138 138 or by contacting your Local Government Authority.",
  "Warning Type: Storm Advice\nRegion: GOLDFIELDS/MIDLANDS, MIDWEST GASCOYNE\nA Storm Advice has been issued for parts of GOLDFIELDS MIDLANDS and MIDWEST GASCOYNE.",
];
const actions = [
  "Warning Type: Storm Advice\nRegion: GOLDFIELDS/MIDLANDS, MIDWEST GASCOYNE\nA Storm Advice has been issued for parts of GOLDFIELDS MIDLANDS and MIDWEST GASCOYNE.\nThe immediate threat has reduced however you need to be aware of potential hazards that remain after the storm has passed.",
  "• Be careful of fallen trees, damaged buildings and debris.\n• Stay away from fallen powerlines, they are dangerous and should always be treated as live.\n• Look around your home, car and property for damage.\n• If damage has occurred and you are insured, contact your insurance company and take photos.\n• If your home has significant damage, like a badly damaged roof or flooding, call the SES for assistance with temporary repairs on 132 500.\n• If you do not have a plan, make one now on Emergency WA or in the Emergency WA app to stay safe in future emergencies.\nSTORM DETAILS\nAt 5:15am on Tuesday 17 November 2026, the Bureau of Meteorology advised severe thunderstorms have eased.\nThis warning is now cancelled.",
  "Some roads may be closed.\nMotorists are asked to avoid the area, reduce speed and drive carefully. Road information may also be available from Main Roads WA by visiting the Main Roads Travel Map, calling 138 138 or by contacting your Local Government Authority.",
];

describe("tidyAgencyContent", () => {
  const out = tidyAgencyContent(facts, actions);
  const all = [...out.facts, ...out.actions];

  it("drops metadata, headings and the title restatement", () => {
    expect(all.some(l => /^warning type|^region:|^STORM DETAILS$|has been issued for/i.test(l))).toBe(false);
  });

  it("never shows a line twice", () => {
    expect(new Set(all).size).toBe(all.length);
  });

  it("puts the cancellation first and keeps every fact", () => {
    expect(out.facts[0]).toBe("This warning is now cancelled.");
    expect(out.facts).toContain("Some roads may be closed.");
    expect(out.facts.some(f => f.startsWith("At 5:15am"))).toBe(true);
  });

  it("gives one instruction per point, every bullet kept", () => {
    expect(out.actions.some(a => a.includes("\n") || a.startsWith("•"))).toBe(false);
    expect(out.actions).toContain("Be careful of fallen trees, damaged buildings and debris.");
    expect(out.actions.filter(a => /^If /.test(a))).toHaveLength(3);
    expect(out.actions.some(a => a.startsWith("Motorists are asked"))).toBe(true);
    expect(out.actions.some(a => a.startsWith("The immediate threat has reduced"))).toBe(true);
  });

  it("drops issue-time labels, the title repeat and DFES keep-up-to-date boilerplate", () => {
    const title = "Facility or Park Closure Park Closure for Nyinggulara National Park (Ex-Ningaloo) in the SHIRE OF EXMOUTH.";
    const r = tidyAgencyContent(
      [
        "Time of issue:\n01:39 PM\nDate of issue:\n30 Mar 2026\nFACILITY OR PARK CLOSURE\nPark Closure for Nyinggulara National Park (Ex-Ningaloo) in the SHIRE OF EXMOUTH.",
        "The park will be closed from 4.30pm on Wednesday 25 March until further notice.",
        "Media Contact: DBCA Media on 9219 9999.",
      ],
      [
        "• People are urged to avoid the area, follow the advice of Parks and Wildlife Service staff and observe signage.\n• People already in the area should leave for a safer place.\n• For more information, contact your local Parks and Wildlife Service office.",
        "• Visit Emergency WA or download the Emergency WA app from the App Store or Google Play.\n• Call 13 DFES (13 3337).\n• Follow DFES on Facebook.\n• Listen to ABC Local Radio, 6PR, or news bulletins.\nDuring a power outage, your home phone, computer or other electronic devices connected to the NBN will not work. Include a battery powered radio in your emergency kit.\nUpdates will be provided when the situation changes.",
      ],
      title,
    );
    expect(r.facts).toEqual(["The park will be closed from 4.30pm on Wednesday 25 March until further notice."]);
    expect(r.actions).toEqual([
      "People are urged to avoid the area, follow the advice of Parks and Wildlife Service staff and observe signage.",
      "People already in the area should leave for a safer place.",
      "For more information, contact your local Parks and Wildlife Service office.",
    ]);
  });

  it("keeps instructions under a lead-in together", () => {
    const r = tidyAgencyContent([], ["If you are driving:\n• Slow down.\n• Turn on your headlights."]);
    expect(r.actions).toEqual(["If you are driving:\n• Slow down.\n• Turn on your headlights."]);
  });
});

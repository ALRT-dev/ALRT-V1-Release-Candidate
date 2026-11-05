import { describe, expect, it } from "vitest";
import {
  defaultTemplatePack,
  templatePackSchema,
  resolveTemplate,
  chooseTemplateBand,
  selectLibraryGuidance,
  normaliseCountry,
  templateCountry,
} from "../utils/alert_templates.util.js";
import { agencyExtractionFallback, parseAgencyExtraction, removeUnattributedNumbers } from "../utils/agency_extraction.util.js";

describe("editable alert templates", () => {
  it("preserves all existing profile rows as drafts until category and wording review", () => {
    const pack = defaultTemplatePack();
    const drafts = pack.library.filter(x => x.id.startsWith("standing-"));
    expect(drafts).toHaveLength(243);
    expect(drafts.every(x => !x.approved && !x.categoryIds.length && x.reviewedAt === null)).toBe(true);
    expect(templatePackSchema.safeParse(pack).success).toBe(true);
    drafts[0]!.approved = true;
    drafts[0]!.reviewedAt = "2026-10-13";
    expect(templatePackSchema.safeParse(pack).success).toBe(false);
  });
  it("inherits defaults then country then source without copying unrelated values", () => {
    const pack = defaultTemplatePack();
    pack.overrides = [
      {
        id: "au",
        name: "Australia",
        country: "AU",
        sourceId: null,
        settings: { language: "en-AU" },
      },
      {
        id: "roads",
        name: "Road authority",
        country: "AU",
        sourceId: "roads",
        settings: { additionalInstructions: "Keep road names." },
      },
    ];
    const result = resolveTemplate(pack, { country: "au", sourceId: "roads" });
    expect(result.settings.language).toBe("en-AU");
    expect(result.settings.additionalInstructions).toBe("Keep road names.");
    expect(result.settings.bandColors.critical).toBe("#D6001C");
    expect(result.applied).toEqual([
      "Shared default",
      "Australia",
      "Road authority",
    ]);
    expect(
      resolveTemplate(pack, { country: "NZ", sourceId: "roads" }).applied,
    ).toEqual(["Shared default"]);
  });
  it("rejects ambiguous overrides and unsupported shape settings", () => {
    const pack = defaultTemplatePack();
    pack.overrides = [
      { id: "a", name: "AU", country: "AU", sourceId: null, settings: {} },
      {
        id: "b",
        name: "AU again",
        country: "AU",
        sourceId: null,
        settings: {},
      },
    ];
    expect(templatePackSchema.safeParse(pack).success).toBe(false);
    expect(
      templatePackSchema.safeParse({ ...defaultTemplatePack(), square: true })
        .success,
    ).toBe(false);
  });
  it("keeps AWS and lifecycle overrides above editable native-level maps", () => {
    const settings = defaultTemplatePack().defaults;
    settings.nativeLevelMappings = [
      { level: "Advice", band: "critical" },
      { level: "Road closed", band: "action" },
    ];
    expect(
      chooseTemplateBand(settings, {
        isAws: true,
        severity: "advice",
        nativeLevel: "Advice",
        description: "Bushfire Advice",
        fallback: "info",
      }).band,
    ).toBe("monitor");
    expect(
      chooseTemplateBand(settings, {
        isAws: false,
        nativeLevel: "Road closed",
        description: "Road closed",
        fallback: "info",
      }).band,
    ).toBe("action");
    expect(
      chooseTemplateBand(settings, {
        isAws: true,
        severity: "emergency",
        description: "This is a test message only",
        fallback: "critical",
      }).band,
    ).toBe("info");
  });
  it("selects only approved, matching library guidance without requiring personal data", () => {
    const pack = defaultTemplatePack();
    pack.library = [
      {
        id: "children",
        text: "Consider confirming school collection arrangements.",
        categoryIds: ["traffic"],
        countries: ["AU"],
        bands: ["action"],
        profileTags: ["kids"],
        approved: true,
        reference: "Reviewed action library",
        reviewedAt: "2026-10-13",
      },
      {
        id: "draft",
        text: "Consider a draft.",
        categoryIds: ["traffic"],
        countries: [],
        bands: [],
        profileTags: [],
        approved: false,
        reference: "Draft",
        reviewedAt: null,
      },
    ];
    const selected = selectLibraryGuidance(pack, {
      categoryId: "traffic",
      country: "AU",
      band: "action",
    });
    expect(selected.alrtSuggestions).toEqual([]);
    expect(selected.profileGuidance.map((x) => x.id)).toEqual(["children"]);
    expect(
      selectLibraryGuidance(pack, {
        categoryId: "weather",
        country: "AU",
        band: "action",
      }).profileGuidance,
    ).toEqual([]);
  });
  it("protects official warning levels on non-AWS categories too", () => {
    const settings = defaultTemplatePack().defaults;
    settings.nativeLevelMappings = [{ level: "Emergency Warning", band: "info" }];
    expect(chooseTemplateBand(settings, { isAws: false, severity: "emergency", nativeLevel: "Emergency Warning", description: "Emergency Warning for Example Town", fallback: "critical" }).band).toBe("critical");
  });
  it("uses the destination country and never a global publisher's home country", () => {
    expect(normaliseCountry("Saudi Arabia")).toBe("SA");
    expect(normaliseCountry("Japan")).toBe("JP");
    expect(normaliseCountry("France")).toBe("FR");
    expect(normaliseCountry("Russia")).toBe("RU");
    expect(normaliseCountry("Timor-Leste")).toBe("TL");
    expect(normaliseCountry("Congo - Kinshasa")).toBe("CD");
    expect(normaliseCountry("A place near Australia")).toBeNull();
    expect(templateCountry(null, {id: "smartraveller", country: "AU"})).toBeNull();
    expect(templateCountry("SA", {id: "smartraveller", country: "AU"})).toBe("SA");
  });
  it("uses editable whole phrases after official levels, with lifecycle rules first", () => {
    const settings = defaultTemplatePack().defaults;
    settings.severityPhrases = [{phrase: "road closed",band:"action"},{phrase:"bridge collapsed",band:"critical"},{phrase:"Advice",band:"critical"}];
    const base = {isAws:false, fallback:"info" as const};
    expect(chooseTemplateBand(settings,{...base,description:"Example Road closed and bridge collapsed."}).band).toBe("critical");
    expect(chooseTemplateBand(settings,{...base,description:"Broad closed circuit display."}).band).toBe("info");
    expect(chooseTemplateBand(settings,{...base,severity:"advice",description:"Advice - road closed"}).band).toBe("monitor");
    expect(chooseTemplateBand(settings,{...base,description:"This is a test message only: bridge collapsed"}).band).toBe("info");
    expect(chooseTemplateBand(settings,{...base,severity:"emergency",description:"Incident not resolved. Emergency Warning."}).band).toBe("critical");
    expect(chooseTemplateBand(settings,{...base,nativeLevel:"Do not travel",fallback:"critical",description:"Road closed"}).band).toBe("critical");
  });
});

describe("grounded agency extraction", () => {
  it("accepts four sourced key points without adding filler to a sparse alert", () => {
    const facts = ["Road closed at Example Bridge.", "Repairs start on Monday.", "The northbound lane is affected.", "The next update is due at noon."];
    const result = parseAgencyExtraction({ title: "Road update", facts: facts.map(text => ({text, evidence:text})), officialActions: [], affectedAreas: [], nativeLevel: null, confidence: "high" }, {sourceText: facts.join("\n\n"), agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: [], profileGuidance: []});
    expect(result.contentDetails.facts).toEqual(facts);
    const sparse = parseAgencyExtraction({ title: "Road update", facts: [{text:facts[0],evidence:facts[0]}], officialActions: [], affectedAreas: [], nativeLevel: null, confidence: "low" }, {sourceText: facts[0]!, agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: [], profileGuidance: []});
    expect(sparse.contentDetails.facts).toEqual([facts[0]]);
  });
  const source =
    "Watch and Act for Example Town.\n\nSmoke affects Example Road.\n\nPrepare to leave if you are in Example Town.";
  const response = {
    title: "Bushfire at Example Town",
    facts: [
      {
        text: "Smoke affects Example Road.",
        evidence: "Smoke affects Example Road.",
      },
    ],
    affectedAreas: ["Example Town"],
    nativeLevel: "Watch and Act",
    officialActions: [
      {
        text: "Prepare to leave if you are in Example Town.",
        evidence: "Prepare to leave if you are in Example Town.",
      },
    ],
    confidence: "high",
  };
  it("keeps grounded facts, the warning and conditions, with separately labelled approved suggestions", () => {
    const result = parseAgencyExtraction(response, {
      sourceText: source,
      sourceActions: response.officialActions.map(x => x.text),
      agency: "Example agency",
      allowAgencyNumbers: false,
      templateVersion: 2,
      alrtSuggestions: [],
      profileGuidance: [],
    });
    expect(result.contentDetails.facts).toEqual([
      "Smoke affects Example Road.",
    ]);
    expect(result.contentDetails.nativeLevel).toBe("Watch and Act");
    expect(result.callsToAction).toEqual([
      "Example agency advises: Prepare to leave if you are in Example Town.",
    ]);
  });
  it("preserves an explicit fire ban fact even when the model omits it", () => {
    const fireBanSource =
      "Watch and Act for Example Town.\n\n" +
      "Total Fire Ban in effect for Example District.\n\n" +
      "Smoke affects Example Road.\n\n" +
      "Prepare to leave if you are in Example Town.";
    const result = parseAgencyExtraction(
      {
        ...response,
        facts: [
          {
            text: "Smoke affects Example Road.",
            evidence: "Smoke affects Example Road.",
          },
        ],
      },
      {
        sourceText: fireBanSource,
        sourceActions: response.officialActions.map(x => x.text),
        agency: "Example agency",
        allowAgencyNumbers: false,
        templateVersion: 2,
        alrtSuggestions: [],
        profileGuidance: [],
      },
    );
    expect(result.contentDetails.facts).toEqual([
      "Total Fire Ban in effect for Example District.",
      "Smoke affects Example Road.",
    ]);
    expect(result.summary).toContain("Total Fire Ban in effect for Example District.");
    expect(result.contentDetails.evidence).toEqual(result.contentDetails.facts);
  });
  it("refuses invented evidence, places, severity and unsourced instructions", () => {
    const opts = {
      sourceText: source,
      agency: "Example agency",
      allowAgencyNumbers: false,
      templateVersion: 1,
      alrtSuggestions: [],
      profileGuidance: [],
    };
    expect(() =>
      parseAgencyExtraction(
        {
          ...response,
          officialActions: [{ text: "Leave now.", evidence: "Leave now." }],
        },
        opts,
      ),
    ).toThrow();
    expect(() =>
      parseAgencyExtraction(
        { ...response, affectedAreas: ["Other Town"] },
        opts,
      ),
    ).toThrow();
    expect(() =>
      parseAgencyExtraction({ ...response, severity: "critical" }, opts),
    ).toThrow();
  });
  it("does not truncate essential official instructions to three bullets", () => {
    const actions = [
      "Check the warning.",
      "Prepare to leave.",
      "Use the marked exit.",
      "Keep this road clear.",
    ];
    const result = parseAgencyExtraction(
      {
        ...response,
        facts: [],
        affectedAreas: [],
        nativeLevel: null,
        officialActions: actions.map((text) => ({ text, evidence: text })),
      },
      {
        sourceText: actions.join("\n\n"),
        sourceActions: actions,
        agency: "Agency",
        allowAgencyNumbers: false,
        templateVersion: 1,
        alrtSuggestions: [],
        profileGuidance: [],
      },
    );
    expect(result.contentDetails.officialActions).toHaveLength(4);
  });
  it("rejects fabricated facts paired with real evidence and shortened action clauses", () => {
    const opts = { sourceText: "Smoke is visible.\n\nIf you are in Example Town and it is safe to do so, leave now via Example Road.", agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: [], profileGuidance: [] };
    expect(() => parseAgencyExtraction({ ...response, nativeLevel: null, affectedAreas: [], officialActions: [], facts: [{ text: "Every bridge has collapsed.", evidence: "Smoke is visible." }] }, opts)).toThrow();
    expect(() => parseAgencyExtraction({ ...response, nativeLevel: null, affectedAreas: [], facts: [], officialActions: [{ text: "leave now", evidence: "leave now" }] }, opts)).toThrow();
  });
  it("keeps geographic and date numbers while removing phone instructions", () => {
    expect(removeUnattributedNumbers("Use Exit 112 via Route 911 if it is safe. Updated 2026-10-13.")).toBe("Use Exit 112 via Route 911 if it is safe. Updated 2026-10-13.");
    expect(removeUnattributedNumbers("Call 000 if you need emergency help.")).toBe("Call your local emergency number if you need emergency help.");
    expect(removeUnattributedNumbers("Emergency number: 112.")).toBe("Emergency number: your local emergency number.");
    expect(removeUnattributedNumbers("call police on 000")).toBe("call police on your local emergency number");
    expect(removeUnattributedNumbers("Phone: (08) 1234 5678")).toBe("Phone: your local emergency number");
    expect(removeUnattributedNumbers("contact DFAT on 1300 555 135")).toBe("contact DFAT on your local emergency number");
    expect(removeUnattributedNumbers("Call for help at Exit 112.")).toBe("Call for help at Exit 112.");
    expect(removeUnattributedNumbers("Contact staff at Gate 112.")).toBe("Contact staff at Gate 112.");
    expect(removeUnattributedNumbers("Phone staff in Room 911.")).toBe("Phone staff in Room 911.");
  });
  it("retains a condition in a paragraph before a free-text instruction",()=>{
    const sourceText="For residents in Example Town only, and only if the route is safe:\n\nLeave now via Example Road.";
    const value=parseAgencyExtraction({...response,facts:[],affectedAreas:[],nativeLevel:null,officialActions:[{text:"Leave now via Example Road.",evidence:"Leave now via Example Road."}]},{sourceText,agency:"Example agency",allowAgencyNumbers:false,templateVersion:1,alrtSuggestions:[],profileGuidance:[]});
    expect(value.contentDetails.officialActions).toEqual([sourceText]);
  });
  it("keeps fallback instructions with their conditions and separately supplied actions", () => {
    const description = "For residents in Example Town only, and only if the route is safe:\n\nLeave now via Example Road.";
    const result = agencyExtractionFallback({ sourceText: description, sourceDescription: description, sourceActions: ["Keep Example Road clear."], agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: [], profileGuidance: [] });
    expect(result.contentDetails.officialActions).toEqual([description, "Keep Example Road clear."]);
    expect(result.callsToAction).toEqual([`Agency advises: ${description}`, "Agency advises: Keep Example Road clear."]);
  });
  it("retains the source lead-in when it scopes several instruction paragraphs", () => {
    const sourceText = "For Example Town residents only, if the route is safe:\n\nPrepare your vehicle.\n\nLeave via Example Road.";
    const options = {sourceText, sourceDescription: sourceText, agency: "Agency", allowAgencyNumbers: false, templateVersion: 1, alrtSuggestions: [], profileGuidance: []};
    const result = parseAgencyExtraction({...response, facts:[], affectedAreas:[], nativeLevel:null, officialActions:[{text:"Leave via Example Road.", evidence:"Leave via Example Road."}]}, options);
    expect(result.contentDetails.officialActions).toEqual([sourceText]);
    expect(agencyExtractionFallback(options).contentDetails.officialActions).toContain(sourceText);
  });
});

describe("5 November owner wording rules", () => {
  const options = { sourceText: "Smoke affects Example Road.", agency: "Agency", allowAgencyNumbers: false, templateVersion: 3, alrtSuggestions: ["Consider reviewing your travel plans.", "Checking local updates may help."], profileGuidance: [] };
  const input = {title:"Update",facts:[{text: options.sourceText,evidence:options.sourceText}],affectedAreas:[],nativeLevel:null,officialActions:[],confidence:"high"};
  it("supplements one complete agency instruction to two advice points", () => {
    const result = parseAgencyExtraction(input, {...options, sourceActions:["Avoid Example Road until it reopens."]});
    expect(result.contentDetails.alrtSuggestions).toEqual([options.alrtSuggestions[0]]);
    expect(result.callsToAction).toEqual(["Agency advises: Avoid Example Road until it reopens.", options.alrtSuggestions[0]]);
  });
  it("does not add filler when two agency instructions already exist", () => {
    expect(parseAgencyExtraction(input, {...options, sourceActions:["Avoid Example Road.","Use Example Bridge."]}).contentDetails.alrtSuggestions).toEqual([]);
  });
  it("uses two sourced facts rather than the full fallback description", () => {
    const description = "Smoke affects Example Road. Crews are on scene. The next update is due at noon.";
    const result = agencyExtractionFallback({...options,sourceText:description,sourceDescription:description});
    expect(result.contentDetails.facts).toEqual(["Smoke affects Example Road.","Crews are on scene."]);
    expect(result.summary).toBe("• Smoke affects Example Road.\n• Crews are on scene.");
    expect(result.contentDetails.alrtSuggestions).toHaveLength(2);
  });
});

describe('fallback source retention',()=>{
 it('keeps the complete original description and excludes adapter metadata from facts',()=>{
  const sourceDescription='Type: Bushfire\n\nSource status: Going\n\nWarning level: Watch and Act\n\nFire near Example Road.\n\nCrews are on scene.\n\nDrink water regularly.\n\nSeek medical attention if symptoms persist.';
  const result=agencyExtractionFallback({sourceText:sourceDescription,sourceDescription,agency:'Agency',allowAgencyNumbers:false,templateVersion:3,alrtSuggestions:[],profileGuidance:[]});
  expect(result.contentDetails.facts).toEqual(['Fire near Example Road.','Crews are on scene.']);
  expect(result.contentDetails.sourceDescription).toBe(sourceDescription);
 });
});
it('applies the source phone-number policy to the visible fallback details',()=>{
 const result=agencyExtractionFallback({sourceText:'Call 000 for assistance.',sourceDescription:'Call 000 for assistance.',agency:'Agency',allowAgencyNumbers:false,templateVersion:3,alrtSuggestions:[],profileGuidance:[]});
 expect(result.contentDetails.sourceDescription).toBe('Call your local emergency number for assistance.');
});
it('does not lend broad utilities guidance to a structure fire without explicit category review',()=>{
 const pack=defaultTemplatePack();
 expect(selectLibraryGuidance(pack,{categoryId:'structureFire',parentCategoryId:'utilitiesAndInfrastructure',band:'action'}).alrtSuggestions).toEqual([]);
});

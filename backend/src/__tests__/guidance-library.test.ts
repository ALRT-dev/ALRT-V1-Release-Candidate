import { describe, expect, it, vi } from "vitest";
vi.mock("../utils/prisma_client.util.js", () => ({ default: {} }));
import {
  checkGuidance, coverageGrid, jurisdictionChain, nextReviewFrom, overdue, pickApproved, toTemplateEntries, type GuidanceRow,
} from "../utils/guidance_library.util.js";
import { buildCountryImport, buildDraftGuideRecords, buildImportRecords, categoryIdsForHazard } from "../utils/guidance_import.util.js";
import { templatePackSchema, libraryEntrySchema } from "../utils/alert_templates.util.js";

const row = (p: Partial<GuidanceRow>): GuidanceRow => ({
  id: p.key ?? "id", key: "k", kind: "advice", hazard: "bushfire", jurisdiction: "AU", text: "Check official updates often.",
  sourceAgency: "DFES", sourceUrl: "https://www.dfes.wa.gov.au/hazard-information/bushfire", version: 1, status: "approved", reviewedAt: "2026-11-16", ...p,
});

describe("guidance library rules", () => {
  it("falls back from state to country to everywhere", () => {
    expect(jurisdictionChain("AU-WA")).toEqual(["AU-WA", "AU", "*"]);
    expect(jurisdictionChain("id")).toEqual(["ID", "*"]);
    expect(jurisdictionChain(undefined)).toEqual(["AU", "*"]);
  });

  it("picks the WA record over the national one, newest version only", () => {
    const rows = [
      row({ key: "a", jurisdiction: "AU", text: "National" }),
      row({ key: "b", jurisdiction: "AU-WA", text: "WA v1", version: 1 }),
      row({ key: "b", jurisdiction: "AU-WA", text: "WA v2", version: 2 }),
      row({ key: "c", jurisdiction: "AU-WA", text: "draft", status: "draft" }),
    ];
    expect(pickApproved(rows, { kind: "advice", hazard: "bushfire", jurisdiction: "AU-WA" }).map((r) => r.text)).toEqual(["WA v2"]);
    expect(pickApproved(rows, { kind: "advice", hazard: "bushfire", jurisdiction: "AU-NSW" }).map((r) => r.text)).toEqual(["National"]);
    expect(pickApproved(rows, { kind: "advice", hazard: "flood", jurisdiction: "AU-WA" })).toEqual([]);
  });

  it("blocks movement directions and non-emergency numbers in ALRT's own words", () => {
    const leave = checkGuidance({ kind: "advice", hazard: "flood", text: "Leave early if you can.", sourceAgency: "SES", sourceUrl: "https://ses.example.gov.au/flood" });
    expect(leave.errors.join(" ")).toMatch(/never tells people to leave/);
    const phone = checkGuidance({ kind: "answer", text: "Call 132 500 for storm help.", triggers: ["storm damage"], sourceAgency: "SES", sourceUrl: "https://ses.example.gov.au/x" });
    expect(phone.errors).toContain("Only emergency numbers may appear.");
    const ok = checkGuidance({ kind: "advice", hazard: "flood", text: "If you are in danger, call 000.", sourceAgency: "SES", sourceUrl: "https://ses.example.gov.au/flood" });
    expect(ok.errors).toEqual([]);
  });

  it("only warns when an agency guide section mentions leaving", () => {
    const r = checkGuidance({ kind: "guide_section", hazard: "flood", stage: "during", text: "The SES suggests leaving early if evacuation is recommended.", sourceAgency: "SES", sourceUrl: "https://ses.example.gov.au/flood" });
    expect(r.errors).toEqual([]);
    expect(r.warnings.join(" ")).toMatch(/agency's advice/);
  });

  it("requires a source page link to approve", () => {
    const r = checkGuidance({ kind: "advice", hazard: "flood", text: "Check updates.", sourceAgency: "SES", sourceUrl: "" }, { forApproval: true });
    expect(r.errors).toContain("Add the source page link.");
    expect(checkGuidance({ kind: "advice", hazard: "flood", text: "Check updates.", sourceAgency: "SES", sourceUrl: "https://www.ses.nsw.gov.au/" }).warnings)
      .toContain("Link to the exact page, not the home page.");
  });

  it("needs a group for Safety Profile lines", () => {
    expect(checkGuidance({ kind: "profile", hazard: "flood", text: "Keeping a kit may help.", sourceAgency: "x", sourceUrl: "https://a.b/c" }).errors)
      .toContain("A Safety Profile line needs one group.");
  });

  it("flags overdue records and builds a coverage grid", () => {
    const now = new Date("2026-11-16");
    const rows = [
      row({ key: "p1", kind: "profile", hazard: "flood", cohort: "older", nextReviewAt: "2026-01-01" }),
      row({ key: "p2", kind: "profile", hazard: "flood", cohort: "kids", status: "draft" }),
      row({ key: "p3", kind: "profile", hazard: "flood", cohort: "pets", sourceUrl: "" }),
    ];
    expect(overdue(rows, now).map((r) => r.key)).toEqual(["p1"]);
    expect(coverageGrid(rows, ["flood"], ["older", "kids", "pets", "deaf"], "cohort", "profile", now)).toEqual({
      flood: { older: "overdue", kids: "draft", pets: "no_source", deaf: "empty" },
    });
    expect(nextReviewFrom(new Date("2026-11-16")).toISOString().slice(0, 10)).toBe("2027-11-16");
  });

  it("turns approved advice and profile rows into valid Alert Templates entries with their source", () => {
    const { entries, skipped } = toTemplateEntries(
      [row({ key: "advice:bushfire:-:-:AU-WA:plan", jurisdiction: "AU-WA" }), row({ key: "p", kind: "profile", cohort: "older", hazard: "grass_fire" })],
      categoryIdsForHazard,
    );
    expect(skipped).toEqual([{ key: "p", reason: 'No alert categories mapped for hazard "grass_fire".' }]);
    expect(entries).toHaveLength(1);
    expect(entries[0]!.countries).toEqual(["AU-WA"]);
    expect(entries[0]!.reference).toMatch(/DFES \(https:\/\/www\.dfes\.wa\.gov\.au.*\); AU-WA; library .* v1/);
    expect(() => libraryEntrySchema.parse(entries[0])).not.toThrow();
  });
});

describe("one-off import of the existing stores", () => {
  const records = buildImportRecords();
  it("brings in every store with a unique key", () => {
    const count = (k: string) => records.filter((r) => r.kind === k).length;
    expect(count("advice")).toBeGreaterThanOrEqual(60);
    expect(count("profile")).toBe(279 + 9);
    expect(count("guide_section")).toBeGreaterThan(100);
    expect(count("answer")).toBeGreaterThan(5);
    expect(new Set(records.map((r) => r.key)).size).toBe(records.length);
  });
  it("keeps every imported advice line free of movement directions", () => {
    for (const r of records.filter((x) => x.kind === "advice")) {
      expect(checkGuidance(r).errors.filter((e) => /never tells/.test(e))).toEqual([]);
    }
  });
  it("carries a source agency on every record", () => {
    expect(records.every((r) => r.sourceAgency.trim().length > 0)).toBe(true);
  });
  it("drafts the new guides with a page-level source and no ALRT movement directions", () => {
    const drafts = buildDraftGuideRecords().filter((d) => d.kind === "guide_section");
    const lines = buildDraftGuideRecords().filter((d) => d.kind === "profile");
    expect(new Set(lines.map((l) => l.cohort))).toEqual(new Set(["powered", "assistance"]));
    for (const l of lines) expect(checkGuidance(l, { forApproval: true }).errors, l.key).toEqual([]);
    expect(new Set(drafts.map((d) => d.hazard))).toEqual(new Set(["smoke-air-quality", "house-fire", "hazardous-materials", "landslide", "armed-attack-escape-hide-tell", "home-security", "water-contamination"]));
    for (const d of drafts) {
      const c = checkGuidance(d, { forApproval: true });
      expect(c.errors, d.key).toEqual([]);
      expect(d.sourceUrl).toMatch(/^https:\/\/[^/]+\/./);
    }
  });
  it("seeds the country register from the shared emergency list", () => {
    const au = buildCountryImport().find((c) => c.code === "AU");
    expect(au?.emergencyNumber).toBe("000");
  });
});

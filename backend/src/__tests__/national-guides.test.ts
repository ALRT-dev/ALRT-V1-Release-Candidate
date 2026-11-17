import { describe, it, expect, vi } from "vitest";
vi.mock("../utils/prisma_client.util.js", () => ({ default: {} }));
import { checkGuidance } from "../utils/guidance_library.util.js";
import { buildDraftGuideRecords } from "../utils/guidance_import.util.js";
import { NATIONAL_GUIDES } from "../data/guidance_drafts_20261116.js";
import { localAnswer } from "../services/ask_alrt/matching.js";
import { resolvePlace } from "../services/ask_alrt/place.js";

const records = buildDraftGuideRecords();
const answers = (j: string) =>
  records.filter((r) => r.kind === "answer" && (r.jurisdiction === j))
    .map((r) => ({ id: r.key, triggers: r.triggers ?? [], keywords: [], answer: r.text }));

describe("national guides and Ask ALRT answers (17 Nov 2026)", () => {
  it("every drafted record passes the approval rules", () => {
    const bad = records.map((r) => ({ key: r.key, errors: checkGuidance(r as any, { forApproval: true }).errors })).filter((x) => x.errors.length);
    expect(bad).toEqual([]);
  });
  it("keys are unique and national sections never collide with imported ones", () => {
    const keys = records.map((r) => r.key);
    expect(new Set(keys).size).toBe(keys.length);
    const national = records.filter((r) => r.kind === "guide_section" && NATIONAL_GUIDES.some((g) => g.slug === r.hazard));
    expect(national.length).toBeGreaterThan(15);
    for (const r of national) expect(r.key.split(":").pop()).toMatch(/^L\d+$/);
  });
  it("answers stay short", () => {
    for (const r of records.filter((x) => x.kind === "answer")) expect(r.text.split(/\s+/).length).toBeLessThanOrEqual(70);
  });
  it.each([
    ["what does watch and act mean", "AU", "guide-warning-levels"],
    ["can i drive through floodwater", "AU", "guide-floodwater"],
    ["what is the difference between a cyclone watch and warning", "AU", "guide-cyclone-watch-warning"],
    ["how long do i boil water for a boil water notice", "AU", "guide-boil-water"],
  ])("%s -> %s", (q, j, id) => {
    const hit = localAnswer(q, answers(j), {} as any);
    expect(hit?.source).toBe("library");
    expect((hit as any).entry.id).toContain(id);
  });
  it.each([["what do the weather warning levels mean in japan", "JP"], ["what does a red warning mean in new zealand", "NZ"], ["what do the warning colours mean in canada", "CA"]])("%s", (q, j) => {
    expect(resolvePlace(q).jurisdiction?.slice(0, 2)).toBe(j);
    const hit = localAnswer(q, answers(j), {} as any);
    expect((hit as any)?.entry?.id).toBe(`answer:-:-:-:${j}:warning-levels`);
  });
});

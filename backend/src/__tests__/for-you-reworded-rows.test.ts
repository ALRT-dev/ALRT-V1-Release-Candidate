import { describe, expect, it } from "vitest";
import { readFileSync } from "fs";
import { join } from "path";
import { MOVEMENT_REWORDS_20261117 } from "../data/guidance_drafts_20261116.js";

// Owner, 17 November 2026: four reworded Safety Profile lines cannot reach
// phones through Alert Templates (their hazards have no alert category), so
// the on-device rows carry the approved wording directly. The app's
// for_you_library.dart and this mirror must say exactly what was approved.
const rows = JSON.parse(readFileSync(join(__dirname, "../data/for_you_rows.json"), "utf8"));
const lookup = (hazard: string, cohort: string): string | undefined => {
  const find = (node: unknown): string | undefined => {
    if (!node || typeof node !== "object") return undefined;
    const record = node as Record<string, unknown>;
    if (record[hazard] && typeof record[hazard] === "object") {
      const value = (record[hazard] as Record<string, unknown>)[cohort];
      if (typeof value === "string") return value;
    }
    for (const child of Object.values(record)) {
      const hit = find(child);
      if (hit) return hit;
    }
    return undefined;
  };
  return find(rows);
};

describe("four reworded For You rows on the device", () => {
  for (const [hazard, cohort] of [["grass_fire", "pets"], ["snakes", "visitor"], ["snakes", "worker"], ["fuel_supply", "pets"]] as const) {
    it(`${hazard} / ${cohort} matches the approved rewording`, () => {
      const approved = MOVEMENT_REWORDS_20261117.find((r) => r.key === `profile:${hazard}:${cohort}:-:AU:line`);
      expect(approved).toBeDefined();
      expect(lookup(hazard, cohort)).toBe(approved!.text);
    });
  }

  it("carries no movement direction", () => {
    for (const [hazard, cohort] of [["grass_fire", "pets"], ["snakes", "visitor"], ["snakes", "worker"], ["fuel_supply", "pets"]] as const) {
      expect(lookup(hazard, cohort)).not.toMatch(/\b(leave|leaving|evacuat\w*|shelter\w*|stay|staying|return\w*)\b/i);
    }
  });
});

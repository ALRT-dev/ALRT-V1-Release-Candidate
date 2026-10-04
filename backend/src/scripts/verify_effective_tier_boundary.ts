/**
 * Unit check of the effective-time boundary for scheduled tier changes.
 * No server or database: `npx tsx src/scripts/verify_effective_tier_boundary.ts`
 */
import assert from "node:assert/strict";
import { effectiveTierAt } from "../utils/subscription_effective.util.js";

const at = new Date("2026-10-28T00:00:00.000Z");
const sub = { tier: "group50", pendingTier: "family", pendingEffectiveAt: at } as const;
const cases: [string, () => void][] = [
  ["1 ms before the effective time: current tier", () =>
    assert.equal(effectiveTierAt({ ...sub }, new Date(at.getTime() - 1)), "group50")],
  ["exactly at the effective time: new tier", () =>
    assert.equal(effectiveTierAt({ ...sub }, at), "family")],
  ["after: new tier", () =>
    assert.equal(effectiveTierAt({ ...sub }, new Date(at.getTime() + 1)), "family")],
  ["a request with no date never takes effect by itself", () =>
    assert.equal(effectiveTierAt({ ...sub, pendingEffectiveAt: null }, new Date(at.getTime() + 1e10)), "group50")],
  ["no pending change: current tier", () =>
    assert.equal(effectiveTierAt({ tier: "group20", pendingTier: null, pendingEffectiveAt: null }), "group20")],
];
let failed = 0;
for (const [label, fn] of cases) {
  try {
    fn();
    console.log(`  ok - ${label}`);
  } catch (error) {
    failed += 1;
    console.log(`  FAIL - ${label}: ${(error as Error).message}`);
  }
}
console.log(`\n${cases.length - failed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);

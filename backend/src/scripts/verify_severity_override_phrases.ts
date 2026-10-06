/**
 * Severity text override: phrase matching, not substrings (master spec
 * §15). Pure function check, no server or database needed.
 *
 * Run: npx tsx src/scripts/verify_severity_override_phrases.ts
 */
import assert from "node:assert/strict";
import { isInfoOverride } from "../utils/ingestion.severity.util.js";

const downgrade: string[] = [
  "This is a test of the emergency warning system.",
  "TEST MESSAGE ONLY. No action required.",
  "Scheduled siren test at 11am today.",
  "Evacuation drill at the school this morning.",
  "A multi-agency exercise will be conducted near the port.",
  "Training exercise underway, expect emergency vehicles.",
  "The crash has been cleared and traffic is flowing.",
  "All lanes are now open.",
  "A man has been charged over the incident.",
  "Police response concluded.",
];

const keep: string[] = [
  "Latest update: bushfire moving towards homes. Leave now.",
  "Protest blocking the highway, expect delays.",
  "Contest crowds near the stadium.",
  "Exercise caution: flooding on the road.",
  "Fire burning in cleared land north of town.",
  "This is not a test. Evacuate now.",
  "This is not a drill: tsunami warning.",
  "Emergency Warning: take shelter immediately.",
];

let passed = 0;
for (const text of downgrade) {
  assert.equal(isInfoOverride(text), true, `should downgrade: ${text}`);
  passed++;
}
for (const text of keep) {
  assert.equal(isInfoOverride(text), false, `must NOT downgrade: ${text}`);
  passed++;
}
console.log(`${passed} passed, 0 failed`);

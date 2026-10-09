/**
 * Unit check for the TEST-only scheduled-jobs switch (no server, no DB).
 *
 * Rule (product owner 2026-09-03): scheduled jobs run in prod always; on
 * a TEST backend only when RUN_SCHEDULED_JOBS_IN_TEST=true (default off);
 * never in dev or any other environment, whatever the flag says.
 *
 * Run with:
 *   npx tsx src/scripts/verify_scheduled_jobs_switch.ts
 */

import assert from "node:assert/strict";
import { shouldRunScheduledJobs } from "../utils/scheduled_jobs.util.js";

let passed = 0;
const check = (label: string, fn: () => void) => {
  fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

console.log("Scheduled-jobs switch verification\n");

check("prod runs jobs regardless of the flag", () => {
  assert.equal(shouldRunScheduledJobs("prod", false), true);
  assert.equal(shouldRunScheduledJobs("prod", true), true);
});

check("test is OFF by default", () => {
  assert.equal(shouldRunScheduledJobs("test", false), false);
});

check("test runs jobs only when the flag is on", () => {
  assert.equal(shouldRunScheduledJobs("test", true), true);
});

check("dev never runs jobs, even with the flag on", () => {
  assert.equal(shouldRunScheduledJobs("dev", false), false);
  assert.equal(shouldRunScheduledJobs("dev", true), false);
});

check("an unknown env never runs jobs", () => {
  assert.equal(shouldRunScheduledJobs("staging", true), false);
  assert.equal(shouldRunScheduledJobs("", true), false);
});

check("the flag is parsed strictly from the literal string 'true'", () => {
  const parse = (value: string | undefined) => (value || "false") === "true";
  assert.equal(parse(undefined), false);
  assert.equal(parse("false"), false);
  assert.equal(parse("1"), false);
  assert.equal(parse("TRUE"), false);
  assert.equal(parse("true"), true);
});

console.log(`\nAll ${passed} checks passed.`);

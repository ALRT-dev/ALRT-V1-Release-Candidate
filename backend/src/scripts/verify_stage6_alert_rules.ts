/**
 * Stage 6 verification script — NOT a test suite (the backend has no test
 * runner configured; see V1_RECONCILIATION_REPORT.md). This is a plain
 * Node script, run directly with tsx, that actually executes the pure
 * severity-band-scan function this stage's classification fix touched and
 * asserts its real output, rather than only reasoning about it by
 * inspection.
 *
 * Deliberately scoped to ingestion.severity.util.ts only: it has no
 * dependency on config/DB/Firebase, so it runs standalone in any
 * environment. notification.service.ts's getNotificationTitleForNewHazard
 * fix (never show a severity word for a community report) is NOT covered
 * here — importing it transitively pulls in config.ts's ~34 required env
 * vars (DATABASE_URL, AWS credentials, SMTP, ...), none of which are set
 * in a bare checkout. That fix was verified by code inspection only; see
 * the report.
 *
 * Run with: npx tsx src/scripts/verify_stage6_alert_rules.ts
 */

import assert from "node:assert/strict";
import { HazardSeverityBand } from "@prisma/client";
import { getSeverityBandFromDescription } from "../utils/ingestion.severity.util.js";

let passed = 0;

const check = (label: string, fn: () => void) => {
  fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

console.log("Severity band scan (ingestion.severity.util.ts)");

check("critical keyword still bands critical", () => {
  assert.equal(
    getSeverityBandFromDescription("Residents face an immediate threat to life."),
    HazardSeverityBand.critical,
  );
});

check("action keyword still bands action", () => {
  assert.equal(
    getSeverityBandFromDescription("Residents are advised to take precautions."),
    HazardSeverityBand.action,
  );
});

check("monitor keyword still bands monitor", () => {
  assert.equal(
    getSeverityBandFromDescription("Motorists should allow extra travel time."),
    HazardSeverityBand.monitor,
  );
});

check("no keyword match falls back to info", () => {
  assert.equal(
    getSeverityBandFromDescription("A routine notice with no hazard language."),
    HazardSeverityBand.info,
  );
});

check(
  "planned drill/exercise forces info even with critical-sounding wording",
  () => {
    assert.equal(
      getSeverityBandFromDescription(
        "This is a training exercise. Evacuate immediately when instructed by drill coordinators.",
      ),
      HazardSeverityBand.info,
    );
  },
);

check("a resolved/closed incident forces info", () => {
  assert.equal(
    getSeverityBandFromDescription(
      "Incident cleared. All lanes open. Response concluded.",
    ),
    HazardSeverityBand.info,
  );
});

check("a structured label followed by a colon does not false-match", () => {
  // "Advice:" as a section label paired with no real keyword phrase should
  // fall through to info, proving the colon-guarded keyword check works
  // the same way here as it already did in the AWS-severity scanner.
  assert.equal(
    getSeverityBandFromDescription("Advice: routine update, no keywords here."),
    HazardSeverityBand.info,
  );
});

console.log(`\n${passed} checks passed.`);

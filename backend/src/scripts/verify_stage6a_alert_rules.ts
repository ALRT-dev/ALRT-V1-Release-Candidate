/**
 * Stage 6A verification script — NOT a test suite (the backend has no
 * test runner configured; see V1_RECONCILIATION_REPORT.md). A plain Node
 * script, run with tsx, that actually executes the pure functions this
 * pass added/changed and asserts their real output.
 *
 * Deliberately scoped to dependency-light functions only (no config/DB/
 * Firebase import chain) so it runs standalone in any environment — see
 * verify_stage6_alert_rules.ts's header comment for why
 * notification.service.ts-adjacent code isn't covered the same way.
 *
 * Run with: npx tsx src/scripts/verify_stage6a_alert_rules.ts
 */

import assert from "node:assert/strict";
import { HazardReviewStatus, HazardSeverityBand } from "@prisma/client";
import {
  getDeterministicAirQualityContent,
  parseAqiValueFromDescription,
  parseStationNameFromDescription,
} from "../utils/air_quality_template.util.js";
import { mapAiReviewStatus } from "../utils/hazard.util.js";

let passed = 0;

const check = (label: string, fn: () => void) => {
  fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

console.log("AQI deterministic template (air_quality_template.util.ts)");

const sampleDescription =
  "Station: Rockingham\nAQI: 142\nCoordinates: -32.28, 115.73\nLast Updated: 2026-08-22T10:00:00";

check("extracts the AQI value from the fixed WAQI description format", () => {
  assert.equal(parseAqiValueFromDescription(sampleDescription), 142);
});

check("extracts the station name from the fixed WAQI description format", () => {
  assert.equal(
    parseStationNameFromDescription(sampleDescription, "fallback"),
    "Rockingham",
  );
});

check("falls back to the title when the description format is unrecognised", () => {
  assert.equal(parseAqiValueFromDescription("no structured fields here"), null);
  assert.equal(
    parseStationNameFromDescription("no structured fields here", "Air Quality Alert - X"),
    "Air Quality Alert - X",
  );
});

check("produces zero-AI action-band content with no invented facts", () => {
  const content = getDeterministicAirQualityContent({
    title: "Air Quality Alert - Rockingham",
    description: sampleDescription,
    severityBand: HazardSeverityBand.action,
  });
  assert.equal(content.title, "Air Quality Alert - Rockingham");
  assert.match(content.summary, /Rockingham/);
  assert.match(content.summary, /142/);
  assert.ok(content.callsToAction.length > 0);
  assert.equal(content.confidence, "high");
});

check(
  "critical-band content branches on the actual AQI number (hazardous vs very poor), not a fixed string",
  () => {
    const hazardous = getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: sampleDescription.replace("142", "350"),
      severityBand: HazardSeverityBand.critical,
    });
    assert.match(hazardous.summary, /hazardous/);

    const veryPoor = getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: sampleDescription.replace("142", "200"),
      severityBand: HazardSeverityBand.critical,
    });
    assert.match(veryPoor.summary, /very poor/);
  },
);

check("every reachable band's content includes the mandatory health disclosure close", () => {
  for (const band of [
    HazardSeverityBand.monitor,
    HazardSeverityBand.action,
    HazardSeverityBand.critical,
  ]) {
    const content = getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: sampleDescription,
      severityBand: band,
    });
    assert.ok(
      content.callsToAction.some((line) =>
        line.includes("not a substitute for personal medical advice"),
      ),
      `expected the mandatory health close for band ${band}`,
    );
  }
});

console.log("\nAI review-status mapping (hazard.util.ts)");

check('trusts a literal "accepted" from the model', () => {
  assert.equal(mapAiReviewStatus("accepted"), HazardReviewStatus.accepted);
});

check('trusts a literal "rejected" from the model', () => {
  assert.equal(mapAiReviewStatus("rejected"), HazardReviewStatus.rejected);
});

check(
  "never silently defaults to accepted for a missing/malformed/hallucinated value — this was the actual bug",
  () => {
    assert.equal(mapAiReviewStatus(undefined), HazardReviewStatus.pending);
    assert.equal(mapAiReviewStatus(null), HazardReviewStatus.pending);
    assert.equal(mapAiReviewStatus("maybe"), HazardReviewStatus.pending);
    assert.equal(mapAiReviewStatus(""), HazardReviewStatus.pending);
  },
);

console.log(`\n${passed} checks passed.`);

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

check("produces zero-AI action-band content in WAQI's words, never the number", () => {
  const content = getDeterministicAirQualityContent({
    title: "Air Quality Alert - Rockingham",
    description: sampleDescription,
    severityBand: HazardSeverityBand.action,
  });
  assert.equal(content.title, "Air Quality Alert - Rockingham");
  assert.equal(
    content.summary,
    "World Air Quality Index reports that air quality near Rockingham is unhealthy for sensitive groups.",
  );
  assert.doesNotMatch(content.summary, /142/);
  assert.ok(content.callsToAction.length > 0);
  assert.ok(content.callsToAction.every((line) => !/^ALRT suggests/i.test(line)));
  assert.equal(content.confidence, "high");
});

check("prefers the rating line the parser wrote over the machine field", () => {
  const content = getDeterministicAirQualityContent({
    title: "Air Quality Alert - X",
    description:
      "Station: X\nAir quality: Very unhealthy (World Air Quality Index rating)\nMeasured: now\nAQI: 250",
    severityBand: HazardSeverityBand.critical,
  });
  assert.match(content.summary, /is very unhealthy\.$/);
});

check(
  "critical-band content takes WAQI's rating for the machine field (hazardous vs unhealthy), not a fixed string",
  () => {
    const hazardous = getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: sampleDescription.replace("142", "350"),
      severityBand: HazardSeverityBand.critical,
    });
    assert.match(hazardous.summary, /is hazardous\.$/);

    const unhealthy = getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: sampleDescription.replace("142", "200"),
      severityBand: HazardSeverityBand.critical,
    });
    assert.match(unhealthy.summary, /is unhealthy\.$/);

    const noNumber = getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: "Station: X",
      severityBand: HazardSeverityBand.critical,
    });
    assert.match(noNumber.summary, /is unhealthy\.$/);
  },
);

check("the info band gives no ALRT lines; the others give unprefixed ones", () => {
  assert.deepEqual(
    getDeterministicAirQualityContent({
      title: "Air Quality Alert - X",
      description: sampleDescription,
      severityBand: HazardSeverityBand.info,
    }).callsToAction,
    [],
  );
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
    assert.ok(content.callsToAction.length > 0, `expected ALRT lines for band ${band}`);
    for (const line of content.callsToAction) {
      assert.doesNotMatch(line, /ALRT suggests/i);
      assert.doesNotMatch(line, /\d{2,}/);
    }
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

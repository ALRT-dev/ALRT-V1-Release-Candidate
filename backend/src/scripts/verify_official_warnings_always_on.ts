/**
 * Official warnings are always on (product owner rule).
 *
 * Pure checks, no database, no network, no Firebase. Exits non-zero on any
 * failure. Run with:
 *   npx tsx src/scripts/verify_official_warnings_always_on.ts
 *
 * Covers:
 *  1. A user whose category filter excludes the alert's parent category (and
 *     whose officialNonAws / awsEmergency switches are off) still gets an AWS
 *     Emergency Warning and an official critical alert, in the hazard list
 *     query and in the push-recipient query; a non-exempt alert is still
 *     filtered; location / block rules are untouched (static guard).
 *  2. awsEmergency=false can never be stored or returned.
 *  3. The push payload stays under the byte limit for a 10,000 character
 *     description (and a huge CTA list), and keeps id, title, severity, band.
 *  4. An escalation on the same hazard id gets a distinct event key; an
 *     identical re-ingest keeps the same key.
 */

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import {
  ALWAYS_ON_OFFICIAL_SQL,
  buildPushSettingsUserWhere,
  isAlwaysOnOfficialWarning,
  withAlwaysOnExemptionSql,
  withAlwaysOnExemptionWhere,
  withAwsEmergencyAlwaysOn,
} from "../utils/official_warning.util.js";
import {
  PUSH_PAYLOAD_MAX_BYTES,
  boundPushPayload,
  hazardPushEventKey,
  truncateText,
} from "../utils/push_payload.util.js";

const EN_DASH = String.fromCharCode(0x2013);
let passed = 0;
const check = (name: string, fn: () => void) => {
  try {
    fn();
    passed++;
    console.log(`PASS  ${name}`);
  } catch (e) {
    console.error(`FAIL  ${name}\n      ${(e as Error).message}`);
    process.exitCode = 1;
  }
};

// ---------- tiny in-memory evaluators for the generated conditions ----------

type Hz = {
  categoryId: string;
  parentCategoryId: string | null;
  isAwsCompliant: boolean;
  severity: string;
  severityBand: string;
  reportedById: string | null;
  sourceId: string | null;
};

/** Evaluates the Prisma-shaped where used by buildHazardsWhereClause. */
const evalWhere = (w: any, h: Hz): boolean => {
  if (w.AND) return w.AND.every((x: any) => evalWhere(x, h));
  if (w.OR) return w.OR.some((x: any) => evalWhere(x, h));
  return Object.entries(w).every(([k, v]: [string, any]) => {
    if (k === "category") return evalWhere({ parentId: v.parentId }, { ...h, parentId: h.parentCategoryId } as any);
    const val = (h as any)[k];
    if (v !== null && typeof v === "object") {
      if ("in" in v) return v.in.includes(val);
      if ("not" in v) return val !== v.not;
      throw new Error(`unsupported operator ${JSON.stringify(v)}`);
    }
    return val === v;
  });
};

/** What buildHazardsWhereClause composes for (category filter, toggles). */
const listWhere = (opts: {
  categoryIds: string[];
  toggles: { officialNonAws?: boolean; userReported?: boolean };
  admin?: boolean;
}) => {
  const gated: any[] = [
    {
      OR: [
        { categoryId: { in: opts.categoryIds } },
        { category: { parentId: { in: opts.categoryIds } } },
      ],
    },
  ];
  const toggles: any[] = [];
  if (opts.toggles.officialNonAws) toggles.push({ AND: [{ isAwsCompliant: false }, { sourceId: { not: null } }] });
  if (opts.toggles.userReported) toggles.push({ reportedById: { not: null } });
  if (toggles.length) gated.push({ OR: toggles });
  return { AND: withAlwaysOnExemptionWhere(gated, !opts.admin) };
};

/** Evaluates the push-recipient `user` where against one user's settings. */
const userMatches = (
  where: Record<string, any>,
  settings: Record<string, any> | null,
): boolean => {
  const s = where.pushNotificationSettings;
  if (!s) return true; // no settings condition at all
  if (!settings) return false;
  return Object.entries(s.some).every(([k, v]: [string, any]) =>
    v && typeof v === "object" && "has" in v
      ? (settings[k] as string[]).includes(v.has)
      : settings[k] === v,
  );
};

const base: Hz = {
  categoryId: "bushfire-sub",
  parentCategoryId: "fire-parent",
  isAwsCompliant: false,
  severity: "advice",
  severityBand: "info",
  reportedById: null,
  sourceId: "src1",
};
const awsEmergency: Hz = { ...base, isAwsCompliant: true, severity: "emergency", severityBand: "critical" };
const officialCritical: Hz = { ...base, severityBand: "critical" };
const officialInfo: Hz = { ...base };
const communityCritical: Hz = { ...base, reportedById: "u9", sourceId: null, severityBand: "critical" };

// ------------------------------- 1. filters --------------------------------

check("predicate: AWS emergency and official critical are always-on", () => {
  assert.equal(isAlwaysOnOfficialWarning(awsEmergency), true);
  assert.equal(isAlwaysOnOfficialWarning(officialCritical), true);
  assert.equal(isAlwaysOnOfficialWarning(officialInfo), false);
  assert.equal(isAlwaysOnOfficialWarning(communityCritical), false);
  assert.equal(
    isAlwaysOnOfficialWarning({ isAwsCompliant: true, severity: "watchAndAct", severityBand: "action" }),
    false,
  );
});

check("list query: category filter excluding the parent still returns AWS emergency", () => {
  const w = listWhere({ categoryIds: ["flood-parent"], toggles: { userReported: true } });
  assert.equal(evalWhere(w, awsEmergency), true);
  assert.equal(evalWhere(w, officialCritical), true);
});

check("list query: officialNonAws toggle off does not hide official critical / AWS emergency", () => {
  const w = listWhere({ categoryIds: ["fire-parent"], toggles: { userReported: true } });
  assert.equal(evalWhere(w, officialCritical), true);
  assert.equal(evalWhere(w, awsEmergency), true);
});

check("list query: a non-exempt alert is still filtered by category and toggle", () => {
  const w = listWhere({ categoryIds: ["flood-parent"], toggles: { userReported: true } });
  assert.equal(evalWhere(w, officialInfo), false);
  assert.equal(evalWhere(w, communityCritical), false, "community critical is not official");
  const inCat = listWhere({ categoryIds: ["fire-parent"], toggles: { userReported: true } });
  assert.equal(evalWhere(inCat, officialInfo), false, "toggle off still hides non-critical official");
});

check("list query: admin and count (non-hierarchical) callers keep the plain filter", () => {
  const w = listWhere({ categoryIds: ["flood-parent"], toggles: {}, admin: true });
  assert.equal(evalWhere(w, awsEmergency), false);
});

check("raw SQL: gated conditions are OR-ed with the always-on fragment", () => {
  const sql = withAlwaysOnExemptionSql(['(h."categoryId" IN ($1))', "(h.x = 1)"], true);
  assert.equal(sql.length, 1);
  assert.ok(sql[0]!.includes(`(h."categoryId" IN ($1)) AND (h.x = 1)`));
  assert.ok(sql[0]!.includes(ALWAYS_ON_OFFICIAL_SQL));
  assert.ok(sql[0]!.startsWith("((") && sql[0]!.includes(") OR "));
  assert.ok(!/\$\d/.test(ALWAYS_ON_OFFICIAL_SQL), "fragment adds no parameters");
  assert.deepEqual(withAlwaysOnExemptionSql(["a"], false), ["a"]);
  assert.deepEqual(withAlwaysOnExemptionSql([], true), []);
});

check("push recipients: category list excluding the parent still reaches the user for AWS emergency", () => {
  // settings: awsEmergency off, officialNonAws off, only flood subscribed
  const user = {
    awsEmergency: false,
    awsWatchAndAct: true,
    awsAdvice: true,
    officialNonAws: false,
    userReported: true,
    subscribedCategoryIds: ["flood-parent"],
  };
  assert.equal(userMatches(buildPushSettingsUserWhere(awsEmergency, "fire-parent"), user), true);
  assert.equal(userMatches(buildPushSettingsUserWhere(officialCritical, "fire-parent"), user), true);
  // no settings row at all: an always-on warning still reaches the user
  assert.equal(userMatches(buildPushSettingsUserWhere(awsEmergency, "fire-parent"), null), true);
});

check("push recipients: non-exempt alerts still obey switch and category", () => {
  const user = {
    awsEmergency: true,
    awsWatchAndAct: true,
    awsAdvice: true,
    officialNonAws: true,
    userReported: true,
    subscribedCategoryIds: ["flood-parent"],
  };
  assert.equal(userMatches(buildPushSettingsUserWhere(officialInfo, "fire-parent"), user), false);
  assert.equal(userMatches(buildPushSettingsUserWhere(officialInfo, "flood-parent"), user), true);
  const off = { ...user, officialNonAws: false, subscribedCategoryIds: ["flood-parent"] };
  assert.equal(userMatches(buildPushSettingsUserWhere(officialInfo, "flood-parent"), off), false);
  assert.equal(userMatches(buildPushSettingsUserWhere(communityCritical, "fire-parent"), user), false);
  const watch = { ...base, isAwsCompliant: true, severity: "watchAndAct", severityBand: "action" };
  assert.equal(userMatches(buildPushSettingsUserWhere(watch, "fire-parent"), user), false);
});

check("source guards: builders and recipient query use the exemption; location/block rules remain", () => {
  const here = dirname(fileURLToPath(import.meta.url));
  const read = (p: string) => readFileSync(join(here, "..", p), "utf8");
  const hz = read("utils/hazard.util.ts");
  assert.ok(hz.includes("withAlwaysOnExemptionWhere(") && hz.includes("withAlwaysOnExemptionSql("));
  assert.ok(hz.includes("ST_Intersects") && hz.includes('"UserBlock"'), "geo and block rules still in the raw query");
  const ns = read("services/notification.service.ts");
  assert.ok(ns.includes("buildPushSettingsUserWhere(hazard, categoryIdToCheck)"));
  assert.ok(ns.includes("northeastLat: { gte: hazardSouthwestLat }"), "radius rule kept");
  assert.ok(ns.includes("blocksMade: { none: { blockedId: reportedById } }"), "block rule kept");
  assert.ok(ns.includes("scheduledDeletionAt: null"), "deletion rule kept");
  assert.ok(ns.includes("isAwsEmergencyWarning(hazard)"), "cooldown exemption kept");
  assert.ok(!ns.includes(EN_DASH) && !read("utils/official_warning.util.ts").includes(EN_DASH), "no en-dashes");
});

// ---------------------------- 2. awsEmergency ------------------------------

check("awsEmergency=false write ends true; other fields untouched", () => {
  const input = {
    awsEmergency: false,
    awsWatchAndAct: false,
    awsAdvice: false,
    officialNonAws: false,
    userReported: false,
    subscribedCategoryIds: [] as string[],
  };
  const out = withAwsEmergencyAlwaysOn(input);
  assert.equal(out.awsEmergency, true);
  assert.equal(out.awsWatchAndAct, false);
  assert.deepEqual(Object.keys(out).sort(), Object.keys(input).sort(), "response shape kept");
  assert.equal(input.awsEmergency, false, "input not mutated");
});

check("write paths: validator transforms, service and onboarding force true", () => {
  const here = dirname(fileURLToPath(import.meta.url));
  const read = (p: string) => readFileSync(join(here, "..", p), "utf8");
  assert.ok(/awsEmergency: z\.boolean\(\)\.transform\(\(\) => true\)/.test(read("validators/user.validator.ts")));
  const us = read("services/user.service.ts");
  assert.ok(us.includes("withAwsEmergencyAlwaysOn(settings)"), "write + read paths");
  assert.ok(/awsEmergency: true,\s*\n\s*awsWatchAndAct: enableOfficial/.test(read("services/onboarding.service.ts")));
});

// ----------------------------- 3. payload size -----------------------------

const bytes = (o: unknown) => Buffer.byteLength(JSON.stringify(o), "utf8");
const bigHazard = {
  id: "11111111-1111-1111-1111-111111111111",
  title: "Emergency Warning: bushfire at Example",
  description: "Leave now. ".repeat(1000).slice(0, 10000),
  aiSummary: "S".repeat(10000),
  severity: "emergency",
  severityBand: "critical",
  categoryId: "fire-parent",
  shape: "triangle",
  isAwsCompliant: true,
  latitude: -31.950527,
  longitude: 115.860457,
  locationName: "Perth ".repeat(300),
  callsToAction: Array.from({ length: 50 }, (_, i) => `Do thing ${i} `.repeat(40)),
  link: "https://example.invalid/" + "x".repeat(3000),
  createdAt: "2026-10-13T00:00:00.000Z",
};

check("payload: 10,000 char description stays under the limit, core fields kept", () => {
  assert.ok(bytes(bigHazard) > 20000, "fixture really is large");
  const out = boundPushPayload(bigHazard);
  const n = bytes(out);
  console.log(`      before=${bytes(bigHazard)} bytes, after=${n} bytes (limit ${PUSH_PAYLOAD_MAX_BYTES})`);
  assert.ok(n <= PUSH_PAYLOAD_MAX_BYTES);
  for (const k of ["id", "title", "severity", "severityBand", "categoryId", "shape"]) {
    assert.equal((out as any)[k], (bigHazard as any)[k], k);
  }
  assert.equal((out as any).latitude, -31.95, "coordinates rounded");
  assert.equal((out as any).longitude, 115.86);
});

check("payload: small payloads pass through untouched; multibyte text is bounded in bytes", () => {
  const small = { id: "a", title: "t", severityBand: "info" };
  assert.equal(boundPushPayload(small), small);
  const emoji = { ...bigHazard, description: "\u{1F525}".repeat(10000), title: "é".repeat(50) };
  assert.ok(bytes(boundPushPayload(emoji)) <= PUSH_PAYLOAD_MAX_BYTES);
  assert.equal(truncateText("\u{1F525}\u{1F525}\u{1F525}", 2).includes("\ud83d…"), false, "no split surrogate");
});

// ------------------------------ 4. escalation ------------------------------

check("event key: escalation is distinct, identical re-ingest is identical", () => {
  const at = "2026-10-13T00:00:00.000Z";
  const watch = { createdAt: at, severity: "watchAndAct", severityBand: "action", isAwsCompliant: true };
  const emerg = { createdAt: at, severity: "emergency", severityBand: "critical", isAwsCompliant: true };
  assert.notEqual(hazardPushEventKey(watch), hazardPushEventKey(emerg));
  assert.equal(hazardPushEventKey(watch), hazardPushEventKey({ ...watch, createdAt: new Date(at) }));
  assert.notEqual(
    hazardPushEventKey({ ...watch, severityBand: "critical" }),
    hazardPushEventKey(watch),
    "band-only escalation",
  );
  assert.ok(hazardPushEventKey({}).startsWith("created"), "tolerates missing fields");
});

console.log(`\n${passed} checks passed${process.exitCode ? ", FAILURES above" : ""}`);

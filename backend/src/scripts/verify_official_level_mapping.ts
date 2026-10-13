/**
 * The official source's own warning level must never be lost (Rule Zero:
 * severity is assigned in code, never by AI; classification standard
 * section 5.1). Regression fixtures for:
 *   1. level -> band regardless of category (planned burn, structure fire,
 *      crash...), with drills / tests / resolved forcing info,
 *   2. whole-phrase matching ("Emergency Warning: Bush Fire at X",
 *      "follow official advice" is not Advice, "information" is not info),
 *   3. WA DFES warningType -> level, content -> category,
 *   4. GeoJSON category refinement before severity / band,
 *   5. the "other" category fallback never throws,
 *   6. the post-AI summary validator.
 *
 * No server, database or network. The category list is the real seed data
 * (populateInitialCategories) captured through a stubbed prisma upsert.
 *
 * Run: npx tsx src/scripts/verify_official_level_mapping.ts
 */
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { register } from "node:module";
import type { HazardCategory } from "@prisma/client";

// ---- offline harness (no secrets, no network, no database) ----
// Constructing the PrismaClient may reject in the background where no query
// engine is installed. This fixture never queries a database (the upsert is
// stubbed), so that background rejection is irrelevant and is ignored; any
// other unhandled rejection still fails the run.
process.on("unhandledRejection", (reason) => {
  if ((reason as Error)?.name === "PrismaClientInitializationError") return;
  console.error(reason);
  process.exit(1);
});
// config.ts refuses to load without its required variables. Fill any that
// are missing with inert placeholders, only inside this process.
for (const m of readFileSync(
  new URL("../utils/config.ts", import.meta.url),
  "utf8",
).matchAll(/getRequiredEnv\(\s*"([A-Z0-9_]+)"/g)) {
  const key = m[1]!;
  if (!process.env[key]) process.env[key] = /EXP|PORT/.test(key) ? "1" : "placeholder";
}
process.env.DATABASE_URL ||= "postgresql://placeholder:placeholder@localhost:5432/placeholder";
// The ingestion modules reach firebase_admin_client.util, which needs a
// service-account file that must never exist in a checkout. Replace that one
// module with an inert stub for this process only.
register(
  "data:text/javascript," +
    encodeURIComponent(`
export async function resolve(specifier, context, next) {
  if (/firebase_admin_client\\.util(\\.js|\\.ts)?$/.test(specifier)) {
    return {
      url: "data:text/javascript," + encodeURIComponent(
        "export const firebaseAdmin = new Proxy({}, { get() { throw new Error('firebase is stubbed in this fixture'); } });"),
      shortCircuit: true,
    };
  }
  return next(specifier, context);
}`),
  import.meta.url,
);

type Cat = HazardCategory & { parent: HazardCategory | null };

let passed = 0;
let failed = 0;
const failures: string[] = [];
const check = (name: string, fn: () => void): void => {
  try {
    fn();
    passed++;
  } catch (e) {
    failed++;
    failures.push(`${name}: ${(e as Error).message.split("\n")[0]}`);
  }
};

async function loadSeedCategories(): Promise<Cat[]> {
  const prisma = (await import("../utils/prisma_client.util.js")).default;
  const { populateInitialCategories } = await import(
    "../services/hazard_category.service.js"
  );
  const rows: HazardCategory[] = [];
  const stub = prisma.hazardCategory as unknown as {
    upsert: (a: { where: { id: string }; create: Record<string, unknown> }) => Promise<unknown>;
  };
  stub.upsert = async (args) => {
    const now = new Date();
    const row = {
      description: null,
      color: null,
      keywords: [],
      isFireRelated: false,
      parentId: null,
      createdAt: now,
      updatedAt: now,
      name: String(args.create.id),
      ...args.create,
    } as unknown as HazardCategory;
    rows.push(row);
    return row;
  };
  const origLog = console.log;
  console.log = () => {};
  try {
    await populateInitialCategories();
  } finally {
    console.log = origLog;
  }
  const byId = new Map(rows.map((r) => [r.id, r]));
  return rows.map((r) => ({
    ...r,
    parent: r.parentId ? (byId.get(r.parentId) ?? null) : null,
  }));
}

async function main(): Promise<void> {
  const { HazardSeverity, HazardSeverityBand } = await import("@prisma/client");
  const {
    getHazardAttributesFromDescription,
    parseGeoJsonToHazards,
  } = await import("../utils/ingestion.util.js");
  const { getSeverityFromDescription, getSeverityBandFromDescription } =
    await import("../utils/ingestion.severity.util.js");
  const { getCategoryFromDescription } = await import(
    "../utils/ingestion.category.util.js"
  );
  const { validateAISummary } = await import(
    "../utils/ai_summary_validation.util.js"
  );

  const cats = await loadSeedCategories();
  assert.ok(cats.length > 20, `seed categories loaded (${cats.length})`);
  assert.ok(cats.some((c) => c.id === "other"), "seed has 'other'");

  const attrs = (text: string) => getHazardAttributesFromDescription(text, cats);

  // ---- 7. RFS fixtures (category from the text, level from the text) ----
  const rfs = (alert: string, kind: string, extra = "") =>
    `ALERT LEVEL: ${alert}\nLOCATION: Smiths Rd, Bargo\nTYPE: ${kind}\nSTATUS: Under control\n${extra}`;

  check("RFS bushfire Advice -> monitor", () => {
    const a = attrs(rfs("Advice", "Bush Fire", "A fire is burning in the bush."));
    assert.equal(a.severity, HazardSeverity.advice);
    assert.equal(a.category.id, "bushfire");
    assert.equal(a.severityBand, HazardSeverityBand.monitor);
    assert.equal(a.isAwsCompliant, true);
  });
  check("RFS bushfire Watch and Act -> action", () => {
    const a = attrs(rfs("Watch and Act", "Bush Fire", "A bush fire is burning."));
    assert.equal(a.severity, HazardSeverity.watchAndAct);
    assert.equal(a.severityBand, HazardSeverityBand.action);
  });
  check("RFS bushfire Emergency Warning -> critical", () => {
    const a = attrs(rfs("Emergency Warning", "Bush Fire", "A bush fire is burning."));
    assert.equal(a.severity, HazardSeverity.emergency);
    assert.equal(a.severityBand, HazardSeverityBand.critical);
  });
  check("RFS Hazard Reduction with Emergency Warning -> critical (not dropped)", () => {
    const a = attrs(rfs("Emergency Warning", "Hazard Reduction", "Hazard reduction burn escaped containment."));
    assert.equal(a.severity, HazardSeverity.emergency);
    assert.equal(a.severityBand, HazardSeverityBand.critical);
  });
  check("RFS Hazard Reduction with Watch and Act -> action", () => {
    const a = attrs(rfs("Watch and Act", "Hazard Reduction", "Planned burn."));
    assert.equal(a.severityBand, HazardSeverityBand.action);
  });
  check("RFS Structure Fire Advice -> monitor", () => {
    const a = attrs(rfs("Advice", "Structure Fire", "A house fire is being attended."));
    assert.equal(a.severity, HazardSeverity.advice);
    assert.notEqual(a.category.id, "bushfire");
    assert.equal(a.severityBand, HazardSeverityBand.monitor);
  });
  check("level survives for a non-AWS category even when isAwsCompliant is false", () => {
    const a = attrs("Alert Level: Emergency Warning. Structure fire in a warehouse, building well alight.");
    assert.equal(a.isAwsCompliant, false);
    assert.equal(a.severityBand, HazardSeverityBand.critical);
  });
  check("Vic 'Alert Level: Advice' + vehicle crash -> monitor", () => {
    const a = attrs("Alert Level: Advice. Vehicle crash on the Hume Freeway, two lanes blocked.");
    assert.equal(a.severity, HazardSeverity.advice);
    assert.equal(a.severityBand, HazardSeverityBand.monitor);
  });

  // ---- 2. phrase matching ----
  check("'Emergency Warning: Bush Fire at X' -> emergency / critical", () => {
    const text = "Emergency Warning: Bush Fire at Wooroloo";
    assert.equal(getSeverityFromDescription(text), HazardSeverity.emergency);
    assert.equal(getSeverityBandFromDescription(text), HazardSeverityBand.critical);
    const a = attrs(text);
    assert.equal(a.severity, HazardSeverity.emergency);
    assert.equal(a.severityBand, HazardSeverityBand.critical);
  });
  check("'Watch and Act: ...' with colon still matches", () => {
    assert.equal(getSeverityFromDescription("Watch and Act: flood at X"), HazardSeverity.watchAndAct);
  });
  check("'emergency warning' alone is critical band (standard 5.1)", () => {
    assert.equal(getSeverityBandFromDescription("An emergency warning is in place for the suburb."), HazardSeverityBand.critical);
  });
  check("'Not Applicable' -> unknown severity, info band", () => {
    const a = attrs("Not Applicable");
    assert.equal(a.severity, HazardSeverity.unknown);
    assert.equal(a.severityBand, HazardSeverityBand.info);
    assert.equal(a.isAwsCompliant, false);
  });
  check("'follow official advice' alone is NOT the Advice level", () => {
    for (const t of [
      "Residents should follow official advice.",
      "Please follow the official advice from authorities.",
      "Seek further advice from your local council.",
      "Travel advice is available online.",
    ]) {
      assert.notEqual(getSeverityFromDescription(t), HazardSeverity.advice, t);
    }
  });
  check("'Advice' as the level still matches", () => {
    for (const t of ["Alert Level: Advice", "Advice: bush fire at Y", "ADVICE message issued"]) {
      assert.equal(getSeverityFromDescription(t), HazardSeverity.advice, t);
    }
  });
  check("'information' does not match info; 'info' does", () => {
    assert.equal(getSeverityFromDescription("For more information visit the website."), HazardSeverity.unknown);
    assert.equal(getSeverityFromDescription("Alert level: Info"), HazardSeverity.info);
    assert.equal(getSeverityFromDescription("Information only, no action needed."), HazardSeverity.info);
  });
  check("band phrases are whole-phrase (no substring hit)", () => {
    assert.equal(getSeverityBandFromDescription("The reaction now was swift."), HazardSeverityBand.info);
    assert.equal(getSeverityBandFromDescription("Leave now."), HazardSeverityBand.critical);
  });

  // ---- drills / tests / resolved still force info, even with a level ----
  check("drill text with strong words -> info", () => {
    for (const t of [
      "Emergency Warning: this is a test of the emergency warning system. Evacuate now (drill).",
      "Evacuation drill at the school. Emergency warning siren will sound, leave immediately.",
      "Training exercise: Watch and Act scenario, life-threatening conditions simulated.",
      "Scheduled siren test at 11am. Emergency Warning tone.",
    ]) {
      const a = attrs(t);
      assert.equal(a.severityBand, HazardSeverityBand.info, t);
    }
  });
  check("resolved -> info", () => {
    for (const t of [
      "Advice: crash on Hume Hwy. The crash has been cleared and all lanes are now open.",
      "Emergency Warning: house fire. A man has been charged over the incident.",
      "Watch and Act: incident response concluded.",
    ]) {
      assert.equal(attrs(t).severityBand, HazardSeverityBand.info, t);
    }
  });
  check("'this is not a drill' keeps a real Emergency Warning critical", () => {
    const a = attrs("Emergency Warning: this is not a drill. Bush fire at X.");
    assert.equal(a.severityBand, HazardSeverityBand.critical);
  });

  // ---- 3. WA DFES: category from title/content, level from warningType ----
  check("WA DFES 'Emergency Warning' + bushfire text -> bushfire / critical", () => {
    const warning = {
      id: "w1",
      warningType: "Emergency Warning",
      title: "Bushfire - Wooroloo",
      content: "A bushfire is burning out of control. Embers are expected.",
    };
    // Mirrors createWAHazardFromWarning's call (it is module-private).
    const description = `Warning Type: ${warning.warningType}\nRegion: Perth Hills\n${warning.content}`;
    const categoryText = [warning.warningType, warning.title, warning.content].join("\n");
    const a = getHazardAttributesFromDescription(description, cats, undefined, {
      severityText: warning.warningType,
      categoryText,
    });
    assert.equal(a.category.id, "bushfire");
    assert.equal(a.severity, HazardSeverity.emergency);
    assert.equal(a.severityBand, HazardSeverityBand.critical);
    assert.equal(a.isAwsCompliant, true);
  });
  check("WA DFES level comes from warningType only, not from content", () => {
    const a = getHazardAttributesFromDescription(
      "Warning Type: Advice\nContent mentions an emergency warning elsewhere.",
      cats,
      undefined,
      { severityText: "Advice", categoryText: "Advice bushfire Wooroloo" },
    );
    assert.equal(a.severity, HazardSeverity.advice);
    assert.equal(a.severityBand, HazardSeverityBand.monitor);
  });

  // ---- 4. GeoJSON: refine category BEFORE compliance / band ----
  check("GeoJSON mainCategory refines the category before severity / band", () => {
    const fc = {
      type: "FeatureCollection",
      features: [
        {
          type: "Feature",
          id: "42",
          geometry: { type: "Point", coordinates: [150.5, -34.1] },
          properties: {
            title: "Incident at Bargo",
            description: "Alert Level: Watch and Act. Smoke across the area.",
            mainCategory: "Bush Fire",
            subCategoryA: null,
          },
        },
      ],
    };
    const out = parseGeoJsonToHazards({
      data: fc as never,
      idPrefix: "test-geojson",
      availableCategories: cats,
    } as never);
    assert.equal(out.length, 1);
    assert.equal(out[0]!.category?.id, "bushfire");
    assert.equal(out[0]!.severity, HazardSeverity.watchAndAct);
    assert.equal(out[0]!.isAwsCompliant, true);
    assert.equal(out[0]!.severityBand, HazardSeverityBand.action);
  });

  // ---- 5. missing 'other' category must not throw ----
  check("missing 'other' category: logs, does not throw", () => {
    const noOther = cats.filter((c) => c.id !== "other" && c.parent?.id !== "other");
    const origErr = console.error;
    let logged = 0;
    console.error = () => {
      logged++;
    };
    try {
      const c = getCategoryFromDescription("zzzz qqqq nothing matches", noOther);
      assert.equal(c.id, "other");
    } finally {
      console.error = origErr;
    }
    // An empty category list has no 'other' at all.
    console.error = () => {
      logged++;
    };
    try {
      const c = getCategoryFromDescription("anything", []);
      assert.equal(c.id, "other");
    } finally {
      console.error = origErr;
    }
    assert.ok(logged >= 1, "the gap must be logged");
  });

  // ---- 6. post-AI validator ----
  const good = {
    title: "Bushfire near Bargo",
    summary: "A bushfire is burning near Bargo. Embers are expected.",
    callsToAction: ["Leave if the way is clear.", "Check official updates."],
    confidence: "high",
  };
  check("validator accepts a good summary", () => {
    assert.equal(validateAISummary(good).ok, true);
  });
  check("validator rejects non-array callsToAction (string / null / object)", () => {
    for (const v of ["Leave now", null, { a: 1 }, undefined, 5]) {
      assert.equal(validateAISummary({ ...good, callsToAction: v }).ok, false);
    }
  });
  check("validator rejects bad title / summary / confidence", () => {
    assert.equal(validateAISummary({ ...good, title: 5 }).ok, false);
    assert.equal(validateAISummary({ ...good, title: "  " }).ok, false);
    assert.equal(validateAISummary({ ...good, summary: ["x"] }).ok, false);
    assert.equal(validateAISummary({ ...good, confidence: "certain" }).ok, false);
    assert.equal(validateAISummary("text").ok, false);
    assert.equal(validateAISummary([good]).ok, false);
  });
  check("validator rejects over-long summary and actions", () => {
    const long = Array.from({ length: 26 }, () => "word").join(" ");
    assert.equal(validateAISummary({ ...good, summary: long }).ok, false);
    assert.equal(validateAISummary({ ...good, callsToAction: [long] }).ok, false);
    assert.equal(validateAISummary({ ...good, callsToAction: ["a", "b", "c", "d", "e"] }).ok, false);
    assert.equal(validateAISummary({ ...good, callsToAction: ["a", 3] }).ok, false);
  });
  check("validator rejects phone-like digit runs, allows dates and figures", () => {
    for (const t of [
      "Call 0412 345 678 for help.",
      "Call 1800 123 456 now.",
      "Ring +61 8 9222 1234.",
      "Phone 13 11 14.",
      "Dial 000 now.",
    ]) {
      assert.equal(validateAISummary({ ...good, summary: t }).ok, false, t);
      assert.equal(validateAISummary({ ...good, callsToAction: [t] }).ok, false, t);
    }
    for (const t of [
      "Fire burning since 2026-10-12 near the town.",
      "About 10,000 hectares burnt across 3 shires.",
      "Road closed 5 km north of the town at 6 pm.",
    ]) {
      assert.equal(validateAISummary({ ...good, summary: t }).ok, true, t);
    }
  });

  if (failed > 0) {
    for (const f of failures) console.error(`FAIL ${f}`);
    console.error(`${passed} passed, ${failed} failed`);
    process.exit(1);
  }
  console.log(`${passed} passed, 0 failed`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => process.exit(process.exitCode ?? 0));

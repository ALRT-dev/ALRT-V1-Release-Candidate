/**
 * Regression coverage for the Hazard.geom/geomBox generated-column repair
 * (20260902000000_repair_hazard_geom_generated_columns).
 *
 * Root cause traced live against the TEST database (2026-09-02): an
 * accepted, unexpired, correctly-coordinated Admin Portal "TEST — DO NOT
 * USE — Fire" alert had "geom" NULL, so it never matched the Android Map
 * tab's ST_Intersects bounds query and no pin ever appeared - even though
 * nothing in the admin/community creation paths was ever supposed to set
 * "geom" directly. It is a Postgres GENERATED ALWAYS ... STORED column
 * (see 20260704000200_postgis_spatial_indexes) computed automatically
 * from latitude/longitude; the TEST database's copy of that column had
 * silently lost its GENERATED expression (most likely during the
 * provision-test-db.sh/migrate-baseline snapshot restore, a known Prisma
 * limitation the original migration's own comment already warns about),
 * so Postgres never (re)computed it for any row, old or new.
 *
 * Proves, against a real Postgres+PostGIS database:
 *   1. Creating a hazard the same way the Admin Portal's Fire preset does
 *      (latitude/longitude only, no explicit geometry) yields a non-NULL,
 *      correctly-positioned "geom" - the schema-level fix.
 *   2. getHazardsApplyingFiltersRaw (the exact function both the
 *      community and admin hazard-list endpoints call) returns that
 *      hazard when queried with bounds around its coordinates, using the
 *      same "everything visible" filter values the Android Map tab sends
 *      by default - the end-to-end fix the app actually depends on.
 *   3. A hazard with no coordinates at all still has "geom" NULL (the
 *      CASE branch isn't overly permissive) and is correctly absent from
 *      a bounds query.
 *   4. Also covers a second, independent defect found while chasing the
 *      same symptom: buildHazardsWhereClauseRaw's categoryIds handling
 *      (hazard.util.ts) treated a single comma-joined categoryIds string
 *      (?categoryIds=a,b,c - what getHazardsQuerySchema's z.string()
 *      expects, and what the app sends when its default "every main
 *      category selected" filter state is active) as ONE bogus category
 *      id instead of splitting it, unlike its Prisma-based sibling a few
 *      hundred lines above in the same file. Selecting more than one
 *      category - the app's default - silently matched nothing.
 *   5. A third, independent defect found from the TEST server's own
 *      access logs after fixing (4): the Android app's Dio client
 *      actually sends categoryIds as REPEATED query keys
 *      (?categoryIds=a&categoryIds=b), which Express's query parser
 *      turns into a real array - and getHazardsQuerySchema/
 *      getHazardsForAdminQuerySchema typed categoryIds/sourceIds as
 *      z.string() only, so every one of these requests was rejected at
 *      the validator with HTTP 400 "Invalid input: expected string,
 *      received array" before ever reaching (4)'s fix. Both schemas now
 *      accept z.union([z.string(), z.array(z.string())]) - this script's
 *      DB-backed checks below already cover the comma-string shape; the
 *      first check covers the schema itself with the exact repeated-key
 *      shape, with no DB required.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_hazard_geom_generated_column.ts
 */

import assert from "node:assert/strict";
import { PrismaClient, HazardReviewStatus, HazardSeverity, HazardSeverityBand } from "@prisma/client";
import { getHazardsApplyingFiltersRaw } from "../services/hazard.service.js";
import { getHazardsQuerySchema } from "../validators/hazard.validator.js";
import { getHazardsForAdminQuerySchema } from "../validators/admin/hazard.validator.js";

const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

// Same fixed coordinates and disposable source id the Admin Portal's TEST
// Alert picker uses (admin/src/data/testAlertPresets.ts,
// admin/src/pages/AlertsPage.tsx) - not invented values.
const SCARBOROUGH_WA_LAT = -31.89441;
const SCARBOROUGH_WA_LNG = 115.75999;
const TEST_SOURCE_ID = "test-dummy";

const scarboroughBounds = {
  northeastLat: -31.84441,
  northeastLng: 115.80999,
  southwestLat: -31.94441,
  southwestLng: 115.70999,
};

// The exact "everything visible" filter values the Android app's Map tab
// sends by default (HazardFiltersProvider._onInit selects every main
// category; these five type toggles all default true) - see
// map_provider.dart's getMapHazards.
const mapTabDefaultFilters = {
  awsEmergency: true,
  awsWatchAndAct: true,
  awsAdvice: true,
  officialNonAws: true,
  userReported: true,
  ignoreHazardLatLngBounds: true,
};

async function main() {
  console.log("Hazard.geom generated-column regression check (real DB)\n");

  console.log("Schema-only checks (no DB required)");

  await check(
    "getHazardsQuerySchema accepts categoryIds as repeated-key array (the Android app's actual request shape)",
    () => {
      const repeatedKeyExample = {
        categoryIds: ["securityAndCrime", "healthAndAir"],
        sourceIds: ["test-dummy", "another-source"],
      };
      const result = getHazardsQuerySchema.safeParse(repeatedKeyExample);
      assert.ok(
        result.success,
        `expected the array shape to validate, got: ${
          result.success ? "" : JSON.stringify(result.error.issues)
        }`,
      );
      assert.deepEqual(result.data?.categoryIds, repeatedKeyExample.categoryIds);
      assert.deepEqual(result.data?.sourceIds, repeatedKeyExample.sourceIds);
    },
  );

  await check(
    "getHazardsQuerySchema still accepts categoryIds as a single comma-joined string (unchanged behaviour)",
    () => {
      const result = getHazardsQuerySchema.safeParse({
        categoryIds: "bushfire,flood",
      });
      assert.ok(result.success);
      assert.equal(result.data?.categoryIds, "bushfire,flood");
    },
  );

  await check(
    "getHazardsForAdminQuerySchema (the admin list endpoint's copy of the same schema) also accepts the repeated-key array shape",
    () => {
      const result = getHazardsForAdminQuerySchema.safeParse({
        categoryIds: ["securityAndCrime", "healthAndAir"],
      });
      assert.ok(
        result.success,
        `expected the array shape to validate, got: ${
          result.success ? "" : JSON.stringify(result.error.issues)
        }`,
      );
    },
  );

  console.log("\nDB-backed checks");

  console.log("Setup");
  const category = await prisma.hazardCategory.findUnique({
    where: { id: "bushfire" },
  });
  assert.ok(category, 'seed data must include the "bushfire" category');

  // The same "every main category selected" default the app's
  // HazardFiltersProvider._onInit ships with, comma-joined the same way
  // getHazardsQuerySchema's categoryIds: z.string() expects a client to
  // send it.
  const mainCategories = await prisma.hazardCategory.findMany({
    where: { parentId: null },
    select: { id: true },
  });
  assert.ok(mainCategories.length > 1, "seed data must include more than one main category");
  const allMainCategoryIdsCommaJoined = mainCategories.map((c) => c.id).join(",");

  await prisma.hazardSource.upsert({
    where: { id: TEST_SOURCE_ID },
    update: {},
    create: {
      id: TEST_SOURCE_ID,
      name: "TEST DUMMY SOURCE - DO NOT USE",
      url: "https://example.invalid/test",
    },
  });

  const fireHazard = await prisma.hazard.create({
    data: {
      title: "TEST — DO NOT USE — geom regression check — Fire",
      description: "Regression coverage only. Not a real fire.",
      severity: HazardSeverity.emergency,
      severityBand: HazardSeverityBand.critical,
      callsToAction: [],
      categoryId: category!.id,
      sourceId: TEST_SOURCE_ID,
      latitude: SCARBOROUGH_WA_LAT,
      longitude: SCARBOROUGH_WA_LNG,
      isAwsCompliant: false,
      reviewStatus: HazardReviewStatus.accepted,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    },
  });

  const noCoordsHazard = await prisma.hazard.create({
    data: {
      title: "TEST — DO NOT USE — geom regression check — no coords",
      description: "Regression coverage only.",
      severity: HazardSeverity.advice,
      severityBand: HazardSeverityBand.info,
      callsToAction: [],
      categoryId: category!.id,
      sourceId: TEST_SOURCE_ID,
      isAwsCompliant: false,
      reviewStatus: HazardReviewStatus.accepted,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    },
  });

  try {
    await check(
      'a Scarborough-coordinate hazard has a non-NULL "geom" that intersects the Scarborough bounds',
      async () => {
        const rows = await prisma.$queryRaw<
          { has_geom: boolean; in_bounds: boolean }[]
        >`
          SELECT
            "geom" IS NOT NULL AS has_geom,
            ST_Intersects(
              "geom",
              ST_MakeEnvelope(
                ${scarboroughBounds.southwestLng},
                ${scarboroughBounds.southwestLat},
                ${scarboroughBounds.northeastLng},
                ${scarboroughBounds.northeastLat},
                4326
              )
            ) AS in_bounds
          FROM "Hazard"
          WHERE id = ${fireHazard.id}
        `;
        assert.equal(rows.length, 1);
        assert.equal(rows[0]!.has_geom, true, "geom must not be NULL");
        assert.equal(rows[0]!.in_bounds, true, "geom must intersect the Scarborough bounds");
      },
    );

    await check(
      "a hazard with no coordinates keeps a NULL geom (the CASE branch is not overly permissive)",
      async () => {
        const rows = await prisma.$queryRaw<{ has_geom: boolean }[]>`
          SELECT "geom" IS NOT NULL AS has_geom
          FROM "Hazard"
          WHERE id = ${noCoordsHazard.id}
        `;
        assert.equal(rows[0]!.has_geom, false);
      },
    );

    await check(
      "getHazardsApplyingFiltersRaw returns the Scarborough hazard for the Map tab's default Scarborough-bounds request",
      async () => {
        const hazards = await getHazardsApplyingFiltersRaw({
          ...scarboroughBounds,
          ...mapTabDefaultFilters,
          pageSize: 100,
        });
        const ids = hazards.map((h) => h.id);
        assert.ok(
          ids.includes(fireHazard.id),
          `expected ${fireHazard.id} in the map-bounds result set, got ${JSON.stringify(ids)}`,
        );
      },
    );

    await check(
      "getHazardsApplyingFiltersRaw does not return the no-coordinates hazard for a bounds request",
      async () => {
        const hazards = await getHazardsApplyingFiltersRaw({
          ...scarboroughBounds,
          ...mapTabDefaultFilters,
          pageSize: 100,
        });
        const ids = hazards.map((h) => h.id);
        assert.ok(!ids.includes(noCoordsHazard.id));
      },
    );

    await check(
      "getHazardsApplyingFiltersRaw still returns the hazard when categoryIds is a comma-joined string of every main category (the app's actual default selection)",
      async () => {
        const hazards = await getHazardsApplyingFiltersRaw({
          ...scarboroughBounds,
          ...mapTabDefaultFilters,
          categoryIds: allMainCategoryIdsCommaJoined,
          pageSize: 100,
        });
        const ids = hazards.map((h) => h.id);
        assert.ok(
          ids.includes(fireHazard.id),
          "buildHazardsWhereClauseRaw's categoryIds branch must split a comma-joined string " +
            "(matching its Prisma-based sibling and the querystring schema) rather than " +
            "matching the whole joined string as one bogus category id",
        );
      },
    );

    await check(
      "getHazardsApplyingFiltersRaw also returns the hazard when categoryIds arrives as a real array of every main category id (the Android app's actual repeated-key request, post-validator)",
      async () => {
        const hazards = await getHazardsApplyingFiltersRaw({
          ...scarboroughBounds,
          ...mapTabDefaultFilters,
          categoryIds: mainCategories.map((c) => c.id),
          pageSize: 100,
        });
        const ids = hazards.map((h) => h.id);
        assert.ok(
          ids.includes(fireHazard.id),
          `expected ${fireHazard.id} in the map-bounds result set with an array categoryIds, got ${JSON.stringify(ids)}`,
        );
      },
    );

    console.log(`\n${passed} checks passed.`);
  } finally {
    await prisma.hazard.deleteMany({
      where: { id: { in: [fireHazard.id, noCoordsHazard.id] } },
    });
  }
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

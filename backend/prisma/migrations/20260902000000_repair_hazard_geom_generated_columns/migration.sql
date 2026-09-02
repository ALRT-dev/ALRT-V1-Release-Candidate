-- Repairs Hazard.geom / Hazard.geomBox on any deployment where these
-- columns exist but are NOT the GENERATED ALWAYS ... STORED columns that
-- 20260704000200_postgis_spatial_indexes defines - e.g. a database
-- provisioned from a schema snapshot/baseline rather than a full
-- sequential `prisma migrate deploy`, where a dump/restore step silently
-- dropped the GENERATED expression and left a plain, permanently-NULL
-- geometry column instead. Prisma's own migration history still marks
-- 20260704000200 "applied" on such a database, so `migrate deploy` never
-- revisits it and the column stays broken indefinitely - nothing in the
-- application ever writes to "geom"/"geomBox" directly (by design, see
-- that migration's comment), so there is no code path that can repair it.
--
-- Confirmed live on the TEST database (2026-09-02): accepted, unexpired,
-- correctly-coordinated hazards had "geom" NULL, which is why they never
-- matched the Map tab's ST_Intersects bounds query.
--
-- Idempotent and safe everywhere, including a database where the columns
-- are already correct: DROP COLUMN IF EXISTS + re-ADD the identical
-- GENERATED definition is a complete no-op there (same expression, same
-- stored values, nothing observable changes). Where it was broken,
-- Postgres recomputes geom/geomBox for every existing row the instant the
-- column is (re)added, from that row's own already-stored latitude/
-- longitude (or bounding-box columns) - no separate backfill statement is
-- needed, and no other column is touched. This only ever re-derives a
-- value from columns that were always the source of truth for it; it
-- never introduces a new value.

ALTER TABLE "Hazard" DROP COLUMN IF EXISTS "geom";
ALTER TABLE "Hazard"
  ADD COLUMN "geom" geometry(Point, 4326)
  GENERATED ALWAYS AS (
    CASE
      WHEN "latitude" IS NOT NULL AND "longitude" IS NOT NULL
        THEN ST_SetSRID(ST_MakePoint("longitude", "latitude"), 4326)
      ELSE NULL
    END
  ) STORED;

CREATE INDEX IF NOT EXISTS "Hazard_geom_idx"
  ON "Hazard" USING GIST ("geom");

ALTER TABLE "Hazard" DROP COLUMN IF EXISTS "geomBox";
ALTER TABLE "Hazard"
  ADD COLUMN "geomBox" geometry(Polygon, 4326)
  GENERATED ALWAYS AS (
    CASE
      WHEN "southwestLng" IS NOT NULL AND "southwestLat" IS NOT NULL
       AND "northeastLng" IS NOT NULL AND "northeastLat" IS NOT NULL
        THEN ST_MakeEnvelope("southwestLng", "southwestLat", "northeastLng", "northeastLat", 4326)
      ELSE NULL
    END
  ) STORED;

CREATE INDEX IF NOT EXISTS "Hazard_geomBox_idx"
  ON "Hazard" USING GIST ("geomBox");

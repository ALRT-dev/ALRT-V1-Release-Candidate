-- A check-in request can now be aimed at specific members of the circle
-- ("Ask Amy") instead of always the whole group. Empty = everyone, which
-- is what every existing row means, so no backfill is needed.
ALTER TABLE "public"."FamilyCheckInRequest"
  ADD COLUMN "targetMemberIds" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

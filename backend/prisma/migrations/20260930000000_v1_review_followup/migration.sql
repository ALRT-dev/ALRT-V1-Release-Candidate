-- V1 review follow-up. Additive only; no existing row changes.
-- SOS location: the sender's explicit per-SOS choice, delivered precision
-- and when the point was actually fixed; SOS trail points tagged with
-- their SOS so they never update the group's snapshot channel.
ALTER TABLE "FamilySosEvent"
  ADD COLUMN "locationMode" TEXT,
  ADD COLUMN "locationPrecision" TEXT,
  ADD COLUMN "locationCapturedAt" TIMESTAMP(3),
  ADD COLUMN "locationAccuracyM" DOUBLE PRECISION;

ALTER TABLE "FamilyLocationPing"
  ADD COLUMN "sosEventId" TEXT;

CREATE INDEX "FamilyLocationPing_sosEventId_idx"
  ON "FamilyLocationPing"("sosEventId");

-- A pending tier change the store dated for later (advance renewal).
ALTER TABLE "StoreSubscription"
  ADD COLUMN "pendingEffectiveAt" TIMESTAMP(3);

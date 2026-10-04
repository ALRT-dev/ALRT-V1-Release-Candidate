-- V1 subscription changes: requested tier changes stay pending until the
-- store confirms them, and upgrades that arrive as a new store transaction
-- take over the same group. Additive only; no existing row changes.

ALTER TABLE "StoreSubscription"
  ADD COLUMN "pendingProductId" TEXT,
  ADD COLUMN "pendingTier" "PlanTier",
  ADD COLUMN "pendingRequestedAt" TIMESTAMP(3),
  ADD COLUMN "tierChangedAt" TIMESTAMP(3),
  ADD COLUMN "changeConfirmedVia" TEXT,
  ADD COLUMN "supersededAt" TIMESTAMP(3),
  ADD COLUMN "supersededById" TEXT;

ALTER TABLE "SponsorshipIntent"
  ADD COLUMN "replacesSubscriptionId" TEXT;

CREATE INDEX "SponsorshipIntent_replacesSubscriptionId_idx"
  ON "SponsorshipIntent"("replacesSubscriptionId");

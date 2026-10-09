-- V1 access model (master spec, 28 Sep 2026).
--
-- Additive only: no existing row is changed or deleted. Every existing
-- circle starts in "individual" funding mode, which is what the old model
-- meant (the host's own ALRT+ paid for it). User.plan stays as a mirror of
-- the personal Individual entitlement. Rollback: see
-- docs/V1_ACCESS_MODEL_IMPLEMENTATION.md (drop the three new tables, the
-- two enums and the added columns; no data outside them is touched).

CREATE TYPE "PlanTier" AS ENUM ('individual', 'family', 'group20', 'group50');

CREATE TYPE "StoreSubscriptionStatus" AS ENUM (
  'active', 'cancelled', 'billingIssue', 'expired', 'refunded'
);

CREATE TYPE "CircleFundingMode" AS ENUM ('individual', 'sponsored');

ALTER TABLE "FamilyCircle"
  ADD COLUMN IF NOT EXISTS "fundingMode" "CircleFundingMode" NOT NULL DEFAULT 'individual';

CREATE TABLE "StoreSubscription" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "tier" "PlanTier" NOT NULL,
  "productId" TEXT NOT NULL,
  "store" TEXT,
  "environment" TEXT,
  "originalTransactionId" TEXT NOT NULL,
  "status" "StoreSubscriptionStatus" NOT NULL,
  "periodType" TEXT,
  "expiresAt" TIMESTAMP(3),
  "gracePeriodExpiresAt" TIMESTAMP(3),
  "lastEventAt" TIMESTAMP(3) NOT NULL,
  "boundCircleId" TEXT,
  "boundAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "StoreSubscription_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "StoreSubscription_originalTransactionId_key"
  ON "StoreSubscription"("originalTransactionId");
CREATE INDEX "StoreSubscription_userId_idx" ON "StoreSubscription"("userId");
CREATE INDEX "StoreSubscription_boundCircleId_idx" ON "StoreSubscription"("boundCircleId");
ALTER TABLE "StoreSubscription"
  ADD CONSTRAINT "StoreSubscription_userId_fkey" FOREIGN KEY ("userId")
  REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "StoreSubscription"
  ADD CONSTRAINT "StoreSubscription_boundCircleId_fkey" FOREIGN KEY ("boundCircleId")
  REFERENCES "FamilyCircle"("id") ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE "SponsorshipIntent" (
  "id" TEXT NOT NULL,
  "payerUserId" TEXT NOT NULL,
  "circleId" TEXT NOT NULL,
  "tier" "PlanTier" NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "consumedAt" TIMESTAMP(3),
  "subscriptionId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SponsorshipIntent_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "SponsorshipIntent_subscriptionId_key"
  ON "SponsorshipIntent"("subscriptionId");
CREATE INDEX "SponsorshipIntent_payerUserId_consumedAt_idx"
  ON "SponsorshipIntent"("payerUserId", "consumedAt");
ALTER TABLE "SponsorshipIntent"
  ADD CONSTRAINT "SponsorshipIntent_payerUserId_fkey" FOREIGN KEY ("payerUserId")
  REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SponsorshipIntent"
  ADD CONSTRAINT "SponsorshipIntent_circleId_fkey" FOREIGN KEY ("circleId")
  REFERENCES "FamilyCircle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE "RevenueCatWebhookEvent" (
  "id" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "appUserId" TEXT,
  "productId" TEXT,
  "eventAt" TIMESTAMP(3),
  "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "processedAt" TIMESTAMP(3),
  "result" TEXT,
  CONSTRAINT "RevenueCatWebhookEvent_pkey" PRIMARY KEY ("id")
);

-- SOS audience (master spec §12). Existing events keep the old whole-circle
-- audience (audienceRestricted=false); new events store their recipients.
ALTER TABLE "FamilySosEvent"
  ADD COLUMN IF NOT EXISTS "recipientUserIds" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN IF NOT EXISTS "audienceRestricted" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "endedByMemberId" TEXT;

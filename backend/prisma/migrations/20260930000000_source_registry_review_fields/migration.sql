ALTER TABLE "HazardSource"
  ADD COLUMN "lastReviewedAt" TIMESTAMP(3),
  ADD COLUMN "expiryReviewAt" TIMESTAMP(3),
  ADD COLUMN "licensingNotes" TEXT;

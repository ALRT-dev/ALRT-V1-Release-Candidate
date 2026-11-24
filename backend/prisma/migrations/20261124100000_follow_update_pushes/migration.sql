-- Followers are pushed for every agency update (owner, 24 Nov 2026).
-- Existing rows stay NULL and take a silent baseline on the next run.
ALTER TABLE "HazardFollow" ADD COLUMN IF NOT EXISTS "lastUpdateAt" TEXT;

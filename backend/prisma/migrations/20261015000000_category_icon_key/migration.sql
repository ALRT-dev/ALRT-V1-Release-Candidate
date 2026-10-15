-- Admin-selectable map icon per category (owner, 15 Oct 2026).
ALTER TABLE "public"."HazardCategory" ADD COLUMN "iconKey" TEXT;

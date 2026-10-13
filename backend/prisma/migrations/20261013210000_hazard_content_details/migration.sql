ALTER TABLE "Hazard" ADD COLUMN "contentDetails" JSONB;
ALTER TABLE "Hazard" ADD COLUMN "nativeWarningLevel" TEXT;
ALTER TABLE "Hazard" ADD COLUMN "jurisdictionCountry" TEXT;
ALTER TABLE "Hazard" ADD COLUMN "sourceContentHash" TEXT;

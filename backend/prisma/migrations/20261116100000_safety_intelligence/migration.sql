-- Safety intelligence build (owner decisions D1 to D8, 16 November 2026).
-- Additive only: no existing row is changed, no source is switched off.

-- Roles and lifecycle
ALTER TYPE "AdminRole" ADD VALUE IF NOT EXISTS 'reviewer';
ALTER TYPE "HazardSourceLifecycleStatus" ADD VALUE IF NOT EXISTS 'draft';

-- Licence gate
ALTER TABLE "HazardSource" ADD COLUMN IF NOT EXISTS "licenceConfirmedAt" TIMESTAMP(3);
ALTER TABLE "HazardSource" ADD COLUMN IF NOT EXISTS "licenceConfirmedById" TEXT;

-- Traceability per alert
ALTER TABLE "Hazard" ADD COLUMN IF NOT EXISTS "extractionMethod" TEXT;
ALTER TABLE "Hazard" ADD COLUMN IF NOT EXISTS "extractionRef" TEXT;

-- Prompt versions
ALTER TABLE "AIPrompt" ADD COLUMN IF NOT EXISTS "version" INTEGER NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS "AIPromptVersion" (
  "id" TEXT NOT NULL,
  "promptId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "version" INTEGER NOT NULL,
  "content" TEXT NOT NULL,
  "model" TEXT NOT NULL,
  "changedById" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AIPromptVersion_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "AIPromptVersion_promptId_version_key" ON "AIPromptVersion"("promptId", "version");

-- Version 1 of every existing prompt, so history starts from today.
INSERT INTO "AIPromptVersion" ("id","promptId","name","version","content","model","changedById")
SELECT gen_random_uuid()::text, "id", "name", 1, "content", "model", "updatedById" FROM "AIPrompt"
ON CONFLICT DO NOTHING;

-- AI usage log (no prompt or answer text)
CREATE TABLE IF NOT EXISTS "AiUsageEvent" (
  "id" TEXT NOT NULL,
  "purpose" TEXT NOT NULL,
  "provider" TEXT NOT NULL,
  "model" TEXT NOT NULL,
  "sourceId" TEXT,
  "inputTokens" INTEGER NOT NULL DEFAULT 0,
  "outputTokens" INTEGER NOT NULL DEFAULT 0,
  "cacheReadTokens" INTEGER NOT NULL DEFAULT 0,
  "durationMs" INTEGER NOT NULL DEFAULT 0,
  "ok" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AiUsageEvent_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "AiUsageEvent_createdAt_idx" ON "AiUsageEvent"("createdAt");
CREATE INDEX IF NOT EXISTS "AiUsageEvent_purpose_createdAt_idx" ON "AiUsageEvent"("purpose", "createdAt");

-- Shared guidance library
DO $$ BEGIN
  CREATE TYPE "GuidanceKind" AS ENUM ('advice', 'profile', 'guide_section', 'answer', 'country_fact');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE "GuidanceStatus" AS ENUM ('draft', 'in_review', 'approved', 'retired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS "GuidanceRecord" (
  "id" TEXT NOT NULL,
  "key" TEXT NOT NULL,
  "kind" "GuidanceKind" NOT NULL,
  "hazard" TEXT,
  "cohort" TEXT,
  "stage" TEXT,
  "jurisdiction" TEXT NOT NULL DEFAULT 'AU',
  "title" TEXT,
  "text" TEXT NOT NULL,
  "longText" TEXT,
  "triggers" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "sourceAgency" TEXT NOT NULL,
  "sourceUrl" TEXT NOT NULL,
  "licence" TEXT,
  "version" INTEGER NOT NULL DEFAULT 1,
  "status" "GuidanceStatus" NOT NULL DEFAULT 'draft',
  "authorId" TEXT,
  "reviewerId" TEXT,
  "reviewedAt" TIMESTAMP(3),
  "publishedAt" TIMESTAMP(3),
  "nextReviewAt" TIMESTAMP(3),
  "changeNote" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "GuidanceRecord_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "GuidanceRecord_key_version_key" ON "GuidanceRecord"("key", "version");
CREATE INDEX IF NOT EXISTS "GuidanceRecord_kind_hazard_jurisdiction_status_idx" ON "GuidanceRecord"("kind", "hazard", "jurisdiction", "status");
CREATE INDEX IF NOT EXISTS "GuidanceRecord_status_nextReviewAt_idx" ON "GuidanceRecord"("status", "nextReviewAt");

-- Country register
CREATE TABLE IF NOT EXISTS "CountryProfile" (
  "code" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "aliases" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "emergencyNumber" TEXT NOT NULL,
  "policeNumber" TEXT,
  "ambulanceNumber" TEXT,
  "fireNumber" TEXT,
  "hazards" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "warningAgencies" JSONB NOT NULL DEFAULT '[]',
  "drivingSide" TEXT,
  "notes" TEXT,
  "sourceUrl" TEXT NOT NULL,
  "status" "GuidanceStatus" NOT NULL DEFAULT 'draft',
  "reviewedAt" TIMESTAMP(3),
  "nextReviewAt" TIMESTAMP(3),
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "CountryProfile_pkey" PRIMARY KEY ("code")
);

-- Server-side Follow
CREATE TABLE IF NOT EXISTS "HazardFollow" (
  "userId" TEXT NOT NULL,
  "hazardId" TEXT NOT NULL,
  "lastLevel" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "HazardFollow_pkey" PRIMARY KEY ("userId", "hazardId")
);
CREATE INDEX IF NOT EXISTS "HazardFollow_hazardId_idx" ON "HazardFollow"("hazardId");

-- Daily assurance
CREATE TABLE IF NOT EXISTS "AssuranceReport" (
  "id" TEXT NOT NULL,
  "runAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "passed" INTEGER NOT NULL,
  "warnings" INTEGER NOT NULL,
  "failures" INTEGER NOT NULL,
  "checks" JSONB NOT NULL,
  "acknowledgedAt" TIMESTAMP(3),
  "acknowledgedById" TEXT,
  CONSTRAINT "AssuranceReport_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "AssuranceReport_runAt_idx" ON "AssuranceReport"("runAt");

-- Generic feed adapters: per-source field mapping
ALTER TABLE "HazardSource" ADD COLUMN IF NOT EXISTS "adapterConfig" JSONB;

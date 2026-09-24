CREATE TYPE "HazardSourceLifecycleStatus" AS ENUM ('active', 'monitoring', 'degraded', 'suspended', 'retired');

CREATE TYPE "HazardSourceHealthStatus" AS ENUM ('unknown', 'healthy', 'stale', 'failing');

ALTER TABLE "HazardSource"
  ADD COLUMN "country" TEXT,
  ADD COLUMN "region" TEXT,
  ADD COLUMN "coverage" TEXT,
  ADD COLUMN "sourceType" TEXT,
  ADD COLUMN "authorityLevel" TEXT,
  ADD COLUMN "feedUrl" TEXT,
  ADD COLUMN "format" TEXT,
  ADD COLUMN "accessMethod" TEXT,
  ADD COLUMN "adapterKey" TEXT,
  ADD COLUMN "scheduleMinutes" INTEGER,
  ADD COLUMN "secretRef" TEXT,
  ADD COLUMN "warningTypes" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN "sourceNativeSeverity" TEXT,
  ADD COLUMN "sourceNativeSymbol" TEXT,
  ADD COLUMN "lifecycleStatus" "HazardSourceLifecycleStatus" NOT NULL DEFAULT 'active',
  ADD COLUMN "healthStatus" "HazardSourceHealthStatus" NOT NULL DEFAULT 'unknown',
  ADD COLUMN "lastHealthCheck" TIMESTAMP(3),
  ADD COLUMN "lastSuccessfulFetch" TIMESTAMP(3),
  ADD COLUMN "lastAlertSeen" TIMESTAMP(3),
  ADD COLUMN "lastHealthError" TEXT;
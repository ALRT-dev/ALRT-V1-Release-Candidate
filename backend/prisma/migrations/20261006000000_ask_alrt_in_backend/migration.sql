-- Ask ALRT moves into the backend: answer library, settings and daily counters.
CREATE TABLE "AskAlrtEntry" (
  "id" TEXT NOT NULL,
  "triggers" TEXT[],
  "keywords" TEXT[],
  "answer" TEXT NOT NULL,
  "enabled" BOOLEAN NOT NULL DEFAULT true,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedBy" TEXT,
  CONSTRAINT "AskAlrtEntry_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "AskAlrtConfig" (
  "key" TEXT NOT NULL,
  "value" JSONB NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedBy" TEXT,
  CONSTRAINT "AskAlrtConfig_pkey" PRIMARY KEY ("key")
);

CREATE TABLE "AskAlrtUsage" (
  "userId" TEXT NOT NULL,
  "dayKey" TEXT NOT NULL,
  "aiCount" INTEGER NOT NULL DEFAULT 0,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AskAlrtUsage_pkey" PRIMARY KEY ("userId","dayKey")
);

CREATE TABLE "AskAlrtZone" (
  "userId" TEXT NOT NULL,
  "timeZone" TEXT NOT NULL,
  "setAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AskAlrtZone_pkey" PRIMARY KEY ("userId")
);

ALTER TABLE "AskAlrtUsage" ADD CONSTRAINT "AskAlrtUsage_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "AskAlrtZone" ADD CONSTRAINT "AskAlrtZone_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Ready tab: emergency plans and drills (per-user preparedness features)

CREATE TABLE "EmergencyPlan" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "meetingPoint" TEXT,
    "evacuationRoute" TEXT,
    "notes" TEXT,
    "items" JSONB NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmergencyPlan_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "EmergencyDrill" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "planId" TEXT,
    "title" TEXT NOT NULL,
    "notes" TEXT,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "durationMinutes" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmergencyDrill_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "EmergencyPlan_userId_idx" ON "EmergencyPlan"("userId");
CREATE INDEX "EmergencyDrill_userId_idx" ON "EmergencyDrill"("userId");
CREATE INDEX "EmergencyDrill_planId_idx" ON "EmergencyDrill"("planId");

ALTER TABLE "EmergencyPlan" ADD CONSTRAINT "EmergencyPlan_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "EmergencyDrill" ADD CONSTRAINT "EmergencyDrill_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "EmergencyDrill" ADD CONSTRAINT "EmergencyDrill_planId_fkey"
    FOREIGN KEY ("planId") REFERENCES "EmergencyPlan"("id") ON DELETE SET NULL ON UPDATE CASCADE;

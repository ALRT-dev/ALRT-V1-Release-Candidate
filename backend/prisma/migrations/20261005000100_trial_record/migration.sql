-- Free-trial record: one keyed hash per email, kept after account deletion.
CREATE TABLE "TrialRecord" (
  "id" TEXT NOT NULL,
  "emailHash" TEXT NOT NULL,
  "firstTrialAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "TrialRecord_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "TrialRecord_emailHash_key" ON "TrialRecord"("emailHash");

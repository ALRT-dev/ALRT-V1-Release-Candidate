-- One tap = one action across the phone and the Apple Watch.
-- Additive only: two nullable columns and two unique indexes. Existing rows
-- keep NULL, and Postgres treats NULLs as distinct, so nothing existing
-- conflicts and older apps (which never send the key) behave as before.

ALTER TABLE "FamilyCheckIn" ADD COLUMN "clientRequestId" TEXT;
ALTER TABLE "FamilySosEvent" ADD COLUMN "clientRequestId" TEXT;

CREATE UNIQUE INDEX "FamilyCheckIn_memberId_clientRequestId_key" ON "FamilyCheckIn"("memberId", "clientRequestId");
CREATE UNIQUE INDEX "FamilySosEvent_memberId_clientRequestId_key" ON "FamilySosEvent"("memberId", "clientRequestId");

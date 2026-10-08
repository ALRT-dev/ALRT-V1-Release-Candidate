-- "Past SOS" survives the sender leaving: the SOS row no longer cascades
-- away with the sender's membership. memberId becomes nullable and is set
-- to NULL when that member row is deleted, and senderName keeps the name
-- the SOS was sent under. Invite codes default to the group cap (20).
-- Additive only: no rows are changed or removed.
ALTER TABLE "FamilySosEvent" ADD COLUMN "senderName" TEXT;
ALTER TABLE "FamilySosEvent" ALTER COLUMN "memberId" DROP NOT NULL;
ALTER TABLE "FamilySosEvent" DROP CONSTRAINT "FamilySosEvent_memberId_fkey";
ALTER TABLE "FamilySosEvent" ADD CONSTRAINT "FamilySosEvent_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "FamilyMember"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "FamilyInvite" ALTER COLUMN "maxUses" SET DEFAULT 20;

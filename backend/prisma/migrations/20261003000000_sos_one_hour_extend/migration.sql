-- SOS lasts 1 hour; the sender can confirm to extend. Additive only.
ALTER TABLE "FamilySosEvent" ADD COLUMN "liveUntil" TIMESTAMP(3);

-- SOS ending-soon reminder: the liveUntil value the sender was last
-- reminded about (about 10 minutes before it). One reminder per SOS per
-- liveUntil value; extending the SOS sets a new liveUntil, so the marker
-- no longer matches and the next reminder can go. Additive only.
ALTER TABLE "FamilySosEvent" ADD COLUMN "endingSoonNotifiedFor" TIMESTAMP(3);

-- SOS live-location sharing used to be assumed, not chosen: every SOS
-- started a continuous location share unconditionally. The sender now
-- picks at the moment of triggering (low battery, or any other reason to
-- send SOS without live tracking). Defaulting true keeps every existing
-- row reading exactly as it always behaved -- live -- with no backfill
-- needed; only newly created SOS events pass the sender's real choice.
ALTER TABLE "FamilySosEvent" ADD COLUMN "isLive" BOOLEAN NOT NULL DEFAULT true;

-- Add per-schedule IANA timezone so fireDueScheduledCheckIns checks each
-- schedule against its owner's local time instead of the hardcoded
-- Australia/Brisbane offset.
-- Existing rows default to "Australia/Brisbane" (UTC+10, no DST) to
-- preserve current behaviour.

ALTER TABLE "FamilyScheduledCheckIn"
  ADD COLUMN "timezone" TEXT NOT NULL DEFAULT 'Australia/Brisbane';

-- The scheduler queries by (timeOfDay, timezone) to find due rows.
CREATE INDEX "FamilyScheduledCheckIn_timeOfDay_timezone_idx"
  ON "FamilyScheduledCheckIn" ("timeOfDay", "timezone");

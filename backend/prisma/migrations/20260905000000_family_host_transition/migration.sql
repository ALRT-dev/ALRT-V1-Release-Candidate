-- Host-transition (7-day grace period) for Family circles.
--
-- When a circle is left without a host — the owner's ALRT+ entitlement
-- lapses, the owner leaves, or the owner's account is deleted — the circle
-- must keep working for its remaining members rather than disband or lose
-- safety features. hostTransitionStartedAt anchors that window; once set,
-- the app computes days-remaining/locked state from it rather than storing
-- a separate deadline. hostTransitionHostName is a display-only memory of
-- who was hosting, kept because a departed/deleted owner's FamilyMember
-- row no longer exists to read a name from.
ALTER TABLE "public"."FamilyCircle"
  ADD COLUMN "hostTransitionStartedAt" TIMESTAMP(3),
  ADD COLUMN "hostTransitionHostName" TEXT;

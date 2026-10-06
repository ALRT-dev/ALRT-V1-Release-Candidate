/**
 * The tier in force at [now]. A pending change the store dated for later
 * (pendingEffectiveAt) takes over exactly at that time, not when the event
 * arrived or the payment was collected; before it the current tier and
 * capacity stay. A pending change with no date is only a request.
 * Dependency-free so the boundary can be unit-tested.
 */
export const effectiveTierAt = <T extends string>(
  sub: { tier: T; pendingTier: T | null; pendingEffectiveAt: Date | null },
  now = new Date(),
): T =>
  sub.pendingTier && sub.pendingEffectiveAt && sub.pendingEffectiveAt.getTime() <= now.getTime()
    ? sub.pendingTier
    : sub.tier;

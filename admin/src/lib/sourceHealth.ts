interface SourceObservation {
  healthStatus: string;
  scheduleMinutes: number | null;
  lastHealthCheck: string | null;
  lastSuccessfulFetch: string | null;
}

const timestamp = (value: string | null) => value ? Date.parse(value) : NaN;

/** A display-only assessment of registry observations, never workflow delivery.
 * A missed check is stale after two recorded intervals, minimum ten minutes. */
export function sourceHealthObservation(source: SourceObservation, now = Date.now()): string {
  if (source.healthStatus === 'failing') return 'failing';
  if (source.healthStatus === 'stale') return 'Stale source check';
  const checked = timestamp(source.lastHealthCheck);
  const succeeded = timestamp(source.lastSuccessfulFetch);
  const interval = source.scheduleMinutes;
  if (source.healthStatus !== 'healthy' || !interval || !Number.isFinite(interval) || interval <= 0
    || !Number.isFinite(checked) || !Number.isFinite(succeeded) || checked > now || succeeded > now) {
    return 'Source health unverified';
  }
  const staleAfter = Math.max(10, 2 * interval) * 60_000;
  return now - checked > staleAfter || now - succeeded > staleAfter
    ? 'Stale source check' : 'Recent successful source check';
}

export function observationDate(value: string | null): string {
  const parsed = timestamp(value);
  return Number.isFinite(parsed) ? new Date(parsed).toLocaleString() : 'Not recorded';
}

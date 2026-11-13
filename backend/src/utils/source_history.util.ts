export interface SourceSnapshot {
  sourceId: string;
  eventId: string;
  title: string;
  description: string;
  nativeLevel: string | null;
  channel?: string;
  instructions?: string[];
}
interface SourceUpdate { summary: string; detectedAt: string; }
type Details = Record<string, unknown> & {
  sourceSnapshot?: SourceSnapshot;
  sourceUpdate?: SourceUpdate;
  sourceUpdates?: SourceUpdate[];
  sourceSnapshots?: Record<string, SourceSnapshot>;
};
const normal = (text: string) => text.replace(/\s+/g, ' ').trim();
function metadata(text: string): Map<string, string> | null {
  const fields = new Map<string, string>();
  for (const line of text.split(/\r?\n/).filter(x => x.trim())) {
    const match = /^(Incident Type|Location|Local government area|Region|Reported|Source):\s*(.+)$/i.exec(line);
    if (!match) return null;
    const key = match[1]!.toLowerCase();
    if (fields.has(key)) return null;
    fields.set(key, normal(match[2]!));
  }
  return fields.has('incident type') && fields.has('location') ? fields : null;
}
/** Source snapshots precede AI processing. Never compare model summaries,
 * template versions or database timestamps to claim an agency change.
 * No baseline means no historical claim. Time here is explicitly detection. */
export function withSourceHistory(
  content: Record<string, unknown>, previous: unknown, snapshot: SourceSnapshot, detectedAt: Date,
): Details {
  const prior = previous && typeof previous === 'object' && !Array.isArray(previous)
    ? previous as Details : {};
  const sameIdentity = prior.sourceSnapshot?.sourceId === snapshot.sourceId && prior.sourceSnapshot?.eventId === snapshot.eventId;
  const snapshots = sameIdentity && prior.sourceSnapshots && typeof prior.sourceSnapshots === 'object'
    ? prior.sourceSnapshots : {};
  const channel = snapshot.channel ?? 'main';
  const candidate = snapshots[channel] ??
    ((prior.sourceSnapshot?.channel ?? 'main') === channel ? prior.sourceSnapshot : undefined);
  const baseline = candidate && typeof candidate.sourceId === 'string' && typeof candidate.eventId === 'string'
    && typeof candidate.title === 'string' && typeof candidate.description === 'string'
    && (candidate.nativeLevel === null || typeof candidate.nativeLevel === 'string') ? candidate : undefined;
  const sameEvent = baseline?.sourceId === snapshot.sourceId && baseline?.eventId === snapshot.eventId;
  const history = sameIdentity && Array.isArray(prior.sourceUpdates)
    ? prior.sourceUpdates.filter(x => x && typeof x.summary === 'string' && typeof x.detectedAt === 'string') : [];
  const changes: string[] = [];
  if (sameEvent && baseline) {
    if (normal(baseline.title) !== normal(snapshot.title)) changes.push(`Title: ${snapshot.title}.`);
    if (baseline.nativeLevel !== snapshot.nativeLevel) changes.push(`Agency level: ${snapshot.nativeLevel ?? 'no level supplied'}.`);
    if (JSON.stringify((baseline.instructions ?? []).map(normal)) !== JSON.stringify((snapshot.instructions ?? []).map(normal))) {
      changes.push('Agency instructions changed. Read the latest agency instructions below.');
    }
    if (normal(baseline.description) !== normal(snapshot.description)) {
      const oldFields = metadata(baseline.description), newFields = metadata(snapshot.description);
      if (oldFields && newFields) {
        for (const [key,label] of [['incident type','Incident type'],['location','Location'],['local government area','Local government area'],['region','Region']] as const) {
          const before = oldFields.get(key), after = newFields.get(key);
          if (before !== after) changes.push(`${label}: ${before ?? 'not supplied'} → ${after ?? 'not supplied'}.`);
        }
      } else changes.push('Source text changed. Read the latest source information below.');
    }
  }
  if (changes.length) history.unshift({summary: changes.join(' '), detectedAt: detectedAt.toISOString()});
  const latest = history.slice(0, 10);
  return {...content, sourceSnapshot: {...snapshot}, sourceSnapshots:{...snapshots,[channel]:{...snapshot}},
    ...(latest.length ? {sourceUpdate:latest[0]!,sourceUpdates:latest} : {})};
}

import { removeUnattributedNumbers, type AgencyExtractionResult } from './agency_extraction.util.js';
import { calmCase, canberraOffset } from './act_incident_content.util.js';

/**
 * VicEmergency incidents (CFA and FRV). TEST, 24 November 2026: Victorian
 * alerts fell back to raw feed text after the model was called and rejected.
 * Same cause as ACT and NSW Live Traffic: the feed body is labelled fields,
 * not sentences the model can quote:
 *
 *   Incident Name: BOWDEN ST
 *   Territory: CFA
 *   Agency: CFA
 *   Fire District: Wimmera
 *   Incident No: 303875
 *   Date/Time: 25/11/2026 12:00:00      (Victorian local time)
 *   Type: STRUCTURE
 *   Location: HORSHAM
 *   Status: Not Yet Under Control
 *   Size: SMALL
 *   Vehicles: 3
 *
 * This adapter writes two to four plain facts from those fields with no model
 * call. The feed gives no instructions, so What to do is reviewed ALRT advice
 * from the library, labelled as ALRT's.
 */

export interface VicIncidentInput {
  title: string;
  description: string;
  agency: string;
  templateVersion: number;
  alrtSuggestions: string[];
  profileGuidance: unknown[];
}

type VicIncidentContent = AgencyExtractionResult & { contentDetails: Record<string, unknown> };

const LABELS = ['Incident Name', 'Territory', 'Agency', 'Fire District', 'Incident No', 'Date/Time', 'Type', 'Location', 'Status', 'Size', 'Vehicles', 'Latitude', 'Longitude'];
const LABEL_RE = new RegExp(`(?:^|\\s|>)(${LABELS.map((l) => l.replace('/', '\\/')).join('|')}):\\s*`, 'g');
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/** Read the labelled fields, on separate lines or run together, with or without HTML. */
export function readVicFields(description: string): Map<string, string> | null {
  const text = description
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&');
  const hits = [...text.matchAll(LABEL_RE)];
  if (hits.length < 4) return null;
  const fields = new Map<string, string>();
  hits.forEach((m, i) => {
    const start = m.index! + m[0].length;
    const end = i + 1 < hits.length ? hits[i + 1]!.index! : text.length;
    fields.set(m[1]!.toLowerCase(), text.slice(start, end).replace(/\s+/g, ' ').trim());
  });
  if (!fields.get('type') || !fields.get('location')) return null;
  return fields;
}

/** True for items that are not a current hazard: a false alarm, or an incident the agency lists as safe. */
export function isVicNonIncident(description: string): boolean {
  const f = readVicFields(description);
  if (!f) return false;
  return /^false alarm$/i.test(f.get('type') ?? '') || /^safe$/i.test(f.get('status') ?? '');
}

const TYPE_WORDS: Record<string, string> = {
  structure: 'structure fire',
  'non structure': 'non-structure fire',
  grass: 'grass fire',
  scrub: 'scrub fire',
  'grass and scrub': 'grass and scrub fire',
  bush: 'bushfire',
  forest: 'bushfire',
  'car fire': 'car fire',
  other: 'incident',
  incident: 'incident',
};

/** "25/11/2026 12:00:00" in Victorian local time to an instant and a plain line. */
export function vicTime(value: string | undefined): { iso: string; words: string } | null {
  const m = /^(\d{1,2})\/(\d{1,2})\/(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?$/.exec((value ?? '').trim());
  if (!m) return null;
  const day = Number(m[1]), month = Number(m[2]) - 1, year = Number(m[3]), hour = Number(m[4]), minute = Number(m[5]);
  if (month < 0 || month > 11 || hour > 23 || minute > 59) return null;
  const local = new Date(Date.UTC(year, month, day, hour, minute, Number(m[6] ?? 0)));
  if (local.getUTCDate() !== day) return null;
  // Victoria and the ACT share daylight saving dates.
  const offset = canberraOffset(year, month, day);
  return {
    iso: new Date(local.getTime() - offset * 3_600_000).toISOString(),
    words: `${hour % 12 || 12}:${String(minute).padStart(2, '0')} ${hour < 12 ? 'am' : 'pm'} on ${day} ${MONTHS[month]} (Victorian time)`,
  };
}

export function buildVicIncidentContent(input: VicIncidentInput): VicIncidentContent | null {
  const fields = readVicFields(input.description);
  if (!fields) return null;
  const rawType = fields.get('type')!.trim();
  const kind = TYPE_WORDS[rawType.toLowerCase()] ?? calmCase(rawType).toLowerCase();
  const article = /^[aeiou]/.test(kind) ? 'an' : 'a';
  const place = calmCase(fields.get('location')!);
  const territory = fields.get('territory') || fields.get('agency');
  const who = territory && /^[A-Z]{2,4}$/.test(territory) ? `${input.agency} (${territory})` : input.agency;

  const facts = [`${who} lists ${article} ${kind} at ${place}.`];
  const status = fields.get('status');
  const size = fields.get('size');
  if (status) {
    facts.push(size && !/^(unknown|n\/a)$/i.test(size)
      ? `Its status is ${status.toLowerCase()} and its size is listed as ${size.toLowerCase()}.`
      : `Its status is ${status.toLowerCase()}.`);
  }
  const time = vicTime(fields.get('date/time'));
  if (time) facts.push(`It was reported at ${time.words}.`);

  const cleanedFacts = facts.map(removeUnattributedNumbers);
  const alrtSuggestions = input.alrtSuggestions.slice(0, 4);
  const title = calmCase(input.title);
  return {
    title,
    summary: cleanedFacts.map((f) => `• ${f}`).join('\n'),
    callsToAction: alrtSuggestions,
    confidence: 'high',
    contentDetails: {
      schemaVersion: 1,
      templateVersion: input.templateVersion,
      facts: cleanedFacts,
      affectedAreas: [place],
      nativeLevel: null,
      officialActions: [],
      alrtSuggestions,
      profileGuidance: input.profileGuidance,
      evidence: cleanedFacts.map(() => input.description),
      issuingAgency: input.agency,
      originalSourceText: input.description,
      extractionMethod: 'vic-incident-fields',
      sourceReportedAt: time?.iso ?? null,
      displayLocation: place,
      sourceLimitations: 'An incident report alone does not establish its current impact or a warning level.',
      sourceAdviceStatus: 'not-in-incident-feed',
    },
  } as VicIncidentContent;
}

import { removeUnattributedNumbers, type AgencyExtractionResult } from './agency_extraction.util.js';

/**
 * ACT Emergency Services Agency incidents (owner, 17 November 2026: the daily
 * assurance check showed hundreds of ACT alerts a day shown as raw agency
 * text). The ACT feed is fully structured: every item is "Field: value"
 * lines (Incident, Location, Status, Suburb, Type, Agency, Incident Number,
 * Updated, Time of Call) with no sentences and no instructions. Those lines
 * failed the template-first plain-card test, so every item went to the model,
 * and the model could not quote complete source sentences that do not exist.
 *
 * This adapter renders the fields as two or three plain facts in the agency's
 * own words, with no model call (the same pattern as the DFES incident
 * adapter). The feed gives no instructions, so What to do is ALRT safety
 * advice from the reviewed library, labelled as ALRT's.
 *
 * Returns null when the body is not in the ACT field format, so the caller
 * keeps its normal path.
 */

export interface ActIncidentInput {
  title: string;
  description: string;
  agency: string;
  templateVersion: number;
  /** Reviewed library lines for this alert's category (Alert Templates). */
  alrtSuggestions: string[];
  profileGuidance: unknown[];
}

type ActIncidentContent = AgencyExtractionResult & { contentDetails: Record<string, unknown> };

const FIELD = /^([A-Za-z][A-Za-z ]{1,30}):\s*(.*)$/;
const KNOWN = new Set(['incident', 'location', 'status', 'suburb', 'type', 'agency', 'incident number', 'updated', 'time of call']);
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/** Bring shouted capitals back to normal case, keeping O'Connor and Mc names readable. */
export const calmCase = (text: string): string =>
  text
    .toLowerCase()
    .replace(/(^|[\s(/-])([a-z])/g, (_, a: string, b: string) => a + b.toUpperCase())
    .replace(/\b(O'|Mc)([a-z])/g, (_, a: string, b: string) => a + b.toUpperCase());

/** Canberra observes daylight saving from the first Sunday in October to the
 * first Sunday in April. Returns the UTC offset in hours for a local date. */
export const canberraOffset = (year: number, month: number, day: number): number => {
  const firstSunday = (m: number) => {
    const d = new Date(Date.UTC(year, m, 1)).getUTCDay();
    return 1 + ((7 - d) % 7);
  };
  if (month > 3 && month < 9) return 10;
  if (month === 3) return day < firstSunday(3) ? 11 : 10;
  if (month === 9) return day >= firstSunday(9) ? 11 : 10;
  return 11;
};

/** "17 Nov 2026 16:37:29" (Canberra local time) to an instant and a plain line. */
export function actTime(value: string | undefined): { iso: string; words: string } | null {
  const m = /^(\d{1,2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$/.exec((value ?? '').trim());
  if (!m) return null;
  const month = MONTHS.findIndex((name) => name.toLowerCase().startsWith(m[2]!.toLowerCase()));
  const day = Number(m[1]), year = Number(m[3]), hour = Number(m[4]), minute = Number(m[5]);
  if (month < 0 || hour > 23 || minute > 59) return null;
  const local = new Date(Date.UTC(year, month, day, hour, minute, Number(m[6] ?? 0)));
  if (local.getUTCDate() !== day) return null;
  const offset = canberraOffset(year, month, day);
  return {
    iso: new Date(local.getTime() - offset * 3_600_000).toISOString(),
    words: `${hour % 12 || 12}:${String(minute).padStart(2, '0')} ${hour < 12 ? 'am' : 'pm'} on ${day} ${MONTHS[month]} (Canberra time)`,
  };
}

/** Read the "Field: value" lines. Null if any line is not a known field. */
export function readActFields(description: string): Map<string, string> | null {
  const fields = new Map<string, string>();
  const lines = description.replace(/\r\n?/g, '\n').split('\n').map((l) => l.trim()).filter(Boolean);
  if (!lines.length) return null;
  for (const line of lines) {
    const m = FIELD.exec(line);
    if (!m) return null;
    const key = m[1]!.trim().toLowerCase();
    if (!KNOWN.has(key)) return null;
    fields.set(key, m[2]!.trim());
  }
  return fields;
}

/** The incident's own time (Time of Call), for the alert's posted time. */
export const actIncidentTime = (description: string): Date | null => {
  const fields = readActFields(description);
  const time = actTime(fields?.get('time of call'));
  return time ? new Date(time.iso) : null;
};

export function buildActIncidentContent(input: ActIncidentInput): ActIncidentContent | null {
  const fields = readActFields(input.description);
  if (!fields) return null;
  const type = fields.get('type') || fields.get('incident')?.split(/\s+-\s+/)[0];
  const suburb = fields.get('suburb');
  if (!type || !suburb) return null;

  const kind = type.toLowerCase();
  const article = /^[aeiou]/.test(kind) ? 'an' : 'a';
  // Location is "NAAS ROAD, THARWA, 2620" or just the suburb: drop the
  // postcode, and name the street only when the agency gave one.
  const location = calmCase((fields.get('location') ?? '').replace(/,\s*\d{4}\s*$/, '').trim());
  const place = location && location.toLowerCase() !== suburb.toLowerCase() ? location : calmCase(suburb);

  const facts = [`${input.agency} lists ${article} ${kind} in ${place}.`];
  const status = fields.get('status');
  if (status && !/^not applicable$/i.test(status)) facts.push(`Its status is ${status.toLowerCase()}.`);
  const call = actTime(fields.get('time of call'));
  if (call) facts.push(`The call was received at ${call.words}.`);
  const updated = actTime(fields.get('updated'));
  if (updated && call && Date.parse(updated.iso) - Date.parse(call.iso) > 3_600_000 && facts.length < 4) {
    facts.push(`The agency last updated it at ${updated.words}.`);
  }

  const cleanedFacts = facts.map(removeUnattributedNumbers);
  // The feed carries no agency instructions. What to do is ALRT safety advice
  // from the reviewed library for this category (two to four points).
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
      affectedAreas: [calmCase(suburb)],
      nativeLevel: null,
      officialActions: [],
      alrtSuggestions,
      profileGuidance: input.profileGuidance,
      evidence: cleanedFacts.map(() => input.description),
      issuingAgency: input.agency,
      originalSourceText: input.description,
      extractionMethod: 'act-incident-fields',
      sourceReportedAt: call?.iso ?? null,
      displayLocation: place,
      sourceLimitations: 'An incident report alone does not establish its current impact or a warning level.',
      sourceAdviceStatus: 'not-in-incident-feed',
    },
  } as ActIncidentContent;
}

import { removeUnattributedNumbers, type AgencyExtractionResult } from './agency_extraction.util.js';
import { calmCase } from './act_incident_content.util.js';

/**
 * NSW Live Traffic hazards (Transport for NSW). TEST, 24 November 2026: about
 * 8,600 model calls a day, nearly all rejected ("Fact text must retain a
 * complete source sentence", "Evidence must be an exact quote"), so the alerts
 * showed raw feed text. Same cause as ACT: the stored body is "Field: value"
 * lines built by extractNSWTrafficDescription, not sentences the model can
 * quote.
 *
 * The body looks like:
 *   ADVERSE WEATHER                      (displayName, first line)
 *   Incident Kind: Unplanned
 *   Main Category: Adverse weather
 *   Sub Category: Water over road
 *   Location: Pacific Highway, Raymond Terrace
 *   Advice: Reduce speed; Exercise caution
 *   Other Advice: Water is over the road. Drive to conditions.
 *
 * This adapter writes the card from those fields with no model call:
 * - facts: what Transport for NSW lists and where, then up to two of the
 *   agency's own sentences from Other Advice;
 * - What to do: the agency's short advice (Advice) attributed to the agency,
 *   then reviewed ALRT lines from the library to make two to four points.
 *
 * Returns null when the body is not in this format, so the caller keeps its
 * normal path.
 */

export interface NswTrafficInput {
  title: string;
  description: string;
  agency: string;
  templateVersion: number;
  alrtSuggestions: string[];
  profileGuidance: unknown[];
}

type NswTrafficContent = AgencyExtractionResult & { contentDetails: Record<string, unknown> };

const KNOWN = new Map<string, string>([
  ['incident kind', 'kind'],
  ['main category', 'main'],
  ['sub category', 'sub'],
  ['location', 'location'],
  ['advice', 'advice'],
  ['other advice', 'other'],
]);
const FIELD = /^([A-Za-z][A-Za-z ]{1,20}):\s*(.*)$/;

export function readNswTrafficFields(description: string): Map<string, string> | null {
  const lines = description.replace(/\r\n?/g, '\n').split('\n').map((l) => l.trim()).filter(Boolean);
  if (lines.length < 2) return null;
  const fields = new Map<string, string>();
  for (const [i, line] of lines.entries()) {
    const m = FIELD.exec(line);
    const key = m ? KNOWN.get(m[1]!.trim().toLowerCase()) : undefined;
    if (key) {
      fields.set(key, m![2]!.trim());
    } else if (i === 0) {
      fields.set('name', line);
    } else if (fields.has('other')) {
      // Other Advice can run over several lines.
      fields.set('other', `${fields.get('other')} ${line}`.trim());
    } else {
      return null;
    }
  }
  if (!fields.has('main') && !fields.has('sub')) return null;
  return fields;
}

const usable = (x?: string) => Boolean(x && x.trim() && !/^(null|undefined|n\/a)$/i.test(x.trim()));

/** "Water over road" or "Adverse weather", lower-cased for use in a sentence. */
const phrase = (text: string) => {
  const t = text.trim();
  return /^[A-Z0-9 .'/&-]+$/.test(t) ? calmCase(t).toLowerCase() : t.charAt(0).toLowerCase() + t.slice(1);
};

/** Complete sentences of a sensible length from the agency's Other Advice. */
const sentences = (text: string) =>
  text
    .replace(/\s+/g, ' ')
    .split(/(?<=[.!?])\s+(?=[A-Z0-9"'(])/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 15 && s.length <= 240 && /[.!?]$/.test(s));

const sentenceCase = (s: string) => {
  const t = s.trim().replace(/[.;]+$/, '');
  if (!t) return '';
  const plain = /^[A-Z0-9 .,'/&-]+$/.test(t) ? t.toLowerCase() : t;
  return `${plain.charAt(0).toUpperCase()}${plain.slice(1)}.`;
};

export function buildNswTrafficContent(input: NswTrafficInput): NswTrafficContent | null {
  const fields = readNswTrafficFields(input.description);
  if (!fields) return null;
  const main = usable(fields.get('main')) ? fields.get('main')! : '';
  const sub = usable(fields.get('sub')) ? fields.get('sub')! : '';
  const what = sub && main && sub.toLowerCase() !== main.toLowerCase()
    ? `${phrase(sub)} (${phrase(main)})`
    : phrase(sub || main);
  if (!what) return null;
  const location = usable(fields.get('location')) ? calmCase(fields.get('location')!) : '';
  const planned = /^\s*planned\b/i.test(fields.get('kind') ?? '');

  const facts = [`${input.agency} lists ${planned ? 'planned ' : ''}${what}${location ? ` at ${location}` : ''}.`];
  const own = usable(fields.get('other')) ? sentences(fields.get('other')!) : [];
  for (const s of own) {
    if (facts.length >= 3) break;
    if (!facts.some((f) => f.toLowerCase() === s.toLowerCase())) facts.push(s);
  }
  const cleanedFacts = facts.map(removeUnattributedNumbers);

  // The agency's own short advice ("Reduce speed; Exercise caution").
  const officialActions = (fields.get('advice') ?? '')
    .split(/\s*;\s*/)
    .filter(usable)
    .map(sentenceCase)
    .filter(Boolean)
    .slice(0, 3);
  const fromAgency = officialActions.map((a) => a.toLowerCase().replace(/[.!]+$/, ''));
  const room = Math.max(0, 4 - officialActions.length);
  // Reviewed ALRT lines fill What to do up to four points, skipping any that
  // repeat what the agency already said.
  const alrtSuggestions = input.alrtSuggestions
    .filter((x) => !fromAgency.some((a) => x.toLowerCase().includes(a)))
    .slice(0, room);

  // Titles arrive as "ADVERSE WEATHER Water over road": bring shouting back to
  // normal case, keep a title that is already written normally.
  const raw = input.title.trim();
  const letters = raw.replace(/[^A-Za-z]/g, '');
  const shouty = letters.length >= 6 && letters.replace(/[^A-Z]/g, '').length / letters.length > 0.4;
  const title = shouty ? calmCase(raw) : raw;
  return {
    title,
    summary: cleanedFacts.map((f) => `• ${f}`).join('\n'),
    callsToAction: [...officialActions.map((a) => `${input.agency} advises: ${a}`), ...alrtSuggestions],
    confidence: 'high',
    contentDetails: {
      schemaVersion: 1,
      templateVersion: input.templateVersion,
      facts: cleanedFacts,
      affectedAreas: location ? [location] : [],
      nativeLevel: null,
      officialActions,
      alrtSuggestions,
      profileGuidance: input.profileGuidance,
      evidence: cleanedFacts.map(() => input.description),
      issuingAgency: input.agency,
      originalSourceText: input.description,
      extractionMethod: 'nsw-traffic-fields',
      displayLocation: location || null,
      sourceLimitations: 'A traffic listing alone does not establish its current impact or a warning level.',
      sourceAdviceStatus: officialActions.length ? 'in-feed' : 'not-in-feed',
    },
  } as NswTrafficContent;
}

/** An epoch-milliseconds time (NSW Live Traffic created/lastUpdated) as a Date. */
export function epochMsDate(value: unknown): Date | null {
  const n = typeof value === 'string' && /^\d{12,14}$/.test(value.trim()) ? Number(value) : value;
  if (typeof n !== 'number' || !Number.isFinite(n) || n < 1e12 || n > 1e14) return null;
  const d = new Date(n);
  return Number.isNaN(d.getTime()) ? null : d;
}

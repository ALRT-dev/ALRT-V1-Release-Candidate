import { removeUnattributedNumbers, type AgencyExtractionResult } from './agency_extraction.util.js';
import { incidentPlanningProfiles } from './dfes_incident_profiles.util.js';

export interface DfesIncidentInput {
  title: string;
  description: string;
  agency: string;
  templateVersion: number;
  sourceActions?: string[];
  allowAgencyNumbers?: boolean;
}

/** ALRT safety advice for DFES incident reports (owner, 10 November 2026:
 * practical points, not "may help" wording). The feed carries only the
 * incident type, place and time, so the first line points to the live
 * incident and warnings; the rest are practical safety points from the ALRT
 * hazard safety library's sources. No leave, evacuate or shelter wording:
 * only the agency gives those. Exact kinds only: a smoke report or a crash
 * never proves a fire or a closure. */
const EMERGENCY_WA = 'https://www.emergency.wa.gov.au/';
const REVIEWED = '2026-11-10';
const bushfirePlanning = [
  { text: 'Check Emergency WA for the latest on this fire and any warnings for your area.', url: EMERGENCY_WA, reviewedAt: REVIEWED },
  { text: 'Fire conditions can change quickly. Review your bushfire plan and talk it through with your household.', url: 'https://dfes.wa.gov.au/hazard-information/bushfire/prepare', reviewedAt: REVIEWED },
  { text: 'If smoke reaches you, keep windows and doors closed.', url: 'https://www.health.nsw.gov.au/environment/bushfire/Pages/bushfire-illness.aspx', reviewedAt: REVIEWED },
];
const firePlanning = [
  { text: 'Check Emergency WA for the latest on this incident and any warnings for your area.', url: EMERGENCY_WA, reviewedAt: REVIEWED },
  { text: 'Keep clear of the area so emergency crews can work.', url: EMERGENCY_WA, reviewedAt: REVIEWED },
  { text: 'If smoke reaches you, keep windows and doors closed.', url: 'https://www.health.nsw.gov.au/environment/bushfire/Pages/bushfire-illness.aspx', reviewedAt: REVIEWED },
];
const smokePlanning = [
  { text: 'Check Emergency WA for any warning linked to this smoke.', url: EMERGENCY_WA, reviewedAt: REVIEWED },
  { text: 'If smoke reaches your home, close doors and windows and turn off air conditioning that draws in outside air.', url: 'https://www.health.nsw.gov.au/environment/bushfire/Pages/bushfire-illness.aspx', reviewedAt: REVIEWED },
  { text: 'If you have asthma or a heart or lung condition, keep your medicines and action plan close by.', url: 'https://www.health.nsw.gov.au/environment/bushfire/Pages/bushfire-illness.aspx', reviewedAt: REVIEWED },
];
// Any other DFES incident kind: safe for every incident report.
const incidentPlanning = [
  { text: 'Check Emergency WA for the latest on this incident and any warnings for your area.', url: EMERGENCY_WA, reviewedAt: REVIEWED },
  { text: 'Keep clear of the area so emergency crews can work.', url: EMERGENCY_WA, reviewedAt: REVIEWED },
];
const crashPlanning = [
  { text: 'Expect delays near the crash and allow extra travel time.', url: 'https://www.mainroads.wa.gov.au/travelmap/', reviewedAt: REVIEWED },
  { text: 'Check Main Roads Travel Map for closures and detours before you go.', url: 'https://www.mainroads.wa.gov.au/travelmap/', reviewedAt: REVIEWED },
  { text: 'Follow directions from police and traffic controllers at the scene.', url: 'https://www.mainroads.wa.gov.au/travelmap/', reviewedAt: REVIEWED },
];

type IncidentContent = AgencyExtractionResult & { contentDetails: {
  originalSourceText: string;
  issuingAgency: string;
  originalSourceActions: string[];
  guidanceReferences: { text: string; url: string; reviewedAt: string }[];
  extractionMethod: 'dfes-incident-fields';
  sourceReportedAt: string | null;
  displayLocation: string;
  sourceLimitations?: string;
  sourceAdviceStatus: 'provided' | 'not-in-incident-feed';
  profileGuidancePolicy: 'publishedIncidentPlanning';
} };

const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
/** Require the source's explicit WA offset. Date round-trip rejects impossible
 * calendar values rather than silently rolling them into the following month. */
function reportedTime(value: string): { iso: string; fact: string } | null {
  const match = /^(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun), (\d{1,2}) ([A-Z][a-z]{2}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) \+0800$/.exec(value);
  if (!match) return null;
  const month = months.findIndex(name => name.startsWith(match[2]!));
  const day = Number(match[1]), year = Number(match[3]), hour = Number(match[4]), minute = Number(match[5]), second = Number(match[6]);
  if (month < 0 || hour > 23 || minute > 59 || second > 59) return null;
  const local = new Date(Date.UTC(year, month, day, hour, minute, second));
  if (local.getUTCFullYear() !== year || local.getUTCMonth() !== month || local.getUTCDate() !== day) return null;
  return { iso: new Date(local.getTime() - 8 * 60 * 60 * 1000).toISOString(),
    fact: `Reported on ${day} ${months[month]} at ${hour % 12 || 12}:${String(minute).padStart(2, '0')} ${hour < 12 ? 'am' : 'pm'} AWST.` };
}

/** Caller must restrict this adapter to source id waDfes. Only recognises the
 * metadata-only incident format; every other source body falls through. */
export function buildDfesIncidentContent(input: DfesIncidentInput): IncidentContent | null {
  if (/\b(?:advice|watch\s+and\s+act|emergency\s+warning|warning\s+level|all\s+clear)\b/i.test(input.title + '\n' + input.description)) return null;
  const fields = new Map<string, { value: string; evidence: string }>();
  const allowed = new Set(['incident type', 'location', 'local government area', 'region', 'reported', 'source']);
  for (const line of input.description.replace(/\r\n/g, '\n').split('\n').filter(line => line.trim())) {
    const match = /^([^:]+):\s*(.+)$/.exec(line);
    if (!match) return null;
    const key = match[1]!.trim().toLowerCase();
    if (!allowed.has(key) || fields.has(key)) return null;
    const value = match[2]!.trim();
    if (!value || value.length > 240) return null;
    fields.set(key, { value, evidence: line });
  }
  const kind = fields.get('incident type'), place = fields.get('location');
  if (!kind || !place || !/Department of Fire and Emergency Services WA incident feed/i.test(fields.get('source')?.value ?? '')) return null;
  const clean = (text: string) => input.allowAgencyNumbers ? text : removeUnattributedNumbers(text);
  const isSmoke = /^(?:report of smoke|smoke)$/i.test(kind.value);
  const isCrash = /^(?:road crash|crash)$/i.test(kind.value);
  const readableKind = isSmoke ? 'smoke' : /^other fire$/i.test(kind.value) ? 'fire' : kind.value.toLowerCase();
  const article = /^[aeiou]/i.test(readableKind) ? 'An' : 'A';
  const lga = fields.get('local government area'), reported = fields.get('reported');
  const readableLga = lga?.value.replace(/\bOf\b/g, 'of');
  const facts = [`${isSmoke ? 'Smoke' : `${article} ${readableKind}`} was reported in ${place.value}${readableLga ? ` (${readableLga})` : ''} by ${input.agency}.`];
  const evidence = [[kind.evidence, place.evidence, lga?.evidence].filter(Boolean).join('\n')];
  const timestamp = reported ? reportedTime(reported.value) : null;
  if (timestamp && reported) { facts.push(timestamp.fact); evidence.push(reported.evidence); }
  const originalSourceActions = [...(input.sourceActions ?? [])];
  const officialActions = [...new Set(originalSourceActions.filter(text => text.trim()).map(clean))];
  const reviewed = kind.value.toLowerCase() === 'bushfire' ? bushfirePlanning
    : /^(?:fire|other fire|structure fire|structural fire|vehicle fire|car fire|building fire)$/i.test(kind.value) ? firePlanning
    : isSmoke ? smokePlanning : isCrash ? crashPlanning : incidentPlanning;
  const sourceLimitations = officialActions.length ? undefined : isSmoke
    ? 'A smoke report alone does not establish its cause or measured air quality at your location.'
    : isCrash ? 'A crash report alone does not confirm current road access or traffic delays.'
    : 'An incident report alone does not establish its current impact or a warning level.';
  // ALRT advice is a fallback only when no agency instructions were supplied.
  const guidanceReferences = (officialActions.length ? [] : reviewed.slice(0, 4)).map(item => ({ ...item }));
  const alrtSuggestions = guidanceReferences.map(item => item.text);
  const cleanedFacts = facts.map(clean);
  return {
    title: clean(input.title), summary: cleanedFacts.map(text => `• ${text}`).join('\n'),
    callsToAction: [...officialActions.map(text => `${input.agency} advises: ${text}`), ...alrtSuggestions], confidence: 'high',
    contentDetails: { schemaVersion: 1, templateVersion: input.templateVersion, facts: cleanedFacts,
      affectedAreas: [place.value], nativeLevel: null, officialActions, alrtSuggestions,
      profileGuidance: kind.value.toLowerCase() === 'bushfire' ? incidentPlanningProfiles('bushfire') : isSmoke ? incidentPlanningProfiles('smoke') : [],
      evidence, issuingAgency: input.agency, originalSourceText: input.description, originalSourceActions, guidanceReferences,
      extractionMethod: 'dfes-incident-fields', sourceReportedAt: timestamp?.iso ?? null, displayLocation: place.value,
      ...(sourceLimitations ? { sourceLimitations } : {}), sourceAdviceStatus: officialActions.length ? 'provided' : 'not-in-incident-feed',
      profileGuidancePolicy: 'publishedIncidentPlanning' },
  };
}

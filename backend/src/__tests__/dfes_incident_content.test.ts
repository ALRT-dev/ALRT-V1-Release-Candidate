import { describe, expect, it } from 'vitest';
import { buildDfesIncidentContent } from '../utils/dfes_incident_content.util.js';

const description = 'Incident Type: Bushfire\nLocation: Scarborough\nLocal government area: City Of Stirling\nRegion: Metro North Coastal\nReported: Fri, 06 Nov 2026 19:27:33 +0800\nSource: Department of Fire and Emergency Services WA incident feed';
const input = { title: 'Bushfire - SCARBOROUGH', description, agency: 'DFES', templateVersion: 2 };
describe('DFES incident content', () => {
  it('attributes the factual sentence to the supplied agency, preserving an official street', () => {
    const value=buildDfesIncidentContent({...input,agency:'DFES WA',description:description.replace('Location: Scarborough','Location: Example Road, Scarborough')});
    expect(value?.contentDetails.facts[0]).toBe('A bushfire was reported in Example Road, Scarborough (City of Stirling) by DFES WA.');
  });
  it.each(['Report of Smoke', 'Road Crash'])('supplies reviewed fallback for %s without inventing incident impacts', kind => {
    const source = description.replace('Bushfire', kind);
    const value = buildDfesIncidentContent({...input, description:source});
    expect(value?.contentDetails.alrtSuggestions.length).toBeGreaterThanOrEqual(2);
    expect(value?.contentDetails.guidanceReferences.every(x=>x.reviewedAt==='2026-11-09')).toBe(true);
    expect(value?.contentDetails).toHaveProperty('sourceLimitations');
    expect(value?.contentDetails.officialActions).toEqual([]);
    const official = buildDfesIncidentContent({...input, description:source,sourceActions:['If affected, follow the marked detour.']});
    expect(official?.contentDetails.alrtSuggestions).toEqual([]);
    expect(official?.contentDetails.officialActions).toEqual(['If affected, follow the marked detour.']);
  });
  it('describes smoke naturally and states the limits of the metadata feed', () => {
    const value=buildDfesIncidentContent({...input,description:description.replace('Bushfire','Report of Smoke')});
    expect(value?.contentDetails.facts[0]).toBe('Smoke was reported in Scarborough (City of Stirling) by DFES.');
    expect(value?.contentDetails).toHaveProperty('sourceLimitations',expect.stringMatching(/cause.*air quality/i));
    expect(value?.contentDetails.profileGuidancePolicy).not.toBe('bundledFallback');
    expect(value?.contentDetails.profileGuidance).toHaveLength(9);
  });
  it('never denies a road name or impact supplied in the entry', () => {
    const source=description.replace('Bushfire','Road Crash').replace('Location: Scarborough','Location: Mitchell Freeway');
    const value=buildDfesIncidentContent({...input,description:source});
    expect(value?.contentDetails.facts.join(' ')).toContain('Mitchell Freeway');
    expect(value?.contentDetails.sourceLimitations).not.toContain('does not give a road name');
    const advised=buildDfesIncidentContent({...input,description:source,sourceActions:['Mitchell Freeway is closed. Use the marked detour.']});
    expect(advised?.contentDetails.sourceLimitations).toBeUndefined();
    expect(advised?.contentDetails.officialActions).toEqual(['Mitchell Freeway is closed. Use the marked detour.']);
  });
  it('renders readable sourced facts and separately attributed reviewed planning suggestions', () => {
    const value = buildDfesIncidentContent(input);
    expect(value?.contentDetails.facts).toEqual(['A bushfire was reported in Scarborough (City of Stirling) by DFES.', 'Reported on 6 November at 7:27 pm AWST.']);
    expect(value?.contentDetails.sourceReportedAt).toBe('2026-11-06T11:27:33.000Z');
    expect(value?.contentDetails.displayLocation).toBe('Scarborough');
    expect(value?.contentDetails.extractionMethod).toBe('dfes-incident-fields');
    expect(value?.contentDetails.profileGuidancePolicy).not.toBe('bundledFallback');
    expect(value?.contentDetails.profileGuidance).toHaveLength(9);
    expect(value?.contentDetails.officialActions).toEqual([]);
    expect(value?.contentDetails.alrtSuggestions).toHaveLength(2);
    expect(value?.contentDetails.originalSourceText).toBe(description);
    expect(value?.contentDetails.guidanceReferences).toHaveLength(2);
  });
  it('does not treat generic fire as bushfire', () => {
    const value = buildDfesIncidentContent({ ...input, description: description.replace('Bushfire', 'Fire') });
    expect(value?.contentDetails.alrtSuggestions).toHaveLength(2);
    expect(value?.contentDetails.alrtSuggestions.join(' ')).not.toMatch(/bushfire|evacuat|leave/i);
    expect(value?.summary).not.toMatch(/bushfire/i);
    expect(value?.contentDetails.profileGuidancePolicy).toBe('publishedIncidentPlanning');
    expect(value?.contentDetails.profileGuidance).toEqual([]);
  });
  it('preserves complete separate source instructions and phone policy', () => {
    const value = buildDfesIncidentContent({ ...input, sourceActions: ['If you see smoke, call 000 and give your location.'] });
    expect(value?.contentDetails.officialActions).toEqual(['If you see smoke, call your local emergency number and give your location.']);
    expect(value?.contentDetails.originalSourceActions).toEqual(['If you see smoke, call 000 and give your location.']);
  });
  it('supports other fire without bushfire advice and leaves unknown hazards without reviewed advice', () => {
    const other = buildDfesIncidentContent({ ...input, description: description.replace('Bushfire', 'Other Fire') });
    expect(other?.summary).toContain('A fire was reported');
    expect(other?.summary).not.toMatch(/other fire/i);
    expect(other?.contentDetails.alrtSuggestions).toHaveLength(2);
    const unknown = buildDfesIncidentContent({ ...input, description: description.replace('Bushfire', 'Unknown Incident') });
    expect(unknown?.contentDetails.alrtSuggestions).toEqual([]);
  });
  it.each(['Fri, 31 Feb 2026 19:27:33 +0800', 'not a date', 'Fri, 06 Nov 2026 19:27:33 +1100'])('omits invalid or unconfirmed WA timestamp %s', timestamp => {
    const source = description.replace('Fri, 06 Nov 2026 19:27:33 +0800', timestamp);
    const value = buildDfesIncidentContent({ ...input, description: source });
    expect(value?.contentDetails.facts).toEqual(['A bushfire was reported in Scarborough (City of Stirling) by DFES.']);
    expect(value?.contentDetails.sourceReportedAt).toBeNull();
    expect(value?.contentDetails.originalSourceText).toBe(source);
  });
  it.each(['Bushfire Advice - Scarborough', 'Bushfire Watch and Act', 'Emergency Warning'])('leaves native warning %s to warning parser', title => {
    expect(buildDfesIncidentContent({ ...input, title })).toBeNull();
  });
  it.each([description + '\nWhat to do: Leave now.', description.replace('Location: Scarborough\n', ''), description.replace('Incident Type: Bushfire', 'Incident Type: Bushfire\nIncident Type: Fire'), 'An ordinary unstructured report'])('declines ambiguous or non-metadata descriptions', text => {
    expect(buildDfesIncidentContent({ ...input, description: text })).toBeNull();
  });
});

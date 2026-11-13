import { describe, expect, it } from 'vitest';
import { withPublicCoords } from '../utils/hazard.util.js';

const description = 'Incident Type: Other Fire\nLocation: Bassendean\nLocal government area: Town Of Bassendean\nRegion: Metro\nReported: Fri, 06 Nov 2026 19:27:33 +0800\nSource: Department of Fire and Emergency Services WA incident feed';
const record = { sourceId: 'waDfes', title: 'Other Fire - BASSENDEAN', description,
  aiSummary: 'Location: Bassendean', callsToAction: [], latitude: -31.91234, longitude: 115.94567,
  reportedById: null as string | null, status: 'expired', expiresAt: '2026-11-06',
  contentDetails: { templateVersion: 7, presentation: { band: 'low', iconCategoryId: 'fire' }, officialActions: ['Stay away from the affected building.'] } };
describe('DFES incident public read repair', () => {
  it('preserves street names, street numbers and precise coordinates from official sources', () => {
    const source={...record,locationName:'25 Example Road, Bassendean',description:description.replace('Location: Bassendean','Location: 25 Example Road, Bassendean'),
      contentDetails:{...record.contentDetails,facts:[] as string[],officialActions:['Keep Example Road clear between First Street and Second Street.']}};
    const actual=withPublicCoords(source, 'another-viewer');
    expect(actual.locationName).toBe('25 Example Road, Bassendean');
    expect(actual.contentDetails.facts.join(' ')).toContain('25 Example Road, Bassendean');
    expect(actual.contentDetails.officialActions).toEqual(source.contentDetails.officialActions);
    expect(actual.latitude).toBe(source.latitude);
    expect(actual.longitude).toBe(source.longitude);
  });
  it('recovers native warning advice into structured fields without losing conditions or history', () => {
    const source = {...record, title:'Bushfire Advice', description:'Warning Type: Bushfire Advice\n• Smoke is present.\nWHAT TO DO\nIf driving\n• Turn on headlights.',
      contentDetails:{...record.contentDetails,sourceUpdate:{summary:'Agency changed advice',detectedAt:'2026-11-09T00:00:00Z'}}};
    const value=withPublicCoords(source);
    expect(value.contentDetails.officialActions).toEqual(['If driving Turn on headlights.']);
    expect(value.contentDetails.sourceUpdate).toEqual(source.contentDetails.sourceUpdate);
    expect(value.status).toBe(source.status);
  });
  it('retains original source instructions even when displayed wording removes a number', () => {
    const source = {...record,contentDetails:{...record.contentDetails,
      originalSourceActions:['Call 000 if there is an immediate threat.'],
      officialActions:['Call your local emergency number if there is an immediate threat.']}};
    const actual=withPublicCoords(source);
    expect(actual.contentDetails.originalSourceActions).toEqual(source.contentDetails.originalSourceActions);
    expect(actual.contentDetails.officialActions.join(' ')).not.toContain('000');
  });
  it('repairs stored metadata through the shared read boundary without mutating data or lifecycle', () => {
    const actual = withPublicCoords(record);
    expect(actual.aiSummary).toContain('A fire was reported in Bassendean (Town of Bassendean) by DFES.');
    expect(actual.callsToAction).toContain('DFES advises: Stay away from the affected building.');
    expect(actual.contentDetails.presentation).toEqual(record.contentDetails.presentation);
    expect(actual.contentDetails.templateVersion).toBe(7);
    expect(actual.status).toBe('expired');
    expect(actual.expiresAt).toBe(record.expiresAt);
    expect(actual.latitude).toBe(record.latitude);
    expect(record.aiSummary).toBe('Location: Bassendean');
  });
  it('still rounds coordinates for community reports', () => {
    const actual = withPublicCoords({ ...record, reportedById: 'someone' });
    expect(actual.latitude).toBe(-31.91);
    expect(actual.longitude).toBe(115.95);
  });
  it('leaves other sources and native warnings unchanged', () => {
    const other = { ...record, sourceId: 'other' };
    expect(withPublicCoords(other)).toBe(other);
    const warning = { ...record, title: 'Bushfire Advice', description: 'Warning Type: Bushfire Advice\nWHAT TO DO:\nStay informed.' };
    // Unbulleted advice is ambiguous to this adapter and stays untouched.
    expect(withPublicCoords(warning)).toBe(warning);
  });
});

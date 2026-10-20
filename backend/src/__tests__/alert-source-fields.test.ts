import {describe, it, expect, vi} from 'vitest';
vi.mock('../services/google_map.service.js', () => ({convertAddressToLatLng: vi.fn(), convertLatLngToAddress: vi.fn()}));
vi.mock('../services/ingestion.service.js', () => ({ExternalSourceId: {smartraveller:'smartraveller', nswSes:'nswSes', rfs:'rfs', nswTransport:'nswTransport', earthquakeUsgs:'earthquakeUsgs'}, getLocationsFromText: vi.fn()}));
vi.mock('../services/hazard_category.service.js', () => ({MainCategoryId: {other:'other', weatherAndEnvironment:'weatherAndEnvironment'}}));
import {parseSmartravellerToHazards, convertHazardDataWithRelationsToCreateInput, parseUSGSEarthquakeToHazards} from '../utils/ingestion.util.js';

describe('source fields for published templates', () => {
  it('retains all travel notes, regional exceptions, original level and destination', () => {
    const [value] = parseSmartravellerToHazards({category: {id:'travel'} as any, data: [{title:'Saudi Arabia', field_overall_advice_level:'Exercise a high degree of caution', field_last_update:'Example update.', field_last_update_notes:'First essential condition.\nSecond instruction.', field_advice_levels:'Do not travel to the named border area.'}]});
    expect(value?.jurisdictionCountry).toBe('SA');
    expect(value?.nativeWarningLevel).toBe('Exercise a high degree of caution');
    expect(value?.description).toContain('First essential condition.');
    expect(value?.description).toContain('Do not travel to the named border area.');
    expect(value?.sourceInstructionBlocks).toHaveLength(2);
    expect(convertHazardDataWithRelationsToCreateInput(value!)).not.toHaveProperty('sourceInstructionBlocks');
  });
  it('does not turn a USGS tsunami information flag into a warning', () => {
    const [value] = parseUSGSEarthquakeToHazards({earthquakeCategory:{id:'earthquake'} as any, data:{type:'FeatureCollection',features:[{type:'Feature',id:'example',geometry:{type:'Point',coordinates:[120,-30,10]},properties:{mag:3,place:'Example location',tsunami:1,time:1,status:'reviewed',alert:null}}]}} as any);
    expect(value?.description).not.toContain('Tsunami Warning');
    expect(value?.severityBand).not.toBe('critical');
  });
});

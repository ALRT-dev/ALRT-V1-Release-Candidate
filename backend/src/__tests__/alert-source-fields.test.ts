import {describe, it, expect, vi} from 'vitest';
vi.mock('../services/google_map.service.js', () => ({convertAddressToLatLng: vi.fn(), convertLatLngToAddress: vi.fn()}));
vi.mock('../services/ingestion.service.js', () => ({ExternalSourceId: {nswSes:'nswSes', rfs:'rfs', nswTransport:'nswTransport', earthquakeUsgs:'earthquakeUsgs'}, getLocationsFromText: vi.fn()}));
vi.mock('../services/hazard_category.service.js', () => ({MainCategoryId: {other:'other', weatherAndEnvironment:'weatherAndEnvironment'}}));
import {parseUSGSEarthquakeToHazards} from '../utils/ingestion.util.js';

describe('source fields for published templates', () => {
  it('does not turn a USGS tsunami information flag into a warning', () => {
    const [value] = parseUSGSEarthquakeToHazards({earthquakeCategory:{id:'earthquake'} as any, data:{type:'FeatureCollection',features:[{type:'Feature',id:'example',geometry:{type:'Point',coordinates:[120,-30,10]},properties:{mag:3,place:'Example location',tsunami:1,time:1,status:'reviewed',alert:null}}]}} as any);
    expect(value?.description).not.toContain('Tsunami Warning');
    expect(value?.severityBand).not.toBe('critical');
  });
});

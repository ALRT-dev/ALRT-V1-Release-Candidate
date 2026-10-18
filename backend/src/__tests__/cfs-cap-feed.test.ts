import {describe,it,expect,vi} from 'vitest';
vi.mock('../services/google_map.service.js',()=>({convertAddressToLatLng:vi.fn(),convertLatLngToAddress:vi.fn()}));
vi.mock('../services/ingestion.service.js',()=>({ExternalSourceId:{cfs:'cfs'},getLocationsFromText:vi.fn()}));
vi.mock('../services/hazard_category.service.js',()=>({MainCategoryId:{other:'other'}}));
import {parseCFSCapToHazards,convertHazardDataWithRelationsToCreateInput} from '../utils/ingestion.util.js';
const categories=[{id:'bushfire',keywords:['bushfire'],isFireRelated:true,parent:null},{id:'plannedBurn',keywords:['burn off','prescribed burn'],isFireRelated:true,parent:null},{id:'other',keywords:[],parent:null}] as any;
const entry=(options:Record<string,string>={})=>{
 const v={id:'F2610150124-2026-10-15T19:51:35+10:30',sender:'South Australian Country Fire Service',status:'Actual',scope:'Public',msgType:'Alert',level:'Watch and Act',life:'Going',type:'Bushfire',instruction:'If you are west of Example Road, leave via North Road. Do not use South Road.',area:'<circle>-33.034933,138.436605 0.0</circle>',...options};
 return `<entry><id>${v.id}</id><title>Example bushfire</title><content type="text/xml"><alert xmlns="urn:oasis:names:tc:emergency:cap:1.2"><identifier>${v.id}</identifier><sent>2026-10-15T19:51:35+10:30</sent><status>${v.status}</status><scope>${v.scope}</scope><msgType>${v.msgType}</msgType><info><language>en-AU</language><senderName>${v.sender}</senderName><event>Fire</event><headline>Example bushfire</headline><description>Fire near Example Road &amp; Hill Road.</description><instruction>${v.instruction}</instruction><web>https://www.cfs.sa.gov.au/incidents</web><parameter><valueName>WarningLevel</valueName><value>${v.level}</value></parameter><parameter><valueName>Status</valueName><value>${v.life}</value></parameter><parameter><valueName>SubCategory</valueName><value>${v.type}</value></parameter><area><areaDesc>Example Road</areaDesc>${v.area}</area></info></alert></content></entry>`;
};
const parse=(entries:string)=>parseCFSCapToHazards({xml:`<feed xmlns="http://www.w3.org/2005/Atom">${entries}</feed>`,availableCategories:categories});
describe('current CFS CAP-AU feed (synthetic fixtures)',()=>{
 it('retains the native level, exact conditional instructions, location and agency URL',()=>{
  const [h]=parse(entry());
  expect(h).toMatchObject({id:'cfs-F2610150124',nativeWarningLevel:'Watch and Act',severity:'watchAndAct',severityBand:'action',isAwsCompliant:true,jurisdictionCountry:'AU',locationName:'Example Road',latitude:-33.034933,longitude:138.436605,link:'https://www.cfs.sa.gov.au/incidents'});
  expect(h?.sourceInstructionBlocks).toEqual(['If you are west of Example Road, leave via North Road. Do not use South Road.']);
  expect(h?.description).toContain('Fire near Example Road & Hill Road.');
 });
 it('keeps a stable incident ID across source updates',()=>{
  expect(parse(entry({id:'F2610150124-2026-10-15T20:51:35+10:30'}))[0]?.id).toBe(parse(entry())[0]?.id);
 });
 it('does not misattribute MFS or private records as CFS',()=>{
  expect(parse(entry({sender:'South Australian Metropolitan Fire Service'})+entry({scope:'Restricted'}))).toEqual([]);
 });
 it.each(['Advice','Watch and Act','Emergency Warning'])('preserves the %s agency level',level=>{
  const expected={Advice:'monitor','Watch and Act':'action','Emergency Warning':'critical'};
  expect(parse(entry({level}))[0]?.severityBand).toBe(expected[level as keyof typeof expected]);
 });
 it.each(['Test','Exercise'])('keeps %s messages Info despite warning language',status=>{
  expect(parse(entry({status,level:'Emergency Warning'}))[0]).toMatchObject({severity:'info',severityBand:'info'});
 });
 it.each(['Complete','Resolved','Closed','Safe'])('keeps %s incidents Info',life=>{
  expect(parse(entry({life,level:'Emergency Warning'}))[0]).toMatchObject({severity:'info',severityBand:'info'});
 });
 it('makes cancellations Info and immediately expired',()=>{
  expect(parse(entry({msgType:'Cancel'}))[0]).toMatchObject({severity:'info',severityBand:'info',expiresAt:new Date('2026-10-15T19:51:35+10:30')});
 });
 it('does not promote an incident level or generic monitoring instruction to AWS Advice',()=>{
  expect(parse(entry({level:'Incident',type:'Burn Off',instruction:'An incident has occurred. Stay up to date in case the situation changes'}))[0]).toMatchObject({nativeWarningLevel:'Incident',severityBand:'info',isAwsCompliant:false});
 });
 it('retains polygon bounds and handles a zero coordinate',()=>{
  expect(parse(entry({area:'<polygon>0,138 0,139 -1,139 -1,138 0,138</polygon>'}))[0]).toMatchObject({northeastLat:0,northeastLng:139,southwestLat:-1,southwestLng:138});
 });
 it('rejects invalid feed bodies and malformed geometry instead of recording a successful empty fetch',()=>{
  expect(()=>parseCFSCapToHazards({xml:'<html>File unavailable</html>',availableCategories:categories})).toThrow();
  expect(()=>parse(entry({area:'<circle>invalid</circle>'}))).toThrow();
 });
 it('allows a valid empty feed',()=>expect(parse('')).toEqual([]));
 it('retains each same-language area, warning level and conditional instruction',()=>{
  const second=entry({level:'Emergency Warning',instruction:'If you are east of Example Road, shelter indoors.',area:'<circle>-34,139 1</circle>'}).match(/<info>[\s\S]*<\/info>/)![0].replaceAll('Example Road</areaDesc>','Eastern Area</areaDesc>');
  const rows=parse(entry().replace('</alert>',`${second}</alert>`));
  expect(rows[0]?.nativeWarningLevel).toBe('Emergency Warning');
  expect(rows[0]?.severityBand).toBe('critical');
  expect(rows[0]?.sourceInstructionBlocks?.join('\n')).toContain('Eastern Area');
  expect(rows[0]?.sourceInstructionBlocks?.join('\n')).toContain('east of Example Road, shelter indoors');
  expect(rows[0]?.sourceInstructionBlocks?.join('\n')).toContain('west of Example Road, leave via North Road');
 });
 it('applies reference-only cancellation to the existing CFS record without inventing geometry',()=>{
  const [previous]=parse(entry());
  const cancel='<entry><content><alert><identifier>cancellation-1</identifier><sender>emergency.services@eso.sa.gov.au</sender><sent>2026-10-15T21:00:00+10:30</sent><status>Actual</status><scope>Public</scope><msgType>Cancel</msgType><references>emergency.services@eso.sa.gov.au,F2610150124-2026-10-15T19:51:35+10:30,2026-10-15T19:51:35+10:30</references></alert></content></entry>';
  const [h]=parseCFSCapToHazards({xml:`<feed>${cancel}</feed>`,availableCategories:categories,previousHazards:[{...previous!,source:{id:'cfs'} as any}]});
  expect(h).toMatchObject({id:previous?.id,latitude:previous?.latitude,longitude:previous?.longitude,severity:'info',severityBand:'info',sourceLifecycle:'resolved',expiresAt:new Date('2026-10-15T21:00:00+10:30')});
  expect(parseCFSCapToHazards({xml:`<feed>${cancel}</feed>`,availableCategories:categories,previousHazards:[{...previous!,source:{id:'other'} as any}]})).toEqual([]);
 });
 it('does not send transient lifecycle or raw instructions to Prisma',()=>{
  const [h]=parse(entry({status:'Test'}));
  const stored=convertHazardDataWithRelationsToCreateInput(h!);
  expect(stored).not.toHaveProperty('sourceLifecycle');
  expect(stored).not.toHaveProperty('sourceInstructionBlocks');
 });
 it('does not downgrade an active area because another area is complete',()=>{
  const second=entry({level:'Watch and Act',life:'Going'}).match(/<info>[\s\S]*<\/info>/)![0];
  const [h]=parse(entry({life:'Complete',level:'Emergency Warning'}).replace('</alert>',`${second}</alert>`));
  expect(h).toMatchObject({nativeWarningLevel:'Watch and Act',severityBand:'action',sourceLifecycle:'active'});
  expect(h?.sourceInstructionBlocks?.join('\n')).toContain('Status: Complete');
  expect(h?.sourceInstructionBlocks?.join('\n')).toContain('Status: Going');
 });
 it('preserves the active official band even without a published template registry',()=>{
  const completed=entry({life:'Complete',level:'Emergency Warning'}).match(/<info>[\s\S]*<\/info>/)![0].replace('Fire near Example Road &amp; Hill Road.','Incident is resolved.');
  const [h]=parse(entry().replace('</alert>',`${completed}</alert>`));
  expect(h).toMatchObject({nativeWarningLevel:'Watch and Act',severity:'watchAndAct',severityBand:'action',sourceLifecycle:'active'});
 });
 it('does not cancel a source update newer than the referenced warning',()=>{
  const [previous]=parse(entry());
  const cancel=entry({msgType:'Cancel',instruction:'North Road remains closed until inspected.'}).replace('<sent>2026-10-15T19:51:35+10:30</sent>','<sent>2026-10-15T21:00:00+10:30</sent><sender>emergency.services@eso.sa.gov.au</sender><references>emergency.services@eso.sa.gov.au,F2610150124-2026-10-15T19:51:35+10:30,2026-10-15T19:51:35+10:30</references>');
  expect(parseCFSCapToHazards({xml:`<feed>${cancel}</feed>`,availableCategories:categories,previousHazards:[{...previous!,occurredAt:new Date('2026-10-15T20:00:00+10:30'),source:{id:'cfs'} as any}]})).toEqual([]);
 });
 it.each([true,false])('retains cancellation instructions when geometry is present: %s',hasGeometry=>{
  const [previous]=parse(entry());
  const cancel=entry({msgType:'Cancel',area:hasGeometry?'<circle>-33.034933,138.436605 0.0</circle>':'',instruction:'North Road remains closed until inspected.'}).replace('<sent>2026-10-15T19:51:35+10:30</sent>','<sent>2026-10-15T21:00:00+10:30</sent><sender>emergency.services@eso.sa.gov.au</sender><references>emergency.services@eso.sa.gov.au,F2610150124-2026-10-15T19:51:35+10:30,2026-10-15T19:51:35+10:30</references>');
  const [h]=parseCFSCapToHazards({xml:`<feed>${cancel}</feed>`,availableCategories:categories,previousHazards:[{...previous!,source:{id:'cfs'} as any}]});
  expect(h?.sourceInstructionBlocks).toContain('North Road remains closed until inspected.');
  expect(h).toMatchObject({latitude:previous?.latitude,longitude:previous?.longitude,severityBand:'info'});
 });
 it('selects the newest record when an incident appears more than once',()=>{
  const rows=parse(entry()+entry({id:'F2610150124-2026-10-15T20:51:35+10:30',level:'Emergency Warning'}).replace('<sent>2026-10-15T19:51:35+10:30</sent>','<sent>2026-10-15T20:51:35+10:30</sent>'));
  expect(rows).toHaveLength(1);expect(rows[0]?.severityBand).toBe('critical');
 });
});

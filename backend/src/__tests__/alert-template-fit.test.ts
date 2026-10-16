import {describe,it,expect} from 'vitest';
import {defaultTemplatePack,chooseTemplateBand,type TemplateBand} from '../utils/alert_templates.util.js';
import {parseAgencyExtraction,AGENCY_EXTRACTION_CONTRACT} from '../utils/agency_extraction.util.js';

// All examples are synthetic. This exercises server validation and mapping,
// not a live model, external feed, geocoder, database or notification service.
const examples: {name:string;label:string|null;severity?:string;band:TemplateBand;aws?:boolean;text:string;action?:string}[] = [
  {name:'Bushfire Advice',label:'Advice',severity:'advice',band:'monitor',aws:true,text:'A bushfire is burning near Example Town.',action:'If you are in Example Town, monitor the agency update.'},
  {name:'Bushfire Watch and Act',label:'Watch and Act',severity:'watchAndAct',band:'action',aws:true,text:'Fire conditions are changing near Example Town.',action:'If you are in Example Town, prepare to leave when directed by the agency.'},
  {name:'Bushfire Emergency Warning',label:'Emergency Warning',severity:'emergency',band:'critical',aws:true,text:'The agency has issued a warning for Example Town.',action:'If you are in the named warning area and it is safe, leave via Example Road.'},
  {name:'Planned burn with warning',label:'Advice',severity:'advice',band:'monitor',aws:true,text:'Smoke from a planned burn may affect Example Road.'},
  {name:'Structure fire',label:'Watch and Act',severity:'watchAndAct',band:'action',text:'Crews are responding to a structure fire in Example Town.'},
  {name:'Vehicle crash',label:'Road closed',band:'action',text:'Example Road is closed following a crash.',action:'Use the signed diversion if travelling towards Example Road.'},
  {name:'Flood',label:'Emergency Warning',severity:'emergency',band:'critical',aws:true,text:'Floodwater is affecting Example Town.',action:'If you are inside the warning boundary, follow the marked route to the named centre.'},
  {name:'Severe weather',label:'Severe weather warning',band:'action',text:'Damaging winds are forecast for Example District.'},
  {name:'Power outage',label:'Unplanned outage',band:'monitor',text:'Power is interrupted in Example Suburb. The restoration time is unknown.'},
  {name:'Drill',label:'Emergency Warning',severity:'emergency',band:'info',aws:true,text:'This is a test message only. No incident is occurring.'},
  {name:'Resolved incident',label:'Emergency Warning',severity:'emergency',band:'info',aws:true,text:'Incident resolved. The earlier warning is cancelled.'},
  {name:'Not Applicable',label:'Not Applicable',band:'info',text:'The agency lists the warning level as Not Applicable.'},
  {name:'Long agency instruction',label:'Advice',severity:'advice',band:'monitor',text:'The agency has published a detailed update for Example Town.',action:'For properties north of Example Road only:\nIf it is safe, prepare your existing plan.\nKeep away from the closed crossing.\nUse Exit 112 via Route 911.\nPeople outside the named area should continue to check agency updates.'},
  {name:'Non-English source',label:'Aviso',band:'monitor',text:'Hay humo en Villa Ejemplo.',action:'Si está en Villa Ejemplo, consulte las actualizaciones de la agencia.'},
  {name:'Humanitarian response scale',label:'Red humanitarian response level',band:'critical',text:'The source rates potential international assistance needs as Red. This is not an Australian Warning System level.'},
  {name:'Saudi Arabia travel',label:'Do not travel',band:'critical',text:'The example agency advises against travel to the named border area.',action:'Do not travel to the named border area. Different advice applies elsewhere in the country.'},
];

describe('synthetic template fit matrix',()=>{
  for (const sample of examples) it(sample.name,()=>{
    const settings=defaultTemplatePack().defaults;
    if(sample.label)settings.nativeLevelMappings=[{level:sample.label,band:sample.band}];
    const sourceText=[sample.name,sample.label,sample.text,sample.action].filter(Boolean).join('\n\n');
    const decision=chooseTemplateBand(settings,{isAws:sample.aws??false,severity:sample.severity??null,nativeLevel:sample.label,description:sample.text,fallback:'info'});
    const value=parseAgencyExtraction({title:sample.name,facts:[{text:sample.text,evidence:sample.text}],affectedAreas:[],nativeLevel:sample.label,officialActions:sample.action?[{text:sample.action,evidence:sample.action}]:[],confidence:'high'},{sourceText,sourceTitle:sample.name,sourceActions:sample.action?[sample.action]:[],agency:'Synthetic agency',allowAgencyNumbers:false,templateVersion:1,alrtSuggestions:[],profileGuidance:[]});
    expect(decision.band).toBe(sample.band);
    expect(value.contentDetails.nativeLevel).toBe(sample.label);
    expect(value.contentDetails.officialActions).toEqual(sample.action?[sample.action]:[]);
    expect(value).not.toHaveProperty('severity');
    expect(value.summary).toContain(sample.text);
    expect(AGENCY_EXTRACTION_CONTRACT).toContain('never severity');
  });
});

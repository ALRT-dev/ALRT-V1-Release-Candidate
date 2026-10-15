import {XMLParser, XMLValidator} from 'fast-xml-parser';

export const CFS_CAP_URL = 'https://data.eso.sa.gov.au/feeds/prod/cap-au.xml';
const list = <T>(value:T|T[]|undefined):T[] => value === undefined ? [] : Array.isArray(value) ? value : [value];
const text = (value:unknown):string => typeof value==='string' ? value.trim() : '';
const date = (value:unknown):Date => {
  const result=new Date(text(value));
  if(!Number.isFinite(result.getTime()))throw Error('CFS CAP contains an invalid source time.');
  return result;
};
const point = (value:string):[number,number] => {
  const parts=value.split(',');
  const lat=Number(parts[0]),lon=Number(parts[1]);
  if(parts.length!==2||parts.some(x=>!x.trim())||!Number.isFinite(lat)||!Number.isFinite(lon)||Math.abs(lat)>90||Math.abs(lon)>180)throw Error('CFS CAP contains invalid coordinates.');
  return [lat,lon];
};
const incidentId=(identifier:string)=>identifier.match(/^([A-Z]\d+)-\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:Z|[+-]\d{2}:\d{2})$/)?.[1]??identifier;
const params=(info:any):Record<string,string>=>Object.fromEntries(list<any>(info.parameter).map(x=>[text(x.valueName),text(x.value)]));
const level=(info:any)=>params(info)['AustralianWarningSystem:WarningLevel']||params(info).WarningLevel||'';
const rank=(info:any)=>({'Advice':1,'Watch and Act':2,'Watch & Act':2,'Emergency Warning':3}[level(info)]??0);
const resolvedInfo=(info:any)=>/^(complete|completed|resolved|closed|safe|cancelled)$/i.test(params(info).Status??'');
const areaContext=(info:any)=>[
  `Area: ${list<any>(info.area).map(x=>text(x.areaDesc)).filter(Boolean).join('; ')||params(info).Location||'Not specified by the source'}`,
  level(info)?`Warning level: ${level(info)}`:'',
  params(info).Status?`Status: ${params(info).Status}`:'',
  info.expires?`Valid until: ${text(info.expires)}`:'',
].filter(Boolean).join('\n');
function entries(xml:string):any[]{
  if(xml.length>5_000_000||/<!DOCTYPE|<!ENTITY/i.test(xml)||XMLValidator.validate(xml)!==true)throw Error('CFS CAP feed is not valid XML.');
  const parsed=new XMLParser({ignoreAttributes:true,removeNSPrefix:true,parseTagValue:false,trimValues:true}).parse(xml);
  if(!Object.hasOwn(parsed,'feed'))throw Error('CFS CAP feed is unavailable or has an unexpected format.');
  return list<any>(parsed.feed?.entry);
}

/** A reference-only cancellation may omit all info/geometry. Resolve only to
 * existing CFS rows at the ingestion boundary; never create a guessed place. */
export function readCFSCapCancellations(xml:string){
  return entries(xml).flatMap(entry=>{
    const alert=entry.content?.alert;
    if(!alert||text(alert.scope)!=='Public'||text(alert.status)!=='Actual'||text(alert.msgType)!=='Cancel')return [];
    const occurredAt=date(alert.sent);
    return text(alert.references).split(/\s+/).filter(Boolean).flatMap(reference=>{
      const [sender,identifier,sent]=reference.split(',');
      if(!identifier||!sent||!sender||sender!==text(alert.sender))throw Error('CFS CAP cancellation has an invalid reference.');
      const referencedAt=date(sent);
      return [{id:`cfs-${incidentId(identifier)}`,messageId:`cfs-${incidentId(text(alert.identifier))}`,referencedAt,occurredAt}];
    });
  });
}

/** Read the agency's current public CAP-AU feed. The feed also carries MFS
 * records; those must not be attributed to the existing CFS source. */
export function readCFSCap(xml:string) {
  return entries(xml).flatMap(entry=>{
    const alert=entry.content?.alert;
    if(!alert)throw Error('CFS CAP entry has no alert payload.');
    if(text(alert.scope)!=='Public')return [];
    if(['Ack','Error'].includes(text(alert.msgType))||['Draft','System'].includes(text(alert.status)))return [];
    const infos=list<any>(alert.info);
    if(!infos.length&&text(alert.msgType)==='Cancel'){
      if(!text(alert.references))throw Error('CFS CAP cancellation has no referenced alert.');
      return [];
    }
    if(!infos.length)throw Error('CFS CAP entry has no information block.');
    const preferred=infos.find(x=>text(x.language).toLowerCase()==='en-au')??infos.find(x=>/^en(?:-|$)/i.test(text(x.language)))??infos[0];
    const selected=infos.filter(x=>text(x.language)===text(preferred.language)&&text(x.senderName)==='South Australian Country Fire Service');
    if(!selected.length)return [];
    const activeSections=selected.filter(x=>!resolvedInfo(x));
    const currentSections=activeSections.length?activeSections:selected;
    const highest=[...currentSections].sort((a,b)=>rank(b)-rank(a))[0];
    const info=selected.length===1?selected[0]:{
      ...highest,
      area:currentSections.flatMap(x=>list(x.area)),
      description:selected.map(x=>`${areaContext(x)}\n${text(x.description)}`).join('\n\n'),
      instruction:selected.filter(x=>text(x.instruction)||params(x).CallToAction||params(x)['AustralianWarningSystem:CallToAction']).map(x=>`${areaContext(x)}\n${[text(x.instruction),params(x)['AustralianWarningSystem:CallToAction']||params(x).CallToAction||''].filter(Boolean).join('\n')}`).join('\n\n'),
      // One combined card retains every section's validity in its source text.
      // Do not expire all areas at the first area's expiry.
      expires:currentSections.every(x=>text(x.expires))?new Date(Math.max(...currentSections.map(x=>date(x.expires).getTime()))).toISOString():undefined,
    };
    const parameters=Object.fromEntries(list<any>(info.parameter).map(x=>[text(x.valueName),text(x.value)]));
    const identifier=text(alert.identifier);
    if(!identifier)throw Error('CFS CAP entry has no identifier.');
    // Current identifiers are incident code + issue timestamp. Strip only that
    // observed suffix, retaining opaque identifiers from other valid messages.
    const stableId=incidentId(identifier);
    const occurredAt=date(alert.sent);
    const cancelled=text(alert.msgType)==='Cancel';
    const status=text(alert.status);
    if(!['Actual','Test','Exercise','Draft','System'].includes(status))throw Error('CFS CAP contains an unrecognised message status.');
    const resolved=cancelled||selected.every(resolvedInfo);
    const sourceLifecycle=resolved?'resolved' as const:status!=='Actual'?'test' as const:
      selected.some(x=>/^(going|active|controlled)$/i.test(params(x).Status??''))?'active' as const:undefined;
    const areas=list<any>(info.area);
    const points:[number,number][]=[];
    let hasExtent=false;
    for(const area of areas){
      for(const polygon of list<string>(area.polygon)){
        const vertices=text(polygon).split(/\s+/).map(point);
        if(vertices.length<4)throw Error('CFS CAP contains an invalid polygon.');
        points.push(...vertices);hasExtent=true;
      }
      for(const circle of list<string>(area.circle)){
        const parts=text(circle).split(/\s+/);const centre=point(parts[0]??'');
        const radius=Number(parts[1]);
        if(parts.length!==2||!Number.isFinite(radius)||radius<0)throw Error('CFS CAP contains an invalid circle.');
        points.push(centre);
        if(radius>0){
          const dLat=radius/111.32,dLon=radius/(111.32*Math.max(0.0001,Math.cos(centre[0]*Math.PI/180)));
          points.push([Math.max(-90,centre[0]-dLat),Math.max(-180,centre[1]-dLon)],[Math.min(90,centre[0]+dLat),Math.min(180,centre[1]+dLon)]);hasExtent=true;
        }
      }
    }
    if(!points.length){
      if(!(cancelled&&text(alert.references)))throw Error('CFS CAP entry has no usable source geometry.');
    }
    const north=Math.max(...points.map(x=>x[0])),south=Math.min(...points.map(x=>x[0]));
    const east=Math.max(...points.map(x=>x[1])),west=Math.min(...points.map(x=>x[1]));
    const nativeWarningLevel=parameters['AustralianWarningSystem:WarningLevel']||parameters.WarningLevel||null;
    const instructions=[text(info.instruction),selected.length===1?(parameters['AustralianWarningSystem:CallToAction']||parameters.CallToAction||''):''].filter(Boolean);
    const sourceDescription=text(info.description);
    const description=[sourceLifecycle==='test'?'Test alert.':sourceLifecycle==='resolved'?'Incident is resolved.':'',
      `Type: ${parameters.SubCategory||parameters.Category||text(info.event)}`,
      parameters.Status?`Source status: ${parameters.Status}`:'',
      nativeWarningLevel?`Warning level: ${nativeWarningLevel}`:'',
      !/^(not available|n\/a)$/i.test(sourceDescription)?sourceDescription:''].filter(Boolean).join('\n\n');
    const url=text(info.web);
    return [{id:`cfs-${stableId}${status!=='Actual'?`-${status.toLowerCase()}`:''}`,title:text(info.headline)||text(entry.title)||'CFS incident',description,nativeWarningLevel,
      categoryText:parameters.SubCategory||parameters.Category||text(info.event),sourceLifecycle,
      isCancellation:cancelled,hasCancellationReferences:!!text(alert.references),
      sourceInstructionBlocks:[...new Set(instructions)],occurredAt,
      expiresAt:cancelled?occurredAt:info.expires?date(info.expires):null,
      locationName:areas.map(x=>text(x.areaDesc)).filter(Boolean).join('; ')||parameters.Location||null,
      latitude:points.length?(north+south)/2:null,longitude:points.length?(east+west)/2:null,
      ...((hasExtent||points.length>1)?{northeastLat:north,northeastLng:east,southwestLat:south,southwestLng:west}:{}),
      link:/^https:\/\//i.test(url)?url:null,jurisdictionCountry:'AU'}];
  });
}

export async function fetchCFSCap():Promise<string>{
  const response=await fetch(CFS_CAP_URL,{signal:AbortSignal.timeout(20_000)});
  if(!response.ok)throw Error(`CFS CAP feed returned HTTP ${response.status}.`);
  return response.text();
}

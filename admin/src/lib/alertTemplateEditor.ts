import type {TemplatePack,TemplateOverride,TemplateSource,TemplateSettings} from '../api/alertTemplates';
const countryCode=(value:string|null|undefined)=>{const name=value?.toUpperCase().trim()??'';return ({AUSTRALIA:'AU','NEW ZEALAND':'NZ','UNITED KINGDOM':'GB','UNITED STATES':'US','SAUDI ARABIA':'SA'} as Record<string,string>)[name]??name;};
export function editorSettings(pack:TemplatePack,active:TemplateOverride|undefined,sources:TemplateSource[]):TemplateSettings{
  if(!active)return pack.defaults;
  const globalSource = ["smartraveller","canadaGovTra","earthquakeUsgs","gdacsGlobal","waqi"].includes(active.sourceId??"");
  const country=active.country??(globalSource?null:countryCode(sources.find(x=>x.id===active.sourceId)?.country));
  const priority=(x:TemplateOverride)=>Number(Boolean(x.sourceId))*2+Number(Boolean(x.country));
  const parents=pack.overrides.filter(x=>x.id!==active.id&&priority(x)<priority(active)&&(!x.country||x.country===country)&&(!x.sourceId||x.sourceId===active.sourceId)).sort((a,b)=>priority(a)-priority(b));
  return Object.assign({},pack.defaults,...parents.map(x=>x.settings),active.settings);
}

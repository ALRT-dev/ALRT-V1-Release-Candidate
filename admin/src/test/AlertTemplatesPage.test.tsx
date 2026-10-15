import {render,screen,waitFor} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import {MemoryRouter} from 'react-router-dom';
import {beforeEach,describe,it,expect,vi} from 'vitest';
import {AlertTemplatesPage} from '../pages/AlertTemplatesPage';
import {editorSettings} from '../lib/alertTemplateEditor';
import type {TemplatePack} from '../api/alertTemplates';
const mocks=vi.hoisted(()=>({get:vi.fn(),save:vi.fn(),preview:vi.fn(),write:true}));
vi.mock('../auth/AuthContext',()=>({useAuth:()=>({hasRole:()=>mocks.write})}));
vi.mock('../api/alertTemplates',async(importOriginal)=>({...await importOriginal<typeof import('../api/alertTemplates')>(),getAlertTemplates:mocks.get,saveAlertTemplates:mocks.save,previewAlertTemplate:mocks.preview}));
vi.mock('../api/resources',()=>({listAIPrompts:async()=>[],listCategories:async()=>[{id:'smoke',name:'Smoke',parentId:null,color:'#FF7E29',images:[],subCategories:[]}]}));
const pack=():TemplatePack=>({defaults:{language:'en-AU',promptId:null,additionalInstructions:'Extract source facts.',bandColors:{info:'#8A93A0',monitor:'#FBE032',action:'#F07E1B',critical:'#DA1F2D'},nativeLevelMappings:[],iconCategoryId:null,allowAgencyNumbers:false},overrides:[{id:'nz',name:'New Zealand',country:'NZ',sourceId:null,settings:{language:'en-NZ'}},{id:'agency',name:'Agency detail',country:null,sourceId:'agency',settings:{additionalInstructions:'Keep road names.'}}],library:[]});
const sources=[{id:'agency',name:'Example agency',country:'NZ',sourceType:null,severitySystem:null}];
const state=()=>({revision:1,draft:pack(),published:null,history:[]});
beforeEach(()=>{vi.clearAllMocks();mocks.write=true;mocks.get.mockResolvedValue({state:state(),sources});mocks.save.mockResolvedValue({...state(),revision:2});});
const show=()=>render(<MemoryRouter><AlertTemplatesPage/></MemoryRouter>);
describe('alert template editor',()=>{
  it('shows inherited country settings for a source override',async()=>{
    expect(editorSettings(pack(),pack().overrides[1],sources).language).toBe('en-NZ');
    show();const user=userEvent.setup();await screen.findByText('One shared template, with country and source changes where needed.');
    await user.selectOptions(screen.getByRole('combobox',{name:/Editing/}),'agency');
    expect(screen.getByDisplayValue('en-NZ')).toBeInTheDocument();
  });
  it('saves a draft without publishing or previewing',async()=>{
    show();await screen.findByRole('button',{name:'Save draft'});await userEvent.click(screen.getByRole('button',{name:'Save draft'}));
    await waitFor(()=>expect(mocks.save).toHaveBeenCalledWith(expect.objectContaining({action:'draft',revision:1})));
    expect(mocks.preview).not.toHaveBeenCalled();
    expect(await screen.findByText('Draft saved. Future alerts still use the published version.')).toBeInTheDocument();
  });
  it('keeps profile selections out of the preview request',async()=>{
    mocks.preview.mockResolvedValue({previewOnly:true,suppressed:false,band:'action',reason:'Native warning',applied:['Shared default'],isAws:false,settings:pack().defaults,output:{title:'Example',summary:'Facts',callsToAction:[],confidence:'high',contentDetails:{schemaVersion:1,templateVersion:0,facts:['Smoke is present.'],affectedAreas:['Example Town'],nativeLevel:'Watch and Act',officialActions:['Prepare to leave.'],alrtSuggestions:[],profileGuidance:[]}}});
    show();const user=userEvent.setup();await screen.findByRole('button',{name:'Preview extracted alert'});
    const combos=screen.getAllByRole('combobox');
    await user.selectOptions(combos.find(x=>x.querySelector('option[value="agency"]')&&x.querySelector('option[value=""]')?.textContent==='Choose a source')!,'agency');
    await user.selectOptions(screen.getByRole('combobox',{name:'Category'}),'smoke');
    await user.click(screen.getByText('Preview safety profiles'));await user.click(screen.getByLabelText('Children in my care'));
    await user.click(screen.getByRole('button',{name:'Preview extracted alert'}));
    await screen.findByText('What the agency says to do');
    expect(mocks.preview.mock.calls[0]?.[0]).not.toHaveProperty('selectedProfiles');expect(mocks.save).not.toHaveBeenCalled();
  });
  it('does not let a moderator save or invoke model previews',async()=>{
    mocks.write=false;show();expect(await screen.findByRole('button',{name:'Save draft'})).toBeDisabled();expect(screen.getByRole('button',{name:'Preview extracted alert'})).toBeDisabled();
  });
});

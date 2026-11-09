import {render,screen} from '@testing-library/react';
import {describe,it,expect} from 'vitest';
import {AlertContentSections} from '../components/AlertContentSections';
describe('owner alert preview rules',()=>{
 it('shows up to four facts and suppresses ALRT fallback when agency advice exists',()=>{
  render(<AlertContentSections content={{schemaVersion:1,templateVersion:3,facts:['First fact.','Second fact.','Third fact.','Fourth fact.','Fifth fact.'],affectedAreas:[],nativeLevel:null,officialActions:['Avoid Example Road.'],alrtSuggestions:['Consider reviewing travel plans.'],profileGuidance:[]}} profileTags={[]}/>);
  expect(screen.getByText('Fourth fact.')).toBeInTheDocument();
  expect(screen.queryByText('Fifth fact.')).not.toBeInTheDocument();
  expect(screen.getByText('Avoid Example Road.')).toBeInTheDocument();
  expect(screen.queryByText('Consider reviewing travel plans.')).not.toBeInTheDocument();
 });
});

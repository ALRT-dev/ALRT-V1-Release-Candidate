import {describe, expect, it} from 'vitest';
import {agencySourceBlocks, parseAgencyExtraction, removeUnattributedNumbers} from '../utils/agency_extraction.util.js';

const options = (sourceText: string) => ({sourceText, sourceDescription: sourceText, agency:'Agency', allowAgencyNumbers:false, templateVersion:1, alrtSuggestions:[], profileGuidance:[]});
const selection = {title:'Agency update', factBlockIds:[0,1], actionBlockIds:[], affectedAreas:[], nativeLevel:null, confidence:'high'};

describe('source block selection', () => {
  it('resolves selected IDs to original source text without model rewriting', () => {
    const source='Incident: Ambulance response\nLocation: Macquarie\nStatus: On scene';
    expect(agencySourceBlocks(source)).toEqual(source.split('\n'));
    const result=parseAgencyExtraction(selection,options(source));
    expect(result.contentDetails.facts).toEqual(['Incident: Ambulance response','Location: Macquarie']);
  });
  it('keeps free-text paragraphs and their conditions together', () => {
    const source='For residents east of Example Road only:\nLeave if it is safe.\nOtherwise shelter inside.';
    expect(agencySourceBlocks(source)).toEqual([source]);
    const result=parseAgencyExtraction({...selection,factBlockIds:[0],actionBlockIds:[0]},options(source));
    expect(result.contentDetails.officialActions).toEqual([source]);
  });
  it('rejects invented, fractional or negative block IDs and extra model authority', () => {
    for(const id of [-1, 2, 0.5]) expect(()=>parseAgencyExtraction({...selection,factBlockIds:[id]},options('One block.'))).toThrow();
    expect(()=>parseAgencyExtraction({...selection,factBlockIds:[0],severity:'critical'},options('One block.'))).toThrow();
  });
  it('does not split unknown metadata or advice into context-free lines', () => {
    for(const source of ['Location: Example Town\nAdvice: Leave only if it is safe.','Location: Example Town\nOnly for residents south of Example Road:','Status: active\nCustom field: other']) {
      expect(agencySourceBlocks(source)).toEqual([source]);
    }
  });
  it('keeps uncertainty or pending status attached to the incident', () => {
    for(const qualifier of ['Report unconfirmed','Suspected incident','Resource Allocation Pending','Not confirmed']) {
      const source=`Incident: Gas leak\nLocation: Example Town\nStatus: ${qualifier}`;
      expect(agencySourceBlocks(source)).toEqual([source]);
    }
  });
});

describe('source phone wording', () => {
  it('keeps ordinary enquiry numbers out of emergency wording', () => {
    expect(removeUnattributedNumbers('For a towed vehicle call 132 701 to speak to an operator.')).toBe('For a towed vehicle call 132 701 to speak to an operator.');
    expect(removeUnattributedNumbers('contact DFAT on 1300 555 135')).toBe('contact DFAT on 1300 555 135');
    expect(removeUnattributedNumbers('Call the non-emergency number 132 500.')).toBe('Call the non-emergency number 132 500.');
    expect(removeUnattributedNumbers('Call State Emergency Service on 132 500.')).toBe('Call State Emergency Service on 132 500.');
  });
  it('replaces a named emergency number and its parenthetical digits once', () => {
    expect(removeUnattributedNumbers('If your property is under threat, call Triple Zero (000) immediately.')).toBe('If your property is under threat, call your local emergency number immediately.');
  });
});

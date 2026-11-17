import { describe, expect, it } from 'vitest';
import { withSourceHistory } from '../utils/source_history.util.js';

const source = {sourceId:'waDfes',eventId:'123',title:'Fire - PERTH',description:'Incident Type: Fire\nLocation: Perth\nReported: one',nativeLevel:null};
const at = new Date('2026-11-07T01:00:00Z');
describe('source history', () => {
  it('records a change confined to original agency instruction blocks', () => {
    const first=withSourceHistory({},null,{...source,instructions:['Keep windows closed.']},at);
    const next=withSourceHistory({},first,{...source,instructions:['If affected, leave when it is safe to do so.']},at);
    expect(next.sourceUpdate?.summary).toContain('Agency instructions changed');
    expect(next.sourceSnapshot?.instructions).toEqual(['If affected, leave when it is safe to do so.']);
  });
  it('starts with a baseline and never invents history for an old record', () => {
    const details = withSourceHistory({}, null, source, at);
    expect(details.sourceSnapshot).toEqual(source);
    expect(details.sourceUpdate).toBeUndefined();
  });
  it('ignores reprocessing, template edits and source report-time-only refreshes', () => {
    const first = withSourceHistory({}, null, source, at);
    const next = withSourceHistory({templateVersion:99}, first, {...source,description:source.description.replace('one','two')},at);
    expect(next.sourceUpdate).toBeUndefined();
    expect(next.templateVersion).toBe(99);
  });
  it('records the changed field on the same source event with detection time, not invented agency time', () => {
    const first = withSourceHistory({},null,source,at);
    const next = withSourceHistory({},first,{...source,description:source.description.replace('Location: Perth','Location: Scarborough')},at);
    expect(next.sourceUpdate).toMatchObject({summary:'Location: Perth → Scarborough.',detectedAt:at.toISOString()});
    expect(next.sourceUpdate).not.toHaveProperty('sourceUpdatedAt');
    expect(first.sourceUpdate).toBeUndefined();
    expect(withSourceHistory({},next,{...source,description:source.description.replace('Location: Perth','Location: Scarborough')},at).sourceUpdates).toHaveLength(1);
  });
  it('never transfers history between source events', () => {
    const first = withSourceHistory({},null,source,at);
    expect(withSourceHistory({},first,{...source,eventId:'different',title:'Different'},at).sourceUpdate).toBeUndefined();
    expect(withSourceHistory({},first,{...source,sourceId:'different',title:'Different'},at).sourceUpdate).toBeUndefined();
  });
  it('compares the two DFES feeds separately rather than inventing changes as they alternate', () => {
    const incident = {...source,channel:'incident'};
    const warning = {...source,channel:'warning',description:'Agency warning text',nativeLevel:'Advice'};
    const first = withSourceHistory({},null,incident,at);
    const second = withSourceHistory({},first,warning,at);
    expect(second.sourceUpdate).toBeUndefined();
    const third = withSourceHistory({},second,incident,at);
    expect(third.sourceUpdate).toBeUndefined();
    const fourth = withSourceHistory({},third,{...warning,nativeLevel:'Watch and Act'},at);
    expect(fourth.sourceUpdate?.summary).toContain('Watch and Act');
  });
  it('retains a real native level change and limits stored history', () => {
    let details = withSourceHistory({},null,source,at);
    for (let i=0;i<15;i++) details=withSourceHistory({},details,{...source,nativeLevel:`Source level ${i}`},at);
    expect(details.sourceUpdates).toHaveLength(10);
    expect(details.sourceUpdate?.summary).toContain('Source level 14');
  });
});

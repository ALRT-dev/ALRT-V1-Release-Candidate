import {describe,expect,it} from 'vitest';
import {sourceRenderHash,isSourceRenderRefresh} from '../utils/source_render_version.util.js';
describe('source render version',()=>{
  it('changes the processing identity without changing the source digest',()=>{
    expect(sourceRenderHash('abc','raw')).toBe('agency-blocks-v3:abc:raw');
  });
  it('recognises unchanged source data across renderer or template upgrades',()=>{
    expect(isSourceRenderRefresh('abc','raw','abc')).toBe(true);
    expect(isSourceRenderRefresh('agency-blocks-v1:abc','raw','abc')).toBe(true);
    expect(isSourceRenderRefresh(sourceRenderHash('old-render','raw'),'raw','different-render')).toBe(true);
  });
  it('does not suppress notifications for new or changed source data',()=>{
    expect(isSourceRenderRefresh(null,'raw','abc')).toBe(false);
    expect(isSourceRenderRefresh('agency-blocks-v1:old','raw','new')).toBe(false);
    expect(isSourceRenderRefresh(sourceRenderHash('abc','old-source'),'new-source','abc')).toBe(false);
  });
});

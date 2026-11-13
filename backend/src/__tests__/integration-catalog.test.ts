import { beforeEach, describe, expect, it, vi } from 'vitest';
const { findMany } = vi.hoisted(()=>({findMany:vi.fn()}));
vi.mock('../utils/prisma_client.util.js',()=>({default:{hazardCategory:{findMany}}}));
import { getWebhookCategories } from '../controllers/integration_catalog.controller.js';

describe('integration taxonomy catalog',()=>{
  beforeEach(()=>vi.clearAllMocks());
  it('reads only the current database leaf taxonomy, without alert writes or secret fields',async()=>{
    const rows=[{id:'bushfire',name:'Bushfire',parentId:'weatherAndEnvironment',description:'Fire',keywords:['bushfire'],isFireRelated:true}];
    findMany.mockResolvedValue(rows);
    const res:any={status:vi.fn().mockReturnThis(),json:vi.fn(),setHeader:vi.fn()};const next=vi.fn();
    await getWebhookCategories({} as any,res,next);
    // Existing n8n category parsing needs this flag as well as parent/keywords.
    expect(findMany).toHaveBeenCalledWith({where:{parentId:{not:null}},select:{id:true,name:true,parentId:true,description:true,keywords:true,isFireRelated:true},orderBy:{id:'asc'}});
    expect(res.json).toHaveBeenCalledWith(rows);expect(next).not.toHaveBeenCalled();
  });
  it('passes database errors to the existing error handler without reporting a successful catalog',async()=>{
    const error=new Error('database unavailable');findMany.mockRejectedValue(error);
    const res:any={status:vi.fn().mockReturnThis(),json:vi.fn(),setHeader:vi.fn()};const next=vi.fn();
    await getWebhookCategories({} as any,res,next);
    expect(next).toHaveBeenCalledWith(error);expect(res.json).not.toHaveBeenCalled();
  });
});

import { expect, it, vi } from 'vitest';
const { create }=vi.hoisted(()=>({create:vi.fn().mockResolvedValue({})}));
vi.mock('../utils/prisma_client.util.js',()=>({default:{webhookLog:{create}}}));
vi.mock('../utils/config.js',()=>({config:{}}));
import { requireWebhookAuth } from '../middlewares/webhook.middleware.js';
it('records rejected catalog GET as GET, never as an alert POST',async()=>{
  const warn=vi.spyOn(console,'warn').mockImplementation(()=>{});
  const next=vi.fn();
  await requireWebhookAuth({headers:{},ip:'127.0.0.1',method:'GET',path:'/categories'} as any,{} as any,next);
  expect(next).toHaveBeenCalledWith(expect.objectContaining({statusCode:401}));
  expect(create).toHaveBeenCalledWith({data:expect.objectContaining({method:'GET',success:false,statusCode:401,endpoint:'/categories'})});
  warn.mockRestore();
});

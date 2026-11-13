import { expect, it, vi } from 'vitest';
const guards=vi.hoisted(()=>({requireWebhookAuth:vi.fn(),webhookBurstProtection:vi.fn(),webhookRateLimiter:vi.fn(),webhookSpeedLimiter:vi.fn(),webhookDailyQuota:vi.fn()}));
vi.mock('../middlewares/webhook.middleware.js',()=>guards);
vi.mock('../controllers/webhook.controller.js',()=>({createHazardViaWebhook:vi.fn()}));
vi.mock('../controllers/integration_catalog.controller.js',()=>({getWebhookCategories:vi.fn()}));
vi.mock('../middlewares/validation.middleware.js',()=>({validate:()=>vi.fn()}));
vi.mock('../validators/webhook.validator.js',()=>({createHazardsWebhookBodySchema:{}}));
import router from '../routes/webhook.route.js';
import { getWebhookCategories } from '../controllers/integration_catalog.controller.js';
it('protects the read catalog with existing authentication and every webhook quota guard',()=>{
  const route:any=router.stack.find((layer:any)=>layer.route?.path==='/categories')?.route;
  expect(route).toBeDefined();expect(route?.methods.get).toBe(true);
  expect(route?.stack.map((layer:any)=>layer.handle)).toEqual([guards.requireWebhookAuth,guards.webhookBurstProtection,guards.webhookRateLimiter,guards.webhookSpeedLimiter,guards.webhookDailyQuota,getWebhookCategories]);
});

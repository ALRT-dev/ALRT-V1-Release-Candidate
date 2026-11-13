import { afterEach, expect, it, vi } from 'vitest';
import { loadEnv } from 'vite';
afterEach(()=>{vi.unstubAllEnvs();vi.unstubAllGlobals();vi.resetModules();});
it('the AWS-hosted live portal resolves its configured API without requiring a Pages Function',async()=>{
  // Vitest's TEST environment must not override the production file under test.
  vi.stubEnv('VITE_API_BASE_URL',undefined);vi.stubEnv('VITE_USE_RELAY',undefined);
  const env=loadEnv('production',process.cwd(),'VITE_');
  vi.stubEnv('VITE_API_BASE_URL',env.VITE_API_BASE_URL);
  vi.stubEnv('VITE_USE_RELAY',env.VITE_USE_RELAY);
  vi.stubGlobal('window',{location:{hostname:'admin.safetyalrt.com'}});
  const fetch=vi.fn();vi.stubGlobal('fetch',fetch);
  vi.resetModules();const {getBackendOrigin}=await import('../api/client');
  await expect(getBackendOrigin()).resolves.toBe('https://api.safetyalrt.com');
  expect(fetch).not.toHaveBeenCalled();
});

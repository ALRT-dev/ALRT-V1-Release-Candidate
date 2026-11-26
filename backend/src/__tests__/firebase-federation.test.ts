import { deleteApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { afterEach, describe, expect, it, vi } from "vitest";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { StsCredentials } from "google-auth-library/build/src/auth/stscredentials.js";
import { createFederatedFirebaseCredential, initializeFederatedFirebaseApp, withAwsMetadataJson } from "../utils/firebase_federation.util.js";

const dirs: string[] = [];
afterEach(() => { vi.restoreAllMocks(); vi.unstubAllEnvs(); for (const dir of dirs.splice(0)) rmSync(dir, {recursive:true,force:true}); });

describe("Firebase AWS federation", () => {
  it('retains Firebase Admin Firestore initialization alongside messaging credentials', async () => {
    const app=initializeFederatedFirebaseApp('unused-external-account.json','offline-test','alrt-federation-offline');
    try {
      const store=getFirestore(app);
      expect(store).toBeDefined();
      // The public Admin credential remains usable and Firestore has received
      // explicit settings before any network operation.
      expect(app.options.credential?.getAccessToken).toBeTypeOf('function');
    } finally { await deleteApp(app); }
  });
  it.each([
    'http://169.254.169.254/latest/api/token',
    'http://169.254.169.254/latest/meta-data/placement/availability-zone',
    'http://169.254.169.254/latest/meta-data/iam/security-credentials',
    'https://firebase.googleapis.com/v1beta1/projects/example',
    'http://example.com/latest/meta-data/iam/security-credentials/Role',
  ])('does not relabel non-credential response %s', async url => {
    const response=new Response('plain response',{headers:{'content-type':'text/plain'}});
    const wrapped=withAwsMetadataJson(async()=>response);
    expect(await wrapped(url)).toBe(response);
    expect(await response.text()).toBe('plain response');
  });
  it('leaves metadata errors intact instead of masking them as valid credentials', async()=>{
    const response=new Response('Unauthorized',{status:401,headers:{'content-type':'text/plain'}});
    expect(await withAwsMetadataJson(async()=>response)('http://169.254.169.254/latest/meta-data/iam/security-credentials/Role')).toBe(response);
  });
  it("signs with temporary session credentials when IMDS labels JSON as plain text", async () => {
    for (const key of ["AWS_ACCESS_KEY_ID","AWS_SECRET_ACCESS_KEY","AWS_SESSION_TOKEN"]) vi.stubEnv(key, "");
    vi.stubEnv("AWS_REGION", "ap-southeast-2");
    const dir=mkdtempSync(join(tmpdir(),"alrt-federation-test-")); dirs.push(dir);
    const file=join(dir,"external-account.json");
    writeFileSync(file,JSON.stringify({type:"external_account",audience:"//iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/test-pool/providers/aws",subject_token_type:"urn:ietf:params:aws:token-type:aws4_request",token_url:"https://sts.googleapis.com/v1/token",service_account_impersonation_url:"https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/test@example.iam.gserviceaccount.com:generateAccessToken",credential_source:{environment_id:"aws1",region_url:"http://169.254.169.254/latest/meta-data/placement/availability-zone",url:"http://169.254.169.254/latest/meta-data/iam/security-credentials",imdsv2_session_token_url:"http://169.254.169.254/latest/api/token",regional_cred_verification_url:"https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15"}}));
    let signedSessionToken: string | undefined;
    // The SDK creates a separate transport for Google STS. Replace that external
    // exchange boundary too, so no real provider is called by this test.
    vi.spyOn(StsCredentials.prototype,'exchangeToken').mockImplementation(async options => {
      const signed=JSON.parse(decodeURIComponent(options.subjectToken));
      signedSessionToken=signed.headers.find((h:{key:string})=>h.key.toLowerCase()==='x-amz-security-token')?.value;
      if(signedSessionToken!=='test-session-token') throw new Error('AWS request lost its temporary session token');
      return {access_token:'test-federated-token',expires_in:3600,token_type:'Bearer',issued_token_type:'urn:ietf:params:oauth:token-type:access_token'} as Awaited<ReturnType<StsCredentials['exchangeToken']>>;
    });
    const fakeFetch: typeof fetch = async (input,init) => {
      const url=new URL(typeof input==='string'?input:input instanceof URL?input.href:input.url);
      const json=(body:unknown)=>new Response(JSON.stringify(body),{headers:{'content-type':'application/json'}});
      if(url.hostname==='169.254.169.254') {
        if(url.pathname==='/latest/api/token') return new Response('test-imds-token');
        if(url.pathname.endsWith('/security-credentials')) return new Response('TestRole');
        if(url.pathname.endsWith('/security-credentials/TestRole')) return new Response(JSON.stringify({Code:'Success',AccessKeyId:'EXAMPLE_TEST_ACCESS_ID',SecretAccessKey:'test-only-secret',Token:'test-session-token',Expiration:new Date(Date.now()+3600000).toISOString()}),{headers:{'content-type':'text/plain'}});
      }
      if(url.hostname==='iamcredentials.googleapis.com') return json({accessToken:'test-firebase-token',expireTime:new Date(Date.now()+3600000).toISOString()});
      throw new Error('Unexpected network request in isolated test');
    };
    const credential=createFederatedFirebaseCredential(file,fakeFetch);
    const token=await credential.getAccessToken();
    expect(signedSessionToken).toBe('test-session-token');
    expect(token.access_token).toBe('test-firebase-token');
    expect(token.expires_in).toBeGreaterThan(0);
    expect(token.expires_in).toBeLessThanOrEqual(3600);
  });
});

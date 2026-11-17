import { getFirestore } from "firebase-admin/firestore";
import { GoogleAuth } from "google-auth-library";
import { applicationDefault, initializeApp, type Credential } from "firebase-admin/app";

// Match Firebase Admin's own ADC scopes so this credential remains usable for
// the same Firebase operations; IAM still limits what the identity may do.
const FIREBASE_SCOPES = [
  "https://www.googleapis.com/auth/cloud-platform",
  "https://www.googleapis.com/auth/firebase.database",
  "https://www.googleapis.com/auth/firebase.messaging",
  "https://www.googleapis.com/auth/identitytoolkit",
  "https://www.googleapis.com/auth/userinfo.email",
];

/** IMDS can label its role credential JSON text/plain. Only correct that
 * response: token, region and role-name metadata must remain plain text. */
export function withAwsMetadataJson(fetchImplementation: typeof fetch): typeof fetch {
  return async (input, init) => {
    const response = await fetchImplementation(input, init);
    const url = new URL(typeof input === "string" ? input : input instanceof URL ? input.href : input.url);
    const method = init?.method ?? (input instanceof Request ? input.method : "GET");
    if (
      method.toUpperCase() !== "GET" || !response.ok || url.protocol !== "http:"
      || !["169.254.169.254", "[fd00:ec2::254]"].includes(url.hostname)
      || !/^\/latest\/meta-data\/iam\/security-credentials\/[^/]+$/.test(url.pathname)
      || !/^text\/plain(?:;|$)/i.test(response.headers.get("content-type") ?? "")
    ) return response;
    const headers = new Headers(response.headers);
    headers.set("content-type", "application/json");
    return new Response(await response.text(), {
      status: response.status, statusText: response.statusText, headers,
    });
  };
}

export function createFederatedFirebaseCredential(
  keyFilename: string,
  fetchImplementation: typeof fetch = globalThis.fetch,
): Credential & { federatedAuth: GoogleAuth } {
  const auth = new GoogleAuth({
    keyFilename,
    scopes: FIREBASE_SCOPES,
    clientOptions: { transporterOptions: { fetchImplementation: withAwsMetadataJson(fetchImplementation) } },
  });
  // Retain Admin's ADC class identity: Firestore rejects a plain Credential.
  // Its separate GAX client must receive federatedAuth through settings below.
  const credential = applicationDefault();
  credential.getAccessToken = async () => {
      const client = await auth.getClient();
      await client.getAccessToken();
      const { access_token, expiry_date } = client.credentials;
      const expires_in = Math.floor(((expiry_date ?? 0) - Date.now()) / 1000);
      if (!access_token || expires_in <= 0) {
        throw new Error("Firebase federation did not return an unexpired access token.");
      }
      return { access_token, expires_in };
  };
  return Object.assign(credential, { federatedAuth: auth });
}

/** Initialize both Firebase Admin and Firestore with the same federated auth. */
export function initializeFederatedFirebaseApp(keyFilename: string, projectId?: string, name?: string) {
  const credential = createFederatedFirebaseCredential(keyFilename);
  const app = initializeApp({credential, ...(projectId ? {projectId} : {})}, name);
  // Firestore uses a separate GAX auth path. Configure it before first use.
  getFirestore(app).settings({auth: credential.federatedAuth});
  return app;
}

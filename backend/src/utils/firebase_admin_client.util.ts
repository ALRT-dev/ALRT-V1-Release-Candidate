import { fileURLToPath } from "node:url";
import admin, { type ServiceAccount } from "firebase-admin";
import serviceAccountFile from "../../serviceAccountKey.json" with { type: "json" };

// serviceAccountKey.json is either a classic service account key (live) or,
// where the Google organisation forbids downloadable keys (TEST), a
// workload identity federation config ("type": "external_account") that
// lets this server sign in with its own AWS role. The federation config
// holds no secret and carries no project id, so FIREBASE_PROJECT_ID names
// the Firebase project to send through.
//
// IMPORTANT: FIREBASE_PROJECT_ID in .env.test MUST match the Firebase project
// the app is built against (alrt-a6539 for both prod + dev flavours).
// If they differ, push tokens are silently undeliverable.
const credentialFile = serviceAccountFile as Record<string, unknown>;

if (!admin.apps.length) {
  if (credentialFile.type === "external_account") {
    process.env.GOOGLE_APPLICATION_CREDENTIALS ??= fileURLToPath(
      new URL("../../serviceAccountKey.json", import.meta.url),
    );
    const envProj = process.env.FIREBASE_PROJECT_ID ?? undefined;
    if (!envProj) {
      console.warn("ALRT BACKEND: FIREBASE_PROJECT_ID not set — push will fail on TEST (workload-identity path)");
    } else {
      console.log(`ALRT BACKEND: Firebase initialising with projectId=${envProj}`);
    }
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      ...(envProj ? { projectId: envProj } : {}),
    });
  } else {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccountFile as ServiceAccount),
    });
  }
}

export const firebaseAdmin = admin;

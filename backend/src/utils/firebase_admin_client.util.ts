import { fileURLToPath } from "node:url";
import admin, { type ServiceAccount } from "firebase-admin";
import serviceAccountFile from "../../serviceAccountKey.json" with { type: "json" };

// serviceAccountKey.json is either a classic service account key (live) or,
// where the Google organisation forbids downloadable keys (TEST), a
// workload identity federation config ("type": "external_account") that
// lets this server sign in with its own AWS role. The federation config
// holds no secret and carries no project id, so FIREBASE_PROJECT_ID names
// the Firebase project to send through.
const credentialFile = serviceAccountFile as Record<string, unknown>;

if (!admin.apps.length) {
  if (credentialFile.type === "external_account") {
    process.env.GOOGLE_APPLICATION_CREDENTIALS ??= fileURLToPath(
      new URL("../../serviceAccountKey.json", import.meta.url),
    );
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      ...(process.env.FIREBASE_PROJECT_ID
        ? { projectId: process.env.FIREBASE_PROJECT_ID }
        : {}),
    });
  } else {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccountFile as ServiceAccount),
    });
  }
}

export const firebaseAdmin = admin;

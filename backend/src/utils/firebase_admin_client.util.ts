import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import admin, { type ServiceAccount } from "firebase-admin";

// The Firebase service-account/workload-identity file is a deployment
// artifact and must not be committed to this public repository. Load it at
// runtime when present so TypeScript builds and CI do not require the secret
// file. In environments without a file, use Application Default Credentials
// (for example, a workload identity or instance role).
const credentialPath = fileURLToPath(
  new URL("../../serviceAccountKey.json", import.meta.url),
);
const credentialFile: Record<string, unknown> | null = existsSync(credentialPath)
  ? (JSON.parse(readFileSync(credentialPath, "utf8")) as Record<string, unknown>)
  : null;

if (!admin.apps.length) {
  if (credentialFile?.type === "external_account") {
    process.env.GOOGLE_APPLICATION_CREDENTIALS ??= credentialPath;
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      ...(process.env.FIREBASE_PROJECT_ID
        ? { projectId: process.env.FIREBASE_PROJECT_ID }
        : {}),
    });
  } else if (credentialFile) {
    admin.initializeApp({
      credential: admin.credential.cert(credentialFile as ServiceAccount),
    });
  } else {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      ...(process.env.FIREBASE_PROJECT_ID
        ? { projectId: process.env.FIREBASE_PROJECT_ID }
        : {}),
    });
  }
}

export const firebaseAdmin = admin;

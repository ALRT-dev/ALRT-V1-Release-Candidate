import { initializeApp, type FirebaseApp } from "firebase/app";
import {
  initializeAppCheck,
  ReCaptchaV3Provider,
  type AppCheck,
} from "firebase/app-check";
import { getAuth, type Auth } from "firebase/auth";

const config = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
};

const appCheckSiteKey = import.meta.env.VITE_FIREBASE_APP_CHECK_SITE_KEY;

/**
 * Whether a real Firebase Web App has been registered and its config
 * supplied. No Firebase Web App exists for this project yet (a Firebase
 * Console action, not something this build can create), so every
 * VITE_FIREBASE_* value is blank until that's done - see .env.example.
 * Callers must check this before touching Firebase at all.
 */
export const isFirebaseConfigured = (): boolean =>
  Boolean(config.apiKey && config.authDomain && config.projectId && config.appId);

let app: FirebaseApp | null = null;
let auth: Auth | null = null;
let appCheck: AppCheck | null = null;

/**
 * Initializes the Firebase Web SDK (App + Auth + App Check), once, only
 * when real config is present. Throws if called without configuration -
 * callers must check isFirebaseConfigured() first.
 */
export const getFirebaseAuth = (): Auth => {
  if (!isFirebaseConfigured()) {
    throw new Error("Firebase is not configured for this environment.");
  }
  if (!app) {
    app = initializeApp(config);
  }
  if (!appCheck && appCheckSiteKey) {
    appCheck = initializeAppCheck(app, {
      provider: new ReCaptchaV3Provider(appCheckSiteKey),
      isTokenAutoRefreshEnabled: true,
    });
  }
  if (!auth) {
    auth = getAuth(app);
  }
  return auth;
};

export const getFirebaseApp = (): FirebaseApp => {
  if (!app) {
    throw new Error("Firebase has not been initialized yet.");
  }
  return app;
};

import { signInWithCustomToken } from "firebase/auth";
import { getFunctions, httpsCallable, type FunctionsError } from "firebase/functions";
import { apiPost } from "../api/client";
import { getFirebaseApp, getFirebaseAuth, isFirebaseConfigured } from "./firebase";

// Matches ALRT-dev/askalrt's functions/src/askalrt/askAlrt.ts AskRequest -
// that Cloud Function is reused unchanged, so this shape must match its
// real contract exactly, not the (currently mismatched) `nearbyAlerts`
// field the mobile app sends - the function only reads `context` (a
// string), never `nearbyAlerts`.
export interface AskAlrtRequest {
  question: string;
  history?: { role: "user" | "assistant"; content: string }[];
  context?: string;
  language?: string;
}

export type AskAlrtSource = "library" | "emergency_lookup" | "ai";

export interface AskAlrtResponse {
  answer: string;
  source: AskAlrtSource;
  usedAI: boolean;
}

export class AskAlrtRateLimitedError extends Error {
  constructor() {
    super("Daily AI question limit reached. Library and emergency-number answers still work.");
    this.name = "AskAlrtRateLimitedError";
  }
}

let signedIn = false;

const ensureSignedIn = async (): Promise<void> => {
  if (signedIn) return;
  const auth = getFirebaseAuth();
  const { token } = await apiPost<{ token: string }>("/api/admin/ask-alrt/firebase-token");
  await signInWithCustomToken(auth, token);
  signedIn = true;
};

/**
 * Calls the existing askAlrt Cloud Function (ALRT-dev/askalrt, unchanged).
 * Throws AskAlrtRateLimitedError for the daily-quota case; any other
 * failure (App Check rejection, not configured, network loss) throws
 * normally for the caller to show as a generic failure state.
 */
export const askAlrt = async (request: AskAlrtRequest): Promise<AskAlrtResponse> => {
  if (!isFirebaseConfigured()) {
    throw new Error(
      "Ask ALRT needs a Firebase Web App to be configured for this environment first.",
    );
  }
  await ensureSignedIn();
  const functions = getFunctions(getFirebaseApp(), "us-central1");
  const callable = httpsCallable<AskAlrtRequest, AskAlrtResponse>(functions, "askAlrt");
  try {
    const result = await callable(request);
    return result.data;
  } catch (error) {
    const code = (error as FunctionsError | undefined)?.code;
    if (code === "functions/resource-exhausted") {
      throw new AskAlrtRateLimitedError();
    }
    throw error;
  }
};

import { ApiError, apiPost } from "../api/client";

// Matches backend/src/validators/admin/ask_alrt_content.validator.ts
// (askAlrtBodySchema). Ask ALRT runs inside the ALRT backend; this page asks
// the same engine the app uses, without counting against anyone's allowance.
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

/**
 * Asks the backend's Ask ALRT engine. Throws AskAlrtRateLimitedError for the
 * daily-quota case; any other failure throws normally for the caller to show
 * as a generic failure state.
 */
export const askAlrt = async (request: AskAlrtRequest): Promise<AskAlrtResponse> => {
  try {
    return await apiPost<AskAlrtResponse>("/api/admin/ask-alrt/ask", request);
  } catch (error) {
    if (error instanceof ApiError && error.status === 429) {
      throw new AskAlrtRateLimitedError();
    }
    throw error;
  }
};

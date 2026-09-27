import { clearTokens, loadTokens, saveTokens } from "./tokenStorage";

const BASE_URL = import.meta.env.VITE_API_BASE_URL;

/** Thrown for any non-2xx response. Screens branch on `status` to show the
 * right state (permission denied, not found, validation message, etc). */
export class ApiError extends Error {
  status: number;
  body: unknown;

  constructor(status: number, message: string, body: unknown) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.body = body;
  }
}

/** Set once by AuthProvider. Called when a request's token could not be
 * refreshed - the session is gone and every screen should return to
 * /login, not just the one screen that happened to make the failing call. */
let onSessionExpired: (() => void) | null = null;
export const registerSessionExpiredHandler = (handler: () => void): void => {
  onSessionExpired = handler;
};

// Concurrent requests that all hit a 401 at once must not each fire their
// own refresh call - dedupe into a single in-flight refresh.
let refreshInFlight: Promise<string | null> | null = null;

const refreshAccessToken = async (): Promise<string | null> => {
  const tokens = loadTokens();
  if (!tokens) return null;

  if (!refreshInFlight) {
    refreshInFlight = (async () => {
      try {
        const res = await fetch(`${BASE_URL}/api/admin/auth/refresh-token`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ refreshToken: tokens.refreshToken }),
        });
        if (!res.ok) return null;
        const data = (await res.json()) as { accessToken: string };
        saveTokens({ accessToken: data.accessToken, refreshToken: tokens.refreshToken });
        return data.accessToken;
      } catch {
        return null;
      } finally {
        refreshInFlight = null;
      }
    })();
  }
  return refreshInFlight;
};

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
  body?: unknown;
  /** Internal - marks a request as already-retried-after-refresh. */
  _isRetry?: boolean;
}

const parseBody = async (res: Response): Promise<unknown> => {
  const text = await res.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
};

const errorMessageFrom = (body: unknown, fallback: string): string => {
  if (body && typeof body === "object" && "error" in body) {
    const err = (body as { error?: unknown }).error;
    if (typeof err === "string") return err;
  }
  return fallback;
};

export const apiRequest = async <T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> => {
  const tokens = loadTokens();
  const isAuthRoute = path.startsWith("/api/admin/auth/login");

  const res = await fetch(`${BASE_URL}${path}`, {
    method: options.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(tokens && !isAuthRoute
        ? { Authorization: `Bearer ${tokens.accessToken}` }
        : {}),
    },
    ...(options.body !== undefined ? { body: JSON.stringify(options.body) } : {}),
  });

  if (res.status === 401 && !isAuthRoute && !options._isRetry && tokens) {
    const newAccessToken = await refreshAccessToken();
    if (newAccessToken) {
      return apiRequest<T>(path, { ...options, _isRetry: true });
    }
    // Refresh failed - the session is genuinely over.
    clearTokens();
    onSessionExpired?.();
    const body = await parseBody(res);
    throw new ApiError(401, errorMessageFrom(body, "Session expired"), body);
  }

  const body = await parseBody(res);

  if (!res.ok) {
    throw new ApiError(
      res.status,
      errorMessageFrom(body, `Request failed (${res.status})`),
      body,
    );
  }

  return body as T;
};

export const apiGet = <T>(path: string): Promise<T> => apiRequest<T>(path);

export const apiPost = <T>(path: string, body?: unknown): Promise<T> =>
  apiRequest<T>(path, { method: "POST", body });

export const apiPut = <T>(path: string, body?: unknown): Promise<T> =>
  apiRequest<T>(path, { method: "PUT", body });

export const apiPatch = <T>(path: string, body?: unknown): Promise<T> =>
  apiRequest<T>(path, { method: "PATCH", body });

export const apiDelete = <T>(path: string): Promise<T> =>
  apiRequest<T>(path, { method: "DELETE" });

import { clearTokens, loadTokens, saveTokens } from "./tokenStorage";

/**
 * On Cloudflare Pages (any *.pages.dev address, including branch previews)
 * requests go to this site's own /api, which the Pages Function in
 * functions/api relays to the backend. The browser then never makes a
 * cross-site call, so a preview address works without the backend having
 * to list it in CORS_ALLOWED_ORIGINS. Anywhere else (local dev, a custom
 * domain) the configured backend is called directly, as before.
 *
 * Through the relay, every request carries this build's VITE_API_BASE_URL
 * in X-ALRT-API-Origin. The relay uses it when the Pages project has no
 * API_ORIGIN set and it is exactly the live or TEST backend, so a
 * production build never silently talks to TEST.
 */
const USES_RELAY =
  typeof window !== "undefined" &&
  window.location.hostname.endsWith(".pages.dev");

const BUILD_API_BASE = (import.meta.env.VITE_API_BASE_URL ?? "").replace(/\/+$/, "");

const BASE_URL = USES_RELAY ? "" : BUILD_API_BASE;

const RELAY_HEADERS: Record<string, string> =
  USES_RELAY && BUILD_API_BASE ? { "X-ALRT-API-Origin": BUILD_API_BASE } : {};

let resolvedOrigin: Promise<string> | null = null;

/**
 * The backend origin this portal actually talks to, for anything that must
 * name it outside the portal (such as the n8n test workflow). Off Pages it
 * is the build's VITE_API_BASE_URL; through the relay it is whatever the
 * relay resolved (API_ORIGIN, the allowed build origin, or TEST).
 */
export const getBackendOrigin = (): Promise<string> => {
  if (!USES_RELAY) return Promise.resolve(BUILD_API_BASE);
  if (!resolvedOrigin) {
    resolvedOrigin = (async () => {
      try {
        const res = await fetch("/api/__alrt-relay-origin", { headers: RELAY_HEADERS });
        if (!res.ok) throw new Error(`relay origin ${res.status}`);
        const data = (await res.json()) as { origin?: unknown };
        if (typeof data.origin !== "string" || !data.origin) throw new Error("no origin");
        return data.origin;
      } catch (error) {
        resolvedOrigin = null;
        throw error;
      }
    })();
  }
  return resolvedOrigin;
};

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

/** Error code the backend sends (with a 403) on every admin route except
 * change-password, GET /users/me and logout while the signed-in admin
 * still has mustChangePassword set. */
export const PASSWORD_CHANGE_REQUIRED = "PASSWORD_CHANGE_REQUIRED";

export const isPasswordChangeRequired = (status: number, body: unknown): boolean =>
  status === 403 &&
  Boolean(body) &&
  typeof body === "object" &&
  (body as { code?: unknown }).code === PASSWORD_CHANGE_REQUIRED;

/** Set once by AuthProvider. Called when any request comes back with
 * PASSWORD_CHANGE_REQUIRED, so the app routes to the Change Password
 * screen instead of showing a permission error. */
let onPasswordChangeRequired: (() => void) | null = null;
export const registerPasswordChangeRequiredHandler = (handler: () => void): void => {
  onPasswordChangeRequired = handler;
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
          headers: { "Content-Type": "application/json", ...RELAY_HEADERS },
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
      ...RELAY_HEADERS,
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
    if (isPasswordChangeRequired(res.status, body)) onPasswordChangeRequired?.();
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

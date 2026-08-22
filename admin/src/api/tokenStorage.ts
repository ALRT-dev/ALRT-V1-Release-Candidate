// Token storage. The backend only issues bearer JWTs (no httpOnly-cookie
// session option), so localStorage is the realistic place to keep them
// across page reloads - there is no more private browser-side option
// available given the backend's actual auth contract. This module is the
// ONLY place that touches storage or reads/writes the raw token strings,
// so a security review has one place to check.
export interface StoredTokens {
  accessToken: string;
  refreshToken: string;
}

const STORAGE_KEY = "alrt_admin_tokens";

export const loadTokens = (): StoredTokens | null => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as Partial<StoredTokens>;
    if (!parsed.accessToken || !parsed.refreshToken) return null;
    return { accessToken: parsed.accessToken, refreshToken: parsed.refreshToken };
  } catch {
    return null;
  }
};

export const saveTokens = (tokens: StoredTokens): void => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(tokens));
};

export const clearTokens = (): void => {
  localStorage.removeItem(STORAGE_KEY);
};

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";
import { ApiError, registerSessionExpiredHandler } from "../api/client";
import { clearTokens, loadTokens, saveTokens } from "../api/tokenStorage";
import { getMyProfile, login as loginRequest, logout as logoutRequest } from "../api/resources";
import type { AdminProfile } from "../api/types";

interface AuthState {
  status: "loading" | "authenticated" | "unauthenticated";
  admin: AdminProfile | null;
}

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  /** UX-only convenience for hiding controls a role can't use. The backend
   * is the actual authority - every screen must still handle a 403 from
   * the API gracefully, never assume this check was sufficient. */
  hasRole: (...roles: AdminProfile["role"][]) => boolean;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [state, setState] = useState<AuthState>({ status: "loading", admin: null });

  useEffect(() => {
    registerSessionExpiredHandler(() => {
      setState({ status: "unauthenticated", admin: null });
    });
  }, []);

  useEffect(() => {
    const tokens = loadTokens();
    if (!tokens) {
      setState({ status: "unauthenticated", admin: null });
      return;
    }
    getMyProfile()
      .then((admin) => setState({ status: "authenticated", admin }))
      .catch(() => {
        clearTokens();
        setState({ status: "unauthenticated", admin: null });
      });
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const result = await loginRequest(email, password);
    saveTokens({ accessToken: result.accessToken, refreshToken: result.refreshToken });
    try {
      const admin = await getMyProfile();
      setState({ status: "authenticated", admin });
    } catch (error) {
      clearTokens();
      setState({ status: "unauthenticated", admin: null });
      throw error;
    }
  }, []);

  const logout = useCallback(async () => {
    try {
      await logoutRequest();
    } catch (error) {
      // Logout is best-effort server-side (Stage 7B: no token revocation
      // exists yet, see V1_RECONCILIATION_REPORT.md §22.3) - the client
      // side must clear its own tokens regardless of whether this call
      // succeeds, so a network error here never traps the admin logged in.
      if (!(error instanceof ApiError)) {
        console.error("Logout request failed", error);
      }
    }
    clearTokens();
    setState({ status: "unauthenticated", admin: null });
  }, []);

  const hasRole = useCallback(
    (...roles: AdminProfile["role"][]) => {
      if (!state.admin) return false;
      return roles.includes(state.admin.role);
    },
    [state.admin],
  );

  const value = useMemo<AuthContextValue>(
    () => ({ ...state, login, logout, hasRole }),
    [state, login, logout, hasRole],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextValue => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
};

import { Navigate, useLocation } from "react-router-dom";
import type { ReactNode } from "react";
import { useAuth } from "./AuthContext";
import { LoadingState } from "../components/AsyncState";

export const CHANGE_PASSWORD_PATH = "/change-password";

export const RequireAuth = ({ children }: { children: ReactNode }) => {
  const { status, mustChangePassword } = useAuth();
  const location = useLocation();

  if (status === "loading") {
    return <LoadingState label="Checking session..." />;
  }

  if (status === "unauthenticated") {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // First login with a temporary password: the backend refuses every other
  // admin route until it is changed, so nothing else is reachable here
  // either. `from` lets the change-password screen continue to wherever
  // the admin was going.
  if (mustChangePassword && location.pathname !== CHANGE_PASSWORD_PATH) {
    return <Navigate to={CHANGE_PASSWORD_PATH} state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

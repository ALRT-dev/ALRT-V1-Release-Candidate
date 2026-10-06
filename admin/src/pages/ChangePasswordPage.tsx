import { useState } from "react";
import type { FormEvent } from "react";
import { Navigate, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { CHANGE_PASSWORD_PATH } from "../auth/RequireAuth";
import { ApiError } from "../api/client";
import { PASSWORD_RULES, passwordChangeProblems } from "../lib/passwordRules";

/** Shown on its own (no sidebar) so nothing else can be opened while the
 * backend still requires a new password. Also reachable later at
 * /change-password for a voluntary change. */
export const ChangePasswordPage = () => {
  const { admin, mustChangePassword, changePassword, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const from = (location.state as { from?: { pathname?: string } } | null)?.from?.pathname;
  const continueTo = from && from !== CHANGE_PASSWORD_PATH ? from : "/";

  if (!admin) return <Navigate to="/login" replace />;

  const problems = passwordChangeProblems({ currentPassword, newPassword, confirmPassword });

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (problems.length > 0) return;
    setError(null);
    setSubmitting(true);
    try {
      await changePassword(currentPassword, newPassword, confirmPassword);
      navigate(continueTo, { replace: true });
    } catch (err) {
      if (err instanceof ApiError && err.status === 401) {
        setError("Current password is incorrect.");
      } else {
        setError(err instanceof Error ? err.message : "Password change failed.");
      }
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="login-page">
      <div className="card login-card">
        <h1>Change password</h1>
        <p>
          {mustChangePassword
            ? "You signed in with a temporary password. Choose a new one to continue. Nothing else in the portal opens until this is done."
            : "Choose a new password for your admin account."}
        </p>
        <form onSubmit={(event) => void handleSubmit(event)}>
          {error && (
            <div className="form-error" role="alert">
              {error}
            </div>
          )}
          <div className="field">
            <label htmlFor="current-password">Current password</label>
            <input
              id="current-password"
              type="password"
              autoComplete="current-password"
              required
              value={currentPassword}
              onChange={(event) => setCurrentPassword(event.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="new-password">New password</label>
            <input
              id="new-password"
              type="password"
              autoComplete="new-password"
              required
              value={newPassword}
              onChange={(event) => setNewPassword(event.target.value)}
            />
          </div>
          <div className="field">
            <label htmlFor="confirm-password">Confirm new password</label>
            <input
              id="confirm-password"
              type="password"
              autoComplete="new-password"
              required
              value={confirmPassword}
              onChange={(event) => setConfirmPassword(event.target.value)}
            />
            {confirmPassword !== "" && confirmPassword !== newPassword && (
              <span style={{ fontSize: 12, color: "var(--color-danger)" }}>
                New passwords do not match.
              </span>
            )}
          </div>
          <ul aria-label="Password rules" style={{ fontSize: 12, paddingLeft: 18 }}>
            {PASSWORD_RULES.map((rule) => {
              const met = rule.test(newPassword);
              return (
                <li
                  key={rule.label}
                  style={{ color: met ? "var(--color-text-muted)" : undefined }}
                >
                  {rule.label}
                  {met ? " (done)" : ""}
                </li>
              );
            })}
            <li>Different from your current password</li>
          </ul>
          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: "100%" }}
            disabled={submitting || problems.length > 0}
          >
            {submitting ? "Saving..." : "Change password"}
          </button>
          <button
            type="button"
            className="btn"
            style={{ width: "100%", marginTop: 8 }}
            onClick={() => {
              if (mustChangePassword) void logout();
              else navigate(continueTo);
            }}
          >
            {mustChangePassword ? "Log out" : "Cancel"}
          </button>
        </form>
      </div>
    </div>
  );
};

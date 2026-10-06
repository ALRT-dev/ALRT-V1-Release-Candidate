import { useCallback, useState } from "react";
import type { FormEvent } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { createAdminAccount, listAdminAccounts, setAdminAccountActive } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { BooleanBadge } from "../components/StatusBadge";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { ApiError } from "../api/client";
import type { AdminAccountListItem, AdminRole } from "../api/types";

const emptyForm = { email: "", password: "", name: "", role: "moderator" as AdminRole };

export const AdminAccountsPage = () => {
  const { admin, hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canManage = hasRole("superAdmin");

  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [formError, setFormError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [toggleTarget, setToggleTarget] = useState<AdminAccountListItem | null>(null);

  const fetcher = useCallback(() => listAdminAccounts(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  const handleCreate = async (event: FormEvent) => {
    event.preventDefault();
    setFormError(null);
    setSubmitting(true);
    try {
      await createAdminAccount({
        email: form.email,
        password: form.password,
        name: form.name || undefined,
        role: form.role,
      });
      notifySuccess(`Created admin account "${form.email}".`);
      setShowCreate(false);
      setForm(emptyForm);
      refetch();
    } catch (err) {
      setFormError(err instanceof ApiError ? err.message : "Could not create account.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleToggleActive = async () => {
    if (!toggleTarget) return;
    try {
      await setAdminAccountActive(toggleTarget.id, !toggleTarget.isActive);
      notifySuccess(
        `${toggleTarget.isActive ? "Deactivated" : "Reactivated"} "${toggleTarget.email}".`,
      );
      setToggleTarget(null);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Could not update account.");
      setToggleTarget(null);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Admin Accounts</h1>
          <p>
            Internal administrator accounts (moderator / admin / super
            admin) - distinct from app users. Only super admins can create
            or deactivate an account; every other role can view the list.
          </p>
        </div>
        {canManage && (
          <button type="button" className="btn btn-primary" onClick={() => setShowCreate(true)}>
            New admin account
          </button>
        )}
      </div>

      {loading && <LoadingState label="Loading admin accounts..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No admin accounts found." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Email</th>
              <th>Name</th>
              <th>Role</th>
              <th>Status</th>
              <th>Last login</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((account) => (
              <tr key={account.id}>
                <td>{account.email}</td>
                <td>{account.name ?? "-"}</td>
                <td>{account.role}</td>
                <td>
                  <BooleanBadge value={account.isActive} trueLabel="Active" falseLabel="Disabled" />
                </td>
                <td>
                  {account.lastLoginAt
                    ? new Date(account.lastLoginAt).toLocaleString()
                    : "Never"}
                </td>
                <td>
                  {canManage && account.id !== admin?.id && (
                    <button
                      type="button"
                      className={account.isActive ? "btn btn-sm btn-danger" : "btn btn-sm"}
                      onClick={() => setToggleTarget(account)}
                    >
                      {account.isActive ? "Deactivate" : "Reactivate"}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {/* No endpoint exists to edit an existing admin's role/email, or to
          force a password reset (backend/src/routes/admin/user.route.ts
          only supports create + activate/deactivate) - not faked here.
          See V1_RECONCILIATION_REPORT.md §22.4/§24. */}
      <div className="card" style={{ marginTop: 16, fontSize: 13 }}>
        There is no backend capability yet to edit an existing admin's
        role/email, or to force a password reset - only account creation
        and activate/deactivate exist. Not built here since the endpoint
        doesn't exist.
      </div>

      {showCreate && (
        <div className="modal-backdrop" onClick={() => setShowCreate(false)}>
          <form
            className="modal"
            onClick={(event) => event.stopPropagation()}
            onSubmit={(event) => void handleCreate(event)}
          >
            <h2>New admin account</h2>
            {formError && (
              <div className="form-error" role="alert">
                {formError}
              </div>
            )}
            <div className="field">
              <label htmlFor="new-admin-email">Email</label>
              <input
                id="new-admin-email"
                type="email"
                required
                value={form.email}
                onChange={(event) => setForm({ ...form, email: event.target.value })}
              />
            </div>
            <div className="field">
              <label htmlFor="new-admin-name">Name</label>
              <input
                id="new-admin-name"
                value={form.name}
                onChange={(event) => setForm({ ...form, name: event.target.value })}
              />
            </div>
            <div className="field">
              <label htmlFor="new-admin-password">Temporary password</label>
              <input
                id="new-admin-password"
                type="password"
                required
                minLength={12}
                value={form.password}
                onChange={(event) => setForm({ ...form, password: event.target.value })}
              />
              <span style={{ fontSize: 11, color: "var(--color-text-muted)" }}>
                12+ chars, upper/lower/number/symbol. The new admin must
                change it on first login (mustChangePassword defaults true).
              </span>
            </div>
            <div className="field">
              <label htmlFor="new-admin-role">Role</label>
              <select
                id="new-admin-role"
                value={form.role}
                onChange={(event) => setForm({ ...form, role: event.target.value as AdminRole })}
              >
                <option value="moderator">Moderator</option>
                <option value="admin">Admin</option>
                <option value="superAdmin">Super Admin</option>
              </select>
            </div>
            <div className="modal-actions">
              <button type="button" className="btn" onClick={() => setShowCreate(false)}>
                Cancel
              </button>
              <button type="submit" className="btn btn-primary" disabled={submitting}>
                Create
              </button>
            </div>
          </form>
        </div>
      )}

      {toggleTarget && (
        <ConfirmDialog
          title={toggleTarget.isActive ? "Deactivate admin" : "Reactivate admin"}
          description={
            toggleTarget.isActive
              ? `Deactivate "${toggleTarget.email}"? They will immediately lose admin access.`
              : `Reactivate "${toggleTarget.email}"?`
          }
          confirmLabel={toggleTarget.isActive ? "Deactivate" : "Reactivate"}
          danger={toggleTarget.isActive}
          onConfirm={() => void handleToggleActive()}
          onCancel={() => setToggleTarget(null)}
        />
      )}
    </div>
  );
};

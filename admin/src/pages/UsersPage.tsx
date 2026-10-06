import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listAppUsers, requestAppUserDeletion, restoreAppUser } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { BooleanBadge } from "../components/StatusBadge";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { ApiError } from "../api/client";
import type { AdminAppUser } from "../api/types";

export const UsersPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const [deleteTarget, setDeleteTarget] = useState<AdminAppUser | null>(null);

  const fetcher = useCallback(
    () => listAppUsers({ search: search || undefined, pageSize: 50 }),
    [search],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [search]);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      await requestAppUserDeletion(deleteTarget.id);
      notifySuccess(`Scheduled deletion for "${deleteTarget.email}" (30 day grace period).`);
      setDeleteTarget(null);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Request failed.");
      setDeleteTarget(null);
    }
  };

  const handleRestore = async (user: AdminAppUser) => {
    try {
      await restoreAppUser(user.id);
      notifySuccess(`Cancelled scheduled deletion for "${user.email}".`);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Restore failed.");
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Users</h1>
          <p>App user accounts. Search by email, name, or location.</p>
        </div>
      </div>

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        {/* GET /api/admin/users/app-users does not select plan/planExpiresAt
            or family membership (backend/src/services/app_user.admin.
            service.ts's APP_USER_SELECT) - per instruction, this is not
            queried directly from the database to work around that. */}
        ALRT+ entitlement/plan status and family circle membership are not
        currently exposed by the Admin API for app users - omitted here
        rather than queried directly from the database. See
        V1_RECONCILIATION_REPORT.md §24.
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Search users..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>

      {loading && <LoadingState label="Loading users..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.users.length === 0 && (
        <EmptyState label="No users match this search." />
      )}
      {!loading && !error && data && data.users.length > 0 && (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>Email</th>
                <th>Name</th>
                <th>Location</th>
                <th>XP</th>
                <th>Reports</th>
                <th>Account status</th>
                <th>Joined</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {data.users.map((user) => (
                <tr key={user.id}>
                  <td>{user.email}</td>
                  <td>{user.name ?? "-"}</td>
                  <td>{user.locationName ?? "-"}</td>
                  <td>{user.xpPoints}</td>
                  <td>{user._count.hazardsReported}</td>
                  <td>
                    <BooleanBadge
                      value={!user.deletionRequestedAt}
                      trueLabel="Active"
                      falseLabel="Deletion pending"
                    />
                  </td>
                  <td>{new Date(user.createdAt).toLocaleDateString()}</td>
                  <td>
                    {canWrite && !user.deletionRequestedAt && (
                      <button
                        type="button"
                        className="btn btn-sm btn-danger"
                        onClick={() => setDeleteTarget(user)}
                      >
                        Delete
                      </button>
                    )}
                    {canWrite && user.deletionRequestedAt && (
                      <button
                        type="button"
                        className="btn btn-sm"
                        onClick={() => void handleRestore(user)}
                      >
                        Restore
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <p style={{ fontSize: 12, color: "var(--color-text-muted)" }}>
            Showing {data.users.length} of {data.total} users.
          </p>
        </>
      )}

      {deleteTarget && (
        <ConfirmDialog
          title="Delete user account"
          description={`Schedule "${deleteTarget.email}" for deletion? This starts a 30 day grace period (matches the app's own account-deletion rule) and can be reversed with Restore until then.`}
          confirmLabel="Schedule deletion"
          danger
          onConfirm={() => void handleDelete()}
          onCancel={() => setDeleteTarget(null)}
        />
      )}
    </div>
  );
};

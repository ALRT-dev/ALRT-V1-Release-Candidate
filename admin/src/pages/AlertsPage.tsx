import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { deleteHazard, listHazards } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ReviewStatusBadge, SeverityBadge } from "../components/StatusBadge";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { HazardDetailModal } from "../components/HazardDetailModal";
import { ApiError } from "../api/client";
import type { AdminHazard, HazardReviewStatus } from "../api/types";

export const AlertsPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const [reviewStatus, setReviewStatus] = useState<HazardReviewStatus | "">("");
  const [origin, setOrigin] = useState<"" | "official" | "community">("");
  const [selected, setSelected] = useState<AdminHazard | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<AdminHazard | null>(null);

  const fetcher = useCallback(
    () =>
      listHazards({
        searchString: search || undefined,
        reviewStatus: reviewStatus || undefined,
        userReported: origin === "" ? undefined : origin === "community",
        pageSize: 100,
      }),
    [search, reviewStatus, origin],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [search, reviewStatus, origin]);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      await deleteHazard(deleteTarget.id);
      notifySuccess(`Deleted "${deleteTarget.title}".`);
      setDeleteTarget(null);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Delete failed.");
      setDeleteTarget(null);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Alerts</h1>
          <p>Search and inspect hazards/alerts across all sources.</p>
        </div>
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Search title/description..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
        <select
          value={reviewStatus}
          onChange={(event) => setReviewStatus(event.target.value as HazardReviewStatus | "")}
        >
          <option value="">All statuses</option>
          <option value="pending">Pending</option>
          <option value="accepted">Accepted</option>
          <option value="rejected">Rejected</option>
        </select>
        <select
          value={origin}
          onChange={(event) => setOrigin(event.target.value as typeof origin)}
        >
          <option value="">Official + Community</option>
          <option value="official">Official only</option>
          <option value="community">Community only</option>
        </select>
      </div>

      {loading && <LoadingState label="Loading alerts..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No alerts match this search/filter." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Type</th>
              <th>Severity</th>
              <th>Source</th>
              <th>Status</th>
              <th>Corroboration</th>
              <th>Created</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((hazard) => (
              <tr key={hazard.id}>
                <td>{hazard.title}</td>
                <td>{hazard.sourceId ? "Official" : "Community"}</td>
                <td>
                  <SeverityBadge severity={hazard.severity} />
                </td>
                <td>{hazard.sourceName ?? hazard.reportedByName ?? "-"}</td>
                <td>
                  <ReviewStatusBadge status={hazard.reviewStatus} />
                </td>
                <td>{hazard.corroborationCount}</td>
                <td>{new Date(hazard.createdAt).toLocaleDateString()}</td>
                <td style={{ display: "flex", gap: 6 }}>
                  <button
                    type="button"
                    className="btn btn-sm"
                    onClick={() => setSelected(hazard)}
                  >
                    View
                  </button>
                  {canWrite && (
                    <button
                      type="button"
                      className="btn btn-sm btn-danger"
                      onClick={() => setDeleteTarget(hazard)}
                    >
                      Delete
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {selected && (
        <HazardDetailModal hazard={selected} onClose={() => setSelected(null)} />
      )}

      {deleteTarget && (
        <ConfirmDialog
          title="Delete alert"
          description={`Permanently delete "${deleteTarget.title}"? This cannot be undone.`}
          confirmLabel="Delete"
          danger
          onConfirm={() => void handleDelete()}
          onCancel={() => setDeleteTarget(null)}
        />
      )}
    </div>
  );
};

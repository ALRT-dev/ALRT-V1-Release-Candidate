import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { createHazard, createHazardSource, deleteHazard, listHazards } from "../api/resources";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ReviewStatusBadge, SeverityBadge } from "../components/StatusBadge";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { HazardDetailModal } from "../components/HazardDetailModal";
import { TestAlertPickerModal } from "../components/TestAlertPickerModal";
import { ApiError } from "../api/client";
import type { AdminHazard, HazardReviewStatus } from "../api/types";
import {
  SCARBOROUGH_WA_LAT,
  SCARBOROUGH_WA_LNG,
  testAlertExpiresAt,
} from "../data/testAlertPresets";
import type { TestAlertPreset } from "../data/testAlertPresets";

// Disposable TEST-only source every "Create Test Alert" preset attaches
// to - lazily created via the API on first use (see handleCreateTestAlert
// below), same as the original single dummy-alert button. The env var
// name predates the picker (it started as one fixed button) but still
// works exactly the same way: it's only set in admin/.env.test, so a
// plain production build never inlines it and the button/picker don't
// exist at all - not just hidden by role/CSS.
const TEST_SOURCE_ID = "test-dummy";
const testAlertsEnabled = import.meta.env.VITE_ENABLE_DUMMY_ALERTS === "true";

export const AlertsPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const [reviewStatus, setReviewStatus] = useState<HazardReviewStatus | "">("");
  const [origin, setOrigin] = useState<"" | "official" | "community">("");
  const [selected, setSelected] = useState<AdminHazard | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<AdminHazard | null>(null);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [creatingPresetId, setCreatingPresetId] = useState<string | null>(null);

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

  // TEST-only - see testAlertsEnabled above. Creates the disposable
  // "test-dummy" source on first use (ignoring the "already exists" 400
  // on every subsequent preset), then the picked preset's fixed alert. No
  // AI (per-preset useDummyAi, see testAlertPresets.ts), Maps, Firebase,
  // email, or payment service is touched by either call - both are the
  // same existing admin endpoints a real admin uses for real hazard
  // management, just with fixed, non-editable payloads.
  const handleCreateTestAlert = async (preset: TestAlertPreset) => {
    setCreatingPresetId(preset.id);
    try {
      try {
        await createHazardSource({
          id: TEST_SOURCE_ID,
          name: "TEST DUMMY SOURCE - DO NOT USE",
          url: "https://example.invalid/test",
        });
      } catch (err) {
        if (!(err instanceof ApiError && err.status === 400)) throw err;
      }
      await createHazard({
        title: preset.title,
        description: preset.description,
        sourceId: TEST_SOURCE_ID,
        categoryId: preset.categoryId,
        latitude: SCARBOROUGH_WA_LAT,
        longitude: SCARBOROUGH_WA_LNG,
        severity: preset.severity,
        severityBand: preset.severityBand,
        expiresAt: testAlertExpiresAt(),
        useDummyAi: preset.useDummyAi,
      });
      notifySuccess(`Created "${preset.title}".`);
      setPickerOpen(false);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Failed to create test alert.");
    } finally {
      setCreatingPresetId(null);
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
        {testAlertsEnabled && canWrite && (
          <button
            type="button"
            className="btn btn-sm"
            onClick={() => setPickerOpen(true)}
          >
            Create Test Alert
          </button>
        )}
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
                <td>{hazard.source?.name ?? hazard.reportedBy?.name ?? "-"}</td>
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

      {testAlertsEnabled && pickerOpen && (
        <TestAlertPickerModal
          creatingId={creatingPresetId}
          onSelect={(preset) => void handleCreateTestAlert(preset)}
          onCancel={() => setPickerOpen(false)}
        />
      )}
    </div>
  );
};

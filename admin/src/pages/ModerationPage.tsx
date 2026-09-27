import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listHazards, reviewHazard } from "../api/resources";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { HazardDetailModal } from "../components/HazardDetailModal";
import { ApiError } from "../api/client";
import type { AdminHazard, HazardReviewStatus } from "../api/types";

type QueueTab = "pending" | "accepted" | "rejected";

export const ModerationPage = () => {
  const { notifySuccess, notifyError } = useToast();
  const [tab, setTab] = useState<QueueTab>("pending");
  const [selected, setSelected] = useState<AdminHazard | null>(null);
  const [rejectTarget, setRejectTarget] = useState<AdminHazard | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  const fetcher = useCallback(
    () => listHazards({ reviewStatus: tab as HazardReviewStatus, pageSize: 100 }),
    [tab],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [tab]);

  const approve = async (hazard: AdminHazard) => {
    setBusyId(hazard.id);
    try {
      await reviewHazard(hazard.id, "accepted");
      notifySuccess(`Approved "${hazard.title}".`);
      refetch();
    } catch (err) {
      notifyError(
        err instanceof ApiError ? err.message : "Approving the report failed.",
      );
    } finally {
      setBusyId(null);
    }
  };

  const reject = async (reason?: string) => {
    if (!rejectTarget) return;
    setBusyId(rejectTarget.id);
    try {
      await reviewHazard(rejectTarget.id, "rejected", reason);
      notifySuccess(`Rejected "${rejectTarget.title}".`);
      setRejectTarget(null);
      refetch();
    } catch (err) {
      notifyError(
        err instanceof ApiError ? err.message : "Rejecting the report failed.",
      );
    } finally {
      setBusyId(null);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Moderation</h1>
          <p>
            Community-reported hazards awaiting a human decision. Approving
            or rejecting here never changes a report's source attribution -
            only the AI's own review is separate and untouched by this
            screen (backend: PATCH /api/admin/hazards/:id/review).
          </p>
        </div>
      </div>

      <div className="toolbar">
        {(["pending", "accepted", "rejected"] as QueueTab[]).map((t) => (
          <button
            key={t}
            type="button"
            className={tab === t ? "btn btn-primary btn-sm" : "btn btn-sm"}
            onClick={() => setTab(t)}
          >
            {t[0].toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>

      {loading && <LoadingState label="Loading moderation queue..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label={`No ${tab} reports.`} />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Report</th>
              <th>Reporter</th>
              <th>Corroboration</th>
              <th>Submitted</th>
              {tab !== "pending" && <th>Moderation note</th>}
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((hazard) => (
              <tr key={hazard.id}>
                <td>{hazard.title}</td>
                <td>{hazard.reportedBy?.name ?? "Unknown"}</td>
                <td>{hazard.corroborationCount}</td>
                <td>{new Date(hazard.createdAt).toLocaleString()}</td>
                {tab !== "pending" && <td>{hazard.reviewFeedback ?? "-"}</td>}
                <td style={{ display: "flex", gap: 6 }}>
                  <button
                    type="button"
                    className="btn btn-sm"
                    onClick={() => setSelected(hazard)}
                  >
                    View
                  </button>
                  {tab === "pending" && (
                    <>
                      <button
                        type="button"
                        className="btn btn-sm btn-primary"
                        disabled={busyId === hazard.id}
                        onClick={() => void approve(hazard)}
                      >
                        Approve
                      </button>
                      <button
                        type="button"
                        className="btn btn-sm btn-danger"
                        disabled={busyId === hazard.id}
                        onClick={() => setRejectTarget(hazard)}
                      >
                        Reject
                      </button>
                    </>
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

      {rejectTarget && (
        <ConfirmDialog
          title="Reject report"
          description={`Reject "${rejectTarget.title}"? A reason is required and will be stored on the report.`}
          confirmLabel="Reject"
          danger
          requireReason
          reasonLabel="Rejection reason"
          onConfirm={(reason) => void reject(reason)}
          onCancel={() => setRejectTarget(null)}
        />
      )}
    </div>
  );
};

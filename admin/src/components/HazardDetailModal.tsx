import type { AdminHazard } from "../api/types";
import { ReviewStatusBadge, SeverityBadge, BooleanBadge } from "./StatusBadge";

/** Read-only detail view. Renders alert/community-report text as plain
 * text nodes only (React escapes text children by default) - never via
 * dangerouslySetInnerHTML - since hazard titles/descriptions/AI summaries
 * originate from external sources or unmoderated community submissions and
 * must be treated as untrusted content (Stage 7C §16). */
export const HazardDetailModal = ({
  hazard,
  onClose,
}: {
  hazard: AdminHazard;
  onClose: () => void;
}) => {
  const isOfficial = Boolean(hazard.sourceId);

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div
        className="modal"
        style={{ width: "min(640px, 92vw)", maxHeight: "85vh", overflowY: "auto" }}
        onClick={(event) => event.stopPropagation()}
      >
        <h2>{hazard.title}</h2>
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap", marginBottom: 12 }}>
          <SeverityBadge severity={hazard.severity} />
          <ReviewStatusBadge status={hazard.reviewStatus} />
          <span className={`badge ${isOfficial ? "badge-success" : "badge-pending"}`}>
            {isOfficial ? "Official source" : "Community report"}
          </span>
          {hazard.isAwsCompliant && <span className="badge badge-pending">AWS</span>}
        </div>

        <p>{hazard.description}</p>
        {hazard.aiSummary && (
          <div className="field">
            <label>AI summary</label>
            <p style={{ margin: 0 }}>{hazard.aiSummary}</p>
          </div>
        )}
        {hazard.callsToAction.length > 0 && (
          <div className="field">
            <label>Calls to action</label>
            <ul style={{ margin: 0, paddingLeft: 18 }}>
              {hazard.callsToAction.map((line, i) => (
                <li key={i}>{line}</li>
              ))}
            </ul>
          </div>
        )}

        <table className="data-table" style={{ marginTop: 12 }}>
          <tbody>
            <tr>
              <th>Category</th>
              <td>
                {hazard.categoryName ?? "-"}
                {hazard.categoryParentName ? ` (${hazard.categoryParentName})` : ""}
              </td>
            </tr>
            <tr>
              <th>Source</th>
              <td>
                {hazard.sourceName ?? "None (community report)"}
                {hazard.licenseBadgeText ? ` · ${hazard.licenseBadgeText}` : ""}
              </td>
            </tr>
            <tr>
              <th>Reported by</th>
              <td>{hazard.reportedByName ?? "-"}</td>
            </tr>
            <tr>
              <th>Location</th>
              <td>
                {hazard.locationName ?? "-"}
                {hazard.latitude != null && hazard.longitude != null
                  ? ` (${hazard.latitude.toFixed(4)}, ${hazard.longitude.toFixed(4)})`
                  : ""}
              </td>
            </tr>
            <tr>
              <th>Corroboration</th>
              <td>
                {hazard.corroborationCount > 0
                  ? `${hazard.corroborationCount} independent report(s)`
                  : "None"}
              </td>
            </tr>
            <tr>
              <th>Confidence score</th>
              <td>{hazard.confidenceScore}</td>
            </tr>
            <tr>
              <th>Moderation</th>
              <td>
                <ReviewStatusBadge status={hazard.reviewStatus} />
                {hazard.reviewFeedback && (
                  <div style={{ marginTop: 4 }}>{hazard.reviewFeedback}</div>
                )}
                {hazard.reviewedAt && (
                  <div style={{ fontSize: 12, color: "var(--color-text-muted)" }}>
                    Reviewed {new Date(hazard.reviewedAt).toLocaleString()}
                    {hazard.reviewedById ? ` by ${hazard.reviewedById}` : ""}
                  </div>
                )}
              </td>
            </tr>
            <tr>
              <th>Media</th>
              <td>
                <BooleanBadge
                  value={hazard.medias.length > 0}
                  trueLabel={`${hazard.medias.length} file(s)`}
                  falseLabel="None"
                />
              </td>
            </tr>
            <tr>
              <th>Occurred</th>
              <td>{new Date(hazard.occurredAt).toLocaleString()}</td>
            </tr>
            <tr>
              <th>Created</th>
              <td>{new Date(hazard.createdAt).toLocaleString()}</td>
            </tr>
            <tr>
              <th>Expires</th>
              <td>{hazard.expiresAt ? new Date(hazard.expiresAt).toLocaleString() : "Never"}</td>
            </tr>
          </tbody>
        </table>

        <div className="modal-actions">
          <button type="button" className="btn" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

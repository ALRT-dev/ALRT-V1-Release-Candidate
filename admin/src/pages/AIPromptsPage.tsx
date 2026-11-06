import { useCallback, useState } from "react";
import { Link } from 'react-router-dom';
import { useApiQuery } from "../hooks/useApiQuery";
import { listAIPrompts, updateAIPrompt } from "../api/resources";
import { getAlertTemplates } from "../api/alertTemplates";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { ApiError } from "../api/client";
import type { AIPrompt } from "../api/types";

export const AIPromptsPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [editing, setEditing] = useState<AIPrompt | null>(null);
  const [contentDraft, setContentDraft] = useState("");
  const [confirming, setConfirming] = useState(false);
  const [saving, setSaving] = useState(false);

  const fetcher = useCallback(() => listAIPrompts(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);
  const registryFetcher = useCallback(() => getAlertTemplates(), []);
  const registry = useApiQuery(registryFetcher, []);
  const published = registry.data?.state?.published;
  const publicationKnown = !registry.loading && !registry.error &&
    (published === null || (typeof published?.version === "number" && published.version > 0));
  const hasSnapshot = publicationKnown && published != null;
  const saveImpact = !publicationKnown
    ? "Publication status could not be verified. Saving prompt text may affect current alerts immediately and other AI features may use the saved text directly. This page does not save a draft."
    : hasSnapshot
      ? `Agency alerts keep using published snapshot v${published.version}. Edited prompt rows enter agency alerts only after a separate preview and publish in Alert Templates. Other AI features may read saved prompt rows directly, so saving may affect those features immediately. This page does not save a draft.`
      : "Saving prompt text may affect current alerts immediately, because no published agency template snapshot is available. Other AI features may also use the saved text directly. This page does not save a draft.";

  const startEdit = (prompt: AIPrompt) => {
    registry.refetch();
    setEditing(prompt);
    setContentDraft(prompt.content);
  };

  const save = async () => {
    if (!editing) return;
    setSaving(true);
    try {
      await updateAIPrompt(editing.id, { content: contentDraft });
      notifySuccess(`Updated prompt "${editing.name}".`);
      setEditing(null);
      setConfirming(false);
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "Update failed.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>AI Prompts</h1>
          <p>
            Edit saved AI prompt text. Review the save impact below before changing it.
            Agency template preview and publication are separate actions in <Link to="/alert-templates">Alert Templates</Link>.
          </p>
        </div>
      </div>

      <div className="card" role="status" style={{ marginBottom: 16 }}>
        <p>{registry.loading
          ? "Checking agency template publication status. Saving prompt text may affect current alerts immediately until that status is verified. This page does not save a draft."
          : !publicationKnown
            ? "Could not verify the agency template publication status. Saving prompt text may affect current alerts immediately. This page does not save a draft."
            : hasSnapshot
              ? `Published agency template snapshot v${published.version}. Agency alerts use that saved snapshot; edited rows enter agency alerts only after a separate preview and publish in Alert Templates. Other AI features may read saved prompt rows directly and may be affected immediately. This page does not save a draft.`
              : "No published agency template snapshot. Saving prompt text may affect current alerts immediately. Other AI features may also use saved rows directly. This page does not save a draft."}</p>
        {!registry.loading && !publicationKnown && <button type="button" className="btn btn-sm" onClick={registry.refetch}>Retry publication status</button>}
      </div>

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        {/* Create/delete of prompts is intentionally not exposed in V1 -
            deleting or misconfiguring a prompt used by Configuration.
            aiPrompts breaks alert generation, and this is a first V1 for
            an internal tool with no usage history yet. The backend
            supports create/delete (gated requireAdminOrAbove); only
            view + edit-content ship here. See V1_RECONCILIATION_REPORT.md
            §24 for the full reasoning. */}
        This V1 supports viewing and editing existing prompt content only.
        Creating or deleting prompts is available on the backend but
        deliberately not exposed here yet - deleting a prompt still wired
        into the live Configuration would break alert generation.
      </div>

      {loading && <LoadingState label="Loading prompts..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No prompts configured." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Group</th>
              <th>Model</th>
              <th>Last updated</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {data.map((prompt) => (
              <tr key={prompt.id}>
                <td>{prompt.name}</td>
                <td>{prompt.group?.name ?? "-"}</td>
                <td>{prompt.model}</td>
                <td>{new Date(prompt.updatedAt).toLocaleString()}</td>
                <td>
                  <button
                    type="button"
                    className="btn btn-sm"
                    onClick={() => startEdit(prompt)}
                  >
                    {canWrite ? "Edit" : "View"}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {editing && (
        <div className="modal-backdrop" onClick={() => setEditing(null)}>
          <div
            className="modal"
            style={{ width: "min(640px, 92vw)" }}
            onClick={(event) => event.stopPropagation()}
          >
            <h2>{editing.name}</h2>
            <p>{saveImpact}</p>
            <div className="field">
              <label htmlFor="prompt-content">Content</label>
              <textarea
                id="prompt-content"
                rows={14}
                value={contentDraft}
                readOnly={!canWrite}
                onChange={(event) => setContentDraft(event.target.value)}
              />
            </div>
            <div className="modal-actions">
              <button type="button" className="btn" onClick={() => setEditing(null)}>
                Close
              </button>
              {canWrite && (
                <button
                  type="button"
                  className="btn btn-primary"
                  disabled={contentDraft === editing.content}
                  onClick={() => setConfirming(true)}
                >
                  Save prompt text
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {confirming && editing && (
        <ConfirmDialog
          title="Confirm prompt content change"
          description={`${hasSnapshot ? `Saving "${editing.name}" updates the prompt row.` : `Saving "${editing.name}" may affect current alerts immediately.`} ${saveImpact}`}
          confirmLabel="Save prompt text"
          danger
          onConfirm={() => void save()}
          onCancel={() => setConfirming(false)}
        />
      )}
      {saving && <LoadingState label="Saving..." />}
    </div>
  );
};

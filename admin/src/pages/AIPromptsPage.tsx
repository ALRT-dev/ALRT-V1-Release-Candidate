import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { listAIPrompts, updateAIPrompt } from "../api/resources";
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

  const startEdit = (prompt: AIPrompt) => {
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
            The live alert-generation prompt content
            (src/utils/ai-prompt.util.ts / ai-prompt.service.ts is the sole
            authoritative system - backend/CLAUDE.md). Editing here changes
            what the AI writes for every future alert of this kind.
          </p>
        </div>
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
                  Save changes
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {confirming && editing && (
        <ConfirmDialog
          title="Confirm prompt content change"
          description={`This changes the live AI prompt "${editing.name}", used for every future alert it applies to. Locked safety rules (e.g. never a specific emergency number, community reports never carry a call-to-action) live in code and are unaffected by this edit, but a bad prompt edit can still degrade alert quality immediately.`}
          confirmLabel="Save and apply"
          danger
          onConfirm={() => void save()}
          onCancel={() => setConfirming(false)}
        />
      )}
      {saving && <LoadingState label="Saving..." />}
    </div>
  );
};

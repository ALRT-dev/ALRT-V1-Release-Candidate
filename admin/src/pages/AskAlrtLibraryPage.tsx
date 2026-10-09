import { useCallback, useMemo, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import {
  deleteAskAlrtEntry,
  listAskAlrtEntries,
  saveAskAlrtEntry,
} from "../api/resources";
import { ApiError } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ConfirmDialog } from "../components/ConfirmDialog";
import { AskAlrtAiSwitch } from "../components/AskAlrtAiSwitch";
import type { AskAlrtEntry, AskAlrtEntryOrigin } from "../api/types";

const MAX_ANSWER = 1200;
const MIN_ANSWER = 20;

const ORIGIN_LABEL: Record<AskAlrtEntryOrigin, string> = {
  built_in: "Built in",
  customised: "Edited",
  custom: "Added by you",
};

// Mirrors the locked copy rules the server enforces (backend
// utils/ask_alrt_content.util.ts). The server is the authority; this only
// gives feedback while typing.
const EN_OR_EM_DASH = /[–—]/;
const PHONE_LIKE = /(?:\+?\d[\s().-]?){7,}/;

const splitLines = (text: string): string[] =>
  text
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line !== "");

const splitKeywords = (text: string): string[] =>
  text
    .split(/[,\n]/)
    .map((part) => part.trim())
    .filter((part) => part !== "");

interface Draft {
  id: string;
  isNew: boolean;
  triggers: string;
  keywords: string;
  answer: string;
  enabled: boolean;
}

const emptyDraft = (): Draft => ({
  id: "",
  isNew: true,
  triggers: "",
  keywords: "",
  answer: "",
  enabled: true,
});

const draftFromEntry = (entry: AskAlrtEntry): Draft => ({
  id: entry.id,
  isNew: false,
  triggers: entry.triggers.join("\n"),
  keywords: entry.keywords.join(", "),
  answer: entry.answer,
  enabled: entry.enabled,
});

const draftProblems = (draft: Draft): string[] => {
  const problems: string[] = [];
  if (draft.isNew && !/^[a-z0-9_]{2,60}$/.test(draft.id)) {
    problems.push("Id: 2 to 60 characters, lower case letters, digits and underscores only.");
  }
  if (splitLines(draft.triggers).length === 0 && splitKeywords(draft.keywords).length === 0) {
    problems.push("Add at least one question phrase or keyword.");
  }
  const answer = draft.answer.trim();
  if (answer.length < MIN_ANSWER) problems.push(`Answer needs at least ${MIN_ANSWER} characters.`);
  if (answer.length > MAX_ANSWER) problems.push(`Answer can be at most ${MAX_ANSWER} characters.`);
  if (EN_OR_EM_DASH.test(answer)) problems.push("No en or em dashes in answers. Use a comma, colon or full stop.");
  if (PHONE_LIKE.test(answer)) problems.push("No phone numbers in answers.");
  return problems;
};

export const AskAlrtLibraryPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const [draft, setDraft] = useState<Draft | null>(null);
  const [confirmingSave, setConfirmingSave] = useState(false);
  const [removing, setRemoving] = useState<AskAlrtEntry | null>(null);
  const [saving, setSaving] = useState(false);

  const fetcher = useCallback(() => listAskAlrtEntries(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  const rows = useMemo(() => {
    const term = search.trim().toLowerCase();
    if (!data) return [];
    if (!term) return data;
    return data.filter(
      (row) =>
        row.id.includes(term) ||
        row.answer.toLowerCase().includes(term) ||
        row.triggers.some((t) => t.toLowerCase().includes(term)) ||
        row.keywords.some((k) => k.toLowerCase().includes(term)),
    );
  }, [data, search]);

  const problems = draft ? draftProblems(draft) : [];

  const save = async () => {
    if (!draft) return;
    setSaving(true);
    try {
      await saveAskAlrtEntry(draft.id, {
        triggers: splitLines(draft.triggers),
        keywords: splitKeywords(draft.keywords),
        answer: draft.answer.trim(),
        enabled: draft.enabled,
      });
      notifySuccess(`Saved answer "${draft.id}". The assistant picks it up within about 5 minutes.`);
      setDraft(null);
      setConfirmingSave(false);
      refetch();
    } catch (err) {
      setConfirmingSave(false);
      notifyError(err instanceof ApiError ? err.message : "Save failed.");
    } finally {
      setSaving(false);
    }
  };

  const remove = async () => {
    if (!removing) return;
    setSaving(true);
    try {
      const result = await deleteAskAlrtEntry(removing.id);
      notifySuccess(
        result.revertedToBuiltIn
          ? `"${removing.id}" is back to the built in text.`
          : `Removed answer "${removing.id}".`,
      );
      setRemoving(null);
      refetch();
    } catch (err) {
      setRemoving(null);
      notifyError(err instanceof ApiError ? err.message : "Remove failed.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Ask ALRT Answers</h1>
          <p>
            The pre-written questions and answers Ask ALRT uses before it ever
            calls the AI. A matching question gets this answer for free and
            does not need the AI. Changes reach the assistant within about 5
            minutes, with no app release.
          </p>
        </div>
        {canWrite && (
          <button type="button" className="btn btn-primary" onClick={() => setDraft(emptyDraft())}>
            Add answer
          </button>
        )}
      </div>

      <AskAlrtAiSwitch />

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        Built in answers ship with the assistant. Editing one saves your
        version over it, and removing your version brings the built in text
        back. Untick Show to hide a built in answer without deleting it. To
        quote someone's local emergency number, write the sentence without a
        number: phone numbers are not allowed here, and the Emergency Numbers
        page drives the assistant's number lookups.
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Search answers..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>

      {loading && <LoadingState label="Loading answers..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && rows.length === 0 && (
        <EmptyState label={search ? "No answers match that search." : "No answers yet."} />
      )}
      {!loading && !error && rows.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Question</th>
              <th>Answer</th>
              <th>Source</th>
              <th>Shown</th>
              <th>Last edited</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id}>
                <td>
                  <div>{row.triggers[0] ?? row.keywords.join(", ")}</div>
                  <div style={{ fontSize: 11, color: "var(--color-text-muted)" }}>{row.id}</div>
                </td>
                <td style={{ maxWidth: 420 }}>
                  {row.answer.length > 140 ? `${row.answer.slice(0, 140)}...` : row.answer}
                </td>
                <td>
                  <span className={`badge ${row.origin === "built_in" ? "badge-pending" : "badge-success"}`}>
                    {ORIGIN_LABEL[row.origin]}
                  </span>
                </td>
                <td>{row.enabled ? "Yes" : <span className="badge badge-warning">Hidden</span>}</td>
                <td>
                  {row.updatedAt ? new Date(row.updatedAt).toLocaleString() : "-"}
                  {row.updatedBy && (
                    <div style={{ fontSize: 11, color: "var(--color-text-muted)" }}>{row.updatedBy}</div>
                  )}
                </td>
                <td style={{ whiteSpace: "nowrap" }}>
                  <button type="button" className="btn btn-sm" onClick={() => setDraft(draftFromEntry(row))}>
                    {canWrite ? "Edit" : "View"}
                  </button>{" "}
                  {canWrite && row.origin !== "built_in" && (
                    <button type="button" className="btn btn-sm btn-danger" onClick={() => setRemoving(row)}>
                      {row.hasBuiltIn ? "Use built in" : "Remove"}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {draft && (
        <div className="modal-backdrop" onClick={() => setDraft(null)}>
          <div
            className="modal"
            style={{ width: "min(680px, 94vw)" }}
            onClick={(event) => event.stopPropagation()}
          >
            <h2>{draft.isNew ? "Add answer" : `Answer: ${draft.id}`}</h2>

            {draft.isNew && (
              <div className="field">
                <label htmlFor="entry-id">Id</label>
                <input
                  id="entry-id"
                  type="text"
                  value={draft.id}
                  placeholder="for_example_refund_policy"
                  onChange={(event) => setDraft({ ...draft, id: event.target.value.trim() })}
                />
              </div>
            )}

            <div className="field">
              <label htmlFor="entry-triggers">Questions people ask (one per line)</label>
              <textarea
                id="entry-triggers"
                rows={4}
                value={draft.triggers}
                readOnly={!canWrite}
                placeholder={"how do i send an sos\nstart an sos"}
                onChange={(event) => setDraft({ ...draft, triggers: event.target.value })}
              />
            </div>

            <div className="field">
              <label htmlFor="entry-keywords">Keywords (separate with commas)</label>
              <input
                id="entry-keywords"
                type="text"
                value={draft.keywords}
                readOnly={!canWrite}
                placeholder="sos, emergency, help"
                onChange={(event) => setDraft({ ...draft, keywords: event.target.value })}
              />
            </div>

            <div className="field">
              <label htmlFor="entry-answer">Answer</label>
              <textarea
                id="entry-answer"
                rows={7}
                value={draft.answer}
                readOnly={!canWrite}
                onChange={(event) => setDraft({ ...draft, answer: event.target.value })}
              />
              <div style={{ fontSize: 11, color: "var(--color-text-muted)" }}>
                {draft.answer.trim().length} / {MAX_ANSWER}
              </div>
            </div>

            <div className="field">
              <label>
                <input
                  type="checkbox"
                  checked={draft.enabled}
                  disabled={!canWrite}
                  onChange={(event) => setDraft({ ...draft, enabled: event.target.checked })}
                />{" "}
                Show this answer
              </label>
            </div>

            {canWrite && problems.length > 0 && (
              <ul style={{ fontSize: 12, color: "var(--color-danger, #b3261e)", margin: "0 0 8px 18px" }}>
                {problems.map((problem) => (
                  <li key={problem}>{problem}</li>
                ))}
              </ul>
            )}

            <div className="modal-actions">
              <button type="button" className="btn" onClick={() => setDraft(null)}>
                Close
              </button>
              {canWrite && (
                <button
                  type="button"
                  className="btn btn-primary"
                  disabled={problems.length > 0 || saving}
                  onClick={() => setConfirmingSave(true)}
                >
                  Save answer
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {confirmingSave && draft && (
        <ConfirmDialog
          title="Publish this answer?"
          description={`This answer is shown to every ALRT user who asks a matching question, within about 5 minutes. It is not checked by the AI. Re-read it for accuracy against the current plans, prices and safety wording before you publish.`}
          confirmLabel="Save and publish"
          onConfirm={() => void save()}
          onCancel={() => setConfirmingSave(false)}
        />
      )}

      {removing && (
        <ConfirmDialog
          title={removing.hasBuiltIn ? "Go back to the built in answer?" : "Remove this answer?"}
          description={
            removing.hasBuiltIn
              ? `Your edited version of "${removing.id}" is deleted and the assistant uses the built in text again.`
              : `"${removing.id}" is deleted. Questions it matched fall through to the AI.`
          }
          confirmLabel={removing.hasBuiltIn ? "Use built in" : "Remove"}
          danger
          onConfirm={() => void remove()}
          onCancel={() => setRemoving(null)}
        />
      )}
    </div>
  );
};

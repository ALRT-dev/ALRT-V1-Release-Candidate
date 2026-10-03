import { useCallback, useMemo, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import {
  importEmergencyDefaults,
  listEmergencyNumbers,
  removeEmergencyNumber,
  saveEmergencyNumber,
} from "../api/resources";
import { ApiError } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { useToast } from "../components/ToastContext";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import { ConfirmDialog } from "../components/ConfirmDialog";
import type { EmergencyNumberRow } from "../api/types";

interface Draft {
  isNew: boolean;
  iso: string;
  name: string;
  number: string;
}

const emptyDraft = (): Draft => ({ isNew: true, iso: "", name: "", number: "" });

const draftProblems = (draft: Draft): string[] => {
  const problems: string[] = [];
  if (!/^[A-Za-z]{2}$/.test(draft.iso.trim())) problems.push("Country code: two letters, for example AU.");
  if (draft.name.trim() === "") problems.push("Country name is required.");
  if (!/^[0-9]{2,6}$/.test(draft.number.trim())) problems.push("Number: 2 to 6 digits, no spaces or symbols.");
  return problems;
};

export const EmergencyNumbersPage = () => {
  const { hasRole } = useAuth();
  const { notifySuccess, notifyError } = useToast();
  const canWrite = hasRole("superAdmin", "admin");

  const [search, setSearch] = useState("");
  const [draft, setDraft] = useState<Draft | null>(null);
  const [confirmingSave, setConfirmingSave] = useState(false);
  const [removing, setRemoving] = useState<EmergencyNumberRow | null>(null);
  const [confirmingImport, setConfirmingImport] = useState(false);
  const [busy, setBusy] = useState(false);

  const fetcher = useCallback(() => listEmergencyNumbers(), []);
  const { data, error, loading, refetch } = useApiQuery(fetcher, []);

  const rows = useMemo(() => {
    const term = search.trim().toLowerCase();
    if (!data) return [];
    if (!term) return data;
    return data.filter(
      (row) =>
        row.name.toLowerCase().includes(term) ||
        row.iso.toLowerCase() === term ||
        row.number.includes(term),
    );
  }, [data, search]);

  const unsavedCount = data ? data.filter((row) => row.isDefault).length : 0;
  const problems = draft ? draftProblems(draft) : [];

  const run = async (action: () => Promise<string>, after: () => void) => {
    setBusy(true);
    try {
      notifySuccess(await action());
      after();
      refetch();
    } catch (err) {
      notifyError(err instanceof ApiError ? err.message : "That did not work.");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Emergency Numbers</h1>
          <p>
            The number Ask ALRT gives when someone asks for a country's
            emergency number. Changes reach the assistant within about 5
            minutes.
          </p>
        </div>
        {canWrite && (
          <div style={{ display: "flex", gap: 8 }}>
            <button
              type="button"
              className="btn"
              disabled={busy || unsavedCount === 0}
              onClick={() => setConfirmingImport(true)}
            >
              Save the whole starting list
            </button>
            <button type="button" className="btn btn-primary" onClick={() => setDraft(emptyDraft())}>
              Add country
            </button>
          </div>
        )}
      </div>

      <div className="card" style={{ marginBottom: 16, fontSize: 13 }}>
        This list drives Ask ALRT only. The emergency number shown on the
        app's own screens (SOS, onboarding) still comes from the table built
        into the app, and a number saved here does not change it until the app
        is updated to read this list. The assistant ships knowing only eight
        countries, so use "Save the whole starting list" once to give it the
        rest. Always double check a number against an official source before
        saving it: a wrong number here is worse than the 112 fallback.
      </div>

      <div className="toolbar">
        <input
          type="search"
          placeholder="Search countries..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>

      {loading && <LoadingState label="Loading emergency numbers..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && rows.length === 0 && (
        <EmptyState label={search ? "No countries match that search." : "No countries yet."} />
      )}
      {!loading && !error && rows.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>Country</th>
              <th>Code</th>
              <th>Number</th>
              <th>Source</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.iso}>
                <td>{row.name}</td>
                <td>{row.iso}</td>
                <td>
                  <strong>{row.number}</strong>
                  {!row.isDefault && row.defaultNumber && row.defaultNumber !== row.number && (
                    <div style={{ fontSize: 11, color: "var(--color-text-muted)" }}>
                      starting list: {row.defaultNumber}
                    </div>
                  )}
                </td>
                <td>
                  <span className={`badge ${row.isDefault ? "badge-pending" : "badge-success"}`}>
                    {row.isDefault ? "Starting list" : "Saved"}
                  </span>
                </td>
                <td style={{ whiteSpace: "nowrap" }}>
                  {canWrite && (
                    <button
                      type="button"
                      className="btn btn-sm"
                      onClick={() =>
                        setDraft({ isNew: false, iso: row.iso, name: row.name, number: row.number })
                      }
                    >
                      Edit
                    </button>
                  )}{" "}
                  {canWrite && !row.isDefault && (
                    <button type="button" className="btn btn-sm btn-danger" onClick={() => setRemoving(row)}>
                      {row.defaultNumber ? "Reset" : "Remove"}
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
            style={{ width: "min(460px, 92vw)" }}
            onClick={(event) => event.stopPropagation()}
          >
            <h2>{draft.isNew ? "Add country" : `Edit ${draft.name}`}</h2>
            <div className="field">
              <label htmlFor="en-iso">Country code</label>
              <input
                id="en-iso"
                type="text"
                maxLength={2}
                value={draft.iso}
                readOnly={!draft.isNew}
                placeholder="JP"
                onChange={(event) => setDraft({ ...draft, iso: event.target.value.toUpperCase() })}
              />
            </div>
            <div className="field">
              <label htmlFor="en-name">Country name</label>
              <input
                id="en-name"
                type="text"
                value={draft.name}
                placeholder="Japan"
                onChange={(event) => setDraft({ ...draft, name: event.target.value })}
              />
            </div>
            <div className="field">
              <label htmlFor="en-number">Emergency number</label>
              <input
                id="en-number"
                type="text"
                inputMode="numeric"
                maxLength={6}
                value={draft.number}
                placeholder="110"
                onChange={(event) => setDraft({ ...draft, number: event.target.value })}
              />
            </div>
            {problems.length > 0 && (
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
              <button
                type="button"
                className="btn btn-primary"
                disabled={problems.length > 0 || busy}
                onClick={() => setConfirmingSave(true)}
              >
                Save number
              </button>
            </div>
          </div>
        </div>
      )}

      {confirmingSave && draft && (
        <ConfirmDialog
          title="Save this emergency number?"
          description={`Ask ALRT will tell people that the emergency number for ${draft.name.trim()} is ${draft.number.trim()}. A wrong number could stop someone reaching help, so check it against an official source first.`}
          confirmLabel="Save number"
          danger
          onConfirm={() =>
            void run(
              async () => {
                await saveEmergencyNumber({
                  iso: draft.iso.trim(),
                  number: draft.number.trim(),
                  name: draft.name.trim(),
                });
                return `Saved ${draft.name.trim()}: ${draft.number.trim()}.`;
              },
              () => {
                setConfirmingSave(false);
                setDraft(null);
              },
            ).finally(() => setConfirmingSave(false))
          }
          onCancel={() => setConfirmingSave(false)}
        />
      )}

      {removing && (
        <ConfirmDialog
          title={removing.defaultNumber ? "Reset to the starting list?" : "Remove this country?"}
          description={
            removing.defaultNumber
              ? `${removing.name} goes back to ${removing.defaultNumber}.`
              : `${removing.name} is removed, so Ask ALRT can no longer look up its number.`
          }
          confirmLabel={removing.defaultNumber ? "Reset" : "Remove"}
          danger
          onConfirm={() =>
            void run(
              async () => {
                await removeEmergencyNumber(removing.iso);
                return `${removing.name} updated.`;
              },
              () => setRemoving(null),
            ).finally(() => setRemoving(null))
          }
          onCancel={() => setRemoving(null)}
        />
      )}

      {confirmingImport && (
        <ConfirmDialog
          title="Save the whole starting list?"
          description={`This saves the ${unsavedCount} countries still on the starting list so Ask ALRT knows them all. It never changes a number you have already saved.`}
          confirmLabel="Save the list"
          onConfirm={() =>
            void run(
              async () => {
                const result = await importEmergencyDefaults();
                return `Saved ${result.added} countries.`;
              },
              () => setConfirmingImport(false),
            ).finally(() => setConfirmingImport(false))
          }
          onCancel={() => setConfirmingImport(false)}
        />
      )}
    </div>
  );
};

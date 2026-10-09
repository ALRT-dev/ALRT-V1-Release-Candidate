import { useCallback, useState } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { usePageForFilters } from "../hooks/usePageForFilters";
import { Pagination } from "../components/Pagination";
import { listAuditLog } from "../api/resources";
import { LoadingState, EmptyState, ErrorState } from "../components/AsyncState";
import type { AdminAuditLogEntry } from "../api/types";

const TARGET_TYPES = [
  "",
  "HazardSource",
  "Hazard",
  "HazardCategory",
  "User",
  "AIPrompt",
  "Configuration",
  "WebhookApiKey",
  "Admin",
  "AskAlrtConfig",
  "AskAlrtEntry",
  "EmergencyNumber",
];

const PAGE_SIZE = 50;

const summarise = (value: Record<string, unknown> | null) =>
  value && Object.keys(value).length > 0 ? JSON.stringify(value) : "-";

export const AuditLogPage = () => {
  const [targetType, setTargetType] = useState("");
  const [page, setPage] = usePageForFilters([targetType]);

  const fetcher = useCallback(
    () => listAuditLog({ targetType: targetType || undefined, page, pageSize: PAGE_SIZE }),
    [targetType, page],
  );
  const { data, error, loading, refetch } = useApiQuery(fetcher, [targetType, page]);

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Audit Log</h1>
          <p>
            Who changed what in the admin portal, newest first. Secret values
            are never recorded here.
          </p>
        </div>
      </div>

      <div className="toolbar">
        <label htmlFor="audit-target-type">Type</label>
        <select
          id="audit-target-type"
          value={targetType}
          onChange={(event) => setTargetType(event.target.value)}
        >
          {TARGET_TYPES.map((type) => (
            <option key={type} value={type}>
              {type || "All"}
            </option>
          ))}
        </select>
      </div>

      {loading && <LoadingState label="Loading audit log..." />}
      {!loading && Boolean(error) && <ErrorState error={error} onRetry={refetch} />}
      {!loading && !error && data && data.length === 0 && (
        <EmptyState label="No audit entries match." />
      )}
      {!loading && !error && data && data.length > 0 && (
        <table className="data-table">
          <thead>
            <tr>
              <th>When</th>
              <th>Admin</th>
              <th>Action</th>
              <th>Target</th>
              <th>Before</th>
              <th>After</th>
            </tr>
          </thead>
          <tbody>
            {data.map((entry: AdminAuditLogEntry) => (
              <tr key={entry.id}>
                <td>{new Date(entry.createdAt).toLocaleString()}</td>
                <td>{entry.admin?.email ?? "-"}</td>
                <td>{entry.action}</td>
                <td>
                  {entry.targetType}
                  {entry.targetId ? ` ${entry.targetId}` : ""}
                </td>
                <td>{summarise(entry.before)}</td>
                <td>{summarise(entry.after)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {!loading && !error && data && (
        <Pagination
          page={page}
          pageSize={PAGE_SIZE}
          itemsOnPage={data.length}
          onPageChange={setPage}
        />
      )}
    </div>
  );
};

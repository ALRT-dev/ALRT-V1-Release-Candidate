import { useCallback } from "react";
import { useApiQuery } from "../hooks/useApiQuery";
import { getAdminStats, getDashboardStats } from "../api/resources";
import { LoadingState, ErrorState } from "../components/AsyncState";

const StatCard = ({
  label,
  value,
}: {
  label: string;
  value: string | number;
}) => (
  <div className="stat-card">
    <div className="stat-card__label">{label}</div>
    <div className="stat-card__value">{value}</div>
  </div>
);

export const DashboardPage = () => {
  const fetchStats = useCallback(() => getAdminStats(), []);
  const fetchDashboard = useCallback(() => getDashboardStats(), []);
  const stats = useApiQuery(fetchStats, []);
  const dashboard = useApiQuery(fetchDashboard, []);

  const loading = stats.loading || dashboard.loading;
  const error = stats.error ?? dashboard.error;

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Dashboard</h1>
          <p>Operational snapshot of ALRT. Not a marketing view.</p>
        </div>
      </div>

      {loading && <LoadingState label="Loading dashboard..." />}
      {!loading && Boolean(error) && (
        <ErrorState
          error={error}
          onRetry={() => {
            stats.refetch();
            dashboard.refetch();
          }}
        />
      )}

      {!loading && !error && dashboard.data && stats.data && (
        <>
          <section>
            <h2 style={{ fontSize: 14, color: "var(--color-text-muted)" }}>
              Users
            </h2>
            <div className="stat-grid">
              <StatCard label="Total users" value={dashboard.data.users.total} />
              <StatCard label="New today" value={dashboard.data.users.newToday} />
              <StatCard
                label="New (7 days)"
                value={dashboard.data.users.newLast7Days}
              />
              <StatCard
                label="Daily active"
                value={dashboard.data.users.dailyActive}
              />
              <StatCard
                label="Weekly active"
                value={dashboard.data.users.weeklyActive}
              />
              <StatCard
                label="Pending deletion"
                value={dashboard.data.users.pendingDeletion}
              />
            </div>
          </section>

          <section>
            <h2 style={{ fontSize: 14, color: "var(--color-text-muted)" }}>
              Hazards / Alerts
            </h2>
            <div className="stat-grid">
              <StatCard label="Active" value={dashboard.data.hazards.active} />
              <StatCard
                label="Pending review"
                value={dashboard.data.hazards.pendingReview}
              />
              <StatCard
                label="Created today"
                value={dashboard.data.hazards.createdToday}
              />
              <StatCard
                label="Total (all time)"
                value={stats.data.hazards.total}
              />
            </div>
          </section>

          <section>
            <h2 style={{ fontSize: 14, color: "var(--color-text-muted)" }}>
              Catalogue
            </h2>
            <div className="stat-grid">
              <StatCard
                label="Categories"
                value={dashboard.data.catalogue.categories}
              />
              <StatCard label="Sources" value={dashboard.data.catalogue.sources} />
            </div>
          </section>

          <section>
            <h2 style={{ fontSize: 14, color: "var(--color-text-muted)" }}>
              Device platforms
            </h2>
            <div className="stat-grid">
              <StatCard label="iOS" value={dashboard.data.platforms.ios} />
              <StatCard label="Android" value={dashboard.data.platforms.android} />
              <StatCard label="Other" value={dashboard.data.platforms.other} />
            </div>
          </section>

          <div className="card" style={{ marginTop: 8 }}>
            {/* ALRT+ / subscription statistics are not currently exposed by
                GET /api/admin/stats/dashboard (backend/src/services/
                stats.admin.service.ts) - the underlying data exists
                (FamilyCircle.plan) but nothing queries it yet. Per
                instruction: display as unavailable rather than invent it. */}
            <strong>ALRT+ / subscription statistics:</strong> not available
            from the Admin API yet - the dashboard endpoint does not
            currently query subscription/plan data. See
            V1_RECONCILIATION_REPORT.md §22.2 / §24.
          </div>

          <p style={{ fontSize: 12, color: "var(--color-text-muted)" }}>
            Generated at {new Date(dashboard.data.generatedAt).toLocaleString()}
            {" · "}day boundary: {stats.data.dayBoundary.timezone}
          </p>
        </>
      )}
    </div>
  );
};

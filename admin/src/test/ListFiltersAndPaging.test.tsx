import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import type { ReactElement } from "react";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { Layout } from "../components/Layout";
import { AlertsPage } from "../pages/AlertsPage";
import { ModerationPage } from "../pages/ModerationPage";
import { UsersPage } from "../pages/UsersPage";
import { AuditLogPage } from "../pages/AuditLogPage";
import { SourcesPage } from "../pages/SourcesPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";
import type { AdminRole } from "../api/types";

const me = (role: AdminRole = "admin") =>
  jsonRoute("/api/admin/users/me", "GET", 200, {
    id: "a1",
    email: `${role}@example.com`,
    name: null,
    role,
    isActive: true,
    lastLoginAt: null,
    mustChangePassword: false,
    createdAt: "2026-01-01T00:00:00.000Z",
    updatedAt: "2026-01-01T00:00:00.000Z",
  });

const hazard = (i: number) => ({
  id: `hz-${i}`,
  title: `Alert ${i}`,
  description: "d",
  aiSummary: null,
  severity: "info",
  severityBand: "info",
  callsToAction: [],
  latitude: null,
  longitude: null,
  locationName: null,
  categoryId: "cat-1",
  category: null,
  sourceId: null,
  source: null,
  reportedById: "u1",
  reportedBy: { id: "u1", name: "Jamie", xpPoints: 0, reliabilityScore: 0, reportsStatus: "unverified" },
  isAwsCompliant: false,
  reviewStatus: "pending",
  reviewFeedback: null,
  reviewedAt: null,
  reviewedById: null,
  confidenceScore: 50,
  corroborationCount: 0,
  medias: [],
  occurredAt: "2026-08-22T00:00:00.000Z",
  createdAt: "2026-08-22T00:00:00.000Z",
  updatedAt: "2026-08-22T00:00:00.000Z",
  expiresAt: null,
});

const params = (url: string) => new URL(url).searchParams;

/** Records every GET to `path` and answers with `body(url)`. */
const recordingRoute = (path: string, body: (url: string) => unknown) => {
  const urls: string[] = [];
  return {
    urls,
    route: {
      match: (url: string, method: string) => url.includes(path) && method === "GET",
      respond: (url: string) => {
        urls.push(url);
        return { status: 200, body: body(url) };
      },
    },
  };
};

const renderWithAuth = (ui: ReactElement) =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>{ui}</ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "t", refreshToken: "r" });
});

describe("Alerts page filters", () => {
  it("sends userReported=false for Official only and showExpired=true for Show expired", async () => {
    const hazards = recordingRoute("/api/admin/hazards", () => []);
    installMockFetch([me(), hazards.route]);
    renderWithAuth(<AlertsPage />);
    await screen.findByText(/no alerts match/i);

    // Default: no origin filter, expired alerts hidden.
    const first = params(hazards.urls[0]!);
    expect(first.get("userReported")).toBeNull();
    expect(first.get("showExpired")).toBeNull();
    expect(first.get("page")).toBe("1");

    await userEvent.selectOptions(screen.getByDisplayValue("Official + Community"), "official");
    await waitFor(() =>
      expect(params(hazards.urls.at(-1)!).get("userReported")).toBe("false"),
    );

    await userEvent.selectOptions(screen.getByDisplayValue("Official only"), "community");
    await waitFor(() => expect(params(hazards.urls.at(-1)!).get("userReported")).toBe("true"));

    await userEvent.click(screen.getByLabelText("Show expired"));
    await waitFor(() => expect(params(hazards.urls.at(-1)!).get("showExpired")).toBe("true"));
  });

  it("debounces the search box into one request", async () => {
    const hazards = recordingRoute("/api/admin/hazards", () => []);
    installMockFetch([me(), hazards.route]);
    renderWithAuth(<AlertsPage />);
    await screen.findByText(/no alerts match/i);
    const before = hazards.urls.length;

    await userEvent.type(screen.getByPlaceholderText(/search title/i), "bushfire");
    await waitFor(() =>
      expect(hazards.urls.some((u) => params(u).get("searchString") === "bushfire")).toBe(true),
    );
    const searched = hazards.urls.slice(before).filter((u) => params(u).get("searchString"));
    // Every partial word ("b", "bu", ...) was skipped.
    expect(searched).toHaveLength(1);
  });

  it("pages with Previous/Next and goes back to page 1 when a filter changes", async () => {
    const hazards = recordingRoute("/api/admin/hazards", (url) =>
      params(url).get("page") === "1"
        ? Array.from({ length: 50 }, (_, i) => hazard(i))
        : [hazard(100)],
    );
    installMockFetch([me(), hazards.route]);
    renderWithAuth(<AlertsPage />);

    await screen.findByText("Alert 0");
    expect(screen.getByText("Page 1")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Previous" })).toBeDisabled();

    await userEvent.click(screen.getByRole("button", { name: "Next" }));
    await screen.findByText("Alert 100");
    expect(params(hazards.urls.at(-1)!).get("page")).toBe("2");
    expect(params(hazards.urls.at(-1)!).get("pageSize")).toBe("50");
    expect(screen.getByText("Page 2 of 2")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Next" })).toBeDisabled();

    await userEvent.selectOptions(screen.getByDisplayValue("All statuses"), "pending");
    await waitFor(() => {
      const last = params(hazards.urls.at(-1)!);
      expect(last.get("reviewStatus")).toBe("pending");
      expect(last.get("page")).toBe("1");
    });
  });
});

describe("Moderation page", () => {
  it("only asks for community reports, and can include expired ones", async () => {
    const hazards = recordingRoute("/api/admin/hazards", () => []);
    installMockFetch([me(), hazards.route]);
    renderWithAuth(<ModerationPage />);
    await screen.findByText(/no pending reports/i);

    const first = params(hazards.urls[0]!);
    expect(first.get("userReported")).toBe("true");
    expect(first.get("reviewStatus")).toBe("pending");
    expect(first.get("showExpired")).toBeNull();

    await userEvent.click(screen.getByLabelText("Show expired"));
    await waitFor(() => {
      const last = params(hazards.urls.at(-1)!);
      expect(last.get("showExpired")).toBe("true");
      expect(last.get("userReported")).toBe("true");
    });
  });
});

describe("Users, Sources and Audit Log paging", () => {
  it("Users shows Page X of Y from the backend total", async () => {
    const users = recordingRoute("/api/admin/users/app-users", (url) => ({
      total: 120,
      page: Number(params(url).get("page")),
      pageSize: 50,
      users: [
        {
          id: `u-${params(url).get("page")}`,
          email: `user${params(url).get("page")}@example.com`,
          name: null,
          locationName: null,
          xpPoints: 0,
          reliabilityScore: 0,
          streakDays: 0,
          isOnboardingCompleted: true,
          lastActivityDate: null,
          deletionRequestedAt: null,
          scheduledDeletionAt: null,
          createdAt: "2026-01-01T00:00:00.000Z",
          updatedAt: "2026-01-01T00:00:00.000Z",
          _count: { hazardsReported: 0, devices: 0 },
        },
      ],
    }));
    installMockFetch([me(), users.route]);
    renderWithAuth(<UsersPage />);

    await screen.findByText("user1@example.com");
    expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
    await userEvent.click(screen.getByRole("button", { name: "Next" }));
    await screen.findByText("user2@example.com");
    expect(screen.getByText("Page 2 of 3")).toBeInTheDocument();
    expect(params(users.urls.at(-1)!).get("page")).toBe("2");
  });

  it("Sources and Audit Log request page and pageSize", async () => {
    const sources = recordingRoute("/api/admin/hazard-sources", () => []);
    const audit = recordingRoute("/api/admin/audit-log", () => []);
    installMockFetch([me(), sources.route, audit.route]);
    renderWithAuth(
      <>
        <SourcesPage />
        <AuditLogPage />
      </>,
    );
    await screen.findByText(/no sources match/i);
    await screen.findByText(/no audit entries match/i);
    expect(params(sources.urls[0]!).get("page")).toBe("1");
    expect(params(sources.urls[0]!).get("pageSize")).toBe("50");
    expect(params(audit.urls[0]!).get("page")).toBe("1");
    expect(params(audit.urls[0]!).get("pageSize")).toBe("50");
  });
});

describe("Navigation", () => {
  it("hides Audit Log from moderators", async () => {
    installMockFetch([me("moderator")]);
    renderWithAuth(<Layout />);
    await screen.findByText("Role: moderator");
    expect(screen.getByRole("link", { name: "Alerts" })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Audit Log" })).not.toBeInTheDocument();
  });

  it("shows Audit Log to admins", async () => {
    installMockFetch([me("admin")]);
    renderWithAuth(<Layout />);
    await screen.findByText("Role: admin");
    expect(screen.getByRole("link", { name: "Audit Log" })).toBeInTheDocument();
  });
});

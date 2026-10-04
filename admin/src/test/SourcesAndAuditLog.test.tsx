import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { SourcesPage } from "../pages/SourcesPage";
import { AuditLogPage } from "../pages/AuditLogPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch } from "./mockFetch";

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "t", refreshToken: "r" });
});

const renderWith = (page: React.ReactNode) =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>{page}</ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );

const meRoute = {
  match: (url: string) => url.includes("/api/admin/users/me"),
  respond: () => ({
    status: 200,
    body: {
      id: "a1",
      email: "admin@example.com",
      name: null,
      role: "admin",
      isActive: true,
      lastLoginAt: null,
      mustChangePassword: false,
      createdAt: "2026-01-01T00:00:00.000Z",
      updatedAt: "2026-01-01T00:00:00.000Z",
    },
  }),
};

const source = {
  id: "rfs",
  name: "NSW Rural Fire Service",
  url: "https://www.rfs.nsw.gov.au",
  imageUrl: null,
  advisoryText: null,
  copyrightText: null,
  copyrightLink: null,
  license: null,
  hazardsCount: 4,
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
  country: "Australia",
  region: "New South Wales",
  coverage: null,
  sourceType: null,
  authorityLevel: null,
  feedUrl: null,
  format: null,
  accessMethod: null,
  adapterKey: "rfs",
  scheduleMinutes: 15,
  secretRef: null,
  warningTypes: [],
  sourceNativeSeverity: "Advice / Watch and Act / Emergency Warning",
  sourceNativeSymbol: null,
  lifecycleStatus: "active",
  healthStatus: "failing",
  lastHealthCheck: "2026-09-30T00:00:00.000Z",
  lastSuccessfulFetch: null,
  lastAlertSeen: null,
  lastHealthError: "Failed to fetch rfs data: Bad Gateway",
  lastReviewedAt: "2026-01-01T00:00:00.000Z",
  expiryReviewAt: "2026-02-01T00:00:00.000Z",
  licensingNotes: "CC-BY 4.0",
};

describe("SourcesPage registry governance", () => {
  it("flags an overdue review, shows health, and saves review dates and licensing notes", async () => {
    const { calls } = installMockFetch([
      {
        match: (url: string, method: string) =>
          url.includes("/api/admin/hazard-sources") && method === "GET",
        respond: () => ({ status: 200, body: [source] }),
      },
      {
        match: (url: string, method: string) =>
          url.includes("/api/admin/hazard-sources/rfs") && method === "PUT",
        respond: () => ({ status: 200, body: source }),
      },
      meRoute,
    ]);

    renderWith(<SourcesPage />);

    await waitFor(() => expect(screen.getByText("NSW Rural Fire Service")).toBeInTheDocument());
    expect(screen.getByText("2026-02-01 (overdue)")).toBeInTheDocument();
    expect(screen.getByText("failing")).toHaveAttribute(
      "title",
      "Failed to fetch rfs data: Bad Gateway",
    );

    await userEvent.click(await screen.findByRole("button", { name: /configure source/i }));
    const notes = await screen.findByLabelText("Licensing and access terms");
    expect(notes).toHaveValue("CC-BY 4.0");
    expect(screen.getByLabelText("Source-native severity terms")).toHaveValue(
      "Advice / Watch and Act / Emergency Warning",
    );

    await userEvent.clear(notes);
    await userEvent.type(notes, "Attribution required");
    await userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(calls.some((c) => c.method === "PUT")).toBe(true));
    const put = calls.find((c) => c.method === "PUT");
    expect(put?.body).toMatchObject({
      licensingNotes: "Attribution required",
      expiryReviewAt: "2026-02-01T00:00:00.000Z",
    });
  });
});

describe("AuditLogPage", () => {
  it("lists who changed which source setting", async () => {
    installMockFetch([
      {
        match: (url: string, method: string) =>
          url.includes("/api/admin/audit-log") && method === "GET",
        respond: () => ({
          status: 200,
          body: [
            {
              id: "e1",
              adminId: "a1",
              admin: { id: "a1", email: "sarah@safetyalrt.com", name: null },
              action: "hazardSource.update",
              targetType: "HazardSource",
              targetId: "rfs",
              reason: null,
              before: { lifecycleStatus: "active" },
              after: { lifecycleStatus: "suspended" },
              createdAt: "2026-09-30T01:00:00.000Z",
            },
          ],
        }),
      },
      meRoute,
    ]);

    renderWith(<AuditLogPage />);

    await waitFor(() => expect(screen.getByText("hazardSource.update")).toBeInTheDocument());
    expect(screen.getByText("sarah@safetyalrt.com")).toBeInTheDocument();
    expect(screen.getByText('{"lifecycleStatus":"suspended"}')).toBeInTheDocument();
  });
});

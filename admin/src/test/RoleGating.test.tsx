import { render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { AlertsPage } from "../pages/AlertsPage";
import { AdminAccountsPage } from "../pages/AdminAccountsPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";

const HAZARD = {
  id: "hz-1",
  title: "Bushfire near Rockingham",
  description: "d",
  aiSummary: null,
  severity: "emergency",
  severityBand: "critical",
  callsToAction: [],
  latitude: null,
  longitude: null,
  locationName: null,
  categoryId: "cat-1",
  category: { id: "cat-1", name: "Fire", description: null, color: null, parentId: null, parent: null },
  sourceId: "src-1",
  source: { id: "src-1", name: "RFS", url: null, shape: null, advisoryText: null, copyrightText: null, copyrightLink: null, license: null },
  reportedById: null,
  reportedBy: null,
  isAwsCompliant: true,
  reviewStatus: "accepted",
  reviewFeedback: null,
  reviewedAt: null,
  reviewedById: null,
  confidenceScore: 90,
  corroborationCount: 0,
  medias: [],
  occurredAt: "2026-08-22T00:00:00.000Z",
  createdAt: "2026-08-22T00:00:00.000Z",
  updatedAt: "2026-08-22T00:00:00.000Z",
  expiresAt: null,
};

const adminProfile = (role: "moderator" | "admin" | "superAdmin") => ({
  id: "admin-1",
  email: `${role}@example.com`,
  name: null,
  role,
  isActive: true,
  lastLoginAt: null,
  mustChangePassword: false,
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
});

const renderAsRole = async (
  role: "moderator" | "admin" | "superAdmin",
  ui: React.ReactElement,
  extraRoutes: Parameters<typeof installMockFetch>[0] = [],
) => {
  saveTokens({ accessToken: "t", refreshToken: "r" });
  installMockFetch([
    jsonRoute("/api/admin/users/me", "GET", 200, adminProfile(role)),
    ...extraRoutes,
  ]);
  return render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>{ui}</ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );
};

beforeEach(() => {
  localStorage.clear();
});

describe("Role-gated UI (backend remains the real authority - this only checks what's shown)", () => {
  it("moderator does not see the Delete alert action", async () => {
    await renderAsRole("moderator", <AlertsPage />, [
      jsonRoute("/api/admin/hazards", "GET", 200, [HAZARD]),
    ]);
    await waitFor(() => expect(screen.getByText("Bushfire near Rockingham")).toBeInTheDocument());
    expect(screen.queryByRole("button", { name: /delete/i })).not.toBeInTheDocument();
  });

  it("admin sees the Delete alert action", async () => {
    await renderAsRole("admin", <AlertsPage />, [
      jsonRoute("/api/admin/hazards", "GET", 200, [HAZARD]),
    ]);
    await waitFor(() => expect(screen.getByText("Bushfire near Rockingham")).toBeInTheDocument());
    expect(screen.getByRole("button", { name: /delete/i })).toBeInTheDocument();
  });

  it("admin (not super admin) does not see New admin account", async () => {
    await renderAsRole("admin", <AdminAccountsPage />, [
      jsonRoute("/api/admin/users/admins", "GET", 200, []),
    ]);
    await waitFor(() => expect(screen.getByText(/no admin accounts found/i)).toBeInTheDocument());
    expect(screen.queryByRole("button", { name: /new admin account/i })).not.toBeInTheDocument();
  });

  it("super admin sees New admin account", async () => {
    await renderAsRole("superAdmin", <AdminAccountsPage />, [
      jsonRoute("/api/admin/users/admins", "GET", 200, []),
    ]);
    await waitFor(() => expect(screen.getByText(/no admin accounts found/i)).toBeInTheDocument());
    expect(screen.getByRole("button", { name: /new admin account/i })).toBeInTheDocument();
  });
});

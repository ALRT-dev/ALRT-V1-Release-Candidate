import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { AlertsPage } from "../pages/AlertsPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch } from "./mockFetch";

// VITE_ENABLE_DUMMY_ALERTS=true in admin/.env.test is what makes this
// button exist at all - vitest's default mode is "test", so it's already
// on in every test run here, same as the real TEST portal build. There is
// no production env file with this var set, which is what actually keeps
// the button out of a production build - see the build-output check run
// separately (not a vitest concern, since Vite inlines this at build time
// per-mode, not per-test).

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "t", refreshToken: "r" });
});

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

const renderPage = () =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>
          <AlertsPage />
        </ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );

describe("AlertsPage TEST-only Create Dummy Alert button", () => {
  it("creates the disposable source then the fixed dummy alert, and refreshes the list", async () => {
    const calls: { url: string; method: string; body: unknown }[] = [];
    installMockFetch([
      meRoute,
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "GET",
        respond: (url) => {
          calls.push({ url, method: "GET", body: undefined });
          return { status: 200, body: [] };
        },
      },
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazard-sources") && method === "POST",
        respond: (url, method, body) => {
          calls.push({ url, method, body });
          return {
            status: 201,
            body: { id: "test-dummy", name: "TEST DUMMY SOURCE - DO NOT USE", url: "https://example.invalid/test" },
          };
        },
      },
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "POST",
        respond: (url, method, body) => {
          calls.push({ url, method, body });
          return { status: 201, body: { id: "h1", title: "TEST — DO NOT USE", reviewStatus: "accepted" } };
        },
      },
    ]);

    renderPage();

    const button = await screen.findByRole("button", { name: /create dummy alert/i });
    await userEvent.click(button);

    await waitFor(() =>
      expect(screen.getByText(/created "TEST — DO NOT USE"/i)).toBeInTheDocument(),
    );

    const sourceCall = calls.find((c) => c.url.includes("hazard-sources"));
    const hazardCall = calls.find((c) => c.url.includes("/api/admin/hazards") && c.method === "POST");

    expect(sourceCall?.body).toMatchObject({ id: "test-dummy" });
    expect(hazardCall?.body).toMatchObject({
      title: "TEST — DO NOT USE",
      sourceId: "test-dummy",
      categoryId: "airQualityAlert",
    });
  });

  it("tolerates the disposable source already existing (400) and still creates the alert", async () => {
    installMockFetch([
      meRoute,
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => ({ status: 200, body: [] }),
      },
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazard-sources") && method === "POST",
        respond: () => ({ status: 400, body: { error: "A hazard source with this ID already exists" } }),
      },
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "POST",
        respond: () => ({ status: 201, body: { id: "h1", title: "TEST — DO NOT USE", reviewStatus: "accepted" } }),
      },
    ]);

    renderPage();

    const button = await screen.findByRole("button", { name: /create dummy alert/i });
    await userEvent.click(button);

    await waitFor(() =>
      expect(screen.getByText(/created "TEST — DO NOT USE"/i)).toBeInTheDocument(),
    );
  });
});

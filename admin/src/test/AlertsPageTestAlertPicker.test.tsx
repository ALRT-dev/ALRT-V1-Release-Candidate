import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { AlertsPage } from "../pages/AlertsPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch } from "./mockFetch";
import { TEST_ALERT_PRESETS } from "../data/testAlertPresets";

// VITE_ENABLE_DUMMY_ALERTS=true in admin/.env.test is what makes this
// button/picker exist at all - vitest's default mode is "test", so it's
// already on in every test run here, same as the real TEST portal build.
// There is no production env file with this var set, which is what
// actually keeps it out of a production build - see the build-output
// check run separately (not a vitest concern, since Vite inlines this at
// build time per-mode, not per-test).

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

describe("AlertsPage TEST-only Create Test Alert picker", () => {
  it("opens the picker and lists every preset", async () => {
    installMockFetch([
      meRoute,
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => ({ status: 200, body: [] }),
      },
    ]);

    renderPage();

    const openButton = await screen.findByRole("button", { name: /create test alert/i });
    await userEvent.click(openButton);

    for (const preset of TEST_ALERT_PRESETS) {
      expect(screen.getByRole("button", { name: preset.label })).toBeInTheDocument();
    }
  });

  it("creates the disposable source then the picked preset's fixed alert, and refreshes the list", async () => {
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
          return {
            status: 201,
            body: { id: "h1", title: "TEST — DO NOT USE — Fire", reviewStatus: "accepted" },
          };
        },
      },
    ]);

    renderPage();

    await userEvent.click(await screen.findByRole("button", { name: /create test alert/i }));
    await userEvent.click(await screen.findByRole("button", { name: "Fire" }));

    await waitFor(() =>
      expect(screen.getByText(/created "TEST — DO NOT USE — Fire"/i)).toBeInTheDocument(),
    );

    const sourceCall = calls.find((c) => c.url.includes("hazard-sources"));
    const hazardCall = calls.find((c) => c.url.includes("/api/admin/hazards") && c.method === "POST");

    expect(sourceCall?.body).toMatchObject({ id: "test-dummy" });
    expect(hazardCall?.body).toMatchObject({
      title: "TEST — DO NOT USE — Fire",
      sourceId: "test-dummy",
      categoryId: "bushfire",
      latitude: -31.89441,
      longitude: 115.75999,
      severity: "emergency",
      severityBand: "critical",
      useDummyAi: true,
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
        respond: () => ({
          status: 201,
          body: { id: "h1", title: "TEST — DO NOT USE — Flood/Weather", reviewStatus: "accepted" },
        }),
      },
    ]);

    renderPage();

    await userEvent.click(await screen.findByRole("button", { name: /create test alert/i }));
    await userEvent.click(await screen.findByRole("button", { name: "Flood / Weather" }));

    await waitFor(() =>
      expect(screen.getByText(/created "TEST — DO NOT USE — Flood\/Weather"/i)).toBeInTheDocument(),
    );
  });

  it("keeps the Air Quality preset on the deterministic no-AI template path (useDummyAi omitted/false)", async () => {
    const calls: { url: string; method: string; body: unknown }[] = [];
    installMockFetch([
      meRoute,
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => ({ status: 200, body: [] }),
      },
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazard-sources") && method === "POST",
        respond: () => ({ status: 400, body: { error: "already exists" } }),
      },
      {
        match: (url: string, method: string) => url.includes("/api/admin/hazards") && method === "POST",
        respond: (url, method, body) => {
          calls.push({ url, method, body });
          return {
            status: 201,
            body: { id: "h1", title: "TEST — DO NOT USE — Air Quality", reviewStatus: "accepted" },
          };
        },
      },
    ]);

    renderPage();

    await userEvent.click(await screen.findByRole("button", { name: /create test alert/i }));
    await userEvent.click(await screen.findByRole("button", { name: "Air Quality" }));

    await waitFor(() => expect(calls.length).toBeGreaterThan(0));

    expect(calls[0]?.body).toMatchObject({
      categoryId: "airQualityAlert",
      useDummyAi: false,
    });
  });
});

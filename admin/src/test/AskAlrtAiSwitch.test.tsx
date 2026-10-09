import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { AskAlrtAiSwitch } from "../components/AskAlrtAiSwitch";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";
import type { AdminRole } from "../api/types";

const me = (role: AdminRole) =>
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

const renderSwitch = () =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>
          <AskAlrtAiSwitch />
        </ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "t", refreshToken: "r" });
});

describe("Ask ALRT AI switch", () => {
  it("lets an admin turn AI answers off, after confirming", async () => {
    let enabled = true;
    const { calls } = installMockFetch([
      me("admin"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/config") && method === "GET",
        respond: () => ({ status: 200, body: { enabled, forcedOffByEnv: false } }),
      },
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/config") && method === "PUT",
        respond: (_url, _method, body) => {
          enabled = (body as { enabled: boolean }).enabled;
          return { status: 200, body: { enabled, forcedOffByEnv: false } };
        },
      },
    ]);
    renderSwitch();

    const toggle = await screen.findByRole("switch");
    expect(toggle).toBeChecked();
    expect(screen.getByText("AI answers are on")).toBeInTheDocument();
    await waitFor(() => expect(toggle).toBeEnabled());

    await userEvent.click(toggle);
    const dialog = screen.getByText("Turn off AI answers?").closest(".modal") as HTMLElement;
    expect(within(dialog).getByText("Library and emergency-number answers keep working.")).toBeInTheDocument();
    // Nothing is sent until the admin confirms.
    expect(calls.some((c) => c.method === "PUT")).toBe(false);

    await userEvent.click(within(dialog).getByRole("button", { name: "Turn off" }));

    await waitFor(() => expect(screen.getByText("AI answers are off")).toBeInTheDocument());
    const put = calls.find((c) => c.method === "PUT");
    expect(put?.url).toContain("/api/admin/ask-alrt/config");
    expect(put?.body).toEqual({ enabled: false });
  });

  it("does nothing when the confirm dialog is cancelled", async () => {
    const { calls } = installMockFetch([
      me("admin"),
      jsonRoute("/api/admin/ask-alrt/config", "GET", 200, { enabled: true, forcedOffByEnv: false }),
    ]);
    renderSwitch();
    const toggle = await screen.findByRole("switch");
    await waitFor(() => expect(toggle).toBeEnabled());
    await userEvent.click(toggle);
    await userEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(screen.queryByText("Turn off AI answers?")).not.toBeInTheDocument();
    expect(calls.some((c) => c.method === "PUT")).toBe(false);
    expect(screen.getByRole("switch")).toBeChecked();
  });

  it("is read-only for a moderator", async () => {
    installMockFetch([
      me("moderator"),
      jsonRoute("/api/admin/ask-alrt/config", "GET", 200, { enabled: true, forcedOffByEnv: false }),
    ]);
    renderSwitch();
    await screen.findByText(/only an admin or super admin can change this/i);
    expect(screen.getByRole("switch")).toBeDisabled();
    expect(screen.getByRole("switch")).toBeChecked();
  });

  it("is disabled, with an explanation, when the server environment forces AI off", async () => {
    installMockFetch([
      me("superAdmin"),
      jsonRoute("/api/admin/ask-alrt/config", "GET", 200, { enabled: true, forcedOffByEnv: true }),
    ]);
    renderSwitch();
    expect(await screen.findByText(/turned off by this server's environment settings/i)).toBeInTheDocument();
    expect(screen.getByRole("switch")).toBeDisabled();
    expect(screen.getByRole("switch")).not.toBeChecked();
    expect(screen.getByText("AI answers are off")).toBeInTheDocument();
  });
});

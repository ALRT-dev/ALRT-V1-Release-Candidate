import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { AskAlrtLibraryPage } from "../pages/AskAlrtLibraryPage";
import { EmergencyNumbersPage } from "../pages/EmergencyNumbersPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch } from "./mockFetch";
import type { ReactElement } from "react";

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "t", refreshToken: "r" });
});

const renderPage = (page: ReactElement) =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>{page}</ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );

const meRoute = (role: string) => ({
  match: (url: string) => url.includes("/api/admin/users/me"),
  respond: () => ({
    status: 200,
    body: {
      id: "a1",
      email: "admin@example.com",
      name: null,
      role,
      isActive: true,
      lastLoginAt: null,
      mustChangePassword: false,
      createdAt: "2026-01-01T00:00:00.000Z",
      updatedAt: "2026-01-01T00:00:00.000Z",
    },
  }),
});

const entry = (over: Record<string, unknown> = {}) => ({
  id: "send_sos",
  triggers: ["how do i send an sos"],
  keywords: ["sos"],
  answer: "Open the SOS screen and hold the button for 3 seconds to send it.",
  enabled: true,
  origin: "built_in",
  hasBuiltIn: true,
  updatedAt: null,
  updatedBy: null,
  ...over,
});

describe("AskAlrtLibraryPage", () => {
  it("lists answers with their source", async () => {
    installMockFetch([
      meRoute("admin"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/entries") && method === "GET",
        respond: () => ({
          status: 200,
          body: [entry(), entry({ id: "mine", origin: "custom", hasBuiltIn: false, triggers: ["my question"] })],
        }),
      },
    ]);
    renderPage(<AskAlrtLibraryPage />);
    expect(await screen.findByText("how do i send an sos")).toBeInTheDocument();
    expect(screen.getByText("Built in")).toBeInTheDocument();
    expect(screen.getByText("Added by you")).toBeInTheDocument();
  });

  it("a moderator can view but not add or edit", async () => {
    installMockFetch([
      meRoute("moderator"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/entries") && method === "GET",
        respond: () => ({ status: 200, body: [entry()] }),
      },
    ]);
    renderPage(<AskAlrtLibraryPage />);
    await screen.findByText("how do i send an sos");
    await waitFor(() => expect(screen.queryByRole("button", { name: "Add answer" })).not.toBeInTheDocument());
    expect(screen.getByRole("button", { name: "View" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Edit" })).not.toBeInTheDocument();
  });

  it("blocks saving an answer with a dash or phone number, then saves a good one after confirming", async () => {
    const user = userEvent.setup();
    const { calls } = installMockFetch([
      meRoute("admin"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/entries") && method === "GET",
        respond: () => ({ status: 200, body: [entry()] }),
      },
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/entries/send_sos") && method === "PUT",
        respond: (_url, _method, body) => ({
          status: 200,
          body: { ...entry({ origin: "customised" }), ...(body as object) },
        }),
      },
    ]);
    renderPage(<AskAlrtLibraryPage />);
    await user.click(await screen.findByRole("button", { name: "Edit" }));

    const answer = screen.getByLabelText("Answer");
    await user.clear(answer);
    await user.type(answer, "Hold the button for 3 seconds – then confirm it.");
    expect(screen.getByText(/No en or em dashes/)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Save answer" })).toBeDisabled();

    await user.clear(answer);
    await user.type(answer, "Call 0412 345 678 for help with this problem.");
    expect(screen.getByText(/No phone numbers/)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Save answer" })).toBeDisabled();

    await user.clear(answer);
    await user.type(answer, "Hold the button for 3 seconds, then confirm it.");
    const save = screen.getByRole("button", { name: "Save answer" });
    expect(save).toBeEnabled();
    await user.click(save);

    const dialog = await screen.findByRole("dialog").catch(() => document.body);
    await user.click(within(dialog as HTMLElement).getByRole("button", { name: "Save and publish" }));

    await waitFor(() => {
      const put = calls.find((c) => c.method === "PUT");
      expect(put).toBeDefined();
      expect(put?.body).toMatchObject({
        answer: "Hold the button for 3 seconds, then confirm it.",
        triggers: ["how do i send an sos"],
        keywords: ["sos"],
        enabled: true,
      });
    });
  });
});

const row = (over: Record<string, unknown> = {}) => ({
  iso: "AU",
  name: "Australia",
  number: "000",
  isDefault: true,
  defaultNumber: "000",
  ...over,
});

describe("EmergencyNumbersPage", () => {
  it("lists countries and marks saved edits against the starting list", async () => {
    installMockFetch([
      meRoute("admin"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/emergency-numbers") && method === "GET",
        respond: () => ({
          status: 200,
          body: [row(), row({ iso: "NZ", name: "New Zealand", number: "112", isDefault: false, defaultNumber: "111" })],
        }),
      },
    ]);
    renderPage(<EmergencyNumbersPage />);
    expect(await screen.findByText("Australia")).toBeInTheDocument();
    expect(screen.getByText("starting list: 111")).toBeInTheDocument();
    expect(screen.getByText("Saved")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Reset" })).toBeInTheDocument();
  });

  it("rejects a malformed number, then saves a valid new country after confirming", async () => {
    const user = userEvent.setup();
    const { calls } = installMockFetch([
      meRoute("admin"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/emergency-numbers") && method === "GET",
        respond: () => ({ status: 200, body: [row()] }),
      },
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/emergency-numbers") && method === "PUT",
        respond: (_url, _method, body) => ({
          status: 200,
          body: { ...(body as object), isDefault: false, defaultNumber: null },
        }),
      },
    ]);
    renderPage(<EmergencyNumbersPage />);
    await user.click(await screen.findByRole("button", { name: "Add country" }));

    await user.type(screen.getByLabelText("Country code"), "jp");
    await user.type(screen.getByLabelText("Country name"), "Japan");
    await user.type(screen.getByLabelText("Emergency number"), "1-1-0");
    expect(screen.getByRole("button", { name: "Save number" })).toBeDisabled();

    await user.clear(screen.getByLabelText("Emergency number"));
    await user.type(screen.getByLabelText("Emergency number"), "110");
    await user.click(screen.getByRole("button", { name: "Save number" }));

    const confirmButtons = await screen.findAllByRole("button", { name: "Save number" });
    await user.click(confirmButtons[confirmButtons.length - 1]!);

    await waitFor(() => {
      const put = calls.find((c) => c.method === "PUT");
      expect(put?.body).toEqual({ iso: "JP", number: "110", name: "Japan" });
    });
  });

  it("a moderator sees the list with no edit controls", async () => {
    installMockFetch([
      meRoute("moderator"),
      {
        match: (url, method) => url.includes("/api/admin/ask-alrt/emergency-numbers") && method === "GET",
        respond: () => ({ status: 200, body: [row()] }),
      },
    ]);
    renderPage(<EmergencyNumbersPage />);
    await screen.findByText("Australia");
    await waitFor(() => expect(screen.queryByRole("button", { name: "Add country" })).not.toBeInTheDocument());
    expect(screen.queryByRole("button", { name: "Edit" })).not.toBeInTheDocument();
  });
});

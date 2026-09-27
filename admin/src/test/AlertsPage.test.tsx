import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { AlertsPage } from "../pages/AlertsPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch } from "./mockFetch";

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "t", refreshToken: "r" });
});

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

describe("AlertsPage search/filter", () => {
  it("re-fetches with the typed search string as a query parameter", async () => {
    const seenUrls: string[] = [];
    installMockFetch([
      {
        match: (url, method) => url.includes("/api/admin/hazards") && method === "GET",
        respond: (url) => {
          seenUrls.push(url);
          return { status: 200, body: [] };
        },
      },
      {
        match: (url) => url.includes("/api/admin/users/me"),
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
      },
    ]);

    renderPage();
    await waitFor(() => expect(screen.getByText(/no alerts match/i)).toBeInTheDocument());

    await userEvent.type(screen.getByPlaceholderText(/search title/i), "flood");
    await waitFor(() =>
      expect(seenUrls.some((u) => u.includes("searchString=flood"))).toBe(true),
    );

    await userEvent.selectOptions(screen.getByDisplayValue(/all statuses/i), "pending");
    await waitFor(() =>
      expect(
        seenUrls.some((u) => u.includes("searchString=flood") && u.includes("reviewStatus=pending")),
      ).toBe(true),
    );
  });
});

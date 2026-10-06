import { act, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider, useAuth } from "../auth/AuthContext";
import { loadTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";

const ADMIN_PROFILE = {
  id: "admin-1",
  email: "mod@example.com",
  name: "Mod",
  role: "moderator",
  isActive: true,
  lastLoginAt: null,
  mustChangePassword: false,
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
};

const Probe = () => {
  const { status, admin, login, logout, hasRole } = useAuth();
  return (
    <div>
      <div data-testid="status">{status}</div>
      <div data-testid="email">{admin?.email ?? "none"}</div>
      <div data-testid="is-moderator">{String(hasRole("moderator"))}</div>
      <div data-testid="is-admin">{String(hasRole("admin", "superAdmin"))}</div>
      <button onClick={() => void login("mod@example.com", "password123!")}>login</button>
      <button onClick={() => void logout()}>logout</button>
    </div>
  );
};

const renderProbe = () =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <Probe />
      </AuthProvider>
    </MemoryRouter>,
  );

beforeEach(() => {
  localStorage.clear();
});

describe("AuthContext", () => {
  it("starts unauthenticated with no stored tokens", async () => {
    installMockFetch([]);
    renderProbe();
    await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("unauthenticated"));
  });

  it("logs in, stores tokens, and exposes the admin's role", async () => {
    installMockFetch([
      jsonRoute("/api/admin/auth/login", "POST", 200, {
        accessToken: "access-1",
        refreshToken: "refresh-1",
        mustChangePassword: false,
      }),
      jsonRoute("/api/admin/users/me", "GET", 200, ADMIN_PROFILE),
    ]);

    renderProbe();
    await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("unauthenticated"));

    await act(async () => {
      await userEvent.click(screen.getByText("login"));
    });

    await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("authenticated"));
    expect(screen.getByTestId("email")).toHaveTextContent("mod@example.com");
    expect(screen.getByTestId("is-moderator")).toHaveTextContent("true");
    expect(screen.getByTestId("is-admin")).toHaveTextContent("false");
    expect(loadTokens()?.accessToken).toBe("access-1");
  });

  it("clears tokens and returns to unauthenticated on logout", async () => {
    installMockFetch([
      jsonRoute("/api/admin/auth/login", "POST", 200, {
        accessToken: "access-1",
        refreshToken: "refresh-1",
        mustChangePassword: false,
      }),
      jsonRoute("/api/admin/users/me", "GET", 200, ADMIN_PROFILE),
      jsonRoute("/api/admin/auth/logout", "POST", 200, { success: true }),
    ]);

    renderProbe();
    await act(async () => {
      await userEvent.click(screen.getByText("login"));
    });
    await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("authenticated"));

    await act(async () => {
      await userEvent.click(screen.getByText("logout"));
    });

    await waitFor(() => expect(screen.getByTestId("status")).toHaveTextContent("unauthenticated"));
    expect(loadTokens()).toBeNull();
  });
});

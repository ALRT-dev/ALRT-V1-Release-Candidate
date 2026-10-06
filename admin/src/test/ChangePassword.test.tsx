import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter, useLocation } from "react-router-dom";
import App from "../App";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";
import type { MockRoute } from "./mockFetch";

const profile = (mustChangePassword: boolean) => ({
  id: "admin-1",
  email: "new@example.com",
  name: null,
  role: "admin",
  isActive: true,
  lastLoginAt: null,
  mustChangePassword,
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
});

const LocationProbe = () => {
  const location = useLocation();
  return <div data-testid="location">{location.pathname}</div>;
};

const renderApp = (path: string) =>
  render(
    <MemoryRouter initialEntries={[path]}>
      <App />
      <LocationProbe />
    </MemoryRouter>,
  );

/** /users/me reports mustChangePassword until change-password succeeds. */
const passwordFlowRoutes = (startsRequired: boolean) => {
  let required = startsRequired;
  const changeBodies: unknown[] = [];
  const routes: MockRoute[] = [
    {
      match: (url, method) => url.includes("/api/admin/users/me") && method === "GET",
      respond: () => ({ status: 200, body: profile(required) }),
    },
    {
      match: (url, method) => url.includes("/api/admin/auth/change-password") && method === "POST",
      respond: (_url, _method, body) => {
        changeBodies.push(body);
        required = false;
        return { status: 200, body: { success: true, message: "Password changed successfully" } };
      },
    },
    jsonRoute("/api/admin/hazards", "GET", 200, []),
  ];
  return { routes, changeBodies };
};

const NEW_PASSWORD = "Brand-New-Pass1!";

const fillAndSubmit = async (current = "Temp-Password1!") => {
  await userEvent.type(screen.getByLabelText("Current password"), current);
  await userEvent.type(screen.getByLabelText("New password"), NEW_PASSWORD);
  await userEvent.type(screen.getByLabelText("Confirm new password"), NEW_PASSWORD);
  await userEvent.click(screen.getByRole("button", { name: /^change password$/i }));
};

beforeEach(() => {
  localStorage.clear();
});

describe("First-login password change", () => {
  it("blocks every page until the password is changed, then continues to the page asked for", async () => {
    saveTokens({ accessToken: "t", refreshToken: "r" });
    const { routes, changeBodies } = passwordFlowRoutes(true);
    installMockFetch(routes);
    renderApp("/alerts");

    expect(await screen.findByRole("heading", { name: /change password/i })).toBeInTheDocument();
    expect(screen.getByTestId("location")).toHaveTextContent("/change-password");
    // No sidebar, so nothing else can be opened.
    expect(screen.queryByRole("link", { name: "Alerts" })).not.toBeInTheDocument();

    await fillAndSubmit();

    await waitFor(() => expect(screen.getByTestId("location")).toHaveTextContent("/alerts"));
    expect(await screen.findByRole("heading", { name: "Alerts" })).toBeInTheDocument();
    expect(changeBodies).toEqual([
      { currentPassword: "Temp-Password1!", newPassword: NEW_PASSWORD, confirmPassword: NEW_PASSWORD },
    ]);
  });

  it("routes to change password straight after a login that says mustChangePassword", async () => {
    const { routes } = passwordFlowRoutes(true);
    installMockFetch([
      jsonRoute("/api/admin/auth/login", "POST", 200, {
        accessToken: "a",
        refreshToken: "r",
        mustChangePassword: true,
      }),
      ...routes,
    ]);
    renderApp("/login");

    await userEvent.type(await screen.findByLabelText("Email"), "new@example.com");
    await userEvent.type(screen.getByLabelText("Password"), "Temp-Password1!");
    await userEvent.click(screen.getByRole("button", { name: /sign in/i }));

    expect(await screen.findByRole("heading", { name: /change password/i })).toBeInTheDocument();
    expect(screen.getByTestId("location")).toHaveTextContent("/change-password");
  });

  it("routes to change password when any API call returns PASSWORD_CHANGE_REQUIRED", async () => {
    saveTokens({ accessToken: "t", refreshToken: "r" });
    installMockFetch([
      // Profile says no change needed (e.g. flag set after the session began)...
      jsonRoute("/api/admin/users/me", "GET", 200, profile(false)),
      // ...but the backend refuses the page's own request.
      jsonRoute("/api/admin/hazards", "GET", 403, {
        error: "Password change required",
        code: "PASSWORD_CHANGE_REQUIRED",
      }),
    ]);
    renderApp("/alerts");

    expect(await screen.findByRole("heading", { name: /change password/i })).toBeInTheDocument();
    expect(screen.getByTestId("location")).toHaveTextContent("/change-password");
  });

  it("shows the backend's error and stays on the screen when the change fails", async () => {
    saveTokens({ accessToken: "t", refreshToken: "r" });
    installMockFetch([
      jsonRoute("/api/admin/users/me", "GET", 200, profile(true)),
      jsonRoute("/api/admin/auth/change-password", "POST", 400, {
        error: "New password must be different from current password",
      }),
    ]);
    renderApp("/");

    await screen.findByRole("heading", { name: /change password/i });
    await fillAndSubmit();

    expect(await screen.findByRole("alert")).toHaveTextContent(
      "New password must be different from current password",
    );
    expect(screen.getByTestId("location")).toHaveTextContent("/change-password");
  });

  it("keeps the submit button disabled until the new password meets the rules", async () => {
    saveTokens({ accessToken: "t", refreshToken: "r" });
    installMockFetch([jsonRoute("/api/admin/users/me", "GET", 200, profile(true))]);
    renderApp("/");

    await screen.findByRole("heading", { name: /change password/i });
    await userEvent.type(screen.getByLabelText("Current password"), "Temp-Password1!");
    await userEvent.type(screen.getByLabelText("New password"), "weak");
    await userEvent.type(screen.getByLabelText("Confirm new password"), "weak");
    expect(screen.getByRole("button", { name: /^change password$/i })).toBeDisabled();
    expect(screen.getByText("At least 12 characters")).toBeInTheDocument();
  });
});

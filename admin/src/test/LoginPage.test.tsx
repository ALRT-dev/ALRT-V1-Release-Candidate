import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { LoginPage } from "../pages/LoginPage";
import { installMockFetch, jsonRoute } from "./mockFetch";

beforeEach(() => {
  localStorage.clear();
});

const renderLogin = () =>
  render(
    <MemoryRouter initialEntries={["/login"]}>
      <AuthProvider>
        <LoginPage />
      </AuthProvider>
    </MemoryRouter>,
  );

describe("LoginPage", () => {
  it("shows an error message on a 401 (wrong credentials) without crashing", async () => {
    installMockFetch([jsonRoute("/api/admin/auth/login", "POST", 401, { error: "Invalid credentials" })]);
    renderLogin();

    await userEvent.type(screen.getByLabelText("Email"), "admin@example.com");
    await userEvent.type(screen.getByLabelText("Password"), "wrong-password");
    await userEvent.click(screen.getByRole("button", { name: /sign in/i }));

    await waitFor(() =>
      expect(screen.getByRole("alert")).toHaveTextContent(/incorrect email or password/i),
    );
  });

  it("shows a locked/disabled message on a 403", async () => {
    installMockFetch([jsonRoute("/api/admin/auth/login", "POST", 403, { error: "Admin account is temporarily locked" })]);
    renderLogin();

    await userEvent.type(screen.getByLabelText("Email"), "admin@example.com");
    await userEvent.type(screen.getByLabelText("Password"), "Password123!");
    await userEvent.click(screen.getByRole("button", { name: /sign in/i }));

    await waitFor(() =>
      expect(screen.getByRole("alert")).toHaveTextContent(/disabled or temporarily locked/i),
    );
  });
});

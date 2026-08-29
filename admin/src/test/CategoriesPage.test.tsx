import { render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { CategoriesPage } from "../pages/CategoriesPage";
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
          <CategoriesPage />
        </ToastProvider>
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

describe("CategoriesPage nested category rendering", () => {
  it("renders a subcategory missing its own subCategories/images fields without crashing, showing the supplied hazardsCount", async () => {
    installMockFetch([
      {
        match: (url: string, method: string) =>
          url.includes("/api/admin/categories") && method === "GET",
        respond: () => ({
          status: 200,
          body: [
            {
              id: "parent",
              name: "Parent Category",
              description: null,
              color: "#FC9493",
              isFireRelated: false,
              parentId: null,
              images: [],
              hazardsCount: 3,
              // Real GET /api/admin/categories shape: a subcategory entry
              // has no `subCategories` or `images` field of its own -
              // hazard_category.controller.ts only nests one level deep.
              // This is exactly what previously crashed CategoryRow's
              // recursive `.map`/`.find` before the `?? []` guards.
              subCategories: [
                {
                  id: "child",
                  name: "Child Category",
                  description: null,
                  color: "#FC9493",
                  isFireRelated: false,
                  parentId: "parent",
                  hazardsCount: 5,
                },
              ],
            },
          ],
        }),
      },
      meRoute,
    ]);

    renderPage();

    await waitFor(() => expect(screen.getByText("Parent Category")).toBeInTheDocument());
    // Reaching this line at all proves the recursive render didn't throw -
    // the child row (which has no subCategories/images of its own) rendered.
    expect(screen.getByText("Child Category")).toBeInTheDocument();
    expect(screen.getByText("3")).toBeInTheDocument();
    expect(screen.getByText("5")).toBeInTheDocument();
  });

  it("falls back to '-' when hazardsCount is absent", async () => {
    installMockFetch([
      {
        match: (url: string, method: string) =>
          url.includes("/api/admin/categories") && method === "GET",
        respond: () => ({
          status: 200,
          body: [
            {
              id: "parent",
              name: "No Count Category",
              description: null,
              color: null,
              isFireRelated: false,
              parentId: null,
              images: [],
              subCategories: [],
            },
          ],
        }),
      },
      meRoute,
    ]);

    renderPage();

    await waitFor(() => expect(screen.getByText("No Count Category")).toBeInTheDocument());
    // Both the "Active hazards" and "Description" columns fall back to "-"
    // for this category, so two dashes are expected on the row.
    expect(screen.getAllByText("-")).toHaveLength(2);
  });
});

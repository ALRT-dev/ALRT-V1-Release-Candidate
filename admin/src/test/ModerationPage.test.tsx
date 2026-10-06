import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "../auth/AuthContext";
import { ToastProvider } from "../components/ToastContext";
import { ModerationPage } from "../pages/ModerationPage";
import { saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";

const PENDING_HAZARD = {
  id: "hz-1",
  title: "Flooded road on Smith St",
  description: "Water over the road",
  aiSummary: null,
  severity: "unknown",
  severityBand: "info",
  callsToAction: [],
  latitude: null,
  longitude: null,
  locationName: null,
  categoryId: "cat-1",
  category: { id: "cat-1", name: "Flood", description: null, color: null, parentId: null, parent: null },
  sourceId: null,
  source: null,
  reportedById: "user-1",
  reportedBy: { id: "user-1", name: "Jamie", xpPoints: 0, reliabilityScore: 0, reportsStatus: "unverified" },
  isAwsCompliant: false,
  reviewStatus: "pending",
  reviewFeedback: null,
  reviewedAt: null,
  reviewedById: null,
  confidenceScore: 50,
  corroborationCount: 0,
  medias: [],
  occurredAt: "2026-08-22T00:00:00.000Z",
  createdAt: "2026-08-22T00:00:00.000Z",
  updatedAt: "2026-08-22T00:00:00.000Z",
  expiresAt: null,
};

beforeEach(() => {
  localStorage.clear();
  saveTokens({ accessToken: "token", refreshToken: "refresh" });
});

const renderPage = () =>
  render(
    <MemoryRouter>
      <AuthProvider>
        <ToastProvider>
          <ModerationPage />
        </ToastProvider>
      </AuthProvider>
    </MemoryRouter>,
  );

describe("ModerationPage", () => {
  it("shows a loading state, then the pending queue", async () => {
    installMockFetch([
      jsonRoute("/api/admin/hazards", "GET", 200, [PENDING_HAZARD]),
    ]);
    renderPage();

    expect(screen.getByText(/loading moderation queue/i)).toBeInTheDocument();
    await waitFor(() => expect(screen.getByText("Flooded road on Smith St")).toBeInTheDocument());
  });

  it("shows an empty state when there are no pending reports", async () => {
    installMockFetch([jsonRoute("/api/admin/hazards", "GET", 200, [])]);
    renderPage();
    await waitFor(() => expect(screen.getByText(/no pending reports/i)).toBeInTheDocument());
  });

  it("shows an error state on a failed fetch, with a working retry", async () => {
    let calls = 0;
    installMockFetch([
      {
        match: (url, method) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => {
          calls += 1;
          if (calls === 1) return { status: 500, body: { error: "boom" } };
          return { status: 200, body: [PENDING_HAZARD] };
        },
      },
    ]);
    renderPage();

    await waitFor(() => expect(screen.getByRole("alert")).toBeInTheDocument());
    await userEvent.click(screen.getByRole("button", { name: /retry/i }));
    await waitFor(() => expect(screen.getByText("Flooded road on Smith St")).toBeInTheDocument());
  });

  it("approves a pending report and refreshes the list", async () => {
    let approveCalled = false;
    installMockFetch([
      {
        match: (url, method) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => ({
          status: 200,
          body: approveCalled ? [] : [PENDING_HAZARD],
        }),
      },
      {
        match: (url, method) => url.includes("/hazards/hz-1/review") && method === "PATCH",
        respond: (_url, _method, body) => {
          approveCalled = true;
          expect((body as { reviewStatus: string }).reviewStatus).toBe("accepted");
          return { status: 200, body: { ...PENDING_HAZARD, reviewStatus: "accepted" } };
        },
      },
    ]);
    renderPage();

    await waitFor(() => expect(screen.getByText("Flooded road on Smith St")).toBeInTheDocument());
    await userEvent.click(screen.getByRole("button", { name: /^approve$/i }));

    await waitFor(() => expect(screen.getByText(/no pending reports/i)).toBeInTheDocument());
  });

  it("requires a reason before a reject confirms", async () => {
    installMockFetch([jsonRoute("/api/admin/hazards", "GET", 200, [PENDING_HAZARD])]);
    renderPage();

    await waitFor(() => expect(screen.getByText("Flooded road on Smith St")).toBeInTheDocument());
    await userEvent.click(screen.getByRole("button", { name: /^reject$/i }));

    const dialog = screen.getByText("Reject report").closest(".modal") as HTMLElement;
    const confirmButton = within(dialog).getByRole("button", { name: /^reject$/i });
    expect(confirmButton).toBeDisabled();

    await userEvent.type(within(dialog).getByLabelText(/rejection reason/i), "Duplicate report");
    expect(confirmButton).toBeEnabled();
  });

  it("rejects with a reason and refreshes the list", async () => {
    let rejectBody: unknown = null;
    let rejected = false;
    installMockFetch([
      {
        match: (url, method) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => ({ status: 200, body: rejected ? [] : [PENDING_HAZARD] }),
      },
      {
        match: (url, method) => url.includes("/hazards/hz-1/review") && method === "PATCH",
        respond: (_url, _method, body) => {
          rejectBody = body;
          rejected = true;
          return { status: 200, body: { ...PENDING_HAZARD, reviewStatus: "rejected" } };
        },
      },
    ]);
    renderPage();

    await waitFor(() => expect(screen.getByText("Flooded road on Smith St")).toBeInTheDocument());
    await userEvent.click(screen.getByRole("button", { name: /^reject$/i }));
    const dialog = screen.getByText("Reject report").closest(".modal") as HTMLElement;
    await userEvent.type(within(dialog).getByLabelText(/rejection reason/i), "Spam");
    await userEvent.click(within(dialog).getByRole("button", { name: /^reject$/i }));

    await waitFor(() => expect(screen.getByText(/no pending reports/i)).toBeInTheDocument());
    expect(rejectBody).toEqual({ reviewStatus: "rejected", reviewFeedback: "Spam" });
  });
});

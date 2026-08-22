import { beforeEach, describe, expect, it, vi } from "vitest";
import { apiGet, ApiError, registerSessionExpiredHandler } from "../api/client";
import { clearTokens, loadTokens, saveTokens } from "../api/tokenStorage";
import { installMockFetch, jsonRoute } from "./mockFetch";

beforeEach(() => {
  localStorage.clear();
  vi.restoreAllMocks();
});

describe("apiRequest 401 handling", () => {
  it("silently refreshes the access token and retries once on a 401", async () => {
    saveTokens({ accessToken: "old-token", refreshToken: "refresh-token" });

    let hazardCalls = 0;
    installMockFetch([
      {
        match: (url, method) => url.includes("/api/admin/hazards") && method === "GET",
        respond: () => {
          hazardCalls += 1;
          if (hazardCalls === 1) {
            return { status: 401, body: { error: "Invalid or expired token" } };
          }
          return { status: 200, body: [{ id: "1" }] };
        },
      },
      jsonRoute("/api/admin/auth/refresh-token", "POST", 200, {
        accessToken: "new-token",
      }),
    ]);

    const result = await apiGet("/api/admin/hazards");
    expect(result).toEqual([{ id: "1" }]);
    expect(hazardCalls).toBe(2);
    expect(loadTokens()?.accessToken).toBe("new-token");
  });

  it("clears tokens and notifies the session-expired handler when refresh itself fails", async () => {
    saveTokens({ accessToken: "old-token", refreshToken: "bad-refresh-token" });
    const onExpired = vi.fn();
    registerSessionExpiredHandler(onExpired);

    installMockFetch([
      jsonRoute("/api/admin/hazards", "GET", 401, { error: "Invalid or expired token" }),
      jsonRoute("/api/admin/auth/refresh-token", "POST", 401, { error: "Invalid refresh token" }),
    ]);

    await expect(apiGet("/api/admin/hazards")).rejects.toThrow(ApiError);
    expect(loadTokens()).toBeNull();
    expect(onExpired).toHaveBeenCalledTimes(1);

    // Reset the module-level handler so later test files aren't affected.
    registerSessionExpiredHandler(() => {});
  });
});

describe("apiRequest 403 handling", () => {
  it("throws an ApiError with status 403 without attempting a refresh", async () => {
    saveTokens({ accessToken: "token", refreshToken: "refresh" });
    let refreshCalled = false;
    installMockFetch([
      jsonRoute("/api/admin/webhook-api-keys", "POST", 403, {
        error: "Insufficient permissions",
      }),
      {
        match: (url) => url.includes("/refresh-token"),
        respond: () => {
          refreshCalled = true;
          return { status: 200, body: { accessToken: "x" } };
        },
      },
    ]);

    const { apiPost } = await import("../api/client");
    try {
      await apiPost("/api/admin/webhook-api-keys", { name: "x" });
      expect.unreachable("expected a 403 to throw");
    } catch (error) {
      expect(error).toBeInstanceOf(ApiError);
      expect((error as ApiError).status).toBe(403);
    }
    expect(refreshCalled).toBe(false);
  });
});

describe("tokenStorage", () => {
  it("round-trips tokens through localStorage and clears them", () => {
    saveTokens({ accessToken: "a", refreshToken: "b" });
    expect(loadTokens()).toEqual({ accessToken: "a", refreshToken: "b" });
    clearTokens();
    expect(loadTokens()).toBeNull();
  });

  it("returns null for malformed stored data instead of throwing", () => {
    localStorage.setItem("alrt_admin_tokens", "{not json");
    expect(loadTokens()).toBeNull();
  });
});

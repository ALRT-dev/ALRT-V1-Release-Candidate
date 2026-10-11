/**
 * Tests for R-01 / R-02: Apple and Microsoft OAuth email_verified checks.
 *
 * These tests verify that the auth controller rejects sign-in attempts when
 * the OAuth provider reports the email address as unverified, matching the
 * existing behaviour for Google OAuth.
 *
 * The controller functions are tested in isolation by mocking the service-layer
 * token verifiers and Prisma, so no database or network is needed.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks — must be set up before importing the controller
// ---------------------------------------------------------------------------

// Mock auth.service token verifiers
vi.mock("../services/auth.service.js", () => ({
  verifyAppleToken: vi.fn(),
  verifyGoogleToken: vi.fn(),
  verifyMicrosoftToken: vi.fn(),
  hashPassword: vi.fn(),
  comparePassword: vi.fn(),
}));

// Mock Prisma client
vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    user: {
      findUnique: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
    },
  },
}));

// Mock JWT utilities
vi.mock("../utils/jwt.util.js", () => ({
  signAccessToken: vi.fn().mockReturnValue("mock-access-token"),
  signRefreshToken: vi.fn().mockReturnValue("mock-refresh-token"),
  verifyRefreshToken: vi.fn(),
}));

// Mock config
vi.mock("../utils/config.js", () => ({
  config: {
    appleOAuth: { audience: "test-audience" },
    googleOAuth: {
      clientIdWeb: "test-web",
      clientIdIos: "test-ios",
      clientIdAndroid: "test-android",
    },
    microsoftOAuth: { clientId: "test-ms-client", tenantId: "common" },
    passwordReset: { baseUrl: "http://localhost" },
  },
}));

// Mock microsoft oauth client util (used by auth.service, but we mock the
// service layer so this just needs to exist)
vi.mock("../utils/microsoft_oauth_client.util.js", () => ({
  verifyMicrosoftIdToken: vi.fn(),
}));

// Mock google oauth client util
vi.mock("../utils/google_oauth_client.util.js", () => ({
  default: { verifyIdToken: vi.fn() },
}));

import {
  verifyAppleOAuth,
  verifyGoogleOAuth,
  verifyMicrosoftOAuth,
} from "../controllers/auth.controller.js";
import {
  verifyAppleToken,
  verifyGoogleToken,
  verifyMicrosoftToken,
} from "../services/auth.service.js";
import prisma from "../utils/prisma_client.util.js";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Builds a minimal Express-shaped request object. */
const mockReq = (body: Record<string, unknown> = {}) =>
  ({ body, protocol: "http", get: () => "localhost" }) as any;

/** Builds a minimal Express-shaped response object. */
const mockRes = () => {
  const res: any = {};
  res.status = vi.fn().mockReturnValue(res);
  res.json = vi.fn().mockReturnValue(res);
  return res;
};

/** A next() that captures whatever error is passed to it. */
const mockNext = () => {
  const next: any = vi.fn();
  return next;
};

// ---------------------------------------------------------------------------
// Apple OAuth — R-01
// ---------------------------------------------------------------------------

describe("verifyAppleOAuth – email_verified check (R-01)", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("rejects when Apple email_verified is 'false' (string)", async () => {
    (verifyAppleToken as any).mockResolvedValue({
      email: "alice@example.com",
      email_verified: "false",
    });

    const req = mockReq({ identityToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyAppleOAuth(req, res, next);

    expect(next).toHaveBeenCalledOnce();
    const err = next.mock.calls[0][0];
    expect(err).toBeDefined();
    expect(err.statusCode ?? err.status).toBe(401);
    expect(err.message).toMatch(/Apple.*not verified/i);
  });

  it("rejects when Apple email_verified is boolean false", async () => {
    (verifyAppleToken as any).mockResolvedValue({
      email: "alice@example.com",
      email_verified: false,
    });

    const req = mockReq({ identityToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyAppleOAuth(req, res, next);

    expect(next).toHaveBeenCalledOnce();
    const err = next.mock.calls[0][0];
    expect(err).toBeDefined();
    expect(err.statusCode ?? err.status).toBe(401);
  });

  it("allows sign-in when Apple email_verified is 'true' (string)", async () => {
    (verifyAppleToken as any).mockResolvedValue({
      email: "alice@example.com",
      email_verified: "true",
    });
    (prisma.user.findUnique as any).mockResolvedValue({ id: "u1", name: null });

    const req = mockReq({ identityToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyAppleOAuth(req, res, next);

    // Should NOT have called next with an error
    if (next.mock.calls.length > 0) {
      expect(next.mock.calls[0][0]).toBeUndefined();
    }
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ accessToken: expect.any(String) }),
    );
  });

  it("allows sign-in when Apple email_verified is boolean true", async () => {
    (verifyAppleToken as any).mockResolvedValue({
      email: "alice@example.com",
      email_verified: true,
    });
    (prisma.user.findUnique as any).mockResolvedValue({ id: "u1", name: null });

    const req = mockReq({ identityToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyAppleOAuth(req, res, next);

    if (next.mock.calls.length > 0) {
      expect(next.mock.calls[0][0]).toBeUndefined();
    }
    expect(res.status).toHaveBeenCalledWith(200);
  });

  it("allows sign-in when Apple email_verified is undefined (legacy tokens)", async () => {
    (verifyAppleToken as any).mockResolvedValue({
      email: "alice@example.com",
      // email_verified not present — older Apple tokens may omit it
    });
    (prisma.user.findUnique as any).mockResolvedValue({ id: "u1", name: null });

    const req = mockReq({ identityToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyAppleOAuth(req, res, next);

    if (next.mock.calls.length > 0) {
      expect(next.mock.calls[0][0]).toBeUndefined();
    }
    expect(res.status).toHaveBeenCalledWith(200);
  });
});

// ---------------------------------------------------------------------------
// Microsoft OAuth — R-02
// ---------------------------------------------------------------------------

describe("verifyMicrosoftOAuth – email_verified check (R-02)", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("rejects when Microsoft email_verified is false", async () => {
    (verifyMicrosoftToken as any).mockResolvedValue({
      email: "bob@example.com",
      name: "Bob",
      email_verified: false,
    });

    const req = mockReq({ idToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyMicrosoftOAuth(req, res, next);

    expect(next).toHaveBeenCalledOnce();
    const err = next.mock.calls[0][0];
    expect(err).toBeDefined();
    expect(err.statusCode ?? err.status).toBe(401);
    expect(err.message).toMatch(/Microsoft.*not verified/i);
  });

  it("allows sign-in when Microsoft email_verified is true", async () => {
    (verifyMicrosoftToken as any).mockResolvedValue({
      email: "bob@example.com",
      name: "Bob",
      email_verified: true,
    });
    (prisma.user.findUnique as any).mockResolvedValue({ id: "u2", name: "Bob" });

    const req = mockReq({ idToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyMicrosoftOAuth(req, res, next);

    if (next.mock.calls.length > 0) {
      expect(next.mock.calls[0][0]).toBeUndefined();
    }
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ accessToken: expect.any(String) }),
    );
  });

  it("allows sign-in when Microsoft email_verified is undefined (work/school accounts)", async () => {
    (verifyMicrosoftToken as any).mockResolvedValue({
      email: "bob@contoso.com",
      name: "Bob",
      // email_verified absent — work/school tokens are directory-verified
    });
    (prisma.user.findUnique as any).mockResolvedValue({ id: "u3", name: "Bob" });

    const req = mockReq({ idToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyMicrosoftOAuth(req, res, next);

    if (next.mock.calls.length > 0) {
      expect(next.mock.calls[0][0]).toBeUndefined();
    }
    expect(res.status).toHaveBeenCalledWith(200);
  });

  it("uses preferred_username when email field is absent", async () => {
    (verifyMicrosoftToken as any).mockResolvedValue({
      preferred_username: "carol@contoso.com",
      name: "Carol",
      email_verified: true,
    });
    (prisma.user.findUnique as any).mockResolvedValue(null);
    (prisma.user.create as any).mockResolvedValue({ id: "u4", name: "Carol" });

    const req = mockReq({ idToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyMicrosoftOAuth(req, res, next);

    if (next.mock.calls.length > 0) {
      expect(next.mock.calls[0][0]).toBeUndefined();
    }
    expect(prisma.user.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ email: "carol@contoso.com" }),
      }),
    );
  });
});

// ---------------------------------------------------------------------------
// Google OAuth — existing check (regression guard)
// ---------------------------------------------------------------------------

describe("verifyGoogleOAuth – email_verified (regression guard)", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("rejects when Google email_verified is not true", async () => {
    (verifyGoogleToken as any).mockResolvedValue({
      email: "dan@example.com",
      email_verified: false,
      exp: Math.floor(Date.now() / 1000) + 3600,
    });

    const req = mockReq({ idToken: "tok" });
    const res = mockRes();
    const next = mockNext();

    await verifyGoogleOAuth(req, res, next);

    expect(next).toHaveBeenCalledOnce();
    const err = next.mock.calls[0][0];
    expect(err).toBeDefined();
    expect(err.statusCode ?? err.status).toBe(401);
    expect(err.message).toMatch(/Google.*not verified/i);
  });
});

/**
 * Stage 9B verification script — real HTTP requests against a running
 * instance of this backend, backed by a real local Postgres+PostGIS
 * database, and a real (local, non-storing) SMTP server so reset emails
 * are genuinely sent and their links genuinely extracted from the wire,
 * not mocked.
 *
 * Setup: same throwaway Postgres+PostGIS pattern as prior stages' verify
 * scripts, plus a local debugging SMTP server:
 *   python3 -m smtpd -n -c DebuggingServer localhost:1025 > smtp.log &
 * See V1_RECONCILIATION_REPORT.md §27 for the exact commands. Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_stage9b_auth_completion.ts
 */

import assert from "node:assert/strict";
import fs from "node:fs/promises";
import { PrismaClient } from "@prisma/client";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const SMTP_LOG_PATH =
  process.env.SMTP_LOG_PATH ||
  "/tmp/claude-0/-home-user/3e788778-d800-5002-9f3a-31dcb92105b1/scratchpad/stage9b_smtp.log";

const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

const api = async (
  path: string,
  opts: { method?: string; token?: string; body?: unknown; form?: string } = {},
) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: opts.method ?? "GET",
    headers: {
      ...(opts.body !== undefined
        ? { "Content-Type": "application/json" }
        : {}),
      ...(opts.form !== undefined
        ? { "Content-Type": "application/x-www-form-urlencoded" }
        : {}),
      ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}),
    },
    ...(opts.body !== undefined ? { body: JSON.stringify(opts.body) } : {}),
    ...(opts.form !== undefined ? { body: opts.form } : {}),
  });
  let json: unknown = null;
  const text = await res.text();
  try {
    json = JSON.parse(text);
  } catch {
    json = text;
  }
  return { status: res.status, body: json };
};

/**
 * Python's smtpd DebuggingServer prints each raw line as a `b'...'` repr,
 * quoted-printable-encoded by nodemailer (soft line breaks on a trailing
 * `=`, `=XX` hex escapes). Unwraps one repr line back to its raw text.
 */
const unwrapReprLine = (line: string): string => {
  const match = line.match(/^b'(.*)'$/);
  if (!match) return "";
  return match[1]!.replace(/\\'/g, "'").replace(/\\"/g, '"');
};

/** Reverses quoted-printable soft line breaks and =XX escapes. */
const decodeQuotedPrintable = (lines: string[]): string => {
  let joined = "";
  for (const line of lines) {
    if (line.endsWith("=")) {
      joined += line.slice(0, -1);
    } else {
      joined += `${line}\n`;
    }
  }
  return joined.replace(/=([0-9A-Fa-f]{2})/g, (_, hex) =>
    String.fromCharCode(parseInt(hex, 16)),
  );
};

const decodedMessagesTo = async (email: string): Promise<string[]> => {
  const log = await fs.readFile(SMTP_LOG_PATH, "utf8");
  const rawMessages = log
    .split("---------- MESSAGE FOLLOWS ----------")
    .slice(1);
  const decoded: string[] = [];
  for (const raw of rawMessages) {
    const lines = raw.split("\n").map(unwrapReprLine);
    const text = decodeQuotedPrintable(lines);
    if (text.includes(`To: ${email}`)) decoded.push(text);
  }
  return decoded;
};

/**
 * Extracts the reset-password link most recently sent to [email] by
 * decoding the real SMTP debug log written by the local server used for
 * this run - the link genuinely traveled over SMTP, this isn't a stub.
 */
const extractResetLinkFor = async (email: string): Promise<string> => {
  const messages = await decodedMessagesTo(email);
  for (let i = messages.length - 1; i >= 0; i--) {
    const match = messages[i]!.match(
      /href="([^"]*\/reset-password\?token=[^"]+)"/,
    );
    if (match) return match[1]!.replace(/&amp;/g, "&");
  }
  throw new Error(`No reset link found in SMTP log for ${email}`);
};

const wasNoPasswordEmailSentTo = async (email: string): Promise<boolean> => {
  const messages = await decodedMessagesTo(email);
  return messages.some((m) => m.includes("About your Safety ALRT"));
};

const registerUser = async (label: string) => {
  const uniqueSuffix = crypto.randomUUID().slice(0, 8);
  const email = `stage9b-${label}-${uniqueSuffix}@test.local`;
  const password = "OriginalPass123!Xx";
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password },
  });
  assert.equal(res.status, 201, JSON.stringify(res.body));
  return {
    email,
    password,
    accessToken: (res.body as any).accessToken as string,
    refreshToken: (res.body as any).refreshToken as string,
  };
};

async function main() {
  console.log("Stage 9B verification (real HTTP + real DB + real SMTP)\n");

  console.log("§27 password reset - request never reveals whether an email exists");

  const user = await registerUser("resetflow");

  await check(
    "POST /password-reset/request for a REGISTERED email returns the generic message",
    async () => {
      const res = await api("/api/auth/password-reset/request", {
        method: "POST",
        body: { email: user.email },
      });
      assert.equal(res.status, 200);
      assert.match((res.body as any).message, /reset link has been sent/);
    },
  );

  await check(
    "POST /password-reset/request for an UNKNOWN email returns the identical response",
    async () => {
      const res = await api("/api/auth/password-reset/request", {
        method: "POST",
        body: { email: `nobody-${crypto.randomUUID()}@test.local` },
      });
      assert.equal(res.status, 200);
      assert.match((res.body as any).message, /reset link has been sent/);
    },
  );

  await check(
    "an OAuth-only account (no password) gets an informational email, not a reset link",
    async () => {
      const oauthEmail = `stage9b-oauth-${crypto.randomUUID().slice(0, 8)}@test.local`;
      // Created directly via Prisma - mirrors exactly what verifyGoogleOAuth
      // etc. leave behind: no passwordHash, so falsy per loginWithEmailAndPassword's
      // own check.
      await prisma.user.create({ data: { email: oauthEmail, name: "OAuth user" } });

      const res = await api("/api/auth/password-reset/request", {
        method: "POST",
        body: { email: oauthEmail },
      });
      assert.equal(res.status, 200);
      assert.match((res.body as any).message, /reset link has been sent/);
      assert.ok(
        await wasNoPasswordEmailSentTo(oauthEmail),
        "expected the social-login-only email, not a reset link",
      );
    },
  );

  console.log();
  console.log("§27 the real reset link, extracted from a real SMTP send");

  const resetLink = await extractResetLinkFor(user.email);
  const token = new URL(resetLink).searchParams.get("token")!;
  assert.ok(token.length > 20, "token should be a long random string");

  await check("GET the reset-password page with the valid token renders the form", async () => {
    const res = await fetch(resetLink);
    assert.equal(res.status, 200);
    const html = await res.text();
    assert.match(html, /Choose a new password/);
    assert.match(html, new RegExp(`value="${token}"`));
  });

  await check("GET with a garbage token renders the invalid/expired page (400)", async () => {
    const res = await fetch(`${BASE_URL}/reset-password?token=not-a-real-token`);
    assert.equal(res.status, 400);
    const html = await res.text();
    assert.match(html, /invalid or has expired/);
  });

  await check("POST with mismatched passwords is rejected and the form is shown again", async () => {
    const res = await api("/reset-password", {
      method: "POST",
      form: `token=${encodeURIComponent(token)}&newPassword=NewPass123!&confirmPassword=Different123!`,
    });
    assert.equal(res.status, 400);
    assert.match(res.body as string, /Passwords do not match/);
  });

  const NEW_PASSWORD = "BrandNewPass456!Xx";

  await check("POST with matching passwords and a valid token succeeds", async () => {
    const res = await api("/reset-password", {
      method: "POST",
      form: `token=${encodeURIComponent(token)}&newPassword=${encodeURIComponent(NEW_PASSWORD)}&confirmPassword=${encodeURIComponent(NEW_PASSWORD)}`,
    });
    assert.equal(res.status, 200);
    assert.match(res.body as string, /Password updated/);
  });

  console.log();
  console.log("§27 the new password works, the old one doesn't, the token can't be replayed");

  await check("login with the NEW password succeeds", async () => {
    const res = await api("/api/auth/email-password/login", {
      method: "POST",
      body: { email: user.email, password: NEW_PASSWORD },
    });
    assert.equal(res.status, 200);
  });

  await check("login with the OLD password is now rejected", async () => {
    const res = await api("/api/auth/email-password/login", {
      method: "POST",
      body: { email: user.email, password: user.password },
    });
    assert.equal(res.status, 400);
  });

  await check("replaying the SAME (already-used) token is rejected", async () => {
    const res = await api("/reset-password", {
      method: "POST",
      form: `token=${encodeURIComponent(token)}&newPassword=AnotherOne789!&confirmPassword=AnotherOne789!`,
    });
    assert.equal(res.status, 400);
    assert.match(res.body as string, /invalid or has expired/);
  });

  await check("an EXPIRED token (backdated in the DB, same token value) is rejected", async () => {
    // A second reset request/token, then simulate the clock passing - the
    // token itself is unchanged, only its recorded expiry moves to the past,
    // exactly what a real hour of elapsed time would do.
    await api("/api/auth/password-reset/request", {
      method: "POST",
      body: { email: user.email },
    });
    const expiredLink = await extractResetLinkFor(user.email);
    const expiredToken = new URL(expiredLink).searchParams.get("token")!;
    const crypto2 = await import("node:crypto");
    const tokenHash = crypto2
      .createHash("sha256")
      .update(expiredToken)
      .digest("hex");
    await prisma.passwordResetToken.update({
      where: { tokenHash },
      data: { expiresAt: new Date(Date.now() - 1000) },
    });

    const res = await api("/reset-password", {
      method: "POST",
      form: `token=${encodeURIComponent(expiredToken)}&newPassword=WontWork123!&confirmPassword=WontWork123!`,
    });
    assert.equal(res.status, 400);
    assert.match(res.body as string, /invalid or has expired/);
  });

  console.log();
  console.log("§27 session invalidation - a refresh token from before the reset stops working");

  await check(
    "the refresh token issued at registration (before the reset) is now rejected",
    async () => {
      const res = await api("/api/auth/refresh-token", {
        method: "POST",
        body: { refreshToken: user.refreshToken },
      });
      assert.equal(res.status, 401);
    },
  );

  // JWT `iat` is second-resolution, and the reset above and this login
  // happen fast enough in an automated run to land in the same wall-clock
  // second - which the controller deliberately treats as still-stale (see
  // its comment). A real login is never this fast after a real reset;
  // step past the second boundary so this check reflects that.
  await new Promise((resolve) => setTimeout(resolve, 1100));

  await check(
    "a FRESH refresh token from logging in with the new password still works",
    async () => {
      const login = await api("/api/auth/email-password/login", {
        method: "POST",
        body: { email: user.email, password: NEW_PASSWORD },
      });
      assert.equal(login.status, 200);
      const freshRefresh = (login.body as any).refreshToken as string;

      const res = await api("/api/auth/refresh-token", {
        method: "POST",
        body: { refreshToken: freshRefresh },
      });
      assert.equal(res.status, 200);
      assert.ok((res.body as any).accessToken);
    },
  );

  console.log();
  console.log("§27 a superseded (never-used) reset request stops working the moment a new one is issued");

  await check(
    "requesting a second reset invalidates the first, still-unused one",
    async () => {
      const supersedeUser = await registerUser("supersede");
      await api("/api/auth/password-reset/request", {
        method: "POST",
        body: { email: supersedeUser.email },
      });
      const firstLink = await extractResetLinkFor(supersedeUser.email);
      const firstToken = new URL(firstLink).searchParams.get("token")!;

      // A second request before the first was ever used.
      await api("/api/auth/password-reset/request", {
        method: "POST",
        body: { email: supersedeUser.email },
      });

      const res = await api("/reset-password", {
        method: "POST",
        form: `token=${encodeURIComponent(firstToken)}&newPassword=ShouldFail123!&confirmPassword=ShouldFail123!`,
      });
      assert.equal(res.status, 400);
      assert.match(res.body as string, /invalid or has expired/);
    },
  );

  console.log();
  console.log("§27 Microsoft OAuth - unconfigured-provider behaviour (MICROSOFT_OAUTH_CLIENT_ID unset, matching current production default)");

  await check(
    "POST /oauth/microsoft returns 501 with a clear message, not a crash or a silent account",
    async () => {
      const res = await api("/api/auth/oauth/microsoft", {
        method: "POST",
        body: { idToken: "anything-at-all" },
      });
      assert.equal(res.status, 501);
      assert.match((res.body as any).error ?? "", /not configured/i);
    },
  );

  await check(
    "an empty idToken is still rejected by validation before reaching the verifier",
    async () => {
      const res = await api("/api/auth/oauth/microsoft", {
        method: "POST",
        body: { idToken: "" },
      });
      assert.equal(res.status, 400);
    },
  );

  console.log();
  console.log("§27 rate limiting on the password-reset surface (shared with the rest of /api/auth)");

  await check(
    "enough rapid reset requests eventually trip the existing auth rate limiter (429)",
    async () => {
      const results: number[] = [];
      for (let i = 0; i < 50; i++) {
        const res = await api("/api/auth/password-reset/request", {
          method: "POST",
          body: { email: `flood-${i}-${crypto.randomUUID()}@test.local` },
        });
        results.push(res.status);
      }
      assert.ok(
        results.includes(429),
        `expected at least one 429 in ${JSON.stringify(results)}`,
      );
    },
  );

  console.log(`\n${passed} checks passed.`);
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

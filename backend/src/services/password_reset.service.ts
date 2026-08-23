import crypto from "crypto";
import prisma from "../utils/prisma_client.util.js";
import { sendEmail } from "../utils/email.util.js";
import { hashPassword } from "./auth.service.js";

// A reset link is live for 1 hour - long enough to find the email, short
// enough that a forgotten, forwarded, or intercepted link goes stale fast.
const RESET_TOKEN_TTL_MINUTES = 60;
const RESET_TOKEN_BYTES = 32; // 256 bits of entropy, matching the webhook API key pattern.

const DISCLAIMER =
  "If you didn't request this, you can safely ignore this email - your password has not been changed.";

const escapeHtml = (value: string): string =>
  value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");

/**
 * SHA-256, not bcrypt: the raw token is already a 256-bit random secret
 * (nothing like a low-entropy human password), so a fast deterministic hash
 * is the right tool - and it's what makes `findUnique({where:{tokenHash}}`
 * possible at all. Bcrypt's per-call salt would force scanning every row in
 * the table to find a match, which does not scale as tokens accumulate.
 */
const hashToken = (token: string): string =>
  crypto.createHash("sha256").update(token).digest("hex");

const buildResetLink = (baseUrl: string, token: string): string =>
  `${baseUrl.replace(/\/$/, "")}/reset-password?token=${encodeURIComponent(token)}`;

const emailShell = (bodyHtml: string): string => `
  <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 480px; margin: 0 auto; color: #1c1c1e;">
    ${bodyHtml}
    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;" />
    <p style="color: #888; font-size: 12px; line-height: 1.5;">${DISCLAIMER}</p>
  </div>
`;

const resetEmailHtml = (link: string): string =>
  emailShell(`
    <h2 style="margin: 0 0 12px;">Reset your password</h2>
    <p style="line-height: 1.6;">We received a request to reset the password for your Safety ALRT account.</p>
    <p style="margin: 24px 0;">
      <a href="${escapeHtml(link)}" style="display: inline-block; background: #1c1c1e; color: #fff; text-decoration: none; font-weight: 600; padding: 14px 28px; border-radius: 12px;">Reset password</a>
    </p>
    <p style="line-height: 1.6; color: #555; font-size: 13px;">This link expires in ${RESET_TOKEN_TTL_MINUTES} minutes and can only be used once. If the button doesn't work, copy and paste this link into your browser:<br />${escapeHtml(link)}</p>
  `);

const noPasswordEmailHtml = (): string =>
  emailShell(`
    <h2 style="margin: 0 0 12px;">About your Safety ALRT account</h2>
    <p style="line-height: 1.6;">Someone requested a password reset for this email address, but this Safety ALRT account doesn't have a password - it was created with Google, Apple, or Microsoft sign-in.</p>
    <p style="line-height: 1.6;">Open the Safety ALRT app and use that same sign-in option to get back in.</p>
  `);

/**
 * Starts a password reset. Always resolves the same way to the caller
 * regardless of whether the email is registered, has a password, or
 * anything else - the only observable difference is what (if anything)
 * lands in that inbox, never the API response.
 */
export const requestPasswordReset = async (
  email: string,
  baseUrl: string,
): Promise<void> => {
  const user = await prisma.user.findUnique({
    where: { email },
    select: { id: true, passwordHash: true },
  });
  if (!user) return;

  if (!user.passwordHash) {
    await sendEmail({
      to: email,
      subject: "About your Safety ALRT account",
      html: noPasswordEmailHtml(),
    });
    return;
  }

  // Superseding any still-open request keeps exactly one live token per
  // user, so an earlier link (forwarded, screenshotted, sitting unread)
  // stops working the moment a fresh one is issued.
  await prisma.passwordResetToken.updateMany({
    where: { userId: user.id, usedAt: null },
    data: { usedAt: new Date() },
  });

  const rawToken = crypto.randomBytes(RESET_TOKEN_BYTES).toString("base64url");
  await prisma.passwordResetToken.create({
    data: {
      userId: user.id,
      tokenHash: hashToken(rawToken),
      expiresAt: new Date(Date.now() + RESET_TOKEN_TTL_MINUTES * 60 * 1000),
    },
  });

  await sendEmail({
    to: email,
    subject: "Reset your Safety ALRT password",
    html: resetEmailHtml(buildResetLink(baseUrl, rawToken)),
  });
};

/**
 * Read-only check used by the GET reset-password page so visiting the link
 * (which email-scanners/prefetchers do automatically) never itself
 * consumes the token - only a submitted new password does.
 */
export const isPasswordResetTokenValid = async (
  rawToken: string,
): Promise<boolean> => {
  const row = await prisma.passwordResetToken.findUnique({
    where: { tokenHash: hashToken(rawToken) },
    select: { usedAt: true, expiresAt: true },
  });
  return Boolean(row) && !row!.usedAt && row!.expiresAt > new Date();
};

/**
 * Redeems a reset token: sets the new password and marks the token used in
 * one transaction, and bumps passwordChangedAt so refresh tokens issued
 * before this moment stop working (see the refreshToken controller).
 * Returns false for a missing, expired, or already-used token - the caller
 * shows one generic "invalid or expired" outcome for all three, never
 * distinguishing which.
 */
export const confirmPasswordReset = async (
  rawToken: string,
  newPassword: string,
): Promise<boolean> => {
  const row = await prisma.passwordResetToken.findUnique({
    where: { tokenHash: hashToken(rawToken) },
  });
  if (!row || row.usedAt || row.expiresAt <= new Date()) {
    return false;
  }

  const passwordHash = hashPassword(newPassword);
  const now = new Date();
  await prisma.$transaction([
    prisma.user.update({
      where: { id: row.userId },
      data: { passwordHash, passwordChangedAt: now },
    }),
    prisma.passwordResetToken.update({
      where: { id: row.id },
      data: { usedAt: now },
    }),
  ]);
  return true;
};

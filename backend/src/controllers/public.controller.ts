import type { Request, Response, NextFunction } from "express";
import { HazardReviewStatus } from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { renderShareCard } from "../services/share_card.service.js";
import {
  confirmPasswordReset,
  isPasswordResetTokenValid,
} from "../services/password_reset.service.js";

const SITE_URL = "https://safetyalrt.com";
const GET_APP_URL = "https://safetyalrt.com/get";
// Shared share cards are read anywhere in the world, which is exactly why
// this cannot name one country's number (product owner 2026-08-05,
// reaffirmed 2026-08-06).
const DISCLAIMER =
  "ALRT shares safety information and does not issue emergency instructions. In a life-threatening emergency call your local emergency number.";

/** Escapes hazard-derived strings for safe interpolation into HTML/attributes. */
const escapeHtml = (value: string): string =>
  value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");

const severityLabel = (severity: string): string => {
  switch (severity) {
    case "emergency":
      return "Emergency Warning";
    case "watchAndAct":
      return "Watch and Act";
    case "advice":
      return "Advice";
    default:
      return "Alert";
  }
};

const severityColor = (severity: string): string => {
  switch (severity) {
    case "emergency":
      return "#D7263D";
    case "watchAndAct":
      return "#F26522";
    case "advice":
      return "#E8B931";
    default:
      return "#666";
  }
};

const timeAgo = (date: Date): string => {
  const diffMs = Date.now() - date.getTime();
  const minutes = Math.max(0, Math.floor(diffMs / 60000));
  if (minutes < 1) return "just now";
  if (minutes < 60) return `${minutes} minute${minutes === 1 ? "" : "s"} ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} hour${hours === 1 ? "" : "s"} ago`;
  const days = Math.floor(hours / 24);
  return `${days} day${days === 1 ? "" : "s"} ago`;
};

const formatIssuedAt = (date: Date): string =>
  new Intl.DateTimeFormat("en-AU", {
    dateStyle: "medium",
    timeStyle: "short",
    timeZone: "Australia/Sydney",
  }).format(date);

/**
 * Fetches a hazard that is publicly shareable: accepted and not expired.
 * Returns null otherwise.
 */
const findShareableHazard = async (hazardId: string) => {
  const hazard = await prisma.hazard.findUnique({
    where: { id: hazardId },
    include: {
      category: { select: { name: true, color: true } },
      source: { select: { name: true } },
    },
  });

  if (!hazard) return null;
  if (hazard.reviewStatus !== HazardReviewStatus.accepted) return null;
  if (hazard.expiresAt && hazard.expiresAt.getTime() <= Date.now()) return null;

  return hazard;
};

/**
 * GET /api/public/hazards/:id — sanitized public JSON for an accepted,
 * unexpired hazard. No auth; excludes reporter identity and private fields.
 */
export const getPublicHazardController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { id } = req.params;
    if (!id) throw new HttpError(400, "id is required");

    const hazard = await findShareableHazard(id);
    if (!hazard) {
      throw new HttpError(404, "Alert not found");
    }

    res.status(200).json({
      id: hazard.id,
      title: hazard.title,
      aiSummary: hazard.aiSummary,
      severity: hazard.severity,
      severityBand: hazard.severityBand,
      callsToAction: hazard.callsToAction,
      latitude: hazard.latitude,
      longitude: hazard.longitude,
      locationName: hazard.locationName,
      categoryId: hazard.categoryId,
      categoryName: hazard.category.name,
      categoryColor: hazard.category.color,
      sourceName: hazard.source?.name ?? null,
      occurredAt: hazard.occurredAt,
      createdAt: hazard.createdAt,
      expiresAt: hazard.expiresAt,
    });
  } catch (error) {
    next(error);
  }
};

const expiredPage = (): string => `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>This alert has expired — Safety ALRT</title>
<meta property="og:site_name" content="Safety ALRT">
<meta property="og:title" content="This alert has expired">
<meta property="og:description" content="The alert you are looking for is no longer active. Open Safety ALRT to see current alerts near you.">
<style>
  body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #f5f6f8; color: #1c1c1e; }
  .wrap { max-width: 480px; margin: 0 auto; padding: 48px 20px; text-align: center; }
  .card { background: #fff; border-radius: 16px; padding: 32px 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
  h1 { font-size: 22px; margin: 0 0 12px; }
  p { color: #555; line-height: 1.5; margin: 0 0 24px; }
  .cta { display: inline-block; background: #1c1c1e; color: #fff; text-decoration: none; font-weight: 600; padding: 14px 28px; border-radius: 12px; }
  .disclaimer { font-size: 12px; color: #888; margin-top: 24px; }
</style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h1>This alert has expired</h1>
      <p>The alert you are looking for is no longer active. Open Safety ALRT to see current alerts near you.</p>
      <a class="cta" href="${SITE_URL}">Open Safety ALRT</a>
      <p class="disclaimer">${DISCLAIMER}</p>
    </div>
  </div>
</body>
</html>`;

type ShareableHazard = NonNullable<
  Awaited<ReturnType<typeof findShareableHazard>>
>;

const sharePage = (hazard: ShareableHazard): string => {
  const label = severityLabel(hazard.severity);
  const color = severityColor(hazard.severity);
  const title = escapeHtml(hazard.title);
  const location = hazard.locationName ? escapeHtml(hazard.locationName) : "";
  const summarySource =
    hazard.aiSummary || hazard.description.slice(0, 200) || "";
  const summary = escapeHtml(summarySource);
  const sourceName = hazard.source?.name ? escapeHtml(hazard.source.name) : "";
  const issuedAgo = escapeHtml(timeAgo(hazard.occurredAt));
  const issuedAt = escapeHtml(formatIssuedAt(hazard.occurredAt));
  const shareUrl = `${SITE_URL}/a/${encodeURIComponent(hazard.id)}`;
  const cardUrl = `${SITE_URL}/share/alert/${encodeURIComponent(hazard.id)}/card.png?v=${hazard.updatedAt.getTime()}`;

  const ogDescriptionParts = [summarySource];
  if (hazard.locationName) ogDescriptionParts.push(hazard.locationName);
  ogDescriptionParts.push(`Issued ${formatIssuedAt(hazard.occurredAt)}`);
  const ogDescription = escapeHtml(ogDescriptionParts.join(" — "));

  const callsToAction = hazard.callsToAction
    .map((cta) => `<li>${escapeHtml(cta)}</li>`)
    .join("\n        ");

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(label)} — ${title} | Safety ALRT</title>
<meta property="og:type" content="website">
<meta property="og:site_name" content="Safety ALRT">
<meta property="og:title" content="${escapeHtml(label)} — ${title}">
<meta property="og:description" content="${ogDescription}">
<meta property="og:url" content="${shareUrl}">
<meta property="og:image" content="${cardUrl}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="${escapeHtml(label)} — ${title}">
<meta name="twitter:description" content="${ogDescription}">
<meta name="twitter:image" content="${cardUrl}">
<meta name="theme-color" content="${color}">
<style>
  body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #f5f6f8; color: #1c1c1e; }
  .wrap { max-width: 520px; margin: 0 auto; padding: 24px 16px 48px; }
  .banner { background: ${color}; color: #fff; border-radius: 16px 16px 0 0; padding: 20px; }
  .badges { display: flex; align-items: center; gap: 8px; margin-bottom: 10px; flex-wrap: wrap; }
  .badge { display: inline-block; background: rgba(255,255,255,0.22); border-radius: 999px; padding: 4px 12px; font-size: 12px; font-weight: 700; letter-spacing: 0.4px; text-transform: uppercase; }
  .banner h1 { font-size: 22px; line-height: 1.3; margin: 0 0 8px; }
  .meta { font-size: 13px; opacity: 0.92; }
  .card { background: #fff; border-radius: 0 0 16px 16px; padding: 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
  .summary { font-size: 15px; line-height: 1.55; color: #333; margin: 0 0 16px; }
  h2 { font-size: 13px; text-transform: uppercase; letter-spacing: 0.6px; color: #888; margin: 20px 0 8px; }
  ul { margin: 0; padding-left: 20px; }
  li { font-size: 14px; line-height: 1.5; color: #333; margin-bottom: 6px; }
  .open-cta { display: block; text-align: center; background: ${color}; color: #fff; text-decoration: none; font-weight: 700; font-size: 16px; padding: 15px 20px; border-radius: 12px; margin: 24px 0 12px; }
  .stores { display: flex; justify-content: center; gap: 16px; margin-bottom: 8px; }
  .stores a { font-size: 13px; color: #555; text-decoration: underline; }
  .disclaimer { font-size: 12px; color: #888; line-height: 1.5; text-align: center; margin-top: 16px; }
</style>
</head>
<body>
  <div class="wrap">
    <div class="banner">
      <div class="badges">
        ${sourceName ? `<span class="badge">${sourceName}</span>` : ""}
        <span class="badge">${escapeHtml(label)}</span>
      </div>
      <h1>${title}</h1>
      <div class="meta">${location ? `${location} · ` : ""}Issued ${issuedAgo} (${issuedAt})</div>
    </div>
    <div class="card">
      ${summary ? `<p class="summary">${summary}</p>` : ""}
      ${
        callsToAction
          ? `<h2>What you can do</h2>
      <ul>
        ${callsToAction}
      </ul>`
          : ""
      }
      <a class="open-cta" href="${SITE_URL}">Open in Safety ALRT</a>
      <div class="stores">
        <a href="${GET_APP_URL}">App Store</a>
        <a href="${GET_APP_URL}">Google Play</a>
      </div>
      <p class="disclaimer">${DISCLAIMER}</p>
    </div>
  </div>
</body>
</html>`;
};

/**
 * GET /share/alert/:id — minimal branded HTML page for link unfurls.
 * Serves a friendly 410 page when the alert is missing, unaccepted or expired.
 */
export const shareAlertPageController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { id } = req.params;

    const hazard = id ? await findShareableHazard(id) : null;

    res.setHeader("Content-Type", "text/html; charset=utf-8");

    if (!hazard) {
      res.status(410).send(expiredPage());
      return;
    }

    res.status(200).send(sharePage(hazard));
  } catch (error) {
    next(error);
  }
};

/**
 * GET /share/alert/:id/card.png — 1200x630 Open Graph card for link unfurls.
 * Rendered once per alert revision and cached; served with long-lived
 * immutable caching since the URL carries the revision in ?v=.
 */
export const shareAlertCardController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { id } = req.params;

    const hazard = id ? await findShareableHazard(id) : null;
    if (!hazard) {
      throw new HttpError(404, "Alert not found");
    }

    const png = await renderShareCard({
      id: hazard.id,
      updatedAt: hazard.updatedAt,
      title: hazard.title,
      severity: hazard.severity,
      severityLabel: severityLabel(hazard.severity),
      severityColor: severityColor(hazard.severity),
      locationName: hazard.locationName,
      issuedAtLabel: formatIssuedAt(hazard.occurredAt),
      sourceName: hazard.source?.name ?? null,
    });

    res.setHeader("Content-Type", "image/png");
    res.setHeader("Cache-Control", "public, max-age=86400, immutable");
    res.status(200).send(png);
  } catch (error) {
    next(error);
  }
};

// ---------------------------------------------------------------------------
// Password reset page — the destination of the link in the reset email.
// Deliberately a plain server-rendered HTML form (no JS required, works in
// any email client's in-app browser) rather than a native app deep link:
// this avoids the app needing to be installed at all, and the reset token
// never needs to touch a mobile deep-link handler.
// ---------------------------------------------------------------------------

const passwordResetPageShell = (bodyHtml: string): string => `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="no-referrer">
<meta name="robots" content="noindex, nofollow">
<title>Reset your password — Safety ALRT</title>
<style>
  body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #f5f6f8; color: #1c1c1e; }
  .wrap { max-width: 420px; margin: 0 auto; padding: 48px 20px; }
  .card { background: #fff; border-radius: 16px; padding: 32px 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
  h1 { font-size: 20px; margin: 0 0 16px; }
  p { color: #555; line-height: 1.5; margin: 0 0 16px; }
  label { display: block; font-size: 13px; font-weight: 600; margin: 16px 0 6px; }
  input[type="password"] { width: 100%; box-sizing: border-box; padding: 12px 14px; border: 1px solid #d8d8dc; border-radius: 10px; font-size: 15px; }
  button { width: 100%; margin-top: 24px; background: #1c1c1e; color: #fff; border: none; font-weight: 600; font-size: 15px; padding: 14px 28px; border-radius: 12px; cursor: pointer; }
  .error { background: #fdecec; color: #a4222c; border-radius: 10px; padding: 10px 14px; font-size: 13px; margin: 0 0 16px; }
  .cta { display: inline-block; background: #1c1c1e; color: #fff; text-decoration: none; font-weight: 600; padding: 14px 28px; border-radius: 12px; }
  .disclaimer { font-size: 12px; color: #888; margin-top: 24px; text-align: center; }
</style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      ${bodyHtml}
    </div>
    <p class="disclaimer">${DISCLAIMER}</p>
  </div>
</body>
</html>`;

const resetLinkInvalidHtml = (): string =>
  passwordResetPageShell(`
    <h1>This link is invalid or has expired</h1>
    <p>Reset links work once and expire an hour after they're sent. Go back to Safety ALRT and request a new one.</p>
    <a class="cta" href="${SITE_URL}">Open Safety ALRT</a>
  `);

const resetFormHtml = (token: string, errorMessage?: string): string =>
  passwordResetPageShell(`
    <h1>Choose a new password</h1>
    ${errorMessage ? `<p class="error">${escapeHtml(errorMessage)}</p>` : ""}
    <form method="POST" action="/reset-password">
      <input type="hidden" name="token" value="${escapeHtml(token)}">
      <label for="password">New password</label>
      <input type="password" id="password" name="newPassword" minlength="6" maxlength="128" required autofocus>
      <label for="confirmPassword">Confirm new password</label>
      <input type="password" id="confirmPassword" name="confirmPassword" minlength="6" maxlength="128" required>
      <button type="submit">Update password</button>
    </form>
  `);

const resetSuccessHtml = (): string =>
  passwordResetPageShell(`
    <h1>Password updated</h1>
    <p>Your password has been changed. Open the Safety ALRT app and sign in with your new password.</p>
  `);

/**
 * GET /reset-password?token=... — read-only by design. Visiting this link
 * (which email-scanners/link-prefetchers do automatically) never itself
 * consumes the token; only a submitted new password does.
 *
 * Errors are handled entirely inside this controller rather than via
 * next(error): the shared error-handler middleware logs req.originalUrl on
 * every error, which for a GET would include the token in the query
 * string. Nothing here ever reaches that logging path.
 */
export const passwordResetPageController = async (
  req: Request,
  res: Response,
) => {
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  try {
    const token = typeof req.query.token === "string" ? req.query.token : "";
    if (!token || !(await isPasswordResetTokenValid(token))) {
      res.status(400).send(resetLinkInvalidHtml());
      return;
    }
    res.status(200).send(resetFormHtml(token));
  } catch {
    // Deliberately no token/URL in this log line - see comment above.
    console.error("Error rendering the password reset page");
    res.status(500).send(resetLinkInvalidHtml());
  }
};

/**
 * POST /reset-password — classic form submit (application/x-www-form-urlencoded),
 * so it works with JavaScript disabled. The token travels in the body here,
 * not the URL, so the req.originalUrl logged by the shared error handler
 * never carries it - next(error) is safe to use in this handler.
 */
export const passwordResetSubmitController = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  try {
    const token =
      typeof req.body?.token === "string" ? req.body.token : "";
    const newPassword =
      typeof req.body?.newPassword === "string" ? req.body.newPassword : "";
    const confirmPassword =
      typeof req.body?.confirmPassword === "string"
        ? req.body.confirmPassword
        : "";

    if (!token) {
      res.status(400).send(resetLinkInvalidHtml());
      return;
    }
    if (newPassword.length < 6 || newPassword.length > 128) {
      res
        .status(400)
        .send(resetFormHtml(token, "Password must be 6-128 characters."));
      return;
    }
    if (newPassword !== confirmPassword) {
      res.status(400).send(resetFormHtml(token, "Passwords do not match."));
      return;
    }

    const succeeded = await confirmPasswordReset(token, newPassword);
    if (!succeeded) {
      res.status(400).send(resetLinkInvalidHtml());
      return;
    }

    res.status(200).send(resetSuccessHtml());
  } catch (error) {
    next(error);
  }
};

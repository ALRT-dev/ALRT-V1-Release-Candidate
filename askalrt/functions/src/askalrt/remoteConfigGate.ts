/**
 * Ask ALRT — Remote Config kill switch.
 *
 * `agent_enabled` (remoteconfig.template.json) was declared as a global off
 * switch for the assistant but nothing server-side ever read it - a client
 * that ignored the flag could still call the callable while the switch was
 * flipped off. This reads the same parameter from the Remote Config
 * template via the Admin SDK so the switch actually disables the callable,
 * not just client UI.
 *
 * Server-side Remote Config only exposes the template's default value, not
 * per-user conditions - correct for a global kill switch, not a
 * personalised rollout.
 */
import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";

const CACHE_TTL_MS = 5 * 60 * 1000;
let cache: { at: number; enabled: boolean } | null = null;

/**
 * Pure: read the boolean default value of `agent_enabled` out of a Remote
 * Config parameter map. Missing or malformed data resolves to enabled
 * (fail open) - matching both the declared template default and
 * entriesLoader's philosophy of falling back to safe behaviour on read
 * errors rather than taking the assistant down over an unrelated outage.
 */
export function parseAgentEnabled(
  parameters: Record<string, { defaultValue?: { value?: unknown } }> | undefined | null
): boolean {
  const raw = parameters?.["agent_enabled"]?.defaultValue?.value;
  if (typeof raw !== "string") return true;
  return raw.trim().toLowerCase() !== "false";
}

/**
 * Current state of the kill switch, cached for 5 minutes. Fails open on any
 * Remote Config read error - an outage here must not take Ask ALRT down.
 */
export async function isAgentEnabled(): Promise<boolean> {
  const now = Date.now();
  if (cache && now - cache.at < CACHE_TTL_MS) return cache.enabled;

  try {
    const template = await admin.remoteConfig().getTemplate();
    const enabled = parseAgentEnabled(
      template.parameters as Record<string, { defaultValue?: { value?: unknown } }>
    );
    cache = { at: now, enabled };
    return enabled;
  } catch (err) {
    logger.warn("Remote Config agent_enabled read failed; assuming enabled", {
      error: (err as Error).message,
    });
    return true;
  }
}

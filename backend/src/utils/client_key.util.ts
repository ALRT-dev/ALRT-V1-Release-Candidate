import { getCacheClient } from "./cache_client.util.js";

/**
 * Client-key deduplication for actions that can be sent twice for one
 * human intention: a check-in answered from the phone and from a watch
 * notification within seconds, or a retry after a lost answer.
 *
 * The client picks a key that is the same for both attempts (the app uses
 * `req:<requestId>` when answering a check-in request). The first attempt
 * claims the key and records the row it created; a later attempt with the
 * same key is handed that row instead of creating a second one.
 *
 * Claims live in the cache for 24 hours; without a cache they live in this
 * process, which still covers the common case (two taps seconds apart on
 * one deployment). This is deliberately not a schema change: a persisted
 * key column needs a migration, which is a separate approval
 * (WEARABLES_AUDIT_AND_PLAN.md §4.4).
 */
const CLIENT_KEY_TTL_S = 24 * 60 * 60;
const PENDING = "pending";
const localClaims = new Map<string, { value: string; expiresAt: number }>();

const cacheKey = (scope: string, userId: string, clientKey: string) =>
  `clientkey:${scope}:${userId}:${clientKey}`;

const sweepLocal = () => {
  const now = Date.now();
  for (const [k, v] of localClaims) if (v.expiresAt <= now) localClaims.delete(k);
};

export type ClientKeyClaim =
  | { status: "claimed" }
  | { status: "pending" }
  | { status: "done"; resultId: string };

/**
 * Claims `clientKey` for `userId` within `scope`. Returns "claimed" when
 * this call is the first, "pending" when an earlier call is still in
 * flight, or "done" with the id the earlier call recorded.
 */
export const claimClientKey = async (
  scope: string,
  userId: string,
  clientKey: string,
): Promise<ClientKeyClaim> => {
  const key = cacheKey(scope, userId, clientKey);
  const redis = getCacheClient();
  if (redis) {
    try {
      const first =
        (await redis.set(key, PENDING, { NX: true, EX: CLIENT_KEY_TTL_S })) === "OK";
      if (first) return { status: "claimed" };
      const existing = await redis.get(key);
      if (!existing || existing === PENDING) return { status: "pending" };
      return { status: "done", resultId: existing };
    } catch {
      // Cache unreachable: fall through to the in-process map.
    }
  }
  sweepLocal();
  const existing = localClaims.get(key);
  if (!existing) {
    localClaims.set(key, { value: PENDING, expiresAt: Date.now() + CLIENT_KEY_TTL_S * 1000 });
    return { status: "claimed" };
  }
  if (existing.value === PENDING) return { status: "pending" };
  return { status: "done", resultId: existing.value };
};

/** Records the row a claimed key produced, so a repeat gets the same row. */
export const completeClientKey = async (
  scope: string,
  userId: string,
  clientKey: string,
  resultId: string,
): Promise<void> => {
  const key = cacheKey(scope, userId, clientKey);
  const redis = getCacheClient();
  if (redis) {
    try {
      await redis.set(key, resultId, { EX: CLIENT_KEY_TTL_S });
      return;
    } catch {
      // Fall through.
    }
  }
  localClaims.set(key, { value: resultId, expiresAt: Date.now() + CLIENT_KEY_TTL_S * 1000 });
};

/** Releases a claim whose action failed, so the client may retry. */
export const releaseClientKey = async (
  scope: string,
  userId: string,
  clientKey: string,
): Promise<void> => {
  const key = cacheKey(scope, userId, clientKey);
  localClaims.delete(key);
  const redis = getCacheClient();
  if (!redis) return;
  try {
    await redis.del(key);
  } catch {
    // Nothing to do: the pending claim expires on its own.
  }
};

/** Test hook: forgets every in-process claim. Never used on a request path. */
export const resetLocalClientKeys = () => localClaims.clear();

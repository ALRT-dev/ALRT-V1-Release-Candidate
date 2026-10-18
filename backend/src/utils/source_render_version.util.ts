// Bump when source rendering/validation changes, even without a new Admin pack.
export const sourceRenderHash = (contentHash: string, rawSourceHash: string): string => `agency-blocks-v3:${contentHash}:${rawSourceHash}`;

// The caller recomputes this digest with the previously stored template version.
// Equal source data needs re-rendering, never a new emergency notification.
export const isSourceRenderRefresh = (storedHash: string | null | undefined, rawSourceHash: string, previousVersionHash: string): boolean => {
  if (!storedHash) return false;
  const parts = storedHash.split(':');
  return parts.length === 3 ? parts[2] === rawSourceHash : storedHash.replace(/^[a-z0-9-]+:/, '') === previousVersionHash;
};

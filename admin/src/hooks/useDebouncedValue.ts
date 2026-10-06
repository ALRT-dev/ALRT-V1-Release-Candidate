import { useEffect, useState } from "react";

export const SEARCH_DEBOUNCE_MS = 300;

/** Returns `value`, but only after it has stopped changing for `delayMs`.
 * Search boxes use this so typing a word sends one request, not one per
 * keystroke. */
export const useDebouncedValue = <T>(value: T, delayMs: number = SEARCH_DEBOUNCE_MS): T => {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timer);
  }, [value, delayMs]);

  return debounced;
};

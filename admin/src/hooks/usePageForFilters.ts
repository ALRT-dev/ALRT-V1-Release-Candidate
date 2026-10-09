import { useCallback, useState } from "react";

/** Current page number for a paged list that goes back to page 1 whenever
 * any of `filters` changes (search text, status, toggles). Derived during
 * render rather than reset in an effect, so a filter change sends exactly
 * one request, for page 1, instead of one for the old page then another. */
export const usePageForFilters = (filters: unknown[]): [number, (page: number) => void] => {
  const key = JSON.stringify(filters);
  const [state, setState] = useState({ key, page: 1 });
  const page = state.key === key ? state.page : 1;
  const setPage = useCallback((next: number) => setState({ key, page: Math.max(1, next) }), [key]);
  return [page, setPage];
};

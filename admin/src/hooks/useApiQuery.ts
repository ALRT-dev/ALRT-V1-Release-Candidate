import { useCallback, useEffect, useRef, useState } from "react";

interface QueryState<T> {
  data: T | null;
  error: unknown;
  loading: boolean;
}

/** Minimal fetch-on-mount(+deps) hook. Deliberately not a caching library -
 * this app has a handful of screens each with one or two lists, which
 * doesn't justify a query-cache dependency. `deps` re-runs the fetch (e.g.
 * on search/filter/page change); call the returned `refetch` after a
 * mutation to show the mutation's result. */
export const useApiQuery = <T>(
  fetcher: () => Promise<T>,
  deps: unknown[],
): QueryState<T> & { refetch: () => void } => {
  const [state, setState] = useState<QueryState<T>>({
    data: null,
    error: null,
    loading: true,
  });
  const fetcherRef = useRef(fetcher);
  fetcherRef.current = fetcher;
  const [tick, setTick] = useState(0);

  useEffect(() => {
    let cancelled = false;
    setState((s) => ({ ...s, loading: true, error: null }));
    fetcherRef
      .current()
      .then((data) => {
        if (!cancelled) setState({ data, error: null, loading: false });
      })
      .catch((error: unknown) => {
        if (!cancelled) setState({ data: null, error, loading: false });
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, tick]);

  const refetch = useCallback(() => setTick((t) => t + 1), []);

  return { ...state, refetch };
};

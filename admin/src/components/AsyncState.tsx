import { ApiError } from "../api/client";

export const LoadingState = ({ label = "Loading..." }: { label?: string }) => (
  <div className="state-block" role="status">
    {label}
  </div>
);

export const EmptyState = ({ label }: { label: string }) => (
  <div className="state-block">{label}</div>
);

/** Renders a permission-denied message for a 403, and a plain error
 * message (with a retry button, if `onRetry` is given) for anything else.
 * Never used for 401 - the client already redirects to /login on a
 * session-expired 401, see AuthContext's registerSessionExpiredHandler. */
export const ErrorState = ({
  error,
  onRetry,
}: {
  error: unknown;
  onRetry?: () => void;
}) => {
  if (error instanceof ApiError && error.status === 403) {
    return (
      <div className="state-block state-block--error" role="alert">
        You don't have permission to view this. Your current role doesn't
        include this capability - ask a super admin if you believe this is
        wrong.
      </div>
    );
  }

  const message =
    error instanceof Error ? error.message : "Something went wrong.";

  return (
    <div className="state-block state-block--error" role="alert">
      <p>{message}</p>
      {onRetry && (
        <button type="button" className="btn btn-sm" onClick={onRetry}>
          Retry
        </button>
      )}
    </div>
  );
};

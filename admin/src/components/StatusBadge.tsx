const REVIEW_STATUS_CLASS: Record<string, string> = {
  accepted: "badge-success",
  rejected: "badge-danger",
  pending: "badge-pending",
};

export const ReviewStatusBadge = ({ status }: { status: string }) => (
  <span className={`badge ${REVIEW_STATUS_CLASS[status] ?? "badge-pending"}`}>
    {status}
  </span>
);

const SEVERITY_CLASS: Record<string, string> = {
  emergency: "badge-danger",
  watchAndAct: "badge-warning",
  advice: "badge-pending",
  info: "badge-pending",
  unknown: "badge-pending",
};

export const SeverityBadge = ({ severity }: { severity: string }) => (
  <span className={`badge ${SEVERITY_CLASS[severity] ?? "badge-pending"}`}>
    {severity}
  </span>
);

export const BooleanBadge = ({
  value,
  trueLabel,
  falseLabel,
}: {
  value: boolean;
  trueLabel: string;
  falseLabel: string;
}) => (
  <span className={`badge ${value ? "badge-success" : "badge-pending"}`}>
    {value ? trueLabel : falseLabel}
  </span>
);

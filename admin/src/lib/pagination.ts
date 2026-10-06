/**
 * Page maths shared by every paged list screen (Alerts, Moderation,
 * Sources, Users, Audit Log).
 *
 * Only GET /api/admin/users/app-users returns a `total`. The hazard,
 * hazard-source and audit-log endpoints return a bare array for the
 * requested page/pageSize, so for those the last page is inferred: a page
 * that came back shorter than pageSize is the last one. Until that last
 * page is reached the label is "Page X", since the page count is not known.
 */
export interface PageInfo {
  page: number;
  totalPages: number | null;
  hasPrevious: boolean;
  hasNext: boolean;
  label: string;
}

export const pageInfo = ({
  page,
  pageSize,
  itemsOnPage,
  total,
}: {
  page: number;
  pageSize: number;
  itemsOnPage: number;
  total?: number | undefined;
}): PageInfo => {
  if (typeof total === "number") {
    const totalPages = Math.max(1, Math.ceil(total / pageSize));
    return {
      page,
      totalPages,
      hasPrevious: page > 1,
      hasNext: page < totalPages,
      label: `Page ${page} of ${totalPages}`,
    };
  }
  const hasNext = itemsOnPage >= pageSize;
  return {
    page,
    totalPages: hasNext ? null : page,
    hasPrevious: page > 1,
    hasNext,
    label: hasNext ? `Page ${page}` : `Page ${page} of ${page}`,
  };
};

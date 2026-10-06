import { pageInfo } from "../lib/pagination";

interface PaginationProps {
  page: number;
  pageSize: number;
  itemsOnPage: number;
  /** Only pass when the endpoint actually returns a total. */
  total?: number | undefined;
  onPageChange: (page: number) => void;
}

/** Previous/Next controls plus a "Page X of Y" label. Hidden when there is
 * only one page. */
export const Pagination = ({ page, pageSize, itemsOnPage, total, onPageChange }: PaginationProps) => {
  const info = pageInfo({ page, pageSize, itemsOnPage, total });
  if (!info.hasPrevious && !info.hasNext) return null;

  return (
    <nav className="pagination" aria-label="Pagination">
      <button
        type="button"
        className="btn btn-sm"
        disabled={!info.hasPrevious}
        onClick={() => onPageChange(page - 1)}
      >
        Previous
      </button>
      <span>{info.label}</span>
      <button
        type="button"
        className="btn btn-sm"
        disabled={!info.hasNext}
        onClick={() => onPageChange(page + 1)}
      >
        Next
      </button>
    </nav>
  );
};

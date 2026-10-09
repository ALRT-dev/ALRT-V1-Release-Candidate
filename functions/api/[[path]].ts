// Cloudflare Pages looks for functions/ next to the build root. When the
// Pages project is built from the repository root, this re-exports the
// Admin Portal's /api relay (admin/functions/api).
export { onRequest } from "../../admin/functions/api/[[path]]";

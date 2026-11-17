import { configDefaults, defineConfig } from "vitest/config";

// Build output contains compiled copies of source tests. Running those again
// breaks source-relative fixtures and can execute stale tests after a build.
export default defineConfig({
  test: { exclude: [...configDefaults.exclude, "dist/**"] },
});

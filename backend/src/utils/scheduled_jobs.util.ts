/**
 * Whether this process runs the in-process scheduled jobs (hazard
 * ingestion, expiry sweeps, scheduled check-ins, SOS 4-hour auto-end,
 * location purge).
 *
 * - prod: always (unchanged behaviour).
 * - test: only when RUN_SCHEDULED_JOBS_IN_TEST=true (default off), so
 *   automated check-ins, SOS auto-end and the purge can be tested
 *   deliberately on the isolated TEST backend without the same flag ever
 *   being able to switch anything on for production.
 * - dev / anything else: never; the flag is ignored outside test.
 *
 * Kept free of side effects (no imports) so scripts/verify_scheduled_jobs_
 * switch.ts can exercise it without booting the server.
 */
export const shouldRunScheduledJobs = (
  env: string,
  runInTest: boolean,
): boolean => {
  if (env === "prod") return true;
  if (env === "test") return runInTest;
  return false;
};

import { config } from "../utils/config.js";

export type PlatformVersionPolicy = {
  minVersion: string | null;
  minBuild: number | null;
  storeUrl: string | null;
};

export type AppVersionPolicy = {
  ios: PlatformVersionPolicy;
  android: PlatformVersionPolicy;
};

const VERSION_PATTERN = /^\d+(\.\d+){0,3}$/;

const warned = new Set<string>();
const warnOnce = (key: string, message: string) => {
  if (warned.has(key)) return;
  warned.add(key);
  console.warn(message);
};

const platformPolicy = (
  platform: "ios" | "android",
  raw: { minVersion: string; minBuild: string; storeUrl: string },
): PlatformVersionPolicy => {
  const envSuffix = platform.toUpperCase();

  let minVersion: string | null = raw.minVersion || null;
  if (minVersion && !VERSION_PATTERN.test(minVersion)) {
    // A malformed value must never lock everyone out: treat it as unset.
    warnOnce(
      `version-${platform}`,
      `MIN_APP_VERSION_${envSuffix} is not a dotted version number (e.g. 1.4.0); ignoring it`,
    );
    minVersion = null;
  }

  let minBuild: number | null = null;
  if (raw.minBuild) {
    const parsed = Number(raw.minBuild);
    if (Number.isInteger(parsed) && parsed >= 0) {
      minBuild = parsed;
    } else {
      warnOnce(
        `build-${platform}`,
        `MIN_APP_BUILD_${envSuffix} is not a whole number; ignoring it`,
      );
    }
  }

  return { minVersion, minBuild, storeUrl: raw.storeUrl || null };
};

/**
 * The minimum app version/build each platform must run, for the app's
 * force-update screen. Read from env; blank means no requirement (null).
 */
export const getAppVersionPolicy = (): AppVersionPolicy => ({
  ios: platformPolicy("ios", config.appVersionPolicy.ios),
  android: platformPolicy("android", config.appVersionPolicy.android),
});

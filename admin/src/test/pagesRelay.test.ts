import { afterEach, describe, expect, it, vi } from "vitest";
import { onRequest } from "../../functions/api/[[path]]";

const LIVE = "https://api.safetyalrt.com";
const TEST = "https://api-test.safetyalrt.com";

// Runs the Pages relay with a stubbed upstream fetch and returns the URL it
// forwarded to plus the headers it sent.
const relay = async (env: { API_ORIGIN?: string }, headers: Record<string, string> = {}) => {
  const upstream = vi.fn(async (_url: string, _init: RequestInit) => new Response("{}", { status: 200 }));
  vi.stubGlobal("fetch", upstream);
  await onRequest({
    request: new Request("https://alrt-admin.pages.dev/api/admin/hazards?page=2", { headers }),
    env,
  });
  const [url, init] = upstream.mock.calls[0]!;
  return { url, headers: new Headers(init.headers) };
};

const resolvedOrigin = async (env: { API_ORIGIN?: string }, headers: Record<string, string> = {}) => {
  const upstream = vi.fn();
  vi.stubGlobal("fetch", upstream);
  const res = await onRequest({
    request: new Request("https://alrt-admin.pages.dev/api/__alrt-relay-origin", { headers }),
    env,
  });
  expect(upstream).not.toHaveBeenCalled();
  return ((await res.json()) as { origin: string }).origin;
};

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("Pages relay backend selection", () => {
  it("defaults to TEST with no API_ORIGIN and no header", async () => {
    const { url } = await relay({});
    expect(url).toBe(`${TEST}/api/admin/hazards?page=2`);
  });

  it("uses API_ORIGIN when set, over any header", async () => {
    const { url } = await relay({ API_ORIGIN: `${LIVE}/` }, { "X-ALRT-API-Origin": TEST });
    expect(url).toBe(`${LIVE}/api/admin/hazards?page=2`);
  });

  it("never reaches live from the build origin header alone", async () => {
    const { url, headers } = await relay({}, { "X-ALRT-API-Origin": LIVE });
    expect(url).toBe(`${TEST}/api/admin/hazards?page=2`);
    // The selector header is not forwarded to the backend.
    expect(headers.get("X-ALRT-API-Origin")).toBeNull();
  });

  it("uses the build origin header when it is exactly the TEST backend", async () => {
    const { url } = await relay({}, { "X-ALRT-API-Origin": TEST });
    expect(url).toBe(`${TEST}/api/admin/hazards?page=2`);
  });

  it.each([
    "https://evil.example.com",
    "https://api.safetyalrt.com.evil.example.com",
    "https://api.safetyalrt.com/",
    "http://api.safetyalrt.com",
    "http://localhost:3000",
  ])("ignores a header that is not exactly allowed: %s", async (value) => {
    const { url } = await relay({}, { "X-ALRT-API-Origin": value });
    expect(url).toBe(`${TEST}/api/admin/hazards?page=2`);
  });

  it("reports the resolved origin without calling the backend", async () => {
    expect(await resolvedOrigin({})).toBe(TEST);
    expect(await resolvedOrigin({}, { "X-ALRT-API-Origin": LIVE })).toBe(TEST);
    expect(await resolvedOrigin({ API_ORIGIN: LIVE }, { "X-ALRT-API-Origin": TEST })).toBe(LIVE);
  });
});

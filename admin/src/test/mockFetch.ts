import { vi } from "vitest";

export interface MockRoute {
  match: (url: string, method: string) => boolean;
  respond: (url: string, method: string, body: unknown) => { status: number; body: unknown };
}

/** Installs a global fetch mock driven by an ordered list of routes - the
 * first matching route wins. Keeps every test's HTTP behaviour explicit
 * instead of hitting a real network, per this being a frontend-only test
 * suite (integration coverage against the real backend lives in
 * backend/src/scripts/verify_stage7b_admin_hardening.ts). */
export const installMockFetch = (routes: MockRoute[]) => {
  const calls: { url: string; method: string; body: unknown }[] = [];

  globalThis.fetch = vi.fn(async (input: string | URL | Request, init?: RequestInit) => {
    const url = typeof input === "string" ? input : input.toString();
    const method = init?.method ?? "GET";
    const body = init?.body ? JSON.parse(init.body as string) : undefined;
    calls.push({ url, method, body });

    const route = routes.find((r) => r.match(url, method));
    if (!route) {
      throw new Error(`No mock route for ${method} ${url}`);
    }
    const { status, body: responseBody } = route.respond(url, method, body);
    return new Response(JSON.stringify(responseBody), {
      status,
      headers: { "Content-Type": "application/json" },
    });
  }) as typeof fetch;

  return { calls };
};

export const jsonRoute = (
  urlIncludes: string,
  method: string,
  status: number,
  body: unknown,
): MockRoute => ({
  match: (url, m) => url.includes(urlIncludes) && m === method,
  respond: () => ({ status, body }),
});

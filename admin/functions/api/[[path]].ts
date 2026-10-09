/**
 * Cloudflare Pages Function: relays every /api/* request from the Admin
 * Portal to the backend, server to server, so the browser only ever talks
 * to the portal's own address (no CORS).
 *
 * Which backend, in order:
 * 1. The Pages environment variable API_ORIGIN, when set. Set it to
 *    https://api.safetyalrt.com on the production Pages project.
 * 2. Otherwise the TEST backend. The live backend is reached ONLY through
 *    API_ORIGIN on the Pages project: the X-ALRT-API-Origin header the
 *    client sends (its build's VITE_API_BASE_URL) is never allowed to pick
 *    live, so a TEST portal built with the default build command can never
 *    end up on live data. The header is stripped before forwarding.
 *
 * GET /api/__alrt-relay-origin is answered here (never forwarded) with the
 * origin the relay would use, so the portal can show or embed the real
 * backend address (for example in the n8n test workflow download).
 */
interface Env {
  API_ORIGIN?: string;
}

const DEFAULT_ORIGIN = "https://api-test.safetyalrt.com";
const API_ORIGIN_HEADER = "X-ALRT-API-Origin";
const RELAY_ORIGIN_PATH = "/api/__alrt-relay-origin";

const resolveRelayOrigin = (
  env: Env,
  requestedOrigin: string | null,
): string => {
  const configured = env.API_ORIGIN?.trim();
  if (configured) return configured.replace(/\/+$/, "");
  void requestedOrigin; // never selects a backend, see the header comment
  return DEFAULT_ORIGIN;
};

export const onRequest = async (context: {
  request: Request;
  env: Env;
}): Promise<Response> => {
  const { request, env } = context;
  const incoming = new URL(request.url);
  const origin = resolveRelayOrigin(env, request.headers.get(API_ORIGIN_HEADER));

  if (incoming.pathname === RELAY_ORIGIN_PATH) {
    return new Response(JSON.stringify({ origin }), {
      status: 200,
      headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
    });
  }

  const target = `${origin}${incoming.pathname}${incoming.search}`;

  const headers = new Headers(request.headers);
  // A server-to-server call: drop the browser's origin so the backend's
  // CORS check treats it like any other non-browser client.
  headers.delete("origin");
  headers.delete("referer");
  headers.delete("host");
  headers.delete(API_ORIGIN_HEADER);

  const hasBody = !["GET", "HEAD"].includes(request.method);
  const response = await fetch(target, {
    method: request.method,
    headers,
    body: hasBody ? await request.arrayBuffer() : undefined,
    redirect: "manual",
  });
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers,
  });
};

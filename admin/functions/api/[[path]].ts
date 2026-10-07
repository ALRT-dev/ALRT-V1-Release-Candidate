/**
 * Cloudflare Pages Function: relays every /api/* request from the Admin
 * Portal to the TEST backend, server to server, so the browser only ever
 * talks to the portal's own address (no CORS). The target can be changed
 * with the Pages environment variable API_ORIGIN; it defaults to the TEST
 * backend and is never the live api.safetyalrt.com unless set so on purpose.
 */
interface Env {
  API_ORIGIN?: string;
}

const DEFAULT_ORIGIN = "https://api-test.safetyalrt.com";

export const onRequest = async (context: {
  request: Request;
  env: Env;
}): Promise<Response> => {
  const { request, env } = context;
  const incoming = new URL(request.url);
  const origin = (env.API_ORIGIN || DEFAULT_ORIGIN).replace(/\/+$/, "");
  const target = `${origin}${incoming.pathname}${incoming.search}`;

  const headers = new Headers(request.headers);
  // A server-to-server call: drop the browser's origin so the backend's
  // CORS check treats it like any other non-browser client.
  headers.delete("origin");
  headers.delete("referer");
  headers.delete("host");

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

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

export const baseUrl = process.env.HIGHFIVE_HTTP_SMOKE_BASE_URL;
export const outDir = process.env.HIGHFIVE_HTTP_SMOKE_OUT_DIR ?? "/private/tmp/highfive-phase-67-0a-staging-backend-http-smoke";
export const loopbackHttpPrefix = "http" + "://127.0.0.1:";
export const localhostHttpPrefix = "http" + "://localhost:";

if (!baseUrl) {
  throw new Error("HIGHFIVE_HTTP_SMOKE_BASE_URL is required");
}
if (!baseUrl.startsWith(loopbackHttpPrefix) && !baseUrl.startsWith(localhostHttpPrefix)) {
  throw new Error("HTTP smoke tests may only target loopback hosts");
}

test.after(() => {
  assert.equal(baseUrl.includes("127.0.0.1") || baseUrl.includes("localhost"), true);
});

export function friendlyRequest(overrides = {}) {
  return {
    user_id: "smoke-user",
    anonymous_session_id: null,
    movie_id: "friendly",
    storekit_product_id: "com.highfive.movie.thefriendly",
    entitlement_context: {
      smoke: true
    },
    playback_provider: "cloudflare_stream",
    device_context: {
      platform: "local_http_smoke"
    },
    ...overrides
  };
}

export function playbackRequest(auditId, overrides = {}) {
  return {
    ...friendlyRequest(),
    audit_id: auditId,
    ...overrides
  };
}

export async function requestJson(path, options = {}) {
  const response = await fetch(/* local_http_smoke */ `${baseUrl}${path}`, {
    method: options.method ?? "GET",
    headers: options.headers,
    body: options.body
  });
  const text = await response.text();
  let json = null;
  if (text.length > 0) {
    try {
      json = JSON.parse(text);
    } catch {
      json = null;
    }
  }
  return {
    status: response.status,
    contentType: response.headers.get("content-type") ?? "",
    json,
    text
  };
}

export async function postJson(path, body, headers = {}) {
  return requestJson(path, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...headers
    },
    body: JSON.stringify(body)
  });
}

export async function postMalformedJson(path) {
  return requestJson(path, {
    method: "POST",
    headers: {
      "content-type": "application/json"
    },
    body: "{"
  });
}

export function assertJsonResponse(result, status) {
  assert.equal(result.status, status);
  assert.match(result.contentType, /application\/json/);
  assert.equal(typeof result.json, "object");
  assert.notEqual(result.json, null);
}

export function assertNoCredentialMaterial(value) {
  const rendered = JSON.stringify(value);
  assert.doesNotMatch(rendered, /HIGHFIVE_/);
  assert.doesNotMatch(rendered, /CLOUDFLARE/i);
  assert.doesNotMatch(rendered, /REVENUECAT/i);
  assert.doesNotMatch(rendered, /APP_STORE/i);
  assert.doesNotMatch(rendered, /PRIVATE_KEY/i);
  assert.doesNotMatch(rendered, /-----BEGIN/);
  assert.doesNotMatch(rendered, /Bearer\s+[A-Za-z0-9]/);
  assert.doesNotMatch(rendered, /(?:token|secret|api[_-]?key)\s*[:=]\s*[^<\s"']+/i);
}

export function assertNoRemoteUrl(value) {
  assert.doesNotMatch(JSON.stringify(value), /https?:\/\//i);
}

export function assertIsoDate(value) {
  assert.equal(typeof value, "string");
  assert.ok(!Number.isNaN(Date.parse(value)));
}

export function assertShortLived(expiresAt, now = Date.now()) {
  const expiresAtMs = Date.parse(expiresAt);
  assert.ok(expiresAtMs > now);
  assert.ok(expiresAtMs - now <= 10 * 60 * 1000 + 5_000);
}

export function readTextFile(path) {
  return readFileSync(path, "utf8");
}

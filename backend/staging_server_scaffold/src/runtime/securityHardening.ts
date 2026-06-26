import type { IncomingMessage, ServerResponse } from "node:http";
import { ContractError } from "../errors.js";
import type { RuntimeConfig } from "./runtimeConfig.js";

type RateBucket = {
  resetAt: number;
  count: number;
};

const rateBuckets = new Map<string, RateBucket>();

export function applySecurityHeaders(response: ServerResponse, requestID = requestIDValue()): void {
  const hardenedResponse = response as ServerResponse & { setHeader(name: string, value: string): void };
  hardenedResponse.setHeader("X-Content-Type-Options", "nosniff");
  hardenedResponse.setHeader("Referrer-Policy", "no-referrer");
  hardenedResponse.setHeader("X-Frame-Options", "DENY");
  hardenedResponse.setHeader("Cross-Origin-Resource-Policy", "same-origin");
  hardenedResponse.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
  hardenedResponse.setHeader("X-HighFive-Security-Baseline", "P43A");
  hardenedResponse.setHeader("X-HighFive-Request-ID", requestID);
}

export function enforceRateLimit(request: IncomingMessage, config: RuntimeConfig): void {
  const path = request.url?.split("?")[0] ?? "/";
  if (path === "/health" || path === "/ready") return;

  const key = `${clientKey(request)}:${path}`;
  const now = Date.now();
  const existing = rateBuckets.get(key);
  const bucket = existing && existing.resetAt > now
    ? existing
    : { resetAt: now + config.rateLimitWindowMs, count: 0 };
  bucket.count += 1;
  rateBuckets.set(key, bucket);

  if (bucket.count > config.rateLimitRequests) {
    throw new ContractError("rate_limited", "Too many requests for this local staging route.", 429);
  }
}

export function securityHardeningReadinessSummary(config: RuntimeConfig): Record<string, string | number | boolean> {
  return {
    security_headers: true,
    request_id_header: true,
    rate_limiting: true,
    rate_limit_requests: config.rateLimitRequests,
    rate_limit_window_ms: config.rateLimitWindowMs,
    privacy_export: true,
    account_deletion_revokes_sessions: true,
    structured_error_contract: true,
    credential_redaction_contract: true,
    backup_restore_runbook: true,
    rollback_runbook: true,
    external_network_blocked_by_default: true
  };
}

function clientKey(request: IncomingMessage): string {
  const authorization = request.headers.authorization;
  const authKey = Array.isArray(authorization) ? authorization[0] : authorization;
  if (authKey) return `auth:${authKey.slice(0, 64)}`;
  return "ip:loopback";
}

function requestIDValue(): string {
  return `hf-req-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
}

import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, baseUrl, localhostHttpPrefix, loopbackHttpPrefix, outDir, postJson, readOptionalTextFile, readTextFile, requestJson } from "./testHelpers.mjs";

test("security http: server binds only to loopback", () => {
  assert.ok(baseUrl.startsWith(loopbackHttpPrefix) || baseUrl.startsWith(localhostHttpPrefix));
});

test("security http: no external request is attempted", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_EXTERNAL_NETWORK_REQUESTS, "false");
});

test("security http: no package install is attempted", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_PACKAGE_INSTALL, "false");
});

test("security http: no deployment is attempted", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_DEPLOYMENT, "false");
});

test("security http: no real .env file is read", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_ENV_FILE_READ, "false");
});

test("security http: no credentials are required", async () => {
  const result = await requestJson("/health");
  assert.equal(result.json.credentials_required, false);
});

test("security http: responses include browser and request hardening headers", async () => {
  const result = await requestJson("/health");
  assertJsonResponse(result, 200);
  assert.equal(result.headers.get("x-content-type-options"), "nosniff");
  assert.equal(result.headers.get("referrer-policy"), "no-referrer");
  assert.equal(result.headers.get("x-frame-options"), "DENY");
  assert.equal(result.headers.get("cross-origin-resource-policy"), "same-origin");
  assert.equal(result.headers.get("x-highfive-security-baseline"), "P43A");
  assert.match(result.headers.get("x-highfive-request-id") ?? "", /^hf-req-/);
});

test("security http: readiness exposes security, privacy, and reliability controls", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);
  assert.equal(result.json.security_headers, true);
  assert.equal(result.json.request_id_header, true);
  assert.equal(result.json.rate_limiting, true);
  assert.equal(result.json.privacy_export, true);
  assert.equal(result.json.account_deletion_revokes_sessions, true);
  assert.equal(result.json.credential_redaction_contract, true);
  assert.equal(result.json.backup_restore_runbook, true);
  assert.equal(result.json.rollback_runbook, true);
});

test("security http: route-scoped rate limit rejects excessive requests", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  const attempts = Number(ready.json.rate_limit_requests) + 2;
  let limited = null;
  for (let index = 0; index < attempts; index += 1) {
    const result = await requestJson("/v1/security/rate-limit-probe");
    if (result.status === 429) {
      limited = result;
      break;
    }
  }
  assert.notEqual(limited, null);
  assertJsonResponse(limited, 429);
  assert.equal(limited.json.error, "rate_limited");
});

test("security http: privacy export is sanitized and deletion revokes local sessions", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  const auth = { authorization: `HighFiveSession ${signIn.json.session.session_id}` };

  const exported = await requestJson("/v1/identity/data-export", { headers: auth });
  assertJsonResponse(exported, 200);
  assert.equal(exported.json.status, "export_ready");
  assert.equal(exported.json.user.user_id, signIn.json.session.user_id);
  assert.equal(exported.json.retention_policy.deletion_request_revokes_sessions, true);
  assertNoCredentialMaterial(exported.json);

  const deleted = await postJson("/v1/identity/delete-request", {}, auth);
  assertJsonResponse(deleted, 200);
  assert.equal(deleted.json.status, "deletion_requested");
  assert.equal(deleted.json.revoked_sessions >= 1, true);

  const afterDelete = await requestJson("/v1/identity/me", { headers: auth });
  assertJsonResponse(afterDelete, 401);
  assert.equal(afterDelete.json.error, "identity_session_required");
});

test("security http: server log contains no request body or response body", () => {
  const log = readOptionalTextFile(`${outDir}/server.log`);
  assert.doesNotMatch(log, /"movie_id"/);
  assert.doesNotMatch(log, /"entitlement_status"/);
  assert.doesNotMatch(log, /"playback_descriptor_status"/);
});

test("security http: descriptor reference is not logged", () => {
  const log = readOptionalTextFile(`${outDir}/server.log`);
  assert.doesNotMatch(log, /playback_url_or_token_reference/i);
  assert.doesNotMatch(log, /MOCK_DESCRIPTOR_REFERENCE/);
});

test("security http: Local Preview fallback policy remains documented", () => {
  const doc = readTextFile("../../docs/production_services/HIGHFIVE_STAGING_BACKEND_HTTP_DEPLOYMENT_TARGET_SMOKE_TEST.md");
  assert.match(doc, /Local Preview fallback remains available/);
});

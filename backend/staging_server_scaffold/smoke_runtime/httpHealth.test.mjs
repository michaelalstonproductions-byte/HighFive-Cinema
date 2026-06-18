import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, assertNoRemoteUrl, requestJson } from "./testHelpers.mjs";

test("health: GET /health returns 200", async () => {
  const result = await requestJson("/health");
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "ok");
});

test("health: body reports local smoke runtime", async () => {
  const result = await requestJson("/health");
  assert.equal(result.json.environment, "local_smoke");
  assert.equal(result.json.provider_mode, "mock");
  assert.equal(result.json.deployment_status, "not_deployed");
});

test("health: response contains no credential or URL value", async () => {
  const result = await requestJson("/health");
  assertNoCredentialMaterial(result.json);
  assertNoRemoteUrl(result.json);
});

test("health: POST /health returns 405", async () => {
  const result = await requestJson("/health", { method: "POST" });
  assertJsonResponse(result, 405);
  assert.equal(result.json.error, "method_not_allowed");
});

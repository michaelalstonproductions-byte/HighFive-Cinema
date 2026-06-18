import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, friendlyRequest, postJson, requestJson } from "./testHelpers.mjs";

test("entitlement http: Friendly approved request returns entitlement_approved", async () => {
  const result = await postJson("/entitlements/validate", friendlyRequest(), {
    "x-highfive-smoke-entitlement-mode": "approved"
  });
  assertJsonResponse(result, 200);
  assert.equal(result.json.entitlement_status, "entitlement_approved");
  assert.match(result.json.audit_id, /^audit-friendly-\d+$/);
});

test("entitlement http: Paranormall season approved request returns entitlement_approved", async () => {
  const result = await postJson(
    "/entitlements/validate",
    friendlyRequest({
      movie_id: "paranormall-s1",
      storekit_product_id: "com.highfive.series.paranormall.season1"
    }),
    { "x-highfive-smoke-entitlement-mode": "approved" }
  );
  assert.equal(result.json.entitlement_status, "entitlement_approved");
});

test("entitlement http: Paranormall episode request uses correct product mapping", async () => {
  const result = await postJson(
    "/entitlements/validate",
    friendlyRequest({
      movie_id: "paranormall_s1_e7",
      storekit_product_id: "com.highfive.episode.paranormall.e7"
    }),
    { "x-highfive-smoke-entitlement-mode": "approved" }
  );
  assert.equal(result.json.entitlement_status, "entitlement_approved");
});

test("entitlement http: denied mode returns entitlement_denied", async () => {
  const result = await postJson("/entitlements/validate", friendlyRequest(), {
    "x-highfive-smoke-entitlement-mode": "denied"
  });
  assert.equal(result.json.entitlement_status, "entitlement_denied");
  assert.equal(result.json.denial_reason, "mock_entitlement_denied");
});

test("entitlement http: pending mode returns entitlement_pending", async () => {
  const result = await postJson("/entitlements/validate", friendlyRequest(), {
    "x-highfive-smoke-entitlement-mode": "pending"
  });
  assert.equal(result.json.entitlement_status, "entitlement_pending");
  assert.equal(result.json.denial_reason, "mock_entitlement_pending");
});

test("entitlement http: unknown movie is rejected", async () => {
  const result = await postJson(
    "/entitlements/validate",
    friendlyRequest({
      movie_id: "unknown-movie",
      storekit_product_id: "com.highfive.movie.unknown"
    }),
    { "x-highfive-smoke-entitlement-mode": "approved" }
  );
  assert.equal(result.json.entitlement_status, "entitlement_denied");
  assert.equal(result.json.denial_reason, "product_mapping_mismatch");
});

test("entitlement http: movie/product mismatch is rejected before provider approval", async () => {
  const result = await postJson(
    "/entitlements/validate",
    friendlyRequest({
      storekit_product_id: "com.highfive.series.paranormall.season1"
    }),
    { "x-highfive-smoke-entitlement-mode": "approved" }
  );
  assert.equal(result.json.entitlement_status, "entitlement_denied");
  assert.equal(result.json.denial_reason, "product_mapping_mismatch");
});

test("entitlement http: missing required fields return a client error", async () => {
  const result = await postJson("/entitlements/validate", { movie_id: "friendly" });
  assertJsonResponse(result, 400);
  assert.equal(result.json.error, "invalid_entitlement_request");
});

test("entitlement http: GET /entitlements/validate returns 405", async () => {
  const result = await requestJson("/entitlements/validate");
  assertJsonResponse(result, 405);
  assert.equal(result.json.error, "method_not_allowed");
});

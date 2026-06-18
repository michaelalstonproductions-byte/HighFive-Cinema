import assert from "node:assert/strict";
import test from "node:test";
import {
  assertIsoDate,
  assertJsonResponse,
  assertNoCredentialMaterial,
  assertShortLived,
  friendlyRequest,
  playbackRequest,
  postJson,
  requestJson
} from "./testHelpers.mjs";

async function approvedEntitlement(overrides = {}) {
  const result = await postJson("/entitlements/validate", friendlyRequest(overrides), {
    "x-highfive-smoke-entitlement-mode": "approved"
  });
  assert.equal(result.json.entitlement_status, "entitlement_approved");
  return result.json;
}

test("playback descriptor http: approved entitlement audit can request descriptor", async () => {
  const entitlement = await approvedEntitlement();
  const result = await postJson("/playback/descriptor", playbackRequest(entitlement.audit_id), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assertJsonResponse(result, 200);
  assert.equal(result.json.playback_descriptor_status, "descriptor_ready");
});

test("playback descriptor http: ready signer returns descriptor_ready with expiry and refresh", async () => {
  const now = Date.now();
  const entitlement = await approvedEntitlement();
  const result = await postJson("/playback/descriptor", playbackRequest(entitlement.audit_id), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assert.equal(result.json.playback_descriptor_status, "descriptor_ready");
  assertIsoDate(result.json.expires_at);
  assertIsoDate(result.json.refresh_after);
  assert.ok(Date.parse(result.json.refresh_after) < Date.parse(result.json.expires_at));
  assertShortLived(result.json.expires_at, now);
});

test("playback descriptor http: unavailable signer returns descriptor_unavailable", async () => {
  const entitlement = await approvedEntitlement();
  const result = await postJson("/playback/descriptor", playbackRequest(entitlement.audit_id), {
    "x-highfive-smoke-descriptor-mode": "unavailable"
  });
  assert.equal(result.json.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(result.json.playback_url_or_token_reference, null);
  assert.equal(result.json.denial_reason, "descriptor_signer_unavailable");
});

test("playback descriptor http: denied entitlement audit does not issue descriptor", async () => {
  const denied = await postJson("/entitlements/validate", friendlyRequest(), {
    "x-highfive-smoke-entitlement-mode": "denied"
  });
  const result = await postJson("/playback/descriptor", playbackRequest(denied.json.audit_id), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assert.equal(result.json.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(result.json.playback_url_or_token_reference, null);
  assert.equal(result.json.denial_reason, "entitlement_audit_not_approved");
});

test("playback descriptor http: unknown audit ID does not issue descriptor", async () => {
  const result = await postJson("/playback/descriptor", playbackRequest("audit-friendly-missing"), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assert.equal(result.json.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(result.json.denial_reason, "entitlement_audit_not_approved");
});

test("playback descriptor http: mismatched movie/product pair does not issue descriptor", async () => {
  const entitlement = await approvedEntitlement();
  const result = await postJson(
    "/playback/descriptor",
    playbackRequest(entitlement.audit_id, {
      storekit_product_id: "com.highfive.series.paranormall.season1"
    }),
    { "x-highfive-smoke-descriptor-mode": "ready" }
  );
  assert.equal(result.json.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(result.json.denial_reason, "product_mapping_mismatch");
});

test("playback descriptor http: GET /playback/descriptor returns 405", async () => {
  const result = await requestJson("/playback/descriptor");
  assertJsonResponse(result, 405);
  assert.equal(result.json.error, "method_not_allowed");
});

test("playback descriptor http: descriptor response contains no provider credential", async () => {
  const entitlement = await approvedEntitlement();
  const result = await postJson("/playback/descriptor", playbackRequest(entitlement.audit_id), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assertNoCredentialMaterial(result.json);
});

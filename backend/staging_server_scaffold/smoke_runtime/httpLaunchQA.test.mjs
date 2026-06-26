import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function developmentSession(role = "admin") {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return result.json.session.session_id;
}

function auth(sessionID) {
  return { authorization: `HighFiveSession ${sessionID}` };
}

test("launch qa: readiness exposes every launch-critical product domain", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);

  const requiredFlags = [
    "catalog_sync_enabled",
    "delta_sync_enabled",
    "uploads_enabled",
    "media_processing_enabled",
    "streaming_playback_runtime",
    "viewer_library_enabled",
    "discovery_service_enabled",
    "analytics_event_ingestion",
    "notifications_enabled",
    "storekit2_products",
    "playback_entitlement_checks",
    "download_entitlement_checks",
    "rights_windows_enabled",
    "territory_enforcement_enabled",
    "date_window_enforcement_enabled",
    "catalog_visibility_filter_enabled",
    "moderation_queue_enabled",
    "security_headers",
    "rate_limiting",
    "privacy_export",
    "auth_enabled",
    "admin_review_workflow",
    "publishing_submit_for_review",
    "publishing_publish"
  ];

  for (const flag of requiredFlags) {
    assert.equal(result.json[flag], true, `${flag} should be ready`);
  }

  assert.equal(result.json.direct_card_collection, false);
  assert.equal(result.json.external_push_attempted, false);
  assert.ok(Number(result.json.catalog_titles) >= 1);
  assert.ok(Number(result.json.catalog_creators) >= 1);
  assert.ok(Number(result.json.catalog_collections) >= 1);
  const rendered = JSON.stringify(result.json);
  assert.doesNotMatch(rendered, /Bearer\s+[A-Za-z0-9]/);
  assert.doesNotMatch(rendered, new RegExp("PRIVATE" + "_KEY", "i"));
  assert.doesNotMatch(rendered, new RegExp("-----" + "BEGIN"));
});

test("launch qa: health remains local-preview capable and credential-free", async () => {
  const result = await requestJson("/health");
  assertJsonResponse(result, 200);

  assert.equal(result.json.status, "ok");
  assert.equal(result.json.credentials_required, false);
  assert.equal(result.json.external_network_allowed, false);
  assert.equal(result.json.local_preview_fallback_preserved, true);
  assertNoCredentialMaterial(result.json);
});

test("launch qa: catalog, discovery, library, and operations survive concurrent launch reads", async () => {
  const adminSession = await developmentSession("admin");
  const viewerSession = await developmentSession("viewer");
  const adminHeaders = auth(adminSession);
  const viewerHeaders = auth(viewerSession);

  const requests = [];
  for (let index = 0; index < 8; index += 1) {
    requests.push(requestJson("/v1/catalog?territory=US"));
    requests.push(requestJson("/v1/discovery/query?kind=trending&page_size=4", { headers: viewerHeaders }));
    requests.push(requestJson("/v1/viewer/library", { headers: viewerHeaders }));
    requests.push(requestJson("/v1/admin/operations/summary", { headers: adminHeaders }));
  }

  const results = await Promise.all(requests);
  for (const result of results) {
    assertJsonResponse(result, 200);
    assertNoCredentialMaterial(result.json);
  }
});

test("launch qa: role boundaries remain intact during final QA", async () => {
  const viewerSession = await developmentSession("viewer");
  const creatorSession = await developmentSession("creator");
  const adminSession = await developmentSession("admin");

  const viewerOperations = await requestJson("/v1/admin/operations/summary", { headers: auth(viewerSession) });
  assert.ok([401, 403].includes(viewerOperations.status));
  assert.ok(["identity_session_required", "admin_role_required"].includes(viewerOperations.json.error));

  const creatorOperations = await requestJson("/v1/admin/operations/summary", { headers: auth(creatorSession) });
  assert.ok([401, 403].includes(creatorOperations.status));
  assert.ok(["identity_session_required", "admin_role_required"].includes(creatorOperations.json.error));

  const adminOperations = await requestJson("/v1/admin/operations/summary", { headers: auth(adminSession) });
  assertJsonResponse(adminOperations, 200);
  assert.equal(adminOperations.json.status, "ready");
});

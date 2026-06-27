import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    creatorID: result.json.session.creator_id,
    userID: result.json.session.user_id
  };
}

test("v3 marketplace: readiness exposes local marketplace capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_marketplace_enabled, true);
  assert.equal(ready.json.v3_marketplace_license_marketplace, true);
  assert.equal(ready.json.v3_marketplace_distribution_marketplace, true);
  assert.equal(ready.json.v3_marketplace_creator_services, true);
  assert.equal(ready.json.v3_marketplace_production_services, true);
  assert.equal(ready.json.v3_marketplace_music_marketplace, true);
  assert.equal(ready.json.v3_marketplace_stock_footage_marketplace, true);
  assert.equal(ready.json.v3_marketplace_transaction_processing, false);
  assert.equal(ready.json.v3_marketplace_external_services, false);
  assert.ok(ready.json.v3_marketplace_license_listings >= 1);
  assert.ok(ready.json.v3_marketplace_service_listings >= 1);
  assert.ok(ready.json.v3_marketplace_asset_listings >= 1);
});

test("v3 marketplace: summary returns seeded marketplace records", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/marketplace/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.marketplace, "local_v3_marketplace");
  assert.equal(summary.json.transaction_processing, false);
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.creator_id, creator.creatorID);
  assert.ok(summary.json.licenses.some((record) => record.id === "marketplace-license-seed-1"));
  assert.ok(summary.json.distribution.some((record) => record.id === "marketplace-distribution-seed-1"));
  assert.ok(summary.json.creator_services.some((record) => record.id === "marketplace-creator-service-seed-1"));
  assert.ok(summary.json.production_services.some((record) => record.id === "marketplace-production-service-seed-1"));
  assert.ok(summary.json.music.some((record) => record.id === "marketplace-music-seed-1"));
  assert.ok(summary.json.stock_footage.some((record) => record.id === "marketplace-stock-footage-seed-1"));
  assert.ok(summary.json.dashboard.available_records >= 1);
  assertNoCredentialMaterial(summary.json);
});

test("v3 marketplace: creator can create marketplace listings", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const license = await postJson("/v3/marketplace/licenses", {
    content_id: "friendly",
    title: "Friendly Education Window",
    territory: "CA",
    window_label: "Education preview",
    rights_scope: "education",
    status: "available"
  }, headers);
  assertJsonResponse(license, 201);
  assert.equal(license.json.license.rights_scope, "education");

  const distribution = await postJson("/v3/marketplace/distribution", {
    target: "partner",
    package_id: "release-package-friendly",
    readiness: "needs_review",
    territory: "GB"
  }, headers);
  assertJsonResponse(distribution, 201);
  assert.equal(distribution.json.distribution.target, "partner");

  const creatorService = await postJson("/v3/marketplace/creator-services", {
    name: "Metadata Polish",
    service_type: "metadata",
    availability: "available",
    delivery_window: "One local review day"
  }, headers);
  assertJsonResponse(creatorService, 201);
  assert.equal(creatorService.json.creator_service.service_type, "metadata");

  const productionService = await postJson("/v3/marketplace/production-services", {
    name: "Local Crew Review",
    service_type: "crew",
    region: "New York",
    availability: "review"
  }, headers);
  assertJsonResponse(productionService, 201);
  assert.equal(productionService.json.production_service.service_type, "crew");

  const music = await postJson("/v3/marketplace/music", {
    title: "Warm Premiere Cue",
    mood: "warm",
    duration_seconds: 122,
    license_scope: "feature",
    status: "available"
  }, headers);
  assertJsonResponse(music, 201);
  assert.equal(music.json.music.mood, "warm");

  const stock = await postJson("/v3/marketplace/stock-footage", {
    title: "Aerial Studio Plate",
    category: "aerial",
    resolution: "8K",
    license_scope: "commercial",
    status: "available"
  }, headers);
  assertJsonResponse(stock, 201);
  assert.equal(stock.json.stock_footage.resolution, "8K");

  const summary = await requestJson("/v3/marketplace/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.licenses.some((record) => record.id === license.json.license.id));
  assert.ok(summary.json.distribution.some((record) => record.id === distribution.json.distribution.id));
  assert.ok(summary.json.creator_services.some((record) => record.id === creatorService.json.creator_service.id));
  assert.ok(summary.json.production_services.some((record) => record.id === productionService.json.production_service.id));
  assert.ok(summary.json.music.some((record) => record.id === music.json.music.id));
  assert.ok(summary.json.stock_footage.some((record) => record.id === stock.json.stock_footage.id));
});

test("v3 marketplace: viewer cannot access marketplace operations", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v3/marketplace/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "marketplace_role_required");

  const license = await postJson("/v3/marketplace/licenses", {
    title: "Viewer License"
  }, { authorization: viewer.authorization });
  assertJsonResponse(license, 403);
  assert.equal(license.json.error, "marketplace_role_required");
});

test("v3 marketplace: OpenAPI exposes marketplace paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/marketplace/summary"]);
  assert.ok(spec.json.paths["/v3/marketplace/licenses"]);
  assert.ok(spec.json.paths["/v3/marketplace/distribution"]);
  assert.ok(spec.json.paths["/v3/marketplace/creator-services"]);
  assert.ok(spec.json.paths["/v3/marketplace/production-services"]);
  assert.ok(spec.json.paths["/v3/marketplace/music"]);
  assert.ok(spec.json.paths["/v3/marketplace/stock-footage"]);
});

import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, requestJson } from "./testHelpers.mjs";

test("catalog: GET /ready reports seed catalog readiness", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "ready");
  assert.equal(result.json.seed_data_loaded, true);
  assert.equal(result.json.auth_enabled, true);
  assert.equal(result.json.sign_in_with_apple_contract, true);
  assert.equal(result.json.development_identity_mode, true);
  assert.equal(result.json.role_authorization, true);
  assert.equal(result.json.catalog_sync_enabled, true);
  assert.equal(result.json.delta_sync_enabled, true);
  assert.equal(result.json.uploads_enabled, true);
  assert.equal(result.json.signed_upload_sessions, true);
  assert.equal(result.json.local_object_storage, true);
  assert.equal(result.json.upload_checksum_validation, true);
  assert.equal(result.json.media_processing_enabled, true);
  assert.equal(result.json.ffprobe_inspection_contract, true);
  assert.equal(result.json.ffmpeg_processing_contract, true);
  assert.equal(result.json.hls_output_contract, true);
  assert.equal(result.json.payments_enabled, true);
  assert.equal(result.json.rights_windows_enabled, true);
  assert.equal(result.json.availability_enforcement_enabled, true);
  assert.equal(result.json.moderation_queue_enabled, true);
});

test("catalog: GET /v1/catalog returns read-only catalog", async () => {
  const result = await requestJson("/v1/catalog");
  assertJsonResponse(result, 200);
  assert.equal(result.json.source, "local_seed");
  assert.equal(result.json.total_titles >= 3, true);
  assert.equal(result.json.movies.some((movie) => movie.id === "friendly"), true);
  assertNoCredentialMaterial(result.json);
});

test("catalog: detail, creator, and collection endpoints resolve seeded IDs", async () => {
  const content = await requestJson("/v1/content/friendly");
  assertJsonResponse(content, 200);
  assert.equal(content.json.id, "friendly");

  const creator = await requestJson("/v1/creators/maya-hart");
  assertJsonResponse(creator, 200);
  assert.equal(creator.json.id, "maya-hart");
  assert.equal(creator.json.titles.length >= 1, true);

  const collection = await requestJson("/v1/collections/featured");
  assertJsonResponse(collection, 200);
  assert.equal(collection.json.id, "featured");
  assert.equal(collection.json.titles.length >= 1, true);
});

test("catalog: missing content returns 404", async () => {
  const result = await requestJson("/v1/content/not-found");
  assertJsonResponse(result, 404);
  assert.equal(result.json.error, "content_not_found");
});

test("catalog: full sync returns versioned cursor and cloud title", async () => {
  const result = await requestJson("/v1/catalog/sync");
  assertJsonResponse(result, 200);
  assert.equal(result.json.full_sync, true);
  assert.equal(result.json.catalog_version, 31);
  assert.equal(result.json.sync_cursor, "catalog-v31-full");
  assert.equal(result.json.movies.some((movie) => movie.id === "cloud-festival-premiere"), true);
  assert.equal(result.json.tombstones.length >= 1, true);
  assertNoCredentialMaterial(result.json);
});

test("catalog: delta sync returns upserts, tombstones, and next cursor", async () => {
  const result = await requestJson("/v1/catalog/delta?cursor=catalog-v31-full");
  assertJsonResponse(result, 200);
  assert.equal(result.json.full_sync, false);
  assert.equal(result.json.catalog_version, 32);
  assert.equal(result.json.previous_cursor, "catalog-v31-full");
  assert.equal(result.json.sync_cursor, "catalog-v32-delta");
  assert.equal(result.json.movies.some((movie) => movie.id === "cloud-director-cut"), true);
  assert.equal(result.json.tombstones.some((record) => record.entity_id === "cloud-festival-premiere"), true);
  assertNoCredentialMaterial(result.json);
});

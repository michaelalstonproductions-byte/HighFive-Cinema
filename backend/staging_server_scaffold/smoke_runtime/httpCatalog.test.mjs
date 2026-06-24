import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, requestJson } from "./testHelpers.mjs";

test("catalog: GET /ready reports seed catalog readiness", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "ready");
  assert.equal(result.json.seed_data_loaded, true);
  assert.equal(result.json.auth_enabled, false);
  assert.equal(result.json.uploads_enabled, false);
  assert.equal(result.json.payments_enabled, false);
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

import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, requestJson } from "./testHelpers.mjs";

test("catalog: GET /ready reports seed catalog readiness", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "ready");
  assert.equal(result.json.seed_data_loaded, true);
  assert.equal(result.json.catalog_titles >= 3, true);
  assert.equal(result.json.catalog_creators >= 2, true);
  assert.equal(result.json.catalog_series >= 1, true);
  assert.equal(result.json.catalog_collections >= 5, true);
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
  assertCatalogGraph(result.json);
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
  assertCatalogGraph(result.json);
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
  assertNoDuplicateIDs(result.json.movies, "delta movies");
  assertNoDuplicateIDs(result.json.collections, "delta collections");
  assertNoCredentialMaterial(result.json);
});

test("catalog: full sync is a fresh-install cloud catalog payload", async () => {
  const result = await requestJson("/v1/catalog/sync?cursor=");
  assertJsonResponse(result, 200);
  const catalog = result.json;
  assert.equal(catalog.total_titles, catalog.movies.length);
  assert.equal(catalog.total_creators, catalog.creators.length);
  assert.equal(catalog.total_series, catalog.series.length);
  assert.equal(catalog.total_collections, catalog.collections.length);
  assert.equal(catalog.series.some((series) => series.seasons.some((season) => season.episodes.length > 0)), true);
  assert.equal(catalog.collections.some((collection) => collection.movie_ids.includes("cloud-festival-premiere")), true);
  assertCatalogGraph(catalog);
  assertNoCredentialMaterial(catalog);
});

test("catalog: delta payload can be merged without duplicate catalog records", async () => {
  const full = await requestJson("/v1/catalog/sync");
  const delta = await requestJson(`/v1/catalog/delta?cursor=${encodeURIComponent(full.json.sync_cursor)}`);
  assertJsonResponse(full, 200);
  assertJsonResponse(delta, 200);

  const movieMap = new Map(full.json.movies.map((movie) => [movie.id, movie]));
  for (const tombstone of delta.json.tombstones) {
    if (tombstone.entity_type === "movie") movieMap.delete(tombstone.entity_id);
  }
  for (const movie of delta.json.movies) {
    movieMap.set(movie.id, movie);
  }

  const collectionMap = new Map(full.json.collections.map((collection) => [collection.id, collection]));
  for (const collection of delta.json.collections) {
    collectionMap.set(collection.id, collection);
  }

  assert.equal(movieMap.has("cloud-festival-premiere"), false);
  assert.equal(movieMap.has("cloud-director-cut"), true);
  assert.equal([...movieMap.keys()].length, new Set(movieMap.keys()).size);
  assert.equal([...collectionMap.keys()].length, new Set(collectionMap.keys()).size);
  assert.equal(collectionMap.get("creator-published").movie_ids.includes("cloud-director-cut"), true);
});

function assertCatalogGraph(catalog) {
  assertNoDuplicateIDs(catalog.movies, "movies");
  assertNoDuplicateIDs(catalog.creators, "creators");
  assertNoDuplicateIDs(catalog.series, "series");
  assertNoDuplicateIDs(catalog.collections, "collections");

  const movieIDs = new Set(catalog.movies.map((movie) => movie.id));
  const creatorIDs = new Set(catalog.creators.map((creator) => creator.id));

  for (const movie of catalog.movies) {
    assert.equal(creatorIDs.has(movie.creator_id), true, `movie ${movie.id} creator ${movie.creator_id} exists`);
  }
  for (const collection of catalog.collections) {
    for (const movieID of collection.movie_ids) {
      assert.equal(movieIDs.has(movieID), true, `collection ${collection.id} movie ${movieID} exists`);
    }
  }
  for (const series of catalog.series) {
    assert.equal(movieIDs.has(series.hero_movie_id), true, `series ${series.id} hero exists`);
    assert.equal(creatorIDs.has(series.creator_id), true, `series ${series.id} creator exists`);
    for (const season of series.seasons) {
      assert.equal(season.series_id, series.id);
      assert.equal(season.episodes.length > 0, true);
      for (const episode of season.episodes) {
        assert.equal(episode.series_id, series.id);
        assert.equal(episode.season_number, season.season_number);
      }
    }
  }
}

function assertNoDuplicateIDs(records, label) {
  const ids = records.map((record) => record.id);
  assert.equal(ids.length, new Set(ids).size, `${label} contain unique IDs`);
}

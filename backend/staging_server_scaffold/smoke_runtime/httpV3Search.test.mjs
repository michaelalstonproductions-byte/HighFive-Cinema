import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function viewerSession() {
  const result = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

test("v3 search: readiness exposes local AI search without external calls", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_ai_search_enabled, true);
  assert.equal(ready.json.v3_natural_language_search_enabled, true);
  assert.equal(ready.json.v3_semantic_search_enabled, true);
  assert.equal(ready.json.v3_visual_similarity_enabled, true);
  assert.equal(ready.json.v3_creator_similarity_enabled, true);
  assert.equal(ready.json.v3_voice_search_enabled, true);
  assert.equal(ready.json.v3_recommendation_search_enabled, true);
  assert.equal(ready.json.v3_search_external_ai_calls, false);
});

test("v3 search: natural language search returns interpreted intent and ranked results", async () => {
  const auth = await viewerSession();
  await postJson("/v1/viewer/library/save", {
    movie_id: "friendly",
    state: "favorite",
    saved: true
  }, auth);

  const search = await requestJson("/v3/search/query?q=show me HighFive original premiere drama", { headers: auth });
  assertJsonResponse(search, 200);
  assert.equal(search.json.engine, "local_v3_ai_search");
  assert.equal(search.json.external_ai_calls, false);
  assert.equal(search.json.mode, "natural_language");
  assert.equal(search.json.interpreted_intent.wants_originals, true);
  assert.equal(search.json.interpreted_intent.wants_premiere, true);
  assert.ok(search.json.ranking_signals.includes("natural_language"));
  assert.ok(search.json.results.length >= 1);
  assert.ok(search.json.results[0].score > 0);
  assertNoCredentialMaterial(search.json);
});

test("v3 search: semantic search expands concepts and explains matches", async () => {
  const auth = await viewerSession();
  const semantic = await requestJson("/v3/search/semantic?q=suspense filmmaker episodes", { headers: auth });
  assertJsonResponse(semantic, 200);
  assert.equal(semantic.json.mode, "semantic");
  assert.ok(semantic.json.semantic_vector.includes("mystery"));
  assert.ok(semantic.json.semantic_vector.includes("creator"));
  assert.ok(semantic.json.results.length >= 1);
  assert.ok(semantic.json.results.every((item) => Array.isArray(item.semantic_concepts)));
});

test("v3 search: visual similarity compares catalog metadata", async () => {
  const auth = await viewerSession();
  const visual = await requestJson("/v3/search/visual-similarity?movie_id=friendly", { headers: auth });
  assertJsonResponse(visual, 200);
  assert.equal(visual.json.mode, "visual_similarity");
  assert.equal(visual.json.source_movie_id, "friendly");
  assert.ok(visual.json.visual_basis.includes("genre_palette"));
  assert.ok(visual.json.results.length >= 1);
  assert.ok(visual.json.results.every((item) => item.movie_id !== "friendly"));
});

test("v3 search: creator similarity compares creator catalogs", async () => {
  const auth = await viewerSession();
  const creator = await requestJson("/v3/search/creator-similarity?creator_id=maya-hart", { headers: auth });
  assertJsonResponse(creator, 200);
  assert.equal(creator.json.mode, "creator_similarity");
  assert.equal(creator.json.source_creator_id, "maya-hart");
  assert.ok(creator.json.results.length >= 1);
  assert.ok(creator.json.results.every((item) => item.creator_id !== "maya-hart"));
});

test("v3 search: voice search normalizes transcript before ranking", async () => {
  const auth = await viewerSession();
  const voice = await requestJson("/v3/search/voice?transcript=Hey%20HighFive%20show%20me%20mystery%20episodes", { headers: auth });
  assertJsonResponse(voice, 200);
  assert.equal(voice.json.mode, "voice");
  assert.equal(voice.json.normalized_query, "mystery episodes");
  assert.equal(voice.json.interpreted_intent.wants_series, true);
  assert.ok(voice.json.results.length >= 1);
});

test("v3 search: recommendation search uses personalization context", async () => {
  const auth = await viewerSession();
  await postJson("/v1/viewer/library/progress", {
    movie_id: "paranormall-s1",
    progress: 0.58,
    completed: false
  }, auth);

  const recommendations = await requestJson("/v3/search/recommendations?q=creator mystery", { headers: auth });
  assertJsonResponse(recommendations, 200);
  assert.equal(recommendations.json.mode, "recommendation");
  assert.ok(recommendations.json.recommendation_context.dynamic_collection_count >= 1);
  assert.ok(recommendations.json.results.length >= 1);
  assertNoCredentialMaterial(recommendations.json);
});

test("v3 search: OpenAPI exposes V3 search paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/search/query"]);
  assert.ok(spec.json.paths["/v3/search/semantic"]);
  assert.ok(spec.json.paths["/v3/search/visual-similarity"]);
  assert.ok(spec.json.paths["/v3/search/creator-similarity"]);
  assert.ok(spec.json.paths["/v3/search/voice"]);
  assert.ok(spec.json.paths["/v3/search/recommendations"]);
});

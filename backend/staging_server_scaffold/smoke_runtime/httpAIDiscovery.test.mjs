import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function viewerSession() {
  const result = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

test("ai discovery: readiness exposes local personalized discovery without external AI calls", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.ai_discovery_enabled, true);
  assert.equal(ready.json.ai_discovery_external_calls, false);
  assert.equal(ready.json.personalized_recommendations_enabled, true);
  assert.equal(ready.json.watch_history_learning_enabled, true);
  assert.equal(ready.json.taste_profiles_enabled, true);
  assert.equal(ready.json.mood_discovery_enabled, true);
  assert.equal(ready.json.creator_affinity_enabled, true);
  assert.equal(ready.json.genre_prediction_enabled, true);
  assert.equal(ready.json.continue_watching_intelligence_enabled, true);
  assert.equal(ready.json.search_ranking_improvements_enabled, true);
});

test("ai discovery: personalized home learns from viewer history and saved titles", async () => {
  const auth = await viewerSession();
  await postJson("/v1/viewer/library/save", {
    movie_id: "friendly",
    state: "favorite",
    saved: true
  }, auth);
  await postJson("/v1/viewer/library/progress", {
    movie_id: "paranormall-s1",
    progress: 0.64,
    completed: false
  }, auth);

  const home = await requestJson("/v2/discovery/home", { headers: auth });
  assertJsonResponse(home, 200);
  assert.equal(home.json.engine, "local_ai_discovery_v1");
  assert.equal(home.json.external_ai_calls, false);
  assert.equal(home.json.personalized_home, true);
  assert.ok(home.json.taste_profile.top_genres.length >= 1);
  assert.ok(home.json.taste_profile.creator_affinity.length >= 1);
  assert.ok(home.json.taste_profile.mood_vector.length >= 1);
  assert.ok(home.json.continue_watching_intelligence.some((item) => item.movie_id === "paranormall-s1"));
  assert.ok(home.json.personalized_rails.some((rail) => rail.id === "because-you-watch" && rail.recommendations.length >= 1));
  assertNoCredentialMaterial(home.json);
});

test("ai discovery: mood endpoint returns explainable mood-filtered recommendations", async () => {
  const auth = await viewerSession();
  const mood = await requestJson("/v2/discovery/mood?mood=mystery", { headers: auth });
  assertJsonResponse(mood, 200);
  assert.equal(mood.json.engine, "local_ai_discovery_v1");
  assert.equal(mood.json.mood, "mystery");
  assert.ok(mood.json.recommendations.length >= 1);
  assert.ok(mood.json.recommendations.every((item) => typeof item.reason === "string" && item.reason.length > 0));
  assert.ok(mood.json.recommendations.every((item) => Array.isArray(item.genre_prediction)));
});

test("ai discovery: search ranking uses title, creator, genre, collection, synopsis, and taste signals", async () => {
  const auth = await viewerSession();
  const search = await requestJson("/v2/discovery/search?q=Maya", { headers: auth });
  assertJsonResponse(search, 200);
  assert.equal(search.json.engine, "local_ai_discovery_v1");
  assert.equal(search.json.query, "Maya");
  assert.ok(search.json.ranking_signals.includes("taste_profile"));
  assert.ok(search.json.ranking_signals.includes("watch_history"));
  assert.ok(search.json.results.length >= 1);
  assert.ok(search.json.results[0].matched_fields.length >= 1);
  assert.ok(search.json.suggestions.length >= 1);
  assertNoCredentialMaterial(search.json);
});

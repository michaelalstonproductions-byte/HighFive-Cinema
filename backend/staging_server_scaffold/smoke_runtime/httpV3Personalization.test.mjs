import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function viewerSession() {
  const result = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

test("v3 personalization: readiness exposes local intelligence platform without external calls", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_personalization_enabled, true);
  assert.equal(ready.json.v3_personalized_home_enabled, true);
  assert.equal(ready.json.v3_taste_graph_enabled, true);
  assert.equal(ready.json.v3_mood_engine_enabled, true);
  assert.equal(ready.json.v3_behavior_learning_enabled, true);
  assert.equal(ready.json.v3_smart_continue_watching_enabled, true);
  assert.equal(ready.json.v3_dynamic_collections_enabled, true);
  assert.equal(ready.json.v3_adaptive_discovery_enabled, true);
  assert.equal(ready.json.v3_personalization_external_ai_calls, false);
});

test("v3 personalization: personalized home adapts to saved and progress behavior", async () => {
  const auth = await viewerSession();
  await postJson("/v1/viewer/library/save", {
    movie_id: "friendly",
    state: "favorite",
    saved: true
  }, auth);
  await postJson("/v1/viewer/library/progress", {
    movie_id: "paranormall-s1",
    progress: 0.72,
    completed: false
  }, auth);

  const home = await requestJson("/v3/personalization/home", { headers: auth });
  assertJsonResponse(home, 200);
  assert.equal(home.json.engine, "local_v3_personalization_platform");
  assert.equal(home.json.external_ai_calls, false);
  assert.ok(home.json.personalized_home.primary_recommendations.length >= 1);
  assert.ok(home.json.dynamic_collections.length >= 1);
  assert.ok(home.json.smart_continue_watching.some((item) => item.movie_id === "paranormall-s1" && item.next_action_label === "Resume"));
  assert.ok(home.json.behavior_learning.total_signals >= 2);
  assert.ok(home.json.taste_graph.nodes.length >= 1);
  assert.ok(home.json.taste_graph.edges.length >= 1);
  assertNoCredentialMaterial(home.json);
});

test("v3 personalization: taste graph returns nodes, edges, and learned weights", async () => {
  const auth = await viewerSession();
  await postJson("/v1/viewer/library/save", {
    movie_id: "friendly",
    state: "watch_later",
    saved: true
  }, auth);

  const graph = await requestJson("/v3/personalization/taste-graph", { headers: auth });
  assertJsonResponse(graph, 200);
  assert.equal(graph.json.engine, "local_v3_personalization_platform");
  assert.ok(graph.json.taste_graph.nodes.some((node) => node.type === "genre"));
  assert.ok(graph.json.taste_graph.nodes.some((node) => node.type === "title"));
  assert.ok(graph.json.taste_graph.graph_density > 0);
  assert.ok(graph.json.behavior_learning.learned_weights.saved_titles > 0);
  assertNoCredentialMaterial(graph.json);
});

test("v3 personalization: mood engine builds deterministic mood rails", async () => {
  const auth = await viewerSession();
  const mood = await requestJson("/v3/personalization/mood-engine", { headers: auth });
  assertJsonResponse(mood, 200);
  assert.equal(mood.json.engine, "local_v3_personalization_platform");
  assert.ok(mood.json.mood_engine.active_mood.length > 0);
  assert.ok(mood.json.mood_engine.mood_vector.length >= 1);
  assert.ok(mood.json.mood_engine.mood_rails.length >= 1);
  assert.ok(mood.json.mood_engine.mood_rails.every((rail) => Array.isArray(rail.titles)));
});

test("v3 personalization: adaptive discovery returns layout and dynamic collections", async () => {
  const auth = await viewerSession();
  await postJson("/v1/viewer/library/progress", {
    movie_id: "friendly",
    progress: 0.41,
    completed: false
  }, auth);

  const discovery = await requestJson("/v3/personalization/adaptive-discovery", { headers: auth });
  assertJsonResponse(discovery, 200);
  assert.equal(discovery.json.engine, "local_v3_personalization_platform");
  assert.equal(discovery.json.adaptive_discovery.layout_strategy, "resume_first");
  assert.ok(discovery.json.adaptive_discovery.slot_order.includes("dynamic_collections"));
  assert.ok(discovery.json.adaptive_discovery.top_titles.length >= 1);
  assert.ok(discovery.json.dynamic_collections.length >= 1);
});

test("v3 personalization: OpenAPI exposes V3 personalization paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/personalization/home"]);
  assert.ok(spec.json.paths["/v3/personalization/taste-graph"]);
  assert.ok(spec.json.paths["/v3/personalization/mood-engine"]);
  assert.ok(spec.json.paths["/v3/personalization/adaptive-discovery"]);
});

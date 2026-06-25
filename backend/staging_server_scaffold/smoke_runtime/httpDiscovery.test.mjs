import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function viewerAuth() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  return { authorization: `HighFiveSession ${signIn.json.session.session_id}` };
}

test("discovery: title search, filters, pagination, and suggestions resolve through service", async () => {
  const result = await requestJson("/v1/discovery/query?q=Friendly&filter=Movies&page=1&page_size=1");
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "ready");
  assert.equal(result.json.source, "loopback_discovery_service");
  assert.equal(result.json.titles.length, 1);
  assert.equal(result.json.titles[0].id, "friendly");
  assert.equal(result.json.suggestions.includes("The Friendly"), true);
  assert.equal(result.json.analytics.search_events >= 1, true);
  assertNoCredentialMaterial(result.json);
});

test("discovery: creator, collection, series, episode, related, and creator-published queries work", async () => {
  const creator = await requestJson("/v1/discovery/query?kind=creator&q=Maya");
  assertJsonResponse(creator, 200);
  assert.equal(creator.json.creators.some((record) => record.id === "maya-hart"), true);

  const collection = await requestJson("/v1/discovery/query?kind=collection&collection_id=creator-published");
  assertJsonResponse(collection, 200);
  assert.equal(collection.json.collections[0].id, "creator-published");
  assert.equal(collection.json.titles.some((record) => record.id === "behind-the-vision"), true);

  const series = await requestJson("/v1/discovery/query?kind=series&series_id=paranormall-s1");
  assertJsonResponse(series, 200);
  assert.equal(series.json.series[0].id, "paranormall-s1");

  const episode = await requestJson("/v1/discovery/query?kind=episode&episode_id=paranormall-s1-e1");
  assertJsonResponse(episode, 200);
  assert.equal(episode.json.episodes[0].id, "paranormall-s1-e1");

  const related = await requestJson("/v1/discovery/query?kind=related&anchor_id=friendly");
  assertJsonResponse(related, 200);
  assert.equal(related.json.related_titles.some((record) => record.id !== "friendly"), true);

  const published = await requestJson("/v1/discovery/query?kind=creator-published");
  assertJsonResponse(published, 200);
  assert.equal(published.json.creator_published_titles.some((record) => record.id === "behind-the-vision"), true);
});

test("discovery: authenticated recommendations react to viewer library state", async () => {
  const auth = await viewerAuth();
  await postJson("/v1/viewer/library/save", { movie_id: "friendly", saved: true, state: "favorite" }, auth);
  await postJson("/v1/viewer/library/progress", { movie_id: "friendly", progress: 0.64, completed: false }, auth);

  const result = await requestJson("/v1/discovery/query?kind=recommendations&anchor_id=friendly", { headers: auth });
  assertJsonResponse(result, 200);
  assert.equal(result.json.recommendations.length >= 1, true);
  assert.equal(result.json.recommendations[0].reason.includes("saved titles"), true);
  assert.equal(result.json.cache_policy, "query-cache-with-local-fallback");
  assertNoCredentialMaterial(result.json);
});

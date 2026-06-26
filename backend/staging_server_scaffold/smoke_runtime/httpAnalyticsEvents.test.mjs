import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function signIn(role = "viewer") {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

test("analytics: event batches ingest, deduplicate, sanitize, and aggregate", async () => {
  const auth = await signIn("viewer");
  const batch = await postJson("/v1/analytics/events", {
    events: [
      {
        event_id: "evt-smoke-playback-start",
        idempotency_key: "idem-smoke-playback-start",
        event_name: "playback_start",
        content_id: "friendly",
        creator_id: "maya-hart",
        source: "smoke",
        properties: {
          progress: 0,
          watch_time_seconds: 0,
          email: "viewer@example.com",
          token: "Bearer should-not-appear"
        }
      },
      {
        event_id: "evt-smoke-playback-progress",
        idempotency_key: "idem-smoke-playback-progress",
        event_name: "playback_progress",
        content_id: "friendly",
        creator_id: "maya-hart",
        source: "smoke",
        properties: { progress: 0.52, watch_time_seconds: 1770 }
      },
      {
        event_id: "evt-smoke-playback-complete",
        idempotency_key: "idem-smoke-playback-complete",
        event_name: "playback_complete",
        content_id: "friendly",
        creator_id: "maya-hart",
        source: "smoke",
        properties: { progress: 1, watch_time_seconds: 5400 }
      },
      {
        event_id: "evt-smoke-search",
        idempotency_key: "idem-smoke-search",
        event_name: "search",
        source: "smoke",
        properties: { query: "Friendly", result_count: 1 }
      }
    ]
  }, auth);
  assertJsonResponse(batch, 202);
  assert.equal(batch.json.accepted_count, 4);
  assert.equal(batch.json.deduplicated_count, 0);
  assert.equal(batch.json.aggregations.completion_rate >= 100, true);
  assert.equal(batch.json.aggregations.watch_time_seconds >= 7170, true);
  assert.equal(batch.json.aggregations.retention.drop_off_events >= 1, true);
  assertNoCredentialMaterial(batch.json);

  const duplicate = await postJson("/v1/analytics/events", {
    events: [
      {
        event_id: "evt-smoke-playback-start",
        idempotency_key: "idem-smoke-playback-start",
        event_name: "playback_start",
        content_id: "friendly",
        source: "smoke"
      }
    ]
  }, auth);
  assertJsonResponse(duplicate, 202);
  assert.equal(duplicate.json.accepted_count, 0);
  assert.equal(duplicate.json.deduplicated_count, 1);

  const dashboard = await requestJson("/v1/analytics/dashboard", { headers: auth });
  assertJsonResponse(dashboard, 200);
  assert.equal(dashboard.json.aggregations.searches >= 1, true);
  assert.equal(dashboard.json.aggregations.top_content.some((record) => record.id === "friendly"), true);
  assert.equal(dashboard.json.aggregations.title_metrics.some((record) => record.content_id === "friendly" && record.watch_time_seconds >= 7170), true);
  assert.equal(dashboard.json.aggregations.creator_metrics.some((record) => record.creator_id === "maya-hart"), true);
  assertNoCredentialMaterial(dashboard.json);
});

test("analytics: product routes emit real events", async () => {
  const auth = await signIn("viewer");
  await requestJson("/v1/discovery/query?q=Friendly", { headers: auth });
  await requestJson("/v1/content/friendly", { headers: auth });
  await requestJson("/v1/creators/maya-hart", { headers: auth });
  await requestJson("/v1/collections/featured", { headers: auth });
  await postJson("/v1/viewer/library/save", { movie_id: "friendly", saved: true, state: "favorite" }, auth);
  await postJson("/v1/viewer/library/progress", { movie_id: "friendly", progress: 1, completed: true }, auth);

  const dashboard = await requestJson("/v1/analytics/dashboard", { headers: auth });
  assertJsonResponse(dashboard, 200);
  assert.equal(dashboard.json.aggregations.searches >= 1, true);
  assert.equal(dashboard.json.aggregations.favorites >= 1, true);
  assert.equal(dashboard.json.aggregations.discovery_events >= 4, true);
  assert.equal(dashboard.json.aggregations.discovery_sources.some((record) => record.id === "discovery_query"), true);
  assertNoCredentialMaterial(dashboard.json);
});

test("analytics: revenue and readiness metrics are exposed without payment data", async () => {
  const creatorAuth = await signIn("creator");
  const result = await postJson("/v1/analytics/events", {
    events: [
      {
        event_id: "evt-smoke-revenue-estimate",
        idempotency_key: "idem-smoke-revenue-estimate",
        event_name: "revenue_estimate",
        content_id: "friendly",
        creator_id: "maya-hart",
        source: "creator_dashboard",
        properties: { revenue_cents: 420, share_count: 2 }
      }
    ]
  }, creatorAuth);
  assertJsonResponse(result, 202);
  assert.equal(result.json.accepted_count, 1);

  const dashboard = await requestJson("/v1/analytics/dashboard", { headers: creatorAuth });
  assertJsonResponse(dashboard, 200);
  assert.equal(dashboard.json.aggregations.revenue_metrics.revenue_events >= 1, true);
  assert.equal(dashboard.json.aggregations.revenue_metrics.estimated_revenue_cents >= 420, true);

  const readiness = await requestJson("/ready");
  assertJsonResponse(readiness, 200);
  assert.equal(readiness.json.analytics_retention_metrics, true);
  assert.equal(readiness.json.analytics_watch_time_metrics, true);
  assert.equal(readiness.json.analytics_creator_title_metrics, true);
  assert.equal(readiness.json.analytics_discovery_source_attribution, true);
  assert.equal(readiness.json.analytics_revenue_metrics, true);
  assertNoCredentialMaterial(dashboard.json);
});

test("analytics: invalid event names are rejected without failing the whole batch", async () => {
  const result = await postJson("/v1/analytics/events", {
    events: [
      { event_id: "evt-smoke-save", event_name: "save", content_id: "friendly" },
      { event_id: "evt-smoke-invalid", event_name: "payment_card_seen", content_id: "friendly" }
    ]
  });
  assertJsonResponse(result, 202);
  assert.equal(result.json.accepted_count, 1);
  assert.equal(result.json.rejected_count, 1);
  assert.equal(result.json.errors[0].error, "analytics_event_not_allowed");
  assertNoCredentialMaterial(result.json);
});

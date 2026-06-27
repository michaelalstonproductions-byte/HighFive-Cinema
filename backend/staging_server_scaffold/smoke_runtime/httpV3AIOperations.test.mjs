import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    userID: result.json.session.user_id
  };
}

test("v3 AI operations: readiness exposes local operations intelligence capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_ai_operations_enabled, true);
  assert.equal(ready.json.v3_ai_operations_automated_moderation, true);
  assert.equal(ready.json.v3_ai_operations_quality_control, true);
  assert.equal(ready.json.v3_ai_operations_catalog_optimization, true);
  assert.equal(ready.json.v3_ai_operations_rights_validation, true);
  assert.equal(ready.json.v3_ai_operations_release_optimization, true);
  assert.equal(ready.json.v3_ai_operations_external_ai_calls, false);
  assert.ok(ready.json.v3_ai_operations_moderation_records >= 1);
  assert.ok(ready.json.v3_ai_operations_quality_records >= 1);
  assert.ok(ready.json.v3_ai_operations_optimization_records >= 1);
});

test("v3 AI operations: summary returns seeded moderation, quality, catalog, rights, and release records", async () => {
  const admin = await session("admin");
  const summary = await requestJson("/v3/ai-operations/summary", {
    headers: { authorization: admin.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.ai_operations, "local_v3_ai_operations");
  assert.equal(summary.json.external_ai_calls, false);
  assert.equal(summary.json.user_id, admin.userID);
  assert.ok(summary.json.moderation_recommendations.some((record) => record.id === "ai-operations-moderation-seed-1"));
  assert.ok(summary.json.quality_control.some((record) => record.id === "ai-operations-quality-seed-1"));
  assert.ok(summary.json.catalog_optimization.some((record) => record.id === "ai-operations-catalog-seed-1"));
  assert.ok(summary.json.rights_validation.some((record) => record.id === "ai-operations-rights-seed-1"));
  assert.ok(summary.json.release_optimization.some((record) => record.id === "ai-operations-release-seed-1"));
  assert.equal(summary.json.dashboard.deterministic_local_rules, true);
  assertNoCredentialMaterial(summary.json);
});

test("v3 AI operations: admin can create operations intelligence records", async () => {
  const admin = await session("admin");
  const headers = { authorization: admin.authorization };

  const moderation = await postJson("/v3/ai-operations/moderation", {
    content_id: "friendly",
    signal: "policy",
    priority: "high",
    recommendation: "Review title before global promotion.",
    status: "review"
  }, headers);
  assertJsonResponse(moderation, 201);
  assert.equal(moderation.json.moderation_recommendation.signal, "policy");

  const quality = await postJson("/v3/ai-operations/quality-control", {
    content_id: "friendly",
    quality_area: "subtitles",
    score: 64,
    recommendation: "Subtitle timing requires local review."
  }, headers);
  assertJsonResponse(quality, 201);
  assert.equal(quality.json.quality_control.blocking, true);

  const catalog = await postJson("/v3/ai-operations/catalog-optimization", {
    collection_id: "featured",
    recommendation_type: "creator_balance",
    priority: "medium",
    summary: "Increase creator balance across the featured rail.",
    expected_lift: 1.09
  }, headers);
  assertJsonResponse(catalog, 201);
  assert.equal(catalog.json.catalog_optimization.recommendation_type, "creator_balance");

  const rights = await postJson("/v3/ai-operations/rights-validation", {
    content_id: "friendly",
    territory: "FR",
    validation_state: "review",
    issue_count: 2,
    recommendation: "Review French window metadata."
  }, headers);
  assertJsonResponse(rights, 201);
  assert.equal(rights.json.rights_validation.validation_state, "review");

  const release = await postJson("/v3/ai-operations/release-optimization", {
    content_id: "friendly",
    release_window: "Saturday matinee window",
    optimization_type: "audience",
    confidence: 87,
    recommendation: "Target audience-affinity rail and creator profile entry."
  }, headers);
  assertJsonResponse(release, 201);
  assert.equal(release.json.release_optimization.optimization_type, "audience");

  const summary = await requestJson("/v3/ai-operations/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.moderation_recommendations.some((record) => record.id === moderation.json.moderation_recommendation.id));
  assert.ok(summary.json.quality_control.some((record) => record.id === quality.json.quality_control.id));
  assert.ok(summary.json.catalog_optimization.some((record) => record.id === catalog.json.catalog_optimization.id));
  assert.ok(summary.json.rights_validation.some((record) => record.id === rights.json.rights_validation.id));
  assert.ok(summary.json.release_optimization.some((record) => record.id === release.json.release_optimization.id));
});

test("v3 AI operations: creator cannot access admin operations intelligence", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/ai-operations/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "ai_operations_role_required");

  const moderation = await postJson("/v3/ai-operations/moderation", {
    content_id: "friendly"
  }, { authorization: creator.authorization });
  assertJsonResponse(moderation, 403);
  assert.equal(moderation.json.error, "ai_operations_role_required");
});

test("v3 AI operations: OpenAPI exposes operations intelligence paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/ai-operations/summary"]);
  assert.ok(spec.json.paths["/v3/ai-operations/moderation"]);
  assert.ok(spec.json.paths["/v3/ai-operations/quality-control"]);
  assert.ok(spec.json.paths["/v3/ai-operations/catalog-optimization"]);
  assert.ok(spec.json.paths["/v3/ai-operations/rights-validation"]);
  assert.ok(spec.json.paths["/v3/ai-operations/release-optimization"]);
});

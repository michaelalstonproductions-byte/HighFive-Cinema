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

test("enterprise studio: readiness exposes enterprise tools without external services", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.enterprise_studio_enabled, true);
  assert.equal(ready.json.enterprise_studio_analytics, true);
  assert.equal(ready.json.enterprise_studio_bulk_publishing, true);
  assert.equal(ready.json.enterprise_studio_rights_management_reporting, true);
  assert.equal(ready.json.enterprise_studio_distribution_reporting, true);
  assert.equal(ready.json.enterprise_studio_dashboards, true);
  assert.equal(ready.json.enterprise_studio_external_services, false);
});

test("enterprise studio: admin summary includes dashboard, analytics, rights, and distribution reports", async () => {
  const admin = await session("admin");
  const summary = await requestJson("/v2/enterprise-studio/summary", {
    headers: { authorization: admin.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.dashboard.studio_health, "ready");
  assert.ok(summary.json.analytics.total_titles > 0);
  assert.ok(summary.json.rights_report.total_windows > 0);
  assert.ok(summary.json.distribution_report.targets.length >= 4);
  assertNoCredentialMaterial(summary.json);
});

test("enterprise studio: creator can fetch studio analytics and reports", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const analytics = await requestJson("/v2/enterprise-studio/analytics", { headers });
  assertJsonResponse(analytics, 200);
  assert.equal(analytics.json.analytics.portfolio_score, 94);
  assert.ok(analytics.json.analytics.creator_performance.length > 0);

  const rights = await requestJson("/v2/enterprise-studio/rights-report", { headers });
  assertJsonResponse(rights, 200);
  assert.ok(rights.json.rights_report.territories.includes("US"));

  const distribution = await requestJson("/v2/enterprise-studio/distribution-report", { headers });
  assertJsonResponse(distribution, 200);
  assert.ok(distribution.json.distribution_report.ready_targets >= 1);
});

test("enterprise studio: bulk publishing validates requested titles and persists batch state", async () => {
  const admin = await session("admin");
  const headers = { authorization: admin.authorization };

  const batch = await postJson("/v2/enterprise-studio/bulk-publishing", {
    title_ids: ["friendly", "missing-enterprise-title"]
  }, headers);
  assertJsonResponse(batch, 201);
  assert.equal(batch.json.batch.status, "needs_review");
  assert.deepEqual(batch.json.validation.invalid_title_ids, ["missing-enterprise-title"]);

  const summary = await requestJson("/v2/enterprise-studio/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.bulk_publishing_batches.some((record) => record.id === batch.json.batch.id));
  assert.equal(summary.json.distribution_report.bulk_batch_count >= 1, true);
});

test("enterprise studio: viewer cannot access enterprise tools", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v2/enterprise-studio/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "enterprise_role_required");

  const batch = await postJson("/v2/enterprise-studio/bulk-publishing", {
    title_ids: ["friendly"]
  }, { authorization: viewer.authorization });
  assertJsonResponse(batch, 403);
  assert.equal(batch.json.error, "enterprise_role_required");
});

test("enterprise studio: OpenAPI exposes enterprise studio contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/enterprise-studio/summary"]);
  assert.ok(spec.json.paths["/v2/enterprise-studio/analytics"]);
  assert.ok(spec.json.paths["/v2/enterprise-studio/bulk-publishing"]);
  assert.ok(spec.json.paths["/v2/enterprise-studio/rights-report"]);
  assert.ok(spec.json.paths["/v2/enterprise-studio/distribution-report"]);
});

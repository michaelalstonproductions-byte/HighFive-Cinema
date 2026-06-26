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

test("performance scale: readiness exposes scale capabilities without external services", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.performance_scale_enabled, true);
  assert.equal(ready.json.performance_scale_large_catalog_pagination, true);
  assert.equal(ready.json.performance_scale_search_index_diagnostics, true);
  assert.equal(ready.json.performance_scale_catalog_cache_warming, true);
  assert.equal(ready.json.performance_scale_background_sync_tuning, true);
  assert.equal(ready.json.performance_scale_database_index_plan, true);
  assert.equal(ready.json.performance_scale_external_services, false);
});

test("performance scale: summary returns catalog, cache, and search diagnostics", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v2/performance-scale/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.catalog.base_titles > 0);
  assert.ok(summary.json.catalog.virtual_large_catalog_titles > summary.json.catalog.base_titles);
  assert.equal(summary.json.cache.policy, "local_memory_cache_with_rebuild_hooks");
  assert.ok(summary.json.search_index.indexed_documents > 0);
  assertNoCredentialMaterial(summary.json);
});

test("performance scale: cache warming records requested scopes", async () => {
  const admin = await session("admin");
  const warmed = await postJson("/v2/performance-scale/cache/warm", {
    scopes: ["catalog", "search", "collections", "series", "creators"]
  }, { authorization: admin.authorization });
  assertJsonResponse(warmed, 200);
  assert.equal(warmed.json.status, "warmed");
  assert.ok(warmed.json.cache.warmed_scopes.includes("catalog"));
  assert.ok(warmed.json.cache.warmed_scopes.includes("search"));
  assert.equal(warmed.json.cache.entry_count >= 5, true);
});

test("performance scale: virtual large catalog paginates deterministically", async () => {
  const viewer = await session("viewer");
  const page = await requestJson("/v2/performance-scale/catalog/large-page?page=2&page_size=5&multiplier=20", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(page, 200);
  assert.equal(page.json.page, 2);
  assert.equal(page.json.page_size, 5);
  assert.equal(page.json.items.length, 5);
  assert.equal(page.json.strategy, "virtualized_catalog_page");
  assert.ok(page.json.total_results > page.json.items.length);
  assert.equal(page.json.items[0].sort_key, 5);
});

test("performance scale: search index diagnostics report ranking fields and cache readiness", async () => {
  const creator = await session("creator");
  const report = await requestJson("/v2/performance-scale/search-index", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(report, 200);
  assert.ok(report.json.search_index.fields.includes("title"));
  assert.ok(report.json.search_index.fields.includes("creator"));
  assert.ok(report.json.search_index.title_tokens > 0);
});

test("performance scale: sync tuning records bounded background sync policy", async () => {
  const admin = await session("admin");
  const tuning = await postJson("/v2/performance-scale/sync-tuning", {
    batch_size: 250,
    stale_while_revalidate_seconds: 1200,
    background_refresh_interval_seconds: 2400,
    max_delta_pages: 12
  }, { authorization: admin.authorization });
  assertJsonResponse(tuning, 201);
  assert.equal(tuning.json.sync_tuning.batch_size, 250);
  assert.equal(tuning.json.effective_policy.cache_strategy, "stale_while_revalidate");
  assert.equal(tuning.json.effective_policy.offline_fallback, true);

  const summary = await requestJson("/v2/performance-scale/summary", {
    headers: { authorization: admin.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.sync_tuning.some((record) => record.id === tuning.json.sync_tuning.id));
});

test("performance scale: OpenAPI exposes performance scale contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/performance-scale/summary"]);
  assert.ok(spec.json.paths["/v2/performance-scale/cache/warm"]);
  assert.ok(spec.json.paths["/v2/performance-scale/catalog/large-page"]);
  assert.ok(spec.json.paths["/v2/performance-scale/search-index"]);
  assert.ok(spec.json.paths["/v2/performance-scale/sync-tuning"]);
});

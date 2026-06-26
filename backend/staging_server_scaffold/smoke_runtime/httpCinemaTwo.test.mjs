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

test("cinema 2.0: readiness exposes final release gates", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.cinema_two_enabled, true);
  assert.equal(ready.json.cinema_two_final_ui_polish, true);
  assert.equal(ready.json.cinema_two_performance_tuning, true);
  assert.equal(ready.json.cinema_two_accessibility_review, true);
  assert.equal(ready.json.cinema_two_animation_policy, true);
  assert.equal(ready.json.cinema_two_launch_marketing_assets, true);
  assert.equal(ready.json.cinema_two_external_services, false);
  assert.ok(ready.json.cinema_two_release_gates >= 5);
});

test("cinema 2.0: summary returns product surfaces and release-readiness reports", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v2/highfive-cinema-2/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.release_name, "HighFive Cinema 2.0");
  assert.ok(summary.json.product_surfaces.some((surface) => surface.id === "home"));
  assert.equal(summary.json.polish_audit.status, "passed");
  assert.equal(summary.json.accessibility.status, "ready");
  assert.equal(summary.json.performance.status, "ready");
  assert.equal(summary.json.animation.infinite_animation_allowed, false);
  assertNoCredentialMaterial(summary.json);
});

test("cinema 2.0: polish audit and accessibility report cover critical gates", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const polish = await requestJson("/v2/highfive-cinema-2/polish-audit", { headers });
  assertJsonResponse(polish, 200);
  assert.ok(polish.json.polish_audit.checks.some((check) => check.id === "consumer_navigation_locked" && check.status === "passed"));
  assert.ok(polish.json.polish_audit.checks.some((check) => check.id === "protected_rendering_systems" && check.status === "passed"));

  const accessibility = await requestJson("/v2/highfive-cinema-2/accessibility", { headers });
  assertJsonResponse(accessibility, 200);
  assert.ok(accessibility.json.accessibility.critical_identifiers.includes("hf.streaming.premium.home"));
  assert.ok(accessibility.json.accessibility.screenshot_routes.includes("player"));
});

test("cinema 2.0: marketing assets and release checklist are available", async () => {
  const admin = await session("admin");
  const headers = { authorization: admin.authorization };

  const assets = await requestJson("/v2/highfive-cinema-2/marketing-assets", { headers });
  assertJsonResponse(assets, 200);
  assert.equal(assets.json.marketing_assets.status, "ready");
  assert.equal(assets.json.marketing_assets.launch_listing, "docs/launch/LAUNCH_LISTING.md");
  assert.ok(assets.json.marketing_assets.screenshot_matrix.some((shot) => shot.surface === "creator"));

  const checklist = await requestJson("/v2/highfive-cinema-2/release-checklist", { headers });
  assertJsonResponse(checklist, 200);
  assert.equal(checklist.json.release_checklist.status, "manual_required");
  assert.ok(checklist.json.release_checklist.gates.some((gate) => gate.id === "backend_smoke" && gate.status === "passed"));
  assert.ok(checklist.json.release_checklist.gates.some((gate) => gate.id === "external_submission" && gate.status === "manual_required"));
});

test("cinema 2.0: OpenAPI exposes Cinema 2.0 readiness contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/highfive-cinema-2/summary"]);
  assert.ok(spec.json.paths["/v2/highfive-cinema-2/polish-audit"]);
  assert.ok(spec.json.paths["/v2/highfive-cinema-2/accessibility"]);
  assert.ok(spec.json.paths["/v2/highfive-cinema-2/marketing-assets"]);
  assert.ok(spec.json.paths["/v2/highfive-cinema-2/release-checklist"]);
});

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

test("v3 HighFive Enterprise: readiness exposes global creator, studio, AI streaming, and launch capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_highfive_enterprise_enabled, true);
  assert.equal(ready.json.v3_highfive_enterprise_global_creator_platform, true);
  assert.equal(ready.json.v3_highfive_enterprise_studio_platform, true);
  assert.equal(ready.json.v3_highfive_enterprise_ai_powered_streaming_platform, true);
  assert.equal(ready.json.v3_highfive_enterprise_launch_readiness, true);
  assert.equal(ready.json.v3_highfive_enterprise_external_ai_calls, false);
  assert.equal(ready.json.v3_highfive_enterprise_external_services, false);
  assert.ok(ready.json.v3_highfive_enterprise_global_creator_records >= 1);
  assert.ok(ready.json.v3_highfive_enterprise_studio_platform_records >= 1);
  assert.ok(ready.json.v3_highfive_enterprise_ai_streaming_records >= 1);
  assert.ok(ready.json.v3_highfive_enterprise_launch_readiness_records >= 1);
});

test("v3 HighFive Enterprise: summary returns seeded enterprise platform records", async () => {
  const admin = await session("admin");
  const summary = await requestJson("/v3/highfive-enterprise/summary", {
    headers: { authorization: admin.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.highfive_enterprise, "local_v3_highfive_enterprise");
  assert.equal(summary.json.user_id, admin.userID);
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.external_ai_calls, false);
  assert.ok(summary.json.global_creator_platform.some((record) => record.id === "highfive-enterprise-global-creator-seed-1"));
  assert.ok(summary.json.enterprise_studio_platform.some((record) => record.id === "highfive-enterprise-studio-platform-seed-1"));
  assert.ok(summary.json.ai_powered_streaming_platform.some((record) => record.id === "highfive-enterprise-ai-streaming-seed-1"));
  assert.ok(summary.json.launch_readiness.some((record) => record.id === "highfive-enterprise-launch-readiness-seed-creator"));
  assert.equal(summary.json.dashboard.deterministic_local_intelligence, true);
  assert.equal(summary.json.dashboard.external_ai_calls, false);
  assertNoCredentialMaterial(summary.json);
});

test("v3 HighFive Enterprise: admin can create enterprise platform records", async () => {
  const admin = await session("admin");
  const headers = { authorization: admin.authorization };

  const globalCreator = await postJson("/v3/highfive-enterprise/global-creator-platform", {
    creator_id: "maya-hart",
    title_count: 5,
    territories: ["US", "GB", "FR"],
    marketplace_channels: ["license_marketplace", "distribution_marketplace"],
    localization_state: "ready",
    distribution_state: "ready"
  }, headers);
  assertJsonResponse(globalCreator, 201);
  assert.equal(globalCreator.json.global_creator_platform.creator_id, "maya-hart");
  assert.equal(globalCreator.json.global_creator_platform.territories.length, 3);

  const studio = await postJson("/v3/highfive-enterprise/enterprise-studio-platform", {
    organization_id: "enterprise-organization-seed-1",
    organization_name: "HighFive Enterprise Studio",
    workspace_count: 6,
    departments: ["production", "post", "rights", "analytics"],
    shared_library_state: "ready",
    operations_state: "ready"
  }, headers);
  assertJsonResponse(studio, 201);
  assert.equal(studio.json.enterprise_studio_platform.permission_model, "role_based");
  assert.equal(studio.json.enterprise_studio_platform.workspace_count, 6);

  const streaming = await postJson("/v3/highfive-enterprise/ai-streaming-platform", {
    title_id: "friendly",
    personalization_state: "ready",
    search_state: "ready",
    operations_state: "ready",
    quality_score: 96
  }, headers);
  assertJsonResponse(streaming, 201);
  assert.equal(streaming.json.ai_powered_streaming_platform.external_ai_calls, false);
  assert.equal(streaming.json.ai_powered_streaming_platform.quality_score, 96);

  const launch = await postJson("/v3/highfive-enterprise/launch-readiness", {
    signal: "launch",
    gate: "Enterprise release cutover",
    state: "ready",
    score: 95,
    blocker_count: 0,
    recommendation: "Proceed with enterprise release review."
  }, headers);
  assertJsonResponse(launch, 201);
  assert.equal(launch.json.launch_readiness.signal, "launch");

  const summary = await requestJson("/v3/highfive-enterprise/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.global_creator_platform.some((record) => record.id === globalCreator.json.global_creator_platform.id));
  assert.ok(summary.json.enterprise_studio_platform.some((record) => record.id === studio.json.enterprise_studio_platform.id));
  assert.ok(summary.json.ai_powered_streaming_platform.some((record) => record.id === streaming.json.ai_powered_streaming_platform.id));
  assert.ok(summary.json.launch_readiness.some((record) => record.id === launch.json.launch_readiness.id));
});

test("v3 HighFive Enterprise: creator cannot access enterprise admin platform", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/highfive-enterprise/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "highfive_enterprise_admin_required");

  const platform = await postJson("/v3/highfive-enterprise/global-creator-platform", {
    creator_id: "maya-hart"
  }, { authorization: creator.authorization });
  assertJsonResponse(platform, 403);
  assert.equal(platform.json.error, "highfive_enterprise_admin_required");
});

test("v3 HighFive Enterprise: OpenAPI exposes enterprise paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/highfive-enterprise/summary"]);
  assert.ok(spec.json.paths["/v3/highfive-enterprise/global-creator-platform"]);
  assert.ok(spec.json.paths["/v3/highfive-enterprise/enterprise-studio-platform"]);
  assert.ok(spec.json.paths["/v3/highfive-enterprise/ai-streaming-platform"]);
  assert.ok(spec.json.paths["/v3/highfive-enterprise/launch-readiness"]);
});

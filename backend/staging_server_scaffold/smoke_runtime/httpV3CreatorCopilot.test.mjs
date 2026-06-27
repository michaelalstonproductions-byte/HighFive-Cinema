import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    creatorID: result.json.session.creator_id
  };
}

const projectContext = {
  project_id: "project-behind-the-vision",
  content_id: "behind-the-vision",
  creator_id: "maya-hart",
  title: "Behind the Vision: Studio Notes",
  description: "A creator-led documentary about building the opening night language of a film.",
  genre: "Documentary",
  tags: ["Creator", "Documentary", "Premiere"],
  runtime: "38m"
};

test("v3 creator copilot: readiness exposes local copilot capabilities without external calls", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_creator_copilot_enabled, true);
  assert.equal(ready.json.v3_creator_copilot_poster_generation, true);
  assert.equal(ready.json.v3_creator_copilot_metadata_writing, true);
  assert.equal(ready.json.v3_creator_copilot_trailer_suggestions, true);
  assert.equal(ready.json.v3_creator_copilot_publishing_recommendations, true);
  assert.equal(ready.json.v3_creator_copilot_audience_targeting, true);
  assert.equal(ready.json.v3_creator_copilot_release_timing, true);
  assert.equal(ready.json.v3_creator_copilot_external_ai_calls, false);
});

test("v3 creator copilot: summary combines metadata, poster, trailer, audience, release, and publishing", async () => {
  const creator = await session("creator");
  const summary = await postJson("/v3/creator-copilot/summary", projectContext, {
    authorization: creator.authorization
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.copilot, "local_v3_creator_copilot");
  assert.equal(summary.json.external_ai_calls, false);
  assert.equal(summary.json.context.content_id, "behind-the-vision");
  assert.ok(summary.json.generation_plan.quality_gates.length >= 3);
  assert.ok(summary.json.metadata_writing.logline.includes(projectContext.title));
  assert.ok(summary.json.poster_generation.generated_variants.length >= 3);
  assert.ok(summary.json.trailer_suggestions.structure.length >= 5);
  assert.ok(summary.json.audience_targeting.affinity_segments.includes("Documentary"));
  assert.ok(summary.json.release_timing.launch_beats.length >= 4);
  assert.ok(["prepare_review_submission", "continue_asset_review"].includes(summary.json.publishing_recommendations.recommendation));
  assertNoCredentialMaterial(summary.json);
});

test("v3 creator copilot: focused generation plan returns metadata poster and trailer briefs", async () => {
  const creator = await session("creator");
  const plan = await postJson("/v3/creator-copilot/generation-plan", projectContext, {
    authorization: creator.authorization
  });
  assertJsonResponse(plan, 200);
  assert.equal(plan.json.copilot, "local_v3_creator_copilot");
  assert.ok(plan.json.generation_plan.priority_order.includes("metadata"));
  assert.ok(plan.json.generation_plan.metadata_brief.tags.includes("Creator Published"));
  assert.ok(plan.json.generation_plan.poster_brief.layouts.length >= 3);
  assert.ok(plan.json.generation_plan.trailer_brief.structure.some((beat) => beat.beat === "Creator Stamp"));
});

test("v3 creator copilot: audience targeting uses local search and project signals", async () => {
  const creator = await session("creator");
  const audience = await postJson("/v3/creator-copilot/audience", projectContext, {
    authorization: creator.authorization
  });
  assertJsonResponse(audience, 200);
  assert.equal(audience.json.audience_targeting.primary_audience, "Documentary viewers");
  assert.ok(audience.json.audience_targeting.related_titles.length >= 1);
  assert.ok(audience.json.audience_targeting.channel_mix.some((channel) => channel.channel === "Creator Profile"));
});

test("v3 creator copilot: release timing and publishing endpoints produce actionable local plans", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const timing = await postJson("/v3/creator-copilot/release-timing", projectContext, headers);
  assertJsonResponse(timing, 200);
  assert.equal(timing.json.release_timing.recommended_window, "friday_evening_preview");
  assert.ok(timing.json.release_timing.launch_beats.some((beat) => beat.beat === "personalized_home_feature"));

  const publishing = await postJson("/v3/creator-copilot/publishing", projectContext, headers);
  assertJsonResponse(publishing, 200);
  assert.equal(typeof publishing.json.publishing_recommendations.readiness_score, "number");
  assert.ok(Array.isArray(publishing.json.publishing_recommendations.discovery_path));
  assert.ok(publishing.json.publishing_recommendations.copilot_note.includes("local"));
});

test("v3 creator copilot: viewer cannot access creator copilot", async () => {
  const viewer = await session("viewer");
  const summary = await postJson("/v3/creator-copilot/summary", projectContext, {
    authorization: viewer.authorization
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "creator_role_required");
});

test("v3 creator copilot: OpenAPI exposes V3 copilot paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/creator-copilot/summary"]);
  assert.ok(spec.json.paths["/v3/creator-copilot/generation-plan"]);
  assert.ok(spec.json.paths["/v3/creator-copilot/audience"]);
  assert.ok(spec.json.paths["/v3/creator-copilot/release-timing"]);
  assert.ok(spec.json.paths["/v3/creator-copilot/publishing"]);
});

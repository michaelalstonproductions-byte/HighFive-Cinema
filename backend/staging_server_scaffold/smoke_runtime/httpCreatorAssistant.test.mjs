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

test("creator assistant: readiness exposes local deterministic assistant capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.creator_assistant_enabled, true);
  assert.equal(ready.json.creator_assistant_external_calls, false);
  assert.equal(ready.json.creator_assistant_metadata_generation, true);
  assert.equal(ready.json.creator_assistant_poster_suggestions, true);
  assert.equal(ready.json.creator_assistant_trailer_suggestions, true);
  assert.equal(ready.json.creator_assistant_publishing_assistant, true);
  assert.equal(ready.json.creator_assistant_seo_assistant, true);
  assert.equal(ready.json.creator_assistant_rights_assistant, true);
  assert.equal(ready.json.creator_assistant_deterministic_local_rules, true);
});

test("creator assistant: summary returns every assistant surface without external calls", async () => {
  const creator = await session("creator");
  const summary = await postJson("/v2/creator-assistant/summary", projectContext, {
    authorization: creator.authorization
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.assistant, "local_creator_assistant_v1");
  assert.equal(summary.json.external_ai_calls, false);
  assert.equal(summary.json.context.content_id, "behind-the-vision");
  assert.equal(summary.json.metadata.genre, "Documentary");
  assert.ok(summary.json.poster.layouts.length >= 3);
  assert.ok(summary.json.trailer.structure.length >= 5);
  assert.ok(summary.json.publishing.checklist.length >= 5);
  assert.ok(summary.json.seo.keywords.includes("Creator"));
  assert.ok(Array.isArray(summary.json.rights.clearance_checks));
  assertNoCredentialMaterial(summary.json);
});

test("creator assistant: focused suggestion endpoints return expected structures", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const metadata = await postJson("/v2/creator-assistant/metadata", projectContext, headers);
  assertJsonResponse(metadata, 200);
  assert.equal(metadata.json.metadata.title, projectContext.title);
  assert.ok(metadata.json.metadata.logline.includes(projectContext.title));

  const poster = await postJson("/v2/creator-assistant/poster", projectContext, headers);
  assertJsonResponse(poster, 200);
  assert.equal(typeof poster.json.poster.concept, "string");
  assert.equal(typeof poster.json.poster.typography, "string");

  const trailer = await postJson("/v2/creator-assistant/trailer", projectContext, headers);
  assertJsonResponse(trailer, 200);
  assert.ok(trailer.json.trailer.structure.some((beat) => beat.beat === "Creator Stamp"));

  const publishing = await postJson("/v2/creator-assistant/publishing", projectContext, headers);
  assertJsonResponse(publishing, 200);
  assert.equal(typeof publishing.json.publishing.readiness_score, "number");
  assert.ok(["submit_for_review", "continue_draft"].includes(publishing.json.publishing.recommended_state));

  const seo = await postJson("/v2/creator-assistant/seo", projectContext, headers);
  assertJsonResponse(seo, 200);
  assert.equal(seo.json.seo.slug, "behind-the-vision-studio-notes");
  assert.ok(seo.json.seo.ranking_focus.includes("tags"));

  const rights = await postJson("/v2/creator-assistant/rights", projectContext, headers);
  assertJsonResponse(rights, 200);
  assert.ok(rights.json.rights.clearance_checks.some((item) => item.item === "Territory window"));
});

test("creator assistant: authenticated GET summary works with default creator context", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v2/creator-assistant/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.external_ai_calls, false);
  assert.equal(summary.json.context.creator_id, creator.creatorID);
});

test("creator assistant: viewer cannot access creator assistant", async () => {
  const viewer = await session("viewer");
  const metadata = await postJson("/v2/creator-assistant/metadata", projectContext, {
    authorization: viewer.authorization
  });
  assertJsonResponse(metadata, 403);
  assert.equal(metadata.json.error, "creator_role_required");
});

test("creator assistant: OpenAPI exposes the V2 assistant contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/creator-assistant/summary"]);
  assert.ok(spec.json.paths["/v2/creator-assistant/metadata"]);
  assert.ok(spec.json.paths["/v2/creator-assistant/rights"]);
});

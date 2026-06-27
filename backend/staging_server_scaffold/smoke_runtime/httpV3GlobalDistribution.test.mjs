import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    creatorID: result.json.session.creator_id,
    userID: result.json.session.user_id
  };
}

test("v3 global distribution: readiness exposes local distribution capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_global_distribution_enabled, true);
  assert.equal(ready.json.v3_global_distribution_localization, true);
  assert.equal(ready.json.v3_global_distribution_subtitles, true);
  assert.equal(ready.json.v3_global_distribution_regional_publishing, true);
  assert.equal(ready.json.v3_global_distribution_territories, true);
  assert.equal(ready.json.v3_global_distribution_languages, true);
  assert.equal(ready.json.v3_global_distribution_external_services, false);
  assert.ok(ready.json.v3_global_distribution_localization_records >= 1);
  assert.ok(ready.json.v3_global_distribution_subtitle_records >= 1);
  assert.ok(ready.json.v3_global_distribution_territory_records >= 1);
});

test("v3 global distribution: summary returns seeded localization, subtitles, regions, territories, and languages", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/global-distribution/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.global_distribution, "local_v3_global_distribution");
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.creator_id, creator.creatorID);
  assert.ok(summary.json.localization.some((record) => record.id === "global-localization-seed-1"));
  assert.ok(summary.json.subtitles.some((record) => record.id === "global-subtitle-seed-1"));
  assert.ok(summary.json.regional_publishing.some((record) => record.id === "global-regional-publishing-seed-1"));
  assert.ok(summary.json.territories.some((record) => record.id === "global-territory-seed-1"));
  assert.ok(summary.json.languages.some((record) => record.id === "global-language-seed-1"));
  assert.ok(summary.json.dashboard.ready_records >= 1);
  assertNoCredentialMaterial(summary.json);
});

test("v3 global distribution: creator can create localization, subtitle, regional publishing, territory, and language records", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const localization = await postJson("/v3/global-distribution/localization", {
    content_id: "friendly",
    locale: "fr-FR",
    title: "The Friendly France",
    synopsis_status: "ready",
    metadata_status: "review"
  }, headers);
  assertJsonResponse(localization, 201);
  assert.equal(localization.json.localization.locale, "fr-FR");

  const subtitle = await postJson("/v3/global-distribution/subtitles", {
    content_id: "friendly",
    language: "French",
    format: "srt",
    status: "ready",
    cue_count: 610
  }, headers);
  assertJsonResponse(subtitle, 201);
  assert.equal(subtitle.json.subtitle.format, "srt");

  const regional = await postJson("/v3/global-distribution/regional-publishing", {
    content_id: "friendly",
    region: "EMEA",
    release_window: "Autumn preview",
    status: "planned",
    collection_id: "featured"
  }, headers);
  assertJsonResponse(regional, 201);
  assert.equal(regional.json.regional_publishing.region, "EMEA");

  const territory = await postJson("/v3/global-distribution/territories", {
    territory: "FR",
    availability: "available",
    rights_state: "clear",
    title_ids: ["friendly"]
  }, headers);
  assertJsonResponse(territory, 201);
  assert.equal(territory.json.territory.territory, "FR");

  const language = await postJson("/v3/global-distribution/languages", {
    language: "French",
    locale: "fr-FR",
    dubbing_status: "review",
    subtitle_status: "ready",
    title_count: 1
  }, headers);
  assertJsonResponse(language, 201);
  assert.equal(language.json.language.locale, "fr-FR");

  const summary = await requestJson("/v3/global-distribution/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.localization.some((record) => record.id === localization.json.localization.id));
  assert.ok(summary.json.subtitles.some((record) => record.id === subtitle.json.subtitle.id));
  assert.ok(summary.json.regional_publishing.some((record) => record.id === regional.json.regional_publishing.id));
  assert.ok(summary.json.territories.some((record) => record.id === territory.json.territory.id));
  assert.ok(summary.json.languages.some((record) => record.id === language.json.language.id));
});

test("v3 global distribution: viewer cannot access global distribution operations", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v3/global-distribution/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "global_distribution_role_required");

  const localization = await postJson("/v3/global-distribution/localization", {
    title: "Viewer Localization"
  }, { authorization: viewer.authorization });
  assertJsonResponse(localization, 403);
  assert.equal(localization.json.error, "global_distribution_role_required");
});

test("v3 global distribution: OpenAPI exposes global distribution paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/global-distribution/summary"]);
  assert.ok(spec.json.paths["/v3/global-distribution/localization"]);
  assert.ok(spec.json.paths["/v3/global-distribution/subtitles"]);
  assert.ok(spec.json.paths["/v3/global-distribution/regional-publishing"]);
  assert.ok(spec.json.paths["/v3/global-distribution/territories"]);
  assert.ok(spec.json.paths["/v3/global-distribution/languages"]);
});

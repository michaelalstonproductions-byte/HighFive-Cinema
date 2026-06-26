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

test("device expansion: readiness exposes local device expansion capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.device_expansion_enabled, true);
  assert.equal(ready.json.device_expansion_apple_tv_profile, true);
  assert.equal(ready.json.device_expansion_ipad_profile, true);
  assert.equal(ready.json.device_expansion_mac_profile, true);
  assert.equal(ready.json.device_expansion_carplay_consideration, true);
  assert.equal(ready.json.device_expansion_airplay_session_planning, true);
  assert.equal(ready.json.device_expansion_handoff_records, true);
  assert.equal(ready.json.device_expansion_external_services, false);
  assert.equal(ready.json.device_expansion_profile_count, 5);
});

test("device expansion: summary returns supported and constrained device profiles", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v2/device-expansion/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.supported_profiles.some((profile) => profile.id === "apple_tv"));
  assert.ok(summary.json.supported_profiles.some((profile) => profile.id === "ipad"));
  assert.ok(summary.json.supported_profiles.some((profile) => profile.id === "mac"));
  assert.ok(summary.json.constrained_profiles.some((profile) => profile.id === "carplay"));
  assertNoCredentialMaterial(summary.json);
});

test("device expansion: profile detail exposes layout recommendations by platform", async () => {
  const viewer = await session("viewer");
  const appleTV = await requestJson("/v2/device-expansion/profiles/apple_tv", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(appleTV, 200);
  assert.equal(appleTV.json.profile.layout_mode, "ten_foot_tv");
  assert.equal(appleTV.json.recommendations.use_safe_title_area, true);

  const iPad = await requestJson("/v2/device-expansion/profiles/ipad", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(iPad, 200);
  assert.equal(iPad.json.profile.layout_mode, "expanded_tablet");
  assert.equal(iPad.json.recommendations.prefer_split_detail, true);
});

test("device expansion: AirPlay and handoff records persist in local summary", async () => {
  const viewer = await session("viewer");
  const headers = { authorization: viewer.authorization };

  const airplay = await postJson("/v2/device-expansion/airplay/sessions", {
    movie_id: "friendly",
    source_platform: "iphone",
    target_name: "Screening Room",
    playback_position_seconds: 125
  }, headers);
  assertJsonResponse(airplay, 201);
  assert.equal(airplay.json.airplay_session.state, "ready");
  assert.equal(airplay.json.airplay_session.target_name, "Screening Room");

  const handoff = await postJson("/v2/device-expansion/handoff", {
    movie_id: "friendly",
    from_platform: "iphone",
    to_platform: "ipad",
    context: "continue_watching",
    playback_position_seconds: 125
  }, headers);
  assertJsonResponse(handoff, 201);
  assert.equal(handoff.json.handoff.from_platform, "iphone");
  assert.equal(handoff.json.handoff.to_platform, "ipad");

  const summary = await requestJson("/v2/device-expansion/summary", {
    headers
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.airplay_sessions.some((record) => record.id === airplay.json.airplay_session.id));
  assert.ok(summary.json.handoffs.some((record) => record.id === handoff.json.handoff.id));
});

test("device expansion: constrained CarPlay profile rejects unsupported video handoff and AirPlay planning", async () => {
  const viewer = await session("viewer");
  const headers = { authorization: viewer.authorization };

  const airplay = await postJson("/v2/device-expansion/airplay/sessions", {
    movie_id: "friendly",
    source_platform: "carplay",
    target_name: "Dashboard"
  }, headers);
  assertJsonResponse(airplay, 400);
  assert.equal(airplay.json.error, "airplay_not_supported");

  const handoff = await postJson("/v2/device-expansion/handoff", {
    movie_id: "friendly",
    from_platform: "iphone",
    to_platform: "carplay"
  }, headers);
  assertJsonResponse(handoff, 400);
  assert.equal(handoff.json.error, "handoff_not_supported");
});

test("device expansion: OpenAPI exposes the V2 device expansion contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/device-expansion/summary"]);
  assert.ok(spec.json.paths["/v2/device-expansion/profiles"]);
  assert.ok(spec.json.paths["/v2/device-expansion/profiles/{id}"]);
  assert.ok(spec.json.paths["/v2/device-expansion/airplay/sessions"]);
  assert.ok(spec.json.paths["/v2/device-expansion/handoff"]);
});

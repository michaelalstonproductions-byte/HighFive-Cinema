import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    userID: result.json.session.user_id,
    creatorID: result.json.session.creator_id
  };
}

test("live premieres: readiness exposes local premiere capabilities without external services", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.live_premieres_enabled, true);
  assert.equal(ready.json.live_premiere_countdowns, true);
  assert.equal(ready.json.live_premiere_rooms, true);
  assert.equal(ready.json.live_premiere_creator_introductions, true);
  assert.equal(ready.json.live_premiere_qa, true);
  assert.equal(ready.json.live_premiere_chat, true);
  assert.equal(ready.json.live_premiere_replay, true);
  assert.equal(ready.json.live_premiere_transport, "local_http_contract");
  assert.equal(ready.json.live_premiere_external_services, false);
  assert.ok(ready.json.live_premiere_events >= 1);
});

test("live premieres: authenticated summary returns seeded premiere, room, and intro", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v2/live-premieres/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.events.some((event) => event.id === "live-premiere-opening-night"));
  assert.ok(summary.json.rooms.some((room) => room.id === "live-premiere-room-opening-night"));
  assert.ok(summary.json.introductions.some((intro) => intro.id === "live-premiere-intro-opening-night"));
  assertNoCredentialMaterial(summary.json);
});

test("live premieres: creator can run event room, countdown, intro, Q&A, and replay workflow", async () => {
  const creator = await session("creator");
  const creatorHeaders = { authorization: creator.authorization };

  const created = await postJson("/v2/live-premieres/events", {
    movie_id: "friendly",
    title: "The Friendly Creator Premiere",
    countdown_seconds: 900,
    max_capacity: 1200
  }, creatorHeaders);
  assertJsonResponse(created, 201);
  assert.equal(created.json.status, "created");
  assert.equal(created.json.event.state, "scheduled");
  const eventID = created.json.event.id;

  const room = await postJson(`/v2/live-premieres/events/${eventID}/room`, {
    state: "open",
    participant_user_ids: ["local-viewer"]
  }, creatorHeaders);
  assertJsonResponse(room, 200);
  assert.equal(room.json.room.state, "open");
  assert.equal(room.json.event.state, "premiere");

  const countdown = await postJson(`/v2/live-premieres/events/${eventID}/countdown`, {
    countdown_seconds: 60
  }, creatorHeaders);
  assertJsonResponse(countdown, 200);
  assert.equal(countdown.json.event.state, "countdown");
  assert.equal(countdown.json.event.countdown_seconds, 60);

  const intro = await postJson(`/v2/live-premieres/events/${eventID}/intro`, {
    title: "Creator Welcome",
    message: "Welcome to the local premiere room.",
    duration_seconds: 75
  }, creatorHeaders);
  assertJsonResponse(intro, 201);
  assert.equal(intro.json.introduction.title, "Creator Welcome");

  const viewer = await session("viewer");
  const viewerHeaders = { authorization: viewer.authorization };
  const chat = await postJson(`/v2/live-premieres/events/${eventID}/chat`, {
    message: "The room is ready.",
    playback_position_seconds: 12
  }, viewerHeaders);
  assertJsonResponse(chat, 201);
  assert.equal(chat.json.message.message, "The room is ready.");

  const question = await postJson(`/v2/live-premieres/events/${eventID}/qa`, {
    question: "What inspired this opening sequence?"
  }, viewerHeaders);
  assertJsonResponse(question, 201);
  assert.equal(question.json.question.status, "open");

  const answer = await postJson(`/v2/live-premieres/events/${eventID}/qa/${question.json.question.id}/answer`, {
    answer: "We built it around the first night audience reaction."
  }, creatorHeaders);
  assertJsonResponse(answer, 200);
  assert.equal(answer.json.question.status, "answered");

  const replay = await postJson(`/v2/live-premieres/events/${eventID}/replay`, {
    title: "The Friendly Premiere Replay",
    replay_position_seconds: 0
  }, creatorHeaders);
  assertJsonResponse(replay, 201);
  assert.equal(replay.json.event.state, "replay");
  assert.equal(replay.json.replay.available, true);

  const summary = await requestJson("/v2/live-premieres/summary", {
    headers: creatorHeaders
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.events.some((event) => event.id === eventID && event.state === "replay"));
  assert.ok(summary.json.chat_messages.some((message) => message.id === chat.json.message.id));
  assert.ok(summary.json.qa.some((item) => item.id === question.json.question.id && item.status === "answered"));
  assert.ok(summary.json.replays.some((item) => item.id === replay.json.replay.id));
  assertNoCredentialMaterial(summary.json);
});

test("live premieres: viewer cannot create or host-manage premiere events", async () => {
  const viewer = await session("viewer");
  const create = await postJson("/v2/live-premieres/events", {
    movie_id: "friendly",
    title: "Viewer Hosted Premiere"
  }, { authorization: viewer.authorization });
  assertJsonResponse(create, 403);
  assert.equal(create.json.error, "creator_role_required");

  const countdown = await postJson("/v2/live-premieres/events/live-premiere-opening-night/countdown", {
    countdown_seconds: 10
  }, { authorization: viewer.authorization });
  assertJsonResponse(countdown, 403);
  assert.equal(countdown.json.error, "creator_role_required");
});

test("live premieres: OpenAPI exposes the V2 live premiere contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/live-premieres/summary"]);
  assert.ok(spec.json.paths["/v2/live-premieres/events"]);
  assert.ok(spec.json.paths["/v2/live-premieres/events/{id}/room"]);
  assert.ok(spec.json.paths["/v2/live-premieres/events/{id}/countdown"]);
  assert.ok(spec.json.paths["/v2/live-premieres/events/{id}/chat"]);
  assert.ok(spec.json.paths["/v2/live-premieres/events/{id}/qa/{questionID}/answer"]);
  assert.ok(spec.json.paths["/v2/live-premieres/events/{id}/replay"]);
});

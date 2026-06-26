import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role = "viewer") {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    userID: result.json.session.user_id
  };
}

test("social watch: readiness exposes local social viewing contracts without socket transport", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.social_watch_enabled, true);
  assert.equal(ready.json.social_watch_parties_enabled, true);
  assert.equal(ready.json.social_watch_invites_enabled, true);
  assert.equal(ready.json.social_watch_friends_enabled, true);
  assert.equal(ready.json.social_watch_shared_libraries_enabled, true);
  assert.equal(ready.json.social_watch_synchronized_playback_enabled, true);
  assert.equal(ready.json.social_watch_voice_rooms_enabled, true);
  assert.equal(ready.json.social_watch_comments_enabled, true);
  assert.equal(ready.json.social_watch_reactions_enabled, true);
  assert.equal(ready.json.social_watch_transport, "local_http_contract");
});

test("social watch: authenticated users can create friends and shared libraries", async () => {
  const viewer = await session("viewer");
  const friend = await postJson("/v2/social-watch/friends", {
    friend_user_id: "local-viewer-friend",
    display_name: "HighFive Friend"
  }, { authorization: viewer.authorization });
  assertJsonResponse(friend, 201);
  assert.equal(friend.json.friend.user_id, viewer.userID);
  assert.equal(friend.json.friend.friend_user_id, "local-viewer-friend");

  const shared = await postJson("/v2/social-watch/shared-library", {
    shared_with_user_id: "local-viewer-friend",
    movie_ids: ["friendly", "paranormall-s1"]
  }, { authorization: viewer.authorization });
  assertJsonResponse(shared, 201);
  assert.equal(shared.json.shared_library.owner_user_id, viewer.userID);
  assert.deepEqual(shared.json.shared_library.movie_ids, ["friendly", "paranormall-s1"]);
  assertNoCredentialMaterial(shared.json);
});

test("social watch: watch party flow records invite, playback sync, reaction, comment, and voice room", async () => {
  const viewer = await session("viewer");
  const party = await postJson("/v2/social-watch/parties", {
    movie_id: "friendly",
    title: "The Friendly Friday Room",
    invited_user_ids: ["local-viewer-friend"]
  }, { authorization: viewer.authorization });
  assertJsonResponse(party, 201);
  assert.equal(party.json.watch_party.host_user_id, viewer.userID);
  assert.equal(party.json.watch_party.movie_id, "friendly");
  assert.equal(party.json.watch_party.state, "active");
  assert.ok(party.json.invites.length >= 1);
  assert.equal(party.json.voice_room.state, "open");

  const partyID = party.json.watch_party.id;
  const invite = await postJson(`/v2/social-watch/parties/${partyID}/invite`, {
    to_user_id: viewer.userID
  }, { authorization: viewer.authorization });
  assertJsonResponse(invite, 201);

  const response = await postJson(`/v2/social-watch/invites/${invite.json.invite.id}/respond`, {
    status: "accepted"
  }, { authorization: viewer.authorization });
  assertJsonResponse(response, 200);
  assert.equal(response.json.invite.status, "accepted");
  assert.ok(response.json.watch_party.participant_user_ids.includes(viewer.userID));

  const playback = await postJson(`/v2/social-watch/parties/${partyID}/playback`, {
    playback_position_seconds: 512,
    playback_state: "playing"
  }, { authorization: viewer.authorization });
  assertJsonResponse(playback, 200);
  assert.equal(playback.json.watch_party.playback_position_seconds, 512);
  assert.equal(playback.json.watch_party.playback_state, "playing");

  const reaction = await postJson(`/v2/social-watch/parties/${partyID}/reactions`, {
    emoji: "spark",
    label: "Big moment",
    playback_position_seconds: 518
  }, { authorization: viewer.authorization });
  assertJsonResponse(reaction, 201);
  assert.equal(reaction.json.reaction.party_id, partyID);
  assert.equal(reaction.json.reaction.label, "Big moment");

  const comment = await postJson(`/v2/social-watch/parties/${partyID}/comments`, {
    message: "That reveal still works.",
    playback_position_seconds: 540
  }, { authorization: viewer.authorization });
  assertJsonResponse(comment, 201);
  assert.equal(comment.json.comment.message, "That reveal still works.");

  const voice = await postJson(`/v2/social-watch/parties/${partyID}/voice-room`, {
    state: "muted",
    active_speaker_user_id: viewer.userID
  }, { authorization: viewer.authorization });
  assertJsonResponse(voice, 200);
  assert.equal(voice.json.voice_room.state, "muted");
  assert.equal(voice.json.voice_room.active_speaker_user_id, viewer.userID);

  const summary = await requestJson("/v2/social-watch/summary", { headers: { authorization: viewer.authorization } });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.watch_parties.some((item) => item.id === partyID));
  assert.ok(summary.json.reactions.some((item) => item.party_id === partyID));
  assert.ok(summary.json.comments.some((item) => item.party_id === partyID));
  assert.ok(summary.json.voice_rooms.some((item) => item.party_id === partyID));
  assertNoCredentialMaterial(summary.json);
});

test("social watch: summary requires an authenticated identity session", async () => {
  const summary = await requestJson("/v2/social-watch/summary");
  assertJsonResponse(summary, 401);
  assert.equal(summary.json.error, "identity_session_required");
});

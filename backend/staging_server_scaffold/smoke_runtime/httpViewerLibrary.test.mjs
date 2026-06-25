import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, postJson, requestJson } from "./testHelpers.mjs";

async function viewerSession() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  return signIn.json.session.session_id;
}

async function creatorSession() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  return signIn.json.session.session_id;
}

function auth(sessionID) {
  return { authorization: `HighFiveSession ${sessionID}` };
}

test("viewer library: snapshot, save, progress, and offline state persist for session", async () => {
  const sessionID = await viewerSession();
  const initial = await requestJson("/v1/viewer/library", { headers: auth(sessionID) });
  assertJsonResponse(initial, 200);
  assert.equal(initial.json.status, "ready");
  assert.ok(initial.json.saved_titles.length >= 1);

  const save = await postJson("/v1/viewer/library/save", {
    movie_id: "behind-the-vision",
    saved: true,
    state: "favorite"
  }, auth(sessionID));
  assertJsonResponse(save, 200);
  assert.equal(save.json.status, "saved");
  assert.ok(save.json.snapshot.favorites.some((record) => record.movie_id === "behind-the-vision"));

  const progress = await postJson("/v1/viewer/library/progress", {
    movie_id: "friendly",
    progress: 0.64,
    completed: false
  }, auth(sessionID));
  assertJsonResponse(progress, 200);
  assert.equal(progress.json.status, "progress_saved");
  assert.ok(progress.json.snapshot.continue_watching.some((record) => record.movie_id === "friendly"));
  assert.ok(progress.json.snapshot.recommendations.length >= 0);

  const offline = await postJson("/v1/viewer/library/offline", {
    movie_id: "friendly",
    state: "downloaded",
    bytes: 32112640
  }, auth(sessionID));
  assertJsonResponse(offline, 200);
  assert.equal(offline.json.status, "offline_state_saved");
  assert.equal(offline.json.record.state, "downloaded");
  assert.equal(offline.json.record.storage_state, "available");

  const finalSnapshot = await requestJson("/v1/viewer/library", { headers: auth(sessionID) });
  assertJsonResponse(finalSnapshot, 200);
  assert.ok(finalSnapshot.json.offline_records.some((record) => record.movie_id === "friendly"));
});

test("viewer library: creator session cannot mutate viewer library", async () => {
  const sessionID = await creatorSession();
  const result = await postJson("/v1/viewer/library/progress", {
    movie_id: "friendly",
    progress: 0.2
  }, auth(sessionID));
  assert.equal(result.status, 403);
  assert.equal(result.json.error, "viewer_role_required");
});

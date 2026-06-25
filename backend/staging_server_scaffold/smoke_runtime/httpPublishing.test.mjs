import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

const draftPayload = {
  title: "Smoke Draft Premiere",
  description: "A local creator draft used by the publishing persistence smoke test.",
  creator: "Maya Hart",
  genre: "Documentary",
  tags: ["Creator", "Smoke"],
  runtime: "44m",
  poster_status: "ready",
  trailer_status: "ready",
  metadata_status: "ready",
  artwork_status: "ready"
};

test("publishing: creator can create, update, conflict, archive, and restore a draft", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  const auth = { authorization: `HighFiveSession ${signIn.json.session.session_id}` };

  const created = await postJson("/v1/creator/drafts", draftPayload, auth);
  assertJsonResponse(created, 201);
  assert.equal(created.json.status, "created");
  assert.equal(created.json.draft.version, 1);
  assert.equal(created.json.draft.release_state, "draft");
  assertNoCredentialMaterial(created.json);

  const draftID = created.json.draft.id;
  const updated = await requestJson(`/v1/creator/drafts/${draftID}`, {
    method: "PATCH",
    headers: {
      "content-type": "application/json",
      ...auth
    },
    body: JSON.stringify({
      ...draftPayload,
      title: "Smoke Draft Premiere Revised",
      base_version: 1
    })
  });
  assertJsonResponse(updated, 200);
  assert.equal(updated.json.status, "updated");
  assert.equal(updated.json.draft.version, 2);

  const conflict = await requestJson(`/v1/creator/drafts/${draftID}`, {
    method: "PATCH",
    headers: {
      "content-type": "application/json",
      ...auth
    },
    body: JSON.stringify({
      ...draftPayload,
      title: "Stale Smoke Draft",
      base_version: 1
    })
  });
  assertJsonResponse(conflict, 409);
  assert.equal(conflict.json.error, "draft_version_conflict");

  const archived = await postJson(`/v1/creator/drafts/${draftID}/archive`, { base_version: 2 }, auth);
  assertJsonResponse(archived, 200);
  assert.equal(archived.json.draft.release_state, "archived");
  assert.equal(archived.json.draft.version, 3);

  const restored = await postJson(`/v1/creator/drafts/${draftID}/restore`, { base_version: 3 }, auth);
  assertJsonResponse(restored, 200);
  assert.equal(restored.json.draft.release_state, "draft");
  assert.equal(restored.json.draft.version, 4);

  const revisions = await requestJson(`/v1/creator/drafts/${draftID}/revisions`, { headers: auth });
  assertJsonResponse(revisions, 200);
  assert.equal(revisions.json.revisions.length >= 4, true);

  const queue = await requestJson("/v1/creator/draft-sync/queue", { headers: auth });
  assertJsonResponse(queue, 200);
  assert.equal(queue.json.queued_edits.some((record) => record.action === "restore"), true);
  assertNoCredentialMaterial(queue.json);
});

test("publishing: creator can list seeded and created drafts", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  const auth = { authorization: `HighFiveSession ${signIn.json.session.session_id}` };

  const result = await requestJson("/v1/creator/drafts", { headers: auth });
  assertJsonResponse(result, 200);
  assert.equal(result.json.drafts.some((draft) => draft.id === "project-behind-the-vision"), true);
  assert.equal(result.json.revision_count >= 1, true);
  assertNoCredentialMaterial(result.json);
});

test("publishing: viewer cannot mutate creator drafts", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  const result = await postJson("/v1/creator/drafts", draftPayload, { authorization: `HighFiveSession ${signIn.json.session.session_id}` });
  assertJsonResponse(result, 403);
  assert.equal(result.json.error, "creator_role_required");
});

test("publishing: server validation rejects incomplete drafts", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  const result = await postJson("/v1/creator/drafts", {
    ...draftPayload,
    description: "Too short"
  }, { authorization: `HighFiveSession ${signIn.json.session.session_id}` });
  assertJsonResponse(result, 422);
  assert.equal(result.json.error, "draft_validation_failed");
});

import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

const readyDraft = {
  title: "Review Smoke Premiere",
  description: "A creator project used to verify governed review and publishing visibility.",
  creator: "Maya Hart",
  genre: "Documentary",
  tags: ["Review", "Premiere"],
  runtime: "42m",
  poster_status: "ready",
  trailer_status: "ready",
  metadata_status: "ready",
  artwork_status: "ready"
};

test("publishing review: creator submit, admin approve/publish, and catalog visibility work", async () => {
  const creatorSignIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(creatorSignIn, 200);
  const creatorAuth = { authorization: `HighFiveSession ${creatorSignIn.json.session.session_id}` };

  const created = await postJson("/v1/creator/drafts", readyDraft, creatorAuth);
  assertJsonResponse(created, 201);
  const draftID = created.json.draft.id;
  const contentID = created.json.draft.content_id;

  const beforeCatalog = await requestJson(`/v1/content/${contentID}`);
  assertJsonResponse(beforeCatalog, 404);

  const submitted = await postJson(`/v1/creator/drafts/${draftID}/submit`, {
    base_version: created.json.draft.version,
    creator_note: "Ready for admin review."
  }, creatorAuth);
  assertJsonResponse(submitted, 200);
  assert.equal(submitted.json.status, "submitted_for_review");
  assert.equal(submitted.json.draft.release_state, "review");
  assert.equal(submitted.json.review.catalog_visible, false);

  const adminSignIn = await postJson("/v1/identity/dev/sign-in", { role: "admin" });
  assertJsonResponse(adminSignIn, 200);
  const adminAuth = { authorization: `HighFiveSession ${adminSignIn.json.session.session_id}` };

  const queue = await requestJson("/v1/admin/review/queue", { headers: adminAuth });
  assertJsonResponse(queue, 200);
  assert.equal(queue.json.review_queue.some((record) => record.project_id === draftID && record.status === "pending_review"), true);

  const approved = await postJson(`/v1/admin/review/${draftID}/approve`, { admin_note: "Approved for release." }, adminAuth);
  assertJsonResponse(approved, 200);
  assert.equal(approved.json.status, "approved");
  assert.equal(approved.json.catalog_visibility, "private");

  const published = await postJson(`/v1/admin/review/${draftID}/publish`, { admin_note: "Publishing to public catalog." }, adminAuth);
  assertJsonResponse(published, 200);
  assert.equal(published.json.status, "published");
  assert.equal(published.json.catalog_visibility, "visible");

  const afterCatalog = await requestJson(`/v1/content/${contentID}`);
  assertJsonResponse(afterCatalog, 200);
  assert.equal(afterCatalog.json.id, contentID);

  const discovery = await requestJson("/v1/discovery/query?kind=creator-published");
  assertJsonResponse(discovery, 200);
  assert.equal(discovery.json.creator_published_titles.some((title) => title.id === contentID), true);

  const audit = await requestJson("/v1/admin/review/audit", { headers: adminAuth });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.audit_records.some((record) => record.action === "published" && record.project_id === draftID), true);
  assertNoCredentialMaterial(audit.json);
});

test("publishing review: admin can request revisions and creator can withdraw", async () => {
  const creatorSignIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(creatorSignIn, 200);
  const creatorAuth = { authorization: `HighFiveSession ${creatorSignIn.json.session.session_id}` };
  const adminSignIn = await postJson("/v1/identity/dev/sign-in", { role: "admin" });
  assertJsonResponse(adminSignIn, 200);
  const adminAuth = { authorization: `HighFiveSession ${adminSignIn.json.session.session_id}` };

  const created = await postJson("/v1/creator/drafts", { ...readyDraft, title: "Revision Smoke Premiere" }, creatorAuth);
  assertJsonResponse(created, 201);
  const draftID = created.json.draft.id;

  const submitted = await postJson(`/v1/creator/drafts/${draftID}/submit`, { base_version: created.json.draft.version }, creatorAuth);
  assertJsonResponse(submitted, 200);

  const revision = await postJson(`/v1/admin/review/${draftID}/request-revision`, { admin_note: "Tighten synopsis and trailer notes." }, adminAuth);
  assertJsonResponse(revision, 200);
  assert.equal(revision.json.review.status, "needs_revision");
  assert.equal(revision.json.draft.release_state, "review");

  const withdrawn = await postJson(`/v1/creator/drafts/${draftID}/withdraw`, { base_version: revision.json.draft.version }, creatorAuth);
  assertJsonResponse(withdrawn, 200);
  assert.equal(withdrawn.json.draft.release_state, "draft");
  assert.equal(withdrawn.json.catalog_visibility, "private");
});

test("publishing review: admin can schedule, publish, unpublish, and archive with catalog rollback", async () => {
  const creatorSignIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(creatorSignIn, 200);
  const creatorAuth = { authorization: `HighFiveSession ${creatorSignIn.json.session.session_id}` };
  const adminSignIn = await postJson("/v1/identity/dev/sign-in", { role: "admin" });
  assertJsonResponse(adminSignIn, 200);
  const adminAuth = { authorization: `HighFiveSession ${adminSignIn.json.session.session_id}` };

  const created = await postJson("/v1/creator/drafts", { ...readyDraft, title: "Rollback Smoke Premiere" }, creatorAuth);
  assertJsonResponse(created, 201);
  const draftID = created.json.draft.id;
  const contentID = created.json.draft.content_id;

  const submitted = await postJson(`/v1/creator/drafts/${draftID}/submit`, { base_version: created.json.draft.version }, creatorAuth);
  assertJsonResponse(submitted, 200);

  const scheduledFor = new Date(Date.now() + 90 * 60 * 1000).toISOString();
  const scheduled = await postJson(`/v1/admin/review/${draftID}/schedule`, {
    admin_note: "Scheduled for release window.",
    scheduled_for: scheduledFor
  }, adminAuth);
  assertJsonResponse(scheduled, 200);
  assert.equal(scheduled.json.status, "scheduled");
  assert.equal(scheduled.json.review.scheduled_for, scheduledFor);
  assert.equal(scheduled.json.catalog_visibility, "private");

  const published = await postJson(`/v1/admin/review/${draftID}/publish`, { admin_note: "Publishing scheduled title." }, adminAuth);
  assertJsonResponse(published, 200);
  assert.equal(published.json.catalog_visibility, "visible");
  const visible = await requestJson(`/v1/content/${contentID}`);
  assertJsonResponse(visible, 200);

  const unpublished = await postJson(`/v1/admin/review/${draftID}/unpublish`, { admin_note: "Rollback after release." }, adminAuth);
  assertJsonResponse(unpublished, 200);
  assert.equal(unpublished.json.status, "unpublished");
  assert.equal(unpublished.json.catalog_visibility, "private");
  const hidden = await requestJson(`/v1/content/${contentID}`);
  assertJsonResponse(hidden, 404);

  const archived = await postJson(`/v1/admin/review/${draftID}/archive`, { admin_note: "Archived after rollback." }, adminAuth);
  assertJsonResponse(archived, 200);
  assert.equal(archived.json.status, "archived");
  assert.equal(archived.json.draft.release_state, "archived");

  const audit = await requestJson("/v1/admin/review/audit", { headers: adminAuth });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.audit_records.some((record) => record.action === "scheduled" && record.project_id === draftID), true);
  assert.equal(audit.json.audit_records.some((record) => record.action === "unpublished" && record.project_id === draftID), true);
  assert.equal(audit.json.audit_records.some((record) => record.action === "archived" && record.project_id === draftID), true);
});

test("publishing review: readiness advertises governed publishing operations", async () => {
  const readiness = await requestJson("/ready");
  assertJsonResponse(readiness, 200);
  assert.equal(readiness.json.publishing_submit_for_review, true);
  assert.equal(readiness.json.publishing_withdraw_submission, true);
  assert.equal(readiness.json.publishing_request_revision, true);
  assert.equal(readiness.json.publishing_approve, true);
  assert.equal(readiness.json.publishing_reject, true);
  assert.equal(readiness.json.publishing_schedule, true);
  assert.equal(readiness.json.publishing_publish, true);
  assert.equal(readiness.json.publishing_unpublish, true);
  assert.equal(readiness.json.publishing_archive_reviewed_project, true);
  assert.equal(readiness.json.publishing_processing_gate, true);
  assert.equal(readiness.json.publishing_rights_gate, true);
});

test("publishing review: viewer cannot submit or administer review", async () => {
  const viewerSignIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(viewerSignIn, 200);
  const viewerAuth = { authorization: `HighFiveSession ${viewerSignIn.json.session.session_id}` };

  const submit = await postJson("/v1/creator/drafts/project-behind-the-vision/submit", { base_version: 1 }, viewerAuth);
  assertJsonResponse(submit, 403);
  assert.equal(submit.json.error, "creator_role_required");

  const queue = await requestJson("/v1/admin/review/queue", { headers: viewerAuth });
  assertJsonResponse(queue, 403);
  assert.equal(queue.json.error, "admin_role_required");
});

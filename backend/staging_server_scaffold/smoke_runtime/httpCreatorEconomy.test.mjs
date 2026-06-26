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

test("creator economy: readiness exposes creator business contracts without external processor calls", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.creator_economy_enabled, true);
  assert.equal(ready.json.creator_payouts_enabled, true);
  assert.equal(ready.json.creator_dashboard_enabled, true);
  assert.equal(ready.json.creator_revenue_sharing_enabled, true);
  assert.equal(ready.json.creator_tips_enabled, true);
  assert.equal(ready.json.creator_memberships_enabled, true);
  assert.equal(ready.json.creator_paid_collections_enabled, true);
  assert.equal(ready.json.creator_paid_premieres_enabled, true);
  assert.equal(ready.json.creator_economy_external_processor_calls, false);
  assert.ok(ready.json.creator_economy_ledger_records >= 1);
});

test("creator economy: creator dashboard summarizes revenue, packages, memberships, and payout preview", async () => {
  const creator = await session("creator");
  const dashboard = await requestJson("/v2/creator-economy/dashboard", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(dashboard, 200);
  assert.equal(dashboard.json.creator.id, creator.creatorID);
  assert.ok(dashboard.json.summary.gross_revenue_cents > 0);
  assert.ok(dashboard.json.creator_dashboard.titles >= 1);
  assert.ok(Array.isArray(dashboard.json.revenue_sources));
  assert.ok(Array.isArray(dashboard.json.top_titles));
  assertNoCredentialMaterial(dashboard.json);
});

test("creator economy: viewer can tip and join creator membership, then creator sees ledger impact", async () => {
  const viewer = await session("viewer");
  const creator = await session("creator");

  const tip = await postJson("/v2/creator-economy/tips", {
    creator_id: creator.creatorID,
    content_id: "friendly",
    amount_cents: 650
  }, { authorization: viewer.authorization });
  assertJsonResponse(tip, 201);
  assert.equal(tip.json.tip.creator_id, creator.creatorID);
  assert.equal(tip.json.tip.source, "tip");
  assert.equal(tip.json.tip.status, "available");

  const membership = await postJson("/v2/creator-economy/memberships", {
    creator_id: creator.creatorID,
    tier_id: "studio-insider",
    amount_cents: 999
  }, { authorization: viewer.authorization });
  assertJsonResponse(membership, 201);
  assert.equal(membership.json.membership.creator_id, creator.creatorID);
  assert.equal(membership.json.membership.state, "active");
  assert.equal(membership.json.ledger_record.source, "membership");

  const dashboard = await requestJson("/v2/creator-economy/dashboard", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(dashboard, 200);
  assert.ok(dashboard.json.revenue_sources.some((item) => item.source === "tip" && item.records >= 1));
  assert.ok(dashboard.json.revenue_sources.some((item) => item.source === "membership" && item.records >= 1));
  assert.ok(dashboard.json.memberships.some((item) => item.tier_id === "studio-insider"));
});

test("creator economy: creator can configure revenue share and create paid collection and premiere packages", async () => {
  const creator = await session("creator");
  const share = await postJson("/v2/creator-economy/revenue-shares", {
    content_id: "friendly",
    creator_share_percent: 82
  }, { authorization: creator.authorization });
  assertJsonResponse(share, 200);
  assert.equal(share.json.revenue_share.creator_share_percent, 82);
  assert.equal(share.json.revenue_share.platform_share_percent, 18);

  const paidCollection = await postJson("/v2/creator-economy/paid-collections", {
    title: "Maya Hart Premiere Set",
    movie_ids: ["friendly", "behind-the-vision"],
    price_cents: 1499,
    state: "available"
  }, { authorization: creator.authorization });
  assertJsonResponse(paidCollection, 201);
  assert.equal(paidCollection.json.paid_collection.creator_id, creator.creatorID);
  assert.equal(paidCollection.json.paid_collection.movie_ids.length, 2);

  const paidPremiere = await postJson("/v2/creator-economy/paid-premieres", {
    movie_id: "friendly",
    title: "The Friendly Opening Weekend",
    price_cents: 799,
    window_label: "Opening weekend",
    state: "scheduled"
  }, { authorization: creator.authorization });
  assertJsonResponse(paidPremiere, 201);
  assert.equal(paidPremiere.json.paid_premiere.creator_id, creator.creatorID);
  assert.equal(paidPremiere.json.paid_premiere.movie_id, "friendly");

  const dashboard = await requestJson("/v2/creator-economy/dashboard", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(dashboard, 200);
  assert.ok(dashboard.json.paid_collections.some((item) => item.title === "Maya Hart Premiere Set"));
  assert.ok(dashboard.json.paid_premieres.some((item) => item.title === "The Friendly Opening Weekend"));
});

test("creator economy: creator can queue payout preview without external transfer", async () => {
  const creator = await session("creator");
  const payout = await postJson("/v2/creator-economy/payouts", {
    amount_cents: 500
  }, { authorization: creator.authorization });
  assertJsonResponse(payout, 201);
  assert.equal(payout.json.status, "queued");
  assert.equal(payout.json.payout.status, "queued");
  assert.equal(payout.json.payout_processing, "preview_only_no_external_transfer");

  const payouts = await requestJson("/v2/creator-economy/payouts", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(payouts, 200);
  assert.ok(payouts.json.payouts.some((item) => item.id === payout.json.payout.id));
});

test("creator economy: viewer cannot access creator dashboard or payout preview", async () => {
  const viewer = await session("viewer");
  const dashboard = await requestJson("/v2/creator-economy/dashboard", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(dashboard, 403);
  assert.equal(dashboard.json.error, "creator_role_required");

  const payout = await postJson("/v2/creator-economy/payouts", {
    amount_cents: 500
  }, { authorization: viewer.authorization });
  assertJsonResponse(payout, 403);
  assert.equal(payout.json.error, "creator_role_required");
});

import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, friendlyRequest, postJson, requestJson } from "./testHelpers.mjs";

async function developmentSession(role = "viewer") {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return result.json.session.session_id;
}

function auth(sessionID) {
  return { authorization: `HighFiveSession ${sessionID}` };
}

function transactionID(label) {
  return `smoke-${label}-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

test("monetization: products and readiness expose StoreKit contracts", async () => {
  const products = await requestJson("/v1/monetization/products");
  assertJsonResponse(products, 200);
  assert.equal(products.json.storekit2_contract, true);
  assert.equal(products.json.app_store_server_api_contract, true);
  assert.equal(products.json.direct_card_collection, false);
  assert.ok(products.json.products.some((product) => product.product_id === "com.highfive.pass.monthly"));

  const readiness = await requestJson("/ready");
  assertJsonResponse(readiness, 200);
  assert.equal(readiness.json.storekit2_products, true);
  assert.equal(readiness.json.backend_entitlement_records, true);
  assert.equal(readiness.json.storekit_transaction_updates, true);
  assert.equal(readiness.json.storekit_expiration_supported, true);
  assert.equal(readiness.json.storekit_grace_period_supported, true);
  assert.equal(readiness.json.storekit_billing_retry_supported, true);
  assert.equal(readiness.json.storekit_family_sharing_supported, true);
  assert.equal(readiness.json.subscription_management_link, true);
  assert.equal(readiness.json.playback_entitlement_checks, true);
  assert.equal(readiness.json.download_entitlement_checks, true);
  assert.equal(readiness.json.payments_enabled, true);
});

test("monetization: transaction grants entitlement and restore returns active record", async () => {
  const sessionID = await developmentSession("viewer");
  const transaction = await postJson("/v1/monetization/transactions", {
    product_id: "com.highfive.movie.thefriendly",
    transaction_id: transactionID("transaction-friendly-1"),
    original_transaction_id: transactionID("original-friendly-1"),
    environment: "sandbox",
    purchase_date: new Date().toISOString(),
    expiration_date: null,
    app_account_token: "smoke-app-account-token"
  }, auth(sessionID));
  assertJsonResponse(transaction, 201);
  assert.equal(transaction.json.entitlement.status, "active");

  const entitlements = await requestJson("/v1/monetization/entitlements", { headers: auth(sessionID) });
  assertJsonResponse(entitlements, 200);
  assert.ok(entitlements.json.active_entitlements.some((record) => record.product_id === "com.highfive.movie.thefriendly"));

  const restore = await postJson("/v1/monetization/restore", {}, auth(sessionID));
  assertJsonResponse(restore, 200);
  assert.equal(restore.json.status, "restored");
  assert.ok(restore.json.restored_entitlements.some((record) => record.product_id === "com.highfive.movie.thefriendly"));
});

test("monetization: backend entitlement record approves existing validation path", async () => {
  const sessionID = await developmentSession("viewer");
  await postJson("/v1/monetization/transactions", {
    product_id: "com.highfive.movie.thefriendly",
    transaction_id: transactionID("transaction-friendly-2"),
    original_transaction_id: transactionID("original-friendly-2"),
    environment: "sandbox"
  }, auth(sessionID));

  const validation = await postJson("/entitlements/validate", friendlyRequest({ user_id: "local-viewer" }), {
    "x-highfive-smoke-entitlement-mode": "denied"
  });
  assertJsonResponse(validation, 200);
  assert.equal(validation.json.entitlement_status, "entitlement_approved");
  assert.equal(validation.json.denial_reason, null);
});

test("monetization: subscription grace period remains access-granting with lifecycle metadata", async () => {
  const sessionID = await developmentSession("viewer");
  const now = Date.now();
  const transaction = await postJson("/v1/monetization/transactions", {
    product_id: "com.highfive.pass.annual",
    transaction_id: transactionID("transaction-pass-grace"),
    original_transaction_id: transactionID("original-pass-grace"),
    environment: "sandbox",
    purchase_date: new Date(now - 31 * 24 * 60 * 60 * 1000).toISOString(),
    expiration_date: new Date(now - 60 * 60 * 1000).toISOString(),
    grace_period_expires_at: new Date(now + 2 * 24 * 60 * 60 * 1000).toISOString(),
    billing_retry: true,
    family_shared: true
  }, auth(sessionID));
  assertJsonResponse(transaction, 201);
  assert.equal(transaction.json.entitlement.status, "grace_period");
  assert.equal(transaction.json.entitlement.billing_retry, true);
  assert.equal(transaction.json.entitlement.family_shared, true);
  assert.equal(transaction.json.subscription_management_link, "app-store-subscription-management");

  const validation = await postJson("/entitlements/validate", friendlyRequest({ user_id: "local-viewer" }), {
    "x-highfive-smoke-entitlement-mode": "denied"
  });
  assertJsonResponse(validation, 200);
  assert.equal(validation.json.entitlement_status, "entitlement_approved");
});

test("monetization: expired subscription does not restore active access", async () => {
  const sessionID = await developmentSession("viewer");
  const now = Date.now();
  const transaction = await postJson("/v1/monetization/transactions", {
    product_id: "com.highfive.pass.monthly",
    transaction_id: transactionID("transaction-pass-expired"),
    original_transaction_id: transactionID("original-pass-expired"),
    environment: "sandbox",
    purchase_date: new Date(now - 60 * 24 * 60 * 60 * 1000).toISOString(),
    expiration_date: new Date(now - 30 * 24 * 60 * 60 * 1000).toISOString()
  }, auth(sessionID));
  assertJsonResponse(transaction, 201);
  assert.equal(transaction.json.entitlement.status, "expired");

  const restore = await postJson("/v1/monetization/restore", {}, auth(sessionID));
  assertJsonResponse(restore, 200);
  assert.equal(restore.json.restored_entitlements.some((record) => record.product_id === "com.highfive.pass.monthly"), false);
});

test("monetization: revocation removes entitlement access", async () => {
  const sessionID = await developmentSession("viewer");
  await postJson("/v1/monetization/transactions", {
    product_id: "com.highfive.movie.thefriendly",
    transaction_id: transactionID("transaction-friendly-3"),
    original_transaction_id: transactionID("original-friendly-3"),
    environment: "sandbox"
  }, auth(sessionID));
  const revoked = await postJson("/v1/monetization/revoke", { product_id: "com.highfive.movie.thefriendly" }, auth(sessionID));
  assertJsonResponse(revoked, 200);
  assert.equal(revoked.json.status, "revoked");

  const entitlements = await requestJson("/v1/monetization/entitlements", { headers: auth(sessionID) });
  assertJsonResponse(entitlements, 200);
  assert.equal(entitlements.json.active_entitlements.some((record) => record.product_id === "com.highfive.movie.thefriendly"), false);
});

test("monetization: authenticated audit trail is available", async () => {
  const sessionID = await developmentSession("viewer");
  await postJson("/v1/monetization/transactions", {
    product_id: "com.highfive.pass.monthly",
    transaction_id: transactionID("transaction-pass-1"),
    original_transaction_id: transactionID("original-pass-1"),
    environment: "sandbox"
  }, auth(sessionID));
  const audit = await requestJson("/v1/monetization/audit", { headers: auth(sessionID) });
  assertJsonResponse(audit, 200);
  assert.ok(audit.json.events.length >= 1);
});

import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function signIn(role = "creator") {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

test("notifications: device registration, preferences, inbox, and read state work", async () => {
  const auth = await signIn("creator");
  const device = await postJson("/v1/notifications/devices", {
    device_token: "simulator-notification-token-1234567890",
    platform: "ios",
    environment: "simulator"
  }, auth);
  assertJsonResponse(device, 201);
  assert.equal(device.json.status, "device_registered");
  assert.match(device.json.device.device_token_suffix, /567890$/);
  assertNoCredentialMaterial(device.json);

  const preferences = await requestJson("/v1/notifications/preferences", { headers: auth });
  assertJsonResponse(preferences, 200);
  assert.equal(preferences.json.preferences.length >= 6, true);

  const updated = await requestJson("/v1/notifications/preferences", {
    method: "PATCH",
    headers: { "content-type": "application/json", ...auth },
    body: JSON.stringify({ category: "revenue", push_enabled: false, inbox_enabled: true })
  });
  assertJsonResponse(updated, 200);
  assert.equal(updated.json.preferences.some((item) => item.category === "revenue" && item.push_enabled === false), true);

  const pushed = await postJson("/v1/notifications/test-push", {
    category: "publishing",
    title: "Publishing review update",
    body: "Your project moved through review.",
    deep_link: "highfive://creator/publishing"
  }, auth);
  assertJsonResponse(pushed, 202);
  assert.equal(pushed.json.status, "development_delivered");
  assert.match(pushed.json.notification.deep_link, /^highfive:\/\//);
  assertNoCredentialMaterial(pushed.json);

  const inbox = await requestJson("/v1/notifications/inbox", { headers: auth });
  assertJsonResponse(inbox, 200);
  assert.equal(inbox.json.notifications.length >= 1, true);
  assert.equal(inbox.json.unread_count >= 1, true);

  const firstID = inbox.json.notifications[0].id;
  const read = await postJson(`/v1/notifications/${firstID}/read`, {}, auth);
  assertJsonResponse(read, 200);
  assert.equal(read.json.status, "read");
  assert.equal(read.json.notification.is_read, true);
});

test("notifications: delivery audit records the development APNs contract", async () => {
  const auth = await signIn("viewer");
  await postJson("/v1/notifications/devices", {
    device_token: "viewer-simulator-notification-token-abcdef",
    environment: "simulator"
  }, auth);
  await postJson("/v1/notifications/test-push", {
    category: "episode",
    title: "New episode available",
    body: "Continue the series.",
    deep_link: "highfive://series/next"
  }, auth);

  const audit = await requestJson("/v1/notifications/delivery-audit", { headers: auth });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.delivery_audit.some((record) => record.delivery_status === "development_delivered"), true);
  assert.equal(audit.json.delivery_audit.some((record) => record.provider === "apns_contract"), true);
  assertNoCredentialMaterial(audit.json);
});

test("notifications: readiness exposes production notification contracts", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);
  assert.equal(result.json.notifications_enabled, true);
  assert.equal(result.json.apns_contract_ready, true);
  assert.equal(result.json.notification_device_registration, true);
  assert.equal(result.json.notification_delivery_audit, true);
  assert.equal(result.json.external_push_attempted, false);
});

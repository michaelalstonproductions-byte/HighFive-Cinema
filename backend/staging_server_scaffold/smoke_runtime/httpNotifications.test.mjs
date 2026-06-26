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
  assert.equal(preferences.json.preferences.length >= 10, true);
  assert.equal(preferences.json.preferences.some((item) => item.category === "creator"), true);
  assert.equal(preferences.json.preferences.some((item) => item.category === "series"), true);

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

test("notifications: creator, series, and system events populate inbox and deep links", async () => {
  const auth = await signIn("creator");
  await postJson("/v1/notifications/devices", {
    device_token: "creator-series-system-notification-token-abcdef",
    environment: "simulator"
  }, auth);

  const events = [
    ["creator", "Creator workspace update", "A project collaborator changed readiness.", "highfive://creator/workspace"],
    ["series", "Series activity update", "A new episode path is ready.", "highfive://series"],
    ["system", "HighFive system notice", "Notification center fallback is available.", "highfive://notifications/system"]
  ];

  for (const [category, title, body, deep_link] of events) {
    const result = await postJson("/v1/notifications/test-push", { category, title, body, deep_link }, auth);
    assertJsonResponse(result, 202);
    assert.equal(result.json.notification.category, category);
    assert.equal(result.json.notification.deep_link, deep_link);
  }

  const inbox = await requestJson("/v1/notifications/inbox", { headers: auth });
  assertJsonResponse(inbox, 200);
  for (const [category] of events) {
    assert.equal(inbox.json.notifications.some((item) => item.category === category), true);
  }
  assertNoCredentialMaterial(inbox.json);
});

test("notifications: disabled push still delivers in-app fallback and audit", async () => {
  const auth = await signIn("creator");
  await postJson("/v1/notifications/devices", {
    device_token: "creator-disabled-push-token-abcdef",
    environment: "simulator"
  }, auth);
  const updated = await requestJson("/v1/notifications/preferences", {
    method: "PATCH",
    headers: { "content-type": "application/json", ...auth },
    body: JSON.stringify({ category: "creator", push_enabled: false, inbox_enabled: true })
  });
  assertJsonResponse(updated, 200);

  const pushed = await postJson("/v1/notifications/test-push", {
    category: "creator",
    title: "Creator update",
    body: "Push disabled fallback should remain in the inbox.",
    deep_link: "highfive://creator/workspace"
  }, auth);
  assertJsonResponse(pushed, 202);
  assert.equal(pushed.json.status, "push_disabled");
  assert.equal(pushed.json.notification.delivery_status, "push_disabled");

  const inbox = await requestJson("/v1/notifications/inbox", { headers: auth });
  assertJsonResponse(inbox, 200);
  assert.equal(inbox.json.notifications.some((item) => item.category === "creator" && item.delivery_status === "push_disabled"), true);

  const audit = await requestJson("/v1/notifications/delivery-audit", { headers: auth });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.delivery_audit.some((record) => record.delivery_status === "push_disabled"), true);
  assertNoCredentialMaterial(audit.json);
});

test("notifications: readiness exposes production notification contracts", async () => {
  const result = await requestJson("/ready");
  assertJsonResponse(result, 200);
  assert.equal(result.json.notifications_enabled, true);
  assert.equal(result.json.apns_contract_ready, true);
  assert.equal(result.json.notification_push_contract, true);
  assert.equal(result.json.notification_device_registration, true);
  assert.equal(result.json.notification_in_app_inbox, true);
  assert.equal(result.json.notification_delivery_audit, true);
  assert.equal(result.json.notification_read_state, true);
  assert.equal(result.json.notification_publishing_events, true);
  assert.equal(result.json.notification_creator_events, true);
  assert.equal(result.json.notification_series_events, true);
  assert.equal(result.json.notification_system_events, true);
  assert.equal(result.json.notification_permission_denied_fallback, true);
  assert.equal(result.json.notification_creator_category, true);
  assert.equal(result.json.notification_series_category, true);
  assert.equal(result.json.notification_category_count >= 10, true);
  assert.equal(result.json.external_push_attempted, false);
});

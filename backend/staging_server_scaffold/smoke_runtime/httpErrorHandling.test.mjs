import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, postMalformedJson, requestJson } from "./testHelpers.mjs";

test("error handling http: unknown path returns 404 JSON", async () => {
  const result = await requestJson("/missing");
  assertJsonResponse(result, 404);
  assert.equal(result.json.error, "route_not_found");
});

test("error handling http: malformed JSON returns client error for entitlement", async () => {
  const result = await postMalformedJson("/entitlements/validate");
  assertJsonResponse(result, 400);
  assert.equal(result.json.error, "malformed_json");
});

test("error handling http: malformed JSON returns client error for playback descriptor", async () => {
  const result = await postMalformedJson("/playback/descriptor");
  assertJsonResponse(result, 400);
  assert.equal(result.json.error, "malformed_json");
});

test("error handling http: unsupported content type returns client error", async () => {
  const result = await requestJson("/entitlements/validate", {
    method: "POST",
    headers: {
      "content-type": "text/plain"
    },
    body: "{}"
  });
  assertJsonResponse(result, 415);
  assert.equal(result.json.error, "unsupported_content_type");
});

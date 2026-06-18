import assert from "node:assert/strict";
import test from "node:test";
import { baseUrl, localhostHttpPrefix, loopbackHttpPrefix, outDir, readTextFile, requestJson } from "./testHelpers.mjs";

test("security http: server binds only to loopback", () => {
  assert.ok(baseUrl.startsWith(loopbackHttpPrefix) || baseUrl.startsWith(localhostHttpPrefix));
});

test("security http: no external request is attempted", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_EXTERNAL_NETWORK_REQUESTS, "false");
});

test("security http: no package install is attempted", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_PACKAGE_INSTALL, "false");
});

test("security http: no deployment is attempted", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_DEPLOYMENT, "false");
});

test("security http: no real .env file is read", () => {
  assert.equal(process.env.HIGHFIVE_HTTP_SMOKE_ENV_FILE_READ, "false");
});

test("security http: no credentials are required", async () => {
  const result = await requestJson("/health");
  assert.equal(result.json.credentials_required, false);
});

test("security http: server log contains no request body or response body", () => {
  const log = readTextFile(`${outDir}/server.log`);
  assert.doesNotMatch(log, /"movie_id"/);
  assert.doesNotMatch(log, /"entitlement_status"/);
  assert.doesNotMatch(log, /"playback_descriptor_status"/);
});

test("security http: descriptor reference is not logged", () => {
  const log = readTextFile(`${outDir}/server.log`);
  assert.doesNotMatch(log, /playback_url_or_token_reference/i);
  assert.doesNotMatch(log, /MOCK_DESCRIPTOR_REFERENCE/);
});

test("security http: Local Preview fallback policy remains documented", () => {
  const doc = readTextFile("docs/production_services/HIGHFIVE_STAGING_BACKEND_HTTP_DEPLOYMENT_TARGET_SMOKE_TEST.md");
  assert.match(doc, /Local Preview fallback remains available/);
});

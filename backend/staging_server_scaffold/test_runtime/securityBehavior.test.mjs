import assert from "node:assert/strict";
import test from "node:test";
import {
  assertNoConcreteUrl,
  assertNoCredentialMaterial,
  baseEntitlementRequest,
  compiledModule,
  guardSummary,
  playbackRequestFromEntitlement
} from "./testHelpers.mjs";

const { validateEntitlement } = await import(compiledModule("entitlements/validateEntitlement.js"));
const { requestPlaybackDescriptor } = await import(compiledModule("playback/requestPlaybackDescriptor.js"));
const { MockEntitlementProvider } = await import(compiledModule("mocks/mockEntitlementProvider.js"));
const { MockCloudflareSigner } = await import(compiledModule("mocks/mockCloudflareSigner.js"));
const { listAuditRecords, resetAuditRecordsForContractTests } = await import(compiledModule("audit.js"));

const secretEnvNames = [
  "HIGHFIVE_CLOUDFLARE_ACCOUNT_ID",
  "HIGHFIVE_CLOUDFLARE_STREAM_API_TOKEN",
  "HIGHFIVE_CLOUDFLARE_WEBHOOK_SECRET",
  "HIGHFIVE_APP_STORE_PRIVATE_KEY",
  "HIGHFIVE_REVENUECAT_SECRET_KEY",
  "HIGHFIVE_DATABASE_URL"
];

async function readyDescriptor() {
  const entitlement = await validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("approved"));
  return requestPlaybackDescriptor(playbackRequestFromEntitlement(entitlement), new MockCloudflareSigner("ready"));
}

test("security behavior: no fetch/HTTP/HTTPS/WebSocket/network calls", () => {
  assert.equal(guardSummary().network_requests_performed, false);
});

test("security behavior: no real .env reads", () => {
  assert.equal(guardSummary().env_reads_attempted, false);
});

test("security behavior: no credentials required", async () => {
  resetAuditRecordsForContractTests();
  const originalValues = new Map(secretEnvNames.map((name) => [name, process.env[name]]));
  try {
    for (const name of secretEnvNames) {
      delete process.env[name];
    }
    const descriptor = await readyDescriptor();
    assert.equal(descriptor.playback_descriptor_status, "descriptor_ready");
  } finally {
    for (const [name, value] of originalValues) {
      if (value === undefined) {
        delete process.env[name];
      } else {
        process.env[name] = value;
      }
    }
  }
});

test("security behavior: descriptor references are not logged", async () => {
  resetAuditRecordsForContractTests();
  const descriptor = await readyDescriptor();
  assert.equal(descriptor.playback_descriptor_status, "descriptor_ready");
  assert.equal(guardSummary().sensitive_log_violations, 0);
});

test("security behavior: descriptor references are not persisted", async () => {
  resetAuditRecordsForContractTests();
  const descriptor = await readyDescriptor();
  assert.equal(descriptor.playback_descriptor_status, "descriptor_ready");
  const auditRecords = listAuditRecords();
  assert.ok(auditRecords.length > 0);
  for (const record of auditRecords) {
    assert.doesNotMatch(JSON.stringify(record), /MOCK_DESCRIPTOR_REFERENCE/);
    assert.doesNotMatch(JSON.stringify(record), /playback_url_or_token_reference/i);
  }
});

test("security behavior: descriptor contains no concrete URL", async () => {
  resetAuditRecordsForContractTests();
  const descriptor = await readyDescriptor();
  assertNoConcreteUrl(descriptor);
});

test("security behavior: descriptor contains no token or private key", async () => {
  resetAuditRecordsForContractTests();
  const descriptor = await readyDescriptor();
  assertNoCredentialMaterial(descriptor);
});

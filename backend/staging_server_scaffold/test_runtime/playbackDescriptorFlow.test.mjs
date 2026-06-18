import assert from "node:assert/strict";
import test from "node:test";
import {
  assertIsoDate,
  assertNoConcreteUrl,
  assertNoCredentialMaterial,
  assertShortLived,
  baseEntitlementRequest,
  compiledModule,
  playbackRequestFromEntitlement
} from "./testHelpers.mjs";

const { validateEntitlement } = await import(compiledModule("entitlements/validateEntitlement.js"));
const { requestPlaybackDescriptor } = await import(compiledModule("playback/requestPlaybackDescriptor.js"));
const { MockEntitlementProvider } = await import(compiledModule("mocks/mockEntitlementProvider.js"));
const { MockCloudflareSigner } = await import(compiledModule("mocks/mockCloudflareSigner.js"));
const { resetAuditRecordsForContractTests } = await import(compiledModule("audit.js"));

async function approvedEntitlement() {
  return validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("approved"));
}

test("playback descriptor flow: denial prevents descriptor issuance", async () => {
  resetAuditRecordsForContractTests();
  const denied = await validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("denied"));
  let signerCalls = 0;
  const readySigner = {
    async createDescriptorReference() {
      signerCalls += 1;
      return {
        playback_url_or_token_reference: "<MOCK_DESCRIPTOR_REFERENCE:friendly>",
        expires_at: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
        refresh_after: new Date(Date.now() + 8 * 60 * 1000).toISOString()
      };
    }
  };
  const descriptor = await requestPlaybackDescriptor(playbackRequestFromEntitlement(denied), readySigner);
  assert.equal(signerCalls, 0);
  assert.equal(descriptor.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(descriptor.playback_url_or_token_reference, null);
  assert.equal(descriptor.denial_reason, "entitlement_audit_not_approved");
});

test("playback descriptor flow: approved audit context required", async () => {
  resetAuditRecordsForContractTests();
  let signerCalls = 0;
  const descriptor = await requestPlaybackDescriptor(
    { ...baseEntitlementRequest(), audit_id: "audit-friendly-999" },
    {
      async createDescriptorReference() {
        signerCalls += 1;
        return {
          playback_url_or_token_reference: "<MOCK_DESCRIPTOR_REFERENCE:friendly>",
          expires_at: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
          refresh_after: new Date(Date.now() + 8 * 60 * 1000).toISOString()
        };
      }
    }
  );
  assert.equal(signerCalls, 0);
  assert.equal(descriptor.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(descriptor.denial_reason, "entitlement_audit_not_approved");
});

test("playback descriptor flow: unavailable signer returns descriptor_unavailable", async () => {
  resetAuditRecordsForContractTests();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("unavailable")
  );
  assert.equal(descriptor.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(descriptor.playback_url_or_token_reference, null);
  assert.equal(descriptor.denial_reason, "descriptor_signer_unavailable");
});

test("playback descriptor flow: ready signer returns descriptor_ready", async () => {
  resetAuditRecordsForContractTests();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("ready")
  );
  assert.equal(descriptor.playback_descriptor_status, "descriptor_ready");
  assert.equal(descriptor.denial_reason, null);
  assert.equal(descriptor.audit_id, entitlement.audit_id);
});

test("playback descriptor flow: ready result includes expires_at", async () => {
  resetAuditRecordsForContractTests();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("ready")
  );
  assertIsoDate(descriptor.expires_at, "descriptor_ready must include expires_at");
});

test("playback descriptor flow: ready result includes refresh_after", async () => {
  resetAuditRecordsForContractTests();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("ready")
  );
  assertIsoDate(descriptor.refresh_after, "descriptor_ready must include refresh_after");
  assert.ok(Date.parse(descriptor.refresh_after) < Date.parse(descriptor.expires_at));
});

test("playback descriptor flow: descriptor reference is placeholder/mock only", async () => {
  resetAuditRecordsForContractTests();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("ready")
  );
  assert.equal(descriptor.playback_url_or_token_reference, "<MOCK_DESCRIPTOR_REFERENCE:friendly>");
  assertNoConcreteUrl(descriptor);
});

test("playback descriptor flow: descriptor response contains no provider credentials", async () => {
  resetAuditRecordsForContractTests();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("ready")
  );
  assertNoCredentialMaterial(descriptor);
});

test("playback descriptor flow: descriptor is short-lived", async () => {
  resetAuditRecordsForContractTests();
  const now = Date.now();
  const entitlement = await approvedEntitlement();
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement),
    new MockCloudflareSigner("ready")
  );
  assertShortLived(descriptor.expires_at, now);
});

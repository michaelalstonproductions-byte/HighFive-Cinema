import assert from "node:assert/strict";
import test from "node:test";
import { baseEntitlementRequest, compiledModule, playbackRequestFromEntitlement } from "./testHelpers.mjs";

const { validateEntitlement } = await import(compiledModule("entitlements/validateEntitlement.js"));
const { requestPlaybackDescriptor } = await import(compiledModule("playback/requestPlaybackDescriptor.js"));
const { MockEntitlementProvider } = await import(compiledModule("mocks/mockEntitlementProvider.js"));
const { MockCloudflareSigner } = await import(compiledModule("mocks/mockCloudflareSigner.js"));
const { RevenueCatValidatorPlaceholder } = await import(compiledModule("providers/revenueCatValidator.js"));
const { contractStates } = await import(compiledModule("contracts.js"));
const { resetAuditRecordsForContractTests } = await import(compiledModule("audit.js"));

test("local fallback: provider unavailable preserves local_preview_fallback", async () => {
  resetAuditRecordsForContractTests();
  const localFallbackState = "local_preview_fallback";
  const result = await validateEntitlement(baseEntitlementRequest(), new RevenueCatValidatorPlaceholder());
  assert.equal(result.entitlement_status, "entitlement_pending");
  assert.equal(result.access_decision, "entitlement_pending");
  assert.equal(localFallbackState, "local_preview_fallback");
  assert.ok(contractStates.includes("local_preview_fallback"));
});

test("local fallback: missing approval preserves local_preview_fallback", async () => {
  resetAuditRecordsForContractTests();
  const localFallbackState = "local_preview_fallback";
  const descriptor = await requestPlaybackDescriptor(
    { ...baseEntitlementRequest(), audit_id: "audit-friendly-missing" },
    new MockCloudflareSigner("ready")
  );
  assert.equal(descriptor.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(descriptor.playback_url_or_token_reference, null);
  assert.equal(localFallbackState, "local_preview_fallback");
});

test("local fallback: invalid mapping preserves local_preview_fallback", async () => {
  resetAuditRecordsForContractTests();
  const localFallbackState = "local_preview_fallback";
  const entitlement = await validateEntitlement(
    baseEntitlementRequest({ storekit_product_id: "com.highfive.series.paranormall.season1" }),
    new MockEntitlementProvider("approved")
  );
  const descriptor = await requestPlaybackDescriptor(
    playbackRequestFromEntitlement(entitlement, { storekit_product_id: "com.highfive.series.paranormall.season1" }),
    new MockCloudflareSigner("ready")
  );
  assert.equal(entitlement.access_decision, "entitlement_denied");
  assert.equal(descriptor.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(localFallbackState, "local_preview_fallback");
});

test("local fallback: rollback state preserves local_preview_fallback", async () => {
  resetAuditRecordsForContractTests();
  const rollbackState = "local_preview_fallback";
  const entitlement = await validateEntitlement(baseEntitlementRequest(), new RevenueCatValidatorPlaceholder());
  const descriptor = await requestPlaybackDescriptor(
    { ...baseEntitlementRequest(), audit_id: entitlement.audit_id },
    new MockCloudflareSigner("unavailable")
  );
  assert.equal(entitlement.entitlement_status, "entitlement_pending");
  assert.equal(descriptor.playback_descriptor_status, "descriptor_unavailable");
  assert.equal(rollbackState, "local_preview_fallback");
});

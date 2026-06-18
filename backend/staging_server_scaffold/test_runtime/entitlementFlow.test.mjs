import assert from "node:assert/strict";
import test from "node:test";
import { assertIsoDate, baseEntitlementRequest, compiledModule } from "./testHelpers.mjs";

const { validateEntitlement } = await import(compiledModule("entitlements/validateEntitlement.js"));
const { MockEntitlementProvider } = await import(compiledModule("mocks/mockEntitlementProvider.js"));
const { findAuditRecord, resetAuditRecordsForContractTests } = await import(compiledModule("audit.js"));

test("entitlement flow: approved result", async () => {
  resetAuditRecordsForContractTests();
  const result = await validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("approved"));
  assert.equal(result.entitlement_status, "entitlement_approved");
  assert.equal(result.access_decision, "entitlement_approved");
  assert.equal(result.denial_reason, null);
  assertIsoDate(result.expires_at, "approved entitlement must include expires_at");
  assertIsoDate(result.refresh_after, "approved entitlement must include refresh_after");
});

test("entitlement flow: denied result", async () => {
  resetAuditRecordsForContractTests();
  const result = await validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("denied"));
  assert.equal(result.entitlement_status, "entitlement_denied");
  assert.equal(result.access_decision, "entitlement_denied");
  assert.equal(result.denial_reason, "mock_entitlement_denied");
  assert.equal(result.expires_at, null);
  assert.equal(result.refresh_after, null);
});

test("entitlement flow: pending result", async () => {
  resetAuditRecordsForContractTests();
  const result = await validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("pending"));
  assert.equal(result.entitlement_status, "entitlement_pending");
  assert.equal(result.access_decision, "entitlement_pending");
  assert.equal(result.denial_reason, "mock_entitlement_pending");
  assert.equal(result.expires_at, null);
  assert.equal(result.refresh_after, null);
});

test("entitlement flow: mismatch denied before provider approval", async () => {
  resetAuditRecordsForContractTests();
  let providerCalls = 0;
  const approvingProvider = {
    async validate() {
      providerCalls += 1;
      return { status: "entitlement_approved", denial_reason: null };
    }
  };
  const result = await validateEntitlement(
    baseEntitlementRequest({ storekit_product_id: "com.highfive.series.paranormall.season1" }),
    approvingProvider
  );
  assert.equal(providerCalls, 0);
  assert.equal(result.entitlement_status, "entitlement_denied");
  assert.equal(result.denial_reason, "product_mapping_mismatch");
});

test("entitlement flow: audit ID produced", async () => {
  resetAuditRecordsForContractTests();
  const result = await validateEntitlement(baseEntitlementRequest(), new MockEntitlementProvider("approved"));
  assert.match(result.audit_id, /^audit-friendly-\d+$/);
  const audit = findAuditRecord(result.audit_id);
  assert.equal(audit?.event_name, "entitlement_validation_approved");
  assert.equal(audit?.movie_id, "friendly");
  assert.equal(audit?.storekit_product_id, "com.highfive.movie.thefriendly");
});

test("entitlement flow: app-provided entitlement state is not trusted", async () => {
  resetAuditRecordsForContractTests();
  const result = await validateEntitlement(
    baseEntitlementRequest({
      entitlement_context: {
        app_reported_state: "entitlement_approved",
        local_receipt_claim: "approved"
      }
    }),
    new MockEntitlementProvider("denied")
  );
  assert.equal(result.entitlement_status, "entitlement_denied");
  assert.equal(result.access_decision, "entitlement_denied");
  assert.equal(result.denial_reason, "mock_entitlement_denied");
});

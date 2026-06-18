import assert from "node:assert/strict";
import test from "node:test";
import { baseEntitlementRequest, compiledModule } from "./testHelpers.mjs";

const { expectedProductIDForMovie, productMatchesMovie } = await import(compiledModule("productMapping.js"));
const { validateEntitlement } = await import(compiledModule("entitlements/validateEntitlement.js"));
const { MockEntitlementProvider } = await import(compiledModule("mocks/mockEntitlementProvider.js"));
const { resetAuditRecordsForContractTests } = await import(compiledModule("audit.js"));

test("product mapping: Friendly mapping", () => {
  assert.equal(expectedProductIDForMovie("friendly"), "com.highfive.movie.thefriendly");
  assert.equal(productMatchesMovie("friendly", "com.highfive.movie.thefriendly"), true);
});

test("product mapping: Paranormall season mapping", () => {
  assert.equal(expectedProductIDForMovie("paranormall-s1"), "com.highfive.series.paranormall.season1");
  assert.equal(productMatchesMovie("paranormall-s1", "com.highfive.series.paranormall.season1"), true);
});

for (let episode = 1; episode <= 7; episode += 1) {
  test(`product mapping: Paranormall episode ${episode}`, () => {
    assert.equal(
      expectedProductIDForMovie(`paranormall_s1_e${episode}`),
      `com.highfive.episode.paranormall.e${episode}`
    );
    assert.equal(
      productMatchesMovie(`paranormall_s1_e${episode}`, `com.highfive.episode.paranormall.e${episode}`),
      true
    );
  });
}

test("product mapping: unknown movie rejection", async () => {
  resetAuditRecordsForContractTests();
  assert.equal(expectedProductIDForMovie("unknown-movie"), undefined);
  const result = await validateEntitlement(
    baseEntitlementRequest({
      movie_id: "unknown-movie",
      storekit_product_id: "com.highfive.movie.unknown"
    }),
    new MockEntitlementProvider("approved")
  );
  assert.equal(result.entitlement_status, "entitlement_denied");
  assert.equal(result.access_decision, "entitlement_denied");
  assert.equal(result.denial_reason, "product_mapping_mismatch");
});

test("product mapping: movie/product mismatch rejection", async () => {
  resetAuditRecordsForContractTests();
  const result = await validateEntitlement(
    baseEntitlementRequest({
      movie_id: "friendly",
      storekit_product_id: "com.highfive.series.paranormall.season1"
    }),
    new MockEntitlementProvider("approved")
  );
  assert.equal(result.entitlement_status, "entitlement_denied");
  assert.equal(result.access_decision, "entitlement_denied");
  assert.equal(result.denial_reason, "product_mapping_mismatch");
});

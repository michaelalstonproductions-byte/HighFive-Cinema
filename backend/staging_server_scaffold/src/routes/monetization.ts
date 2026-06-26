import { type EntitlementValidationRequest, type JsonObject, isRecord } from "../contracts.js";
import { ContractError } from "../errors.js";
import { expectedProductIDForMovie } from "../productMapping.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type MonetizationProduct = {
  id: string;
  product_id: string;
  title: string;
  kind: "subscription" | "movie" | "season" | "episode";
  display_price: string;
  entitlement_scope: string;
  subscription_management_link: string | null;
  detail: string;
};

type TransactionRecord = {
  id: string;
  user_id: string;
  product_id: string;
  original_transaction_id: string;
  transaction_id: string;
  environment: "development" | "sandbox" | "production";
  status: "verified" | "revoked" | "expired";
  purchased_at: string;
  expires_at: string | null;
  app_account_token: string | null;
};

type EntitlementRecord = {
  id: string;
  user_id: string;
  product_id: string;
  scope: string;
  status: "active" | "grace_period" | "revoked" | "expired";
  source: "storekit2" | "development";
  transaction_id: string;
  expires_at: string | null;
  grace_period_expires_at: string | null;
  billing_retry: boolean;
  family_shared: boolean;
  revocation_reason: string | null;
  subscription_management_link: string | null;
  updated_at: string;
};

type MonetizationAuditRecord = {
  id: string;
  user_id: string;
  action: string;
  product_id: string | null;
  detail: string;
  created_at: string;
};

const products: MonetizationProduct[] = [
  {
    id: "highfive-pass-monthly",
    product_id: "com.highfive.pass.monthly",
    title: "HighFive Pass Monthly",
    kind: "subscription",
    display_price: "$7.99",
    entitlement_scope: "highfive_pass",
    subscription_management_link: "app-store-subscription-management",
    detail: "StoreKit 2 subscription product for HighFive Pass entitlement checks."
  },
  {
    id: "highfive-pass-annual",
    product_id: "com.highfive.pass.annual",
    title: "HighFive Pass Annual",
    kind: "subscription",
    display_price: "$79.99",
    entitlement_scope: "highfive_pass",
    subscription_management_link: "app-store-subscription-management",
    detail: "StoreKit 2 annual subscription product for HighFive Pass entitlement checks."
  },
  {
    id: "friendly",
    product_id: "com.highfive.movie.thefriendly",
    title: "The Friendly",
    kind: "movie",
    display_price: "$4.99",
    entitlement_scope: "movie:friendly",
    subscription_management_link: null,
    detail: "Transactional movie entitlement mapped to the Friendly catalog title."
  },
  {
    id: "paranormall-s1",
    product_id: "com.highfive.series.paranormall.season1",
    title: "Paranormall Season 1",
    kind: "season",
    display_price: "$9.99",
    entitlement_scope: "series:paranormall-s1",
    subscription_management_link: null,
    detail: "Transactional season entitlement mapped to the Paranormall catalog season."
  }
];

const transactions: TransactionRecord[] = [];
const entitlements: EntitlementRecord[] = [];
const auditRecords: MonetizationAuditRecord[] = [];
let transactionCounter = 1;
let entitlementCounter = 1;
let auditCounter = 1;

export function monetizationProducts(): JsonObject {
  return {
    status: "ready",
    products,
    storekit2_contract: true,
    app_store_server_api_contract: true,
    direct_card_collection: false
  };
}

export function monetizationEntitlements(authorizationHeader: string | undefined): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  expireUserEntitlements(session.user_id);
  const records = entitlements.filter((record) => record.user_id === session.user_id);
  recordAudit(session, "entitlements_checked", null, "Backend entitlement records fetched for authenticated account.");
  return {
    status: "ready",
    user_id: session.user_id,
    entitlements: records,
    active_entitlements: records.filter((record) => record.status === "active")
  };
}

export function recordStoreKitTransaction(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  const payload = transactionPayload(body);
  const product = productForID(payload.product_id);
  if (!product) throw new ContractError("unknown_product", "StoreKit product is not registered in the backend catalog.", 422);

  const status = transactionStatus(payload);
  const transaction: TransactionRecord = {
    id: `storekit-transaction-${transactionCounter++}`,
    user_id: session.user_id,
    product_id: product.product_id,
    original_transaction_id: payload.original_transaction_id,
    transaction_id: payload.transaction_id,
    environment: payload.environment,
    status: status === "grace_period" ? "verified" : status,
    purchased_at: payload.purchase_date ?? nowISO(),
    expires_at: payload.expiration_date,
    app_account_token: payload.app_account_token
  };
  transactions.push(transaction);

  const entitlement = upsertEntitlement(session, product, transaction, status === "verified" ? "active" : status, payload);
  recordAudit(session, `transaction_${status}`, product.product_id, `StoreKit transaction ${transaction.transaction_id} recorded as ${status}.`);
  return {
    status: "recorded",
    transaction,
    entitlement,
    app_store_server_api_contract: true,
    subscription_management_link: product.subscription_management_link
  };
}

export function restoreMonetizationEntitlements(authorizationHeader: string | undefined): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  expireUserEntitlements(session.user_id);
  const restored = entitlements.filter((record) => record.user_id === session.user_id && isAccessGrantingStatus(record.status));
  recordAudit(session, "restore_checked", null, `${restored.length} active entitlement records restored from backend ledger.`);
  return {
    status: "restored",
    restored_entitlements: restored,
    restore_supported: true,
    app_store_server_api_contract: true,
    subscription_management_link: "app-store-subscription-management"
  };
}

export function revokeMonetizationEntitlement(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  const productID = stringField(body, "product_id");
  if (!productID) throw new ContractError("product_id_required", "Revocation requires product_id.", 400);
  const affected = entitlements.filter((record) => record.user_id === session.user_id && record.product_id === productID);
  for (const record of affected) {
    record.status = "revoked";
    record.updated_at = nowISO();
  }
  recordAudit(session, "entitlement_revoked", productID, `${affected.length} entitlement records revoked.`);
  return {
    status: "revoked",
    product_id: productID,
    entitlements: affected
  };
}

export function monetizationAudit(authorizationHeader: string | undefined): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  return {
    status: "ready",
    events: auditRecords.filter((record) => record.user_id === session.user_id).slice(-30)
  };
}

export function monetizationReadinessSummary(): JsonObject {
  return {
    storekit2_products: true,
    purchase_recording: true,
    transaction_updates: true,
    restore_supported: true,
    revocation_supported: true,
    expiration_supported: true,
    grace_period_supported: true,
    billing_retry_supported: true,
    family_sharing_supported: true,
    subscription_management_link: true,
    playback_entitlement_checks: true,
    download_entitlement_checks: true,
    backend_entitlement_records: true,
    app_store_server_api_contract: true,
    direct_card_collection: false,
    active_entitlements: entitlements.filter((record) => isAccessGrantingStatus(record.status)).length,
    transaction_records: transactions.length
  };
}

export function activeEntitlementForRequest(request: EntitlementValidationRequest): EntitlementRecord | null {
  if (!request.user_id) return null;
  expireUserEntitlements(request.user_id);
  const expectedProductID = expectedProductIDForMovie(request.movie_id);
  const productIDs = new Set([request.storekit_product_id, expectedProductID, "com.highfive.pass.monthly", "com.highfive.pass.annual"].filter(Boolean));
  return entitlements.find((record) => record.user_id === request.user_id && isAccessGrantingStatus(record.status) && productIDs.has(record.product_id)) ?? null;
}

function upsertEntitlement(
  session: IdentitySession,
  product: MonetizationProduct,
  transaction: TransactionRecord,
  status: EntitlementRecord["status"],
  payload: ReturnType<typeof transactionPayload>
): EntitlementRecord {
  const existing = entitlements.find((record) => record.user_id === session.user_id && record.product_id === product.product_id);
  if (existing) {
    existing.status = status;
    existing.transaction_id = transaction.transaction_id;
    existing.expires_at = transaction.expires_at;
    existing.grace_period_expires_at = payload.grace_period_expires_at;
    existing.billing_retry = payload.billing_retry;
    existing.family_shared = payload.family_shared;
    existing.revocation_reason = payload.revocation_reason;
    existing.subscription_management_link = product.subscription_management_link;
    existing.updated_at = nowISO();
    return existing;
  }
  const record: EntitlementRecord = {
    id: `entitlement-${entitlementCounter++}`,
    user_id: session.user_id,
    product_id: product.product_id,
    scope: product.entitlement_scope,
    status,
    source: transaction.environment === "development" ? "development" : "storekit2",
    transaction_id: transaction.transaction_id,
    expires_at: transaction.expires_at,
    grace_period_expires_at: payload.grace_period_expires_at,
    billing_retry: payload.billing_retry,
    family_shared: payload.family_shared,
    revocation_reason: payload.revocation_reason,
    subscription_management_link: product.subscription_management_link,
    updated_at: nowISO()
  };
  entitlements.push(record);
  return record;
}

function expireUserEntitlements(userID: string): void {
  const now = Date.now();
  for (const record of entitlements) {
    if (record.user_id !== userID) continue;
    if (record.status === "active" && record.expires_at && Date.parse(record.expires_at) <= now) {
      if (record.grace_period_expires_at && Date.parse(record.grace_period_expires_at) > now) {
        record.status = "grace_period";
      } else {
        record.status = "expired";
      }
      record.updated_at = nowISO();
    }
    if (record.status === "grace_period" && record.grace_period_expires_at && Date.parse(record.grace_period_expires_at) <= now) {
      record.status = "expired";
      record.updated_at = nowISO();
    }
  }
}

function transactionPayload(body: unknown): {
  product_id: string;
  transaction_id: string;
  original_transaction_id: string;
  environment: "development" | "sandbox" | "production";
  purchase_date: string | null;
  expiration_date: string | null;
  revocation_date: string | null;
  grace_period_expires_at: string | null;
  billing_retry: boolean;
  family_shared: boolean;
  revocation_reason: string | null;
  app_account_token: string | null;
} {
  if (!isRecord(body)) throw new ContractError("transaction_body_required", "StoreKit transaction body is required.", 400);
  const productID = stringField(body, "product_id");
  const transactionID = stringField(body, "transaction_id");
  if (!productID || !transactionID) throw new ContractError("transaction_fields_required", "product_id and transaction_id are required.", 400);
  const environment = environmentField(body.environment);
  return {
    product_id: productID,
    transaction_id: transactionID,
    original_transaction_id: stringField(body, "original_transaction_id") ?? transactionID,
    environment,
    purchase_date: stringField(body, "purchase_date"),
    expiration_date: stringField(body, "expiration_date"),
    revocation_date: stringField(body, "revocation_date"),
    grace_period_expires_at: stringField(body, "grace_period_expires_at"),
    billing_retry: booleanField(body, "billing_retry"),
    family_shared: booleanField(body, "family_shared"),
    revocation_reason: stringField(body, "revocation_reason"),
    app_account_token: stringField(body, "app_account_token")
  };
}

function transactionStatus(payload: ReturnType<typeof transactionPayload>): "verified" | "grace_period" | "revoked" | "expired" {
  if (payload.revocation_date) return "revoked";
  if (payload.expiration_date && Date.parse(payload.expiration_date) <= Date.now()) {
    if (payload.grace_period_expires_at && Date.parse(payload.grace_period_expires_at) > Date.now()) return "grace_period";
    return "expired";
  }
  return "verified";
}

function isAccessGrantingStatus(status: EntitlementRecord["status"]): boolean {
  return status === "active" || status === "grace_period";
}

function productForID(productID: string): MonetizationProduct | undefined {
  return products.find((product) => product.product_id === productID);
}

function stringField(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function environmentField(value: unknown): "development" | "sandbox" | "production" {
  if (value === "production" || value === "sandbox" || value === "development") return value;
  return "development";
}

function booleanField(body: unknown, key: string): boolean {
  if (!isRecord(body)) return false;
  return body[key] === true;
}

function recordAudit(session: IdentitySession, action: string, productID: string | null, detail: string): void {
  auditRecords.push({
    id: `monetization-audit-${auditCounter++}`,
    user_id: session.user_id,
    action,
    product_id: productID,
    detail,
    created_at: nowISO()
  });
  if (auditRecords.length > 100) auditRecords.splice(0, auditRecords.length - 100);
}

function nowISO(): string {
  return new Date().toISOString();
}

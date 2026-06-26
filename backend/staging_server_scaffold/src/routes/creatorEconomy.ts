import { catalogSeed, type CatalogCollection, type CatalogCreator, type CatalogMovie } from "../catalog/catalogSeed.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type RevenueSource = "streaming" | "tip" | "membership" | "paid_collection" | "paid_premiere";

type RevenueLedgerRecord = {
  id: string;
  creator_id: string;
  source: RevenueSource;
  amount_cents: number;
  platform_fee_cents: number;
  creator_net_cents: number;
  content_id: string | null;
  collection_id: string | null;
  viewer_user_id: string | null;
  status: "estimated" | "available" | "pending_payout";
  created_at: string;
};

type RevenueShareRecord = {
  id: string;
  creator_id: string;
  content_id: string | null;
  platform_share_percent: number;
  creator_share_percent: number;
  updated_at: string;
};

type PayoutPreviewRecord = {
  id: string;
  creator_id: string;
  amount_cents: number;
  status: "preview" | "queued";
  ledger_record_ids: string[];
  created_at: string;
};

type CreatorMembershipRecord = {
  id: string;
  creator_id: string;
  viewer_user_id: string;
  tier_id: string;
  display_name: string;
  amount_cents: number;
  state: "active" | "paused" | "cancelled";
  started_at: string;
  updated_at: string;
};

type PaidCollectionRecord = {
  id: string;
  creator_id: string;
  collection_id: string;
  title: string;
  movie_ids: string[];
  price_cents: number;
  state: "draft" | "available" | "archived";
  created_at: string;
  updated_at: string;
};

type PaidPremiereRecord = {
  id: string;
  creator_id: string;
  movie_id: string;
  title: string;
  price_cents: number;
  window_label: string;
  state: "scheduled" | "available" | "archived";
  created_at: string;
  updated_at: string;
};

const revenueLedger: RevenueLedgerRecord[] = seedStreamingRevenue();
const revenueShares: RevenueShareRecord[] = catalogSeed.movies.map((movie, index) => ({
  id: `revenue-share-${index + 1}`,
  creator_id: movie.creator_id,
  content_id: movie.id,
  platform_share_percent: 30,
  creator_share_percent: 70,
  updated_at: catalogSeed.generated_at
}));
const payoutPreviews: PayoutPreviewRecord[] = [];
const memberships: CreatorMembershipRecord[] = [];
const paidCollections: PaidCollectionRecord[] = [];
const paidPremieres: PaidPremiereRecord[] = [];

let ledgerCounter = revenueLedger.length + 1;
let revenueShareCounter = revenueShares.length + 1;
let payoutCounter = 1;
let membershipCounter = 1;
let paidCollectionCounter = 1;
let paidPremiereCounter = 1;

export function creatorEconomyReadinessSummary() {
  return {
    creator_economy_enabled: true,
    creator_payouts: true,
    creator_dashboard: true,
    revenue_sharing: true,
    tips: true,
    memberships: true,
    paid_collections: true,
    paid_premieres: true,
    direct_card_collection: false,
    external_processor_calls: false,
    ledger_records: revenueLedger.length
  };
}

export function creatorEconomyDashboard(authorizationHeader: string | undefined) {
  const session = requireCreatorEconomySession(authorizationHeader);
  const creator = creatorForSession(session);
  const ledger = ledgerForCreator(creator.id);
  const titles = titlesForCreator(creator.id);
  const collectionPackages = paidCollections.filter((record) => record.creator_id === creator.id);
  const premierePackages = paidPremieres.filter((record) => record.creator_id === creator.id);
  const memberRecords = memberships.filter((record) => record.creator_id === creator.id && record.state === "active");
  return {
    status: "ready",
    creator,
    summary: revenueSummary(ledger),
    revenue_sources: sourceSummary(ledger),
    top_titles: titleRevenueSummary(creator.id),
    memberships: memberRecords,
    paid_collections: collectionPackages,
    paid_premieres: premierePackages,
    revenue_shares: revenueShares.filter((record) => record.creator_id === creator.id),
    payout_preview: payoutSummary(creator.id),
    creator_dashboard: {
      titles: titles.length,
      active_members: memberRecords.length,
      paid_packages: collectionPackages.length + premierePackages.length,
      estimated_revenue_cents: ledger.reduce((total, record) => total + record.amount_cents, 0),
      available_creator_net_cents: ledger.filter((record) => record.status === "available").reduce((total, record) => total + record.creator_net_cents, 0)
    }
  };
}

export function creatorEconomyPayouts(authorizationHeader: string | undefined, body?: unknown) {
  const session = requireCreatorEconomySession(authorizationHeader);
  const creator = creatorForSession(session);
  if (body === undefined) {
    return {
      status: "ready",
      creator_id: creator.id,
      payouts: payoutPreviews.filter((record) => record.creator_id === creator.id),
      payout_preview: payoutSummary(creator.id),
      payout_processing: "not_configured"
    };
  }
  const amountCents = positiveCentsFromBody(body, "amount_cents") ?? payoutSummary(creator.id).available_creator_net_cents;
  if (amountCents <= 0) {
    throw new ContractError("payout_amount_unavailable", "Payout preview requires available creator revenue", 422);
  }
  const available = revenueLedger.filter((record) => record.creator_id === creator.id && record.status === "available");
  const selectedIDs: string[] = [];
  let selectedCents = 0;
  for (const record of available) {
    if (selectedCents >= amountCents) break;
    selectedIDs.push(record.id);
    selectedCents += record.creator_net_cents;
    record.status = "pending_payout";
  }
  const payout: PayoutPreviewRecord = {
    id: `payout-preview-${payoutCounter++}`,
    creator_id: creator.id,
    amount_cents: Math.min(selectedCents, amountCents),
    status: "queued",
    ledger_record_ids: selectedIDs,
    created_at: nowISO()
  };
  payoutPreviews.push(payout);
  return {
    status: "queued",
    payout,
    payout_processing: "preview_only_no_external_transfer"
  };
}

export function updateCreatorRevenueShare(authorizationHeader: string | undefined, body: unknown) {
  const session = requireCreatorEconomySession(authorizationHeader);
  const creator = creatorForSession(session);
  const contentID = optionalStringFromBody(body, "content_id");
  if (contentID) {
    const movie = movieForID(contentID);
    if (movie.creator_id !== creator.id && session.role !== "admin") {
      throw new ContractError("creator_content_required", "Revenue share can only be updated for creator-owned content", 403);
    }
  }
  const creatorPercent = percentFromBody(body, "creator_share_percent") ?? 70;
  const platformPercent = 100 - creatorPercent;
  const existingIndex = revenueShares.findIndex((record) => record.creator_id === creator.id && record.content_id === contentID);
  const record: RevenueShareRecord = {
    id: existingIndex >= 0 ? revenueShares[existingIndex].id : `revenue-share-${revenueShareCounter++}`,
    creator_id: creator.id,
    content_id: contentID,
    platform_share_percent: platformPercent,
    creator_share_percent: creatorPercent,
    updated_at: nowISO()
  };
  if (existingIndex >= 0) {
    revenueShares[existingIndex] = record;
  } else {
    revenueShares.push(record);
  }
  return {
    status: "updated",
    revenue_share: record
  };
}

export function recordCreatorTip(authorizationHeader: string | undefined, body: unknown) {
  const session = requireViewerEconomySession(authorizationHeader);
  const creator = creatorForID(stringFromBody(body, "creator_id", "invalid_tip_request"));
  const amountCents = positiveCentsFromBody(body, "amount_cents") ?? 500;
  const contentID = optionalStringFromBody(body, "content_id");
  if (contentID) movieForID(contentID);
  const ledger = appendLedgerRecord({
    creatorID: creator.id,
    source: "tip",
    amountCents,
    contentID,
    collectionID: null,
    viewerUserID: session.user_id,
    status: "available"
  });
  recordAnalyticsEvent("revenue_estimate", {
    creator_id: creator.id,
    content_id: contentID,
    revenue_cents: ledger.amount_cents,
    revenue_source: "tip"
  }, { authorizationHeader, contentID, creatorID: creator.id, source: "creator_economy_tip" });
  return {
    status: "recorded",
    tip: ledger,
    creator
  };
}

export function joinCreatorMembership(authorizationHeader: string | undefined, body: unknown) {
  const session = requireViewerEconomySession(authorizationHeader);
  const creator = creatorForID(stringFromBody(body, "creator_id", "invalid_membership_request"));
  const tierID = optionalStringFromBody(body, "tier_id") ?? "creator-supporter";
  const amountCents = positiveCentsFromBody(body, "amount_cents") ?? 799;
  const existingIndex = memberships.findIndex((record) => record.creator_id === creator.id && record.viewer_user_id === session.user_id && record.tier_id === tierID);
  const record: CreatorMembershipRecord = {
    id: existingIndex >= 0 ? memberships[existingIndex].id : `creator-membership-${membershipCounter++}`,
    creator_id: creator.id,
    viewer_user_id: session.user_id,
    tier_id: tierID,
    display_name: tierDisplayName(tierID),
    amount_cents: amountCents,
    state: "active",
    started_at: existingIndex >= 0 ? memberships[existingIndex].started_at : nowISO(),
    updated_at: nowISO()
  };
  if (existingIndex >= 0) {
    memberships[existingIndex] = record;
  } else {
    memberships.push(record);
  }
  const ledger = appendLedgerRecord({
    creatorID: creator.id,
    source: "membership",
    amountCents,
    contentID: null,
    collectionID: null,
    viewerUserID: session.user_id,
    status: "available"
  });
  return {
    status: "active",
    membership: record,
    ledger_record: ledger
  };
}

export function createPaidCollection(authorizationHeader: string | undefined, body: unknown) {
  const session = requireCreatorEconomySession(authorizationHeader);
  const creator = creatorForSession(session);
  const sourceCollectionID = optionalStringFromBody(body, "collection_id");
  const sourceCollection = sourceCollectionID ? collectionForID(sourceCollectionID) : null;
  const movieIDs = stringArrayFromBody(body, "movie_ids");
  const resolvedMovieIDs = (movieIDs.length > 0 ? movieIDs : sourceCollection?.movie_ids ?? titlesForCreator(creator.id).map((movie) => movie.id))
    .map((movieID) => movieForID(movieID))
    .filter((movie) => movie.creator_id === creator.id || session.role === "admin")
    .map((movie) => movie.id);
  if (resolvedMovieIDs.length === 0) {
    throw new ContractError("paid_collection_empty", "Paid collection requires creator-owned titles", 422);
  }
  const record: PaidCollectionRecord = {
    id: `paid-collection-${paidCollectionCounter++}`,
    creator_id: creator.id,
    collection_id: sourceCollection?.id ?? `creator-${creator.id}-collection-${paidCollectionCounter}`,
    title: optionalStringFromBody(body, "title") ?? `${creator.name} Collection`,
    movie_ids: [...new Set(resolvedMovieIDs)],
    price_cents: positiveCentsFromBody(body, "price_cents") ?? 1299,
    state: paidPackageStateFromBody(body) ?? "available",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  paidCollections.push(record);
  appendLedgerRecord({
    creatorID: creator.id,
    source: "paid_collection",
    amountCents: record.price_cents,
    contentID: null,
    collectionID: record.collection_id,
    viewerUserID: null,
    status: "estimated"
  });
  return {
    status: "created",
    paid_collection: record
  };
}

export function createPaidPremiere(authorizationHeader: string | undefined, body: unknown) {
  const session = requireCreatorEconomySession(authorizationHeader);
  const creator = creatorForSession(session);
  const movie = movieForID(stringFromBody(body, "movie_id", "invalid_paid_premiere_request"));
  if (movie.creator_id !== creator.id && session.role !== "admin") {
    throw new ContractError("creator_content_required", "Paid premiere can only be created for creator-owned content", 403);
  }
  const record: PaidPremiereRecord = {
    id: `paid-premiere-${paidPremiereCounter++}`,
    creator_id: creator.id,
    movie_id: movie.id,
    title: optionalStringFromBody(body, "title") ?? `${movie.title} Premiere`,
    price_cents: positiveCentsFromBody(body, "price_cents") ?? 499,
    window_label: optionalStringFromBody(body, "window_label") ?? "Premiere window",
    state: paidPremiereStateFromBody(body) ?? "scheduled",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  paidPremieres.push(record);
  appendLedgerRecord({
    creatorID: creator.id,
    source: "paid_premiere",
    amountCents: record.price_cents,
    contentID: movie.id,
    collectionID: null,
    viewerUserID: null,
    status: "estimated"
  });
  return {
    status: "created",
    paid_premiere: record
  };
}

function seedStreamingRevenue(): RevenueLedgerRecord[] {
  return catalogSeed.movies.map((movie, index) => {
    const gross = 1_200 + index * 475;
    const platformFee = Math.round(gross * 0.3);
    return {
      id: `creator-revenue-${index + 1}`,
      creator_id: movie.creator_id,
      source: "streaming",
      amount_cents: gross,
      platform_fee_cents: platformFee,
      creator_net_cents: gross - platformFee,
      content_id: movie.id,
      collection_id: null,
      viewer_user_id: null,
      status: "available",
      created_at: catalogSeed.generated_at
    };
  });
}

function appendLedgerRecord(input: {
  creatorID: string;
  source: RevenueSource;
  amountCents: number;
  contentID: string | null;
  collectionID: string | null;
  viewerUserID: string | null;
  status: RevenueLedgerRecord["status"];
}): RevenueLedgerRecord {
  const share = shareFor(input.creatorID, input.contentID);
  const platformFee = Math.round(input.amountCents * (share.platform_share_percent / 100));
  const record: RevenueLedgerRecord = {
    id: `creator-revenue-${ledgerCounter++}`,
    creator_id: input.creatorID,
    source: input.source,
    amount_cents: input.amountCents,
    platform_fee_cents: platformFee,
    creator_net_cents: input.amountCents - platformFee,
    content_id: input.contentID,
    collection_id: input.collectionID,
    viewer_user_id: input.viewerUserID,
    status: input.status,
    created_at: nowISO()
  };
  revenueLedger.push(record);
  return record;
}

function revenueSummary(ledger: RevenueLedgerRecord[]) {
  const gross = ledger.reduce((total, record) => total + record.amount_cents, 0);
  const platformFee = ledger.reduce((total, record) => total + record.platform_fee_cents, 0);
  const creatorNet = ledger.reduce((total, record) => total + record.creator_net_cents, 0);
  return {
    gross_revenue_cents: gross,
    platform_fee_cents: platformFee,
    creator_net_cents: creatorNet,
    available_creator_net_cents: ledger.filter((record) => record.status === "available").reduce((total, record) => total + record.creator_net_cents, 0),
    pending_payout_cents: ledger.filter((record) => record.status === "pending_payout").reduce((total, record) => total + record.creator_net_cents, 0),
    estimated_cents: ledger.filter((record) => record.status === "estimated").reduce((total, record) => total + record.creator_net_cents, 0)
  };
}

function sourceSummary(ledger: RevenueLedgerRecord[]) {
  const sources: RevenueSource[] = ["streaming", "tip", "membership", "paid_collection", "paid_premiere"];
  return sources.map((source) => {
    const records = ledger.filter((record) => record.source === source);
    return {
      source,
      records: records.length,
      gross_cents: records.reduce((total, record) => total + record.amount_cents, 0),
      creator_net_cents: records.reduce((total, record) => total + record.creator_net_cents, 0)
    };
  });
}

function titleRevenueSummary(creatorID: string) {
  return titlesForCreator(creatorID).map((movie) => {
    const ledger = revenueLedger.filter((record) => record.content_id === movie.id);
    return {
      movie_id: movie.id,
      title: movie.title,
      gross_revenue_cents: ledger.reduce((total, record) => total + record.amount_cents, 0),
      creator_net_cents: ledger.reduce((total, record) => total + record.creator_net_cents, 0),
      revenue_sources: [...new Set(ledger.map((record) => record.source))]
    };
  }).sort((lhs, rhs) => rhs.creator_net_cents - lhs.creator_net_cents || lhs.title.localeCompare(rhs.title));
}

function payoutSummary(creatorID: string) {
  const creatorLedger = ledgerForCreator(creatorID);
  return {
    creator_id: creatorID,
    available_creator_net_cents: creatorLedger.filter((record) => record.status === "available").reduce((total, record) => total + record.creator_net_cents, 0),
    pending_payout_cents: creatorLedger.filter((record) => record.status === "pending_payout").reduce((total, record) => total + record.creator_net_cents, 0),
    lifetime_creator_net_cents: creatorLedger.reduce((total, record) => total + record.creator_net_cents, 0),
    payout_records: payoutPreviews.filter((record) => record.creator_id === creatorID)
  };
}

function ledgerForCreator(creatorID: string): RevenueLedgerRecord[] {
  return revenueLedger.filter((record) => record.creator_id === creatorID);
}

function titlesForCreator(creatorID: string): CatalogMovie[] {
  return catalogSeed.movies.filter((movie) => movie.creator_id === creatorID);
}

function shareFor(creatorID: string, contentID: string | null): RevenueShareRecord {
  return revenueShares.find((record) => record.creator_id === creatorID && record.content_id === contentID) ??
    revenueShares.find((record) => record.creator_id === creatorID && record.content_id === null) ??
    {
      id: "default-revenue-share",
      creator_id: creatorID,
      content_id: contentID,
      platform_share_percent: 30,
      creator_share_percent: 70,
      updated_at: catalogSeed.generated_at
    };
}

function requireCreatorEconomySession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("creator_role_required", "Creator economy dashboard requires a creator or admin session", 403);
  }
  return session;
}

function requireViewerEconomySession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "viewer" && session.role !== "admin") {
    throw new ContractError("viewer_role_required", "Creator economy support actions require a viewer or admin session", 403);
  }
  return session;
}

function creatorForSession(session: IdentitySession): CatalogCreator {
  if (session.role === "admin") return catalogSeed.creators[0];
  return creatorForID(session.creator_id ?? catalogSeed.creators[0].id);
}

function creatorForID(creatorID: string): CatalogCreator {
  const creator = catalogSeed.creators.find((candidate) => candidate.id === creatorID);
  if (!creator) {
    throw new ContractError("creator_not_found", "Creator was not found", 404);
  }
  return creator;
}

function movieForID(movieID: string): CatalogMovie {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === movieID);
  if (!movie) {
    throw new ContractError("content_not_found", "Catalog content was not found", 404);
  }
  return movie;
}

function collectionForID(collectionID: string): CatalogCollection {
  const collection = catalogSeed.collections.find((candidate) => candidate.id === collectionID);
  if (!collection) {
    throw new ContractError("collection_not_found", "Catalog collection was not found", 404);
  }
  return collection;
}

function stringFromBody(body: unknown, key: string, code: string): string {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) {
    throw new ContractError(code, `${key} is required`, 400);
  }
  return body[key].trim();
}

function optionalStringFromBody(body: unknown, key: string): string | null {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) return null;
  return body[key].trim();
}

function stringArrayFromBody(body: unknown, key: string): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return [];
  return body[key]
    .filter((value): value is string => typeof value === "string" && value.trim().length > 0)
    .map((value) => value.trim());
}

function positiveCentsFromBody(body: unknown, key: string): number | null {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return null;
  return Math.max(1, Math.round(body[key]));
}

function percentFromBody(body: unknown, key: string): number | null {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return null;
  return Math.max(1, Math.min(99, Math.round(body[key])));
}

function paidPackageStateFromBody(body: unknown): PaidCollectionRecord["state"] | null {
  const state = optionalStringFromBody(body, "state");
  return state === "draft" || state === "available" || state === "archived" ? state : null;
}

function paidPremiereStateFromBody(body: unknown): PaidPremiereRecord["state"] | null {
  const state = optionalStringFromBody(body, "state");
  return state === "scheduled" || state === "available" || state === "archived" ? state : null;
}

function tierDisplayName(tierID: string): string {
  if (tierID === "premiere-circle") return "Premiere Circle";
  if (tierID === "studio-insider") return "Studio Insider";
  return "Creator Supporter";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}

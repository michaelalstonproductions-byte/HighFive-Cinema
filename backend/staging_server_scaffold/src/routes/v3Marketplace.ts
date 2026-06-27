import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type MarketplaceStatus = "available" | "review" | "reserved";

type LicenseListingRecord = {
  id: string;
  creator_id: string | null;
  content_id: string;
  title: string;
  territory: string;
  window_label: string;
  rights_scope: "festival" | "streaming" | "education" | "airline";
  status: MarketplaceStatus;
  created_at: string;
  updated_at: string;
};

type DistributionListingRecord = {
  id: string;
  creator_id: string | null;
  target: "highfive" | "premiere" | "partner" | "education";
  package_id: string;
  readiness: "ready" | "needs_review";
  territory: string;
  created_at: string;
  updated_at: string;
};

type CreatorServiceRecord = {
  id: string;
  creator_id: string | null;
  name: string;
  service_type: "editing" | "poster" | "metadata" | "marketing" | "consulting";
  availability: MarketplaceStatus;
  delivery_window: string;
  created_at: string;
  updated_at: string;
};

type ProductionServiceRecord = {
  id: string;
  creator_id: string | null;
  name: string;
  service_type: "crew" | "location" | "equipment" | "post" | "sound";
  region: string;
  availability: MarketplaceStatus;
  created_at: string;
  updated_at: string;
};

type MusicListingRecord = {
  id: string;
  creator_id: string | null;
  title: string;
  mood: "cinematic" | "tense" | "warm" | "ambient";
  duration_seconds: number;
  license_scope: "trailer" | "feature" | "series" | "promo";
  status: MarketplaceStatus;
  created_at: string;
  updated_at: string;
};

type StockFootageRecord = {
  id: string;
  creator_id: string | null;
  title: string;
  category: "city" | "nature" | "studio" | "texture" | "aerial";
  resolution: "HD" | "4K" | "8K";
  license_scope: "editorial" | "commercial" | "internal";
  status: MarketplaceStatus;
  created_at: string;
  updated_at: string;
};

const licenseListings: LicenseListingRecord[] = [];
const distributionListings: DistributionListingRecord[] = [];
const creatorServices: CreatorServiceRecord[] = [];
const productionServices: ProductionServiceRecord[] = [];
const musicListings: MusicListingRecord[] = [];
const stockFootageListings: StockFootageRecord[] = [];

let licenseCounter = 1;
let distributionCounter = 1;
let creatorServiceCounter = 1;
let productionServiceCounter = 1;
let musicCounter = 1;
let stockCounter = 1;

seedMarketplace();

export function v3MarketplaceReadinessSummary(): JsonObject {
  return {
    v3_marketplace_enabled: true,
    license_marketplace: true,
    distribution_marketplace: true,
    creator_services: true,
    production_services: true,
    music_marketplace: true,
    stock_footage_marketplace: true,
    transaction_processing: false,
    external_marketplace_services: false,
    license_listings: licenseListings.length,
    service_listings: creatorServices.length + productionServices.length,
    asset_listings: musicListings.length + stockFootageListings.length
  };
}

export function v3MarketplaceSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  return {
    status: "ready",
    marketplace: "local_v3_marketplace",
    transaction_processing: false,
    external_services: false,
    user_id: session.user_id,
    creator_id: session.creator_id,
    licenses: visibleTo(session, licenseListings),
    distribution: visibleTo(session, distributionListings),
    creator_services: visibleTo(session, creatorServices),
    production_services: visibleTo(session, productionServices),
    music: visibleTo(session, musicListings),
    stock_footage: visibleTo(session, stockFootageListings),
    dashboard: marketplaceDashboard(session),
    generated_at: nowISO()
  };
}

export function createMarketplaceLicense(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  const movie = catalogSeed.movies.find((candidate) => candidate.id === optionalString(body, "content_id")) ?? catalogSeed.movies[0];
  const record: LicenseListingRecord = {
    id: `marketplace-license-${licenseCounter++}`,
    creator_id: session.creator_id,
    content_id: movie?.id ?? "friendly",
    title: trimmed(optionalString(body, "title") ?? movie?.title ?? "HighFive Title", 140),
    territory: trimmed(optionalString(body, "territory") ?? "US", 40),
    window_label: trimmed(optionalString(body, "window_label") ?? "Preview window", 120),
    rights_scope: rightsScope(optionalString(body, "rights_scope")),
    status: marketplaceStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  licenseListings.push(record);
  return { status: "created", license: record };
}

export function createMarketplaceDistribution(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  const record: DistributionListingRecord = {
    id: `marketplace-distribution-${distributionCounter++}`,
    creator_id: session.creator_id,
    target: distributionTarget(optionalString(body, "target")),
    package_id: trimmed(optionalString(body, "package_id") ?? "release-package-preview", 120),
    readiness: readiness(optionalString(body, "readiness")),
    territory: trimmed(optionalString(body, "territory") ?? "US", 40),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  distributionListings.push(record);
  return { status: "created", distribution: record };
}

export function createMarketplaceCreatorService(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  const record: CreatorServiceRecord = {
    id: `marketplace-creator-service-${creatorServiceCounter++}`,
    creator_id: session.creator_id,
    name: trimmed(optionalString(body, "name") ?? "Creator Service", 120),
    service_type: creatorServiceType(optionalString(body, "service_type")),
    availability: marketplaceStatus(optionalString(body, "availability")),
    delivery_window: trimmed(optionalString(body, "delivery_window") ?? "Local review window", 120),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  creatorServices.push(record);
  return { status: "created", creator_service: record };
}

export function createMarketplaceProductionService(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  const record: ProductionServiceRecord = {
    id: `marketplace-production-service-${productionServiceCounter++}`,
    creator_id: session.creator_id,
    name: trimmed(optionalString(body, "name") ?? "Production Service", 120),
    service_type: productionServiceType(optionalString(body, "service_type")),
    region: trimmed(optionalString(body, "region") ?? "Local", 80),
    availability: marketplaceStatus(optionalString(body, "availability")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  productionServices.push(record);
  return { status: "created", production_service: record };
}

export function createMarketplaceMusic(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  const record: MusicListingRecord = {
    id: `marketplace-music-${musicCounter++}`,
    creator_id: session.creator_id,
    title: trimmed(optionalString(body, "title") ?? "Cinematic Cue", 120),
    mood: musicMood(optionalString(body, "mood")),
    duration_seconds: positiveInteger(body, "duration_seconds", 90),
    license_scope: musicLicenseScope(optionalString(body, "license_scope")),
    status: marketplaceStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  musicListings.push(record);
  return { status: "created", music: record };
}

export function createMarketplaceStockFootage(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireMarketplaceSession(authorizationHeader);
  const record: StockFootageRecord = {
    id: `marketplace-stock-footage-${stockCounter++}`,
    creator_id: session.creator_id,
    title: trimmed(optionalString(body, "title") ?? "Stock Footage", 120),
    category: stockCategory(optionalString(body, "category")),
    resolution: stockResolution(optionalString(body, "resolution")),
    license_scope: stockLicenseScope(optionalString(body, "license_scope")),
    status: marketplaceStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  stockFootageListings.push(record);
  return { status: "created", stock_footage: record };
}

function seedMarketplace(): void {
  if (licenseListings.length > 0) return;
  const creatorID = "maya-hart";
  licenseListings.push({
    id: "marketplace-license-seed-1",
    creator_id: creatorID,
    content_id: "friendly",
    title: "The Friendly Festival Window",
    territory: "US",
    window_label: "Spring festival preview",
    rights_scope: "festival",
    status: "available",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  distributionListings.push({
    id: "marketplace-distribution-seed-1",
    creator_id: creatorID,
    target: "premiere",
    package_id: "release-package-friendly",
    readiness: "ready",
    territory: "US",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  creatorServices.push({
    id: "marketplace-creator-service-seed-1",
    creator_id: creatorID,
    name: "Poster Polish Review",
    service_type: "poster",
    availability: "available",
    delivery_window: "Two local review days",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  productionServices.push({
    id: "marketplace-production-service-seed-1",
    creator_id: creatorID,
    name: "Sound Mix Review",
    service_type: "sound",
    region: "Los Angeles",
    availability: "review",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  musicListings.push({
    id: "marketplace-music-seed-1",
    creator_id: creatorID,
    title: "Gold Room Cue",
    mood: "cinematic",
    duration_seconds: 96,
    license_scope: "trailer",
    status: "available",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  stockFootageListings.push({
    id: "marketplace-stock-footage-seed-1",
    creator_id: creatorID,
    title: "Night City Plate",
    category: "city",
    resolution: "4K",
    license_scope: "editorial",
    status: "available",
    created_at: nowISO(),
    updated_at: nowISO()
  });
}

function requireMarketplaceSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("marketplace_role_required", "Marketplace operations require a creator or admin session", 403);
  }
  return session;
}

function visibleTo<T extends { creator_id: string | null }>(session: IdentitySession, records: T[]): T[] {
  if (session.role === "admin") return records;
  return records.filter((record) => record.creator_id === session.creator_id);
}

function marketplaceDashboard(session: IdentitySession): JsonObject {
  const licenses = visibleTo(session, licenseListings);
  const creatorServiceRecords = visibleTo(session, creatorServices);
  const productionServiceRecords = visibleTo(session, productionServices);
  const music = visibleTo(session, musicListings);
  const stock = visibleTo(session, stockFootageListings);
  return {
    license_listings: licenses.length,
    distribution_targets: visibleTo(session, distributionListings).length,
    service_listings: creatorServiceRecords.length + productionServiceRecords.length,
    music_listings: music.length,
    stock_footage_listings: stock.length,
    available_records: [
      ...licenses,
      ...creatorServiceRecords,
      ...productionServiceRecords,
      ...music,
      ...stock
    ].filter(isAvailableListing).length
  };
}

function isAvailableListing(record: unknown): boolean {
  if (!isRecord(record)) return false;
  return record.status === "available" || record.availability === "available";
}

function optionalString(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "string" && body[key].trim().length > 0 ? body[key].trim() : null;
}

function positiveInteger(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(1, Math.floor(body[key]));
}

function marketplaceStatus(value: string | null): MarketplaceStatus {
  if (value === "review" || value === "reserved") return value;
  return "available";
}

function rightsScope(value: string | null): LicenseListingRecord["rights_scope"] {
  if (value === "streaming" || value === "education" || value === "airline") return value;
  return "festival";
}

function distributionTarget(value: string | null): DistributionListingRecord["target"] {
  if (value === "highfive" || value === "partner" || value === "education") return value;
  return "premiere";
}

function readiness(value: string | null): DistributionListingRecord["readiness"] {
  return value === "needs_review" ? "needs_review" : "ready";
}

function creatorServiceType(value: string | null): CreatorServiceRecord["service_type"] {
  if (value === "editing" || value === "metadata" || value === "marketing" || value === "consulting") return value;
  return "poster";
}

function productionServiceType(value: string | null): ProductionServiceRecord["service_type"] {
  if (value === "crew" || value === "location" || value === "equipment" || value === "post") return value;
  return "sound";
}

function musicMood(value: string | null): MusicListingRecord["mood"] {
  if (value === "tense" || value === "warm" || value === "ambient") return value;
  return "cinematic";
}

function musicLicenseScope(value: string | null): MusicListingRecord["license_scope"] {
  if (value === "feature" || value === "series" || value === "promo") return value;
  return "trailer";
}

function stockCategory(value: string | null): StockFootageRecord["category"] {
  if (value === "nature" || value === "studio" || value === "texture" || value === "aerial") return value;
  return "city";
}

function stockResolution(value: string | null): StockFootageRecord["resolution"] {
  if (value === "HD" || value === "8K") return value;
  return "4K";
}

function stockLicenseScope(value: string | null): StockFootageRecord["license_scope"] {
  if (value === "commercial" || value === "internal") return value;
  return "editorial";
}

function trimmed(value: string, limit: number): string {
  const clean = value.trim();
  return clean.length <= limit ? clean : clean.slice(0, limit).trim();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}

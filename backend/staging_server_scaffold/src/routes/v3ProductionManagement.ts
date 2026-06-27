import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { requireCreatorIdentitySession, type IdentitySession } from "./identity.js";

type ProductionStatus = "planning" | "active" | "review" | "complete";

type FilmRecord = {
  id: string;
  creator_id: string;
  title: string;
  project_id: string;
  status: ProductionStatus;
  format: "feature" | "short" | "documentary";
  created_at: string;
  updated_at: string;
};

type SeriesRecord = {
  id: string;
  creator_id: string;
  title: string;
  project_id: string;
  status: ProductionStatus;
  season_count: number;
  episode_count: number;
  created_at: string;
  updated_at: string;
};

type ProductionProjectRecord = {
  id: string;
  creator_id: string;
  title: string;
  linked_content_id: string;
  phase: "development" | "production" | "post" | "release";
  status: ProductionStatus;
  created_at: string;
  updated_at: string;
};

type ScheduleRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  title: string;
  schedule_type: "shoot" | "edit" | "review" | "release";
  window_label: string;
  status: ProductionStatus;
  created_at: string;
  updated_at: string;
};

type BudgetRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  category: "production" | "post" | "marketing" | "distribution";
  planned_amount: number;
  committed_amount: number;
  status: "draft" | "review" | "locked";
  created_at: string;
  updated_at: string;
};

type CrewRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  name: string;
  role: "director" | "producer" | "writer" | "editor" | "composer" | "marketing" | "crew";
  status: "invited" | "active" | "complete";
  created_at: string;
  updated_at: string;
};

type ProductionAssetRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  title: string;
  asset_type: "script" | "poster" | "trailer" | "cut" | "audio" | "still";
  status: ProductionStatus;
  owner: string;
  created_at: string;
  updated_at: string;
};

const films: FilmRecord[] = [];
const series: SeriesRecord[] = [];
const projects: ProductionProjectRecord[] = [];
const schedules: ScheduleRecord[] = [];
const budgets: BudgetRecord[] = [];
const crew: CrewRecord[] = [];
const assets: ProductionAssetRecord[] = [];

let filmCounter = 1;
let seriesCounter = 1;
let projectCounter = 1;
let scheduleCounter = 1;
let budgetCounter = 1;
let crewCounter = 1;
let assetCounter = 1;

seedProductionManagement();

export function v3ProductionReadinessSummary(): JsonObject {
  return {
    v3_production_management_enabled: true,
    films: true,
    series: true,
    projects: true,
    production_schedules: true,
    budgets: true,
    crew: true,
    assets: true,
    external_services: false,
    production_projects: projects.length,
    production_assets: assets.length
  };
}

export function v3ProductionSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const creatorID = creatorIDFor(session);
  return {
    status: "ready",
    production: "local_v3_production_management",
    external_services: false,
    creator_id: creatorID,
    films: films.filter((record) => visibleTo(session, record.creator_id)),
    series: series.filter((record) => visibleTo(session, record.creator_id)),
    projects: projects.filter((record) => visibleTo(session, record.creator_id)),
    schedules: schedules.filter((record) => visibleTo(session, record.creator_id)),
    budgets: budgets.filter((record) => visibleTo(session, record.creator_id)),
    crew: crew.filter((record) => visibleTo(session, record.creator_id)),
    assets: assets.filter((record) => visibleTo(session, record.creator_id)),
    dashboard: productionDashboard(creatorID),
    generated_at: nowISO()
  };
}

export function createProductionFilm(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const record: FilmRecord = {
    id: `production-film-${filmCounter++}`,
    creator_id: creatorIDFor(session),
    title: trimmed(optionalString(body, "title") ?? "Untitled Film", 160),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    status: productionStatus(optionalString(body, "status")),
    format: filmFormat(optionalString(body, "format")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  films.push(record);
  return { status: "created", film: record };
}

export function createProductionSeries(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const record: SeriesRecord = {
    id: `production-series-${seriesCounter++}`,
    creator_id: creatorIDFor(session),
    title: trimmed(optionalString(body, "title") ?? "Untitled Series", 160),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    status: productionStatus(optionalString(body, "status")),
    season_count: positiveInteger(body, "season_count", 1),
    episode_count: positiveInteger(body, "episode_count", 6),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  series.push(record);
  return { status: "created", series: record };
}

export function createProductionProject(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const record: ProductionProjectRecord = {
    id: `production-project-${projectCounter++}`,
    creator_id: creatorIDFor(session),
    title: trimmed(optionalString(body, "title") ?? "Production Project", 160),
    linked_content_id: optionalString(body, "content_id") ?? defaultContentID(session),
    phase: productionPhase(optionalString(body, "phase")),
    status: productionStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  projects.push(record);
  return { status: "created", project: record };
}

export function createProductionSchedule(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const record: ScheduleRecord = {
    id: `production-schedule-${scheduleCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    title: trimmed(optionalString(body, "title") ?? "Production review window", 160),
    schedule_type: scheduleType(optionalString(body, "schedule_type")),
    window_label: trimmed(optionalString(body, "window_label") ?? "This production window", 120),
    status: productionStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  schedules.push(record);
  return { status: "created", schedule: record };
}

export function createProductionBudget(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const planned = positiveNumber(body, "planned_amount", 10000);
  const record: BudgetRecord = {
    id: `production-budget-${budgetCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    category: budgetCategory(optionalString(body, "category")),
    planned_amount: planned,
    committed_amount: Math.min(positiveNumber(body, "committed_amount", 0), planned),
    status: budgetStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  budgets.push(record);
  return { status: "created", budget: record, budget_summary: budgetSummary(creatorIDFor(session)) };
}

export function createProductionCrew(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const record: CrewRecord = {
    id: `production-crew-${crewCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    name: trimmed(optionalString(body, "name") ?? "Crew Member", 120),
    role: crewRole(optionalString(body, "role")),
    status: crewStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  crew.push(record);
  return { status: "created", crew_member: record };
}

export function createProductionAsset(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireProductionSession(authorizationHeader);
  const record: ProductionAssetRecord = {
    id: `production-asset-${assetCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    title: trimmed(optionalString(body, "title") ?? "Production asset", 160),
    asset_type: assetType(optionalString(body, "asset_type")),
    status: productionStatus(optionalString(body, "status")),
    owner: trimmed(optionalString(body, "owner") ?? session.display_name, 120),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  assets.push(record);
  return { status: "created", asset: record };
}

function seedProductionManagement(): void {
  if (projects.length > 0) return;
  const creatorID = "maya-hart";
  const projectID = "project-behind-the-vision";
  films.push({
    id: "production-film-seed-1",
    creator_id: creatorID,
    title: "Behind the Vision",
    project_id: projectID,
    status: "active",
    format: "documentary",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  series.push({
    id: "production-series-seed-1",
    creator_id: creatorID,
    title: "Studio Notes",
    project_id: projectID,
    status: "planning",
    season_count: 1,
    episode_count: 4,
    created_at: nowISO(),
    updated_at: nowISO()
  });
  projects.push({
    id: "production-project-seed-1",
    creator_id: creatorID,
    title: "Behind the Vision Production",
    linked_content_id: "behind-the-vision",
    phase: "post",
    status: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  schedules.push({
    id: "production-schedule-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    title: "Creator review window",
    schedule_type: "review",
    window_label: "Launch prep week",
    status: "review",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  budgets.push({
    id: "production-budget-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    category: "post",
    planned_amount: 18000,
    committed_amount: 12250,
    status: "review",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  crew.push({
    id: "production-crew-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    name: "Local Editor",
    role: "editor",
    status: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  assets.push({
    id: "production-asset-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    title: "Opening sequence cut",
    asset_type: "cut",
    status: "review",
    owner: "Local Editor",
    created_at: nowISO(),
    updated_at: nowISO()
  });
}

function requireProductionSession(authorizationHeader: string | undefined): IdentitySession {
  return requireCreatorIdentitySession(authorizationHeader);
}

function creatorIDFor(session: IdentitySession): string {
  return session.creator_id ?? catalogSeed.creators[0]?.id ?? "maya-hart";
}

function visibleTo(session: IdentitySession, creatorID: string): boolean {
  return session.role === "admin" || session.creator_id === creatorID;
}

function defaultProjectID(session: IdentitySession): string {
  return catalogSeed.publishing_projects.find((project) => project.creator_id === creatorIDFor(session))?.id ??
    catalogSeed.publishing_projects[0]?.id ??
    "project-behind-the-vision";
}

function defaultContentID(session: IdentitySession): string {
  return catalogSeed.publishing_projects.find((project) => project.creator_id === creatorIDFor(session))?.content_id ??
    catalogSeed.movies.find((movie) => movie.creator_id === creatorIDFor(session))?.id ??
    "behind-the-vision";
}

function productionDashboard(creatorID: string): JsonObject {
  return {
    active_projects: projects.filter((record) => record.creator_id === creatorID && record.status !== "complete").length,
    schedule_windows: schedules.filter((record) => record.creator_id === creatorID && record.status !== "complete").length,
    crew_active: crew.filter((record) => record.creator_id === creatorID && record.status === "active").length,
    assets_in_review: assets.filter((record) => record.creator_id === creatorID && record.status === "review").length,
    budget_summary: budgetSummary(creatorID)
  };
}

function budgetSummary(creatorID: string): JsonObject {
  const records = budgets.filter((record) => record.creator_id === creatorID);
  const planned = records.reduce((total, record) => total + record.planned_amount, 0);
  const committed = records.reduce((total, record) => total + record.committed_amount, 0);
  return {
    planned_amount: planned,
    committed_amount: committed,
    remaining_preview: planned - committed,
    utilization_percent: planned > 0 ? Math.round((committed / planned) * 100) : 0
  };
}

function optionalString(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "string" && body[key].trim().length > 0 ? body[key].trim() : null;
}

function positiveInteger(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(1, Math.floor(body[key]));
}

function positiveNumber(body: unknown, key: string, fallback: number): number {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return fallback;
  return Math.max(0, Math.round(body[key] * 100) / 100);
}

function productionStatus(value: string | null): ProductionStatus {
  if (value === "active" || value === "review" || value === "complete") return value;
  return "planning";
}

function filmFormat(value: string | null): FilmRecord["format"] {
  if (value === "short" || value === "documentary") return value;
  return "feature";
}

function productionPhase(value: string | null): ProductionProjectRecord["phase"] {
  if (value === "production" || value === "post" || value === "release") return value;
  return "development";
}

function scheduleType(value: string | null): ScheduleRecord["schedule_type"] {
  if (value === "shoot" || value === "edit" || value === "release") return value;
  return "review";
}

function budgetCategory(value: string | null): BudgetRecord["category"] {
  if (value === "production" || value === "marketing" || value === "distribution") return value;
  return "post";
}

function budgetStatus(value: string | null): BudgetRecord["status"] {
  if (value === "review" || value === "locked") return value;
  return "draft";
}

function crewRole(value: string | null): CrewRecord["role"] {
  if (value === "director" || value === "producer" || value === "writer" || value === "editor" || value === "composer" || value === "marketing") return value;
  return "crew";
}

function crewStatus(value: string | null): CrewRecord["status"] {
  if (value === "active" || value === "complete") return value;
  return "invited";
}

function assetType(value: string | null): ProductionAssetRecord["asset_type"] {
  if (value === "script" || value === "poster" || value === "trailer" || value === "audio" || value === "still") return value;
  return "cut";
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

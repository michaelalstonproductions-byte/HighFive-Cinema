import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { requireCreatorIdentitySession, type IdentitySession } from "./identity.js";

type CRMStatus = "open" | "in_progress" | "review" | "complete";

type InboxRecord = {
  id: string;
  creator_id: string;
  from: string;
  subject: string;
  category: "partner" | "studio" | "crew" | "distribution";
  status: "unread" | "read" | "archived";
  related_project_id: string | null;
  created_at: string;
};

type ContractRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  partner_name: string;
  contract_type: "distribution" | "collaboration" | "services" | "license_preview";
  status: "draft" | "review" | "approved_preview";
  value_preview: string;
  created_at: string;
  updated_at: string;
};

type TaskRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  title: string;
  owner: string;
  status: CRMStatus;
  priority: "low" | "medium" | "high";
  due_label: string;
  created_at: string;
  updated_at: string;
};

type MilestoneRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  title: string;
  status: CRMStatus;
  target_label: string;
  created_at: string;
  updated_at: string;
};

type TeamRecord = {
  id: string;
  creator_id: string;
  name: string;
  members: { name: string; role: string; permission: "owner" | "edit" | "review" | "view" }[];
  created_at: string;
  updated_at: string;
};

type DeliverableRecord = {
  id: string;
  creator_id: string;
  project_id: string;
  title: string;
  kind: "poster" | "trailer" | "metadata" | "cut" | "campaign";
  status: CRMStatus;
  owner: string;
  created_at: string;
  updated_at: string;
};

const inboxRecords: InboxRecord[] = [];
const contractRecords: ContractRecord[] = [];
const taskRecords: TaskRecord[] = [];
const milestoneRecords: MilestoneRecord[] = [];
const teamRecords: TeamRecord[] = [];
const deliverableRecords: DeliverableRecord[] = [];

let inboxCounter = 1;
let contractCounter = 1;
let taskCounter = 1;
let milestoneCounter = 1;
let teamCounter = 1;
let deliverableCounter = 1;

seedCreatorCRM();

export function v3CreatorCRMReadinessSummary(): JsonObject {
  return {
    v3_creator_crm_enabled: true,
    creator_inbox: true,
    contracts: true,
    tasks: true,
    milestones: true,
    teams: true,
    deliverables: true,
    external_services: false,
    inbox_records: inboxRecords.length,
    task_records: taskRecords.length
  };
}

export function v3CreatorCRMSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const creatorID = creatorIDFor(session);
  return {
    status: "ready",
    crm: "local_v3_creator_crm",
    external_services: false,
    creator_id: creatorID,
    inbox: inboxRecords.filter((record) => visibleTo(session, record.creator_id)),
    contracts: contractRecords.filter((record) => visibleTo(session, record.creator_id)),
    tasks: taskRecords.filter((record) => visibleTo(session, record.creator_id)),
    milestones: milestoneRecords.filter((record) => visibleTo(session, record.creator_id)),
    teams: teamRecords.filter((record) => visibleTo(session, record.creator_id)),
    deliverables: deliverableRecords.filter((record) => visibleTo(session, record.creator_id)),
    dashboard: crmDashboard(creatorID),
    generated_at: nowISO()
  };
}

export function createCreatorCRMInboxRecord(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const record: InboxRecord = {
    id: `crm-inbox-${inboxCounter++}`,
    creator_id: creatorIDFor(session),
    from: trimmed(optionalString(body, "from") ?? "HighFive Studio", 120),
    subject: trimmed(optionalString(body, "subject") ?? "Creator update", 160),
    category: inboxCategory(optionalString(body, "category")),
    status: "unread",
    related_project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    created_at: nowISO()
  };
  inboxRecords.push(record);
  return { status: "created", inbox_record: record };
}

export function createCreatorCRMContract(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const record: ContractRecord = {
    id: `crm-contract-${contractCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    partner_name: trimmed(optionalString(body, "partner_name") ?? "HighFive Distribution", 140),
    contract_type: contractType(optionalString(body, "contract_type")),
    status: "draft",
    value_preview: trimmed(optionalString(body, "value_preview") ?? "Local planning only", 120),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  contractRecords.push(record);
  return { status: "created", contract: record };
}

export function createCreatorCRMTask(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const record: TaskRecord = {
    id: `crm-task-${taskCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    title: trimmed(optionalString(body, "title") ?? "Review creator project", 160),
    owner: trimmed(optionalString(body, "owner") ?? session.display_name, 120),
    status: crmStatus(optionalString(body, "status")),
    priority: priority(optionalString(body, "priority")),
    due_label: trimmed(optionalString(body, "due_label") ?? "This week", 80),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  taskRecords.push(record);
  return { status: "created", task: record, task_board: taskBoard(creatorIDFor(session)) };
}

export function createCreatorCRMMilestone(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const record: MilestoneRecord = {
    id: `crm-milestone-${milestoneCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    title: trimmed(optionalString(body, "title") ?? "Release package ready", 160),
    status: crmStatus(optionalString(body, "status")),
    target_label: trimmed(optionalString(body, "target_label") ?? "Next release window", 120),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  milestoneRecords.push(record);
  return { status: "created", milestone: record };
}

export function createCreatorCRMTeam(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const record: TeamRecord = {
    id: `crm-team-${teamCounter++}`,
    creator_id: creatorIDFor(session),
    name: trimmed(optionalString(body, "name") ?? `${session.display_name} Team`, 120),
    members: teamMembers(body, session),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  teamRecords.push(record);
  return { status: "created", team: record };
}

export function createCreatorCRMDeliverable(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCRMSession(authorizationHeader);
  const record: DeliverableRecord = {
    id: `crm-deliverable-${deliverableCounter++}`,
    creator_id: creatorIDFor(session),
    project_id: optionalString(body, "project_id") ?? defaultProjectID(session),
    title: trimmed(optionalString(body, "title") ?? "Poster package", 160),
    kind: deliverableKind(optionalString(body, "kind")),
    status: crmStatus(optionalString(body, "status")),
    owner: trimmed(optionalString(body, "owner") ?? session.display_name, 120),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  deliverableRecords.push(record);
  return { status: "created", deliverable: record };
}

function seedCreatorCRM(): void {
  if (inboxRecords.length > 0) return;
  const creatorID = "maya-hart";
  const projectID = "project-behind-the-vision";
  inboxRecords.push({
    id: "crm-inbox-seed-1",
    creator_id: creatorID,
    from: "HighFive Distribution",
    subject: "Premiere package review notes",
    category: "distribution",
    status: "unread",
    related_project_id: projectID,
    created_at: nowISO()
  });
  contractRecords.push({
    id: "crm-contract-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    partner_name: "HighFive Distribution",
    contract_type: "distribution",
    status: "review",
    value_preview: "Preview window planning",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  taskRecords.push({
    id: "crm-task-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    title: "Confirm trailer clearance notes",
    owner: "Maya Hart",
    status: "in_progress",
    priority: "high",
    due_label: "Before review",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  milestoneRecords.push({
    id: "crm-milestone-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    title: "Creator package review",
    status: "review",
    target_label: "Launch prep",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  teamRecords.push({
    id: "crm-team-seed-1",
    creator_id: creatorID,
    name: "Maya Hart Studio",
    members: [
      { name: "Maya Hart", role: "Director", permission: "owner" },
      { name: "Local Producer", role: "Producer", permission: "edit" }
    ],
    created_at: nowISO(),
    updated_at: nowISO()
  });
  deliverableRecords.push({
    id: "crm-deliverable-seed-1",
    creator_id: creatorID,
    project_id: projectID,
    title: "Premiere poster set",
    kind: "poster",
    status: "review",
    owner: "Local Producer",
    created_at: nowISO(),
    updated_at: nowISO()
  });
}

function requireCRMSession(authorizationHeader: string | undefined): IdentitySession {
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

function crmDashboard(creatorID: string): JsonObject {
  return {
    unread_inbox: inboxRecords.filter((record) => record.creator_id === creatorID && record.status === "unread").length,
    open_tasks: taskRecords.filter((record) => record.creator_id === creatorID && record.status !== "complete").length,
    active_contracts: contractRecords.filter((record) => record.creator_id === creatorID && record.status !== "approved_preview").length,
    pending_deliverables: deliverableRecords.filter((record) => record.creator_id === creatorID && record.status !== "complete").length,
    task_board: taskBoard(creatorID)
  };
}

function taskBoard(creatorID: string): JsonObject {
  const records = taskRecords.filter((record) => record.creator_id === creatorID);
  return {
    open: records.filter((record) => record.status === "open"),
    in_progress: records.filter((record) => record.status === "in_progress"),
    review: records.filter((record) => record.status === "review"),
    complete: records.filter((record) => record.status === "complete")
  };
}

function optionalString(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "string" && body[key].trim().length > 0 ? body[key].trim() : null;
}

function teamMembers(body: unknown, session: IdentitySession): TeamRecord["members"] {
  if (!isRecord(body) || !Array.isArray(body.members)) {
    return [{ name: session.display_name, role: "Owner", permission: "owner" }];
  }
  return body.members
    .filter((member): member is Record<string, unknown> => isRecord(member))
    .map((member) => ({
      name: trimmed(typeof member.name === "string" ? member.name : "Team Member", 120),
      role: trimmed(typeof member.role === "string" ? member.role : "Contributor", 80),
      permission: teamPermission(typeof member.permission === "string" ? member.permission : null)
    }))
    .slice(0, 12);
}

function inboxCategory(value: string | null): InboxRecord["category"] {
  if (value === "partner" || value === "studio" || value === "crew" || value === "distribution") return value;
  return "studio";
}

function contractType(value: string | null): ContractRecord["contract_type"] {
  if (value === "distribution" || value === "collaboration" || value === "services" || value === "license_preview") return value;
  return "collaboration";
}

function crmStatus(value: string | null): CRMStatus {
  if (value === "in_progress" || value === "review" || value === "complete") return value;
  return "open";
}

function priority(value: string | null): TaskRecord["priority"] {
  if (value === "low" || value === "high") return value;
  return "medium";
}

function deliverableKind(value: string | null): DeliverableRecord["kind"] {
  if (value === "trailer" || value === "metadata" || value === "cut" || value === "campaign") return value;
  return "poster";
}

function teamPermission(value: string | null): TeamRecord["members"][number]["permission"] {
  if (value === "edit" || value === "review" || value === "view") return value;
  return "owner";
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

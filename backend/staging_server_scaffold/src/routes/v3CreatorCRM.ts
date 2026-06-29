import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { requireCreatorIdentitySession, requireIdentitySession, type IdentitySession } from "./identity.js";

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

type ContactLinkTarget = "project" | "studio" | "creator" | "distribution_deal";

type ContactLink = {
  target_type: ContactLinkTarget;
  target_id: string;
  relationship: string;
  created_at: string;
};

type CompanyRecord = {
  id: string;
  name: string;
  type: string;
  email: string | null;
  phone: string | null;
  linkedin: string | null;
  source_url: string | null;
  tags: string[];
  notes: string;
  private_scope: "admin";
  created_at: string;
  updated_at: string;
};

type ContactRecord = {
  id: string;
  full_name: string;
  company_id: string | null;
  company_name: string | null;
  role: string;
  roles: string[];
  department: string | null;
  email: string | null;
  phone: string | null;
  linkedin: string | null;
  imdb: string | null;
  representative: string | null;
  agency: string | null;
  manager: string | null;
  priority: "P1" | "P2" | "P3" | "unranked";
  relationship_status: string;
  outreach_status: string;
  last_contacted: string | null;
  follow_up_date: string | null;
  tags: string[];
  location: string | null;
  notes: string;
  links: ContactLink[];
  private_scope: "admin";
  created_at: string;
  updated_at: string;
};

const inboxRecords: InboxRecord[] = [];
const contractRecords: ContractRecord[] = [];
const taskRecords: TaskRecord[] = [];
const milestoneRecords: MilestoneRecord[] = [];
const teamRecords: TeamRecord[] = [];
const deliverableRecords: DeliverableRecord[] = [];
const companyRecords: CompanyRecord[] = [];
const contactRecords: ContactRecord[] = [];

let inboxCounter = 1;
let contractCounter = 1;
let taskCounter = 1;
let milestoneCounter = 1;
let teamCounter = 1;
let deliverableCounter = 1;
let companyCounter = 1;
let contactCounter = 1;

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
    private_contact_database: true,
    admin_only_contacts: true,
    companies: true,
    contact_roles: true,
    csv_import: true,
    contact_search_filters: true,
    linked_contact_targets: ["projects", "studios", "creators", "distribution_deals"],
    automatic_email_sending: false,
    external_services: false,
    inbox_records: inboxRecords.length,
    task_records: taskRecords.length,
    contact_records: contactRecords.length,
    company_records: companyRecords.length
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
    private_contact_database: session.role === "admin"
      ? contactDatabaseSummary()
      : { access: "admin_required", public_exposure: false },
    dashboard: crmDashboard(creatorID),
    generated_at: nowISO()
  };
}

export function v3CreatorCRMContacts(authorizationHeader: string | undefined, rawURL: string | undefined): JsonObject {
  requireAdminCRMSession(authorizationHeader);
  const url = new URL(rawURL ?? "/v3/creator-crm/contacts", "http://127.0.0.1");
  const q = normalized(url.searchParams.get("q"));
  const company = normalized(url.searchParams.get("company"));
  const role = normalized(url.searchParams.get("role"));
  const tag = normalized(url.searchParams.get("tag"));
  const relationshipStatus = normalized(url.searchParams.get("relationship_status"));
  const outreachStatus = normalized(url.searchParams.get("outreach_status"));
  const priorityParam = normalized(url.searchParams.get("priority"));
  const limit = boundedInteger(url.searchParams.get("limit"), 100, 1, 500);
  const records = contactRecords.filter((record) => {
    const haystack = normalized([
      record.full_name,
      record.company_name,
      record.role,
      record.department,
      record.email,
      record.phone,
      record.linkedin,
      record.imdb,
      record.representative,
      record.agency,
      record.manager,
      record.location,
      record.notes,
      record.tags.join(" ")
    ].filter(Boolean).join(" "));
    if (q && !haystack.includes(q)) return false;
    if (company && !normalized(record.company_name).includes(company)) return false;
    if (role && !normalized(record.roles.join(" ")).includes(role) && !normalized(record.role).includes(role)) return false;
    if (tag && !record.tags.some((candidate) => normalized(candidate) === tag)) return false;
    if (relationshipStatus && normalized(record.relationship_status) !== relationshipStatus) return false;
    if (outreachStatus && normalized(record.outreach_status) !== outreachStatus) return false;
    if (priorityParam && normalized(record.priority) !== priorityParam) return false;
    return true;
  });
  return {
    status: "ready",
    access: "admin_only",
    public_exposure: false,
    external_services: false,
    automatic_email_sending: false,
    total_contacts: contactRecords.length,
    matched_contacts: records.length,
    contacts: records.slice(0, limit)
  };
}

export function createCreatorCRMContact(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAdminCRMSession(authorizationHeader);
  const contact = contactFromInput(body);
  contactRecords.push(contact);
  return {
    status: "created",
    access: "admin_only",
    public_exposure: false,
    contact
  };
}

export function v3CreatorCRMCompanies(authorizationHeader: string | undefined, rawURL: string | undefined): JsonObject {
  requireAdminCRMSession(authorizationHeader);
  const url = new URL(rawURL ?? "/v3/creator-crm/companies", "http://127.0.0.1");
  const q = normalized(url.searchParams.get("q"));
  const type = normalized(url.searchParams.get("type"));
  const records = companyRecords.filter((record) => {
    const haystack = normalized([record.name, record.type, record.email, record.phone, record.linkedin, record.notes, record.tags.join(" ")].filter(Boolean).join(" "));
    if (q && !haystack.includes(q)) return false;
    if (type && normalized(record.type) !== type) return false;
    return true;
  });
  return {
    status: "ready",
    access: "admin_only",
    public_exposure: false,
    external_services: false,
    total_companies: companyRecords.length,
    matched_companies: records.length,
    companies: records
  };
}

export function createCreatorCRMCompany(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAdminCRMSession(authorizationHeader);
  const company = companyFromInput(body);
  companyRecords.push(company);
  return {
    status: "created",
    access: "admin_only",
    public_exposure: false,
    company
  };
}

export function importCreatorCRMContactsCSV(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAdminCRMSession(authorizationHeader);
  const csvText = optionalString(body, "csv_text") ?? optionalString(body, "csv");
  if (!csvText) {
    const error = new Error("csv_text_required");
    error.name = "BadCRMImportRequest";
    throw error;
  }
  const rows = parseCSV(csvText);
  if (rows.length < 2) {
    return {
      status: "import_skipped",
      access: "admin_only",
      public_exposure: false,
      imported_contacts: 0,
      imported_companies: 0,
      skipped_rows: 0
    };
  }
  const headers = rows[0].map((header) => normalizedHeader(header));
  const startingCompanyCount = companyRecords.length;
  let importedContacts = 0;
  let skippedRows = 0;
  for (const row of rows.slice(1, 10001)) {
    const mapped = rowObject(headers, row);
    const fullName = firstValue(mapped, ["full_name", "name"]);
    if (!fullName) {
      skippedRows += 1;
      continue;
    }
    const companyName = firstValue(mapped, ["company", "contact_org_rep", "matched_org_rep", "matched_org", "agency", "talent_agency"]);
    const company = companyName ? ensureCompany(companyName, {
      type: firstValue(mapped, ["company_type", "matched_org_type", "org_type"]) ?? "Contact Organization",
      email: firstValue(mapped, ["org_email"]),
      phone: firstValue(mapped, ["org_phone"]),
      linkedin: firstValue(mapped, ["org_linkedin"]),
      source_url: firstValue(mapped, ["source_url", "public_source_url"]),
      notes: firstValue(mapped, ["research_notes", "notes"]) ?? ""
    }) : null;
    contactRecords.push(contactFromInput({
      full_name: fullName,
      company_id: company?.id,
      company_name: company?.name ?? companyName,
      role: firstValue(mapped, ["role", "role_profession"]),
      department: firstValue(mapped, ["department"]),
      email: firstValue(mapped, ["email", "emails", "best_email"]),
      phone: firstValue(mapped, ["phone", "phones", "best_phone"]),
      linkedin: firstValue(mapped, ["linkedin", "linkedin_url"]),
      imdb: firstValue(mapped, ["imdb", "imdbpro_url"]),
      representative: firstValue(mapped, ["representative", "contact_org_rep", "best_outreach_route"]),
      agency: firstValue(mapped, ["agency", "talent_agency"]),
      manager: firstValue(mapped, ["manager", "management"]),
      priority: firstValue(mapped, ["priority"]),
      relationship_status: relationshipStatus(firstValue(mapped, ["relationship_status", "status"])),
      outreach_status: outreachStatus(firstValue(mapped, ["outreach_status", "contacted", "lookup_status", "lookup_status_original"])),
      last_contacted: firstValue(mapped, ["last_contacted"]),
      follow_up_date: firstValue(mapped, ["follow_up_date"]),
      tags: firstValue(mapped, ["tags"]),
      location: firstValue(mapped, ["location", "country"]),
      notes: [
        firstValue(mapped, ["notes"]),
        firstValue(mapped, ["original_notes"]),
        firstValue(mapped, ["research_notes"]),
        firstValue(mapped, ["contact_confidence"])
      ].filter(Boolean).join(" | ")
    }));
    importedContacts += 1;
  }
  return {
    status: "imported",
    access: "admin_only",
    public_exposure: false,
    external_services: false,
    automatic_email_sending: false,
    imported_contacts: importedContacts,
    imported_companies: companyRecords.length - startingCompanyCount,
    skipped_rows: skippedRows,
    total_contacts: contactRecords.length,
    total_companies: companyRecords.length
  };
}

export function linkCreatorCRMContact(authorizationHeader: string | undefined, body: unknown): JsonObject {
  requireAdminCRMSession(authorizationHeader);
  const contactID = optionalString(body, "contact_id");
  const contact = contactRecords.find((record) => record.id === contactID);
  if (!contact) {
    const error = new Error("contact_not_found");
    error.name = "NotFoundCRMContact";
    throw error;
  }
  const link: ContactLink = {
    target_type: contactLinkTarget(optionalString(body, "target_type")),
    target_id: trimmed(optionalString(body, "target_id") ?? "unknown-target", 160),
    relationship: trimmed(optionalString(body, "relationship") ?? "Related contact", 120),
    created_at: nowISO()
  };
  contact.links.push(link);
  contact.updated_at = nowISO();
  return {
    status: "linked",
    access: "admin_only",
    public_exposure: false,
    contact
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

function requireAdminCRMSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "admin") {
    const error = new Error("admin_role_required");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  return session;
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

function contactDatabaseSummary(): JsonObject {
  return {
    access: "admin_only",
    public_exposure: false,
    contacts: contactRecords.length,
    companies: companyRecords.length,
    csv_import: true,
    search_filters: ["q", "company", "role", "tag", "relationship_status", "outreach_status", "priority"],
    linked_targets: ["project", "studio", "creator", "distribution_deal"],
    automatic_email_sending: false,
    external_services: false
  };
}

function contactFromInput(body: unknown): ContactRecord {
  const companyName = optionalString(body, "company_name") ?? optionalString(body, "company");
  const companyID = optionalString(body, "company_id");
  const role = trimmed(optionalString(body, "role") ?? "Contact", 160);
  const now = nowISO();
  return {
    id: `crm-contact-${contactCounter++}`,
    full_name: trimmed(optionalString(body, "full_name") ?? optionalString(body, "name") ?? "Unnamed Contact", 160),
    company_id: companyID ?? companyByName(companyName)?.id ?? null,
    company_name: companyName ?? companyRecords.find((company) => company.id === companyID)?.name ?? null,
    role,
    roles: contactRoles(optionalString(body, "roles") ?? role),
    department: optionalString(body, "department"),
    email: optionalString(body, "email"),
    phone: optionalString(body, "phone"),
    linkedin: optionalString(body, "linkedin"),
    imdb: optionalString(body, "imdb") ?? optionalString(body, "imdb_url"),
    representative: optionalString(body, "representative"),
    agency: optionalString(body, "agency"),
    manager: optionalString(body, "manager"),
    priority: contactPriority(optionalString(body, "priority")),
    relationship_status: relationshipStatus(optionalString(body, "relationship_status")),
    outreach_status: outreachStatus(optionalString(body, "outreach_status")),
    last_contacted: optionalString(body, "last_contacted"),
    follow_up_date: optionalString(body, "follow_up_date"),
    tags: tagsFrom(optionalString(body, "tags")),
    location: optionalString(body, "location"),
    notes: trimmed(optionalString(body, "notes") ?? "", 2000),
    links: [],
    private_scope: "admin",
    created_at: now,
    updated_at: now
  };
}

function companyFromInput(body: unknown): CompanyRecord {
  const now = nowISO();
  return {
    id: `crm-company-${companyCounter++}`,
    name: trimmed(optionalString(body, "name") ?? optionalString(body, "company") ?? "Unnamed Company", 180),
    type: trimmed(optionalString(body, "type") ?? "Company", 120),
    email: optionalString(body, "email"),
    phone: optionalString(body, "phone"),
    linkedin: optionalString(body, "linkedin"),
    source_url: optionalString(body, "source_url"),
    tags: tagsFrom(optionalString(body, "tags")),
    notes: trimmed(optionalString(body, "notes") ?? "", 2000),
    private_scope: "admin",
    created_at: now,
    updated_at: now
  };
}

function ensureCompany(name: string, input: Partial<CompanyRecord>): CompanyRecord {
  const existing = companyByName(name);
  if (existing) return existing;
  const company = companyFromInput({
    name,
    type: input.type,
    email: input.email,
    phone: input.phone,
    linkedin: input.linkedin,
    source_url: input.source_url,
    notes: input.notes
  });
  companyRecords.push(company);
  return company;
}

function companyByName(name: string | null | undefined): CompanyRecord | null {
  if (!name) return null;
  const match = normalized(name);
  return companyRecords.find((company) => normalized(company.name) === match) ?? null;
}

function contactRoles(value: string | null): string[] {
  const raw = value ?? "";
  const roles = raw
    .split(/[,/;|]/)
    .map((role) => trimmed(role, 80))
    .filter((role) => role.length > 0);
  return roles.length > 0 ? Array.from(new Set(roles)).slice(0, 12) : ["Contact"];
}

function contactPriority(value: string | null): ContactRecord["priority"] {
  const clean = (value ?? "").trim().toUpperCase();
  if (clean === "P1" || clean === "1" || clean === "HIGH") return "P1";
  if (clean === "P2" || clean === "2" || clean === "MEDIUM") return "P2";
  if (clean === "P3" || clean === "3" || clean === "LOW") return "P3";
  return "unranked";
}

function relationshipStatus(value: string | null): string {
  const clean = normalizedLabel(value);
  if (["introduced", "meeting_scheduled", "loi_sent", "investor", "studio", "distributor", "talent", "producer", "director", "writer", "casting", "press", "partner"].includes(clean)) {
    return clean;
  }
  return "never_contacted";
}

function outreachStatus(value: string | null): string {
  const clean = normalizedLabel(value);
  if (clean === "yes" || clean === "contacted") return "contacted";
  if (["never_contacted", "introduced", "meeting_scheduled", "loi_sent", "email_sent", "call_logged", "follow_up_due", "do_not_contact"].includes(clean)) return clean;
  return "never_contacted";
}

function contactLinkTarget(value: string | null): ContactLinkTarget {
  if (value === "studio" || value === "creator" || value === "distribution_deal") return value;
  return "project";
}

function parseCSV(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let cell = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];
    if (char === "\"") {
      if (quoted && next === "\"") {
        cell += "\"";
        index += 1;
      } else {
        quoted = !quoted;
      }
    } else if (char === "," && !quoted) {
      row.push(cell.trim());
      cell = "";
    } else if ((char === "\n" || char === "\r") && !quoted) {
      if (char === "\r" && next === "\n") index += 1;
      row.push(cell.trim());
      if (row.some((value) => value.length > 0)) rows.push(row);
      row = [];
      cell = "";
    } else {
      cell += char;
    }
  }
  row.push(cell.trim());
  if (row.some((value) => value.length > 0)) rows.push(row);
  return rows;
}

function rowObject(headers: string[], row: string[]): Record<string, string> {
  const result: Record<string, string> = {};
  headers.forEach((header, index) => {
    result[header] = row[index]?.trim() ?? "";
  });
  return result;
}

function firstValue(record: Record<string, string>, keys: string[]): string | null {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === "string" && value.trim().length > 0) return value.trim();
  }
  return null;
}

function normalizedHeader(value: string): string {
  return normalizedLabel(value)
    .replace(/emails/g, "email")
    .replace(/phones/g, "phone")
    .replace(/profession/g, "role_profession")
    .replace(/imdbpro/g, "imdbpro");
}

function normalizedLabel(value: string | null | undefined): string {
  return normalized(value).replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "");
}

function normalized(value: string | null | undefined): string {
  return (value ?? "").trim().toLowerCase();
}

function tagsFrom(value: string | null): string[] {
  if (!value) return [];
  return Array.from(new Set(value.split(/[,;|]/).map((tag) => trimmed(tag, 60)).filter((tag) => tag.length > 0))).slice(0, 24);
}

function boundedInteger(value: string | null, fallback: number, min: number, max: number): number {
  const parsed = Number.parseInt(value ?? "", 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(max, Math.max(min, parsed));
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

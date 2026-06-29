import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    creatorID: result.json.session.creator_id
  };
}

test("v3 creator CRM: readiness exposes local CRM capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_creator_crm_enabled, true);
  assert.equal(ready.json.v3_creator_crm_inbox, true);
  assert.equal(ready.json.v3_creator_crm_contracts, true);
  assert.equal(ready.json.v3_creator_crm_tasks, true);
  assert.equal(ready.json.v3_creator_crm_milestones, true);
  assert.equal(ready.json.v3_creator_crm_teams, true);
  assert.equal(ready.json.v3_creator_crm_deliverables, true);
  assert.equal(ready.json.v3_creator_crm_private_contact_database, true);
  assert.equal(ready.json.v3_creator_crm_admin_only_contacts, true);
  assert.equal(ready.json.v3_creator_crm_companies, true);
  assert.equal(ready.json.v3_creator_crm_contact_roles, true);
  assert.equal(ready.json.v3_creator_crm_csv_import, true);
  assert.equal(ready.json.v3_creator_crm_contact_search_filters, true);
  assert.equal(ready.json.v3_creator_crm_automatic_email_sending, false);
  assert.equal(ready.json.v3_creator_crm_external_services, false);
  assert.ok(ready.json.v3_creator_crm_inbox_records >= 1);
  assert.ok(ready.json.v3_creator_crm_task_records >= 1);
});

test("v3 creator CRM: summary returns seeded inbox, contracts, tasks, teams, and deliverables", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/creator-crm/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.crm, "local_v3_creator_crm");
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.creator_id, creator.creatorID);
  assert.ok(summary.json.inbox.some((record) => record.id === "crm-inbox-seed-1"));
  assert.ok(summary.json.contracts.some((record) => record.id === "crm-contract-seed-1"));
  assert.ok(summary.json.tasks.some((record) => record.id === "crm-task-seed-1"));
  assert.ok(summary.json.teams.some((record) => record.id === "crm-team-seed-1"));
  assert.ok(summary.json.deliverables.some((record) => record.id === "crm-deliverable-seed-1"));
  assert.ok(summary.json.dashboard.open_tasks >= 1);
  assertNoCredentialMaterial(summary.json);
});

test("v3 creator CRM: creator can create inbox, contract, task, milestone, team, and deliverable records", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const inbox = await postJson("/v3/creator-crm/inbox", {
    from: "Local Producer",
    subject: "Campaign notes ready",
    category: "crew",
    project_id: "project-behind-the-vision"
  }, headers);
  assertJsonResponse(inbox, 201);
  assert.equal(inbox.json.inbox_record.category, "crew");

  const contract = await postJson("/v3/creator-crm/contracts", {
    project_id: "project-behind-the-vision",
    partner_name: "HighFive Studio Services",
    contract_type: "services",
    value_preview: "Local services planning"
  }, headers);
  assertJsonResponse(contract, 201);
  assert.equal(contract.json.contract.contract_type, "services");

  const task = await postJson("/v3/creator-crm/tasks", {
    project_id: "project-behind-the-vision",
    title: "Send trailer notes to editor",
    owner: "Maya Hart",
    status: "in_progress",
    priority: "high",
    due_label: "Tomorrow"
  }, headers);
  assertJsonResponse(task, 201);
  assert.equal(task.json.task.priority, "high");
  assert.ok(task.json.task_board.in_progress.some((record) => record.id === task.json.task.id));

  const milestone = await postJson("/v3/creator-crm/milestones", {
    project_id: "project-behind-the-vision",
    title: "Creator review locked",
    status: "review",
    target_label: "Release prep"
  }, headers);
  assertJsonResponse(milestone, 201);
  assert.equal(milestone.json.milestone.status, "review");

  const team = await postJson("/v3/creator-crm/teams", {
    name: "Release Team",
    members: [
      { name: "Maya Hart", role: "Director", permission: "owner" },
      { name: "Local Editor", role: "Editor", permission: "edit" }
    ]
  }, headers);
  assertJsonResponse(team, 201);
  assert.equal(team.json.team.members.length, 2);

  const deliverable = await postJson("/v3/creator-crm/deliverables", {
    project_id: "project-behind-the-vision",
    title: "Final trailer cut",
    kind: "trailer",
    status: "review",
    owner: "Local Editor"
  }, headers);
  assertJsonResponse(deliverable, 201);
  assert.equal(deliverable.json.deliverable.kind, "trailer");

  const summary = await requestJson("/v3/creator-crm/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.inbox.some((record) => record.id === inbox.json.inbox_record.id));
  assert.ok(summary.json.contracts.some((record) => record.id === contract.json.contract.id));
  assert.ok(summary.json.milestones.some((record) => record.id === milestone.json.milestone.id));
  assert.ok(summary.json.deliverables.some((record) => record.id === deliverable.json.deliverable.id));
});

test("v3 creator CRM: admin-only contact database imports CSV, searches, and links private contacts", async () => {
  const admin = await session("admin");
  const headers = { authorization: admin.authorization };

  const company = await postJson("/v3/creator-crm/companies", {
    name: "Netflix",
    type: "Studio",
    email: "studio-relations@example.invalid",
    phone: "+1 310 000 0000",
    linkedin: "https://www.linkedin.com/company/netflix",
    tags: "Studio, Distributor",
    notes: "Internal relationship record only."
  }, headers);
  assertJsonResponse(company, 201);
  assert.equal(company.json.company.private_scope, "admin");

  const contact = await postJson("/v3/creator-crm/contacts", {
    full_name: "Jordan Sample",
    company_name: "Netflix",
    role: "Producer, Studio Executive",
    department: "Original Film",
    email: "jordan.sample@example.invalid",
    phone: "+1 310 555 0100",
    linkedin: "https://www.linkedin.com/in/jordan-sample",
    imdb: "https://pro.imdb.com/name/nm0000000",
    representative: "Internal introduction",
    agency: "HighFive Cinema",
    manager: "HigherKey",
    priority: "P1",
    relationship_status: "Introduced",
    outreach_status: "Meeting Scheduled",
    last_contacted: "2026-06-28",
    follow_up_date: "2026-07-05",
    tags: "Investor Deck, Studio Deals, Distribution",
    location: "Los Angeles",
    notes: "Private admin-only contact. Do not email automatically."
  }, headers);
  assertJsonResponse(contact, 201);
  assert.equal(contact.json.contact.private_scope, "admin");
  assert.deepEqual(contact.json.contact.roles, ["Producer", "Studio Executive"]);
  assert.equal(contact.json.contact.outreach_status, "meeting_scheduled");

  const imported = await postJson("/v3/creator-crm/contacts/import-csv", {
    csv_text: [
      "Full Name,Company,Role,Department,Email,Phone,LinkedIn,IMDb,Representative,Agency,Manager,Priority,Status,Tags,Location,Notes,Follow-up Date",
      "Avery Distributor,Sony Pictures,Distributor,Acquisitions,avery@example.invalid,+1 212 555 0101,https://www.linkedin.com/in/avery-distributor,https://pro.imdb.com/name/nm1111111,Intro via HigherKey,HighFive Cinema,HigherKey,P1,LOI Sent,\"Distribution,Mark of the West\",New York,\"Private distribution lead\",2026-07-10"
    ].join("\n")
  }, headers);
  assertJsonResponse(imported, 201);
  assert.equal(imported.json.imported_contacts, 1);
  assert.equal(imported.json.automatic_email_sending, false);
  assert.equal(imported.json.external_services, false);

  const search = await requestJson("/v3/creator-crm/contacts?q=producer&company=netflix&tag=Studio%20Deals", { headers });
  assertJsonResponse(search, 200);
  assert.equal(search.json.access, "admin_only");
  assert.equal(search.json.public_exposure, false);
  assert.ok(search.json.contacts.some((record) => record.full_name === "Jordan Sample"));

  const linked = await postJson("/v3/creator-crm/contacts/link", {
    contact_id: contact.json.contact.id,
    target_type: "distribution_deal",
    target_id: "deal-mark-of-the-west-domestic",
    relationship: "Potential distribution conversation"
  }, headers);
  assertJsonResponse(linked, 201);
  assert.equal(linked.json.contact.links[0].target_type, "distribution_deal");

  const companies = await requestJson("/v3/creator-crm/companies?q=sony", { headers });
  assertJsonResponse(companies, 200);
  assert.ok(companies.json.companies.some((record) => record.name === "Sony Pictures"));

  const summary = await requestJson("/v3/creator-crm/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.private_contact_database.access, "admin_only");
  assert.ok(summary.json.private_contact_database.contacts >= 2);
  assert.equal(summary.json.private_contact_database.automatic_email_sending, false);
  assertNoCredentialMaterial(summary.json);
});

test("v3 creator CRM: viewer cannot access creator CRM", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v3/creator-crm/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "creator_role_required");

  const task = await postJson("/v3/creator-crm/tasks", {
    title: "Viewer task"
  }, { authorization: viewer.authorization });
  assertJsonResponse(task, 403);
  assert.equal(task.json.error, "creator_role_required");
});

test("v3 creator CRM: private contacts are admin-only", async () => {
  const creator = await session("creator");
  const creatorContacts = await requestJson("/v3/creator-crm/contacts", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(creatorContacts, 403);
  assert.equal(creatorContacts.json.error, "admin_role_required");

  const viewer = await session("viewer");
  const viewerImport = await postJson("/v3/creator-crm/contacts/import-csv", {
    csv_text: "Full Name,Company\nBlocked Viewer,HighFive"
  }, { authorization: viewer.authorization });
  assertJsonResponse(viewerImport, 403);
  assert.equal(viewerImport.json.error, "admin_role_required");
});

test("v3 creator CRM: OpenAPI exposes CRM paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/creator-crm/summary"]);
  assert.ok(spec.json.paths["/v3/creator-crm/inbox"]);
  assert.ok(spec.json.paths["/v3/creator-crm/contracts"]);
  assert.ok(spec.json.paths["/v3/creator-crm/tasks"]);
  assert.ok(spec.json.paths["/v3/creator-crm/milestones"]);
  assert.ok(spec.json.paths["/v3/creator-crm/teams"]);
  assert.ok(spec.json.paths["/v3/creator-crm/deliverables"]);
  assert.ok(spec.json.paths["/v3/creator-crm/contacts"]);
  assert.ok(spec.json.paths["/v3/creator-crm/companies"]);
  assert.ok(spec.json.paths["/v3/creator-crm/contacts/import-csv"]);
  assert.ok(spec.json.paths["/v3/creator-crm/contacts/link"]);
});

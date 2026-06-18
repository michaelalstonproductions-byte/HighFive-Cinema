export type AuditEventName =
  | "entitlement_validation_requested"
  | "entitlement_validation_denied"
  | "entitlement_validation_approved"
  | "playback_descriptor_requested"
  | "playback_descriptor_unavailable"
  | "playback_descriptor_issued";

export type AuditRecord = {
  audit_id: string;
  event_name: AuditEventName;
  movie_id: string;
  storekit_product_id: string;
  created_at: string;
  detail: string;
};

let auditCounter = 0;
const auditRecords: AuditRecord[] = [];

export async function createAuditRecord(input: {
  event_name: AuditEventName;
  movie_id: string;
  storekit_product_id: string;
  detail: string;
}): Promise<AuditRecord> {
  auditCounter += 1;
  const record = {
    audit_id: `audit-${input.movie_id}-${auditCounter}`,
    event_name: input.event_name,
    movie_id: input.movie_id,
    storekit_product_id: input.storekit_product_id,
    created_at: new Date().toISOString(),
    detail: input.detail
  };
  auditRecords.push(record);
  return record;
}

export function findAuditRecord(auditID: string): AuditRecord | undefined {
  return auditRecords.find((record) => record.audit_id === auditID);
}

export function listAuditRecords(): readonly AuditRecord[] {
  return auditRecords;
}

export function resetAuditRecordsForContractTests(): void {
  auditCounter = 0;
  auditRecords.length = 0;
}

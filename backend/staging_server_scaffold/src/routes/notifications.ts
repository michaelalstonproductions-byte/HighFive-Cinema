import type { JsonObject } from "../contracts.js";
import { isRecord } from "../contracts.js";
import { type IdentityRole, type IdentitySession, requireIdentitySession } from "./identity.js";

type NotificationCategory =
  | "publishing"
  | "creator"
  | "processing"
  | "release"
  | "series"
  | "episode"
  | "collaboration"
  | "revenue"
  | "upload"
  | "system";

type DeviceEnvironment = "development" | "production" | "simulator";

type DeviceRegistration = {
  id: string;
  user_id: string;
  role: IdentityRole;
  device_token_suffix: string;
  platform: string;
  environment: DeviceEnvironment;
  push_enabled: boolean;
  registered_at: string;
  updated_at: string;
};

type NotificationPreference = {
  id: string;
  user_id: string;
  category: NotificationCategory;
  push_enabled: boolean;
  inbox_enabled: boolean;
  updated_at: string;
};

type NotificationInboxItem = {
  id: string;
  user_id: string;
  category: NotificationCategory;
  title: string;
  body: string;
  deep_link: string;
  is_read: boolean;
  created_at: string;
  delivery_status: "queued" | "development_delivered" | "push_disabled";
};

type NotificationDeliveryAudit = {
  id: string;
  notification_id: string;
  user_id: string;
  device_id: string | null;
  category: NotificationCategory;
  delivery_status: string;
  provider: "apns_contract" | "local_development";
  detail: string;
  created_at: string;
};

const devices = new Map<string, DeviceRegistration>();
const preferences = new Map<string, NotificationPreference>();
const inbox: NotificationInboxItem[] = [];
const deliveryAudit: NotificationDeliveryAudit[] = [];
let deviceCounter = 1;
let notificationCounter = 1;
let auditCounter = 1;

const defaultCategories: NotificationCategory[] = [
  "publishing",
  "creator",
  "processing",
  "release",
  "series",
  "episode",
  "collaboration",
  "revenue",
  "upload",
  "system"
];

export function registerNotificationDevice(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  if (!isRecord(body)) throw badRequest("notification_device_body_required");
  const token = stringField(body, "device_token");
  const platform = optionalStringField(body, "platform") ?? "ios";
  const environment = environmentField(body.environment);
  if (!token || token.length < 8) throw badRequest("valid_device_token_required");

  const id = `notification-device-${deviceCounter++}`;
  const existing = [...devices.values()].find((device) => device.user_id === session.user_id && device.device_token_suffix === tokenSuffix(token));
  const record: DeviceRegistration = {
    id: existing?.id ?? id,
    user_id: session.user_id,
    role: session.role,
    device_token_suffix: tokenSuffix(token),
    platform,
    environment,
    push_enabled: true,
    registered_at: existing?.registered_at ?? nowISO(),
    updated_at: nowISO()
  };
  devices.set(record.id, record);
  ensurePreferences(session);
  return {
    status: "device_registered",
    device: record,
    apns_contract_ready: true,
    detail: "Device token suffix registered. Full APNs token is never persisted in this staging runtime."
  };
}

export function notificationPreferences(authorizationHeader: string | undefined, body?: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  ensurePreferences(session);
  if (body !== undefined) updatePreferences(session, body);
  return {
    status: "preferences_ready",
    preferences: [...preferences.values()].filter((preference) => preference.user_id === session.user_id)
  };
}

export function notificationInbox(authorizationHeader: string | undefined): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  seedInboxIfNeeded(session);
  const items = inbox
    .filter((item) => item.user_id === session.user_id)
    .sort((a, b) => Date.parse(b.created_at) - Date.parse(a.created_at));
  return {
    status: "inbox_ready",
    unread_count: items.filter((item) => !item.is_read).length,
    notifications: items
  };
}

export function markNotificationRead(authorizationHeader: string | undefined, id: string): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  const item = inbox.find((notification) => notification.id === id && notification.user_id === session.user_id);
  if (!item) throw notFound("notification_not_found");
  item.is_read = true;
  recordAudit(item, session, null, "read", "Notification marked read.");
  return {
    status: "read",
    notification: item,
    unread_count: inbox.filter((notification) => notification.user_id === session.user_id && !notification.is_read).length
  };
}

export function sendTestNotification(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  if (!isRecord(body)) throw badRequest("notification_body_required");
  const category = categoryField(body.category);
  const notification = createNotification({
    session,
    category,
    title: optionalStringField(body, "title") ?? titleForCategory(category),
    body: optionalStringField(body, "body") ?? "HighFive product event delivered through the notification pipeline.",
    deepLink: optionalStringField(body, "deep_link") ?? deepLinkForCategory(category)
  });
  return {
    status: notification.delivery_status,
    notification,
    delivery_audit: deliveryAudit.slice(-5)
  };
}

export function notificationDeliveryAudit(authorizationHeader: string | undefined): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  return {
    status: "audit_ready",
    delivery_audit: deliveryAudit.filter((record) => record.user_id === session.user_id).slice(-25)
  };
}

export function recordProductNotification(input: {
  userID?: string | null;
  role?: IdentityRole;
  category: NotificationCategory;
  title: string;
  body: string;
  deepLink?: string;
}): NotificationInboxItem {
  const userID = input.userID ?? userForRole(input.role ?? "creator");
  const session: IdentitySession = {
    session_id: "system-notification",
    user_id: userID,
    display_name: "HighFive System",
    email: null,
    role: input.role ?? "creator",
    creator_id: input.role === "viewer" ? null : "maya-hart",
    workspace_id: input.role === "viewer" ? "watch-workspace" : "creator-workspace",
    provider: "development",
    issued_at: nowISO(),
    expires_at: nowISO()
  };
  return createNotification({
    session,
    category: input.category,
    title: input.title,
    body: input.body,
    deepLink: input.deepLink ?? deepLinkForCategory(input.category)
  });
}

export function notificationReadinessSummary(): JsonObject {
  const categoryCounts = defaultCategories.reduce<Record<string, number>>((counts, category) => {
    counts[category] = inbox.filter((item) => item.category === category).length;
    return counts;
  }, {});

  return {
    notifications_enabled: true,
    apns_contract_ready: true,
    push_contract: true,
    device_registration: true,
    preferences: true,
    inbox: true,
    in_app_inbox: true,
    deep_links: true,
    delivery_audit: true,
    read_state: true,
    publishing_events: true,
    creator_events: true,
    series_events: true,
    system_events: true,
    permission_denied_fallback: true,
    categories: defaultCategories,
    category_counts: categoryCounts,
    registered_devices: devices.size,
    inbox_items: inbox.length,
    delivery_events: deliveryAudit.length,
    external_push_attempted: false
  };
}

function createNotification(input: {
  session: IdentitySession;
  category: NotificationCategory;
  title: string;
  body: string;
  deepLink: string;
}): NotificationInboxItem {
  ensurePreferences(input.session);
  const preference = preferences.get(preferenceID(input.session.user_id, input.category));
  const device = [...devices.values()].find((record) => record.user_id === input.session.user_id && record.push_enabled);
  const deliveryStatus = preference?.push_enabled === false ? "push_disabled" : device ? "development_delivered" : "queued";
  const notification: NotificationInboxItem = {
    id: `notification-${notificationCounter++}`,
    user_id: input.session.user_id,
    category: input.category,
    title: sanitizeText(input.title, 96),
    body: sanitizeText(input.body, 220),
    deep_link: input.deepLink,
    is_read: false,
    created_at: nowISO(),
    delivery_status: deliveryStatus
  };
  if (preference?.inbox_enabled !== false) inbox.push(notification);
  trimCollections();
  recordAudit(notification, input.session, device ?? null, deliveryStatus, deliveryDetail(deliveryStatus));
  return notification;
}

function updatePreferences(session: IdentitySession, body: unknown): void {
  if (!isRecord(body)) throw badRequest("notification_preferences_body_required");
  const updates = Array.isArray(body.preferences) ? body.preferences : [body];
  for (const update of updates) {
    if (!isRecord(update)) continue;
    const category = categoryField(update.category);
    const id = preferenceID(session.user_id, category);
    const existing = preferences.get(id) ?? defaultPreference(session.user_id, category);
    preferences.set(id, {
      ...existing,
      push_enabled: booleanField(update.push_enabled, existing.push_enabled),
      inbox_enabled: booleanField(update.inbox_enabled, existing.inbox_enabled),
      updated_at: nowISO()
    });
  }
}

function seedInboxIfNeeded(session: IdentitySession): void {
  if (inbox.some((item) => item.user_id === session.user_id)) return;
  createNotification({
    session,
    category: "publishing",
    title: "Publishing review update",
    body: "A creator project has a review update ready in HighFive.",
    deepLink: "highfive://creator/publishing"
  });
  createNotification({
    session,
    category: "creator",
    title: "Creator workspace update",
    body: "A creator profile, project, or collaboration update is ready for review.",
    deepLink: "highfive://creator/workspace"
  });
  createNotification({
    session,
    category: "processing",
    title: "Media processing complete",
    body: "A source asset has a processing completion event available.",
    deepLink: "highfive://creator/processing"
  });
  createNotification({
    session,
    category: "episode",
    title: "New episode available",
    body: "Series continuity can open the next episode path.",
    deepLink: "highfive://series/next"
  });
  createNotification({
    session,
    category: "series",
    title: "Series activity update",
    body: "A season, episode, or continuity event is ready in the series workspace.",
    deepLink: "highfive://series"
  });
  createNotification({
    session,
    category: "system",
    title: "HighFive system notice",
    body: "The notification center is available even when external push delivery is not configured.",
    deepLink: "highfive://notifications/system"
  });
}

function ensurePreferences(session: IdentitySession): void {
  for (const category of defaultCategories) {
    const id = preferenceID(session.user_id, category);
    if (!preferences.has(id)) preferences.set(id, defaultPreference(session.user_id, category));
  }
}

function defaultPreference(userID: string, category: NotificationCategory): NotificationPreference {
  return {
    id: preferenceID(userID, category),
    user_id: userID,
    category,
    push_enabled: true,
    inbox_enabled: true,
    updated_at: nowISO()
  };
}

function recordAudit(
  notification: NotificationInboxItem,
  session: IdentitySession,
  device: DeviceRegistration | null,
  deliveryStatus: string,
  detail: string
): void {
  deliveryAudit.push({
    id: `notification-audit-${auditCounter++}`,
    notification_id: notification.id,
    user_id: session.user_id,
    device_id: device?.id ?? null,
    category: notification.category,
    delivery_status: deliveryStatus,
    provider: device ? "apns_contract" : "local_development",
    detail,
    created_at: nowISO()
  });
  trimCollections();
}

function trimCollections(): void {
  if (inbox.length > 200) inbox.splice(0, inbox.length - 200);
  if (deliveryAudit.length > 200) deliveryAudit.splice(0, deliveryAudit.length - 200);
}

function categoryField(value: unknown): NotificationCategory {
  return isCategory(value) ? value : "system";
}

function isCategory(value: unknown): value is NotificationCategory {
  return typeof value === "string" && defaultCategories.includes(value as NotificationCategory);
}

function environmentField(value: unknown): DeviceEnvironment {
  return value === "production" || value === "simulator" ? value : "development";
}

function stringField(body: JsonObject, key: string): string | null {
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function optionalStringField(body: JsonObject, key: string): string | null {
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function booleanField(value: unknown, fallback: boolean): boolean {
  return typeof value === "boolean" ? value : fallback;
}

function tokenSuffix(token: string): string {
  return token.replace(/[^A-Za-z0-9]/g, "").slice(-12);
}

function preferenceID(userID: string, category: NotificationCategory): string {
  return `${userID}:${category}`;
}

function userForRole(role: IdentityRole): string {
  if (role === "admin") return "user-admin";
  if (role === "viewer") return "user-viewer";
  return "user-creator";
}

function titleForCategory(category: NotificationCategory): string {
  switch (category) {
  case "publishing": return "Publishing review update";
  case "creator": return "Creator workspace update";
  case "processing": return "Processing complete";
  case "release": return "Release publication update";
  case "series": return "Series activity update";
  case "episode": return "New episode available";
  case "collaboration": return "Collaboration update";
  case "revenue": return "Revenue milestone";
  case "upload": return "Upload update";
  case "system": return "HighFive notification";
  }
}

function deepLinkForCategory(category: NotificationCategory): string {
  switch (category) {
  case "publishing": return "highfive://creator/publishing";
  case "creator": return "highfive://creator/workspace";
  case "processing": return "highfive://creator/processing";
  case "release": return "highfive://content/release";
  case "series": return "highfive://series";
  case "episode": return "highfive://series/next";
  case "collaboration": return "highfive://creator/collaboration";
  case "revenue": return "highfive://creator/revenue";
  case "upload": return "highfive://creator/uploads";
  case "system": return "highfive://notifications";
  }
}

function deliveryDetail(status: string): string {
  if (status === "development_delivered") return "Development APNs contract accepted by registered local device token.";
  if (status === "push_disabled") return "Push preference disabled; item remains available in the in-app inbox.";
  return "No registered device token; item queued in the in-app inbox.";
}

function sanitizeText(value: string, maxLength: number): string {
  return value.replace(/(?:token|secret|api[_-]?key|client_secret|access_token|refresh_token)/gi, "redacted").slice(0, maxLength);
}

function badRequest(message: string): Error {
  const error = new Error(message);
  error.name = "BadRequest";
  return error;
}

function notFound(message: string): Error {
  const error = new Error(message);
  error.name = "NotFound";
  return error;
}

function nowISO(): string {
  return new Date().toISOString();
}

import Foundation
import Security

protocol HFAuthService {
    func currentAccount() async -> HFAccountIdentity?
    func currentStatus(localProfile: HFLocalViewingProfile) -> HFAuthRuntimeStatus
    func signOut() async throws
}

struct HFAuthConfiguration: Equatable {
    static let providerKey = "HIGHFIVE_AUTH_PROVIDER"
    static let modeKey = "HIGHFIVE_AUTH_MODE"
    static let baseURLKey = "HIGHFIVE_AUTH_BASE_URL"
    static let clientIDKey = "HIGHFIVE_AUTH_CLIENT_ID"

    let requestedProvider: String?
    let requestedMode: String?
    let authBaseURL: String?
    let clientID: String?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        requestedProvider = Self.nonEmpty(environment[Self.providerKey])
        requestedMode = Self.nonEmpty(environment[Self.modeKey])
        authBaseURL = Self.nonEmpty(environment[Self.baseURLKey])
        clientID = Self.nonEmpty(environment[Self.clientIDKey])
    }

    var hasAnyRuntimeConfig: Bool {
        requestedProvider != nil || requestedMode != nil || authBaseURL != nil || clientID != nil
    }

    var hasCompleteRuntimeConfig: Bool {
        authBaseURL != nil && clientID != nil && (requestedProvider != nil || requestedMode != nil)
    }

    var providerStatus: HFAuthProviderStatus {
        guard hasAnyRuntimeConfig else { return .localAccountMode }
        return hasCompleteRuntimeConfig ? .authConfigured : .missingAuthCredentials
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

enum HFAccountProvider: String, Codable, Equatable {
    case local
    case staging
    case custom
}

enum HFSessionState: String, Codable, Equatable {
    case local
    case signedOut

    var statusLabel: String {
        switch self {
        case .local:
            return "Session Local"
        case .signedOut:
            return "Session Signed Out"
        }
    }

    var detail: String {
        switch self {
        case .local:
            return "Local profile fallback is active on this device."
        case .signedOut:
            return "No live auth session is active."
        }
    }
}

enum HFAuthProviderStatus: String, Codable, Equatable {
    case localAccountMode
    case authNotConnected
    case missingAuthCredentials
    case authConfigured

    var statusLabel: String {
        switch self {
        case .localAccountMode:
            return "Local Account Mode"
        case .authNotConnected:
            return "Auth Not Connected Yet"
        case .missingAuthCredentials:
            return "Missing Auth Credentials"
        case .authConfigured:
            return "Auth Configured"
        }
    }

    var detail: String {
        switch self {
        case .localAccountMode:
            return "Missing auth config keeps account identity local."
        case .authNotConnected:
            return "Auth Not Connected Yet. No live sign-in provider is active."
        case .missingAuthCredentials:
            return "Missing Auth Credentials. Complete runtime config is required before staging auth can be evaluated."
        case .authConfigured:
            return "Auth Configured. Remote auth adapter is ready for staging validation, but no live login is performed."
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .localAccountMode:
            return "hf.account.localMode"
        case .authNotConnected:
            return "hf.account.notConnected"
        case .missingAuthCredentials:
            return "hf.account.credentialsMissing"
        case .authConfigured:
            return "hf.account.configured"
        }
    }
}

struct HFAccountIdentity: Codable, Identifiable, Equatable {
    let id: String
    let provider: HFAccountProvider
    let displayName: String
    let email: String?
}

struct HFAccountDeletionRequest: Codable, Identifiable, Equatable {
    let id: String
    let accountID: String
    let statusLabel: String
    let detail: String

    static func local(accountID: String) -> HFAccountDeletionRequest {
        HFAccountDeletionRequest(
            id: "delete-\(accountID)",
            accountID: accountID,
            statusLabel: "Delete Account Not Connected Yet",
            detail: "Deletion workflow waits for live account ownership, provider policy, and backend audit support."
        )
    }
}

struct HFAccountExportRequest: Codable, Identifiable, Equatable {
    let id: String
    let accountID: String
    let statusLabel: String
    let detail: String

    static func local(accountID: String) -> HFAccountExportRequest {
        HFAccountExportRequest(
            id: "export-\(accountID)",
            accountID: accountID,
            statusLabel: "Export Account Not Connected Yet",
            detail: "Export workflow waits for live account records, retention policy, and backend packaging support."
        )
    }
}

struct HFSignInRequirement: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let statusLabel: String
    let detail: String
}

struct HFAppleSignInRequirementNote: Codable, Equatable {
    let title: String
    let statusLabel: String
    let detail: String

    static let pending = HFAppleSignInRequirementNote(
        title: "Sign in with Apple",
        statusLabel: "Sign in with Apple requirement pending",
        detail: "Apple review requirements must be resolved before third-party account creation ships."
    )
}

struct HFAuthRuntimeStatus: Codable, Equatable {
    let providerStatus: HFAuthProviderStatus
    let sessionState: HFSessionState
    let accountIdentity: HFAccountIdentity?
    let signInRequirement: HFSignInRequirement
    let appleRequirementNote: HFAppleSignInRequirementNote
    let deletionRequest: HFAccountDeletionRequest
    let exportRequest: HFAccountExportRequest

    var statusLabel: String {
        providerStatus.statusLabel
    }

    var detail: String {
        providerStatus.detail
    }
}

struct HFLocalAuthAdapter: HFAuthService {
    func currentAccount() async -> HFAccountIdentity? {
        HFAccountIdentity(id: "local-profile", provider: .local, displayName: "Local Profile", email: nil)
    }

    func currentStatus(localProfile: HFLocalViewingProfile) -> HFAuthRuntimeStatus {
        let account = HFAccountIdentity(
            id: "local-\(localProfile.id)",
            provider: .local,
            displayName: localProfile.displayName,
            email: nil
        )
        return HFAuthRuntimeStatus(
            providerStatus: .localAccountMode,
            sessionState: .local,
            accountIdentity: account,
            signInRequirement: HFSignInRequirement(
                id: "local-sign-in-readiness",
                title: "Sign-in readiness",
                statusLabel: "Auth Not Connected Yet",
                detail: "Review Account Readiness before enabling a live provider."
            ),
            appleRequirementNote: .pending,
            deletionRequest: .local(accountID: account.id),
            exportRequest: .local(accountID: account.id)
        )
    }

    func signOut() async throws {}
}

struct HFRemoteAuthAdapter: HFAuthService {
    let configuration: HFAuthConfiguration

    func currentAccount() async -> HFAccountIdentity? {
        nil
    }

    func currentStatus(localProfile: HFLocalViewingProfile) -> HFAuthRuntimeStatus {
        guard configuration.hasAnyRuntimeConfig else {
            return HFLocalAuthAdapter().currentStatus(localProfile: localProfile)
        }

        let providerStatus: HFAuthProviderStatus = configuration.hasCompleteRuntimeConfig ? .authConfigured : .missingAuthCredentials
        let accountID = "staging-\(localProfile.id)"
        return HFAuthRuntimeStatus(
            providerStatus: providerStatus,
            sessionState: .signedOut,
            accountIdentity: HFAccountIdentity(
                id: accountID,
                provider: .staging,
                displayName: localProfile.displayName,
                email: nil
            ),
            signInRequirement: HFSignInRequirement(
                id: "staging-sign-in-readiness",
                title: "Sign-in readiness",
                statusLabel: providerStatus == .authConfigured ? "Auth Configured" : "Missing Auth Credentials",
                detail: "Remote auth adapter is config-gated. No OAuth tokens, passwords, or live provider sessions are handled."
            ),
            appleRequirementNote: .pending,
            deletionRequest: .local(accountID: accountID),
            exportRequest: .local(accountID: accountID)
        )
    }

    func signOut() async throws {}
}

enum HFAuthServiceFactory {
    static func make(configuration: HFAuthConfiguration = HFAuthConfiguration()) -> HFAuthService {
        configuration.hasAnyRuntimeConfig ? HFRemoteAuthAdapter(configuration: configuration) : HFLocalAuthAdapter()
    }
}

enum HFIdentityAccessRole: String, Codable, Hashable, CaseIterable {
    case viewer
    case creator
    case admin

    var title: String {
        switch self {
        case .viewer: return "Viewer"
        case .creator: return "Creator"
        case .admin: return "Admin"
        }
    }

    var workspaceTitle: String {
        switch self {
        case .viewer: return "Watch Workspace"
        case .creator: return "Creator Workspace"
        case .admin: return "Administration Workspace"
        }
    }
}

enum HFIdentityAccessRuntimeState: String, Codable, Hashable {
    case signedOut = "Signed Out"
    case localDevelopment = "Development Session"
    case remoteAuthenticated = "Authenticated"
    case expired = "Session Expired"
    case deletionRequested = "Deletion Requested"

    var statusLabel: String { rawValue }
}

struct HFIdentityAccessSession: Identifiable, Codable, Hashable {
    let id: String
    var userID: String
    var displayName: String
    var email: String?
    var provider: String
    var role: HFIdentityAccessRole
    var creatorID: String?
    var workspaceID: String
    var issuedAt: Date
    var expiresAt: Date
    var lastRefreshAt: Date?

    var isExpired: Bool {
        expiresAt <= Date()
    }

    var expiresAtLabel: String {
        Self.shortDateFormatter.string(from: expiresAt)
    }

    static func development(role: HFIdentityAccessRole, profile: HFLocalViewingProfile, creatorID: String?) -> HFIdentityAccessSession {
        let issuedAt = Date()
        return HFIdentityAccessSession(
            id: "hf-dev-\(role.rawValue)-\(profile.id)",
            userID: "user-\(profile.id)",
            displayName: role == .viewer ? profile.displayName : "HighFive Creator",
            email: nil,
            provider: "Development Identity",
            role: role,
            creatorID: role == .viewer ? nil : creatorID,
            workspaceID: role == .viewer ? "watch-workspace" : "creator-workspace",
            issuedAt: issuedAt,
            expiresAt: issuedAt.addingTimeInterval(45 * 60),
            lastRefreshAt: nil
        )
    }

    func refreshed() -> HFIdentityAccessSession {
        let refreshDate = Date()
        var copy = self
        copy.issuedAt = refreshDate
        copy.expiresAt = refreshDate.addingTimeInterval(45 * 60)
        copy.lastRefreshAt = refreshDate
        return copy
    }

    func expiredForQA() -> HFIdentityAccessSession {
        var copy = self
        copy.expiresAt = Date().addingTimeInterval(-60)
        return copy
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

struct HFIdentityAccessRoleCheck: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFIdentityAccessAuditEvent: Identifiable, Codable, Hashable {
    let id: String
    var action: String
    var detail: String
    var createdAt: Date

    var createdAtLabel: String {
        Self.shortDateFormatter.string(from: createdAt)
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

struct HFIdentityAccessRuntimeSnapshot: Codable, Hashable {
    var state: HFIdentityAccessRuntimeState
    var activeSession: HFIdentityAccessSession?
    var roleChecks: [HFIdentityAccessRoleCheck]
    var auditEvents: [HFIdentityAccessAuditEvent]
    var deletionRequestStatus: String
    var appleSignInStatus: String
    var detail: String
    var updatedAtLabel: String

    var statusLabel: String {
        state.statusLabel
    }

    var isAuthenticated: Bool {
        guard let activeSession else { return false }
        return state == .localDevelopment || state == .remoteAuthenticated || state == .deletionRequested && !activeSession.isExpired
    }

    static func signedOut(reason: String) -> HFIdentityAccessRuntimeSnapshot {
        HFIdentityAccessRuntimeSnapshot(
            state: .signedOut,
            activeSession: nil,
            roleChecks: HFIdentityAccessRuntimeSnapshot.roleChecks(for: nil),
            auditEvents: [],
            deletionRequestStatus: "Not Requested",
            appleSignInStatus: "Production capability not configured",
            detail: reason,
            updatedAtLabel: "Signed out"
        )
    }

    static func snapshot(
        state: HFIdentityAccessRuntimeState,
        session: HFIdentityAccessSession?,
        auditEvents: [HFIdentityAccessAuditEvent],
        deletionRequestStatus: String,
        detail: String
    ) -> HFIdentityAccessRuntimeSnapshot {
        HFIdentityAccessRuntimeSnapshot(
            state: state,
            activeSession: session,
            roleChecks: roleChecks(for: session),
            auditEvents: auditEvents,
            deletionRequestStatus: deletionRequestStatus,
            appleSignInStatus: "Sign in with Apple contract ready; production capability setup required",
            detail: detail,
            updatedAtLabel: "Identity runtime refreshed"
        )
    }

    static func roleChecks(for session: HFIdentityAccessSession?) -> [HFIdentityAccessRoleCheck] {
        let role = session?.role
        let canCreate = role == .creator || role == .admin
        return [
            HFIdentityAccessRoleCheck(
                id: "watch",
                title: "Watch",
                detail: "Browse catalog, save titles, and resume playback.",
                status: session == nil ? "Signed Out" : "Allowed",
                systemImage: "play.rectangle.fill"
            ),
            HFIdentityAccessRoleCheck(
                id: "creator",
                title: "Creator Workspace",
                detail: canCreate ? "Creator mutations are available to this session." : "Viewer sessions cannot mutate creator projects.",
                status: canCreate ? "Allowed" : "Denied",
                systemImage: "wand.and.stars"
            ),
            HFIdentityAccessRoleCheck(
                id: "admin",
                title: "Administration",
                detail: role == .admin ? "Administration mutations are available to this session." : "Admin role required for operations mutations.",
                status: role == .admin ? "Allowed" : "Denied",
                systemImage: "checkmark.shield.fill"
            )
        ]
    }
}

final class HFIdentityKeychainSessionStore {
    private let service = "com.highfive.cinema.identity"
    private let account = "active-session"

    func load() -> HFIdentityAccessSession? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(HFIdentityAccessSession.self, from: data)
    }

    func save(_ session: HFIdentityAccessSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        var query = baseQuery()
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            query.merge(attributes) { _, new in new }
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    func delete() {
        SecItemDelete(baseQuery() as CFDictionary)
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

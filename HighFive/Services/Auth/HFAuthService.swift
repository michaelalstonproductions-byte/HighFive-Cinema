import Foundation

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

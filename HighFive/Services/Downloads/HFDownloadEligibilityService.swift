import Foundation

struct HFDownloadConfiguration: Equatable {
    static let modeKey = "HIGHFIVE_DOWNLOADS_MODE"
    static let providerKey = "HIGHFIVE_DOWNLOADS_PROVIDER"
    static let policyBaseURLKey = "HIGHFIVE_DOWNLOAD_POLICY_BASE_URL"
    static let offlineLicenseProviderKey = "HIGHFIVE_OFFLINE_LICENSE_PROVIDER"
    static let storageLimitMBKey = "HIGHFIVE_DOWNLOAD_STORAGE_LIMIT_MB"

    let requestedMode: String?
    let requestedProvider: String?
    let policyBaseURL: String?
    let offlineLicenseProvider: String?
    let storageLimitMB: String?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        requestedMode = Self.nonEmpty(environment[Self.modeKey])
        requestedProvider = Self.nonEmpty(environment[Self.providerKey])
        policyBaseURL = Self.nonEmpty(environment[Self.policyBaseURLKey])
        offlineLicenseProvider = Self.nonEmpty(environment[Self.offlineLicenseProviderKey])
        storageLimitMB = Self.nonEmpty(environment[Self.storageLimitMBKey])
    }

    var hasAnyRuntimeConfig: Bool {
        requestedMode != nil
            || requestedProvider != nil
            || policyBaseURL != nil
            || offlineLicenseProvider != nil
            || storageLimitMB != nil
    }

    var hasCompleteRuntimeConfig: Bool {
        requestedMode != nil
            && requestedProvider != nil
            && policyBaseURL != nil
            && offlineLicenseProvider != nil
            && storageLimitMB != nil
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

enum HFDownloadProviderStatus: String, Codable, Equatable {
    case localOfflinePreview
    case providerNotConnected
    case missingProvider
    case policyConfigured

    var statusLabel: String {
        switch self {
        case .localOfflinePreview:
            return "Offline Preview"
        case .providerNotConnected:
            return "Download Provider Not Connected Yet"
        case .missingProvider:
            return "Download Eligibility Missing Provider"
        case .policyConfigured:
            return "Download policy configured"
        }
    }
}

enum HFDownloadPrerequisite: String, Codable, Equatable, CaseIterable {
    case mediaSourceRequired
    case entitlementRequired
    case licenseRequired
    case storagePolicyRequired

    var statusLabel: String {
        switch self {
        case .mediaSourceRequired:
            return "Media Source Required"
        case .entitlementRequired:
            return "Entitlement Required"
        case .licenseRequired:
            return "License Required"
        case .storagePolicyRequired:
            return "Storage Policy Required"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .mediaSourceRequired:
            return "hf.downloads.mediaSourceRequired"
        case .entitlementRequired:
            return "hf.downloads.entitlementRequired"
        case .licenseRequired:
            return "hf.downloads.licenseRequired"
        case .storagePolicyRequired:
            return "hf.downloads.storagePolicyRequired"
        }
    }
}

enum HFDownloadQueueState: String, Codable, Equatable {
    case localOfflineShelf
    case notQueued
    case unavailable

    var statusLabel: String {
        switch self {
        case .localOfflineShelf:
            return "Local Offline Shelf"
        case .notQueued:
            return "Offline Preview"
        case .unavailable:
            return "Real downloads disabled"
        }
    }
}

enum HFOfflineLicenseState: String, Codable, Equatable {
    case notActive
    case required
    case staged

    var statusLabel: String {
        switch self {
        case .notActive:
            return "Offline license not active"
        case .required:
            return "License Required"
        case .staged:
            return "Download policy configured"
        }
    }
}

enum HFStoragePressureState: String, Codable, Equatable {
    case localPreview
    case policyRequired
    case configured

    var statusLabel: String {
        switch self {
        case .localPreview:
            return "Local offline preview only"
        case .policyRequired:
            return "Storage Policy Required"
        case .configured:
            return "Download policy configured"
        }
    }
}

enum HFDownloadExpirationPolicy: String, Codable, Equatable {
    case required
    case staged

    var statusLabel: String {
        switch self {
        case .required:
            return "Expiration policy required"
        case .staged:
            return "Download policy configured"
        }
    }
}

enum HFDownloadStoragePolicy: String, Codable, Equatable {
    case required
    case localPreviewOnly
    case configured

    var statusLabel: String {
        switch self {
        case .required:
            return "Storage Policy Required"
        case .localPreviewOnly:
            return "Local offline preview only"
        case .configured:
            return "Download policy configured"
        }
    }
}

enum HFOfflineLicensePolicy: String, Codable, Equatable {
    case required
    case notActive
    case configured

    var statusLabel: String {
        switch self {
        case .required:
            return "License Required"
        case .notActive:
            return "Offline license not active"
        case .configured:
            return "Download policy configured"
        }
    }
}

enum HFDownloadActionReadiness: String, Codable, Equatable {
    case reviewOnly
    case unavailable
    case configured

    var statusLabel: String {
        switch self {
        case .reviewOnly:
            return "Review Download Eligibility"
        case .unavailable:
            return "Real downloads disabled"
        case .configured:
            return "Download policy configured"
        }
    }
}

struct HFDownloadProviderBoundary: Codable, Equatable {
    let title: String
    let detail: String

    static let backendMediated = HFDownloadProviderBoundary(
        title: "Backend-mediated downloads only",
        detail: "Real downloads disabled until streaming, entitlement, license, storage, and backend policy are approved."
    )
}

struct HFDownloadPolicy: Codable, Equatable {
    let providerStatus: HFDownloadProviderStatus
    let boundary: HFDownloadProviderBoundary
    let storagePolicy: HFDownloadStoragePolicy
    let licensePolicy: HFOfflineLicensePolicy
    let expirationPolicy: HFDownloadExpirationPolicy
    let actionReadiness: HFDownloadActionReadiness

    static let localPreview = HFDownloadPolicy(
        providerStatus: .localOfflinePreview,
        boundary: .backendMediated,
        storagePolicy: .localPreviewOnly,
        licensePolicy: .notActive,
        expirationPolicy: .required,
        actionReadiness: .unavailable
    )
}

struct HFDownloadQueueRecord: Codable, Identifiable, Equatable {
    let id: String
    let titleID: String
    let title: String
    let queueState: HFDownloadQueueState
    let detail: String
}

struct HFDownloadEligibilityResult: Codable, Equatable {
    let titleID: String
    let statusLabel: String
    let isEligibleForRealDownload: Bool
    let prerequisites: [HFDownloadPrerequisite]
    let policy: HFDownloadPolicy
    let queueRecord: HFDownloadQueueRecord
    let detail: String
}

struct HFDownloadRuntimeStatus: Codable, Equatable {
    let providerStatus: HFDownloadProviderStatus
    let policy: HFDownloadPolicy
    let queueState: HFDownloadQueueState
    let offlineLicenseState: HFOfflineLicenseState
    let storagePressureState: HFStoragePressureState
    let prerequisites: [HFDownloadPrerequisite]
    let detail: String

    var statusLabel: String {
        providerStatus.statusLabel
    }
}

protocol HFDownloadEligibilityService {
    func eligibility(titleID: String, title: String, isInLocalOfflineShelf: Bool) -> HFDownloadEligibilityResult
    func runtimeStatus(localOfflineCount: Int) -> HFDownloadRuntimeStatus
}

struct HFLocalDownloadEligibilityAdapter: HFDownloadEligibilityService {
    func eligibility(titleID: String, title: String, isInLocalOfflineShelf: Bool) -> HFDownloadEligibilityResult {
        let queueState: HFDownloadQueueState = isInLocalOfflineShelf ? .localOfflineShelf : .notQueued
        return HFDownloadEligibilityResult(
            titleID: titleID,
            statusLabel: "Real downloads disabled",
            isEligibleForRealDownload: false,
            prerequisites: HFDownloadPrerequisite.allCases,
            policy: .localPreview,
            queueRecord: HFDownloadQueueRecord(
                id: "download-policy-\(titleID)",
                titleID: titleID,
                title: title,
                queueState: queueState,
                detail: "Local offline preview only"
            ),
            detail: "Offline Preview. Local offline preview only. Real downloads disabled."
        )
    }

    func runtimeStatus(localOfflineCount: Int) -> HFDownloadRuntimeStatus {
        HFDownloadRuntimeStatus(
            providerStatus: .localOfflinePreview,
            policy: .localPreview,
            queueState: localOfflineCount > 0 ? .localOfflineShelf : .notQueued,
            offlineLicenseState: .notActive,
            storagePressureState: .localPreview,
            prerequisites: HFDownloadPrerequisite.allCases,
            detail: "Offline Preview. Local Offline Shelf remains available. Backend-mediated downloads only."
        )
    }
}

struct HFRemoteDownloadPolicyGateway: HFDownloadEligibilityService {
    let configuration: HFDownloadConfiguration
    let streamingStatus: HFPlaybackDescriptorStatus
    let entitlementStatus: HFProductAccessState
    let localFallback: HFLocalDownloadEligibilityAdapter

    init(
        configuration: HFDownloadConfiguration,
        streamingStatus: HFPlaybackDescriptorStatus,
        entitlementStatus: HFProductAccessState,
        localFallback: HFLocalDownloadEligibilityAdapter = HFLocalDownloadEligibilityAdapter()
    ) {
        self.configuration = configuration
        self.streamingStatus = streamingStatus
        self.entitlementStatus = entitlementStatus
        self.localFallback = localFallback
    }

    func eligibility(titleID: String, title: String, isInLocalOfflineShelf: Bool) -> HFDownloadEligibilityResult {
        guard configuration.hasAnyRuntimeConfig else {
            return localFallback.eligibility(titleID: titleID, title: title, isInLocalOfflineShelf: isInLocalOfflineShelf)
        }

        var prerequisites: [HFDownloadPrerequisite] = []
        if streamingStatus != .stagingDescriptorReady {
            prerequisites.append(.mediaSourceRequired)
        }
        if entitlementStatus != .entitlementConfigured {
            prerequisites.append(.entitlementRequired)
        }
        prerequisites.append(.licenseRequired)
        prerequisites.append(.storagePolicyRequired)

        let providerStatus: HFDownloadProviderStatus = configuration.hasCompleteRuntimeConfig ? .policyConfigured : .missingProvider
        let statusLabel = configuration.hasCompleteRuntimeConfig ? "Download policy configured" : "Download Eligibility Missing Provider"
        let policy = HFDownloadPolicy(
            providerStatus: providerStatus,
            boundary: .backendMediated,
            storagePolicy: configuration.storageLimitMB == nil ? .required : .configured,
            licensePolicy: configuration.offlineLicenseProvider == nil ? .required : .configured,
            expirationPolicy: .required,
            actionReadiness: .unavailable
        )

        return HFDownloadEligibilityResult(
            titleID: titleID,
            statusLabel: statusLabel,
            isEligibleForRealDownload: false,
            prerequisites: prerequisites,
            policy: policy,
            queueRecord: HFDownloadQueueRecord(
                id: "download-policy-\(titleID)",
                titleID: titleID,
                title: title,
                queueState: isInLocalOfflineShelf ? .localOfflineShelf : .unavailable,
                detail: "Real downloads disabled"
            ),
            detail: "\(statusLabel). \(policy.boundary.title)."
        )
    }

    func runtimeStatus(localOfflineCount: Int) -> HFDownloadRuntimeStatus {
        guard configuration.hasAnyRuntimeConfig else {
            return localFallback.runtimeStatus(localOfflineCount: localOfflineCount)
        }

        guard configuration.hasCompleteRuntimeConfig else {
            return HFDownloadRuntimeStatus(
                providerStatus: .missingProvider,
                policy: HFDownloadPolicy(
                    providerStatus: .missingProvider,
                    boundary: .backendMediated,
                    storagePolicy: .required,
                    licensePolicy: .required,
                    expirationPolicy: .required,
                    actionReadiness: .unavailable
                ),
                queueState: localOfflineCount > 0 ? .localOfflineShelf : .unavailable,
                offlineLicenseState: .required,
                storagePressureState: .policyRequired,
                prerequisites: HFDownloadPrerequisite.allCases,
                detail: "Download Eligibility Missing Provider. Real downloads disabled."
            )
        }

        return HFDownloadRuntimeStatus(
            providerStatus: .policyConfigured,
            policy: HFDownloadPolicy(
                providerStatus: .policyConfigured,
                boundary: .backendMediated,
                storagePolicy: .configured,
                licensePolicy: .configured,
                expirationPolicy: .required,
                actionReadiness: .unavailable
            ),
            queueState: localOfflineCount > 0 ? .localOfflineShelf : .unavailable,
            offlineLicenseState: .staged,
            storagePressureState: .configured,
            prerequisites: [.mediaSourceRequired, .entitlementRequired, .licenseRequired],
            detail: "Download policy configured. Expiration policy required. Real downloads disabled."
        )
    }
}

enum HFDownloadEligibilityServiceFactory {
    static func make(
        configuration: HFDownloadConfiguration = HFDownloadConfiguration(),
        streamingStatus: HFPlaybackDescriptorStatus = .streamingProviderNotConnected,
        entitlementStatus: HFProductAccessState = .localPreviewAccess
    ) -> HFDownloadEligibilityService {
        configuration.hasAnyRuntimeConfig
            ? HFRemoteDownloadPolicyGateway(
                configuration: configuration,
                streamingStatus: streamingStatus,
                entitlementStatus: entitlementStatus
            )
            : HFLocalDownloadEligibilityAdapter()
    }
}

import Foundation

struct HFLibrarySyncConfiguration: Equatable {
    static let modeKey = "HIGHFIVE_LIBRARY_SYNC_MODE"
    static let baseURLKey = "HIGHFIVE_LIBRARY_SYNC_BASE_URL"
    static let providerKey = "HIGHFIVE_LIBRARY_SYNC_PROVIDER"
    static let userScopeKey = "HIGHFIVE_LIBRARY_SYNC_USER_SCOPE"

    let requestedMode: String?
    let baseURL: String?
    let provider: String?
    let userScope: String?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        requestedMode = Self.nonEmpty(environment[Self.modeKey])
        baseURL = Self.nonEmpty(environment[Self.baseURLKey])
        provider = Self.nonEmpty(environment[Self.providerKey])
        userScope = Self.nonEmpty(environment[Self.userScopeKey])
    }

    var hasAnyRuntimeConfig: Bool {
        requestedMode != nil || baseURL != nil || provider != nil || userScope != nil
    }

    var hasCompleteRuntimeConfig: Bool {
        requestedMode != nil && baseURL != nil && provider != nil && userScope != nil
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

enum HFLibrarySyncState: String, Codable, Equatable {
    case localLibraryMode
    case cloudLibraryNotConnected
    case missingCredentials
    case configured

    var statusLabel: String {
        switch self {
        case .localLibraryMode:
            return "Local Library Mode"
        case .cloudLibraryNotConnected:
            return "Cloud Library Not Connected Yet"
        case .missingCredentials:
            return "Library Sync Missing Credentials"
        case .configured:
            return "Library Sync Configured"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .localLibraryMode:
            return "hf.library.localLibraryMode"
        case .cloudLibraryNotConnected:
            return "hf.library.cloudNotConnected"
        case .missingCredentials:
            return "hf.library.cloudNotConnected"
        case .configured:
            return "hf.library.syncStatus"
        }
    }
}

enum HFLibrarySyncProviderStatus: String, Codable, Equatable {
    case local
    case accountRequired
    case providerMissing
    case configured

    var statusLabel: String {
        switch self {
        case .local:
            return "Local Library Mode"
        case .accountRequired:
            return "Cloud sync requires account"
        case .providerMissing:
            return "Library Sync Missing Credentials"
        case .configured:
            return "Library Sync Configured"
        }
    }
}

enum HFLibrarySyncOperation: String, Codable, Equatable {
    case snapshot
    case saveTitle
    case updateProgress
    case updateOfflineState
}

enum HFLibraryConflictPolicy: String, Codable, Equatable {
    case localWinsUntilCloudReady
    case newestRecordWinsAfterValidation

    var statusLabel: String {
        switch self {
        case .localWinsUntilCloudReady:
            return "Local Library Mode"
        case .newestRecordWinsAfterValidation:
            return "Library Sync Configured"
        }
    }

    var detail: String {
        switch self {
        case .localWinsUntilCloudReady:
            return "Saved titles, progress, and offline preview state remain local until account and backend config are ready."
        case .newestRecordWinsAfterValidation:
            return "Server conflict resolution is staged only and waits for production validation."
        }
    }
}

struct HFSavedTitleRecord: Codable, Identifiable, Equatable {
    let id: String
    let userID: String
    let titleID: String
    let statusLabel: String
    let updatedAtLabel: String
}

struct HFProgressRecord: Codable, Identifiable, Equatable {
    let id: String
    let userID: String
    let titleID: String
    let progress: Double
    let statusLabel: String
}

struct HFOfflineStateRecord: Codable, Identifiable, Equatable {
    let id: String
    let userID: String
    let titleID: String
    let statusLabel: String
}

struct HFLibrarySyncBoundary: Codable, Equatable {
    let title: String
    let detail: String

    static let backendMediated = HFLibrarySyncBoundary(
        title: "Backend-mediated library sync only",
        detail: "Cloud sync requires account and complete runtime config. No direct cloud provider or database client is active."
    )
}

struct HFLibrarySyncSnapshot: Codable, Equatable {
    let userID: String
    let savedTitles: [HFSavedTitleRecord]
    let progressRecords: [HFProgressRecord]
    let offlineStates: [HFOfflineStateRecord]
    let conflictPolicy: HFLibraryConflictPolicy
}

struct HFLibrarySyncRuntimeStatus: Codable, Equatable {
    let state: HFLibrarySyncState
    let providerStatus: HFLibrarySyncProviderStatus
    let boundary: HFLibrarySyncBoundary
    let conflictPolicy: HFLibraryConflictPolicy
    let detail: String

    var statusLabel: String {
        state.statusLabel
    }
}

protocol HFLibrarySyncService {
    func library(userID: String) async throws -> [HFLibraryItemDTO]
    func save(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO
    func snapshot(userID: String) -> HFLibrarySyncSnapshot
    func runtimeStatus(userID: String) -> HFLibrarySyncRuntimeStatus
}

struct HFLocalLibrarySyncAdapter: HFLibrarySyncService {
    let savedTitleIDs: Set<String>
    let progressByTitleID: [String: Double]
    let offlineTitleIDs: Set<String>

    init(savedTitleIDs: Set<String> = [], progressByTitleID: [String: Double] = [:], offlineTitleIDs: Set<String> = []) {
        self.savedTitleIDs = savedTitleIDs
        self.progressByTitleID = progressByTitleID
        self.offlineTitleIDs = offlineTitleIDs
    }

    func library(userID: String) async throws -> [HFLibraryItemDTO] {
        snapshot(userID: userID).savedTitles.map { record in
            HFLibraryItemDTO(
                id: record.id,
                userID: userID,
                titleID: record.titleID,
                saved: true,
                progress: progressByTitleID[record.titleID],
                offlineState: offlineTitleIDs.contains(record.titleID) ? "Offline Preview State" : "Saved Locally",
                updatedAt: nil
            )
        }
    }

    func save(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO {
        item
    }

    func snapshot(userID: String) -> HFLibrarySyncSnapshot {
        HFLibrarySyncSnapshot(
            userID: userID,
            savedTitles: savedTitleIDs.sorted().map {
                HFSavedTitleRecord(id: "saved-\($0)", userID: userID, titleID: $0, statusLabel: "Saved Locally", updatedAtLabel: "Local")
            },
            progressRecords: progressByTitleID.keys.sorted().map {
                HFProgressRecord(id: "progress-\($0)", userID: userID, titleID: $0, progress: progressByTitleID[$0] ?? 0, statusLabel: "Progress Saved Locally")
            },
            offlineStates: offlineTitleIDs.sorted().map {
                HFOfflineStateRecord(id: "offline-\($0)", userID: userID, titleID: $0, statusLabel: "Offline Preview State")
            },
            conflictPolicy: .localWinsUntilCloudReady
        )
    }

    func runtimeStatus(userID: String) -> HFLibrarySyncRuntimeStatus {
        HFLibrarySyncRuntimeStatus(
            state: .localLibraryMode,
            providerStatus: .local,
            boundary: .backendMediated,
            conflictPolicy: .localWinsUntilCloudReady,
            detail: "Local Library Mode. Saved Locally, Progress Saved Locally, and Offline Preview State remain on this device."
        )
    }
}

struct HFRemoteLibrarySyncGateway: HFLibrarySyncService {
    let configuration: HFLibrarySyncConfiguration
    let backendConfiguration: HFBackendConfiguration
    let authConfiguration: HFAuthConfiguration
    let localFallback: HFLocalLibrarySyncAdapter

    init(
        configuration: HFLibrarySyncConfiguration,
        backendConfiguration: HFBackendConfiguration,
        authConfiguration: HFAuthConfiguration,
        localFallback: HFLocalLibrarySyncAdapter = HFLocalLibrarySyncAdapter()
    ) {
        self.configuration = configuration
        self.backendConfiguration = backendConfiguration
        self.authConfiguration = authConfiguration
        self.localFallback = localFallback
    }

    func library(userID: String) async throws -> [HFLibraryItemDTO] {
        try await localFallback.library(userID: userID)
    }

    func save(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO {
        item
    }

    func snapshot(userID: String) -> HFLibrarySyncSnapshot {
        localFallback.snapshot(userID: userID)
    }

    func runtimeStatus(userID: String) -> HFLibrarySyncRuntimeStatus {
        guard configuration.hasAnyRuntimeConfig else {
            return localFallback.runtimeStatus(userID: userID)
        }

        guard authConfiguration.hasCompleteRuntimeConfig else {
            return HFLibrarySyncRuntimeStatus(
                state: .cloudLibraryNotConnected,
                providerStatus: .accountRequired,
                boundary: .backendMediated,
                conflictPolicy: .localWinsUntilCloudReady,
                detail: "Cloud Library Not Connected Yet. Cloud sync requires account."
            )
        }

        guard configuration.hasCompleteRuntimeConfig && backendConfiguration.hasCompleteRuntimeConfig else {
            return HFLibrarySyncRuntimeStatus(
                state: .missingCredentials,
                providerStatus: .providerMissing,
                boundary: .backendMediated,
                conflictPolicy: .localWinsUntilCloudReady,
                detail: "Library Sync Missing Credentials. Backend-mediated library sync only."
            )
        }

        return HFLibrarySyncRuntimeStatus(
            state: .configured,
            providerStatus: .configured,
            boundary: .backendMediated,
            conflictPolicy: .newestRecordWinsAfterValidation,
            detail: "Library Sync Configured for staging only. No live cross-device sync claim is made."
        )
    }
}

struct HFBackendLibrarySyncService: HFLibrarySyncService {
    private let gateway: HFBackendGateway

    init(gateway: HFBackendGateway) {
        self.gateway = gateway
    }

    func library(userID: String) async throws -> [HFLibraryItemDTO] {
        try await gateway.fetchLibrary(userID: userID)
    }

    func save(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO {
        try await gateway.upsertLibraryItem(item)
    }

    func snapshot(userID: String) -> HFLibrarySyncSnapshot {
        HFLibrarySyncSnapshot(
            userID: userID,
            savedTitles: [],
            progressRecords: [],
            offlineStates: [],
            conflictPolicy: .localWinsUntilCloudReady
        )
    }

    func runtimeStatus(userID: String) -> HFLibrarySyncRuntimeStatus {
        HFLibrarySyncRuntimeStatus(
            state: .cloudLibraryNotConnected,
            providerStatus: .providerMissing,
            boundary: .backendMediated,
            conflictPolicy: .localWinsUntilCloudReady,
            detail: "Cloud Library Not Connected Yet. Backend-mediated library sync only."
        )
    }
}

enum HFLibrarySyncServiceFactory {
    static func make(
        configuration: HFLibrarySyncConfiguration = HFLibrarySyncConfiguration(),
        backendConfiguration: HFBackendConfiguration = HFBackendConfiguration(),
        authConfiguration: HFAuthConfiguration = HFAuthConfiguration(),
        localFallback: HFLocalLibrarySyncAdapter = HFLocalLibrarySyncAdapter()
    ) -> HFLibrarySyncService {
        configuration.hasAnyRuntimeConfig
            ? HFRemoteLibrarySyncGateway(
                configuration: configuration,
                backendConfiguration: backendConfiguration,
                authConfiguration: authConfiguration,
                localFallback: localFallback
            )
            : localFallback
    }
}

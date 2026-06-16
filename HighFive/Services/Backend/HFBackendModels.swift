import Foundation

enum HFBackendMode: String, Codable, Equatable {
    case local
    case configured
    case unavailable
}

enum HFBackendConnectionState: String, Codable, Equatable {
    case localMode
    case missingCredentials
    case localPreview
    case backendNotConfigured
    case backendConfigured
    case backendUnavailable
    case credentialsMissing
    case readyForStaging
    case stagingReachable
    case stagingUnavailable
}

struct HFBackendServiceStatus: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let detail: String
    let state: HFBackendConnectionState
    let statusLabel: String
    let systemImage: String
    let accessibilityIdentifier: String

    var displayTitle: String {
        statusLabel
    }

    var isConfigured: Bool {
        state == .backendConfigured || state == .readyForStaging || state == .stagingReachable
    }
}

struct HFBackendRuntimeStatus: Codable, Equatable {
    let mode: HFBackendMode
    let connectionState: HFBackendConnectionState
    let status: HFBackendServiceStatus
    let services: [HFBackendServiceStatus]
}

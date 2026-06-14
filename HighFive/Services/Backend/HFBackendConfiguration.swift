import Foundation

struct HFBackendConfiguration: Equatable {
    static let modeKey = "HIGHFIVE_BACKEND_MODE"
    static let baseURLKey = "HIGHFIVE_BACKEND_BASE_URL"
    static let projectURLKey = "HIGHFIVE_SUPABASE_PROJECT_URL"
    static let anonKeyKey = "HIGHFIVE_SUPABASE_ANON_KEY"

    let requestedMode: String?
    let backendBaseURL: String?
    let projectURL: String?
    let anonKey: String?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        requestedMode = Self.nonEmpty(environment[Self.modeKey])
        backendBaseURL = Self.nonEmpty(environment[Self.baseURLKey])
        projectURL = Self.nonEmpty(environment[Self.projectURLKey])
        anonKey = Self.nonEmpty(environment[Self.anonKeyKey])
    }

    var mode: HFBackendMode {
        let normalized = requestedMode?.lowercased()

        if normalized == "unavailable" || normalized == "disabled" {
            return .unavailable
        }

        if hasAnyRuntimeConfig || normalized == "configured" || normalized == "staging" {
            return .configured
        }

        return .local
    }

    var connectionState: HFBackendConnectionState {
        switch mode {
        case .local:
            return hasAnyRuntimeConfig ? .backendNotConfigured : .localPreview
        case .unavailable:
            return .backendUnavailable
        case .configured:
            if hasCompleteRuntimeConfig {
                return requestedMode?.lowercased() == "staging" ? .readyForStaging : .backendConfigured
            }
            return .credentialsMissing
        }
    }

    var hasAnyRuntimeConfig: Bool {
        backendBaseURL != nil || projectURL != nil || anonKey != nil
    }

    var hasCompleteRuntimeConfig: Bool {
        backendBaseURL != nil || (projectURL != nil && anonKey != nil)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

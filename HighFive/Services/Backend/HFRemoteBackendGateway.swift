import Foundation

struct HFRemoteBackendGateway: HFBackendGateway {
    private let configuration: HFBackendConfiguration

    init(configuration: HFBackendConfiguration) {
        self.configuration = configuration
    }

    func health() async throws -> HFBackendHealth {
        guard configuration.hasCompleteRuntimeConfig else {
            throw HFBackendGatewayError.missingRuntimeValue("runtime config")
        }

        guard let url = healthURL() else {
            throw HFBackendGatewayError.notConfigured
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let anonKey = configuration.anonKey, configuration.projectURL != nil {
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw HFBackendGatewayError.invalidResponse
        }

        return try JSONDecoder().decode(HFBackendHealth.self, from: data)
    }

    func serviceStatuses() async -> [HFBackendServiceStatus] {
        let state: HFBackendConnectionState
        if configuration.hasCompleteRuntimeConfig {
            do {
                _ = try await health()
                state = .stagingReachable
            } catch {
                state = .stagingUnavailable
            }
        } else {
            state = .missingCredentials
        }

        let label = label(for: state)
        return [
            status(id: "backend", title: "Backend Runtime", detail: "Runtime configuration is present for staging boundaries. No production service claim is made.", state: state, label: label, systemImage: "server.rack"),
            status(id: "account", title: "Account", detail: "Account boundary can be staged when auth runtime config is supplied.", state: state, label: label, systemImage: "person.crop.circle.fill"),
            status(id: "catalog", title: "Catalog", detail: "Catalog requests must pass through the backend gateway.", state: state, label: label, systemImage: "sparkles.tv.fill"),
            status(id: "library", title: "Library", detail: "Cloud library sync remains backend-mediated.", state: state, label: label, systemImage: "bookmark.fill"),
            status(id: "downloads", title: "Downloads", detail: "Download eligibility remains policy-only until media and license providers are configured.", state: state, label: label, systemImage: "arrow.down.circle.fill")
        ]
    }

    func fetchCatalog() async throws -> [HFCatalogTitleDTO] { throw HFBackendGatewayError.unsupportedInLocalMode }
    func fetchLibrary(userID: String) async throws -> [HFLibraryItemDTO] { throw HFBackendGatewayError.unsupportedInLocalMode }
    func upsertLibraryItem(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO { throw HFBackendGatewayError.unsupportedInLocalMode }
    func fetchCreatorProjects(userID: String) async throws -> [HFCreatorProjectDTO] { throw HFBackendGatewayError.unsupportedInLocalMode }
    func saveCreatorProject(_ project: HFCreatorProjectDTO) async throws -> HFCreatorProjectDTO { throw HFBackendGatewayError.unsupportedInLocalMode }
    func fetchSocialKit(projectID: String) async throws -> HFSocialKitDTO { throw HFBackendGatewayError.unsupportedInLocalMode }
    func saveSocialKit(_ kit: HFSocialKitDTO) async throws -> HFSocialKitDTO { throw HFBackendGatewayError.unsupportedInLocalMode }
    func fetchVODPackage(projectID: String) async throws -> HFVODPackageDTO { throw HFBackendGatewayError.unsupportedInLocalMode }
    func saveVODPackage(_ package: HFVODPackageDTO) async throws -> HFVODPackageDTO { throw HFBackendGatewayError.unsupportedInLocalMode }

    private func healthURL() -> URL? {
        if let backendBaseURL = configuration.backendBaseURL, let baseURL = URL(string: backendBaseURL) {
            return baseURL.appendingPathComponent("health")
        }

        if let projectURL = configuration.projectURL, let baseURL = URL(string: projectURL) {
            return baseURL
                .appendingPathComponent("functions")
                .appendingPathComponent("v1")
                .appendingPathComponent("highfive-api")
                .appendingPathComponent("health")
        }

        return nil
    }

    private func label(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Staging Reachable"
        case .stagingUnavailable:
            return "Staging Unavailable"
        case .backendConfigured, .readyForStaging:
            return "Backend Configured"
        case .missingCredentials, .credentialsMissing:
            return "Missing Credentials"
        case .localMode, .localPreview:
            return "Local Mode"
        default:
            return "Backend Not Connected Yet"
        }
    }

    private func status(id: String, title: String, detail: String, state: HFBackendConnectionState, label: String, systemImage: String) -> HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: id,
            title: title,
            detail: detail,
            state: state,
            statusLabel: label,
            systemImage: systemImage,
            accessibilityIdentifier: "hf.backend.\(id)"
        )
    }
}

import Foundation

protocol HFBackendGateway {
    func health() async throws -> HFBackendHealth
    func serviceStatuses() async -> [HFBackendServiceStatus]
    func fetchCatalog() async throws -> [HFCatalogTitleDTO]
    func fetchLibrary(userID: String) async throws -> [HFLibraryItemDTO]
    func upsertLibraryItem(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO
    func fetchCreatorProjects(userID: String) async throws -> [HFCreatorProjectDTO]
    func saveCreatorProject(_ project: HFCreatorProjectDTO) async throws -> HFCreatorProjectDTO
    func fetchSocialKit(projectID: String) async throws -> HFSocialKitDTO
    func saveSocialKit(_ kit: HFSocialKitDTO) async throws -> HFSocialKitDTO
    func fetchVODPackage(projectID: String) async throws -> HFVODPackageDTO
    func saveVODPackage(_ package: HFVODPackageDTO) async throws -> HFVODPackageDTO
}

enum HFBackendGatewayError: Error, LocalizedError {
    case notConfigured
    case invalidResponse
    case unsupportedInLocalMode
    case missingRuntimeValue(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Backend Not Connected Yet"
        case .invalidResponse:
            return "The staging backend returned an invalid response."
        case .unsupportedInLocalMode:
            return "Local Mode keeps this request inside the app."
        case .missingRuntimeValue(let name):
            return "Missing Credentials: \(name)"
        }
    }
}

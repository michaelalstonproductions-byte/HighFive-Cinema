import Foundation

protocol HFLibrarySyncService {
    func library(userID: String) async throws -> [HFLibraryItemDTO]
    func save(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO
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
}

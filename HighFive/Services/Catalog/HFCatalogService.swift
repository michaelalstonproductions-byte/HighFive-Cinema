import Foundation

protocol HFCatalogService {
    func titles() async throws -> [HFCatalogTitleDTO]
}

struct HFBackendCatalogService: HFCatalogService {
    private let gateway: HFBackendGateway

    init(gateway: HFBackendGateway) {
        self.gateway = gateway
    }

    func titles() async throws -> [HFCatalogTitleDTO] {
        try await gateway.fetchCatalog()
    }
}

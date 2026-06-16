import Foundation

struct HFBackendHealth: Codable, Equatable {
    let status: String
    let environment: String
    let services: [String: String]
}

struct HFCatalogTitleDTO: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let synopsis: String?
    let posterAssetName: String?
    let backdropAssetName: String?
    let rating: String?
    let duration: String?
    let genres: [String]
    let isOriginal: Bool
    let isComingSoon: Bool
}

struct HFLibraryItemDTO: Codable, Identifiable, Equatable {
    let id: String
    let userID: String
    let titleID: String
    let saved: Bool
    let progress: Double?
    let offlineState: String
    let updatedAt: Date?
}

struct HFCreatorProjectDTO: Codable, Identifiable, Equatable {
    let id: String
    let ownerUserID: String
    let titleID: String?
    let name: String
    let status: String
    let updatedAt: Date?
}

struct HFSocialKitDTO: Codable, Identifiable, Equatable {
    let id: String
    let projectID: String
    let captionDrafts: [String]
    let platformReadiness: [String: String]
    let status: String
}

struct HFVODPackageDTO: Codable, Identifiable, Equatable {
    let id: String
    let projectID: String
    let checklist: [String: String]
    let distributionProviderStatus: String
    let storefrontProviderStatus: String
    let status: String
}

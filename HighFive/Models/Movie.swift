import Foundation

struct Movie: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let synopsis: String
    let year: String
    let rating: String
    let duration: String
    let genres: [String]
    let posterAssetName: String?
    let backdropAssetName: String?
    let creatorName: String
    let isOriginal: Bool
    let isComingSoon: Bool
    let isDownloaded: Bool
    let progress: Double?

    var metadataLine: String {
        [year, rating, duration].filter { !$0.isEmpty }.joined(separator: "  |  ")
    }
}

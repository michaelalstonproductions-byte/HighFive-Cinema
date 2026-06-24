import Foundation

struct Creator: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let role: String
    let avatarAssetName: String?
    let featuredMovieIDs: [String]
}

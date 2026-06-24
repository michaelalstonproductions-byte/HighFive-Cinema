import Foundation

struct Category: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String?
    let movies: [Movie]
}

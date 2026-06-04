import Foundation

struct Category: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let movies: [Movie]
}

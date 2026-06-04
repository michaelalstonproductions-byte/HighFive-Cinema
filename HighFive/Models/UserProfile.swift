import Foundation

struct UserProfile: Identifiable, Hashable {
    let id: String
    let name: String
    let avatarSystemName: String
    let accentName: String
    let isKidsProfile: Bool
}

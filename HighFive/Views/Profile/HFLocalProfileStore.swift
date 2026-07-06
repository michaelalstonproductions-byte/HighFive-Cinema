import Foundation
import SwiftUI
import Combine

@MainActor
final class HFLocalProfileStore: ObservableObject {
    @AppStorage("hf.profile.hasProfile") private var storedHasProfile = false
    @AppStorage("hf.profile.displayName") private var storedDisplayName = ""
    @AppStorage("hf.profile.avatarSymbol") private var storedAvatarSymbol = "person.crop.circle.fill"
    @AppStorage("hf.profile.createdAt") private var storedCreatedAt = ""
    @AppStorage("hf.profile.updatedAt") private var storedUpdatedAt = ""

    @Published private(set) var hasProfile: Bool = false
    @Published var displayName: String = ""
    @Published var avatarSymbol: String = "person.crop.circle.fill"

    init() {
        reload()
    }

    func reload() {
        hasProfile = storedHasProfile
        displayName = storedDisplayName
        avatarSymbol = storedAvatarSymbol.isEmpty ? "person.crop.circle.fill" : storedAvatarSymbol
    }

    func save(displayName: String, avatarSymbol: String) {
        let cleanedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = cleanedName.isEmpty ? "HighFive Viewer" : cleanedName
        let now = ISO8601DateFormatter().string(from: Date())

        storedHasProfile = true
        storedDisplayName = finalName
        storedAvatarSymbol = avatarSymbol.isEmpty ? "person.crop.circle.fill" : avatarSymbol

        if storedCreatedAt.isEmpty {
            storedCreatedAt = now
        }

        storedUpdatedAt = now
        reload()
    }

    func deleteLocalProfile() {
        storedHasProfile = false
        storedDisplayName = ""
        storedAvatarSymbol = "person.crop.circle.fill"
        storedCreatedAt = ""
        storedUpdatedAt = ""
        reload()
    }

    var profileSubtitle: String {
        hasProfile ? "Local viewing profile" : "Create a local viewing profile"
    }
}

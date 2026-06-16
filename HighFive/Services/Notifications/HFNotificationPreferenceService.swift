import Foundation

struct HFNotificationPreference: Codable, Equatable {
    let userID: String
    let channel: String
    let isEnabled: Bool
}

protocol HFNotificationPreferenceService {
    func preferences(userID: String) async throws -> [HFNotificationPreference]
}

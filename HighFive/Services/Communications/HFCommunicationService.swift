import Foundation

struct HFAudienceUpdate: Codable, Identifiable, Equatable {
    let id: String
    let projectID: String
    let channel: String
    let body: String
    let status: String
}

protocol HFCommunicationService {
    func audienceUpdates(projectID: String) async throws -> [HFAudienceUpdate]
    func saveAudienceUpdate(_ update: HFAudienceUpdate) async throws -> HFAudienceUpdate
}

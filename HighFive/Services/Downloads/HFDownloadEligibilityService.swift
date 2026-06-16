import Foundation

struct HFDownloadEligibility: Codable, Equatable {
    let titleID: String
    let isEligible: Bool
    let reason: String
    let state: String

    static func localPreview(titleID: String) -> HFDownloadEligibility {
        HFDownloadEligibility(
            titleID: titleID,
            isEligible: false,
            reason: "Local offline preview only. Real media download provider is not connected.",
            state: "Provider-ready"
        )
    }
}

protocol HFDownloadEligibilityService {
    func eligibility(titleID: String, userID: String) async throws -> HFDownloadEligibility
}

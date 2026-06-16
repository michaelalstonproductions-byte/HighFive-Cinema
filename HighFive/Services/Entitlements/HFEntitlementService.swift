import Foundation

struct HFEntitlementState: Codable, Equatable {
    let userID: String
    let titleID: String?
    let hasAccess: Bool
    let state: String
    let detail: String

    static func localPreview(userID: String, titleID: String? = nil) -> HFEntitlementState {
        HFEntitlementState(
            userID: userID,
            titleID: titleID,
            hasAccess: true,
            state: "Local Preview",
            detail: "No live payment provider is connected."
        )
    }
}

protocol HFEntitlementService {
    func entitlement(userID: String, titleID: String?) async throws -> HFEntitlementState
}

import Foundation

enum HFInstagramConnectionState: String, Codable {
    case notConnected = "Not Connected Yet"
    case providerReady = "Provider-ready"
    case awaitingProvider = "Missing Credentials"
    case connected = "Connected"
    case unavailable = "Unavailable"
}

struct HFInstagramReadiness: Codable, Equatable {
    let state: HFInstagramConnectionState
    let displayTitle: String
    let detail: String
    let allowedLocalActions: [String]
    let forbiddenLiveActions: [String]

    static let localPreview = HFInstagramReadiness(
        state: .notConnected,
        displayTitle: "Instagram Connect",
        detail: "Provider-ready local planning. No account connection, token storage, posting, or provider SDK is active.",
        allowedLocalActions: ["Review Caption Drafts", "Preview Post Plan", "Save Local Draft"],
        forbiddenLiveActions: ["Publish", "Upload", "Submit to platform", "Connect account"]
    )
}

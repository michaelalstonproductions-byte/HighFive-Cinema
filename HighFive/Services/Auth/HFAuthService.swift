import Foundation

protocol HFAuthService {
    func currentAccount() async -> HFAccountIdentity?
    func signOut() async throws
}

struct HFAccountIdentity: Codable, Identifiable, Equatable {
    let id: String
    let provider: String
    let displayName: String
    let email: String?
}

actor HFLocalAuthAdapter: HFAuthService {
    func currentAccount() async -> HFAccountIdentity? {
        HFAccountIdentity(id: "local-profile", provider: "local", displayName: "Local Profile", email: nil)
    }

    func signOut() async throws {}
}

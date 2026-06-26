import AuthenticationServices
import Foundation

struct HFAppleIdentityCredentialPayload: Equatable {
    let identityCredential: String
    let authorizationCredential: String?
    let userIdentifier: String
    let email: String?
    let fullName: String?

    init?(credential: ASAuthorizationAppleIDCredential) {
        guard
            let identityToken = credential.identityToken,
            let identityCredential = String(data: identityToken, encoding: .utf8)
        else {
            return nil
        }

        self.identityCredential = identityCredential
        authorizationCredential = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
        userIdentifier = credential.user
        email = credential.email
        fullName = credential.fullName.map {
            PersonNameComponentsFormatter.localizedString(from: $0, style: .medium, options: [])
        }
    }
}

enum HFIdentityAccessClientError: Error, LocalizedError {
    case backendNotConfigured
    case invalidEndpoint
    case invalidResponse
    case httpError(Int, String)

    var errorDescription: String? {
        switch self {
        case .backendNotConfigured:
            return "Backend identity endpoint is not configured. Development identity remains available."
        case .invalidEndpoint:
            return "Identity endpoint could not be constructed from the configured backend URL."
        case .invalidResponse:
            return "Identity service returned an invalid response."
        case .httpError(let status, let detail):
            return "Identity service returned \(status): \(detail)"
        }
    }
}

struct HFIdentityAccessClient {
    private let baseURL: URL?
    private let transport: URLSession

    init(
        backendConfiguration: HFBackendConfiguration,
        authConfiguration: HFAuthConfiguration,
        transport: URLSession = .shared
    ) {
        let rawURL = backendConfiguration.backendBaseURL ?? authConfiguration.authBaseURL
        baseURL = rawURL.flatMap(URL.init(string:))
        self.transport = transport
    }

    var isConfigured: Bool {
        baseURL != nil
    }

    func exchangeAppleCredential(
        _ credential: HFAppleIdentityCredentialPayload,
        role: HFIdentityAccessRole
    ) async throws -> HFIdentityAccessSession {
        let request = try jsonRequest(
            path: "/v1/identity/apple/exchange",
            method: "POST",
            authorizationSessionID: nil,
            body: HFAppleIdentityExchangeRequest(
                role: role.rawValue,
                identityCredential: credential.identityCredential,
                authorizationCredential: credential.authorizationCredential,
                userIdentifier: credential.userIdentifier,
                email: credential.email,
                fullName: credential.fullName
            )
        )
        let response: HFIdentitySessionResponse = try await send(request)
        return response.identityAccessSession
    }

    func developmentSession(role: HFIdentityAccessRole) async throws -> HFIdentityAccessSession {
        let request = try jsonRequest(
            path: "/v1/identity/dev/sign-in",
            method: "POST",
            authorizationSessionID: nil,
            body: HFDevelopmentIdentityRequest(role: role.rawValue)
        )
        let response: HFIdentitySessionResponse = try await send(request)
        return response.identityAccessSession
    }

    func refresh(session: HFIdentityAccessSession) async throws -> HFIdentityAccessSession {
        let request = try jsonRequest(
            path: "/v1/identity/session/refresh",
            method: "POST",
            authorizationSessionID: session.id,
            body: HFEmptyIdentityRequest()
        )
        let response: HFIdentitySessionResponse = try await send(request)
        return response.identityAccessSession
    }

    func signOut(session: HFIdentityAccessSession) async throws {
        let request = try jsonRequest(
            path: "/v1/identity/sign-out",
            method: "POST",
            authorizationSessionID: session.id,
            body: HFEmptyIdentityRequest()
        )
        let _: HFIdentityMutationResponse = try await send(request)
    }

    func requestDeletion(session: HFIdentityAccessSession) async throws -> HFIdentityMutationResponse {
        let request = try jsonRequest(
            path: "/v1/identity/delete-request",
            method: "POST",
            authorizationSessionID: session.id,
            body: HFEmptyIdentityRequest()
        )
        return try await send(request)
    }

    private func jsonRequest<T: Encodable>(
        path: String,
        method: String,
        authorizationSessionID: String?,
        body: T
    ) throws -> URLRequest {
        guard let baseURL else { throw HFIdentityAccessClientError.backendNotConfigured }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw HFIdentityAccessClientError.invalidEndpoint }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let authorizationSessionID {
            request.setValue("HighFiveSession \(authorizationSessionID)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await transport.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HFIdentityAccessClientError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = (try? JSONDecoder().decode(HFIdentityErrorResponse.self, from: data))?.detail
                ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw HFIdentityAccessClientError.httpError(httpResponse.statusCode, backendError)
        }
        do {
            return try JSONDecoder.highfiveIdentity.decode(T.self, from: data)
        } catch {
            throw HFIdentityAccessClientError.invalidResponse
        }
    }
}

private struct HFAppleIdentityExchangeRequest: Encodable {
    let role: String
    let identityCredential: String
    let authorizationCredential: String?
    let userIdentifier: String
    let email: String?
    let fullName: String?

    enum CodingKeys: String, CodingKey {
        case role
        case identityCredential = "identity_credential"
        case authorizationCredential = "authorization_credential"
        case userIdentifier = "user_identifier"
        case email
        case fullName = "full_name"
    }
}

private struct HFDevelopmentIdentityRequest: Encodable {
    let role: String
}

private struct HFEmptyIdentityRequest: Encodable {}

private struct HFIdentitySessionResponse: Decodable {
    let status: String
    let detail: String
    let session: HFRemoteIdentitySession

    var identityAccessSession: HFIdentityAccessSession {
        session.identityAccessSession
    }
}

struct HFIdentityMutationResponse: Decodable, Equatable {
    let status: String
    let detail: String?
    let userID: String?
    let revokedSessions: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case detail
        case userID = "user_id"
        case revokedSessions = "revoked_sessions"
    }
}

private struct HFRemoteIdentitySession: Decodable {
    let sessionID: String
    let userID: String
    let displayName: String
    let email: String?
    let role: HFIdentityAccessRole
    let creatorID: String?
    let workspaceID: String
    let provider: String
    let issuedAt: Date
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case userID = "user_id"
        case displayName = "display_name"
        case email
        case role
        case creatorID = "creator_id"
        case workspaceID = "workspace_id"
        case provider
        case issuedAt = "issued_at"
        case expiresAt = "expires_at"
    }

    var identityAccessSession: HFIdentityAccessSession {
        HFIdentityAccessSession(
            id: sessionID,
            userID: userID,
            displayName: displayName,
            email: email,
            provider: provider == "apple" ? "Apple" : "Development Identity",
            role: role,
            creatorID: creatorID,
            workspaceID: workspaceID,
            issuedAt: issuedAt,
            expiresAt: expiresAt,
            lastRefreshAt: nil
        )
    }
}

private struct HFIdentityErrorResponse: Decodable {
    let error: String
    let detail: String
}

private extension JSONDecoder {
    static var highfiveIdentity: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            if let date = ISO8601DateFormatter.highfiveFractional.date(from: value)
                ?? ISO8601DateFormatter.highfiveInternet.date(from: value) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO-8601 date: \(value)")
        }
        return decoder
    }
}

private extension ISO8601DateFormatter {
    static let highfiveFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let highfiveInternet: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

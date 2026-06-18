import Foundation

enum HFBackendRequestState: String, Codable, Equatable {
    case notConfigured
    case missingCredentials
    case validatingEntitlement
    case entitlementApproved
    case entitlementDenied
    case requestingPlaybackDescriptor
    case stagingPlaybackDescriptorReady
    case playbackDescriptorUnavailable
    case playbackDescriptorExpired
    case descriptorRefreshRequired
    case localPreviewFallbackActive

    var statusLabel: String {
        switch self {
        case .notConfigured:
            return "Staging backend not configured"
        case .missingCredentials:
            return "Missing Credentials"
        case .validatingEntitlement:
            return "Validating entitlement"
        case .entitlementApproved:
            return "Entitlement approved"
        case .entitlementDenied:
            return "Entitlement denied"
        case .requestingPlaybackDescriptor:
            return "Requesting playback descriptor"
        case .stagingPlaybackDescriptorReady:
            return "Staging playback descriptor ready"
        case .playbackDescriptorUnavailable:
            return "Playback descriptor unavailable"
        case .playbackDescriptorExpired:
            return "Playback descriptor expired"
        case .descriptorRefreshRequired:
            return "Descriptor refresh required"
        case .localPreviewFallbackActive:
            return "Local Preview fallback active"
        }
    }
}

struct HFBackendHTTPStatus: Codable, Equatable {
    let statusCode: Int
    let statusLabel: String

    var isSuccess: Bool {
        (200..<300).contains(statusCode)
    }

    init(statusCode: Int) {
        self.statusCode = statusCode
        let success = (200..<300).contains(statusCode)
        self.statusLabel = success ? "HTTP Success" : "HTTP \(statusCode)"
    }
}

enum HFBackendTransportError: Error, LocalizedError, Equatable {
    case notConfigured
    case missingCredentials
    case invalidEndpoint
    case invalidResponse
    case httpStatus(HFBackendHTTPStatus)
    case decodingFailed
    case cancellation

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Staging backend not configured"
        case .missingCredentials:
            return "Missing Credentials"
        case .invalidEndpoint:
            return "Backend endpoint configuration incomplete"
        case .invalidResponse:
            return "Invalid backend response"
        case .httpStatus(let status):
            return status.statusLabel
        case .decodingFailed:
            return "Invalid response body"
        case .cancellation:
            return "Request cancelled"
        }
    }
}

struct HFBackendRequestAuditContext: Codable, Equatable {
    let movieID: String
    let endpointLabel: String
    let state: HFBackendRequestState
    let detail: String
    let localFallback: String

    static func localFallback(movieID: String, detail: String) -> HFBackendRequestAuditContext {
        HFBackendRequestAuditContext(
            movieID: movieID,
            endpointLabel: "Backend-mediated playback only",
            state: .localPreviewFallbackActive,
            detail: detail,
            localFallback: "Local Preview fallback active"
        )
    }
}

struct HFPlaybackDescriptorRuntimeState: Codable, Equatable {
    let state: HFBackendRequestState
    let statusLabel: String
    let detail: String
    let expiresAt: String?
    let refreshAfter: String?

    static func localFallback(detail: String) -> HFPlaybackDescriptorRuntimeState {
        HFPlaybackDescriptorRuntimeState(
            state: .localPreviewFallbackActive,
            statusLabel: "Local Preview fallback active",
            detail: detail,
            expiresAt: nil,
            refreshAfter: nil
        )
    }
}

struct HFEntitlementPlaybackResult: Codable, Equatable {
    let movieID: String
    let entitlementState: HFBackendRequestState
    let descriptorState: HFBackendRequestState
    let entitlementResponse: HFBackendEntitlementValidationResponse?
    let playbackDescriptorResponse: HFBackendPlaybackDescriptorResponse?
    let playbackDescriptor: HFPlaybackDescriptor?
    let runtimeState: HFPlaybackDescriptorRuntimeState
    let auditContext: HFBackendRequestAuditContext
    let statusLabel: String
    let detail: String

    static func localFallback(movieID: String, detail: String) -> HFEntitlementPlaybackResult {
        let audit = HFBackendRequestAuditContext.localFallback(movieID: movieID, detail: detail)
        return HFEntitlementPlaybackResult(
            movieID: movieID,
            entitlementState: .notConfigured,
            descriptorState: .localPreviewFallbackActive,
            entitlementResponse: nil,
            playbackDescriptorResponse: nil,
            playbackDescriptor: nil,
            runtimeState: .localFallback(detail: detail),
            auditContext: audit,
            statusLabel: "Local Preview fallback active",
            detail: detail
        )
    }

    static func denied(
        movieID: String,
        response: HFBackendEntitlementValidationResponse,
        detail: String
    ) -> HFEntitlementPlaybackResult {
        let audit = HFBackendRequestAuditContext(
            movieID: movieID,
            endpointLabel: HFBackendPlaybackDescriptorEndpoint.entitlementValidation.statusLabel,
            state: .entitlementDenied,
            detail: detail,
            localFallback: "Local Preview fallback active"
        )
        return HFEntitlementPlaybackResult(
            movieID: movieID,
            entitlementState: .entitlementDenied,
            descriptorState: .localPreviewFallbackActive,
            entitlementResponse: response,
            playbackDescriptorResponse: nil,
            playbackDescriptor: nil,
            runtimeState: .localFallback(detail: detail),
            auditContext: audit,
            statusLabel: "Entitlement denied",
            detail: detail
        )
    }

    static func unavailable(
        movieID: String,
        entitlementResponse: HFBackendEntitlementValidationResponse?,
        descriptorResponse: HFBackendPlaybackDescriptorResponse?,
        descriptorState: HFBackendRequestState,
        detail: String
    ) -> HFEntitlementPlaybackResult {
        let audit = HFBackendRequestAuditContext(
            movieID: movieID,
            endpointLabel: HFBackendPlaybackDescriptorEndpoint.playbackDescriptor.statusLabel,
            state: descriptorState,
            detail: detail,
            localFallback: "Local Preview fallback active"
        )
        return HFEntitlementPlaybackResult(
            movieID: movieID,
            entitlementState: entitlementResponse?.entitlementStatus == .approved ? .entitlementApproved : .validatingEntitlement,
            descriptorState: descriptorState,
            entitlementResponse: entitlementResponse,
            playbackDescriptorResponse: descriptorResponse,
            playbackDescriptor: nil,
            runtimeState: HFPlaybackDescriptorRuntimeState(
                state: descriptorState,
                statusLabel: descriptorState.statusLabel,
                detail: detail,
                expiresAt: descriptorResponse?.expiresAt,
                refreshAfter: descriptorResponse?.refreshAfter
            ),
            auditContext: audit,
            statusLabel: descriptorState.statusLabel,
            detail: detail
        )
    }

    static func ready(
        movieID: String,
        entitlementResponse: HFBackendEntitlementValidationResponse,
        descriptorResponse: HFBackendPlaybackDescriptorResponse,
        descriptor: HFPlaybackDescriptor,
        detail: String
    ) -> HFEntitlementPlaybackResult {
        let audit = HFBackendRequestAuditContext(
            movieID: movieID,
            endpointLabel: HFBackendPlaybackDescriptorEndpoint.playbackDescriptor.statusLabel,
            state: .stagingPlaybackDescriptorReady,
            detail: detail,
            localFallback: "Local Preview fallback active"
        )
        return HFEntitlementPlaybackResult(
            movieID: movieID,
            entitlementState: .entitlementApproved,
            descriptorState: .stagingPlaybackDescriptorReady,
            entitlementResponse: entitlementResponse,
            playbackDescriptorResponse: descriptorResponse,
            playbackDescriptor: descriptor,
            runtimeState: HFPlaybackDescriptorRuntimeState(
                state: .stagingPlaybackDescriptorReady,
                statusLabel: "Staging playback descriptor ready",
                detail: detail,
                expiresAt: descriptorResponse.expiresAt,
                refreshAfter: descriptorResponse.refreshAfter
            ),
            auditContext: audit,
            statusLabel: "Staging playback descriptor ready",
            detail: detail
        )
    }
}

struct HFBackendEndpointResolver: Equatable {
    let backendConfiguration: HFBackendConfiguration
    let entitlementConfiguration: HFEntitlementConfiguration
    let streamingConfiguration: HFStreamingProviderConfiguration

    var hasAnyEndpointConfig: Bool {
        backendConfiguration.backendBaseURL != nil ||
            entitlementConfiguration.entitlementBaseURL != nil ||
            streamingConfiguration.descriptorBaseURL != nil
    }

    var hasCompleteEndpointConfig: Bool {
        entitlementEndpointURL != nil && playbackDescriptorEndpointURL != nil
    }

    var entitlementEndpointURL: URL? {
        resolve(
            base: entitlementConfiguration.entitlementBaseURL ?? backendConfiguration.backendBaseURL,
            relativePath: HFBackendPlaybackDescriptorEndpoint.entitlementValidationPath
        )
    }

    var playbackDescriptorEndpointURL: URL? {
        resolve(
            base: streamingConfiguration.descriptorBaseURL ?? backendConfiguration.backendBaseURL,
            relativePath: HFBackendPlaybackDescriptorEndpoint.playbackDescriptorPath
        )
    }

    private func resolve(base: String?, relativePath: String) -> URL? {
        guard let base, let baseURL = URL(string: base) else { return nil }
        let cleanedPath = relativePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return baseURL.appendingPathComponent(cleanedPath)
    }
}

protocol HFBackendEntitlementPlaybackTransport {
    func post<Request: Encodable, Response: Decodable>(
        _ requestBody: Request,
        to endpoint: URL
    ) async throws -> Response
}

struct HFURLSessionEntitlementPlaybackTransport: HFBackendEntitlementPlaybackTransport {
    private let session: URLSession
    private let timeout: TimeInterval

    init(session: URLSession = .shared, timeout: TimeInterval = 12) {
        self.session = session
        self.timeout = timeout
    }

    func post<Request: Encodable, Response: Decodable>(
        _ requestBody: Request,
        to endpoint: URL
    ) async throws -> Response {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(requestBody)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HFBackendTransportError.invalidResponse
            }

            let status = HFBackendHTTPStatus(statusCode: httpResponse.statusCode)
            guard status.isSuccess else {
                throw HFBackendTransportError.httpStatus(status)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw HFBackendTransportError.decodingFailed
            }
        } catch is CancellationError {
            throw HFBackendTransportError.cancellation
        } catch let error as HFBackendTransportError {
            throw error
        } catch {
            throw HFBackendTransportError.invalidResponse
        }
    }
}

struct HFBackendEntitlementPlaybackAdapter {
    let endpointResolver: HFBackendEndpointResolver
    let transport: any HFBackendEntitlementPlaybackTransport

    init(
        endpointResolver: HFBackendEndpointResolver,
        transport: any HFBackendEntitlementPlaybackTransport = HFURLSessionEntitlementPlaybackTransport()
    ) {
        self.endpointResolver = endpointResolver
        self.transport = transport
    }

    var canContactStagingEndpoint: Bool {
        endpointResolver.hasCompleteEndpointConfig
    }

    var runtimeState: HFBackendRequestState {
        guard endpointResolver.hasAnyEndpointConfig else { return .notConfigured }
        return endpointResolver.hasCompleteEndpointConfig ? .localPreviewFallbackActive : .missingCredentials
    }

    func validateEntitlement(
        request: HFBackendEntitlementValidationRequest
    ) async throws -> HFBackendEntitlementValidationResponse {
        guard endpointResolver.hasAnyEndpointConfig else {
            throw HFBackendTransportError.notConfigured
        }
        guard let endpoint = endpointResolver.entitlementEndpointURL else {
            throw HFBackendTransportError.missingCredentials
        }

        return try await transport.post(request, to: endpoint)
    }

    func requestPlaybackDescriptor(
        request: HFBackendPlaybackDescriptorRequest
    ) async throws -> HFBackendPlaybackDescriptorResponse {
        guard endpointResolver.hasAnyEndpointConfig else {
            throw HFBackendTransportError.notConfigured
        }
        guard let endpoint = endpointResolver.playbackDescriptorEndpointURL else {
            throw HFBackendTransportError.missingCredentials
        }

        return try await transport.post(request, to: endpoint)
    }

    func validateAndRequestPlaybackDescriptor(
        entitlementRequest: HFBackendEntitlementValidationRequest,
        descriptorRequest: HFBackendPlaybackDescriptorRequest
    ) async -> HFEntitlementPlaybackResult {
        guard endpointResolver.hasAnyEndpointConfig else {
            return .localFallback(
                movieID: entitlementRequest.movieID,
                detail: "Staging backend not configured. Local Preview fallback active."
            )
        }

        guard endpointResolver.hasCompleteEndpointConfig else {
            return .localFallback(
                movieID: entitlementRequest.movieID,
                detail: "Missing Credentials or endpoint configuration incomplete. Local Preview fallback active."
            )
        }

        do {
            let entitlementResponse = try await validateEntitlement(request: entitlementRequest)
            guard entitlementResponse.entitlementStatus == .approved else {
                return .denied(
                    movieID: entitlementRequest.movieID,
                    response: entitlementResponse,
                    detail: "Entitlement denied. Local Preview fallback active."
                )
            }

            let descriptorResponse = try await requestPlaybackDescriptor(request: descriptorRequest)
            let descriptorState = descriptorState(for: descriptorResponse)
            guard descriptorState == .stagingPlaybackDescriptorReady,
                  descriptorResponse.playbackURLOrTokenReference != nil else {
                return .unavailable(
                    movieID: entitlementRequest.movieID,
                    entitlementResponse: entitlementResponse,
                    descriptorResponse: descriptorResponse,
                    descriptorState: descriptorState,
                    detail: descriptorResponse.detail
                )
            }

            let descriptor = makePlaybackDescriptor(
                movieID: entitlementRequest.movieID,
                provider: entitlementRequest.playbackProvider,
                descriptorResponse: descriptorResponse
            )
            return .ready(
                movieID: entitlementRequest.movieID,
                entitlementResponse: entitlementResponse,
                descriptorResponse: descriptorResponse,
                descriptor: descriptor,
                detail: "Staging playback descriptor ready. Server-side Cloudflare signing required."
            )
        } catch {
            return .unavailable(
                movieID: entitlementRequest.movieID,
                entitlementResponse: nil,
                descriptorResponse: nil,
                descriptorState: .playbackDescriptorUnavailable,
                detail: "Playback descriptor unavailable. Local Preview fallback active."
            )
        }
    }

    private func descriptorState(for response: HFBackendPlaybackDescriptorResponse) -> HFBackendRequestState {
        if let error = response.error {
            switch error {
            case .descriptorExpired:
                return .playbackDescriptorExpired
            case .descriptorRefreshRequired:
                return .descriptorRefreshRequired
            case .entitlementDenied:
                return .entitlementDenied
            case .unavailable:
                return .playbackDescriptorUnavailable
            }
        }

        return response.playbackDescriptorStatus == .stagingDescriptorReady ? .stagingPlaybackDescriptorReady : .playbackDescriptorUnavailable
    }

    private func makePlaybackDescriptor(
        movieID: String,
        provider: HFStreamingProvider,
        descriptorResponse: HFBackendPlaybackDescriptorResponse
    ) -> HFPlaybackDescriptor {
        HFPlaybackDescriptor(
            id: "staging-backend-\(movieID)",
            movieID: movieID,
            title: movieID,
            status: descriptorResponse.playbackDescriptorStatus,
            provider: provider,
            providerAssetMapping: HFProviderAssetMapping(
                id: "staging-provider-\(movieID)",
                movieID: movieID,
                provider: provider,
                providerAssetID: nil,
                localPreviewAssetName: nil
            ),
            detail: "Staging playback descriptor ready",
            boundary: .backendMediated
        )
    }
}

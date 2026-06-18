import Foundation

enum HFServerEntitlementValidationState: String, Codable, Equatable {
    case pending
    case approved
    case denied

    var statusLabel: String {
        switch self {
        case .pending:
            return "Server entitlement validation pending"
        case .approved:
            return "Entitlement approved"
        case .denied:
            return "Entitlement denied"
        }
    }
}

enum HFBackendPlaybackDescriptorError: String, Codable, Equatable {
    case unavailable
    case entitlementDenied
    case descriptorExpired
    case descriptorRefreshRequired

    var statusLabel: String {
        switch self {
        case .unavailable:
            return "Playback descriptor unavailable"
        case .entitlementDenied:
            return "Entitlement denied"
        case .descriptorExpired:
            return "Descriptor expired"
        case .descriptorRefreshRequired:
            return "Descriptor refresh required"
        }
    }
}

struct HFBackendPlaybackDescriptorEndpoint: Codable, Equatable {
    static let entitlementValidationPath = "/entitlements/validate"
    static let playbackDescriptorPath = "/playback/descriptor"

    let method: String
    let relativePath: String
    let statusLabel: String
    let detail: String

    static let entitlementValidation = HFBackendPlaybackDescriptorEndpoint(
        method: "POST",
        relativePath: entitlementValidationPath,
        statusLabel: "Backend entitlement validation required",
        detail: "Server entitlement validation pending until backend runtime config is complete."
    )

    static let playbackDescriptor = HFBackendPlaybackDescriptorEndpoint(
        method: "POST",
        relativePath: playbackDescriptorPath,
        statusLabel: "Backend playback descriptor endpoint required",
        detail: "Backend playback descriptor endpoint required before Cloudflare descriptor readiness."
    )
}

struct HFCloudflareSignedPlaybackPolicy: Codable, Equatable {
    let title: String
    let detail: String
    let statusLabel: String

    static let serverSideOnly = HFCloudflareSignedPlaybackPolicy(
        title: "Cloudflare signed token generated server-side",
        detail: "No Cloudflare token in app. The app only accepts backend-mediated descriptor metadata.",
        statusLabel: "No Cloudflare token in app"
    )
}

struct HFPlaybackDescriptorExpiryPolicy: Codable, Equatable {
    let title: String
    let detail: String
    let expiredStatusLabel: String
    let refreshStatusLabel: String

    static let required = HFPlaybackDescriptorExpiryPolicy(
        title: "Playback descriptor expiry policy",
        detail: "Backend descriptors must include expires_at and refresh_after contract fields.",
        expiredStatusLabel: "Descriptor expired",
        refreshStatusLabel: "Descriptor refresh required"
    )
}

struct HFBackendPlaybackDescriptorPolicy: Codable, Equatable {
    let entitlementEndpoint: HFBackendPlaybackDescriptorEndpoint
    let playbackEndpoint: HFBackendPlaybackDescriptorEndpoint
    let signedPlaybackPolicy: HFCloudflareSignedPlaybackPolicy
    let expiryPolicy: HFPlaybackDescriptorExpiryPolicy
    let backendURLPolicy: String
    let localFallbackPolicy: String

    static let staging = HFBackendPlaybackDescriptorPolicy(
        entitlementEndpoint: .entitlementValidation,
        playbackEndpoint: .playbackDescriptor,
        signedPlaybackPolicy: .serverSideOnly,
        expiryPolicy: .required,
        backendURLPolicy: "No backend URL committed",
        localFallbackPolicy: "Local Preview fallback active"
    )
}

struct HFBackendEntitlementValidationRequest: Codable, Equatable {
    let userID: String?
    let anonymousSessionID: String
    let movieID: String
    let storeKitProductID: String
    let entitlementContext: HFPlaybackDescriptorEntitlementContext
    let playbackProvider: HFStreamingProvider
    let deviceContext: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case anonymousSessionID = "anonymous_session_id"
        case movieID = "movie_id"
        case storeKitProductID = "storekit_product_id"
        case entitlementContext = "entitlement_context"
        case playbackProvider = "playback_provider"
        case deviceContext = "device_context"
    }
}

struct HFBackendEntitlementValidationResponse: Codable, Equatable {
    let entitlementStatus: HFServerEntitlementValidationState
    let accessDecision: HFPlaybackAccessDecision
    let denialReason: String?
    let auditID: String
    let detail: String

    enum CodingKeys: String, CodingKey {
        case entitlementStatus = "entitlement_status"
        case accessDecision = "access_decision"
        case denialReason = "denial_reason"
        case auditID = "audit_id"
        case detail
    }
}

struct HFBackendPlaybackDescriptorRequest: Codable, Equatable {
    let entitlementRequest: HFBackendEntitlementValidationRequest
    let descriptorAccessRequest: HFPlaybackDescriptorAccessRequest
    let endpoint: HFBackendPlaybackDescriptorEndpoint
    let policy: HFBackendPlaybackDescriptorPolicy

    enum CodingKeys: String, CodingKey {
        case entitlementRequest = "entitlement_request"
        case descriptorAccessRequest = "descriptor_access_request"
        case endpoint
        case policy
    }
}

struct HFBackendPlaybackDescriptorResponse: Codable, Equatable {
    static let playbackURLOrTokenReferenceField = "playback_url_or_token_reference"

    let entitlementResponse: HFBackendEntitlementValidationResponse
    let playbackDescriptorStatus: HFPlaybackDescriptorStatus
    let playbackURLOrTokenReference: String?
    let expiresAt: String?
    let refreshAfter: String?
    let denialReason: String?
    let auditID: String
    let error: HFBackendPlaybackDescriptorError?
    let detail: String

    enum CodingKeys: String, CodingKey {
        case entitlementResponse = "entitlement_response"
        case playbackDescriptorStatus = "playback_descriptor_status"
        case playbackURLOrTokenReference = "playback_url_or_token_reference"
        case expiresAt = "expires_at"
        case refreshAfter = "refresh_after"
        case denialReason = "denial_reason"
        case auditID = "audit_id"
        case error
        case detail
    }
}

struct HFPlaybackDescriptorAuditRecord: Identifiable, Codable, Equatable {
    let id: String
    let movieID: String
    let userID: String?
    let storeKitProductID: String
    let entitlementStatus: HFServerEntitlementValidationState
    let playbackDescriptorStatus: HFPlaybackDescriptorStatus
    let detail: String
}

struct HFBackendPlaybackDescriptorContract: Codable, Equatable {
    let movieID: String
    let productIdentifier: HFProductIdentifier
    let entitlementValidationRequest: HFBackendEntitlementValidationRequest
    let entitlementValidationResponse: HFBackendEntitlementValidationResponse
    let playbackDescriptorRequest: HFBackendPlaybackDescriptorRequest
    let playbackDescriptorResponse: HFBackendPlaybackDescriptorResponse
    let policy: HFBackendPlaybackDescriptorPolicy
    let auditRecord: HFPlaybackDescriptorAuditRecord
    let statusLabel: String
    let detail: String

    static func staged(
        movieID: String,
        userID: String?,
        anonymousSessionID: String,
        context: HFPlaybackDescriptorEntitlementContext,
        descriptorAccessRequest: HFPlaybackDescriptorAccessRequest,
        descriptorStatus: HFPlaybackDescriptorStatus,
        entitlementState: HFServerEntitlementValidationState,
        hasCompleteRuntimeConfig: Bool
    ) -> HFBackendPlaybackDescriptorContract {
        let policy = HFBackendPlaybackDescriptorPolicy.staging
        let entitlementRequest = HFBackendEntitlementValidationRequest(
            userID: userID,
            anonymousSessionID: anonymousSessionID,
            movieID: movieID,
            storeKitProductID: context.productReference.productIdentifier.rawValue,
            entitlementContext: context,
            playbackProvider: descriptorAccessRequest.provider,
            deviceContext: "iOS Simulator staging contract"
        )
        let entitlementResponse = HFBackendEntitlementValidationResponse(
            entitlementStatus: entitlementState,
            accessDecision: context.playbackAccessDecision,
            denialReason: entitlementState == .denied ? "Entitlement denied" : nil,
            auditID: "audit-\(movieID)",
            detail: entitlementState.statusLabel
        )
        let descriptorError: HFBackendPlaybackDescriptorError? = hasCompleteRuntimeConfig ? nil : .unavailable
        let descriptorResponse = HFBackendPlaybackDescriptorResponse(
            entitlementResponse: entitlementResponse,
            playbackDescriptorStatus: hasCompleteRuntimeConfig ? .stagingDescriptorReady : descriptorStatus,
            playbackURLOrTokenReference: nil,
            expiresAt: nil,
            refreshAfter: nil,
            denialReason: entitlementResponse.denialReason,
            auditID: entitlementResponse.auditID,
            error: descriptorError,
            detail: hasCompleteRuntimeConfig ? "Playback descriptor contract ready" : "Playback descriptor unavailable"
        )
        let audit = HFPlaybackDescriptorAuditRecord(
            id: entitlementResponse.auditID,
            movieID: movieID,
            userID: userID,
            storeKitProductID: context.productReference.productIdentifier.rawValue,
            entitlementStatus: entitlementState,
            playbackDescriptorStatus: descriptorResponse.playbackDescriptorStatus,
            detail: "Backend entitlement validation required; backend playback descriptor endpoint required."
        )
        return HFBackendPlaybackDescriptorContract(
            movieID: movieID,
            productIdentifier: context.productReference.productIdentifier,
            entitlementValidationRequest: entitlementRequest,
            entitlementValidationResponse: entitlementResponse,
            playbackDescriptorRequest: HFBackendPlaybackDescriptorRequest(
                entitlementRequest: entitlementRequest,
                descriptorAccessRequest: descriptorAccessRequest,
                endpoint: .playbackDescriptor,
                policy: policy
            ),
            playbackDescriptorResponse: descriptorResponse,
            policy: policy,
            auditRecord: audit,
            statusLabel: hasCompleteRuntimeConfig ? "Playback descriptor contract ready" : "Local Preview fallback active",
            detail: hasCompleteRuntimeConfig ? "Contract models are ready for backend integration." : "Missing backend, entitlement, or playback config keeps Local Preview fallback active."
        )
    }
}

import Foundation

enum HFStreamingProvider: String, Codable, Equatable {
    case localPreview
    case cloudflareStream
    case mux
    case custom
}

enum HFPlaybackDescriptorStatus: String, Codable, Equatable {
    case localPreviewReady
    case providerDescriptorMissing
    case stagingDescriptorReady
    case streamingProviderNotConnected

    var statusLabel: String {
        switch self {
        case .localPreviewReady:
            return "Local Preview Ready"
        case .providerDescriptorMissing:
            return "Provider Descriptor Missing"
        case .stagingDescriptorReady:
            return "Staging Descriptor Ready"
        case .streamingProviderNotConnected:
            return "Streaming Provider Not Connected Yet"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .localPreviewReady:
            return "hf.streaming.localPreviewReady"
        case .providerDescriptorMissing:
            return "hf.streaming.providerDescriptorMissing"
        case .stagingDescriptorReady:
            return "hf.streaming.stagingDescriptorReady"
        case .streamingProviderNotConnected:
            return "hf.streaming.notConnected"
        }
    }
}

struct HFStreamingProviderConfiguration: Equatable {
    static let providerKey = "HIGHFIVE_STREAMING_PROVIDER"
    static let modeKey = "HIGHFIVE_STREAMING_MODE"
    static let descriptorBaseURLKey = "HIGHFIVE_PLAYBACK_DESCRIPTOR_BASE_URL"
    static let cloudflareAccountIDKey = "HIGHFIVE_CLOUDFLARE_STREAM_ACCOUNT_ID"
    static let muxEnvironmentKey = "HIGHFIVE_MUX_ENVIRONMENT_KEY"

    let requestedProvider: String?
    let requestedMode: String?
    let descriptorBaseURL: String?
    let cloudflareAccountID: String?
    let muxEnvironmentKey: String?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        requestedProvider = Self.nonEmpty(environment[Self.providerKey])
        requestedMode = Self.nonEmpty(environment[Self.modeKey])
        descriptorBaseURL = Self.nonEmpty(environment[Self.descriptorBaseURLKey])
        cloudflareAccountID = Self.nonEmpty(environment[Self.cloudflareAccountIDKey])
        muxEnvironmentKey = Self.nonEmpty(environment[Self.muxEnvironmentKey])
    }

    var hasAnyRuntimeConfig: Bool {
        requestedProvider != nil || requestedMode != nil || descriptorBaseURL != nil || cloudflareAccountID != nil || muxEnvironmentKey != nil
    }

    var hasCompleteRuntimeConfig: Bool {
        descriptorBaseURL != nil && requestedProvider != nil && (cloudflareAccountID != nil || muxEnvironmentKey != nil)
    }

    var preferredProvider: HFStreamingProvider {
        guard let provider = requestedProvider?.lowercased() else { return .cloudflareStream }
        if provider.contains("mux") { return .mux }
        if provider.contains("custom") { return .custom }
        return .cloudflareStream
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

struct HFProviderAssetMapping: Codable, Identifiable, Equatable {
    let id: String
    let movieID: String
    let provider: HFStreamingProvider
    let providerAssetID: String?
    let localPreviewAssetName: String?
}

struct HFPlaybackDescriptor: Codable, Identifiable, Equatable {
    let id: String
    let movieID: String
    let title: String
    let status: HFPlaybackDescriptorStatus
    let provider: HFStreamingProvider
    let providerAssetMapping: HFProviderAssetMapping
    let detail: String
    let boundary: HFPlaybackSourceBoundary
}

struct HFPlaybackDescriptorRequest: Codable, Equatable {
    let movieID: String
    let profileID: String?
}

struct HFPlaybackDescriptorResponse: Codable, Equatable {
    let descriptor: HFPlaybackDescriptor?
    let status: HFPlaybackDescriptorStatus
}

enum HFPlaybackDescriptorGateStatus: String, Codable, Equatable {
    case localPreviewAccess
    case entitlementGateRequired
    case backendDescriptorRequired
    case cloudflareDescriptorNotConnected
    case cloudflareDescriptorReady
    case storeKitProductMappingRequired
    case serverEntitlementValidationRequired

    var statusLabel: String {
        switch self {
        case .localPreviewAccess:
            return "Local Preview Access"
        case .entitlementGateRequired:
            return "Entitlement gate required"
        case .backendDescriptorRequired:
            return "Backend descriptor required"
        case .cloudflareDescriptorNotConnected:
            return "Cloudflare descriptor not connected"
        case .cloudflareDescriptorReady:
            return "Cloudflare descriptor ready"
        case .storeKitProductMappingRequired:
            return "StoreKit product mapping required"
        case .serverEntitlementValidationRequired:
            return "Server entitlement validation required"
        }
    }
}

struct HFBackendPlaybackDescriptorRequirement: Codable, Equatable {
    let title: String
    let detail: String
    let status: HFPlaybackDescriptorGateStatus

    static let required = HFBackendPlaybackDescriptorRequirement(
        title: "Backend descriptor required",
        detail: "Backend-mediated playback only. The app never builds Cloudflare URLs or signed playback credentials.",
        status: .backendDescriptorRequired
    )
}

enum HFCloudflarePlaybackDescriptorState: String, Codable, Equatable {
    case notConnected
    case ready

    var statusLabel: String {
        switch self {
        case .notConnected:
            return "Cloudflare descriptor not connected"
        case .ready:
            return "Cloudflare descriptor ready"
        }
    }
}

struct HFPlaybackDescriptorEntitlementGate: Codable, Equatable {
    let movieID: String
    let productIdentifier: HFProductIdentifier
    let requirement: HFMovieEntitlementRequirement
    let accessDecision: HFPlaybackAccessDecision
    let status: HFPlaybackDescriptorGateStatus
    let detail: String
}

struct HFPlaybackDescriptorAccessRequest: Codable, Equatable {
    let movieID: String
    let profileID: String?
    let productIdentifier: HFProductIdentifier
    let provider: HFStreamingProvider
    let entitlementRequirement: HFMovieEntitlementRequirement
    let backendRequirement: HFBackendPlaybackDescriptorRequirement
}

struct HFPlaybackDescriptorAccessResponse: Codable, Equatable {
    let request: HFPlaybackDescriptorAccessRequest
    let descriptor: HFPlaybackDescriptor
    let gate: HFPlaybackDescriptorEntitlementGate
    let gateStatus: HFPlaybackDescriptorGateStatus
    let cloudflareState: HFCloudflarePlaybackDescriptorState
    let auditContext: HFEntitlementPlaybackAuditContext
    let detail: String
}

struct HFEntitlementPlaybackAuditContext: Codable, Equatable {
    let movieID: String
    let flow: String
    let entitlementStatus: String
    let descriptorStatus: String
    let noCloudflareTokenInApp: String
    let localFallback: String
}

struct HFEntitlementGatedPlaybackDescriptorService {
    let streamingConfiguration: HFStreamingProviderConfiguration
    let entitlementConfiguration: HFEntitlementConfiguration

    func accessResponse(
        request: HFPlaybackDescriptorAccessRequest,
        descriptor: HFPlaybackDescriptor,
        context: HFPlaybackDescriptorEntitlementContext,
        entitlementRuntimeStatus: HFEntitlementRuntimeStatus
    ) -> HFPlaybackDescriptorAccessResponse {
        let cloudflareState = cloudflareState(for: descriptor)
        let gateStatus = gateStatus(
            descriptor: descriptor,
            context: context,
            entitlementRuntimeStatus: entitlementRuntimeStatus,
            cloudflareState: cloudflareState
        )
        let gate = HFPlaybackDescriptorEntitlementGate(
            movieID: request.movieID,
            productIdentifier: request.productIdentifier,
            requirement: context.entitlementRequirement,
            accessDecision: context.playbackAccessDecision,
            status: gateStatus,
            detail: "Playback descriptor requires entitlement. Backend descriptor required before Cloudflare descriptor readiness can be used."
        )
        let audit = HFEntitlementPlaybackAuditContext(
            movieID: request.movieID,
            flow: "Movie ID -> StoreKit product -> entitlement decision -> backend descriptor -> Cloudflare playback descriptor",
            entitlementStatus: entitlementRuntimeStatus.accessState.statusLabel,
            descriptorStatus: descriptor.status.statusLabel,
            noCloudflareTokenInApp: "No Cloudflare token in app",
            localFallback: "Local Preview Access"
        )
        return HFPlaybackDescriptorAccessResponse(
            request: request,
            descriptor: descriptor,
            gate: gate,
            gateStatus: gateStatus,
            cloudflareState: cloudflareState,
            auditContext: audit,
            detail: "Entitlement gate required. Backend-mediated playback only. Local Preview Access remains available."
        )
    }

    private func cloudflareState(for descriptor: HFPlaybackDescriptor) -> HFCloudflarePlaybackDescriptorState {
        descriptor.status == .stagingDescriptorReady ? .ready : .notConnected
    }

    private func gateStatus(
        descriptor: HFPlaybackDescriptor,
        context: HFPlaybackDescriptorEntitlementContext,
        entitlementRuntimeStatus: HFEntitlementRuntimeStatus,
        cloudflareState: HFCloudflarePlaybackDescriptorState
    ) -> HFPlaybackDescriptorGateStatus {
        guard streamingConfiguration.hasAnyRuntimeConfig else {
            return .localPreviewAccess
        }

        guard context.productReference.readiness != .productIDRequired else {
            return .storeKitProductMappingRequired
        }

        guard entitlementConfiguration.hasCompleteRuntimeConfig,
              entitlementRuntimeStatus.accessState == .entitlementConfigured else {
            return .serverEntitlementValidationRequired
        }

        guard streamingConfiguration.hasCompleteRuntimeConfig else {
            return .backendDescriptorRequired
        }

        guard descriptor.status == .stagingDescriptorReady, cloudflareState == .ready else {
            return .cloudflareDescriptorNotConnected
        }

        return .cloudflareDescriptorReady
    }
}

struct HFPlaybackSourceBoundary: Codable, Equatable {
    let title: String
    let detail: String

    static let backendMediated = HFPlaybackSourceBoundary(
        title: "Backend-mediated playback only",
        detail: "Playback descriptors must come through the backend boundary. No raw provider SDK, provider token, or hardcoded media URL is used in app code."
    )
}

struct HFStreamingProviderStatus: Codable, Equatable {
    let status: HFPlaybackDescriptorStatus
    let provider: HFStreamingProvider
    let title: String
    let detail: String
    let systemImage: String
    let accessibilityIdentifier: String

    static let localPreviewReady = HFStreamingProviderStatus(
        status: .localPreviewReady,
        provider: .localPreview,
        title: "Streaming Provider",
        detail: "No streaming provider connected. Local preview remains the default playback fallback.",
        systemImage: "play.rectangle.fill",
        accessibilityIdentifier: "hf.streaming.localPreviewReady"
    )
}

protocol HFPlaybackSourceResolver {
    func descriptor(for movieID: String, title: String) -> HFPlaybackDescriptor
}

struct HFLocalPreviewPlaybackResolver: HFPlaybackSourceResolver {
    private let localPreviewIDs: Set<String>

    init(localPreviewIDs: Set<String> = ["friendly", "paranormall-s1"]) {
        self.localPreviewIDs = localPreviewIDs
    }

    func descriptor(for movieID: String, title: String) -> HFPlaybackDescriptor {
        let isLocalPreview = localPreviewIDs.contains(movieID)
        let status: HFPlaybackDescriptorStatus = isLocalPreview ? .localPreviewReady : .streamingProviderNotConnected
        return HFPlaybackDescriptor(
            id: "local-preview-\(movieID)",
            movieID: movieID,
            title: title,
            status: status,
            provider: .localPreview,
            providerAssetMapping: HFProviderAssetMapping(
                id: "asset-map-\(movieID)",
                movieID: movieID,
                provider: .localPreview,
                providerAssetID: nil,
                localPreviewAssetName: isLocalPreview ? movieID : nil
            ),
            detail: isLocalPreview ? "Local Preview Ready" : "Streaming Provider Not Connected Yet",
            boundary: .backendMediated
        )
    }
}

struct HFRemotePlaybackDescriptorGateway {
    let configuration: HFStreamingProviderConfiguration

    func descriptor(
        for request: HFPlaybackDescriptorRequest,
        title: String,
        response: HFPlaybackDescriptorResponse? = nil
    ) -> HFPlaybackDescriptor {
        guard configuration.hasAnyRuntimeConfig else {
            return HFLocalPreviewPlaybackResolver().descriptor(for: request.movieID, title: title)
        }

        guard configuration.hasCompleteRuntimeConfig else {
            return missingDescriptor(movieID: request.movieID, title: title)
        }

        if let descriptor = response?.descriptor, response?.status == .stagingDescriptorReady {
            return descriptor
        }

        return missingDescriptor(movieID: request.movieID, title: title)
    }

    private func missingDescriptor(movieID: String, title: String) -> HFPlaybackDescriptor {
        HFPlaybackDescriptor(
            id: "provider-descriptor-\(movieID)",
            movieID: movieID,
            title: title,
            status: .providerDescriptorMissing,
            provider: configuration.preferredProvider,
            providerAssetMapping: HFProviderAssetMapping(
                id: "provider-map-\(movieID)",
                movieID: movieID,
                provider: configuration.preferredProvider,
                providerAssetID: nil,
                localPreviewAssetName: nil
            ),
            detail: "Provider Descriptor Missing",
            boundary: .backendMediated
        )
    }
}

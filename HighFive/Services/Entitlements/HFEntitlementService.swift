import Foundation

struct HFProductIdentifier: Codable, Hashable, Equatable {
    let rawValue: String

    static let localPreview = HFProductIdentifier(rawValue: "local-preview-access")
    static let appUnlock = HFProductIdentifier(rawValue: "com.highfive.app.unlock")
    static let theFriendlyMovie = HFProductIdentifier(rawValue: "com.highfive.movie.thefriendly")
    static let paranormallSeasonOne = HFProductIdentifier(rawValue: "com.highfive.series.paranormall.season1")

    static func paranormallEpisode(_ episodeNumber: Int) -> HFProductIdentifier {
        HFProductIdentifier(rawValue: "com.highfive.episode.paranormall.e\(episodeNumber)")
    }
}

enum HFStoreKitProductKind: String, Codable, Equatable {
    case appUnlock
    case movie
    case season
    case episode
}

struct HFStoreKitProductMapping: Identifiable, Codable, Equatable {
    let id: String
    let currentMovieID: String
    let sourceMovieID: String
    let productIdentifier: HFProductIdentifier
    let referenceName: String
    let displayPrice: String
    let kind: HFStoreKitProductKind
    let detail: String

    var statusLabel: String {
        "StoreKit product mapped"
    }
}

struct HFStoreKitProductReference: Identifiable, Codable, Equatable {
    let id: String
    let productIdentifier: HFProductIdentifier
    let referenceName: String
    let displayPrice: String
    let readiness: HFStoreKitProductReadiness
}

enum HFMovieEntitlementRequirement: String, Codable, Equatable {
    case localPreviewAccess
    case storeKitProductMapping
    case serverEntitlementValidation
    case productIDRequired

    var statusLabel: String {
        switch self {
        case .localPreviewAccess:
            return "Local Preview Access"
        case .storeKitProductMapping:
            return "StoreKit product mapping"
        case .serverEntitlementValidation:
            return "Entitlement validation required"
        case .productIDRequired:
            return "Product ID required"
        }
    }
}

enum HFPlaybackAccessDecision: String, Codable, Equatable {
    case localPreviewAccess
    case playbackDescriptorRequiresEntitlement
    case cloudflarePlaybackRequiresBackendDescriptor
    case entitlementValidationRequired

    var statusLabel: String {
        switch self {
        case .localPreviewAccess:
            return "Local Preview Access"
        case .playbackDescriptorRequiresEntitlement:
            return "Playback descriptor requires entitlement"
        case .cloudflarePlaybackRequiresBackendDescriptor:
            return "Cloudflare playback requires backend descriptor"
        case .entitlementValidationRequired:
            return "Entitlement validation required"
        }
    }
}

enum HFPaywallReadinessState: String, Codable, Equatable {
    case localPreviewAccess
    case paywallReadiness
    case productIDRequired
    case paymentProviderNotConnected
    case restorePurchasesNotActiveYet

    var statusLabel: String {
        switch self {
        case .localPreviewAccess:
            return "Local Preview Access"
        case .paywallReadiness:
            return "Paywall readiness"
        case .productIDRequired:
            return "Product ID required"
        case .paymentProviderNotConnected:
            return "Payment Provider Not Connected Yet"
        case .restorePurchasesNotActiveYet:
            return "Restore Purchases Not Active Yet"
        }
    }
}

enum HFStoreKitProductReadiness: String, Codable, Equatable {
    case mappedFromSource
    case productIDRequired

    var statusLabel: String {
        switch self {
        case .mappedFromSource:
            return "StoreKit product mapping"
        case .productIDRequired:
            return "Product ID required"
        }
    }
}

struct HFCloudflarePlaybackReference: Codable, Equatable {
    let provider: HFStreamingProvider
    let providerAssetID: String?
    let statusLabel: String
    let detail: String

    static let descriptorRequired = HFCloudflarePlaybackReference(
        provider: .cloudflareStream,
        providerAssetID: nil,
        statusLabel: "Cloudflare playback requires backend descriptor",
        detail: "Cloudflare video UIDs and playback URLs are not committed in app code. Runtime playback must arrive through the backend descriptor boundary."
    )
}

struct HFPlaybackDescriptorEntitlementContext: Codable, Equatable {
    let movieID: String
    let productReference: HFStoreKitProductReference
    let entitlementRequirement: HFMovieEntitlementRequirement
    let playbackAccessDecision: HFPlaybackAccessDecision
    let cloudflareReference: HFCloudflarePlaybackReference
    let detail: String
}

struct HFMovieAccessRule: Identifiable, Codable, Equatable {
    let id: String
    let currentMovieID: String
    let sourceMovieID: String
    let title: String
    let productReference: HFStoreKitProductReference
    let entitlementRequirement: HFMovieEntitlementRequirement
    let paywallReadiness: HFPaywallReadinessState
    let playbackAccessDecision: HFPlaybackAccessDecision
    let cloudflareReference: HFCloudflarePlaybackReference
    let detail: String
}

enum HFStoreKitAccessMapping {
    static let placeholderProductID = HFProductIdentifier(rawValue: "<STOREKIT_PRODUCT_ID_REQUIRED>")
    static let placeholderCloudflareVideoUID = "<CLOUDFLARE_VIDEO_UID_REQUIRED>"

    static let fallbackRule = HFMovieAccessRule(
        id: "fallback-product-required",
        currentMovieID: "unmapped",
        sourceMovieID: "unmapped",
        title: "Unmapped catalog title",
        productReference: HFStoreKitProductReference(
            id: "product-required",
            productIdentifier: placeholderProductID,
            referenceName: "Product ID required",
            displayPrice: "Required",
            readiness: .productIDRequired
        ),
        entitlementRequirement: .productIDRequired,
        paywallReadiness: .productIDRequired,
        playbackAccessDecision: .localPreviewAccess,
        cloudflareReference: .descriptorRequired,
        detail: "Current catalog title has no verified StoreKit product mapping yet. Local Preview Access remains available."
    )

    static let rules: [HFMovieAccessRule] = [
        HFMovieAccessRule(
            id: "friendly",
            currentMovieID: "friendly",
            sourceMovieID: "the_friendly",
            title: "The Friendly",
            productReference: HFStoreKitProductReference(
                id: "friendly-product",
                productIdentifier: .theFriendlyMovie,
                referenceName: "The Friendly",
                displayPrice: "$4.99",
                readiness: .mappedFromSource
            ),
            entitlementRequirement: .serverEntitlementValidation,
            paywallReadiness: .paymentProviderNotConnected,
            playbackAccessDecision: .cloudflarePlaybackRequiresBackendDescriptor,
            cloudflareReference: .descriptorRequired,
            detail: "Friendly maps to the older the_friendly StoreKit product. Playback remains local until backend entitlement validation and Cloudflare descriptor readiness exist."
        ),
        HFMovieAccessRule(
            id: "paranormall-s1",
            currentMovieID: "paranormall-s1",
            sourceMovieID: "paranormall_s1",
            title: "Paranormall Season 1",
            productReference: HFStoreKitProductReference(
                id: "paranormall-season-product",
                productIdentifier: .paranormallSeasonOne,
                referenceName: "Paranormall Season 1",
                displayPrice: "$9.99",
                readiness: .mappedFromSource
            ),
            entitlementRequirement: .serverEntitlementValidation,
            paywallReadiness: .paymentProviderNotConnected,
            playbackAccessDecision: .cloudflarePlaybackRequiresBackendDescriptor,
            cloudflareReference: .descriptorRequired,
            detail: "Paranormall Season 1 maps to the older paranormall_s1 StoreKit season product. Episode products are mapped as source metadata only."
        )
    ]

    static func rule(forCurrentMovieID movieID: String) -> HFMovieAccessRule {
        rules.first { $0.currentMovieID == movieID } ?? fallbackRule
    }

    static func context(forCurrentMovieID movieID: String) -> HFPlaybackDescriptorEntitlementContext {
        let rule = rule(forCurrentMovieID: movieID)
        return HFPlaybackDescriptorEntitlementContext(
            movieID: movieID,
            productReference: rule.productReference,
            entitlementRequirement: rule.entitlementRequirement,
            playbackAccessDecision: rule.playbackAccessDecision,
            cloudflareReference: rule.cloudflareReference,
            detail: "Movie ID -> Product / entitlement rule -> Playback access decision -> Cloudflare descriptor readiness is staged. Local Preview Access remains available."
        )
    }
}

enum HFStoreKitPaywallCatalog {
    static let sourceProjectName = "May 24th 917 "
    static let sourcePaywallBundleName = "HigherKey_UI_Library_Paywall_LUT_Restore_Bundle"

    static let mappings: [HFStoreKitProductMapping] = [
        HFStoreKitProductMapping(
            id: "app-unlock",
            currentMovieID: "app",
            sourceMovieID: "app",
            productIdentifier: .appUnlock,
            referenceName: "HighFive App Unlock",
            displayPrice: "$0.00",
            kind: .appUnlock,
            detail: "Imported from the older app unlock paywall source as catalog metadata only."
        ),
        HFStoreKitProductMapping(
            id: "friendly",
            currentMovieID: "friendly",
            sourceMovieID: "the_friendly",
            productIdentifier: .theFriendlyMovie,
            referenceName: "The Friendly",
            displayPrice: "$4.99",
            kind: .movie,
            detail: "Current movie ID friendly maps to old movie ID the_friendly."
        ),
        HFStoreKitProductMapping(
            id: "paranormall-s1",
            currentMovieID: "paranormall-s1",
            sourceMovieID: "paranormall_s1",
            productIdentifier: .paranormallSeasonOne,
            referenceName: "Paranormall Season 1",
            displayPrice: "$9.99",
            kind: .season,
            detail: "Current movie ID paranormall-s1 maps to old season ID paranormall_s1."
        )
    ] + (1...7).map { episodeNumber in
        HFStoreKitProductMapping(
            id: "paranormall-s1-e\(episodeNumber)",
            currentMovieID: "paranormall-s1",
            sourceMovieID: "paranormall_s1_e\(episodeNumber)",
            productIdentifier: .paranormallEpisode(episodeNumber),
            referenceName: "Paranormall Episode \(episodeNumber)",
            displayPrice: "$1.99",
            kind: .episode,
            detail: "Episode product from the older paywall source. Current catalog keeps season-level local preview until episode records are modeled."
        )
    }

    static func mapping(forCurrentMovieID movieID: String) -> HFStoreKitProductMapping? {
        mappings.first { $0.currentMovieID == movieID && $0.kind != .episode }
    }

    static func episodeMappings(forCurrentMovieID movieID: String) -> [HFStoreKitProductMapping] {
        mappings.filter { $0.currentMovieID == movieID && $0.kind == .episode }
    }
}

enum HFPaymentProvider: String, Codable, Equatable {
    case localPreview
    case revenueCat
    case storeKit
    case stripeWebFallback
    case custom
}

enum HFEntitlementProvider: String, Codable, Equatable {
    case localPreview
    case backendValidated
    case notConnected
}

enum HFProductAccessState: String, Codable, Equatable {
    case localPreviewAccess
    case accessReady
    case paymentProviderNotConnected
    case purchaseProviderMissing
    case entitlementProviderMissing
    case entitlementConfigured
    case serverEntitlementValidationRequired

    var statusLabel: String {
        switch self {
        case .localPreviewAccess:
            return "Local Preview Access"
        case .accessReady:
            return "Access Ready"
        case .paymentProviderNotConnected:
            return "Payment Provider Not Connected Yet"
        case .purchaseProviderMissing:
            return "Purchase Provider Missing"
        case .entitlementProviderMissing:
            return "Entitlement Provider Missing"
        case .entitlementConfigured:
            return "Entitlement Configured"
        case .serverEntitlementValidationRequired:
            return "Server Entitlement Validation Required"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .localPreviewAccess:
            return "hf.entitlement.localPreviewAccess"
        case .paymentProviderNotConnected:
            return "hf.entitlement.paymentProviderNotConnected"
        case .serverEntitlementValidationRequired:
            return "hf.entitlement.serverValidationRequired"
        default:
            return "hf.entitlement.status"
        }
    }
}

enum HFRestorePurchaseState: String, Codable, Equatable {
    case notActiveYet
    case providerMissing
    case validationRequired

    var statusLabel: String {
        switch self {
        case .notActiveYet:
            return "Restore Purchases Not Active Yet"
        case .providerMissing:
            return "Purchase Provider Missing"
        case .validationRequired:
            return "Server Entitlement Validation Required"
        }
    }
}

struct HFPurchaseEligibility: Codable, Equatable {
    let isEligible: Bool
    let statusLabel: String
    let detail: String

    static let localPreview = HFPurchaseEligibility(
        isEligible: false,
        statusLabel: "Payment Provider Not Connected Yet",
        detail: "Purchase readiness is staged only. No live purchase, StoreKit transaction, or paywall is active."
    )
}

struct HFEntitlementBoundary: Codable, Equatable {
    let title: String
    let detail: String

    static let pricing = HFEntitlementBoundary(
        title: "Pricing / entitlement boundary",
        detail: "Server Entitlement Validation Required before paid access, restore, refunds, revocations, or expired entitlement handling can ship."
    )
}

struct HFEntitlementConfiguration: Equatable {
    static let paymentProviderKey = "HIGHFIVE_PAYMENT_PROVIDER"
    static let paymentModeKey = "HIGHFIVE_PAYMENT_MODE"
    static let entitlementBaseURLKey = "HIGHFIVE_ENTITLEMENT_BASE_URL"
    static let storeKitProductNamespaceKey = "HIGHFIVE_STOREKIT_PRODUCT_NAMESPACE"
    static let revenueCatProjectIDKey = "HIGHFIVE_REVENUECAT_PROJECT_ID"

    let requestedPaymentProvider: String?
    let requestedPaymentMode: String?
    let entitlementBaseURL: String?
    let storeKitProductNamespace: String?
    let revenueCatProjectID: String?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        requestedPaymentProvider = Self.nonEmpty(environment[Self.paymentProviderKey])
        requestedPaymentMode = Self.nonEmpty(environment[Self.paymentModeKey])
        entitlementBaseURL = Self.nonEmpty(environment[Self.entitlementBaseURLKey])
        storeKitProductNamespace = Self.nonEmpty(environment[Self.storeKitProductNamespaceKey])
        revenueCatProjectID = Self.nonEmpty(environment[Self.revenueCatProjectIDKey])
    }

    var hasAnyRuntimeConfig: Bool {
        requestedPaymentProvider != nil
            || requestedPaymentMode != nil
            || entitlementBaseURL != nil
            || storeKitProductNamespace != nil
            || revenueCatProjectID != nil
    }

    var hasCompleteRuntimeConfig: Bool {
        requestedPaymentProvider != nil
            && requestedPaymentMode != nil
            && entitlementBaseURL != nil
            && storeKitProductNamespace != nil
            && revenueCatProjectID != nil
    }

    var preferredPaymentProvider: HFPaymentProvider {
        guard let provider = requestedPaymentProvider?.lowercased() else { return .localPreview }
        if provider.contains("revenue") { return .revenueCat }
        if provider.contains("store") { return .storeKit }
        if provider.contains("stripe") { return .stripeWebFallback }
        if provider.contains("custom") { return .custom }
        return .localPreview
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

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
            state: "Local Preview Access",
            detail: "No live payment provider is connected."
        )
    }
}

struct HFEntitlementRuntimeStatus: Codable, Equatable {
    let accessState: HFProductAccessState
    let restoreState: HFRestorePurchaseState
    let purchaseEligibility: HFPurchaseEligibility
    let paymentProvider: HFPaymentProvider
    let entitlementProvider: HFEntitlementProvider
    let boundary: HFEntitlementBoundary
    let detail: String

    var statusLabel: String {
        accessState.statusLabel
    }

    var paymentProviderLabel: String {
        switch accessState {
        case .entitlementConfigured:
            return "Entitlement Configured"
        case .purchaseProviderMissing:
            return "Purchase Provider Missing"
        case .entitlementProviderMissing:
            return "Entitlement Provider Missing"
        default:
            return "Payment Provider Not Connected Yet"
        }
    }
}

protocol HFEntitlementService {
    func entitlement(userID: String, titleID: String?) async throws -> HFEntitlementState
    func runtimeStatus(userID: String, titleID: String?) -> HFEntitlementRuntimeStatus
}

struct HFLocalEntitlementAdapter: HFEntitlementService {
    func entitlement(userID: String, titleID: String?) async throws -> HFEntitlementState {
        HFEntitlementState.localPreview(userID: userID, titleID: titleID)
    }

    func runtimeStatus(userID: String, titleID: String?) -> HFEntitlementRuntimeStatus {
        HFEntitlementRuntimeStatus(
            accessState: .localPreviewAccess,
            restoreState: .notActiveYet,
            purchaseEligibility: .localPreview,
            paymentProvider: .localPreview,
            entitlementProvider: .localPreview,
            boundary: .pricing,
            detail: "Local Preview Access remains active. Payment Provider Not Connected Yet."
        )
    }
}

struct HFRemoteEntitlementGateway: HFEntitlementService {
    let configuration: HFEntitlementConfiguration

    func entitlement(userID: String, titleID: String?) async throws -> HFEntitlementState {
        HFEntitlementState.localPreview(userID: userID, titleID: titleID)
    }

    func runtimeStatus(userID: String, titleID: String?) -> HFEntitlementRuntimeStatus {
        guard configuration.hasAnyRuntimeConfig else {
            return HFLocalEntitlementAdapter().runtimeStatus(userID: userID, titleID: titleID)
        }

        guard configuration.hasCompleteRuntimeConfig else {
            return HFEntitlementRuntimeStatus(
                accessState: .purchaseProviderMissing,
                restoreState: .providerMissing,
                purchaseEligibility: .localPreview,
                paymentProvider: configuration.preferredPaymentProvider,
                entitlementProvider: .notConnected,
                boundary: .pricing,
                detail: "Purchase Provider Missing. Entitlement Provider Missing. Local Preview Access remains available."
            )
        }

        return HFEntitlementRuntimeStatus(
            accessState: .entitlementConfigured,
            restoreState: .validationRequired,
            purchaseEligibility: .localPreview,
            paymentProvider: configuration.preferredPaymentProvider,
            entitlementProvider: .backendValidated,
            boundary: .pricing,
            detail: "Entitlement Configured. Server Entitlement Validation Required before any live purchase or paid access claim."
        )
    }
}

enum HFEntitlementServiceFactory {
    static func make(configuration: HFEntitlementConfiguration = HFEntitlementConfiguration()) -> HFEntitlementService {
        configuration.hasAnyRuntimeConfig
            ? HFRemoteEntitlementGateway(configuration: configuration)
            : HFLocalEntitlementAdapter()
    }
}

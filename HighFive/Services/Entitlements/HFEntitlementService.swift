import Foundation

struct HFProductIdentifier: Codable, Hashable, Equatable {
    let rawValue: String

    static let localPreview = HFProductIdentifier(rawValue: "local-preview-access")
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

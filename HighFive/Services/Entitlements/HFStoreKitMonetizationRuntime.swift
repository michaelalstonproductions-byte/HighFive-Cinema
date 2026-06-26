import Foundation
import StoreKit

struct HFStoreKitRuntimeProduct: Identifiable, Codable, Equatable {
    let id: String
    var productID: String
    var displayName: String
    var displayPrice: String
    var kind: String
    var detail: String
}

struct HFStoreKitRuntimeEntitlement: Identifiable, Codable, Equatable {
    let id: String
    var productID: String
    var originalTransactionID: String
    var transactionID: String
    var status: String
    var expiresAt: String?
    var source: String
}

struct HFStoreKitRuntimeTransaction: Codable, Equatable {
    var productID: String
    var transactionID: String
    var originalTransactionID: String
    var environment: String
    var purchaseDate: String?
    var expirationDate: String?
    var revocationDate: String?
    var appAccountToken: String?
}

struct HFStoreKitRuntimeSnapshot: Codable, Equatable {
    var status: String
    var detail: String
    var productCount: Int
    var activeEntitlementCount: Int
    var restoreState: String
    var lastTransactionID: String?
    var updatedAt: String

    static let localUnavailable = HFStoreKitRuntimeSnapshot(
        status: "StoreKit Unconfigured",
        detail: "No StoreKit products were returned. Add a StoreKit configuration or App Store Connect products to test purchase flows.",
        productCount: 0,
        activeEntitlementCount: 0,
        restoreState: "Not Restored",
        lastTransactionID: nil,
        updatedAt: "Local"
    )
}

enum HFStoreKitMonetizationError: Error, LocalizedError {
    case productUnavailable(String)
    case unverifiedTransaction
    case purchaseCancelled
    case purchasePending

    var errorDescription: String? {
        switch self {
        case .productUnavailable(let productID):
            return "StoreKit product \(productID) is unavailable in the current configuration."
        case .unverifiedTransaction:
            return "StoreKit returned an unverified transaction."
        case .purchaseCancelled:
            return "Purchase was cancelled."
        case .purchasePending:
            return "Purchase is pending external approval."
        }
    }
}

struct HFStoreKitMonetizationRuntime {
    static let productIDs = [
        "com.highfive.pass.monthly",
        "com.highfive.pass.annual",
        "com.highfive.movie.thefriendly",
        "com.highfive.series.paranormall.season1"
    ]

    func loadProducts() async -> ([HFStoreKitRuntimeProduct], HFStoreKitRuntimeSnapshot) {
        do {
            let products = try await Product.products(for: Self.productIDs)
            let rows = products.map { product in
                HFStoreKitRuntimeProduct(
                    id: product.id,
                    productID: product.id,
                    displayName: product.displayName.isEmpty ? product.id : product.displayName,
                    displayPrice: product.displayPrice,
                    kind: String(describing: product.type),
                    detail: product.description.isEmpty ? "StoreKit 2 product loaded." : product.description
                )
            }
            let entitlements = await currentEntitlements()
            return (
                rows,
                HFStoreKitRuntimeSnapshot(
                    status: rows.isEmpty ? "StoreKit Unconfigured" : "StoreKit Ready",
                    detail: rows.isEmpty ? HFStoreKitRuntimeSnapshot.localUnavailable.detail : "StoreKit 2 returned \(rows.count) configured product records.",
                    productCount: rows.count,
                    activeEntitlementCount: entitlements.count,
                    restoreState: entitlements.isEmpty ? "No Active Entitlements" : "Active Entitlements",
                    lastTransactionID: entitlements.first?.transactionID,
                    updatedAt: Self.nowLabel()
                )
            )
        } catch {
            return (
                [],
                HFStoreKitRuntimeSnapshot(
                    status: "StoreKit Error",
                    detail: error.localizedDescription,
                    productCount: 0,
                    activeEntitlementCount: 0,
                    restoreState: "Not Restored",
                    lastTransactionID: nil,
                    updatedAt: Self.nowLabel()
                )
            )
        }
    }

    func currentEntitlements() async -> [HFStoreKitRuntimeEntitlement] {
        var rows: [HFStoreKitRuntimeEntitlement] = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                rows.append(Self.entitlement(from: transaction))
            }
        }
        return rows
    }

    func purchase(productID: String, appAccountToken: UUID? = nil) async throws -> HFStoreKitRuntimeTransaction {
        let products = try await Product.products(for: [productID])
        guard let product = products.first else {
            throw HFStoreKitMonetizationError.productUnavailable(productID)
        }
        let result: Product.PurchaseResult
        if let appAccountToken {
            result = try await product.purchase(options: [.appAccountToken(appAccountToken)])
        } else {
            result = try await product.purchase()
        }
        switch result {
        case .success(let verification):
            let transaction = try Self.verified(verification)
            await transaction.finish()
            return Self.transactionPayload(from: transaction, appAccountToken: appAccountToken?.uuidString)
        case .userCancelled:
            throw HFStoreKitMonetizationError.purchaseCancelled
        case .pending:
            throw HFStoreKitMonetizationError.purchasePending
        @unknown default:
            throw HFStoreKitMonetizationError.purchasePending
        }
    }

    func restoreEntitlements() async throws -> [HFStoreKitRuntimeEntitlement] {
        try await AppStore.sync()
        return await currentEntitlements()
    }

    func developmentTransaction(productID: String, userID: String) -> HFStoreKitRuntimeTransaction {
        let stable = "\(userID)-\(productID)".replacingOccurrences(of: ".", with: "-")
        return HFStoreKitRuntimeTransaction(
            productID: productID,
            transactionID: "development-\(stable)",
            originalTransactionID: "development-original-\(stable)",
            environment: "development",
            purchaseDate: Self.iso8601(Date()),
            expirationDate: Self.iso8601(Date().addingTimeInterval(30 * 24 * 60 * 60)),
            revocationDate: nil,
            appAccountToken: userID
        )
    }

    private static func verified<T>(_ verification: VerificationResult<T>) throws -> T {
        switch verification {
        case .verified(let safe):
            return safe
        case .unverified:
            throw HFStoreKitMonetizationError.unverifiedTransaction
        }
    }

    private static func entitlement(from transaction: Transaction) -> HFStoreKitRuntimeEntitlement {
        HFStoreKitRuntimeEntitlement(
            id: "\(transaction.id)",
            productID: transaction.productID,
            originalTransactionID: "\(transaction.originalID)",
            transactionID: "\(transaction.id)",
            status: transaction.revocationDate == nil ? "active" : "revoked",
            expiresAt: transaction.expirationDate.map(Self.iso8601),
            source: "storekit2"
        )
    }

    private static func transactionPayload(from transaction: Transaction, appAccountToken: String?) -> HFStoreKitRuntimeTransaction {
        HFStoreKitRuntimeTransaction(
            productID: transaction.productID,
            transactionID: "\(transaction.id)",
            originalTransactionID: "\(transaction.originalID)",
            environment: "sandbox",
            purchaseDate: iso8601(transaction.purchaseDate),
            expirationDate: transaction.expirationDate.map(Self.iso8601),
            revocationDate: transaction.revocationDate.map(Self.iso8601),
            appAccountToken: appAccountToken
        )
    }

    private static func nowLabel() -> String {
        DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    }

    private static func iso8601(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}

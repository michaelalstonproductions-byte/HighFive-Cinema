import Foundation

struct HFLocalBackendAdapter: HFBackendService {
    let configuration: HFBackendConfiguration

    func currentStatus() -> HFBackendRuntimeStatus {
        let services = serviceStatuses(state: .backendNotConfigured, statusLabel: "Backend Not Connected Yet")
        return HFBackendRuntimeStatus(
            mode: .local,
            connectionState: .localPreview,
            status: HFBackendServiceStatus(
                id: "backend-runtime",
                title: "Backend Runtime",
                detail: "Local Mode. Backend Not Connected Yet. Provider-ready service adapters are available without live provider calls.",
                state: .localPreview,
                statusLabel: "Local Mode",
                systemImage: "server.rack",
                accessibilityIdentifier: "hf.backend.status"
            ),
            services: services
        )
    }

    func accountStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "account", title: "Account", detail: "Local profile fallback active. Backend account provider not connected yet.", state: .backendNotConfigured, statusLabel: "Local Mode", systemImage: "person.crop.circle.fill", accessibilityIdentifier: "hf.backend.localMode")
    }

    func libraryStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "library", title: "Library", detail: "Saved titles stay local. Cloud Library backend is provider-ready.", state: .backendNotConfigured, statusLabel: "Backend Not Connected Yet", systemImage: "bookmark.fill", accessibilityIdentifier: "hf.library.backendStatus")
    }

    func downloadsStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "downloads", title: "Downloads", detail: "Offline state stays local. No real media downloads are active.", state: .backendNotConfigured, statusLabel: "Backend Not Connected Yet", systemImage: "arrow.down.circle.fill", accessibilityIdentifier: "hf.downloads.backendStatus")
    }

    func paymentStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "payments", title: "Payments", detail: "No live payment provider. Entitlement boundaries remain local.", state: .backendNotConfigured, statusLabel: "Backend Not Connected Yet", systemImage: "creditcard.fill", accessibilityIdentifier: "hf.payment.backendStatus")
    }

    func creatorStudioStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "creator-studio", title: "Creator Studio", detail: "Creator project state remains Local Draft. Backend service is provider-ready.", state: .backendNotConfigured, statusLabel: "Provider-ready", systemImage: "wand.and.stars", accessibilityIdentifier: "hf.creatorStudio.backendStatus")
    }

    func socialKitStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "social-kit", title: "Social Kit", detail: "Caption and platform plans stay local. No social posting is active.", state: .backendNotConfigured, statusLabel: "Backend Not Connected Yet", systemImage: "bubble.left.and.bubble.right.fill", accessibilityIdentifier: "hf.creatorStudio.socialBackendStatus")
    }

    func vodPackageStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "vod-package", title: "VOD", detail: "VOD package readiness stays local. No publishing, upload, or payment provider is active.", state: .backendNotConfigured, statusLabel: "Backend Not Connected Yet", systemImage: "shippingbox.fill", accessibilityIdentifier: "hf.creatorStudio.vodBackendStatus")
    }

    private func serviceStatuses(state: HFBackendConnectionState, statusLabel: String) -> [HFBackendServiceStatus] {
        [
            accountStatus(),
            libraryStatus(),
            downloadsStatus(),
            paymentStatus(),
            creatorStudioStatus(),
            socialKitStatus(),
            vodPackageStatus()
        ].map { status in
            if status.statusLabel == "Provider-ready" { return status }
            return HFBackendServiceStatus(
                id: status.id,
                title: status.title,
                detail: status.detail,
                state: state,
                statusLabel: statusLabel,
                systemImage: status.systemImage,
                accessibilityIdentifier: status.accessibilityIdentifier
            )
        }
    }

    private func serviceStatus(id: String, title: String, detail: String, state: HFBackendConnectionState, statusLabel: String, systemImage: String, accessibilityIdentifier: String) -> HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: id,
            title: title,
            detail: detail,
            state: state,
            statusLabel: statusLabel,
            systemImage: systemImage,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }
}

struct HFConfiguredBackendAdapter: HFBackendService {
    let configuration: HFBackendConfiguration

    func currentStatus() -> HFBackendRuntimeStatus {
        let state = configuration.connectionState
        let label = label(for: state)
        let services = [
            accountStatus(),
            libraryStatus(),
            downloadsStatus(),
            paymentStatus(),
            creatorStudioStatus(),
            socialKitStatus(),
            vodPackageStatus()
        ]

        return HFBackendRuntimeStatus(
            mode: configuration.mode,
            connectionState: state,
            status: HFBackendServiceStatus(
                id: "backend-runtime",
                title: "Backend Runtime",
                detail: detail(for: state),
                state: state,
                statusLabel: label,
                systemImage: state == .backendUnavailable ? "server.rack" : "checkmark.seal.fill",
                accessibilityIdentifier: accessibilityIdentifier(for: state)
            ),
            services: services
        )
    }

    func accountStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "account", title: "Account", detail: "Runtime configuration found. Account adapter is ready for staging validation.", systemImage: "person.crop.circle.fill", accessibilityIdentifier: "hf.backend.configured")
    }

    func libraryStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "library", title: "Library", detail: "Library adapter is backend-capable. No cloud sync request is made in this build.", systemImage: "bookmark.fill", accessibilityIdentifier: "hf.library.backendStatus")
    }

    func downloadsStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "downloads", title: "Downloads", detail: "Download policy adapter is backend-capable. No media downloads are active.", systemImage: "arrow.down.circle.fill", accessibilityIdentifier: "hf.downloads.backendStatus")
    }

    func paymentStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "payments", title: "Payments", detail: "Payment boundary is configured only. No live payment provider is active.", systemImage: "creditcard.fill", accessibilityIdentifier: "hf.payment.backendStatus")
    }

    func creatorStudioStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "creator-studio", title: "Creator Studio", detail: "Creator Studio adapter is ready for staging records once backend validation is approved.", systemImage: "wand.and.stars", accessibilityIdentifier: "hf.creatorStudio.backendStatus")
    }

    func socialKitStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "social-kit", title: "Social Kit", detail: "Social kit adapter is configured only. No live posting is active.", systemImage: "bubble.left.and.bubble.right.fill", accessibilityIdentifier: "hf.creatorStudio.socialBackendStatus")
    }

    func vodPackageStatus() -> HFBackendServiceStatus {
        configuredStatus(id: "vod-package", title: "VOD", detail: "VOD package adapter is configured only. No live publishing is active.", systemImage: "shippingbox.fill", accessibilityIdentifier: "hf.creatorStudio.vodBackendStatus")
    }

    private func configuredStatus(id: String, title: String, detail: String, systemImage: String, accessibilityIdentifier: String) -> HFBackendServiceStatus {
        let state = configuration.connectionState
        return HFBackendServiceStatus(
            id: id,
            title: title,
            detail: state == .credentialsMissing ? "Missing Credentials. \(detail)" : detail,
            state: state,
            statusLabel: label(for: state),
            systemImage: systemImage,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    private func label(for state: HFBackendConnectionState) -> String {
        switch state {
        case .readyForStaging:
            return "Staging Ready"
        case .backendConfigured:
            return "Backend Configured"
        case .credentialsMissing:
            return "Missing Credentials"
        case .backendUnavailable:
            return "Backend Not Connected Yet"
        case .backendNotConfigured:
            return "Backend Not Connected Yet"
        case .localPreview:
            return "Local Mode"
        }
    }

    private func detail(for state: HFBackendConnectionState) -> String {
        switch state {
        case .readyForStaging:
            return "Backend Configured. Runtime configuration is present for staging validation. No production verification is claimed."
        case .backendConfigured:
            return "Backend Configured. Runtime configuration is present. No live provider request is made in this build."
        case .credentialsMissing:
            return "Missing Credentials. Add complete runtime configuration to leave Local Mode."
        case .backendUnavailable:
            return "Backend Not Connected Yet. Runtime mode marks backend unavailable."
        case .backendNotConfigured:
            return "Backend Not Connected Yet."
        case .localPreview:
            return "Local Mode."
        }
    }

    private func accessibilityIdentifier(for state: HFBackendConnectionState) -> String {
        switch state {
        case .credentialsMissing:
            return "hf.backend.credentialsMissing"
        case .backendConfigured, .readyForStaging:
            return "hf.backend.configured"
        case .localPreview:
            return "hf.backend.localMode"
        default:
            return "hf.backend.notConnected"
        }
    }
}

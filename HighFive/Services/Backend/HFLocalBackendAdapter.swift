import Foundation

struct HFLocalBackendAdapter: HFBackendService {
    let configuration: HFBackendConfiguration

    func currentStatus() -> HFBackendRuntimeStatus {
        let services = serviceStatuses(state: .localMode, statusLabel: "Backend Not Connected Yet")
        return HFBackendRuntimeStatus(
            mode: .local,
            connectionState: .localMode,
            status: HFBackendServiceStatus(
                id: "backend-runtime",
                title: "Backend Runtime",
                detail: "Local Mode. Backend Not Connected Yet. Provider-ready service adapters are available without live provider calls.",
                state: .localMode,
                statusLabel: "Local Mode",
                systemImage: "server.rack",
                accessibilityIdentifier: "hf.backend.status"
            ),
            services: services
        )
    }

    func currentStatus(for state: HFBackendConnectionState) -> HFBackendRuntimeStatus {
        currentStatus()
    }

    func accountStatus() -> HFBackendServiceStatus {
        serviceStatus(id: "account", title: "Account", detail: "Auth/account is local and provider-ready. Backend account provider not connected yet.", state: .backendNotConfigured, statusLabel: "Local Mode", systemImage: "person.crop.circle.fill", accessibilityIdentifier: "hf.backend.localMode")
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
            if status.statusLabel == "Provider-ready" {
                return HFBackendServiceStatus(
                    id: status.id,
                    title: status.title,
                    detail: status.detail,
                    state: status.state,
                    statusLabel: status.statusLabel,
                    systemImage: status.systemImage,
                    accessibilityIdentifier: "hf.backend.providerReady"
                )
            }
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
        currentStatus(for: configuration.connectionState)
    }

    func currentStatus(for state: HFBackendConnectionState) -> HFBackendRuntimeStatus {
        let label = label(for: state)
        let services = [
            configuredStatus(id: "account", title: "Account", detail: "Runtime configuration found. Auth/account adapter is ready for staging validation without a live provider claim.", systemImage: "person.crop.circle.fill", accessibilityIdentifier: accessibilityIdentifier(for: state), state: state),
            configuredStatus(id: "library", title: "Library", detail: "Library adapter is backend-capable. No cloud sync request is made in this build.", systemImage: "bookmark.fill", accessibilityIdentifier: accessibilityIdentifier(for: state), state: state),
            configuredStatus(id: "downloads", title: "Downloads", detail: "Download policy adapter is backend-capable. No media downloads are active.", systemImage: "arrow.down.circle.fill", accessibilityIdentifier: accessibilityIdentifier(for: state), state: state),
            configuredStatus(id: "payments", title: "Payments", detail: "Payment boundary is configured only. No live payment provider is active.", systemImage: "creditcard.fill", accessibilityIdentifier: accessibilityIdentifier(for: state), state: state),
            configuredStatus(id: "creator-studio", title: "Creator Studio", detail: "Creator Studio adapter is ready for staging records once backend validation is approved.", systemImage: "wand.and.stars", accessibilityIdentifier: "hf.creatorStudio.backendStatus", state: state),
            configuredStatus(id: "social-kit", title: "Social Kit", detail: "Social kit adapter is configured only. No live posting is active.", systemImage: "bubble.left.and.bubble.right.fill", accessibilityIdentifier: "hf.creatorStudio.socialBackendStatus", state: state),
            configuredStatus(id: "vod-package", title: "VOD", detail: "VOD package adapter is configured only. No live publishing is active.", systemImage: "shippingbox.fill", accessibilityIdentifier: "hf.creatorStudio.vodBackendStatus", state: state)
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
        configuredStatus(id: "account", title: "Account", detail: "Runtime configuration found. Auth/account adapter is ready for staging validation without a live provider claim.", systemImage: "person.crop.circle.fill", accessibilityIdentifier: "hf.backend.configured")
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
        configuredStatus(id: id, title: title, detail: detail, systemImage: systemImage, accessibilityIdentifier: accessibilityIdentifier, state: configuration.connectionState)
    }

    private func configuredStatus(id: String, title: String, detail: String, systemImage: String, accessibilityIdentifier: String, state: HFBackendConnectionState) -> HFBackendServiceStatus {
        return HFBackendServiceStatus(
            id: id,
            title: title,
            detail: state == .credentialsMissing || state == .missingCredentials ? "Missing Credentials. \(detail)" : detail,
            state: state,
            statusLabel: label(for: state),
            systemImage: systemImage,
            accessibilityIdentifier: accessibilityIdentifier
        )
    }

    private func label(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Staging Reachable"
        case .readyForStaging:
            return "Staging Ready"
        case .backendConfigured:
            return "Backend Configured"
        case .missingCredentials:
            return "Missing Credentials"
        case .credentialsMissing:
            return "Missing Credentials"
        case .stagingUnavailable:
            return "Staging Unavailable"
        case .backendUnavailable:
            return "Backend Not Connected Yet"
        case .backendNotConfigured:
            return "Backend Not Connected Yet"
        case .localMode:
            return "Local Mode"
        case .localPreview:
            return "Local Mode"
        }
    }

    private func detail(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Staging Reachable. Backend health returned successfully from runtime configuration. No production service claim is made."
        case .readyForStaging:
            return "Backend Configured. Runtime configuration is present for staging validation. No production verification is claimed."
        case .backendConfigured:
            return "Backend Configured. Runtime configuration is present and ready for a staging health check."
        case .missingCredentials:
            return "Missing Credentials. Add complete runtime configuration to leave Local Mode."
        case .credentialsMissing:
            return "Missing Credentials. Add complete runtime configuration to leave Local Mode."
        case .stagingUnavailable:
            return "Staging Unavailable. Runtime configuration exists, but the staging health check failed."
        case .backendUnavailable:
            return "Backend Not Connected Yet. Runtime mode marks backend unavailable."
        case .backendNotConfigured:
            return "Backend Not Connected Yet."
        case .localMode:
            return "Local Mode."
        case .localPreview:
            return "Local Mode."
        }
    }

    private func accessibilityIdentifier(for state: HFBackendConnectionState) -> String {
        switch state {
        case .credentialsMissing, .missingCredentials:
            return "hf.backend.credentialsMissing"
        case .stagingReachable:
            return "hf.backend.stagingReachable"
        case .backendConfigured, .readyForStaging:
            return "hf.backend.configured"
        case .localPreview, .localMode:
            return "hf.backend.localMode"
        case .stagingUnavailable:
            return "hf.backend.stagingUnavailable"
        default:
            return "hf.backend.notConnected"
        }
    }
}

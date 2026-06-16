import Foundation

struct HFLocalBackendGateway: HFBackendGateway {
    func health() async throws -> HFBackendHealth {
        HFBackendHealth(
            status: "local",
            environment: "Local Mode",
            services: [
                "account": "Local Mode",
                "catalog": "Local Mode",
                "library": "Backend Not Connected Yet",
                "downloads": "Provider-ready",
                "entitlements": "Backend Not Connected Yet",
                "creatorStudio": "Provider-ready",
                "socialKit": "Backend Not Connected Yet",
                "vodPackage": "Backend Not Connected Yet"
            ]
        )
    }

    func serviceStatuses() async -> [HFBackendServiceStatus] {
        [
            status(id: "account", title: "Account", detail: "Local profile fallback is active.", state: .localMode, label: "Local Mode", systemImage: "person.crop.circle.fill"),
            status(id: "catalog", title: "Catalog", detail: "Local mock catalog remains the source of truth.", state: .localMode, label: "Local Mode", systemImage: "sparkles.tv.fill"),
            status(id: "library", title: "Library", detail: "Saved titles stay on device until cloud sync is configured.", state: .localMode, label: "Backend Not Connected Yet", systemImage: "bookmark.fill"),
            status(id: "downloads", title: "Downloads", detail: "Offline shelf is local preview only.", state: .localMode, label: "Provider-ready", systemImage: "arrow.down.circle.fill"),
            status(id: "entitlements", title: "Entitlements", detail: "Access boundaries are local. No payment provider is active.", state: .localMode, label: "Backend Not Connected Yet", systemImage: "checkmark.shield.fill"),
            status(id: "creator-studio", title: "Creator Studio", detail: "Creator drafts stay local and provider-ready.", state: .localMode, label: "Provider-ready", systemImage: "wand.and.stars"),
            status(id: "social-kit", title: "Social Kit", detail: "No live social posting is active.", state: .localMode, label: "Backend Not Connected Yet", systemImage: "bubble.left.and.bubble.right.fill"),
            status(id: "instagram", title: "Instagram Connect", detail: "Provider-ready planning only. No account connection is active.", state: .localMode, label: "Provider-ready", systemImage: "camera.viewfinder"),
            status(id: "vod-package", title: "VOD Package", detail: "No live distribution provider is connected.", state: .localMode, label: "Backend Not Connected Yet", systemImage: "shippingbox.fill")
        ]
    }

    func fetchCatalog() async throws -> [HFCatalogTitleDTO] { [] }
    func fetchLibrary(userID: String) async throws -> [HFLibraryItemDTO] { [] }
    func upsertLibraryItem(_ item: HFLibraryItemDTO) async throws -> HFLibraryItemDTO { item }
    func fetchCreatorProjects(userID: String) async throws -> [HFCreatorProjectDTO] { [] }
    func saveCreatorProject(_ project: HFCreatorProjectDTO) async throws -> HFCreatorProjectDTO { project }

    func fetchSocialKit(projectID: String) async throws -> HFSocialKitDTO {
        HFSocialKitDTO(id: "local-social-kit", projectID: projectID, captionDrafts: [], platformReadiness: ["Instagram": "Not Connected Yet"], status: "Local Draft")
    }

    func saveSocialKit(_ kit: HFSocialKitDTO) async throws -> HFSocialKitDTO { kit }

    func fetchVODPackage(projectID: String) async throws -> HFVODPackageDTO {
        HFVODPackageDTO(id: "local-vod-package", projectID: projectID, checklist: [:], distributionProviderStatus: "Not Connected Yet", storefrontProviderStatus: "Not Connected Yet", status: "Local Draft")
    }

    func saveVODPackage(_ package: HFVODPackageDTO) async throws -> HFVODPackageDTO { package }

    private func status(id: String, title: String, detail: String, state: HFBackendConnectionState, label: String, systemImage: String) -> HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: id,
            title: title,
            detail: detail,
            state: state,
            statusLabel: label,
            systemImage: systemImage,
            accessibilityIdentifier: "hf.backend.\(id)"
        )
    }
}

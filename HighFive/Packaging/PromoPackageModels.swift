import Foundation

enum PromoExportPreset: String, CaseIterable, Identifiable, Codable {
    case tikTokVertical
    case instagramReelStory
    case instagramSquare
    case linkedInLandscape
    case posterExport
    case pressKitSlide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tikTokVertical: return "TikTok Vertical"
        case .instagramReelStory: return "Instagram Reel / Story"
        case .instagramSquare: return "Instagram Square"
        case .linkedInLandscape: return "LinkedIn Landscape"
        case .posterExport: return "Poster Export"
        case .pressKitSlide: return "Press Kit Slide"
        }
    }

    var aspectRatioLabel: String {
        switch self {
        case .tikTokVertical, .instagramReelStory: return "9:16"
        case .instagramSquare: return "1:1"
        case .linkedInLandscape: return "16:9"
        case .posterExport: return "2:3"
        case .pressKitSlide: return "4:5 / 16:9"
        }
    }
}

enum SocialLayoutPreset: String, CaseIterable, Identifiable, Codable {
    case titleCard
    case quoteCard
    case characterCard
    case worldLocations
    case pitchAtGlance
    case budgetInternal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .titleCard: return "Hero Title Card"
        case .quoteCard: return "Quote Card"
        case .characterCard: return "Character Card"
        case .worldLocations: return "World / Locations"
        case .pitchAtGlance: return "Pitch at a Glance"
        case .budgetInternal: return "Budget / Investment"
        }
    }

    var isInternalOnly: Bool {
        self == .budgetInternal
    }
}

struct PromoPackageItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let layout: SocialLayoutPreset
    let exportPresets: [PromoExportPreset]
    let assetName: String?
    let isInternalOnly: Bool
}

struct PromoPackage: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let status: String
    let items: [PromoPackageItem]
}

extension PromoExportPreset {
    init?(projectPresetID: String) {
        switch projectPresetID {
        case "tikTokVertical": self = .tikTokVertical
        case "instagramReelStory": self = .instagramReelStory
        case "instagramSquare": self = .instagramSquare
        case "linkedInLandscape": self = .linkedInLandscape
        case "posterExport": self = .posterExport
        case "pressKitSlide": self = .pressKitSlide
        default: return nil
        }
    }
}

extension SocialLayoutPreset {
    init(projectLayout: HFProjectPackagingLayout) {
        switch projectLayout {
        case .titleCard: self = .titleCard
        case .quoteCard: self = .quoteCard
        case .characterCard: self = .characterCard
        case .worldLocations: self = .worldLocations
        case .pitchAtGlance: self = .pitchAtGlance
        case .budgetInternal: self = .budgetInternal
        }
    }
}

extension PromoPackageItem {
    init(projectItem: HFProjectPackagingItem) {
        self.init(
            id: projectItem.id,
            title: projectItem.title,
            subtitle: projectItem.subtitle,
            layout: SocialLayoutPreset(projectLayout: projectItem.layout),
            exportPresets: projectItem.exportPresetIDs.compactMap(PromoExportPreset.init(projectPresetID:)),
            assetName: projectItem.assetName,
            isInternalOnly: projectItem.isInternalOnly
        )
    }
}

extension PromoPackage {
    init(project: HFProject) {
        self.init(
            id: "\(project.id.rawValue)-promo-kit",
            title: "\(project.title) Promo Kit",
            status: project.packageStatus,
            items: project.packagingItems.map(PromoPackageItem.init(projectItem:))
        )
    }
}

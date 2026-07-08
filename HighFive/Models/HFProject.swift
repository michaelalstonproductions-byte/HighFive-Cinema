import Foundation

enum HFProjectID: String, CaseIterable, Codable, Hashable, Sendable {
    case markOfTheWest = "mark-of-the-west"
    case paranormall = "paranormall-s1"
    case theFriendly = "friendly"
}

enum HFProjectFormat: String, Codable, Hashable, Sendable {
    case feature = "Feature"
    case series = "Series"
    case limitedSeries = "Limited Series"
}

enum HFProjectLifecycleState: String, Codable, Hashable, Sendable {
    case packaging = "Packaging"
    case creatorReview = "Creator Review"
    case streaming = "Streaming"
    case intelligence = "Intelligence"
}

enum HFProjectPackagingLayout: String, Codable, Hashable, Sendable {
    case titleCard
    case quoteCard
    case characterCard
    case worldLocations
    case pitchAtGlance
    case budgetInternal
}

struct HFProjectReadiness: Codable, Hashable, Sendable {
    let overall: Double
    let package: Double
    let assets: Double
    let teamReview: Double
    let blockers: Int
    let status: String
}

struct HFProjectAssetState: Codable, Hashable, Sendable {
    let poster: String
    let trailer: String
    let artwork: String
    let metadata: String
    let thumbnail: String
}

struct HFProjectPackagingItem: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let layout: HFProjectPackagingLayout
    let exportPresetIDs: [String]
    let assetName: String?
    let isInternalOnly: Bool
}

struct HFProjectActivitySignal: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
}

struct HFProjectBlocker: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let status: String
    let systemImage: String
}

struct HFProjectChecklistItem: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let status: String
    let systemImage: String
}

struct HFProjectToolSignal: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let systemImage: String
}

struct HFProject: Identifiable, Codable, Hashable, Sendable {
    let id: HFProjectID
    let movieID: String?
    let title: String
    let shortTitle: String
    let creator: String
    let format: HFProjectFormat
    let genre: String
    let runtime: String
    let synopsis: String
    let posterAssetName: String?
    let lifecycleState: HFProjectLifecycleState
    let workflowStage: String
    let packageStatus: String
    let releaseState: String
    let readiness: HFProjectReadiness
    let assetState: HFProjectAssetState
    let reviewNotes: Int
    let marketplaceInterest: Int
    let audienceSaves: String
    let teamMembers: Int
    let versionRounds: Int
    let tags: [String]
    let packagingItems: [HFProjectPackagingItem]
    let activitySignals: [HFProjectActivitySignal]
    let blockers: [HFProjectBlocker]
    let launchChecklist: [HFProjectChecklistItem]

    var creatorPackageTitle: String {
        "\(title) - Creator Package"
    }

    var readinessPercentLabel: String {
        "\(Int(readiness.overall * 100))%"
    }

    var packagePercentLabel: String {
        "\(Int(readiness.package * 100))%"
    }
}

struct HFProjectStudioIntelligenceSnapshot: Codable, Hashable, Sendable {
    let projectCount: Int
    let activeProjectTitle: String
    let readinessLabel: String
    let packageLabel: String
    let reviewNotes: Int
    let marketplaceInterest: Int
    let detail: String
}

struct HFProjectBrainSnapshot: Codable, Hashable, Sendable {
    let projectCount: Int
    let primaryProjectTitle: String
    let sourceLabel: String
    let summary: String
    let toolSignals: [HFProjectToolSignal]
}

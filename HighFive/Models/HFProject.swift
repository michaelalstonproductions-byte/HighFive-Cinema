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

enum HFStudioProjectEventKind: String, Codable, Hashable, Sendable {
    case activity = "Activity"
    case readiness = "Readiness"
    case dependency = "Dependency"
    case automation = "Automation"
}

enum HFStudioSignalSeverity: String, Codable, Hashable, Sendable {
    case info = "Info"
    case watch = "Watch"
    case attention = "Attention"
    case blocked = "Blocked"
    case ready = "Ready"
}

struct HFStudioProjectEvent: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let kind: HFStudioProjectEventKind
    let title: String
    let detail: String
    let severity: HFStudioSignalSeverity
    let workspace: String
    let systemImage: String
}

struct HFStudioReadinessChange: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let readinessLabel: String
    let packageLabel: String
    let status: String
    let deltaLabel: String
    let detail: String
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFStudioDependencySignal: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let dependencyTitle: String
    let upstreamWorkspace: String
    let downstreamWorkspace: String
    let status: String
    let detail: String
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFStudioAutomationSuggestion: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let title: String
    let detail: String
    let actionLabel: String
    let destinationWorkspace: String
    let isLocalOnly: Bool
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFStudioIntelligenceSnapshot: Codable, Hashable, Sendable {
    let sourceLabel: String
    let summary: String
    let events: [HFStudioProjectEvent]
    let readinessChanges: [HFStudioReadinessChange]
    let dependencySignals: [HFStudioDependencySignal]
    let automationSuggestions: [HFStudioAutomationSuggestion]

    var totalSignalCount: Int {
        events.count + readinessChanges.count + dependencySignals.count + automationSuggestions.count
    }
}

enum HFWorkflowAutomationRuleKind: String, Codable, Hashable, Sendable {
    case blockerReview = "Blocker Review"
    case dependencyGate = "Dependency Gate"
    case readinessMovement = "Readiness Movement"
    case nextAction = "Next Action"
}

struct HFWorkflowAutomationRule: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let kind: HFWorkflowAutomationRuleKind
    let trigger: String
    let localAction: String
    let targetWorkspace: String
    let isEnabled: Bool
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFDependencyThreshold: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let dependencyStatus: String
    let maximumOpenDependencies: Int
    let currentOpenDependencies: Int
    let recommendation: String
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFWorkflowTriggeredSuggestion: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let ruleID: String
    let projectID: HFProjectID
    let projectTitle: String
    let title: String
    let detail: String
    let actionLabel: String
    let targetWorkspace: String
    let isLocalOnly: Bool
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFReadinessTransitionSuggestion: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let fromState: String
    let recommendedState: String
    let readinessLabel: String
    let dependencySummary: String
    let detail: String
    let isMovementAllowed: Bool
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFWorkflowAutomationSnapshot: Codable, Hashable, Sendable {
    let sourceLabel: String
    let summary: String
    let rules: [HFWorkflowAutomationRule]
    let dependencyThresholds: [HFDependencyThreshold]
    let triggeredSuggestions: [HFWorkflowTriggeredSuggestion]
    let blockedDependencies: [HFStudioDependencySignal]
    let readinessMovementRecommendations: [HFReadinessTransitionSuggestion]

    var totalSignalCount: Int {
        rules.count + dependencyThresholds.count + triggeredSuggestions.count + blockedDependencies.count + readinessMovementRecommendations.count
    }
}

enum HFOrchestrationWorkspace: String, CaseIterable, Codable, Hashable, Sendable {
    case unifiedProjectState = "Unified Project State"
    case studioIntelligence = "Studio Intelligence"
    case workflowAutomation = "Workflow Automation"
    case higherKeyBrain = "HigherKey Brain"
    case packagingStudio = "Packaging Studio"
    case creatorOS = "Creator OS"
    case qa = "QA"
    case release = "Release"
    case marketing = "Marketing"

    var systemImage: String {
        switch self {
        case .unifiedProjectState:
            return "square.stack.3d.up.fill"
        case .studioIntelligence:
            return "lightbulb.max.fill"
        case .workflowAutomation:
            return "arrow.triangle.branch"
        case .higherKeyBrain:
            return "brain.head.profile"
        case .packagingStudio:
            return "shippingbox.fill"
        case .creatorOS:
            return "command"
        case .qa:
            return "checklist.checked"
        case .release:
            return "flag.checkered"
        case .marketing:
            return "megaphone.fill"
        }
    }
}

enum HFOrchestrationStatus: String, Codable, Hashable, Sendable {
    case queued = "Queued"
    case ready = "Ready"
    case blocked = "Blocked"
    case reviewNeeded = "Review Needed"
    case localOnly = "Local Only"
}

struct HFOrchestrationStep: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let sequenceIndex: Int
    let workspace: HFOrchestrationWorkspace
    let title: String
    let detail: String
    let inputSource: String
    let outputTarget: String
    let status: HFOrchestrationStatus
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFCrossWorkspaceHandoff: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let sourceWorkspace: HFOrchestrationWorkspace
    let targetWorkspace: HFOrchestrationWorkspace
    let title: String
    let detail: String
    let blockerSummary: String
    let status: HFOrchestrationStatus
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFOrchestrationQueueItem: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let position: Int
    let stepID: String
    let handoffID: String?
    let title: String
    let targetWorkspace: HFOrchestrationWorkspace
    let suggestedAction: String
    let status: HFOrchestrationStatus
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFProjectSequenceState: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let projectID: HFProjectID
    let projectTitle: String
    let currentWorkspace: HFOrchestrationWorkspace
    let nextWorkspace: HFOrchestrationWorkspace
    let pipelineState: String
    let suggestedSequence: String
    let readinessLabel: String
    let blockedHandoffCount: Int
    let status: HFOrchestrationStatus
    let severity: HFStudioSignalSeverity
    let systemImage: String
}

struct HFOrchestrationLocalAction: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let detail: String
    let targetWorkspace: HFOrchestrationWorkspace
    let isPlaceholder: Bool
    let systemImage: String
}

struct HFOrchestrationSnapshot: Codable, Hashable, Sendable {
    let sourceLabel: String
    let summary: String
    let steps: [HFOrchestrationStep]
    let handoffs: [HFCrossWorkspaceHandoff]
    let queue: [HFOrchestrationQueueItem]
    let projectStates: [HFProjectSequenceState]
    let localActions: [HFOrchestrationLocalAction]

    var blockedHandoffs: [HFCrossWorkspaceHandoff] {
        handoffs.filter { $0.status == .blocked }
    }

    var nextHandoff: HFCrossWorkspaceHandoff? {
        handoffs.first { $0.status != .blocked } ?? handoffs.first
    }

    var suggestedSequenceLabel: String {
        projectStates.map { "\($0.projectTitle): \($0.suggestedSequence)" }.joined(separator: " / ")
    }
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

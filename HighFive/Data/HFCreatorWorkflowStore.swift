import Combine
import Foundation

final class HFCreatorWorkflowStore: ObservableObject {
    private static let activeProject = HFLocalProjectStore.creatorOSProject

    @Published var currentProjectTitle = HFCreatorWorkflowStore.activeProject.creatorPackageTitle
    @Published var selectedWorkflowStage = HFCreatorWorkflowStore.activeProject.workflowStage
    @Published var openReviewNotes = HFCreatorWorkflowStore.activeProject.reviewNotes
    @Published var completionPercent = HFCreatorWorkflowStore.activeProject.readiness.overall
    @Published var reviewReadinessPercent = HFCreatorWorkflowStore.activeProject.readiness.package
    @Published var marketplaceInterest = HFCreatorWorkflowStore.activeProject.marketplaceInterest
    @Published var teamMembersCount = HFCreatorWorkflowStore.activeProject.teamMembers
    @Published var recentActivities: [HFCreatorWorkflowActivity] = HFCreatorWorkflowStore.activeProject.activitySignals.map(HFCreatorWorkflowActivity.init(projectSignal:))

    let releaseReadiness = HFCreatorReleaseReadiness(
        projectReadiness: HFCreatorWorkflowStore.activeProject.readiness
    )

    let workflowStages: [HFCreatorWorkflowStageState] = [
        HFCreatorWorkflowStageState(title: "Studio", status: "Active", systemImage: "film.stack.fill"),
        HFCreatorWorkflowStageState(title: "Package Builder", status: "In Progress", systemImage: "shippingbox.fill"),
        HFCreatorWorkflowStageState(title: "Asset Manager", status: "Needs Review", systemImage: "rectangle.stack.fill"),
        HFCreatorWorkflowStageState(title: "Submission Workflow", status: "Draft Review", systemImage: "checklist"),
        HFCreatorWorkflowStageState(title: "Team Review", status: "Internal Review", systemImage: "person.3.fill"),
        HFCreatorWorkflowStageState(title: "Version History", status: "Tracking", systemImage: "clock.arrow.circlepath"),
        HFCreatorWorkflowStageState(title: "Team Permissions", status: "Preview Only", systemImage: "person.3.sequence.fill"),
        HFCreatorWorkflowStageState(title: "Marketplace", status: "Coming Soon", systemImage: "storefront.fill")
    ]

    let criticalActions: [HFCreatorCriticalAction] = [
        HFCreatorCriticalAction(title: "Continue Package Builder", detail: "Confirm credits and submission notes.", systemImage: "shippingbox.fill"),
        HFCreatorCriticalAction(title: "Review Assets", detail: "Trailer cut still needs one review pass.", systemImage: "rectangle.stack.fill"),
        HFCreatorCriticalAction(title: "Open Submission Workflow", detail: "Check gates before internal review.", systemImage: "paperplane.fill"),
        HFCreatorCriticalAction(title: "Open Team Review", detail: "Resolve open reviewer notes.", systemImage: "person.3.fill"),
        HFCreatorCriticalAction(title: "Check Release Readiness", detail: "Preview blockers and launch path.", systemImage: "gauge.with.dots.needle.67percent")
    ]

    let releaseBlockers = HFCreatorWorkflowStore.activeProject.blockers.map(HFCreatorReleaseBlocker.init(projectBlocker:))

    let launchReadiness = HFCreatorWorkflowStore.activeProject.readiness.overall
    let accessPreviewStatus = "Mock Only"
    let audienceSaves = HFCreatorWorkflowStore.activeProject.audienceSaves
    let marketplaceFollows = HFCreatorWorkflowStore.activeProject.marketplaceInterest

    let launchChecklist = HFCreatorWorkflowStore.activeProject.launchChecklist.map(HFCreatorLaunchChecklistItem.init(projectChecklistItem:))

    let mockAccessPlans: [HFCreatorAccessPlan] = [
        HFCreatorAccessPlan(title: "Viewer Pass", status: "Preview Only", detail: "Coming soon", systemImage: "ticket.fill"),
        HFCreatorAccessPlan(title: "Creator Supporter", status: "Preview Only", detail: "Coming soon", systemImage: "heart.fill"),
        HFCreatorAccessPlan(title: "Studio Review Access", status: "Preview Only", detail: "Coming soon", systemImage: "person.badge.shield.checkmark.fill")
    ]
}

struct HFCreatorWorkflowActivity: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct HFCreatorWorkflowStageState: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

struct HFCreatorReleaseReadiness {
    let overall: Double
    let package: Double
    let assets: Double
    let teamReview: Double
    let blockers: Int
    let status: String
}

struct HFCreatorCriticalAction: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct HFCreatorReleaseBlocker: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

struct HFCreatorLaunchChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

struct HFCreatorAccessPlan: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
    let systemImage: String
}

extension HFCreatorWorkflowActivity {
    init(projectSignal: HFProjectActivitySignal) {
        self.init(title: projectSignal.title, detail: projectSignal.detail, systemImage: projectSignal.systemImage)
    }
}

extension HFCreatorReleaseReadiness {
    init(projectReadiness: HFProjectReadiness) {
        self.init(
            overall: projectReadiness.overall,
            package: projectReadiness.package,
            assets: projectReadiness.assets,
            teamReview: projectReadiness.teamReview,
            blockers: projectReadiness.blockers,
            status: projectReadiness.status
        )
    }
}

extension HFCreatorReleaseBlocker {
    init(projectBlocker: HFProjectBlocker) {
        self.init(title: projectBlocker.title, status: projectBlocker.status, systemImage: projectBlocker.systemImage)
    }
}

extension HFCreatorLaunchChecklistItem {
    init(projectChecklistItem: HFProjectChecklistItem) {
        self.init(title: projectChecklistItem.title, status: projectChecklistItem.status, systemImage: projectChecklistItem.systemImage)
    }
}

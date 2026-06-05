import Combine
import Foundation

final class HFCreatorWorkflowStore: ObservableObject {
    @Published var currentProjectTitle = "The Friendly — Creator Package"
    @Published var selectedWorkflowStage = "Team Review"
    @Published var openReviewNotes = 5
    @Published var completionPercent = 0.72
    @Published var reviewReadinessPercent = 0.68
    @Published var marketplaceInterest = 48
    @Published var teamMembersCount = 4
    @Published var recentActivities: [HFCreatorWorkflowActivity] = [
        HFCreatorWorkflowActivity(title: "Poster artwork approved", detail: "Creative Lead cleared the package artwork.", systemImage: "checkmark.seal.fill"),
        HFCreatorWorkflowActivity(title: "Trailer cut flagged for review", detail: "Opening sequence needs one more pass.", systemImage: "film.fill"),
        HFCreatorWorkflowActivity(title: "Metadata updated", detail: "Synopsis and cast details were refreshed.", systemImage: "text.badge.checkmark"),
        HFCreatorWorkflowActivity(title: "Team permissions reviewed", detail: "Reviewer roles are ready for preview.", systemImage: "checkmark.shield.fill"),
        HFCreatorWorkflowActivity(title: "Marketplace preview generated", detail: "Listing signals are ready for the mock marketplace.", systemImage: "storefront.fill")
    ]

    let releaseReadiness = HFCreatorReleaseReadiness(
        overall: 0.72,
        package: 0.68,
        assets: 0.75,
        teamReview: 0.72,
        blockers: 2,
        status: "On track"
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

    let releaseBlockers: [HFCreatorReleaseBlocker] = [
        HFCreatorReleaseBlocker(title: "Trailer opening needs review", status: "Blocking", systemImage: "film.fill"),
        HFCreatorReleaseBlocker(title: "Cast credits need confirmation", status: "Blocking", systemImage: "person.2.fill"),
        HFCreatorReleaseBlocker(title: "Submission notes incomplete", status: "Pending", systemImage: "note.text"),
        HFCreatorReleaseBlocker(title: "Team sign-off pending", status: "Pending", systemImage: "person.3.fill")
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

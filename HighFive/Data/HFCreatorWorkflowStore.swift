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
}

struct HFCreatorWorkflowActivity: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

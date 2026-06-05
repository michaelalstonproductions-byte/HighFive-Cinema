import Combine
import Foundation

final class HFNotificationCenterStore: ObservableObject {
    @Published var notifications: [HFLocalNotificationItem] = [
        HFLocalNotificationItem(
            title: "The Friendly is ready to continue.",
            message: "Resume the creator cut from your Continue Watching rail.",
            category: "Streaming",
            systemImage: "play.rectangle.fill"
        ),
        HFLocalNotificationItem(
            title: "New titles added to HighFive.",
            message: "Browse fresh cinema picks in Search and Discover.",
            category: "Streaming",
            systemImage: "sparkles"
        ),
        HFLocalNotificationItem(
            title: "Downloads are ready offline.",
            message: "Your local download queue is available for preview.",
            category: "Streaming",
            systemImage: "arrow.down.circle.fill"
        ),
        HFLocalNotificationItem(
            title: "Trailer cut needs review.",
            message: "The active creator package has one open trailer note.",
            category: "Creator",
            systemImage: "film.fill"
        ),
        HFLocalNotificationItem(
            title: "Team permissions updated.",
            message: "Reviewer roles are ready in the Team Permissions preview.",
            category: "Creator",
            systemImage: "checkmark.shield.fill"
        ),
        HFLocalNotificationItem(
            title: "Submission workflow is 68% ready.",
            message: "Finish notes and credits before release readiness improves.",
            category: "Creator",
            systemImage: "paperplane.fill"
        ),
        HFLocalNotificationItem(
            title: "Marketplace preview generated.",
            message: "The Friendly package has new marketplace signal cards.",
            category: "Creator",
            systemImage: "storefront.fill"
        ),
        HFLocalNotificationItem(
            title: "Version v0.8 is in internal review.",
            message: "Version history is tracking the current review round.",
            category: "Creator",
            systemImage: "clock.arrow.circlepath"
        )
    ]
}

struct HFLocalNotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let category: String
    let systemImage: String
}

import Foundation

enum HFAnalyticsAllowlist {
    static let permittedEventNames: Set<String> = [
        "app_launched",
        "home_viewed",
        "title_viewed",
        "watch_started",
        "creator_studio_opened",
        "social_kit_reviewed",
        "vod_package_reviewed"
    ]

    static func allows(_ eventName: String) -> Bool {
        permittedEventNames.contains(eventName)
    }
}

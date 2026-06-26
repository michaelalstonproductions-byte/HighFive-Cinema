import Foundation

enum HFAnalyticsAllowlist {
    static let permittedEventNames: Set<String> = [
        "app_launched",
        "home_viewed",
        "title_viewed",
        "watch_started",
        "playback_start",
        "playback_progress",
        "playback_pause",
        "playback_complete",
        "search",
        "search_result_click",
        "save",
        "favorite",
        "collection_open",
        "creator_profile_open",
        "upload",
        "processing_complete",
        "publishing_state_change",
        "revenue_estimate",
        "creator_studio_opened",
        "social_kit_reviewed",
        "vod_package_reviewed"
    ]

    static func allows(_ eventName: String) -> Bool {
        permittedEventNames.contains(eventName)
    }
}

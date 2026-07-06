import Foundation

#if os(iOS)
import UIKit
#endif

enum HFSupportConfig {
    static let appName = "HighFive Cinema"
    static let supportEmail = HFLegalDocuments.supportEmail
    static let supportSubject = "HighFive Cinema Support"
    static let playbackIssueSubject = "HighFive Cinema Playback Issue"
    static let dataPrivacySubject = "HighFive Cinema Data Privacy Request"

    static var appVersionDisplay: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "\(version) (\(build))"
    }

    static func mailtoURL(subject: String, body: String = "") -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }

    static func supportBody(context: String) -> String {
        """
        \(context)

        App: \(appName)
        Version: \(appVersionDisplay)
        Device: \(deviceDescription)
        """
    }

    private static var deviceDescription: String {
        #if os(iOS)
        return "\(UIDevice.current.model) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #else
        return "Unknown device"
        #endif
    }
}

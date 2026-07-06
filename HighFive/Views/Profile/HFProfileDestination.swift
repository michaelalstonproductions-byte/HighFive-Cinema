import Foundation

enum HFProfileDestination: String, Identifiable, CaseIterable {
    case account
    case appSettings
    case helpSupport

    var id: String { rawValue }

    var title: String {
        switch self {
        case .account:
            return "Account"
        case .appSettings:
            return "App Settings"
        case .helpSupport:
            return "Help & Support"
        }
    }

    var subtitle: String {
        switch self {
        case .account:
            return "Purchases, restore, and access"
        case .appSettings:
            return "Playback, motion, and downloads"
        case .helpSupport:
            return "Support, FAQs, and legal"
        }
    }

    var systemImage: String {
        switch self {
        case .account:
            return "person.crop.circle"
        case .appSettings:
            return "gearshape.fill"
        case .helpSupport:
            return "questionmark.circle.fill"
        }
    }

    var accessibilityID: String {
        switch self {
        case .account:
            return "hf.profile.row.account"
        case .appSettings:
            return "hf.profile.row.appSettings"
        case .helpSupport:
            return "hf.profile.row.helpSupport"
        }
    }
}

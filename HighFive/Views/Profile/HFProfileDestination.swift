import Foundation

enum HFProfileDestination: String, Identifiable, CaseIterable {
    case account
    case appSettings
    case helpSupport
    case releaseCandidateQA

    var id: String { rawValue }

    var title: String {
        switch self {
        case .account:
            return "Account"
        case .appSettings:
            return "App Settings"
        case .helpSupport:
            return "Help & Support"
        case .releaseCandidateQA:
            return "4.1 RC QA Checklist"
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
        case .releaseCandidateQA:
            return "Internal TestFlight release pass"
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
        case .releaseCandidateQA:
            return "checklist.checked"
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
        case .releaseCandidateQA:
            return "hf.profile.internal.rc41Checklist"
        }
    }
}

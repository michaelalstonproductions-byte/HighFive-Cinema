import SwiftUI

enum HFTypography {
    static let display = Font.system(size: 32, weight: .black, design: .rounded)
    static let heroTitle = Font.system(size: 42, weight: .black, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let section = Font.system(size: 22, weight: .black, design: .rounded)
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let micro = Font.system(size: 10, weight: .bold, design: .rounded)
    static let menu = Font.system(size: 19, weight: .semibold, design: .rounded)
    static let smallAction = Font.system(size: 14, weight: .bold, design: .rounded)

    static func heroTitle(for horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        horizontalSizeClass == .regular
            ? Font.system(size: 52, weight: .black, design: .rounded)
            : heroTitle
    }
}

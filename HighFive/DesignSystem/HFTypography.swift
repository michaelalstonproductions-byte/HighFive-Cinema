import SwiftUI

enum HFTypography {
    static let display = Font.system(size: 32, weight: .black, design: .default)
    static let heroTitle = Font.system(size: 44, weight: .black, design: .default)
    static let title = Font.system(size: 28, weight: .bold, design: .default)
    static let section = Font.system(size: 22, weight: .black, design: .default)
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let body = Font.system(size: 15, weight: .medium, design: .default)
    static let caption = Font.system(size: 12, weight: .semibold, design: .default)
    static let micro = Font.system(size: 10, weight: .bold, design: .default)
    static let menu = Font.system(size: 19, weight: .semibold, design: .default)
    static let smallAction = Font.system(size: 14, weight: .bold, design: .default)

    static func heroTitle(for horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        horizontalSizeClass == .regular
            ? Font.system(size: 52, weight: .black, design: .default)
            : heroTitle
    }
}

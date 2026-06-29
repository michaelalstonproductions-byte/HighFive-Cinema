import SwiftUI

enum HFResponsiveFit {
    static func isCompactPhone(width: CGFloat) -> Bool {
        width < 390
    }

    static func isStandardPhone(width: CGFloat) -> Bool {
        width >= 390 && width < 430
    }

    static func isLargePhone(width: CGFloat) -> Bool {
        width >= 430
    }

    static func safeHorizontalPadding(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 12 : 16
    }

    static func heroHorizontalInset(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 10 : 16
    }

    static func heroCardCornerRadius(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 18 : HFSpacing.heroRadius
    }

    static func heroImageHeight(width: CGFloat) -> CGFloat {
        min(610, max(520, width * 1.32))
    }

    static func heroContentBottomPadding(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 126 : HFSpacing.floatingTabClearance + HFSpacing.lg
    }

    static func heroPosterWidth(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 58 : (isStandardPhone(width: width) ? 64 : 70)
    }

    static func posterRailWidth(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 132 : (isStandardPhone(width: width) ? 140 : HFSpacing.posterRailWidth)
    }

    static func bottomTabIconSize(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 20 : 22
    }

    static func bottomTabFontSize(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 10.5 : 12
    }

    static func bottomTabItemHeight(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 64 : HFSpacing.tabBarHeight - HFSpacing.xs
    }

    static func bottomTabHorizontalPadding(width: CGFloat) -> CGFloat {
        isCompactPhone(width: width) ? 10 : HFSpacing.floatingTabHorizontal
    }

    static func floatingTabContentClearance(dynamicTypeSize: DynamicTypeSize, extra: CGFloat = 0) -> CGFloat {
        let base = HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight + extra
        if dynamicTypeSize.isAccessibilitySize {
            return base + HFSpacing.floatingTabClearance
        }

        switch dynamicTypeSize {
        case .xxLarge, .xxxLarge:
            return base + HFSpacing.xxl
        default:
            return base
        }
    }

    static func smallBadgeFontSize(width: CGFloat) -> CGFloat {
        width < 86 ? 8 : 9
    }

    static func comingSoonBadgeSize(width: CGFloat) -> CGFloat {
        width < 86 ? 42 : 50
    }

    static func headerLogoSize(width: CGFloat) -> CGFloat {
        width < 460 ? 44 : 50
    }

    static func headerIconSize(width: CGFloat) -> CGFloat {
        width < 460 ? 22 : 25
    }

    static let minimumTapTarget: CGFloat = 44
}

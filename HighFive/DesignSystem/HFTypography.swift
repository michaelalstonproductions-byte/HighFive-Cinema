import SwiftUI

enum HFTypography {
    static let display = Font.system(.largeTitle, design: .default, weight: .black)
    static let heroTitle = Font.system(.largeTitle, design: .default, weight: .black)
    static let title = Font.system(.title, design: .default, weight: .bold)
    static let section = Font.system(.title3, design: .default, weight: .black)
    static let cardTitle = Font.system(.headline, design: .default, weight: .semibold)
    static let body = Font.system(.body, design: .default, weight: .medium)
    static let caption = Font.system(.caption, design: .default, weight: .semibold)
    static let micro = Font.system(.caption2, design: .default, weight: .bold)
    static let menu = Font.system(.title3, design: .default, weight: .semibold)
    static let smallAction = Font.system(.subheadline, design: .default, weight: .bold)

    static func heroTitle(for horizontalSizeClass: UserInterfaceSizeClass?) -> Font {
        horizontalSizeClass == .regular
            ? Font.system(.largeTitle, design: .default, weight: .black)
            : heroTitle
    }
}

private struct HFReadableTextModifier: ViewModifier {
    let lines: Int?
    let scale: CGFloat
    let multilineAlignment: TextAlignment
    let reservesVerticalSpace: Bool

    func body(content: Content) -> some View {
        if let lines {
            content
                .lineLimit(lines, reservesSpace: reservesVerticalSpace)
                .minimumScaleFactor(scale)
                .multilineTextAlignment(multilineAlignment)
                .allowsTightening(false)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.disabled)
        } else {
            content
                .lineLimit(nil)
                .minimumScaleFactor(scale)
                .multilineTextAlignment(multilineAlignment)
                .allowsTightening(false)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.disabled)
        }
    }
}

extension View {
    func hfReadableText(
        lines: Int? = nil,
        minimumScaleFactor: CGFloat = 0.82,
        alignment: TextAlignment = .leading,
        reservesVerticalSpace: Bool = false
    ) -> some View {
        modifier(
            HFReadableTextModifier(
                lines: lines,
                scale: minimumScaleFactor,
                multilineAlignment: alignment,
                reservesVerticalSpace: reservesVerticalSpace
            )
        )
    }

    func hfSingleLineText(minimumScaleFactor: CGFloat = 0.76) -> some View {
        hfReadableText(lines: 1, minimumScaleFactor: minimumScaleFactor)
    }

    func hfDynamicTypeGuard() -> some View {
        dynamicTypeSize(.xSmall ... .accessibility2)
    }
}

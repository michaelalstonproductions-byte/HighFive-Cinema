import SwiftUI

struct HFButton: View {
    enum Style {
        case primary
        case secondary
        case outline
    }

    let title: String
    let systemImage: String?
    let style: Style
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: HFSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(HFIconography.symbolFont(size: HFIconography.actionIconSize, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: HFIconography.actionIconFrame)
                }
                Text(title)
                    .font(HFTypography.smallAction)
                    .hfSingleLineText(minimumScaleFactor: 0.56)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background)
            .overlay(border)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
    }

    private var accessibilityHint: String {
        switch style {
        case .primary:
            return "Primary action"
        case .secondary:
            return "Secondary action"
        case .outline:
            return "Additional action"
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .black
        case .secondary, .outline:
            return HFColors.textPrimary
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            return HFColors.amberGlow.opacity(0.22)
        case .secondary:
            return .black.opacity(0.20)
        case .outline:
            return HFColors.gold.opacity(0.10)
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return 16
        case .secondary, .outline:
            return 10
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            HFColors.goldGradient
        case .secondary:
            HFColors.cinematicPanelGradient
        case .outline:
            LinearGradient(
                colors: [
                    HFColors.gold.opacity(0.12),
                    Color.white.opacity(0.055),
                    Color.black.opacity(0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private var border: some View {
        if style == .secondary {
            Capsule()
                .stroke(HFColors.subtleGlassRimGradient, lineWidth: 1)
        } else if style == .outline {
            Capsule()
                .stroke(HFColors.goldStroke, lineWidth: 1)
        }
    }
}

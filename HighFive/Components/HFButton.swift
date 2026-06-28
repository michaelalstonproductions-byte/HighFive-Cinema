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

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            HFColors.goldGradient
        case .secondary:
            HFColors.controlFillStrong
        case .outline:
            HFColors.quietFill
        }
    }

    @ViewBuilder
    private var border: some View {
        if style == .secondary {
            Capsule()
                .stroke(HFColors.glassStroke, lineWidth: 1)
        } else if style == .outline {
            Capsule()
                .stroke(HFColors.goldStroke, lineWidth: 1)
        }
    }
}

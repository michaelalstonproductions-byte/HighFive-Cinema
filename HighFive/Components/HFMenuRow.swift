import SwiftUI

struct HFMenuRow: View {
    let title: String
    let systemImage: String
    var badgeCount = 0
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                HStack(spacing: HFSpacing.md) {
                    Image(systemName: systemImage)
                        .font(HFIconography.symbolFont(size: HFIconography.controlIconSize, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(HFColors.gold)
                        .frame(width: HFIconography.menuIconFrame)

                    Text(title)
                        .font(HFTypography.menu)
                        .foregroundStyle(HFColors.textPrimary)

                    Spacer()

                    HFUnreadBadge(count: badgeCount)

                    Image(systemName: "chevron.right")
                        .font(HFIconography.symbolFont(size: HFIconography.smallIconSize, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(HFColors.textMuted)
                        .frame(width: HFIconography.chipIconFrame)
                }
                .frame(height: 64)
                .padding(.horizontal, HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
    }
}

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
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 28)

                    Text(title)
                        .font(HFTypography.menu)
                        .foregroundStyle(HFColors.textPrimary)

                    Spacer()

                    HFUnreadBadge(count: badgeCount)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(HFColors.textMuted)
                }
                .frame(height: 64)
                .padding(.horizontal, HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
    }
}

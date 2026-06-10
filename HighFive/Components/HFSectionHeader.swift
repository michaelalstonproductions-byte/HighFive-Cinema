import SwiftUI

struct HFSectionHeader: View {
    let title: String
    var actionTitle: String? = "See All"
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: HFSpacing.sm) {
            Capsule()
                .fill(HFColors.goldGradient)
                .frame(width: 4, height: 20)
                .accessibilityHidden(true)

            Text(title)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer()

            if let actionTitle {
                Button(action: { action?() }) {
                    HStack(spacing: HFSpacing.xxs) {
                        Text(actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .black))
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.gold)
                    .padding(.horizontal, HFSpacing.xs)
                    .frame(height: 30)
                    .background(HFColors.gold.opacity(0.10))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(actionTitle)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

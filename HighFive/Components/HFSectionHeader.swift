import SwiftUI

struct HFSectionHeader: View {
    let title: String
    var actionTitle: String? = "See All"
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: HFSpacing.sm) {
            ZStack {
                Capsule()
                    .fill(HFColors.goldGradient)
                    .frame(width: 4, height: 24)
                    .shadow(color: HFColors.amberGlow.opacity(0.36), radius: 10, x: 0, y: 0)

                Capsule()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: 1, height: 18)
                    .offset(x: -1)
            }
                .accessibilityHidden(true)

            Text(title)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.textPrimary)
                .hfReadableText(lines: 2, minimumScaleFactor: 0.78)

            Spacer()

            if let actionTitle {
                Button(action: { action?() }) {
                    HStack(spacing: HFSpacing.xxs) {
                        Text(actionTitle)
                        Image(systemName: "chevron.right")
                            .font(HFIconography.symbolFont(size: HFIconography.smallIconSize, weight: .black))
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: HFIconography.chipIconFrame)
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.gold)
                    .hfSingleLineText(minimumScaleFactor: 0.72)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(height: 30)
                    .background(
                        LinearGradient(
                            colors: [HFColors.gold.opacity(0.16), Color.white.opacity(0.055)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Capsule().stroke(HFColors.gold.opacity(0.24), lineWidth: 1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(actionTitle)
                .accessibilityHint("Opens more items for \(title)")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
    }
}

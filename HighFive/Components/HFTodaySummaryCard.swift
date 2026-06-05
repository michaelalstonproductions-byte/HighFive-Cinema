import SwiftUI

struct HFTodaySummaryCard: View {
    let items: [HFTodaySummaryItem]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Today on HighFive")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Watch stories. Follow creators. Explore communities. Launch cinematic work.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.md) {
                    ForEach(items) { item in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Image(systemName: item.systemImage)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 30, height: 30)
                                .background(HFColors.gold.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(HFTypography.micro)
                                    .foregroundStyle(HFColors.textMuted)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.78)
                                Text(item.value)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.78)
                                Text(item.caption)
                                    .font(HFTypography.micro)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.78)
                            }

                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
    }
}

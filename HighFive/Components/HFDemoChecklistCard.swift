import SwiftUI

struct HFDemoChecklistCard: View {
    let title: String
    let items: [String]
    var systemImage = "checkmark.seal.fill"
    var status = "Local"

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 40, height: 40)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: status, isProminent: false)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)

                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

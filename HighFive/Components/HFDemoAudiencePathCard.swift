import SwiftUI

struct HFDemoAudiencePathCard: View {
    let path: HFFinalDemoAudiencePath

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: path.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: path.status, isProminent: false)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(path.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)

                    Text(path.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Start: \(path.recommendedStart)")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
            }
            .frame(width: 232, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

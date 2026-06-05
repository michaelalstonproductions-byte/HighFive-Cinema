import SwiftUI

struct HFCriticalPathCard: View {
    let index: Int
    let title: String
    let status: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.md) {
                Text("\(index)")
                    .font(HFTypography.caption)
                    .foregroundStyle(.black)
                    .frame(width: 32, height: 32)
                    .background(HFColors.gold)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(title)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(status)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
    }
}

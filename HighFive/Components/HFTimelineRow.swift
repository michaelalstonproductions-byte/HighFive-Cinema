import SwiftUI

struct HFTimelineRow: View {
    let title: String
    let detail: String
    let systemImage: String
    var isLast = false

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            VStack(spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 30, height: 30)
                    .background(HFColors.gold)
                    .clipShape(Circle())

                if !isLast {
                    Rectangle()
                        .fill(HFColors.glassStroke)
                        .frame(width: 1, height: 30)
                }
            }

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

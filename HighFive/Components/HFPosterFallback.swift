import SwiftUI

struct HFPosterFallback: View {
    let title: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    HFColors.charcoalLight,
                    HFColors.background,
                    HFColors.goldDeep.opacity(0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(HFColors.gold.opacity(0.16))
                    Image(systemName: "film.stack")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
                .frame(width: 54, height: 54)

                Text("Artwork Pending")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)

                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
        }
    }
}

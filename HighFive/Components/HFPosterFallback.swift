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

                Text("Artwork\nPending")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                    .hfReadableText(lines: 2, minimumScaleFactor: 0.50, alignment: .center)

                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .hfReadableText(lines: 3, minimumScaleFactor: 0.50, alignment: .center)
            }
            .padding(HFSpacing.sm)
        }
    }
}

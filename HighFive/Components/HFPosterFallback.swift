import SwiftUI

struct HFPosterFallback: View {
    let title: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    HFColors.glassSurfaceRaised,
                    HFColors.background.opacity(0.96),
                    HFColors.warmGlow.opacity(0.72),
                    HFColors.goldDeep.opacity(0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.11),
                    Color.clear,
                    HFColors.cyanGlow.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(HFColors.gold.opacity(0.18))
                        .overlay(Circle().stroke(HFColors.gold.opacity(0.20), lineWidth: 1))
                    Image(systemName: "film.stack")
                        .font(HFIconography.symbolFont(size: HFIconography.featureIconSize, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
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

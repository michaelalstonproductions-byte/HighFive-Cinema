import SwiftUI

struct HFLaunchBrandMark: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            depthRings

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.black.opacity(0.30),
                            HFColors.gold.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 116, height: 116)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    HFColors.gold.opacity(0.72),
                                    Color.white.opacity(0.18),
                                    HFColors.gold.opacity(0.28)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.3
                        )
                )
                .shadow(color: HFColors.gold.opacity(0.24), radius: 28, x: 0, y: 0)
                .shadow(color: .black.opacity(0.48), radius: 22, x: 0, y: 14)

            HStack(spacing: 3) {
                Text("H")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                Text("5")
                    .font(.system(size: 48, weight: .black, design: .rounded))
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.94, blue: 0.48),
                        HFColors.gold,
                        Color(red: 0.98, green: 0.48, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: HFColors.gold.opacity(0.45), radius: 14, x: 0, y: 0)

            Image(systemName: "play.fill")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.black.opacity(0.86))
                .frame(width: 28, height: 28)
                .background(HFColors.gold, in: Circle())
                .offset(x: 34, y: 34)
                .shadow(color: HFColors.gold.opacity(0.38), radius: 10, x: 0, y: 0)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.94)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("HighFive Cinema")
        .accessibilityIdentifier("hf.launch.brandMark")
    }

    private var depthRings: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 34 + CGFloat(index) * 8, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.18 - Double(index) * 0.045), lineWidth: 1)
                    .frame(
                        width: 136 + CGFloat(index) * 28,
                        height: 136 + CGFloat(index) * 28
                    )
                    .scaleEffect(isAnimating ? 1.03 + CGFloat(index) * 0.015 : 0.96)
                    .opacity(isAnimating ? 1.0 : 0.55)
            }
        }
    }
}

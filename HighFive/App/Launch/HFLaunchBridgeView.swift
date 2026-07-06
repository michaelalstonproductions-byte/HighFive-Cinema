import SwiftUI

struct HFLaunchBridgeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false
    @State private var shimmerOffset: CGFloat = -140

    var body: some View {
        ZStack {
            launchBackground

            VStack(spacing: 26) {
                HFLaunchBrandMark(isAnimating: reduceMotion || isAnimating)

                VStack(spacing: 8) {
                    Text("HIGHFIVE")
                        .font(.system(size: 34, weight: .black, design: .default))
                        .tracking(4.5)
                        .foregroundStyle(wordmarkGradient)
                        .shadow(color: HFColors.gold.opacity(0.34), radius: 16, x: 0, y: 0)

                    Text("CINEMA")
                        .font(.system(size: 15, weight: .heavy, design: .default))
                        .tracking(7)
                        .foregroundStyle(.white.opacity(0.86))

                    Text("Depth. Motion. Story.")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(.white.opacity(0.56))
                        .padding(.top, 4)
                }
                .accessibilityIdentifier("hf.launch.wordmark")

                premiumLoadingIndicator
                    .padding(.top, 4)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.70)) {
                isAnimating = true
            }

            withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                shimmerOffset = 140
            }
        }
        .accessibilityIdentifier("hf.launch.bridge")
    }

    private var launchBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.030, green: 0.024, blue: 0.018),
                    Color(red: 0.070, green: 0.045, blue: 0.018),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    HFColors.gold.opacity(0.22),
                    HFColors.gold.opacity(0.06),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 340
            )
            .ignoresSafeArea()

            DepthAtmosphereLayer(intensity: 0.52, tint: HFColors.gold)
                .blendMode(.screen)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.035),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 70)
            .offset(x: reduceMotion ? 0 : shimmerOffset)
            .blur(radius: 18)
            .ignoresSafeArea()
        }
    }

    private var wordmarkGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.96, blue: 0.55),
                HFColors.gold,
                Color(red: 0.95, green: 0.55, blue: 0.14)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var premiumLoadingIndicator: some View {
        HStack(spacing: 7) {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(HFColors.gold.opacity(0.92))
                    .frame(width: index == 2 ? 18 : 8, height: 5)
                    .opacity(reduceMotion ? 0.72 : (isAnimating ? 1.0 : 0.45))
                    .scaleEffect(reduceMotion ? 1 : (isAnimating ? 1.0 : 0.72))
                    .animation(
                        reduceMotion
                            ? nil
                            : .easeInOut(duration: 0.78)
                                .repeatForever()
                                .delay(Double(index) * 0.11),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 30)
        .background(Color.white.opacity(0.055), in: Capsule())
        .overlay(
            Capsule()
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
        .accessibilityIdentifier("hf.launch.loadingIndicator")
        .accessibilityHidden(true)
    }
}

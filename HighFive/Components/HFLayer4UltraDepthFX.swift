import SwiftUI

struct HFLayer4UltraDepthFX: View {
    var motion: DepthMotionValues
    var role: HFDepthSurfaceRole = .staticDecorative
    var tint: Color = HFColors.gold
    var showDust = true
    var showFocusBreath = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var lowPower: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    private var profile: HFDepthIntensityProfile {
        HFCinematicDepthDirector.profile(for: role)
    }

    private var effectiveMotion: DepthMotionValues {
        reduceMotion ? .still : motion
    }

    var body: some View {
        ZStack {
            HFLayer4VolumetricGlow(
                motion: effectiveMotion,
                tint: tint,
                intensity: Double(profile.glowMultiplier) * (lowPower ? 0.58 : 1.0)
            )

            if showDust {
                HFLayer4AtmosphericDust(
                    motion: effectiveMotion,
                    tint: tint,
                    intensity: lowPower ? 0.34 : 0.78
                )
            }

            HFLayer4GlassSweep(
                motion: effectiveMotion,
                tint: tint,
                intensity: role == .rowCard ? 0.42 : 0.84
            )

            if showFocusBreath {
                HFLayer4FocusBreath(
                    motion: effectiveMotion,
                    tint: tint,
                    intensity: lowPower ? 0.20 : 0.38
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct HFLayer4GlassSweep: View {
    var motion: DepthMotionValues = .still
    var tint: Color = HFColors.gold
    var intensity: Double = 1

    var body: some View {
        GeometryReader { proxy in
            let width = max(1, proxy.size.width)
            let height = max(1, proxy.size.height)
            let offsetX = motion.isActive ? -motion.x * width * 0.10 : 0
            let offsetY = motion.isActive ? -motion.y * height * 0.06 : 0

            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.030 * intensity),
                    tint.opacity(0.060 * intensity),
                    Color.white.opacity(0.075 * intensity),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: width * 0.62, height: height * 1.35)
            .rotationEffect(.degrees(-18))
            .blur(radius: 14)
            .offset(x: width * 0.34 + offsetX, y: -height * 0.16 + offsetY)
            .blendMode(.screen)
        }
    }
}

struct HFLayer4AtmosphericDust: View {
    var motion: DepthMotionValues = .still
    var tint: Color = HFColors.gold
    var intensity: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var lowPower: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var body: some View {
        GeometryReader { proxy in
            if reduceMotion || lowPower {
                dustClouds(size: proxy.size, drift: 0)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
                    let drift = timeline.date.timeIntervalSinceReferenceDate
                    dustClouds(size: proxy.size, drift: drift)
                }
            }
        }
    }

    private func dustClouds(size: CGSize, drift: TimeInterval) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let phase = Double(index) * 0.73
                let slowDrift = CGFloat(sin(drift * 0.16 + phase)) * 18
                let motionX = motion.isActive ? motion.x * CGFloat(8 + index * 2) : 0
                let motionY = motion.isActive ? motion.y * CGFloat(5 + index) : 0

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                tint.opacity(0.030 * intensity),
                                Color.white.opacity(0.018 * intensity),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: size.width * (0.58 + CGFloat(index) * 0.10),
                        height: 2 + CGFloat(index % 2)
                    )
                    .blur(radius: 10 + CGFloat(index) * 2)
                    .offset(
                        x: -size.width * 0.12 + CGFloat(index) * 34 + slowDrift + motionX,
                        y: size.height * (0.34 + CGFloat(index) * 0.09) + motionY
                    )
                    .opacity(0.72)
            }
        }
        .blendMode(.screen)
    }
}

struct HFLayer4VolumetricGlow: View {
    var motion: DepthMotionValues = .still
    var tint: Color = HFColors.gold
    var intensity: Double = 1

    var body: some View {
        RadialGradient(
            colors: [
                tint.opacity(0.18 * intensity),
                tint.opacity(0.055 * intensity),
                .clear
            ],
            center: UnitPoint(
                x: max(0.10, min(0.90, 0.52 - motion.x * 0.18)),
                y: max(0.10, min(0.78, 0.34 - motion.y * 0.14))
            ),
            startRadius: 4,
            endRadius: 380
        )
        .blendMode(.screen)
    }
}

struct HFLayer4FocusBreath: View {
    var motion: DepthMotionValues = .still
    var tint: Color = HFColors.gold
    var intensity: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var lowPower: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var body: some View {
        GeometryReader { proxy in
            let baseScale = motion.isActive ? 1.0 + min(0.010, abs(motion.x + motion.y) * 0.010) : 1.0

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.025 * intensity),
                            tint.opacity(0.080 * intensity),
                            .clear,
                            tint.opacity(0.035 * intensity)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: proxy.size.width * 0.94, height: proxy.size.height * 0.92)
                .scaleEffect(reduceMotion || lowPower ? 1.0 : baseScale)
                .blur(radius: 6)
                .opacity(0.80)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                .blendMode(.screen)
        }
    }
}

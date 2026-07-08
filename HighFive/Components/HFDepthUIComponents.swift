import SwiftUI
import CoreMotion
import Combine

struct DepthMotionValues: Equatable {
    var x: CGFloat
    var y: CGFloat
    var isActive: Bool
    var intensity: CGFloat = 1

    static let still = DepthMotionValues(x: 0, y: 0, isActive: false, intensity: 0)
}

enum HFDepthScenePhase: Equatable {
    case active
    case focused
    case pressed
    case background
    case inactive
}

enum HFDepthSurfaceRole: Equatable {
    case hero
    case detailPoster
    case focusedCard
    case rowCard
    case backgroundAtmosphere
    case compactUtility
    case staticDecorative
}

enum HFDepthRenderBudget: Equatable {
    case full
    case balanced
    case reduced
    case staticOnly
}

struct HFDepthIntensityProfile: Equatable {
    let imageOffsetMax: CGFloat
    let backgroundOffsetMax: CGFloat
    let glassOffsetMax: CGFloat
    let rotationMax: Double
    let shadowMultiplier: CGFloat
    let glowMultiplier: CGFloat
    let geometryInfluence: CGFloat
    let budget: HFDepthRenderBudget
}

struct HFCinematicDepthDirector {
    static func profile(
        for role: HFDepthSurfaceRole,
        phase: HFDepthScenePhase = .active
    ) -> HFDepthIntensityProfile {
        let lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        let powerScale: CGFloat = lowPower ? 0.62 : 1.0
        let phaseScale: CGFloat
        switch phase {
        case .pressed: phaseScale = 1.10
        case .focused: phaseScale = 1.0
        case .active: phaseScale = 0.92
        case .background: phaseScale = 0.58
        case .inactive: phaseScale = 0.0
        }
        let scale = powerScale * phaseScale

        switch role {
        case .hero:
            return HFDepthIntensityProfile(
                imageOffsetMax: 12 * scale,
                backgroundOffsetMax: 20 * scale,
                glassOffsetMax: 18 * scale,
                rotationMax: Double(1.0 * scale),
                shadowMultiplier: 1.0 * scale,
                glowMultiplier: 1.0 * scale,
                geometryInfluence: lowPower ? 0.055 : 0.10,
                budget: lowPower ? .balanced : .full
            )

        case .detailPoster:
            return HFDepthIntensityProfile(
                imageOffsetMax: 7 * scale,
                backgroundOffsetMax: 14 * scale,
                glassOffsetMax: 16 * scale,
                rotationMax: Double(1.1 * scale),
                shadowMultiplier: 1.0 * scale,
                glowMultiplier: 0.92 * scale,
                geometryInfluence: lowPower ? 0.07 : 0.12,
                budget: lowPower ? .balanced : .full
            )

        case .focusedCard:
            return HFDepthIntensityProfile(
                imageOffsetMax: 4 * scale,
                backgroundOffsetMax: 7 * scale,
                glassOffsetMax: 8 * scale,
                rotationMax: Double(0.7 * scale),
                shadowMultiplier: 0.82 * scale,
                glowMultiplier: 0.72 * scale,
                geometryInfluence: 0.065,
                budget: .balanced
            )

        case .rowCard:
            return HFDepthIntensityProfile(
                imageOffsetMax: 2 * scale,
                backgroundOffsetMax: 4 * scale,
                glassOffsetMax: 5 * scale,
                rotationMax: Double(0.4 * scale),
                shadowMultiplier: 0.55 * scale,
                glowMultiplier: 0.42 * scale,
                geometryInfluence: 0.035,
                budget: .reduced
            )

        case .backgroundAtmosphere:
            return HFDepthIntensityProfile(
                imageOffsetMax: 0,
                backgroundOffsetMax: 18 * scale,
                glassOffsetMax: 0,
                rotationMax: 0,
                shadowMultiplier: 0,
                glowMultiplier: 0.72 * scale,
                geometryInfluence: 0.08,
                budget: .balanced
            )

        case .compactUtility:
            return HFDepthIntensityProfile(
                imageOffsetMax: 2 * scale,
                backgroundOffsetMax: 3 * scale,
                glassOffsetMax: 4 * scale,
                rotationMax: Double(0.25 * scale),
                shadowMultiplier: 0.35 * scale,
                glowMultiplier: 0.30 * scale,
                geometryInfluence: 0.02,
                budget: .reduced
            )

        case .staticDecorative:
            return HFDepthIntensityProfile(
                imageOffsetMax: 0,
                backgroundOffsetMax: 0,
                glassOffsetMax: 0,
                rotationMax: 0,
                shadowMultiplier: 0.25,
                glowMultiplier: 0.25,
                geometryInfluence: 0,
                budget: .staticOnly
            )
        }
    }

    static func directedMotion(
        _ motion: DepthMotionValues,
        role: HFDepthSurfaceRole,
        phase: HFDepthScenePhase = .active,
        reduceMotion: Bool
    ) -> DepthMotionValues {
        guard !reduceMotion else { return .still }
        let profile = profile(for: role, phase: phase)
        guard profile.budget != .staticOnly else { return .still }
        let amount = min(1, max(0, motion.intensity))
        return DepthMotionValues(
            x: max(-1, min(1, motion.x)) * amount,
            y: max(-1, min(1, motion.y)) * amount,
            isActive: motion.isActive,
            intensity: amount
        )
    }
}

final class HFUIDepthMotionController: ObservableObject {
    static let shared = HFUIDepthMotionController()

    @Published private(set) var motion: DepthMotionValues = .still

    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    private var subscriberCount = 0
    private var neutralX: CGFloat = 0
    private var neutralY: CGFloat = 0
    private var filteredX: CGFloat = 0
    private var filteredY: CGFloat = 0
    private var hasNeutral = false
    private var warmupBlend: CGFloat = 0

    #if DEBUG && targetEnvironment(simulator)
    private var simulatorPreviewTimer: DispatchSourceTimer?
    private var simulatorPreviewStartTime: TimeInterval = 0
    #endif

    private init() {
        queue.name = "com.highfive.uiDepthMotion"
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
    }

    var isRunning: Bool {
        manager.isDeviceMotionActive
    }

    func start(reduceMotion: Bool) {
        subscriberCount += 1

        guard !reduceMotion else {
            stopAll()
            return
        }

        #if DEBUG && targetEnvironment(simulator)
        if Self.isSimulatorDepthPreviewEnabled {
            startSimulatorDepthPreview()
            return
        }
        #endif

        guard manager.isDeviceMotionAvailable else {
            motion = .still
            return
        }

        guard !manager.isDeviceMotionActive else { return }

        let lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        manager.deviceMotionUpdateInterval = lowPower ? 1.0 / 30.0 : 1.0 / 45.0
        resetFilter()

        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] deviceMotion, _ in
            guard let self, let deviceMotion else { return }

            let rawX = CGFloat(deviceMotion.gravity.x)
            let rawY = CGFloat(-deviceMotion.gravity.y)

            DispatchQueue.main.async {
                self.publish(rawX: rawX, rawY: rawY)
            }
        }
    }

    func stop() {
        subscriberCount = max(0, subscriberCount - 1)
        guard subscriberCount == 0 else { return }
        stopAll()
    }

    private func stopAll() {
        subscriberCount = 0
        #if DEBUG && targetEnvironment(simulator)
        stopSimulatorDepthPreview()
        #endif
        manager.stopDeviceMotionUpdates()
        resetFilter()
        motion = .still
    }

    private func resetFilter() {
        neutralX = 0
        neutralY = 0
        filteredX = 0
        filteredY = 0
        hasNeutral = false
        warmupBlend = 0
    }

    private func publish(rawX: CGFloat, rawY: CGFloat) {
        let lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        let inputScale: CGFloat = 0.38
        let normalizedX = clamped(rawX / inputScale)
        let normalizedY = clamped(rawY / inputScale)

        if !hasNeutral {
            neutralX = normalizedX
            neutralY = normalizedY
            hasNeutral = true
        }

        let targetX = quieted(clamped(normalizedX - neutralX))
        let targetY = quieted(clamped(normalizedY - neutralY))
        let smoothing: CGFloat = lowPower ? 0.10 : 0.145
        filteredX += (targetX - filteredX) * smoothing
        filteredY += (targetY - filteredY) * smoothing
        warmupBlend = min(1, warmupBlend + (lowPower ? 0.045 : 0.065))

        let intensity: CGFloat = lowPower ? 0.62 : 1
        motion = DepthMotionValues(
            x: clamped(filteredX * warmupBlend) * intensity,
            y: clamped(filteredY * warmupBlend) * intensity,
            isActive: warmupBlend > 0.08,
            intensity: intensity
        )
    }

    private func quieted(_ value: CGFloat) -> CGFloat {
        abs(value) < 0.018 ? 0 : value
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        max(-1, min(1, value))
    }

    #if DEBUG && targetEnvironment(simulator)
    private static var isSimulatorDepthPreviewEnabled: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("--hf-simulate-ui-depth")
            || arguments.contains("--hf-simulator-preview")
    }

    private func startSimulatorDepthPreview() {
        guard simulatorPreviewTimer == nil else { return }

        resetFilter()
        simulatorPreviewStartTime = Date().timeIntervalSinceReferenceDate

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.highfive.uiDepthMotion.simulatorPreview"))
        let lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        timer.schedule(deadline: .now(), repeating: .milliseconds(lowPower ? 100 : 66))
        timer.setEventHandler { [weak self] in
            guard let self else { return }

            let elapsed = Date().timeIntervalSinceReferenceDate - self.simulatorPreviewStartTime
            let lowPowerScale: CGFloat = ProcessInfo.processInfo.isLowPowerModeEnabled ? 0.55 : 1.0
            let x = CGFloat(sin(elapsed * Double.pi * 2.0 / 11.5)) * 0.35 * lowPowerScale
            let y = CGFloat(cos(elapsed * Double.pi * 2.0 / 13.0)) * 0.22 * lowPowerScale

            DispatchQueue.main.async {
                self.motion = DepthMotionValues(
                    x: x,
                    y: y,
                    isActive: true,
                    intensity: lowPowerScale
                )
            }
        }
        simulatorPreviewTimer = timer
        timer.resume()
    }

    private func stopSimulatorDepthPreview() {
        simulatorPreviewTimer?.cancel()
        simulatorPreviewTimer = nil
    }
    #endif
}

struct DepthMotionProvider<Content: View>: View {
    var isEnabled = true
    var clamp: CGFloat = 1
    var geometryInfluence: CGFloat = 0.16
    var role: HFDepthSurfaceRole = .staticDecorative
    var phase: HFDepthScenePhase = .active
    var content: (DepthMotionValues) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var motionController = HFUIDepthMotionController.shared

    init(
        isEnabled: Bool = true,
        clamp: CGFloat = 1,
        geometryInfluence: CGFloat = 0.16,
        role: HFDepthSurfaceRole = .staticDecorative,
        phase: HFDepthScenePhase = .active,
        @ViewBuilder content: @escaping (DepthMotionValues) -> Content
    ) {
        self.isEnabled = isEnabled
        self.clamp = clamp
        self.geometryInfluence = geometryInfluence
        self.role = role
        self.phase = phase
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            let screen = UIScreen.main.bounds
            let rawX = ((frame.midX - screen.midX) / max(1, screen.midX)) * geometryInfluence
            let rawY = ((frame.midY - screen.midY) / max(1, screen.midY)) * geometryInfluence
            let active = isEnabled && !reduceMotion
            let liveMotion = motionController.motion
            let x = max(-clamp, min(clamp, (liveMotion.isActive ? liveMotion.x : 0) + rawX))
            let y = max(-clamp, min(clamp, (liveMotion.isActive ? liveMotion.y : 0) + rawY))
            let rawMotion = active ? DepthMotionValues(
                x: x,
                y: y,
                isActive: liveMotion.isActive || abs(rawX) > 0.001 || abs(rawY) > 0.001,
                intensity: liveMotion.isActive ? liveMotion.intensity : 0.45
            ) : .still
            let motion = HFCinematicDepthDirector.directedMotion(
                rawMotion,
                role: role,
                phase: phase,
                reduceMotion: reduceMotion
            )

            content(motion)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onAppear {
            if isEnabled {
                motionController.start(reduceMotion: reduceMotion)
            }
        }
        .onDisappear {
            if isEnabled {
                motionController.stop()
            }
        }
        .onChange(of: reduceMotion) { newValue in
            if newValue {
                motionController.stop()
            } else if isEnabled {
                motionController.start(reduceMotion: false)
            }
        }
    }
}

struct DepthParallaxModifier: ViewModifier {
    var depth: CGFloat = 8
    var rotation: Double = 2
    var enabled = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        DepthMotionProvider(
            isEnabled: enabled && !reduceMotion,
            clamp: 1,
            geometryInfluence: HFCinematicDepthDirector.profile(for: .focusedCard).geometryInfluence,
            role: .focusedCard
        ) { motion in
            let x = motion.x
            let y = motion.y
            let active = enabled && !reduceMotion

            content
                .offset(
                    x: active ? -x * depth : 0,
                    y: active ? -y * depth * 0.56 : 0
                )
                .rotation3DEffect(
                    .degrees(active ? Double(-x) * rotation : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.55
                )
                .rotation3DEffect(
                    .degrees(active ? Double(y) * rotation * 0.45 : 0),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.55
                )
        }
    }
}

extension View {
    func depthParallax(depth: CGFloat = 8, rotation: Double = 2, enabled: Bool = true) -> some View {
        modifier(DepthParallaxModifier(depth: depth, rotation: rotation, enabled: enabled))
    }
}

struct DepthAtmosphereLayer: View {
    var motion: DepthMotionValues = .still
    var intensity: Double = 1
    var tint: Color = HFColors.gold

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    tint.opacity(0.24 * intensity),
                    tint.opacity(0.075 * intensity),
                    .clear
                ],
                center: UnitPoint(
                    x: max(0.12, min(0.88, 0.50 - motion.x * 0.16)),
                    y: max(0.10, min(0.76, 0.30 - motion.y * 0.12))
                ),
                startRadius: 12,
                endRadius: 420
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.045 * intensity),
                    .clear,
                    tint.opacity(0.08 * intensity),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.screen)

            LinearGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.26),
                    Color.black.opacity(0.86)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct PremiumDepthPosterView<Poster: View>: View {
    let width: CGFloat
    let height: CGFloat
    var scale: HFDepthPosterScale
    var role: HFDepthSurfaceRole
    var depthEnabled = true
    var poster: Poster

    init(
        width: CGFloat,
        height: CGFloat,
        scale: HFDepthPosterScale,
        role: HFDepthSurfaceRole? = nil,
        depthEnabled: Bool = true,
        @ViewBuilder poster: () -> Poster
    ) {
        self.width = width
        self.height = height
        self.scale = scale
        self.role = role ?? (scale == .detail ? .detailPoster : .rowCard)
        self.depthEnabled = depthEnabled
        self.poster = poster()
    }

    var body: some View {
        HFDepthPosterFrame(
            width: width,
            height: height,
            scale: scale,
            role: role,
            depthEnabled: depthEnabled
        ) {
            poster
        }
        .overlay(surfaceLightSweep)
        .accessibilityIdentifier(scale == .detail ? "hf.titleDetail.premiumDepthPoster" : "hf.catalog.premiumDepthPoster")
    }

    private var surfaceLightSweep: some View {
        RoundedRectangle(cornerRadius: scale.outerCornerRadius, style: .continuous)
            .stroke(Color.white.opacity(scale == .detail ? 0.10 : 0.045), lineWidth: 0.8)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(scale == .detail ? 0.16 : 0.07),
                        .clear,
                        HFColors.gold.opacity(scale == .detail ? 0.08 : 0.035)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct DepthHeroStage<Media: View, Foreground: View>: View {
    var height: CGFloat
    var depthEnabled = true
    var atmosphereTint: Color = HFColors.gold
    var role: HFDepthSurfaceRole = .hero
    var media: Media
    var foreground: (DepthMotionValues) -> Foreground

    init(
        height: CGFloat,
        depthEnabled: Bool = true,
        atmosphereTint: Color = HFColors.gold,
        role: HFDepthSurfaceRole = .hero,
        @ViewBuilder media: () -> Media,
        @ViewBuilder foreground: @escaping (DepthMotionValues) -> Foreground
    ) {
        self.height = height
        self.depthEnabled = depthEnabled
        self.atmosphereTint = atmosphereTint
        self.role = role
        self.media = media()
        self.foreground = foreground
    }

    var body: some View {
        let profile = HFCinematicDepthDirector.profile(for: role)
        DepthMotionProvider(
            isEnabled: depthEnabled,
            clamp: 1,
            geometryInfluence: profile.geometryInfluence,
            role: role
        ) { motion in
            ZStack(alignment: .bottomLeading) {
                media
                    .scaleEffect(motion.isActive ? 1.035 : 1)
                    .offset(
                        x: motion.isActive ? -motion.x * profile.backgroundOffsetMax : 0,
                        y: motion.isActive ? -motion.y * profile.backgroundOffsetMax * 0.58 : 0
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                DepthAtmosphereLayer(motion: motion, intensity: 1, tint: atmosphereTint)

                HFLayer4UltraDepthFX(
                    motion: motion,
                    role: role,
                    tint: atmosphereTint,
                    showDust: true,
                    showFocusBreath: false
                )

                foreground(motion)
                    .offset(
                        x: motion.isActive ? -motion.x * min(5, profile.imageOffsetMax * 0.50) : 0,
                        y: motion.isActive ? -motion.y * min(4, profile.imageOffsetMax * 0.38) : 0
                    )
            }
            .background(Color.black)
            .clipped()
        }
        .frame(height: height)
        .accessibilityIdentifier("hf.depth.heroStage")
    }
}

struct CompactImportSlateButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Import", systemImage: "movieclapper")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(Color.white.opacity(0.08), in: Capsule())
                .overlay(Capsule().stroke(HFColors.gold.opacity(0.28), lineWidth: 1))
                .shadow(color: HFColors.gold.opacity(0.10), radius: 12, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Import")
        .accessibilityIdentifier("hf.home.hero.import")
        .background(Color.clear.accessibilityIdentifier("hf.home.importVideos.cover"))
    }
}

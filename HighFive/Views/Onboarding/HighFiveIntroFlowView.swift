import AVFoundation
import Combine
import CoreMotion
import SwiftUI
import UIKit

private enum HighFiveLayer4DebugGate {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["HF_SHOW_LAYER4_DEBUG"] == "1"
            || ProcessInfo.processInfo.arguments.contains("HF_SHOW_LAYER4_DEBUG=1")
            || ProcessInfo.processInfo.arguments.contains("--hf-show-layer4-debug")
    }
}

enum HighFiveIntroStep: Int, CaseIterable {
    case intro
    case controls
    case timelinePractice

    var page: Int { rawValue }

    static var initialFromLaunchArguments: HighFiveIntroStep {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-onboarding-intro") || arguments.contains("--hf-start-intro-video") { return .intro }
        if arguments.contains("--hf-start-training-controls") { return .controls }
        if arguments.contains("--hf-start-timeline-practice") { return .timelinePractice }
        return .intro
    }
}

struct HighFiveIntroFlowView: View {
    let initialStep: HighFiveIntroStep
    let onFinish: () -> Void

    @State private var step: HighFiveIntroStep

    init(initialStep: HighFiveIntroStep = .intro, onFinish: @escaping () -> Void) {
        self.initialStep = initialStep
        self.onFinish = onFinish
        _step = State(initialValue: initialStep)
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            switch step {
            case .intro:
                HighFiveCinematicIntroView(
                    onNext: { advance(to: .controls) },
                    onSkip: onFinish
                )
                .transition(.opacity)
            case .controls:
                HighFiveTrainingControlsView(
                    onNext: { advance(to: .timelinePractice) }
                )
                .transition(.opacity)
            case .timelinePractice:
                HighFiveTimelinePracticeView(
                    onEnterHome: onFinish
                )
                .transition(.opacity)
            }

            VStack {
                Color.clear
                    .frame(height: 1)
                    .accessibilityIdentifier("hf.safeArea.topProtected")
                Spacer()
            }
            .allowsHitTesting(false)

            VStack {
                Spacer()
                if step != .timelinePractice {
                    HighFiveIntroPageDots(currentPage: step.page, totalPages: HighFiveIntroStep.allCases.count)
                        .padding(.bottom, 146)
                        .accessibilityIdentifier("hf.safeArea.bottomProtected")
                }
            }
            .allowsHitTesting(false)
        }
        .onAppear {
            step = initialStep
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 44)
                .onEnded { value in
                    advanceFromSwipe(value)
                }
        )
    }

    private func advance(to nextStep: HighFiveIntroStep) {
        withAnimation(.easeInOut(duration: 0.28)) {
            step = nextStep
        }
    }

    private func advanceFromSwipe(_ value: DragGesture.Value) {
        let horizontalTravel = abs(value.translation.width)
        guard horizontalTravel > 58, horizontalTravel > abs(value.translation.height) * 1.3 else { return }

        switch step {
        case .intro:
            advance(to: .controls)
        case .controls:
            advance(to: .timelinePractice)
        case .timelinePractice:
            onFinish()
        }
    }
}

private enum HighFiveLocalVideoResolver {
    private static let resourceSubdirectories: [String?] = [
        nil,
        "App/Resources/Intro",
        "App/Resources/PreviewClips",
        "Resources/Intro",
        "PreviewClips"
    ]

    static var introURL: URL? {
        localVideoURL(named: [
            "Timeline1",
            "timeline1",
            "HigherKey",
            "higherkey",
            "HighFive",
            "highfive",
            "girl_walking",
            "GirlWalking",
            "walking",
            "intro",
            "Intro"
        ])
    }

    static var timelineURL: URL? {
        localVideoURL(named: [
            "Timeline1",
            "timeline1",
            "timeline_1",
            "Timeline_1",
            "higherkey_timeline1",
            "HighFiveTimeline1",
            "preview_the_friendly_30s",
            "preview_paranormall_e1_30s"
        ])
    }

    private static func localVideoURL(named names: [String]) -> URL? {
        for name in names {
            for extensionName in ["mp4", "mov", "m4v"] {
                for subdirectory in resourceSubdirectories {
                    let url: URL?
                    if let subdirectory {
                        url = Bundle.main.url(forResource: name, withExtension: extensionName, subdirectory: subdirectory)
                    } else {
                        url = Bundle.main.url(forResource: name, withExtension: extensionName)
                    }

                    if let url {
                        return url
                    }
                }
            }
        }
        return nil
    }
}

private struct HighFiveCinematicIntroView: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    @State private var player: AVPlayer?
    @State private var isAnimating = false
    @State private var didAdvanceFromVideoEnd = false
    @State private var playbackEndObserver: NSObjectProtocol?
    @State private var introPrewarmTask: Task<Void, Never>?
    @State private var isIntroDepthPrewarmed = false
    @State private var shouldRevealIntroVideo = false
    @State private var layer4State: HighFivePracticeLayer4State = .idle
    @State private var layer4Task: Task<Void, Never>?
    @State private var debugState = HighFivePracticeLayer4DebugState()

    private var localVideoURL: URL? {
        HighFiveLocalVideoResolver.introURL
    }

    var body: some View {
        HighFiveIntroFrame(
            primaryTitle: nil,
            secondaryTitle: "Skip",
            primaryIdentifier: "hf.intro.next",
            secondaryIdentifier: "hf.intro.skip",
            onPrimary: onNext,
            onSecondary: onSkip
        ) {
            GeometryReader { proxy in
                let brandBottomPadding = max(214, min(238, proxy.size.height * 0.23))

                ZStack {
                    if let player {
                        HighFivePracticeLayer4Renderer(
                            player: player,
                            layer4State: layer4State,
                            configuration: .introLiveMotion,
                            debugState: $debugState
                        )
                        .opacity(shouldRevealIntroVideo ? 1 : 0.01)
                        .accessibilityIdentifier("hf.onboarding.intro.liveMotion")

                        if !shouldRevealIntroVideo {
                            HighFiveIntroDepthPrewarmCover()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .transition(.opacity)
                                .accessibilityIdentifier("hf.onboarding.intro.depthPrewarm")
                        }
                    } else {
                        HighFiveIntroFallbackCard(isAnimating: isAnimating)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .accessibilityIdentifier("hf.intro.videoFallback")
                    }

                    LinearGradient(
                        colors: [.black.opacity(0.03), .clear, .black.opacity(0.34)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    Text("HIGHFIVE CINEMA")
                        .font(.system(size: 34, weight: .black, design: .default))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.72)
                        .accessibilityIdentifier("hf.intro.highfiveCinema")
                        .padding(.horizontal, 22)
                        .padding(.bottom, brandBottomPadding)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 8)
                        .overlay(alignment: .bottom) {
                            Text("HIGHFIVE CINEMA")
                                .font(.system(size: 34, weight: .black, design: .default))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.72)
                                .blur(radius: 10)
                                .opacity(0.20)
                                .padding(.bottom, brandBottomPadding)
                        }

                    #if DEBUG
                    if HighFiveLayer4DebugGate.isEnabled {
                        HighFivePracticeLayer4DebugOverlay(
                            state: debugState,
                            sourceName: localVideoURL?.lastPathComponent ?? "Missing intro source"
                        )
                        .padding(.top, 72)
                        .padding(.leading, 12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .allowsHitTesting(false)
                    }
                    #endif
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .ignoresSafeArea()
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("hf.intro.verticalVideo")
                .onTapGesture {
                    onNext()
                }
                .onAppear {
                    if let localVideoURL, player == nil {
                        startIntroVideo(url: localVideoURL)
                    } else if player != nil {
                        startLayer4Runtime()
                    }
                }
                .accessibilityIdentifier("hf.intro.cinematic")
            }
        }
        .onAppear {
            if let localVideoURL, player == nil {
                startIntroVideo(url: localVideoURL)
            } else if player != nil {
                startLayer4Runtime()
            }

            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onDisappear {
            didAdvanceFromVideoEnd = true
            introPrewarmTask?.cancel()
            introPrewarmTask = nil
            isIntroDepthPrewarmed = false
            shouldRevealIntroVideo = false
            layer4Task?.cancel()
            layer4Task = nil
            layer4State = .idle
            removePlaybackEndObserver()
            player?.pause()
            player = nil
        }
    }

    private func startIntroVideo(url: URL) {
        let introPlayer = AVPlayer(url: url)
        introPlayer.isMuted = false
        introPlayer.volume = 1.0
        introPlayer.pause()
        introPlayer.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in }
        isIntroDepthPrewarmed = false
        shouldRevealIntroVideo = false
        player = introPlayer
        installPlaybackEndObserver(for: introPlayer)
        startLayer4Runtime()
        prewarmIntroDepth(player: introPlayer)
    }

    private func prewarmIntroDepth(player: AVPlayer) {
        introPrewarmTask?.cancel()
        introPrewarmTask = Task { @MainActor in
            #if DEBUG
            print("[IntroDepthPrewarm] configuring spatial player")
            #endif

            player.pause()
            await player.seek(to: .zero)

            let itemReady = await waitForIntroItemReady(player)
            guard !Task.isCancelled else { return }

            #if DEBUG
            if itemReady {
                print("[IntroDepthPrewarm] player item ready")
            }
            #endif

            _ = await waitForIntroDepthStateReady()
            guard !Task.isCancelled else { return }

            isIntroDepthPrewarmed = true
            withAnimation(.easeOut(duration: 0.28)) {
                shouldRevealIntroVideo = true
            }
            player.play()

            #if DEBUG
            print("[IntroDepthPrewarm] reveal intro")
            #endif
        }
    }

    @MainActor
    private func waitForIntroItemReady(_ player: AVPlayer) async -> Bool {
        for _ in 0..<12 {
            if Task.isCancelled { return false }
            if player.currentItem?.status == .failed { return false }
            if player.currentItem?.status == .readyToPlay {
                return true
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        return player.currentItem?.status == .readyToPlay
    }

    @MainActor
    private func waitForIntroDepthStateReady() async -> Bool {
        for _ in 0..<12 {
            if Task.isCancelled { return false }
            if layer4State == .spatialActive || layer4State == .fallbackFlat {
                return true
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        return layer4State == .spatialActive || layer4State == .fallbackFlat
    }

    private func installPlaybackEndObserver(for player: AVPlayer) {
        removePlaybackEndObserver()
        didAdvanceFromVideoEnd = false
        playbackEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            guard !didAdvanceFromVideoEnd else { return }
            didAdvanceFromVideoEnd = true
            onNext()
        }
    }

    private func removePlaybackEndObserver() {
        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
            self.playbackEndObserver = nil
        }
    }

    private func startLayer4Runtime() {
        layer4Task?.cancel()
        guard let player else {
            layer4State = .idle
            return
        }

        layer4State = .flatStartup
        layer4Task = Task { @MainActor in
            let stable = await waitForStablePlayback(player)
            guard !Task.isCancelled else { return }
            guard stable else {
                layer4State = .fallbackFlat
                return
            }

            layer4State = .playbackStabilizing
            try? await Task.sleep(nanoseconds: 320_000_000)
            guard !Task.isCancelled else { return }

            layer4State = .depthPreparing
            try? await Task.sleep(nanoseconds: 90_000_000)
            guard !Task.isCancelled else { return }

            layer4State = .spatialActive
        }
    }

    @MainActor
    private func waitForStablePlayback(_ player: AVPlayer) async -> Bool {
        for _ in 0..<70 {
            if Task.isCancelled { return false }
            if player.currentItem?.status == .failed { return false }
            if player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0 {
                return true
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        return player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0
    }

}

private struct HighFiveIntroDepthPrewarmCover: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.050, green: 0.036, blue: 0.018),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    HFColors.gold.opacity(0.18),
                    .clear
                ],
                center: .center,
                startRadius: 18,
                endRadius: 280
            )

            DepthAtmosphereLayer(intensity: 0.40, tint: HFColors.gold)
                .blendMode(.screen)

            VStack(spacing: 10) {
                Text("HIGHFIVE CINEMA")
                    .font(.system(size: 24, weight: .black, design: .default))
                    .tracking(3.2)
                    .foregroundStyle(HFColors.goldGradient)
                    .shadow(color: HFColors.gold.opacity(0.32), radius: 16, x: 0, y: 0)

                Text("Preparing depth...")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(.white.opacity(0.58))
            }
            .padding(.horizontal, 24)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Preparing depth")
    }
}

private struct HighFiveIntroFallbackCard: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black,
                            Color(red: 0.18, green: 0.11, blue: 0.04),
                            Color.black
                        ],
                        startPoint: isAnimating ? .topLeading : .topTrailing,
                        endPoint: isAnimating ? .bottomTrailing : .bottomLeading
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.42), lineWidth: 1)
                )

            Image(systemName: "figure.walk")
                .font(.system(size: 70, weight: .semibold))
                .foregroundStyle(.white, HFColors.gold)
                .offset(x: isAnimating ? 38 : -38, y: -16)
                .shadow(color: HFColors.gold.opacity(0.32), radius: 22, x: 0, y: 16)

            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(HFColors.gold.opacity(0.20 - Double(index) * 0.022))
                    .frame(width: 88 + CGFloat(index * 22), height: 4)
                    .offset(y: CGFloat(index * 26) - 10)
            }
        }
    }
}

struct HighFiveTrainingControlsView: View {
    let onNext: () -> Void

    @State private var isTilting = false

    var body: some View {
        HighFiveIntroFrame(
            primaryTitle: nil,
            secondaryTitle: nil,
            primaryIdentifier: "hf.training.next",
            secondaryIdentifier: nil,
            onPrimary: onNext,
            onSecondary: nil
        ) {
            VStack(spacing: 20) {
                tiltPeekDiagram
                    .accessibilityIdentifier("hf.training.diagram")
                    .onTapGesture {
                        onNext()
                    }

                HStack(spacing: 10) {
                    HighFiveInstructionChip(title: "Tilt", systemImage: "viewfinder")
                    HighFiveInstructionChip(title: "Peek", systemImage: "scope")
                }
                .accessibilityIdentifier("hf.training.tiltPeekInstructions")
            }
            .accessibilityIdentifier("hf.training.controls")
        }
        .onAppear {
            isTilting = true
        }
    }

    private var tiltPeekDiagram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white)
                .frame(width: 156, height: 308)
                .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 16)
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 27, style: .continuous)
                            .fill(Color(red: 0.05, green: 0.06, blue: 0.09))
                            .padding(8)

                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        HFColors.gold.opacity(0.38),
                                        Color(red: 0.12, green: 0.15, blue: 0.22),
                                        .white.opacity(0.10)
                                    ],
                                    startPoint: isTilting ? .topLeading : .topTrailing,
                                    endPoint: isTilting ? .bottomTrailing : .bottomLeading
                                )
                            )
                            .padding(14)
                            .offset(x: isTilting ? 16 : -16)

                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.16))
                            .frame(width: 84, height: 88)
                            .offset(x: isTilting ? -10 : 10, y: 78)

                        Capsule()
                            .fill(Color.black.opacity(0.22))
                            .frame(width: 44, height: 5)
                            .offset(y: -134)
                    }
                }
                .rotationEffect(.degrees(isTilting ? -7 : 7), anchor: .bottom)
                .rotation3DEffect(.degrees(isTilting ? -14 : 14), axis: (x: 0, y: 1, z: 0), perspective: 0.65)
                .offset(x: isTilting ? -5 : 5)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: isTilting)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tilt to move, peek to explore training diagram")
    }
}

struct HighFiveTimelinePracticeView: View {
    let onEnterHome: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var player: AVPlayer?
    @State private var playbackEndObserver: NSObjectProtocol?
    @State private var layer4State: HighFivePracticeLayer4State = .idle
    @State private var layer4Task: Task<Void, Never>?
    @State private var debugState = HighFivePracticeLayer4DebugState()
    @State private var instructionPhase: HighFivePracticeInstructionPhase = .hidden
    @State private var instructionTask: Task<Void, Never>?

    private var localVideoURL: URL? {
        HighFiveLocalVideoResolver.timelineURL
    }

    var body: some View {
        HighFiveIntroFrame(
            primaryTitle: "Enter HighFive Cinema",
            secondaryTitle: nil,
            primaryIdentifier: "hf.training.enterHome",
            secondaryIdentifier: nil,
            onPrimary: onEnterHome,
            onSecondary: nil
        ) {
            timelinePreview
                .ignoresSafeArea()
            .accessibilityIdentifier("hf.training.timelinePractice")
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                player?.play()
            }
        }
        .onDisappear {
            layer4Task?.cancel()
            layer4Task = nil
            instructionTask?.cancel()
            instructionTask = nil
            instructionPhase = .hidden
            layer4State = .idle
            removeLoopObserver()
            player?.pause()
            player = nil
        }
    }

    @ViewBuilder
    private var timelinePreview: some View {
        GeometryReader { proxy in
            ZStack {
                if let player {
                    HighFivePracticeLayer4Renderer(
                        player: player,
                        layer4State: layer4State,
                        configuration: .practiceDepthTiltPeek,
                        debugState: $debugState
                    )
                    .accessibilityIdentifier("hf.onboarding.practice.liveMotion")
                } else {
                    HighFiveTimelineFallback(progress: 0.36)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .accessibilityIdentifier("hf.training.timelineFallback")
                }

                HighFivePracticeInstructionOverlay(phase: instructionPhase)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 124)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("hf.training.instructionOverlay")

                #if DEBUG
                if HighFiveLayer4DebugGate.isEnabled {
                    HighFivePracticeLayer4DebugOverlay(
                        state: debugState,
                        sourceName: localVideoURL?.lastPathComponent ?? "Missing practice source"
                    )
                    .padding(.top, 72)
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .allowsHitTesting(false)
                }
                #endif
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .onAppear {
                if let localVideoURL {
                    startPracticeVideo(url: localVideoURL)
                }
                startLayer4Runtime()
                startInstructionSequence()
            }
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("hf.training.timelineVerticalVideo")
    }

    private func startInstructionSequence() {
        guard instructionTask == nil else { return }
        instructionTask = Task { @MainActor in
            instructionPhase = .tiltRight
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }

            instructionPhase = .hidden
            try? await Task.sleep(nanoseconds: 320_000_000)
            guard !Task.isCancelled else { return }

            instructionPhase = .tiltLeft
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }

            instructionPhase = .hidden
            try? await Task.sleep(nanoseconds: 320_000_000)
            guard !Task.isCancelled else { return }

            instructionPhase = .peek
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled else { return }

            instructionPhase = .hidden
            instructionTask = nil
        }
    }

    private func startPracticeVideo(url: URL) {
        guard player == nil else {
            player?.play()
            return
        }

        let practicePlayer = AVPlayer(url: url)
        practicePlayer.isMuted = false
        practicePlayer.volume = 1.0
        player = practicePlayer
        installLoopObserver(for: practicePlayer)
        practicePlayer.play()
        startLayer4Runtime()
    }

    private func installLoopObserver(for player: AVPlayer) {
        removeLoopObserver()
        playbackEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                player.play()
            }
        }
    }

    private func removeLoopObserver() {
        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
            self.playbackEndObserver = nil
        }
    }

    private func startLayer4Runtime() {
        layer4Task?.cancel()
        guard let player else {
            layer4State = .idle
            return
        }

        layer4State = .flatStartup
        layer4Task = Task { @MainActor in
            let stable = await waitForStablePlayback(player)
            guard !Task.isCancelled else { return }
            guard stable else {
                layer4State = .fallbackFlat
                return
            }

            layer4State = .playbackStabilizing
            try? await Task.sleep(nanoseconds: 320_000_000)
            guard !Task.isCancelled else { return }

            layer4State = .depthPreparing
            try? await Task.sleep(nanoseconds: 90_000_000)
            guard !Task.isCancelled else { return }

            layer4State = .spatialActive
        }
    }

    @MainActor
    private func waitForStablePlayback(_ player: AVPlayer) async -> Bool {
        for _ in 0..<70 {
            if Task.isCancelled { return false }
            if player.currentItem?.status == .failed { return false }
            if player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0 {
                return true
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        return player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0
    }

}

private struct HighFiveInstructionChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 14, weight: .black, design: .default))
            .foregroundStyle(.white)
            .frame(width: 104, height: 42)
            .background(.ultraThinMaterial, in: Capsule())
            .background(Color.white.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.28), lineWidth: 1))
            .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 8)
    }
}

private struct HighFiveTrainingStepPill: View {
    let number: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 15, weight: .black, design: .default))
                .foregroundStyle(.black)
                .frame(width: 32, height: 32)
                .background(HFColors.goldGradient)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 22, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(height: 64)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(HFColors.gold.opacity(0.22), lineWidth: 1))
    }
}

private struct HighFiveTimelineFallback: View {
    let progress: Double

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.04, green: 0.04, blue: 0.06),
                            Color(red: 0.20, green: 0.12, blue: 0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(index <= Int(progress * 10) ? HFColors.gold.opacity(0.82) : .white.opacity(0.14))
                        .frame(width: 14, height: CGFloat(76 + (index % 4) * 26))
                }
            }
            .padding(22)

        }
    }
}

private enum HighFivePracticeLayer4State: String {
    case idle
    case flatStartup
    case playbackStabilizing
    case depthPreparing
    case spatialActive
    case fallbackFlat
}

private struct HighFivePracticeLayer4DebugState: Equatable {
    var stepName = "Intro"
    var layer4State: HighFivePracticeLayer4State = .idle
    var depthEnabled = false
    var tiltPeekEnabled = false
    var motionEnabled = false
    var depthActive = false
    var tiltActive = false
    var peekActive = false
    var tiltX: CGFloat = 0
    var tiltY: CGFloat = 0
    var motionSource = "real device"
    var rendererPath = "HKV1_PlayerLayerView"
}

private struct HighFivePracticeLayer4Configuration: Equatable {
    let stepName: String
    let depthEnabled: Bool
    let tiltPeekEnabled: Bool
    let motionEnabled: Bool
    let framingScale: CGFloat
    let depthIntensity: CGFloat
    let focusFalloff: CGFloat
    let bgPlane: CGFloat
    let midPlane: CGFloat
    let fgPlane: CGFloat
    let tiltResponse: CGFloat
    let peekResponse: CGFloat

    static let introLiveMotion = HighFivePracticeLayer4Configuration(
        stepName: "First intro",
        depthEnabled: true,
        tiltPeekEnabled: true,
        motionEnabled: true,
        framingScale: 1.30,
        depthIntensity: 1.46,
        focusFalloff: 0.34,
        bgPlane: 1.80,
        midPlane: 2.00,
        fgPlane: 2.36,
        tiltResponse: 0.92,
        peekResponse: 0.94
    )

    static let practiceDepthTiltPeek = HighFivePracticeLayer4Configuration(
        stepName: "Final practice",
        depthEnabled: true,
        tiltPeekEnabled: true,
        motionEnabled: true,
        framingScale: 1.30,
        depthIntensity: 1.46,
        focusFalloff: 0.34,
        bgPlane: 1.80,
        midPlane: 2.00,
        fgPlane: 2.36,
        tiltResponse: 0.92,
        peekResponse: 0.94
    )
}

private enum HighFivePracticeInstructionPhase: Equatable {
    case hidden
    case tiltRight
    case tiltLeft
    case peek
}

private struct HighFivePracticeInstructionOverlay: View {
    let phase: HighFivePracticeInstructionPhase
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            switch phase {
            case .hidden:
                EmptyView()
            case .tiltRight:
                tiltPhoneCue(title: "Tilt", pointsRight: true)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            case .tiltLeft:
                tiltPhoneCue(title: "Tilt", pointsRight: false)
                    .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity))
            case .peek:
                peekCue
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.32), value: phase)
        .onAppear {
            restartInstructionMotion()
        }
        .onChange(of: phase) { _, _ in
            restartInstructionMotion()
        }
    }

    private func tiltPhoneCue(title: String, pointsRight: Bool) -> some View {
        let direction: CGFloat = pointsRight ? 1 : -1
        let baseTilt: Double = pointsRight ? 10 : -10
        let animatedTilt = baseTilt + (isAnimating ? Double(direction) * 4.0 : Double(direction) * -1.5)
        let screenTravel = isAnimating ? direction * 8 : direction * 2

        return HStack {
            if pointsRight {
                Spacer(minLength: 0)
            }

            HStack(spacing: 14) {
                phoneGlyph(tiltDegrees: animatedTilt, screenOffset: screenTravel)
                    .offset(x: isAnimating ? direction * 5 : direction * -2)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(pointsRight ? "1" : "2")
                            .font(.system(size: 14, weight: .black, design: .default))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 26, height: 26)
                            .overlay(Circle().stroke(HFColors.gold.opacity(0.86), lineWidth: 1.4))

                        Text(title)
                            .font(.system(size: 20, weight: .black, design: .default))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    Text(pointsRight ? "Tilt right" : "Tilt left")
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(1)
                }

                arrowGlyph(systemImage: pointsRight ? "arrow.right" : "arrow.left")
                    .offset(x: isAnimating ? direction * 7 : 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .background(Color.black.opacity(0.30), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.36), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.30), radius: 18, x: 0, y: 12)

            if !pointsRight {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var peekCue: some View {
        let peekX = isAnimating ? CGFloat(22) : CGFloat(-22)

        return VStack(spacing: 10) {
            HStack(spacing: 14) {
                arrowGlyph(systemImage: "arrow.left")
                    .offset(x: isAnimating ? -8 : 0)

                phoneGlyph(tiltDegrees: 0, screenOffset: 0)
                    .offset(x: peekX)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.32), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 7]))
                            .frame(width: 98, height: 84)
                    }

                arrowGlyph(systemImage: "arrow.right")
                    .offset(x: isAnimating ? 8 : 0)
            }

            HStack(spacing: 9) {
                Text("3")
                    .font(.system(size: 14, weight: .black, design: .default))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 26, height: 26)
                    .overlay(Circle().stroke(HFColors.gold.opacity(0.86), lineWidth: 1.4))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Peek")
                        .font(.system(size: 20, weight: .black, design: .default))
                        .foregroundStyle(.white)

                    Text("Move left and right")
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HFColors.gold.opacity(0.34), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.30), radius: 18, x: 0, y: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func phoneGlyph(tiltDegrees: Double, screenOffset: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.92))
                .frame(width: 38, height: 72)
                .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 5)

            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.70),
                            Color(red: 0.09, green: 0.10, blue: 0.16),
                            .white.opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 62)
                .offset(x: screenOffset)

            Capsule()
                .fill(.black.opacity(0.26))
                .frame(width: 12, height: 2)
                .offset(y: -28)
        }
        .rotationEffect(.degrees(tiltDegrees), anchor: .bottom)
        .rotation3DEffect(.degrees(tiltDegrees * 1.7), axis: (x: 0, y: 1, z: 0), perspective: 0.70)
    }

    private func arrowGlyph(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 24, weight: .black))
            .foregroundStyle(HFColors.gold)
            .frame(width: 38, height: 38)
            .background(.white.opacity(0.10), in: Circle())
            .overlay(Circle().stroke(.white.opacity(0.16), lineWidth: 1))
    }

    private func restartInstructionMotion() {
        isAnimating = false
        DispatchQueue.main.async {
            let duration = phase == .peek ? 1.05 : 0.92
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

private struct HighFivePracticeLayer4DebugOverlay: View {
    let state: HighFivePracticeLayer4DebugState
    let sourceName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            debugPill("Step: \(state.stepName)", systemImage: "1.circle")
            debugPill("Layer 4: \(state.layer4State.rawValue)", systemImage: "square.stack.3d.up.fill")
            debugPill("Config depth \(state.depthEnabled) tilt/peek \(state.tiltPeekEnabled) motion \(state.motionEnabled)", systemImage: "switch.2")
            debugPill("Depth: \(state.depthActive ? "true" : "false")", systemImage: "cube.transparent")
            debugPill("Tilt: \(String(format: "%+.2f", Double(state.tiltX))) / \(String(format: "%+.2f", Double(state.tiltY)))", systemImage: "viewfinder")
            debugPill("Peek: \(state.peekActive ? "true" : "false")", systemImage: "scope")
            debugPill("Motion: \(state.motionSource)", systemImage: "gyroscope")
            debugPill("Renderer: \(state.rendererPath)", systemImage: "rectangle.stack.fill")
            debugPill("Source: \(sourceName)", systemImage: "film.stack")
        }
        .accessibilityIdentifier("hf.training.layer4.debugOverlay")
    }

    private func debugPill(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 10, weight: .black, design: .monospaced))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.62)
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(.black.opacity(0.48), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.28), lineWidth: 1))
    }
}

private final class HighFivePracticeLayer4ContainerView: UIView {
    let playerView = HKV1_PlayerLayerView()

    var framingScale: CGFloat = 1.12 {
        didSet { setNeedsLayout() }
    }

    private(set) var currentStageOffset: CGPoint = .zero
    private(set) var maxTravelX: CGFloat = 0
    private(set) var maxTravelY: CGFloat = 0

    private let portraitStageOverscanScale: CGFloat = 1.12
    private let landscapeStageOverscanScale: CGFloat = 1.10
    private let stageFactor: CGFloat = 0.94

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
        playerView.clipsToBounds = false
        addSubview(playerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutStage()
    }

    func setStageOffset(_ offset: CGPoint) {
        currentStageOffset = CGPoint(
            x: softLimitedOffset(offset.x, limit: maxTravelX),
            y: softLimitedOffset(offset.y, limit: maxTravelY)
        )
        applyStageCenter()
    }

    func resetMotion() {
        currentStageOffset = .zero
        applyStageCenter()
        playerView.bgOffset = .zero
        playerView.midOffset = .zero
        playerView.fgOffset = .zero
    }

    private func layoutStage() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let isPortrait = bounds.height >= bounds.width
        let stageSize = computeStageSize(for: bounds.size, isPortrait: isPortrait)
        maxTravelX = max(0, (stageSize.width - bounds.width) * 0.5)
        maxTravelY = max(0, (stageSize.height - bounds.height) * 0.5)
        currentStageOffset.x = max(-maxTravelX, min(maxTravelX, currentStageOffset.x))
        currentStageOffset.y = max(-maxTravelY, min(maxTravelY, currentStageOffset.y))
        playerView.bounds = CGRect(origin: .zero, size: stageSize)
        applyStageCenter()
    }

    private func computeStageSize(for maskSize: CGSize, isPortrait: Bool) -> CGSize {
        let safeFramingScale = max(1.0, min(framingScale / 1.24, 1.10))

        if isPortrait {
            let stageHeight = maskSize.height * portraitStageOverscanScale * safeFramingScale
            return CGSize(width: stageHeight * (16.0 / 9.0), height: stageHeight)
        }

        let stageWidth = maskSize.width * landscapeStageOverscanScale * safeFramingScale
        let stageHeight = stageWidth * (9.0 / 16.0)
        if stageHeight < maskSize.height {
            let correctedHeight = maskSize.height * landscapeStageOverscanScale * safeFramingScale
            return CGSize(width: correctedHeight * (16.0 / 9.0), height: correctedHeight)
        }
        return CGSize(width: stageWidth, height: stageHeight)
    }

    private func applyStageCenter() {
        playerView.center = CGPoint(
            x: bounds.midX + currentStageOffset.x * stageFactor,
            y: bounds.midY + currentStageOffset.y * stageFactor
        )
    }

    private func softLimitedOffset(_ value: CGFloat, limit: CGFloat) -> CGFloat {
        guard limit > 0 else { return 0 }
        return tanh(value / limit) * limit
    }
}

private struct HighFivePracticeLayer4Renderer: UIViewRepresentable {
    let player: AVPlayer
    let layer4State: HighFivePracticeLayer4State
    let configuration: HighFivePracticeLayer4Configuration
    @Binding var debugState: HighFivePracticeLayer4DebugState

    func makeUIView(context: Context) -> HighFivePracticeLayer4ContainerView {
        let view = HighFivePracticeLayer4ContainerView()
        view.accessibilityIdentifier = "hf.onboarding.spatialMotionPlayer"
        configure(view, context: context)
        context.coordinator.start(containerView: view)
        return view
    }

    func updateUIView(_ uiView: HighFivePracticeLayer4ContainerView, context: Context) {
        configure(uiView, context: context)
    }

    static func dismantleUIView(_ uiView: HighFivePracticeLayer4ContainerView, coordinator: Coordinator) {
        coordinator.stop()
        uiView.playerView.setPlayer(nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func configure(_ view: HighFivePracticeLayer4ContainerView, context: Context) {
        let depthActive = configuration.depthEnabled && layer4State == .spatialActive
        let motionActive = depthActive && configuration.tiltPeekEnabled && configuration.motionEnabled
        view.framingScale = depthActive ? configuration.framingScale : 1.24
        view.playerView.setPlayer(player)
        view.playerView.allowsFallbackFullFrameMasks = depthActive
        view.playerView.setLensMode(.portrait)
        view.playerView.setLUTMode(.off)
        view.playerView.setDepthIntensity(depthActive ? configuration.depthIntensity : 0)
        view.playerView.setFocusFalloff(depthActive ? configuration.focusFalloff : 0)
        view.playerView.setPlaneAuthority(
            bg: depthActive ? configuration.bgPlane : 1.0,
            mid: depthActive ? configuration.midPlane : 1.0,
            fg: depthActive ? configuration.fgPlane : 1.0,
            userDriven: true
        )
        view.playerView.setRenderMode(depthActive ? .depthPrepared : .flat)
        view.playerView.setSpatialMode(depthActive ? .threePlane : .flat)
        context.coordinator.layer4State = layer4State
        context.coordinator.configuration = configuration
        context.coordinator.debugState = $debugState
        if !motionActive {
            context.coordinator.resetMotionSmoothing()
        }
        context.coordinator.start(containerView: view)
    }

    final class Coordinator: NSObject {
        var layer4State: HighFivePracticeLayer4State = .idle
        var configuration = HighFivePracticeLayer4Configuration.practiceDepthTiltPeek
        var debugState: Binding<HighFivePracticeLayer4DebugState>?

        private let motionService = HKV1_MotionService()
        private let proMotionCoordinator = HKV1_ProMotionCoordinator()
        private weak var containerView: HighFivePracticeLayer4ContainerView?
        private var displayLink: CADisplayLink?
        private var lastTimestamp: CFTimeInterval = 0
        private var lastDebugPublishTimestamp: CFTimeInterval = 0
        private var neutralTilt: CGPoint?
        private var smoothedDx: CGFloat = 0
        private var smoothedDy: CGFloat = 0
        private var lastMotionLogKey: String?

        func start(containerView: HighFivePracticeLayer4ContainerView) {
            self.containerView = containerView
            if !motionService.isRunning {
                motionService.simulatorTiltMode = .figureEight
                motionService.simulatorAmplitudeX = 0.22
                motionService.simulatorAmplitudeY = 0.13
                motionService.simulatorSpeed = 0.95
                motionService.start()
            }
            if displayLink == nil {
                let link = CADisplayLink(target: self, selector: #selector(step(_:)))
                link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
                link.add(to: .main, forMode: .common)
                displayLink = link
            }
        }

        func stop() {
            displayLink?.invalidate()
            displayLink = nil
            motionService.stop()
            resetMotionSmoothing()
        }

        func resetMotionSmoothing() {
            proMotionCoordinator.reset()
            motionService.reset()
            smoothedDx = 0
            smoothedDy = 0
            neutralTilt = nil
            lastTimestamp = 0
            lastDebugPublishTimestamp = 0
            containerView?.resetMotion()
        }

        @objc private func step(_ link: CADisplayLink) {
            guard let containerView else { return }

            let deltaTime: CGFloat
            if lastTimestamp > 0 {
                deltaTime = CGFloat(max(1.0 / 120.0, min(link.timestamp - lastTimestamp, 1.0 / 20.0)))
            } else {
                deltaTime = 1.0 / 60.0
            }
            lastTimestamp = link.timestamp

            let depthActive = configuration.depthEnabled && layer4State == .spatialActive
            let tilt = motionService.readTilt()
            let motionActive = depthActive && configuration.tiltPeekEnabled && configuration.motionEnabled
            guard depthActive else {
                containerView.resetMotion()
                publishDebugIfNeeded(link.timestamp, tilt: CGPoint(x: CGFloat(tilt.x), y: CGFloat(tilt.y)), depthActive: false)
                return
            }
            guard motionActive else {
                containerView.resetMotion()
                publishDebugIfNeeded(link.timestamp, tilt: .zero, depthActive: true)
                return
            }

            let rawTilt = CGPoint(x: CGFloat(tilt.x), y: CGFloat(tilt.y))
            if neutralTilt == nil {
                neutralTilt = rawTilt
            }
            let viewerTilt = calibratedViewerTilt(rawTilt)
            let maxDx = max(70, containerView.maxTravelX)
            let maxDy = max(48, containerView.maxTravelY)
            let actionAmount = smoothstep(edge0: 0, edge1: 1, x: max(configuration.tiltResponse, configuration.peekResponse))
            let response = max(0.18, max(configuration.tiltResponse, configuration.peekResponse) * lerp(1.0, 1.34, actionAmount))
            let output = proMotionCoordinator.compute(
                roll: clamp(viewerTilt.x * response, min: -0.72, max: 0.72),
                pitch: clamp(viewerTilt.y * response, min: -0.54, max: 0.54),
                deltaTime: deltaTime * lerp(1.54, 2.10, actionAmount),
                lensProfile: .portrait,
                personality: .cinematic,
                maxDx: maxDx,
                maxDy: maxDy
            )

            let peekBlend: CGFloat = 0.62
            let target = CGPoint(
                x: lerp(output.tiltDx, output.peekDx, peekBlend),
                y: lerp(output.tiltDy, output.peekDy, peekBlend)
            )
            let targetGain = configuration.peekResponse * lerp(1.0, 1.85, actionAmount)
            let boostedTarget = CGPoint(x: target.x * targetGain, y: target.y * targetGain)
            let tuning = resolvedMotionResponse(maxDx: maxDx, maxDy: maxDy)
            smoothedDx = premiumWeightedBlend(current: smoothedDx, target: boostedTarget.x, dt: deltaTime, response: tuning.x * lerp(1.0, 1.42, actionAmount), residualDamp: tuning.residualDampX)
            smoothedDy = premiumWeightedBlend(current: smoothedDy, target: boostedTarget.y, dt: deltaTime, response: tuning.y * lerp(1.0, 1.36, actionAmount), residualDamp: tuning.residualDampY)
            let safeLimitX = maxDx * softLimitInputMultiplier(forFinalTravelRatio: 0.85)
            let safeLimitY = maxDy * softLimitInputMultiplier(forFinalTravelRatio: 0.85)
            let approvedOffset = CGPoint(
                x: featherEdgeLimit(value: softenedCenterOffset(smoothedDx, centerWidth: tuning.centerWidthX), limit: safeLimitX * 0.985, shoulderStart: 0.72, softness: 0.42),
                y: featherEdgeLimit(value: softenedCenterOffset(smoothedDy, centerWidth: tuning.centerWidthY), limit: safeLimitY * 0.985, shoulderStart: 0.74, softness: 0.46)
            )
            containerView.setStageOffset(approvedOffset)

            let residual = CGPoint(
                x: containerView.currentStageOffset.x * 0.10,
                y: containerView.currentStageOffset.y * 0.10
            )
            let centerDistance = hypot(containerView.currentStageOffset.x, containerView.currentStageOffset.y)
            let centerCollapseScale = lerp(0.34, 1.0, smoothstep(edge0: 5, edge1: 22, x: centerDistance))
            let playerView = containerView.playerView
            playerView.bgOffset = CGPoint(x: residual.x * 0.18 * centerCollapseScale, y: residual.y * 0.11 * centerCollapseScale)
            playerView.midOffset = CGPoint(x: residual.x * 0.42 * centerCollapseScale, y: residual.y * 0.25 * centerCollapseScale)
            playerView.fgOffset = CGPoint(x: residual.x * 0.70 * centerCollapseScale, y: residual.y * 0.42 * centerCollapseScale)
            logLiveMotionIfNeeded(depthActive: depthActive, motionActive: motionActive)
            publishDebugIfNeeded(link.timestamp, tilt: CGPoint(x: CGFloat(tilt.x), y: CGFloat(tilt.y)), depthActive: true)
        }

        private func calibratedViewerTilt(_ tilt: CGPoint) -> CGPoint {
            let neutral = neutralTilt ?? .zero
            return CGPoint(
                x: clamp(tilt.x - neutral.x, min: -0.62, max: 0.62),
                y: clamp(tilt.y - neutral.y, min: -0.46, max: 0.46)
            )
        }

        private func resolvedMotionResponse(
            maxDx: CGFloat,
            maxDy: CGFloat
        ) -> (x: CGFloat, y: CGFloat, centerWidthX: CGFloat, centerWidthY: CGFloat, residualDampX: CGFloat, residualDampY: CGFloat) {
            (
                x: 8.0,
                y: 7.2,
                centerWidthX: max(6.6, maxDx * 0.080),
                centerWidthY: max(4.4, maxDy * 0.108),
                residualDampX: 0.987,
                residualDampY: 0.989
            )
        }

        private func softLimitInputMultiplier(forFinalTravelRatio ratio: CGFloat) -> CGFloat {
            let target = clamp(ratio, min: 0, max: 0.85)
            guard target > 0 else { return 0 }
            return 0.5 * log((1 + target) / max(0.0001, 1 - target))
        }

        private func logLiveMotionIfNeeded(depthActive: Bool, motionActive: Bool) {
            #if DEBUG
            let key = "\(configuration.stepName)-\(depthActive)-\(motionActive)-\(configuration.tiltPeekEnabled)-\(configuration.motionEnabled)"
            guard key != lastMotionLogKey else { return }
            lastMotionLogKey = key
            print("[OnboardingMotion] live spatial motion active depth=\(depthActive) tilt=\(configuration.tiltPeekEnabled) peek=\(configuration.tiltPeekEnabled) motion=\(configuration.motionEnabled) renderer=HKV1_PlayerLayerView")
            #endif
        }

        private func publishDebugIfNeeded(_ timestamp: CFTimeInterval, tilt: CGPoint, depthActive: Bool) {
            guard timestamp - lastDebugPublishTimestamp > 0.20 else { return }
            lastDebugPublishTimestamp = timestamp
            let source: String
            #if targetEnvironment(simulator)
            source = "simulator fallback"
            #else
            source = "real device"
            #endif
            debugState?.wrappedValue = HighFivePracticeLayer4DebugState(
                stepName: configuration.stepName,
                layer4State: layer4State,
                depthEnabled: configuration.depthEnabled,
                tiltPeekEnabled: configuration.tiltPeekEnabled,
                motionEnabled: configuration.motionEnabled,
                depthActive: depthActive,
                tiltActive: depthActive && configuration.tiltPeekEnabled && configuration.motionEnabled,
                peekActive: depthActive && configuration.tiltPeekEnabled && configuration.motionEnabled,
                tiltX: tilt.x,
                tiltY: tilt.y,
                motionSource: source,
                rendererPath: "HKV1_PlayerLayerView"
            )
        }

        private func smoothstep(edge0: CGFloat, edge1: CGFloat, x: CGFloat) -> CGFloat {
            guard edge0 != edge1 else { return x < edge0 ? 0 : 1 }
            let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
            return t * t * (3 - 2 * t)
        }

        private func softenedCenterOffset(_ value: CGFloat, centerWidth: CGFloat) -> CGFloat {
            let magnitude = abs(value)
            guard centerWidth > 0, magnitude > 0 else { return value }
            let t = clamp(magnitude / centerWidth, min: 0, max: 1)
            let eased = t * t * (3 - (2 * t))
            let scale = 0.82 + (0.18 * eased)
            return (value >= 0 ? 1 : -1) * magnitude * scale
        }

        private func premiumWeightedBlend(current: CGFloat, target: CGFloat, dt: CGFloat, response: CGFloat, residualDamp: CGFloat) -> CGFloat {
            let alpha = 1.0 - exp(-response * dt)
            var next = current + ((target - current) * alpha)
            if abs(target) < 0.0012 {
                next *= residualDamp
            }
            if abs(next) < 0.0008 {
                next = 0
            }
            return next
        }

        private func featherEdgeLimit(value: CGFloat, limit: CGFloat, shoulderStart: CGFloat, softness: CGFloat) -> CGFloat {
            guard limit > 0 else { return 0 }
            let normalized = clamp(value / limit, min: -1, max: 1)
            let sign: CGFloat = normalized < 0 ? -1 : 1
            let magnitude = abs(normalized)
            if magnitude <= shoulderStart {
                return normalized * limit
            }
            let remaining = max(0.0001, 1 - shoulderStart)
            let u = clamp((magnitude - shoulderStart) / remaining, min: 0, max: 1)
            let eased = shoulderStart + ((1 - shoulderStart) * (1 - exp(-(u / max(0.0001, softness)))))
            return sign * min(1, eased) * limit
        }

        private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
            a + ((b - a) * t)
        }

        private func clamp(_ value: CGFloat, min lowerBound: CGFloat, max upperBound: CGFloat) -> CGFloat {
            Swift.max(lowerBound, Swift.min(upperBound, value))
        }
    }
}

private struct HighFiveVerticalStageContainer<Content: View>: View {
    let maxStageHeight: CGFloat
    let reservedHeight: CGFloat
    @ViewBuilder let content: (CGSize) -> Content

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(240, proxy.size.width - 56)
            let availableHeight = max(360, min(maxStageHeight, proxy.size.height - reservedHeight))
            let stageWidth = min(availableWidth, availableHeight * 9 / 16)
            let stageHeight = stageWidth * 16 / 9

            content(CGSize(width: stageWidth, height: stageHeight))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: maxStageHeight + reservedHeight)
    }
}

private struct HighFiveVerticalDepthVideoStage<Fallback: View, Overlay: View>: View {
    let player: AVPlayer?
    var cornerRadius: CGFloat = 34
    var fillsContainer = false
    let hasLocalVideo: Bool
    var depthEnabled = true
    var tiltPeekEnabled = true
    var motionEnabled = true
    var maxTranslationX: CGFloat = 32
    var maxTranslationY: CGFloat = 18
    var sourceName: String = "Unknown source"
    let playerIdentifier: String
    let fallbackIdentifier: String
    @ViewBuilder let fallback: Fallback
    @ViewBuilder let overlay: Overlay
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var motionModel = HighFiveTiltPeekMotionModel()
    @State private var isLayer4Active = false
    @State private var isFallbackFlat = false
    @State private var layer4ActivationTask: Task<Void, Never>?
    private let previewDepthDirector = HKV1_Layer4PreviewDepthDirector()

    var body: some View {
        Group {
            if fillsContainer {
                stageContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                stageContent
                    .aspectRatio(9 / 16, contentMode: .fit)
            }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(HFColors.gold.opacity(cornerRadius == 0 ? 0.0 : 0.40), lineWidth: 1))
        .shadow(color: HFColors.gold.opacity(cornerRadius == 0 ? 0.0 : 0.16), radius: 28, x: 0, y: 20)
        .onAppear {
            previewDepthDirector.setProfile(.hyperPreview)
            startFlatFirstLayer4Activation()
        }
        .onChange(of: motionEnabled) { _, _ in
            startMotionIfNeeded()
        }
        .onChange(of: player != nil) { _, _ in
            startFlatFirstLayer4Activation()
        }
        .onDisappear {
            layer4ActivationTask?.cancel()
            layer4ActivationTask = nil
            isLayer4Active = false
            isFallbackFlat = false
            motionModel.stop()
        }
    }

    private var envelope: HKV1_Layer4PreviewEnvelope {
        previewDepthDirector.resolve(
            tiltX: motionModel.normalizedTilt.x,
            tiltY: motionModel.normalizedTilt.y,
            depthAvailable: hasLocalVideo && depthEnabled && isLayer4Active,
            layerHealth: hasLocalVideo ? 1.0 : 0.70,
            bungeeRisk: 0.0,
            hingeRisk: 0.0,
            foldbackRisk: 0.0,
            reduceMotion: reduceMotion || !isLayer4Active
        )
    }

    private var depthLift: CGFloat {
        guard isLayer4Active, depthEnabled, hasLocalVideo else { return 0 }
        return max(envelope.uiDepthAmount, tiltPeekEnabled ? 0.72 : 0.58)
    }

    private var visibleDepthEnergy: CGFloat {
        guard isLayer4Active, depthEnabled, hasLocalVideo else { return 0 }
        return max(envelope.depthEnergy, tiltPeekEnabled ? 0.68 : 0.52)
    }

    private var stageContent: some View {
        ZStack {
            if hasLocalVideo, let player {
                layeredVideoStage(player: player)
            } else {
                fallback
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .scaleEffect(fallbackScale, anchor: .center)
                    .offset(fallbackOffset)
                    .accessibilityIdentifier(fallbackIdentifier)
            }

            LinearGradient(
                colors: [.black.opacity(0.03), .clear, .black.opacity(0.34)],
                startPoint: .top,
                endPoint: .bottom
            )

            overlay

            #if DEBUG
            if HighFiveLayer4DebugGate.isEnabled {
                layer4DebugOverlay
            }
            #endif
        }
    }

    private func layeredVideoStage(player: AVPlayer) -> some View {
        ZStack {
            videoPlane(
                player: player,
                scale: envelope.backgroundScalar,
                gain: 0.24,
                opacity: isLayer4Active && depthEnabled ? 0.18 : 0,
                blur: isLayer4Active && depthEnabled ? 0.18 : 0
            )

            videoPlane(
                player: player,
                scale: envelope.midgroundScalar,
                gain: 0.58,
                opacity: 1.0,
                blur: 0
            )
            .accessibilityIdentifier(playerIdentifier)

            if isLayer4Active && depthEnabled {
                videoPlane(
                    player: player,
                    scale: envelope.foregroundScalar,
                    gain: 1.08,
                    opacity: 0.13,
                    blur: 0
                )
                .allowsHitTesting(false)

                videoPlane(
                    player: player,
                    scale: 1.006 + visibleDepthEnergy * 0.008,
                    gain: 0.22,
                    opacity: 0.08,
                    blur: 0.7
                )
                .blendMode(.plusLighter)
                .accessibilityIdentifier("hf.layer4.focusLayer")
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .scaleEffect(isLayer4Active && depthEnabled ? envelope.globalPlaneScalar : 1.0, anchor: .center)
        .shadow(
            color: HFColors.gold.opacity(depthLift * 0.12),
            radius: 16 + (depthLift * 16),
            x: tiltPeekEnabled ? -planeOffset(gain: 0.15).width : 0,
            y: 10
        )
    }

    private func videoPlane(
        player: AVPlayer,
        scale: CGFloat,
        gain: CGFloat,
        opacity: CGFloat,
        blur: CGFloat
    ) -> some View {
        HighFiveVerticalVideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .scaleEffect(scale, anchor: .center)
            .offset(planeOffset(gain: gain))
            .blur(radius: blur)
            .opacity(opacity)
    }

    private var fallbackScale: CGFloat {
        isLayer4Active && depthEnabled ? 1.018 + visibleDepthEnergy * 0.018 : 1.0
    }

    private var fallbackOffset: CGSize {
        planeOffset(gain: 0.34)
    }

    private func planeOffset(gain: CGFloat) -> CGSize {
        guard isLayer4Active, tiltPeekEnabled, motionEnabled, !reduceMotion else { return .zero }
        let x = HKV1_Layer4Math.clamp(envelope.stageOffset.x * gain, -24, 24)
        let y = HKV1_Layer4Math.clamp(envelope.stageOffset.y * gain, -14, 14)
        return CGSize(width: x, height: y)
    }

    #if DEBUG
    private var layer4DebugOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isFallbackFlat {
                debugPill("Fallback Flat", systemImage: "rectangle", identifier: "hf.layer4.fallbackFlat")
            } else {
                debugPill(isLayer4Active ? "Layer 4 Active" : "Layer 4 Stabilizing", systemImage: "square.stack.3d.up.fill", identifier: "hf.layer4.active")
                debugPill(isLayer4Active && depthEnabled && hasLocalVideo ? "Depth Active" : "Depth Waiting", systemImage: "cube.transparent", identifier: "hf.depth.active")
                debugPill(isLayer4Active && tiltPeekEnabled && motionEnabled ? "Tilt Active" : "Tilt Waiting", systemImage: "viewfinder", identifier: "hf.tilt.active")
                debugPill(isLayer4Active && tiltPeekEnabled && motionEnabled ? "Peek Active" : "Peek Waiting", systemImage: "scope", identifier: "hf.peek.active")
            }

            Text("Source: \(sourceName)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .padding(.horizontal, 9)
                .frame(height: 22)
                .background(.black.opacity(0.42), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                .accessibilityIdentifier("hf.layer4.source")

            Text("Motion: \(motionModel.motionSourceLabel) x:\(String(format: "%.2f", motionModel.normalizedTilt.x)) y:\(String(format: "%.2f", motionModel.normalizedTilt.y))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .padding(.horizontal, 9)
                .frame(height: 22)
                .background(.black.opacity(0.42), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                .accessibilityIdentifier("hf.layer4.motionSource")
        }
        .padding(.top, 102)
        .padding(.leading, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    private func debugPill(_ title: String, systemImage: String, identifier: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 9)
            .frame(height: 24)
            .background(HFColors.goldGradient, in: Capsule())
            .shadow(color: .black.opacity(0.20), radius: 8, x: 0, y: 5)
            .accessibilityIdentifier(identifier)
    }
    #endif

    private func startFlatFirstLayer4Activation() {
        layer4ActivationTask?.cancel()
        isLayer4Active = false
        isFallbackFlat = false
        startMotionIfNeeded()

        layer4ActivationTask = Task { @MainActor in
            let stable = await waitForStablePlayback()
            guard !Task.isCancelled else { return }
            guard stable else {
                isFallbackFlat = true
                startMotionIfNeeded()
                return
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            isLayer4Active = true
            isFallbackFlat = false
            startMotionIfNeeded()
        }
    }

    @MainActor
    private func waitForStablePlayback() async -> Bool {
        guard let player else {
            try? await Task.sleep(nanoseconds: 350_000_000)
            return !hasLocalVideo
        }

        for _ in 0..<40 {
            if Task.isCancelled { return false }
            if player.currentItem?.status == .failed { return false }
            if player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0 {
                return true
            }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        return player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing || player.rate > 0
    }

    private func startMotionIfNeeded() {
        motionModel.start(
            maxTranslationX: maxTranslationX,
            maxTranslationY: maxTranslationY,
            enabled: isLayer4Active && tiltPeekEnabled && motionEnabled && !reduceMotion
        )
    }
}

private struct HighFiveVerticalVideoPlayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.clipsToBounds = true
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.videoGravity = .resizeAspectFill
        uiView.playerLayer.player = player
    }

    final class PlayerView: UIView {
        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }
    }
}

private struct HighFiveDepthActivationOverlay: View {
    let identifier: String
    var topPadding: CGFloat = 14
    private let protectedBridgeAvailable = HFDepthBridgeAvailability.isProtectedBridgeAvailable

    var body: some View {
        HStack {
            HighFiveActivationBadge(
                title: protectedBridgeAvailable ? "Depth Active" : "Depth Preview",
                systemImage: "cube.transparent"
            )
                .accessibilityIdentifier(identifier)
            Spacer(minLength: 0)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct HighFiveTiltPeekActivationOverlay: View {
    var showsBadge = true
    @StateObject private var motionModel = HighFiveTiltPeekMotionModel()
    @State private var fallbackPulse = false

    var body: some View {
        ZStack {
            if showsBadge {
                VStack(spacing: 8) {
                    Spacer()

                    HStack(spacing: 8) {
                        HighFiveActivationBadge(title: "Tilt + Peek Live", systemImage: "viewfinder")
                            .accessibilityIdentifier("hf.training.tiltPeekActive")
                    }
                    .padding(.bottom, 14)
                }
            }
        }
        .onAppear {
            motionModel.start()
        }
        .onDisappear {
            motionModel.stop()
        }
    }
}

private struct HighFiveActivationBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 12, weight: .black, design: .default))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(HFColors.goldGradient, in: Capsule())
            .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 6)
    }
}

private final class HighFiveTiltPeekMotionModel: ObservableObject {
    @Published var offset: CGSize = .zero
    @Published var normalizedTilt: CGPoint = .zero

    private let motionService = HKV1_MotionService()
    private var displayLink: CADisplayLink?
    private var filteredX: CGFloat = 0
    private var filteredY: CGFloat = 0
    private var maxTranslationX: CGFloat = 20
    private var maxTranslationY: CGFloat = 14
    private let deadZone: CGFloat = 0.014
    private let smoothing: CGFloat = 0.18
    private let tiltResponse: CGFloat = 1.25
    private var lowMotionStartTime: CFTimeInterval?
    private var demoAssistStartTime: CFTimeInterval?
    private(set) var motionSourceLabel: String = "real device"

    func start(maxTranslationX: CGFloat = 20, maxTranslationY: CGFloat = 14, enabled: Bool = true) {
        stop()
        self.maxTranslationX = max(0, maxTranslationX)
        self.maxTranslationY = max(0, maxTranslationY)
        guard enabled else {
            publish(rawX: 0, rawY: 0)
            return
        }

        #if targetEnvironment(simulator)
        motionService.simulatorTiltMode = .figureEight
        motionService.simulatorAmplitudeX = 0.72
        motionService.simulatorAmplitudeY = 0.48
        motionService.simulatorSpeed = 1.0
        #endif

        motionService.start()
        let link = CADisplayLink(target: self, selector: #selector(stepMotion))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func stepMotion() {
        let tilt = motionService.readTilt()
        let assisted = onboardingAssistedTilt(rawX: CGFloat(tilt.x), rawY: CGFloat(tilt.y))
        publish(
            rawX: CGFloat(max(-1, min(1, assisted.x * tiltResponse))),
            rawY: CGFloat(max(-1, min(1, assisted.y * tiltResponse)))
        )
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        motionService.stop()
        lowMotionStartTime = nil
        demoAssistStartTime = nil
    }

    private func onboardingAssistedTilt(rawX: CGFloat, rawY: CGFloat) -> (x: CGFloat, y: CGFloat) {
        #if targetEnvironment(simulator)
        motionSourceLabel = "simulator fallback"
        return (rawX, rawY)
        #else
        let now = CACurrentMediaTime()
        let magnitude = hypot(rawX, rawY)
        if magnitude > 0.018 {
            lowMotionStartTime = nil
            demoAssistStartTime = nil
            motionSourceLabel = "real device"
            return (rawX, rawY)
        }

        if lowMotionStartTime == nil {
            lowMotionStartTime = now
        }

        guard let start = lowMotionStartTime, now - start >= 1.0 else {
            motionSourceLabel = "real device"
            return (rawX, rawY)
        }

        if demoAssistStartTime == nil {
            demoAssistStartTime = now
        }

        let t = now - (demoAssistStartTime ?? now)
        motionSourceLabel = "demo assist"
        return (
            x: CGFloat(sin(t * 0.82) * 0.34),
            y: CGFloat(sin(t * 1.12 + .pi / 3) * 0.22)
        )
        #endif
    }

    private func publish(rawX: CGFloat, rawY: CGFloat) {
        let clampedX = max(-1, min(1, rawX))
        let clampedY = max(-1, min(1, rawY))
        filteredX += (clampedX - filteredX) * smoothing
        filteredY += (clampedY - filteredY) * smoothing

        let x = softenCenter(filteredX)
        let y = softenCenter(filteredY)
        normalizedTilt = CGPoint(x: x, y: y)
        offset = CGSize(width: x * maxTranslationX, height: y * maxTranslationY)
    }

    private func softenCenter(_ value: CGFloat) -> CGFloat {
        let magnitude = abs(value)
        guard magnitude > deadZone else { return 0 }
        let normalized = (magnitude - deadZone) / max(0.0001, 1 - deadZone)
        let eased = normalized * normalized * (3 - (2 * normalized))
        return (value < 0 ? -1 : 1) * eased
    }
}

struct HighFiveProtectedSpatialPeekBridge: View {
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    private var localVideoURL: URL? {
        HighFiveLocalVideoResolver.timelineURL ?? HighFiveLocalVideoResolver.introURL
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            HighFiveProtectedSpatialPeekControllerHost()
                .ignoresSafeArea()
                .accessibilityIdentifier("hf.protectedDepth.preview")

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Protected Depth Preview")
                            .font(.system(size: 13, weight: .black, design: .default))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .frame(height: 30)
                            .background(HFColors.goldGradient, in: Capsule())
                            .accessibilityIdentifier("hf.protectedDepth.available")

                        Text("Tilt + peek engine")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .frame(height: 28)
                            .background(.black.opacity(0.54), in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.16), lineWidth: 1))
                            .accessibilityIdentifier("hf.protectedDepth.localOnly")
                    }

                    Spacer(minLength: 16)

                    Button {
                        player?.pause()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(.black.opacity(0.58), in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close depth preview")
                    .accessibilityIdentifier("hf.protectedDepth.close")
                }
            }
            .padding(.top, 64)
            .padding(.horizontal, 16)
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            player = nil
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
        .accessibilityIdentifier("hf.protectedDepth.bridge")
    }
}

private struct HighFiveProtectedSpatialPeekLocalPreview: View {
    let player: AVPlayer?
    let hasLocalVideo: Bool

    var body: some View {
        HighFiveVerticalDepthVideoStage(
            player: player,
            cornerRadius: 0,
            fillsContainer: true,
            hasLocalVideo: hasLocalVideo,
            depthEnabled: true,
            tiltPeekEnabled: true,
            motionEnabled: true,
            maxTranslationX: 24,
            maxTranslationY: 14,
            sourceName: hasLocalVideo ? "Timeline1.mov" : "Missing protected source",
            playerIdentifier: "hf.protectedDepth.localVideoPlayer",
            fallbackIdentifier: "hf.protectedDepth.localFallback",
            fallback: {
                HighFiveTimelineFallback(progress: 0.62)
            },
            overlay: {
                HighFiveDepthActivationOverlay(identifier: "hf.protectedDepth.depthActive", topPadding: 116)
                HighFiveTiltPeekActivationOverlay()
            }
        )
    }
}

private struct HighFiveProtectedSpatialPeekControllerHost: UIViewControllerRepresentable {
    static var isProtectedControllerAvailable: Bool {
        true
    }

    func makeUIViewController(context: Context) -> UIViewController {
        HKV1_SpatialPeekViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private final class HighFiveProtectedSpatialPeekUnavailableViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14

        let title = UILabel()
        title.text = "Protected Depth Preview"
        title.font = .systemFont(ofSize: 28, weight: .black)
        title.textColor = .white
        title.textAlignment = .center
        title.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.text = "Local depth and tilt preview is active."
        subtitle.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitle.textColor = UIColor(white: 1.0, alpha: 0.72)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        let status = UILabel()
        status.text = "Local engine preview"
        status.font = .systemFont(ofSize: 13, weight: .bold)
        status.textColor = UIColor(red: 1.0, green: 0.72, blue: 0.26, alpha: 1.0)
        status.textAlignment = .center

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        stack.addArrangedSubview(status)
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

private struct HighFiveIntroFrame<Content: View>: View {
    let primaryTitle: String?
    let secondaryTitle: String?
    let primaryIdentifier: String
    let secondaryIdentifier: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.06, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()

                if let primaryTitle {
                    Button(action: onPrimary) {
                        Text(primaryTitle)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .accessibilityIdentifier(primaryIdentifier)
                    .accessibilityLabel(primaryTitle)
                }

                if let secondaryTitle, let onSecondary {
                    Button(action: onSecondary) {
                        Text(secondaryTitle)
                            .font(.system(size: 16, weight: .black, design: .default))
                            .foregroundStyle(.white.opacity(0.92))
                            .tracking(0.2)
                            .frame(width: 188, height: 50)
                            .background(.ultraThinMaterial, in: Capsule())
                            .background(Color.black.opacity(0.18), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.22),
                                                HFColors.gold.opacity(0.34),
                                                .white.opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .overlay(alignment: .top) {
                                Capsule()
                                    .fill(.white.opacity(0.16))
                                    .frame(height: 1)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 1)
                            }
                            .shadow(color: .black.opacity(0.30), radius: 18, x: 0, y: 10)
                            .shadow(color: HFColors.gold.opacity(0.10), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(secondaryIdentifier ?? "hf.intro.skip")
                    .accessibilityLabel(secondaryTitle)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
        }
    }
}

private struct HighFiveIntroPageDots: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? .white : .white.opacity(0.30))
                    .frame(width: index == currentPage ? 22 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.20), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding page \(currentPage + 1) of \(totalPages)")
    }
}

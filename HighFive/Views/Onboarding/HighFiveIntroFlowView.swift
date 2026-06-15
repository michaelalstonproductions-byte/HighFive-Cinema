import AVFoundation
import Combine
import CoreMotion
import SwiftUI
import UIKit

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
                Spacer()
                HighFiveIntroPageDots(currentPage: step.page, totalPages: HighFiveIntroStep.allCases.count)
                    .padding(.bottom, 146)
                    .accessibilityIdentifier("hf.safeArea.bottomProtected")
            }
            .allowsHitTesting(false)
        }
        .onAppear {
            step = initialStep
        }
    }

    private func advance(to nextStep: HighFiveIntroStep) {
        withAnimation(.easeInOut(duration: 0.28)) {
            step = nextStep
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
            "HighFiveTimeline1"
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

    private var localVideoURL: URL? {
        HighFiveLocalVideoResolver.introURL
    }

    var body: some View {
        HighFiveIntroFrame(
            primaryTitle: "Next",
            secondaryTitle: "Skip",
            primaryIdentifier: "hf.intro.next",
            secondaryIdentifier: "hf.intro.skip",
            onPrimary: onNext,
            onSecondary: onSkip
        ) {
            GeometryReader { proxy in
                ZStack {
                    HighFiveVerticalDepthVideoStage(
                        player: player,
                        cornerRadius: 0,
                        fillsContainer: true,
                        hasLocalVideo: localVideoURL != nil,
                        playerIdentifier: "hf.intro.videoPlayer",
                        fallbackIdentifier: "hf.intro.videoFallback",
                        fallback: {
                            HighFiveIntroFallbackCard(isAnimating: isAnimating)
                        },
                        overlay: {
                            HighFiveDepthActivationOverlay(identifier: "hf.intro.depthActive", topPadding: 54)

                            VStack(spacing: 10) {
                                Text("HigherKey")
                                    .font(.system(size: 16, weight: .black, design: .default))
                                    .foregroundStyle(HFColors.gold)
                                    .textCase(.uppercase)
                                    .accessibilityIdentifier("hf.intro.higherkey")

                                Text("HighFive Cinema")
                                    .font(.system(size: 34, weight: .black, design: .default))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.72)
                                    .accessibilityIdentifier("hf.intro.highfiveCinema")

                                Text("Streaming now.")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .foregroundStyle(.white.opacity(0.82))
                            }
                            .padding(.horizontal, 22)
                            .padding(.bottom, 300)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    )
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .ignoresSafeArea()
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("hf.intro.verticalVideo")

                    if localVideoURL == nil {
                        Text("Local intro video not found. Cinematic preview is active.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .padding(.horizontal, 34)
                            .padding(.bottom, 160)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
                .accessibilityIdentifier("hf.intro.cinematic")
            }
        }
        .onAppear {
            if let localVideoURL {
                player = AVPlayer(url: localVideoURL)
                player?.isMuted = true
                player?.play()
            }

            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
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
            primaryTitle: "Next",
            secondaryTitle: nil,
            primaryIdentifier: "hf.training.next",
            secondaryIdentifier: nil,
            onPrimary: onNext,
            onSecondary: nil
        ) {
            VStack(spacing: 20) {
                tiltPeekDiagram
                    .accessibilityIdentifier("hf.training.diagram")

                VStack(spacing: 8) {
                    HighFiveTrainingStepPill(number: "1", title: "Tilt to move", subtitle: "Shift your view")
                        .accessibilityIdentifier("hf.training.tiltToMove")
                    HighFiveTrainingStepPill(number: "2", title: "Peek to explore", subtitle: "Reveal what's around you")
                        .accessibilityIdentifier("hf.training.peekToExplore")
                }
                .padding(.horizontal, 30)
            }
            .accessibilityIdentifier("hf.training.controls")
        }
        .onAppear { isTilting = true }
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

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var progress = 0.36
    @State private var isShowingProtectedDepthPreview = false

    private var localVideoURL: URL? {
        HighFiveLocalVideoResolver.timelineURL
    }

    var body: some View {
        HighFiveIntroFrame(
            primaryTitle: "Enter HighFive",
            secondaryTitle: nil,
            primaryIdentifier: "hf.training.enterHome",
            secondaryIdentifier: nil,
            onPrimary: onEnterHome,
            onSecondary: nil
        ) {
            ZStack {
                timelinePreview
                    .ignoresSafeArea()

                VStack(spacing: 5) {
                    Text("Practice the Timeline")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("Scrub, pause, and preview before entering HighFive.")
                        .font(HFTypography.caption)
                        .foregroundStyle(.white.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .padding(.horizontal, 28)
                }
                .padding(.top, 126)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack(spacing: 12) {
                    Spacer()
                    timelineControls
                        .accessibilityIdentifier("hf.training.timelineScrubber")
                    protectedDepthPeekCTA
                }
                .padding(.bottom, 154)
            }
            .accessibilityIdentifier("hf.training.timelinePractice")
        }
        .fullScreenCover(isPresented: $isShowingProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
                .accessibilityIdentifier("hf.protectedDepth.launch")
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    @ViewBuilder
    private var timelinePreview: some View {
        if let localVideoURL {
            HighFiveVerticalDepthVideoStage(
                player: player,
                cornerRadius: 0,
                fillsContainer: true,
                hasLocalVideo: true,
                playerIdentifier: "hf.training.timelineVideo",
                fallbackIdentifier: "hf.training.timelineFallback",
                fallback: {
                    HighFiveTimelineFallback(progress: progress)
                },
                overlay: {
                    HighFiveDepthActivationOverlay(identifier: "hf.training.depthActive", topPadding: 58)
                    HighFiveTiltPeekActivationOverlay()
                }
            )
                .accessibilityIdentifier("hf.training.timelineVerticalVideo")
                .ignoresSafeArea()
                .onAppear {
                    player = AVPlayer(url: localVideoURL)
                    player?.isMuted = true
                }
        } else {
            HighFiveVerticalDepthVideoStage(
                player: nil,
                cornerRadius: 0,
                fillsContainer: true,
                hasLocalVideo: false,
                playerIdentifier: "hf.training.timelineVideo",
                fallbackIdentifier: "hf.training.timelineFallback",
                fallback: {
                    HighFiveTimelineFallback(progress: progress)
                },
                overlay: {
                    HighFiveDepthActivationOverlay(identifier: "hf.training.depthActive", topPadding: 58)
                    HighFiveTiltPeekActivationOverlay()
                }
            )
                .accessibilityIdentifier("hf.training.timelineVerticalVideo")
                .ignoresSafeArea()
        }
    }

    private var timelineControls: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button {
                    isPlaying.toggle()
                    if isPlaying {
                        player?.play()
                    } else {
                        player?.pause()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 42, height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Pause timeline practice" : "Play timeline practice")

                Slider(value: $progress, in: 0...1)
                    .tint(HFColors.gold)
                    .onChange(of: progress) { _, newValue in
                        guard let player,
                              let duration = player.currentItem?.duration.seconds,
                              duration.isFinite else { return }
                        player.seek(to: CMTime(seconds: duration * newValue, preferredTimescale: 600))
                    }
            }

            HStack {
                Text("00:18")
                Spacer()
                Text("Preview")
                Spacer()
                Text("00:50")
            }
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.textSecondary)

            if localVideoURL == nil {
                Text("Timeline1 video not found. Local practice simulation is active.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .background(.black.opacity(0.52), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(.white.opacity(0.14), lineWidth: 1))
        .padding(.horizontal, 20)
    }

    private var protectedDepthPeekCTA: some View {
        VStack(spacing: 8) {
            Button {
                player?.pause()
                isPlaying = false
                isShowingProtectedDepthPreview = true
            } label: {
                Label("Try Depth + Peek", systemImage: "cube.transparent")
                    .font(.system(size: 15, weight: .black, design: .default))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.training.tryDepthPeek")

            HStack(spacing: 8) {
                if HighFiveProtectedSpatialPeekControllerHost.isProtectedControllerAvailable {
                    Text("Depth engine ready")
                    Text("Tilt + Peek engine ready")
                } else {
                    Text("Protected engine bridge not available yet.")
                }
            }
            .font(.system(size: 10, weight: .bold, design: .default))
            .foregroundStyle(HFColors.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .accessibilityIdentifier("hf.training.protectedEngineReady")
        }
        .padding(.horizontal, 30)
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

            VStack(alignment: .leading, spacing: 6) {
                Text("Timeline Preview")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(.white)
                Text("Local practice mode")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
            }
            .padding(22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
    let playerIdentifier: String
    let fallbackIdentifier: String
    @ViewBuilder let fallback: Fallback
    @ViewBuilder let overlay: Overlay

    var body: some View {
        Group {
            if fillsContainer {
                stageContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                stageContent
                    .aspectRatio(9 / 16, contentMode: .fit)
            }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(HFColors.gold.opacity(cornerRadius == 0 ? 0.0 : 0.40), lineWidth: 1))
        .shadow(color: HFColors.gold.opacity(cornerRadius == 0 ? 0.0 : 0.16), radius: 28, x: 0, y: 20)
    }

    private var stageContent: some View {
        ZStack {
            if hasLocalVideo, let player {
                HighFiveVerticalVideoPlayer(player: player)
                    .accessibilityIdentifier(playerIdentifier)
            } else {
                fallback
                    .accessibilityIdentifier(fallbackIdentifier)
            }

            LinearGradient(
                colors: [.black.opacity(0.10), .clear, .black.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )

            overlay
        }
    }
}

private struct HighFiveVerticalVideoPlayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
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

    var body: some View {
        HStack {
            HighFiveActivationBadge(title: "Depth Active", systemImage: "cube.transparent")
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
    @StateObject private var motionModel = HighFiveTiltPeekMotionModel()
    @State private var fallbackPulse = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HFColors.gold.opacity(0.36), lineWidth: 1)
                .frame(width: 118, height: 182)
                .offset(x: motionModel.offset.width, y: motionModel.offset.height)
                .scaleEffect(fallbackPulse ? 1.04 : 0.98)
                .opacity(0.72)
                .accessibilityIdentifier("hf.training.peekActivated")

            VStack(spacing: 8) {
                Spacer()

                HStack(spacing: 8) {
                    HighFiveActivationBadge(title: "Tilt + Peek Active", systemImage: "viewfinder")
                        .accessibilityIdentifier("hf.training.tiltPeekActive")
                }
                .padding(.bottom, 14)
            }
        }
        .onAppear {
            motionModel.start()
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                fallbackPulse = true
            }
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

    private let motionManager = CMMotionManager()

    func start() {
        guard motionManager.isDeviceMotionAvailable else {
            offset = CGSize(width: 10, height: -8)
            return
        }

        motionManager.deviceMotionUpdateInterval = 1 / 30
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let roll = max(-1, min(1, motion.attitude.roll))
            let pitch = max(-1, min(1, motion.attitude.pitch))
            self.offset = CGSize(width: roll * 20, height: pitch * -14)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}

struct HighFiveProtectedSpatialPeekBridge: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            HighFiveProtectedSpatialPeekControllerHost()
                .ignoresSafeArea()
                .accessibilityIdentifier("hf.protectedDepth.preview")

            VStack(alignment: .leading, spacing: 8) {
                Text("Protected Depth Preview")
                    .font(.system(size: 13, weight: .black, design: .default))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(HFColors.goldGradient, in: Capsule())
                    .accessibilityIdentifier("hf.protectedDepth.available")

                Text("Local engine preview")
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 28)
                    .background(.black.opacity(0.54), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.16), lineWidth: 1))
                    .accessibilityIdentifier("hf.protectedDepth.localOnly")
            }
            .padding(.top, 64)
            .padding(.leading, 16)
        }
        .background(Color.black.ignoresSafeArea())
        .accessibilityIdentifier("hf.protectedDepth.bridge")
    }
}

private struct HighFiveProtectedSpatialPeekControllerHost: UIViewControllerRepresentable {
    static var isProtectedControllerAvailable: Bool {
        protectedControllerType != nil
    }

    private static var protectedControllerType: UIViewController.Type? {
        NSClassFromString("HighFive.HKV1_SpatialPeekViewController") as? UIViewController.Type
    }

    func makeUIViewController(context: Context) -> UIViewController {
        if let controllerType = Self.protectedControllerType {
            return controllerType.init()
        }

        return HighFiveProtectedSpatialPeekUnavailableViewController()
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
        subtitle.text = "Protected engine bridge not available yet."
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
    let primaryTitle: String
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

                if let secondaryTitle, let onSecondary {
                    Button(action: onSecondary) {
                        Text(secondaryTitle)
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundStyle(.white.opacity(0.82))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
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

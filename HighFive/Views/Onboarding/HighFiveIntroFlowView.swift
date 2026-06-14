import AVKit
import SwiftUI

enum HighFiveIntroStep: Int, CaseIterable {
    case intro
    case controls
    case timelinePractice

    var page: Int { rawValue }

    static var initialFromLaunchArguments: HighFiveIntroStep {
        let arguments = ProcessInfo.processInfo.arguments
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
        }
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 6)
                .accessibilityIdentifier("hf.safeArea.topProtected")
        }
        .safeAreaInset(edge: .bottom) {
            HighFiveIntroPageDots(currentPage: step.page, totalPages: HighFiveIntroStep.allCases.count)
                .padding(.bottom, 146)
                .accessibilityIdentifier("hf.safeArea.bottomProtected")
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
            VStack(spacing: 18) {
                ZStack {
                    if let localVideoURL {
                        VideoPlayer(player: player)
                            .frame(width: 306, height: 408)
                            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, Color.black.opacity(0.78)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                            )
                            .accessibilityIdentifier("hf.intro.videoPlayer")
                            .onAppear {
                                player = AVPlayer(url: localVideoURL)
                                player?.isMuted = true
                                player?.play()
                            }
                            .onDisappear {
                                player?.pause()
                                player = nil
                            }
                    } else {
                        HighFiveIntroFallbackCard(isAnimating: isAnimating)
                            .accessibilityIdentifier("hf.intro.videoFallback")
                    }

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
                    .padding(.bottom, 30)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(width: 306, height: 408)
                .accessibilityIdentifier("hf.intro.cinematic")

                if localVideoURL == nil {
                    Text("Local intro video not found. Cinematic preview is active.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .padding(.horizontal, 34)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
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
        .frame(width: 306, height: 408)
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
            VStack(spacing: 22) {
                VStack(spacing: 8) {
                    Text("Practice the Timeline")
                        .font(.system(size: 32, weight: .black, design: .default))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Scrub, pause, and preview before entering HighFive.")
                        .font(HFTypography.body)
                        .foregroundStyle(.white.opacity(0.74))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }

                timelinePreview

                timelineControls
                    .accessibilityIdentifier("hf.training.timelineScrubber")
            }
            .accessibilityIdentifier("hf.training.timelinePractice")
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    @ViewBuilder
    private var timelinePreview: some View {
        if let localVideoURL {
            VideoPlayer(player: player)
                .frame(width: 314, height: 198)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(HFColors.gold.opacity(0.36), lineWidth: 1))
                .accessibilityIdentifier("hf.training.timelineVideo")
                .onAppear {
                    player = AVPlayer(url: localVideoURL)
                    player?.isMuted = true
                }
        } else {
            HighFiveTimelineFallback(progress: progress)
                .accessibilityIdentifier("hf.training.timelineFallback")
        }
    }

    private var timelineControls: some View {
        VStack(spacing: 12) {
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
                    .onChange(of: progress) { newValue in
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
                        .frame(width: 22, height: CGFloat(42 + (index % 4) * 18))
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
        .frame(width: 314, height: 198)
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(HFColors.gold.opacity(0.36), lineWidth: 1))
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
                Spacer(minLength: 20)
                content
                Spacer(minLength: 154)
            }

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

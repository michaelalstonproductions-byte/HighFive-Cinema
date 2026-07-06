import Foundation
import CoreGraphics

struct HKV1_Layer4VideoPracticeRuntimeState: Equatable {
    enum Phase: String, Equatable {
        case intro
        case tiltPractice
        case controlPanelPractice
        case home
        case unknown
    }

    var phase: Phase
    var videoURLResolved: Bool
    var hasVideoSurface: Bool
    var videoSurfaceVisible: Bool
    var playerActive: Bool
    var activeAVPlayerCount: Int
    var activeDisplayLinkCount: Int
    var hasStillImageAsPrimarySurface: Bool
    var hasGrayInstructionBox: Bool
    var controlPanelVisible: Bool
    var controlPanelBlocksVideo: Bool
    var separateInstructionAfterPractice: Bool
    var reduceMotion: Bool
    var userPressedNext: Bool
    var demoOffsetX: CGFloat
    var demoOffsetY: CGFloat
    var maxTranslationX: CGFloat
    var maxTranslationY: CGFloat
}

struct HKV1_Layer4VideoPracticeRuntimeDecision: Equatable {
    var allowVideo: Bool
    var allowMotion: Bool
    var allowControlPanelOverlay: Bool
    var blockSeparateInstruction: Bool
    var shouldStopOnNext: Bool
    var maxTranslationX: CGFloat
    var maxTranslationY: CGFloat
    var missingVideoRisk: CGFloat
    var blankVideoRisk: CGFloat
    var stillImageRisk: CGFloat
    var grayBoxRisk: CGFloat
    var duplicatePlayerRisk: CGFloat
    var duplicateDisplayLinkRisk: CGFloat
    var panelObstructionRisk: CGFloat
    var extraInstructionRisk: CGFloat
    var overtravelRisk: CGFloat
    var reason: String

    static let fallback = HKV1_Layer4VideoPracticeRuntimeDecision(
        allowVideo: false,
        allowMotion: false,
        allowControlPanelOverlay: false,
        blockSeparateInstruction: true,
        shouldStopOnNext: true,
        maxTranslationX: 0,
        maxTranslationY: 0,
        missingVideoRisk: 1,
        blankVideoRisk: 1,
        stillImageRisk: 0,
        grayBoxRisk: 0,
        duplicatePlayerRisk: 0,
        duplicateDisplayLinkRisk: 0,
        panelObstructionRisk: 0,
        extraInstructionRisk: 0,
        overtravelRisk: 0,
        reason: "fallback"
    )

    var clamped: HKV1_Layer4VideoPracticeRuntimeDecision {
        HKV1_Layer4VideoPracticeRuntimeDecision(
            allowVideo: allowVideo,
            allowMotion: allowMotion,
            allowControlPanelOverlay: allowControlPanelOverlay,
            blockSeparateInstruction: blockSeparateInstruction,
            shouldStopOnNext: shouldStopOnNext,
            maxTranslationX: HKV1_Layer4Math.clamp(maxTranslationX, 0, 32),
            maxTranslationY: HKV1_Layer4Math.clamp(maxTranslationY, 0, 18),
            missingVideoRisk: HKV1_Layer4Math.clamp01(missingVideoRisk),
            blankVideoRisk: HKV1_Layer4Math.clamp01(blankVideoRisk),
            stillImageRisk: HKV1_Layer4Math.clamp01(stillImageRisk),
            grayBoxRisk: HKV1_Layer4Math.clamp01(grayBoxRisk),
            duplicatePlayerRisk: HKV1_Layer4Math.clamp01(duplicatePlayerRisk),
            duplicateDisplayLinkRisk: HKV1_Layer4Math.clamp01(duplicateDisplayLinkRisk),
            panelObstructionRisk: HKV1_Layer4Math.clamp01(panelObstructionRisk),
            extraInstructionRisk: HKV1_Layer4Math.clamp01(extraInstructionRisk),
            overtravelRisk: HKV1_Layer4Math.clamp01(overtravelRisk),
            reason: reason
        )
    }
}

final class HKV1_Layer4VideoPracticeRuntimeGuard {
    func decide(_ state: HKV1_Layer4VideoPracticeRuntimeState) -> HKV1_Layer4VideoPracticeRuntimeDecision {
        let missingVideoRisk: CGFloat = state.videoURLResolved ? 0 : 1
        let blankVideoRisk: CGFloat = state.hasVideoSurface && state.videoSurfaceVisible ? 0 : 1
        let stillImageRisk: CGFloat = state.hasStillImageAsPrimarySurface ? 1 : 0
        let grayBoxRisk: CGFloat = state.hasGrayInstructionBox ? 1 : 0
        let duplicatePlayerRisk: CGFloat = state.activeAVPlayerCount > 1 ? 1 : 0
        let duplicateDisplayLinkRisk: CGFloat = state.activeDisplayLinkCount > 1 ? 1 : 0
        let panelRisk: CGFloat = state.controlPanelVisible && state.controlPanelBlocksVideo ? 1 : 0
        let extraInstructionRisk: CGFloat = state.separateInstructionAfterPractice ? 1 : 0
        let overtravelX = abs(state.demoOffsetX) > max(state.maxTranslationX, 0.001)
        let overtravelY = abs(state.demoOffsetY) > max(state.maxTranslationY, 0.001)
        let overtravelRisk: CGFloat = overtravelX || overtravelY ? 1 : 0

        if state.userPressedNext {
            return HKV1_Layer4VideoPracticeRuntimeDecision(
                allowVideo: false,
                allowMotion: false,
                allowControlPanelOverlay: false,
                blockSeparateInstruction: true,
                shouldStopOnNext: true,
                maxTranslationX: 0,
                maxTranslationY: 0,
                missingVideoRisk: missingVideoRisk,
                blankVideoRisk: blankVideoRisk,
                stillImageRisk: stillImageRisk,
                grayBoxRisk: grayBoxRisk,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                panelObstructionRisk: panelRisk,
                extraInstructionRisk: extraInstructionRisk,
                overtravelRisk: overtravelRisk,
                reason: "next stops practice"
            ).clamped
        }

        let videoOk =
            missingVideoRisk < 0.5 &&
            blankVideoRisk < 0.5 &&
            stillImageRisk < 0.5 &&
            grayBoxRisk < 0.5 &&
            duplicatePlayerRisk < 0.5

        let motionOk =
            videoOk &&
            !state.reduceMotion &&
            duplicateDisplayLinkRisk < 0.5

        return HKV1_Layer4VideoPracticeRuntimeDecision(
            allowVideo: videoOk,
            allowMotion: motionOk,
            allowControlPanelOverlay: videoOk && panelRisk < 0.5,
            blockSeparateInstruction: true,
            shouldStopOnNext: true,
            maxTranslationX: motionOk ? min(max(state.maxTranslationX, 24), 32) : 0,
            maxTranslationY: motionOk ? min(max(state.maxTranslationY, 14), 18) : 0,
            missingVideoRisk: missingVideoRisk,
            blankVideoRisk: blankVideoRisk,
            stillImageRisk: stillImageRisk,
            grayBoxRisk: grayBoxRisk,
            duplicatePlayerRisk: duplicatePlayerRisk,
            duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
            panelObstructionRisk: panelRisk,
            extraInstructionRisk: extraInstructionRisk,
            overtravelRisk: overtravelRisk,
            reason: videoOk ? "video practice runtime safe" : "practice video setup required"
        ).clamped
    }
}

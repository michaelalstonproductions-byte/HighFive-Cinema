import Foundation
import CoreGraphics

struct HKV1_Layer4LaunchPracticeState: Equatable {
    enum Phase: String, Equatable {
        case coldLaunch
        case intro
        case tiltPeekPractice
        case home
        case hamburgerMenu
        case fullPlayer
        case returningFromPreview
        case unknown
    }

    var phase: Phase
    var introPlayerActive: Bool
    var practiceMotionActive: Bool
    var homeHeroPlayerActive: Bool
    var discoveryHeroPlayerActive: Bool
    var fullPlayerActive: Bool
    var hamburgerTapped: Bool
    var userRequestedReplayIntro: Bool
    var hasCompletedIntroThisSession: Bool
    var hasCompletedPracticeThisSession: Bool
    var activeAVPlayerCount: Int
    var activeDisplayLinkCount: Int
    var reduceMotion: Bool
}

struct HKV1_Layer4LaunchPracticeDecision: Equatable {
    var allowIntroPlayback: Bool
    var allowPracticeMotion: Bool
    var allowHomeHeroPlayback: Bool
    var allowFullPlayerPlayback: Bool
    var hamburgerMayOpenIntro: Bool
    var mustStopIntroBeforePractice: Bool
    var mustStopPracticeBeforeHome: Bool
    var mustStopHomeHeroBeforeFullPlayer: Bool
    var duplicatePlayerRisk: CGFloat
    var duplicateDisplayLinkRisk: CGFloat
    var introRestartRisk: CGFloat
    var practiceMotionRisk: CGFloat
    var reason: String

    static let neutral = HKV1_Layer4LaunchPracticeDecision(
        allowIntroPlayback: false,
        allowPracticeMotion: false,
        allowHomeHeroPlayback: false,
        allowFullPlayerPlayback: false,
        hamburgerMayOpenIntro: false,
        mustStopIntroBeforePractice: true,
        mustStopPracticeBeforeHome: true,
        mustStopHomeHeroBeforeFullPlayer: true,
        duplicatePlayerRisk: 0,
        duplicateDisplayLinkRisk: 0,
        introRestartRisk: 0,
        practiceMotionRisk: 0,
        reason: "neutral"
    )

    var clamped: HKV1_Layer4LaunchPracticeDecision {
        HKV1_Layer4LaunchPracticeDecision(
            allowIntroPlayback: allowIntroPlayback,
            allowPracticeMotion: allowPracticeMotion,
            allowHomeHeroPlayback: allowHomeHeroPlayback,
            allowFullPlayerPlayback: allowFullPlayerPlayback,
            hamburgerMayOpenIntro: hamburgerMayOpenIntro,
            mustStopIntroBeforePractice: mustStopIntroBeforePractice,
            mustStopPracticeBeforeHome: mustStopPracticeBeforeHome,
            mustStopHomeHeroBeforeFullPlayer: mustStopHomeHeroBeforeFullPlayer,
            duplicatePlayerRisk: HKV1_Layer4Math.clamp01(duplicatePlayerRisk),
            duplicateDisplayLinkRisk: HKV1_Layer4Math.clamp01(duplicateDisplayLinkRisk),
            introRestartRisk: HKV1_Layer4Math.clamp01(introRestartRisk),
            practiceMotionRisk: HKV1_Layer4Math.clamp01(practiceMotionRisk),
            reason: reason
        )
    }
}

final class HKV1_Layer4LaunchPracticeRuntimeGuard {
    func decide(_ state: HKV1_Layer4LaunchPracticeState) -> HKV1_Layer4LaunchPracticeDecision {
        let duplicatePlayerRisk: CGFloat = state.activeAVPlayerCount > 1 ? 1.0 : 0.0
        let duplicateDisplayLinkRisk: CGFloat = state.activeDisplayLinkCount > 1 ? 1.0 : 0.0

        if state.hamburgerTapped && !state.userRequestedReplayIntro {
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: false,
                allowPracticeMotion: state.phase == .tiltPeekPractice && !state.reduceMotion,
                allowHomeHeroPlayback: state.phase == .home,
                allowFullPlayerPlayback: state.phase == .fullPlayer,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 1.0,
                practiceMotionRisk: 0,
                reason: "hamburger must not restart intro"
            ).clamped
        }

        switch state.phase {
        case .coldLaunch:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: true,
                allowPracticeMotion: false,
                allowHomeHeroPlayback: false,
                allowFullPlayerPlayback: false,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: 0,
                reason: "cold launch intro"
            ).clamped

        case .intro:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: true,
                allowPracticeMotion: false,
                allowHomeHeroPlayback: false,
                allowFullPlayerPlayback: false,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: 0,
                reason: "intro active"
            ).clamped

        case .tiltPeekPractice:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: false,
                allowPracticeMotion: !state.reduceMotion,
                allowHomeHeroPlayback: false,
                allowFullPlayerPlayback: false,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: state.reduceMotion ? 0.0 : duplicateDisplayLinkRisk,
                reason: state.reduceMotion ? "practice static reduce motion" : "practice motion allowed"
            ).clamped

        case .home:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: false,
                allowPracticeMotion: false,
                allowHomeHeroPlayback: true,
                allowFullPlayerPlayback: false,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: 0,
                reason: "home active"
            ).clamped

        case .fullPlayer:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: false,
                allowPracticeMotion: false,
                allowHomeHeroPlayback: false,
                allowFullPlayerPlayback: true,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: 0,
                reason: "full player active"
            ).clamped

        case .returningFromPreview:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: false,
                allowPracticeMotion: false,
                allowHomeHeroPlayback: true,
                allowFullPlayerPlayback: false,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: 0,
                reason: "returning to home"
            ).clamped

        case .hamburgerMenu, .unknown:
            return HKV1_Layer4LaunchPracticeDecision(
                allowIntroPlayback: false,
                allowPracticeMotion: false,
                allowHomeHeroPlayback: false,
                allowFullPlayerPlayback: false,
                hamburgerMayOpenIntro: false,
                mustStopIntroBeforePractice: true,
                mustStopPracticeBeforeHome: true,
                mustStopHomeHeroBeforeFullPlayer: true,
                duplicatePlayerRisk: duplicatePlayerRisk,
                duplicateDisplayLinkRisk: duplicateDisplayLinkRisk,
                introRestartRisk: 0,
                practiceMotionRisk: 0,
                reason: "navigation state"
            ).clamped
        }
    }
}

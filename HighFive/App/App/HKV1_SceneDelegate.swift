import SwiftUI
import UIKit

final class HKV1_SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let layer4LaunchRuntimeGuard = HKV1_Layer4LaunchRuntimeGuard()
    private let layer4LaunchPosterRuntimeQA = HKV1_Layer4LaunchPosterRuntimeQA()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        noteLaunchRuntime(phase: .coldLaunch, title: "Cold Launch", activeAVPlayerCount: 0)
        let intro = HKCHighFiveLaunchIntroViewController()
        intro.onFinish = { [weak self, weak intro] in
            self?.showTiltPeekPractice(in: window, introVideoURL: intro?.introVideoURL)
            self?.window = window
        }
        window.rootViewController = intro
        window.makeKeyAndVisible()
        self.window = window
    }

    private func showTiltPeekPractice(in window: UIWindow, introVideoURL: URL?) {
        noteLaunchRuntime(phase: .instructions, title: "Tilt + Peek Practice", activeAVPlayerCount: 0)
        let practice = HKV1_SpatialPeekViewController()
        practice.configureForSpatialPractice(videoURL: introVideoURL) { [weak self, weak window] in
            guard let window else { return }
            self?.showControlBarTutorial(in: window, introVideoURL: introVideoURL)
        }
        UIView.transition(with: window, duration: 0.28, options: [.transitionCrossDissolve]) {
            window.rootViewController = practice
        }
    }

    private func showControlBarTutorial(in window: UIWindow, introVideoURL: URL?) {
        noteLaunchRuntime(phase: .instructions, title: "Control Bar Tutorial", activeAVPlayerCount: 0)
        let tutorial = HKCControlBarTutorialViewController(videoURL: introVideoURL)
        tutorial.onBack = { [weak self, weak window] in
            guard let window else { return }
            self?.showTiltPeekPractice(in: window, introVideoURL: introVideoURL)
        }
        tutorial.onFinish = { [weak self, weak window] in
            guard let window else { return }
            self?.showHome(in: window)
        }
        UIView.transition(with: window, duration: 0.28, options: [.transitionCrossDissolve]) {
            window.rootViewController = tutorial
        }
    }

    private func showHome(in window: UIWindow) {
        noteLaunchRuntime(phase: .home, title: "Home", activeAVPlayerCount: 0)
        let home = UIHostingController(rootView: HFStreamingRootView())
        UIView.transition(with: window, duration: 0.28, options: [.transitionCrossDissolve]) {
            window.rootViewController = home
        }
        self.window = window
    }

    private func noteLaunchRuntime(
        phase: HKV1_Layer4LaunchRuntimeState.Phase,
        title: String,
        activeAVPlayerCount: Int
    ) {
        let decision = layer4LaunchRuntimeGuard.decide(
            HKV1_Layer4LaunchRuntimeState(
                phase: phase,
                introPlayerActive: phase == .intro || phase == .coldLaunch,
                homeHeroPlayerActive: false,
                discoveryHeroPlayerActive: false,
                hamburgerTapped: false,
                userRequestedReplayIntro: false,
                hasCompletedIntroThisSession: phase != .coldLaunch && phase != .intro,
                hasCompletedInstructionsThisSession: phase == .home,
                activeAVPlayerCount: activeAVPlayerCount
            )
        )
        layer4LaunchPosterRuntimeQA.noteLaunch(
            surface: phase.rawValue,
            title: title,
            decision: decision
        )
    }
}

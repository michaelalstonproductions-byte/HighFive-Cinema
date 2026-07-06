import SwiftUI
import UIKit

final class HKV1_SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        #if DEBUG
        HFSimulatorQABootstrap.prepareIfNeeded()
        #endif

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .black

        let rootView = HFLaunchReadyGate {
            HFStreamingRootView()
        }
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .black
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        self.window = window
    }
}

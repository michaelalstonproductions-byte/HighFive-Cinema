import UserNotifications
import UIKit

@main
final class HKV1_AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        if ProcessInfo.processInfo.arguments.contains("--hf-notification-register-apns") {
            requestRemoteNotificationRegistration(application)
        }
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = HKV1_SceneDelegate.self
        return config
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let suffix = String(deviceToken.map { String(format: "%02x", $0) }.joined().suffix(16))
        UserDefaults.standard.set(suffix, forKey: "hf.notification.apnsTokenSuffix")
        UserDefaults.standard.set("registered", forKey: "hf.notification.apnsRegistrationState")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UserDefaults.standard.set("failed: \(error.localizedDescription)", forKey: "hf.notification.apnsRegistrationState")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    private func requestRemoteNotificationRegistration(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            UserDefaults.standard.set(granted ? "authorized" : "denied", forKey: "hf.notification.permissionState")
            if let error {
                UserDefaults.standard.set(error.localizedDescription, forKey: "hf.notification.permissionError")
            }
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

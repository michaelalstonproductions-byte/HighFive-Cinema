import Foundation

protocol HFBackendService {
    func currentStatus() -> HFBackendRuntimeStatus
    func currentStatus(for state: HFBackendConnectionState) -> HFBackendRuntimeStatus
    func accountStatus() -> HFBackendServiceStatus
    func libraryStatus() -> HFBackendServiceStatus
    func downloadsStatus() -> HFBackendServiceStatus
    func paymentStatus() -> HFBackendServiceStatus
    func creatorStudioStatus() -> HFBackendServiceStatus
    func socialKitStatus() -> HFBackendServiceStatus
    func vodPackageStatus() -> HFBackendServiceStatus
}

enum HFBackendServiceFactory {
    static func make(configuration: HFBackendConfiguration = HFBackendConfiguration()) -> HFBackendService {
        switch configuration.mode {
        case .local:
            return HFLocalBackendAdapter(configuration: configuration)
        case .configured, .unavailable:
            return HFConfiguredBackendAdapter(configuration: configuration)
        }
    }
}

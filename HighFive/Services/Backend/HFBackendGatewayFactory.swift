import Foundation

enum HFBackendGatewayFactory {
    static func make(configuration: HFBackendConfiguration = HFBackendConfiguration()) -> HFBackendGateway {
        configuration.hasCompleteRuntimeConfig ? HFRemoteBackendGateway(configuration: configuration) : HFLocalBackendGateway()
    }
}

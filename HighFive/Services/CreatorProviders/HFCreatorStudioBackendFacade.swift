import Foundation

struct HFCreatorStudioBackendFacade {
    private let gateway: HFBackendGateway

    init(gateway: HFBackendGateway) {
        self.gateway = gateway
    }

    func loadControlCenter(userID: String) async -> HFCreatorControlCenterState {
        do {
            let projects = try await gateway.fetchCreatorProjects(userID: userID)
            let project = projects.first
            let social: HFSocialKitDTO?
            let vod: HFVODPackageDTO?

            if let project {
                social = try await gateway.fetchSocialKit(projectID: project.id)
                vod = try await gateway.fetchVODPackage(projectID: project.id)
            } else {
                social = nil
                vod = nil
            }

            return HFCreatorControlCenterState(project: project, socialKit: social, vodPackage: vod, isBackendConnected: true)
        } catch {
            return HFCreatorControlCenterState(project: nil, socialKit: nil, vodPackage: nil, isBackendConnected: false)
        }
    }
}

struct HFCreatorControlCenterState: Equatable {
    let project: HFCreatorProjectDTO?
    let socialKit: HFSocialKitDTO?
    let vodPackage: HFVODPackageDTO?
    let isBackendConnected: Bool
}

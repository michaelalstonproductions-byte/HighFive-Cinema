import Foundation

#if DEBUG
enum HFSimulatorQABootstrap {
    static var isSimulatorQAActive: Bool {
        #if targetEnvironment(simulator)
        ProcessInfo.processInfo.environment["HF_SIMULATOR_QA"] == "1"
        #else
        false
        #endif
    }

    static var shouldFastEnter: Bool {
        #if targetEnvironment(simulator)
        ProcessInfo.processInfo.environment["HF_SIMULATOR_FAST_ENTRY"] == "1"
        #else
        false
        #endif
    }

    static var shouldUseMotionPreview: Bool {
        #if targetEnvironment(simulator)
        ProcessInfo.processInfo.environment["HF_SIMULATOR_MOTION_PREVIEW"] == "1"
        #else
        false
        #endif
    }

    static func prepareIfNeeded() {
        guard isSimulatorQAActive else { return }

        print("[SimulatorQA] active fastEntry=\(shouldFastEnter) motionPreview=\(shouldUseMotionPreview)")

        if shouldFastEnter {
            HFLegalDocuments.recordCurrentAcceptance()
            UserDefaults.standard.set(true, forKey: "hf.hasCompletedCinematicOnboarding")
            UserDefaults.standard.set(true, forKey: "hf.hasSeenControlPanelWalkthrough")
        }
    }
}
#endif

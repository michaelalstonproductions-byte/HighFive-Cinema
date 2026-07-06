import SwiftUI

struct HFLaunchReadyGate<Content: View>: View {
    private let minimumDisplayDuration: TimeInterval
    private let content: () -> Content

    @State private var isReady = false

    init(
        minimumDisplayDuration: TimeInterval = 0.65,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minimumDisplayDuration = minimumDisplayDuration
        self.content = content
    }

    var body: some View {
        ZStack {
            if isReady {
                content()
                    .transition(.opacity.animation(.easeOut(duration: 0.24)))
            } else {
                HFLaunchBridgeView()
                    .transition(.opacity)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            await prepareFirstFrame()
        }
        .accessibilityIdentifier("hf.launch.readyGate")
    }

    private func prepareFirstFrame() async {
        #if DEBUG
        print("[Launch] showing bridge")
        #endif

        let nanoseconds = UInt64(max(0, minimumDisplayDuration) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)

        await MainActor.run {
            withAnimation(.easeOut(duration: 0.22)) {
                isReady = true
            }
            #if DEBUG
            print("[Launch] root content ready")
            #endif
        }
    }
}

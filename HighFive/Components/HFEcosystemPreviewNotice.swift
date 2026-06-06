import SwiftUI

struct HFEcosystemPreviewNotice: View {
    var body: some View {
        HFInsightCard(
            title: "Local preview mode",
            message: "Local SwiftUI preview only. No backend, accounts, payments, uploads, capture, or protected systems are connected.",
            systemImage: "lock.shield.fill"
        )
    }
}

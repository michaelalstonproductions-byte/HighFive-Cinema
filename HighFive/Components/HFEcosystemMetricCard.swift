import SwiftUI

struct HFEcosystemMetricCard: View {
    let metric: HFEcosystemMetric

    var body: some View {
        HFMetricCard(
            title: metric.title,
            value: metric.value,
            caption: metric.caption,
            systemImage: metric.systemImage
        )
    }
}

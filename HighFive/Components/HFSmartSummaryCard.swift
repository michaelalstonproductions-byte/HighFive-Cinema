import SwiftUI

struct HFSmartSummaryCard: View {
    let signals: [HFPersonalSignal]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("Smart Summary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Local preview signals across watching, creating, launching, and connecting.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            LazyVGrid(columns: columns, spacing: HFSpacing.md) {
                ForEach(signals) { signal in
                    HFPersonalSignalCard(signal: signal)
                }
            }
        }
    }
}

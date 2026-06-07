import SwiftUI

struct LockedSystemsMapView: View {
    private let categories = [
        "Account + Backend",
        "Commerce",
        "Media / Capture",
        "Export / Share",
        "Design / Asset"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                ForEach(categories, id: \.self) { category in
                    lockSection(title: title(for: category), category: category)
                }
                lockRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Locked Systems")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Locked until scoped", isProminent: true)

            Text("Locked Systems Map")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Everything real stays locked until separately scoped.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func lockSection(title: String, category: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineCompletionData.locks(for: category)) { item in
                    HFLockedSystemCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func title(for category: String) -> String {
        switch category {
        case "Account + Backend":
            return "Account + Backend Locks"
        case "Commerce":
            return "Commerce Locks"
        case "Media / Capture":
            return "Media / Capture Locks"
        case "Export / Share":
            return "Export / Share Locks"
        default:
            return "Design / Asset Locks"
        }
    }

    private var lockRule: some View {
        HFInsightCard(
            title: "Lock Rule",
            message: "Anything listed here requires its own scoped phase, build, commit, tag, QA, and QA tag before becoming real.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

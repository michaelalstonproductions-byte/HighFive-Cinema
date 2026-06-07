import SwiftUI

struct DemoSafetySummaryView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                activeLocalSection
                lockedSystemsSection
                permissionSection
                assetSafetySection
                safetyRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Demo Safety")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "No real services", isProminent: true)

            Text("Demo Safety Summary")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Confirm what remains local, locked, and protected during the final walkthrough.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var activeLocalSection: some View {
        HFDemoChecklistCard(
            title: "Active Local Preview",
            items: [
                "SwiftUI screens",
                "Local mock data",
                "Local navigation",
                "Local state buttons",
                "Static recommendations",
                "Static export queue",
                "Static safety roadmap"
            ],
            systemImage: "checkmark.circle.fill",
            status: "Active"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var lockedSystemsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Locked Real Systems", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFFinalDemoTourData.safetyLocks) { lock in
                    HFDemoSafetyLockCard(lock: lock)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var permissionSection: some View {
        HFDemoChecklistCard(
            title: "Permission State",
            items: [
                "Camera: Not requested",
                "Photos: Not requested",
                "Microphone: Not requested",
                "Notifications: Not requested",
                "File access: Not requested",
                "Social accounts: Not connected"
            ],
            systemImage: "hand.raised.fill",
            status: "Locked"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var assetSafetySection: some View {
        HFDemoChecklistCard(
            title: "Asset/Figma Safety",
            items: [
                "No asset catalog changes",
                "No poster mapping changes",
                "No Figma sync",
                "No StoreKit files",
                "No Info.plist permission changes"
            ],
            systemImage: "shield.lefthalf.filled",
            status: "Untouched"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var safetyRule: some View {
        HFInsightCard(
            title: "Safety Rule",
            message: "This tour explains the product without activating real services or protected systems.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

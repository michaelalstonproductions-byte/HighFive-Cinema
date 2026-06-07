import SwiftUI

struct ProductSpineLockdownView: View {
    private let pillars = [
        ("Watch", ["Home", "Search", "Movie Detail", "My List", "Downloads"], "play.rectangle.fill"),
        ("Create", ["Creator Mode", "Command Center", "Package Builder", "Release Readiness", "Launch Center"], "shippingbox.fill"),
        ("Connect", ["Connect Hub", "Social Rooms", "Creator Circles", "Social Graph", "Activity Feed"], "person.2.fill"),
        ("Launch", ["Launch Center", "Access Preview", "Release Presentation", "Demo Checklist"], "flag.checkered"),
        ("Export", ["Social Export Hub", "Queue", "Demo Flow", "Safety Center", "Protected Capture Roadmap"], "square.and.arrow.up")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                spineMapSection
                pillarRoutesSection
                productCopySection
                noRealSystemsSection
                finalQAEntrySection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Spine Lockdown")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Product spine", isProminent: true)

            Text("Product Spine Lockdown")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Verify Watch, Create, Connect, Launch, and Export are discoverable and clearly separated.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var spineMapSection: some View {
        HFInsightCard(
            title: "Spine Map",
            message: "Watch -> Create -> Connect -> Launch -> Export",
            systemImage: "map.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var pillarRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Pillar Routes", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(pillars, id: \.0) { pillar in
                    HFDemoChecklistCard(title: pillar.0, items: pillar.1, systemImage: pillar.2, status: pillar.0 == "Export" ? "Future" : "Local")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var productCopySection: some View {
        HFDemoChecklistCard(
            title: "Product Copy Check",
            items: [
                "Home explains HighFive",
                "Profile acts as hub",
                "Command Center maps the ecosystem",
                "Movie Detail remains readable",
                "Export is clearly local/preview only",
                "Safety pages explain locked systems"
            ],
            systemImage: "text.alignleft",
            status: "Review"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var noRealSystemsSection: some View {
        HFDemoChecklistCard(
            title: "No Real Systems Check",
            items: [
                "No backend",
                "No auth",
                "No payments",
                "No upload",
                "No capture",
                "No share sheet",
                "No Photos",
                "No ReplayKit",
                "No AVPlayer implementation",
                "No protected media integration"
            ],
            systemImage: "lock.shield.fill",
            status: "Locked"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var finalQAEntrySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Final QA Entry", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    FinalDemoTourView()
                } label: {
                    HFActionTile(title: "Final Demo Tour", subtitle: "Walk the complete Watch -> Create -> Connect -> Launch -> Export path.", systemImage: "map.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoReviewChecklistView()
                } label: {
                    HFActionTile(title: "Demo Review Checklist", subtitle: "Review final walkthrough checkpoints.", systemImage: "checklist.checked")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    ReleaseCandidatePrepView()
                } label: {
                    HFActionTile(title: "Release Candidate Prep", subtitle: "Lock the product spine before final QA.", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}

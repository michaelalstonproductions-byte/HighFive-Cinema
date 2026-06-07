import SwiftUI

struct DemoAudiencePathView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                audiencePathsSection
                pathSection(title: "Viewer Demo Path", items: HFFinalDemoTourData.viewerPath, systemImage: "play.rectangle.fill")
                pathSection(title: "Creator Demo Path", items: HFFinalDemoTourData.creatorPath, systemImage: "shippingbox.fill")
                pathSection(title: "Community Demo Path", items: HFFinalDemoTourData.communityPath, systemImage: "person.2.fill")
                pathSection(title: "Launch Demo Path", items: HFFinalDemoTourData.launchPath, systemImage: "flag.checkered")
                pathSection(title: "Export Demo Path", items: HFFinalDemoTourData.exportPath, systemImage: "square.and.arrow.up", status: "Future")
                pathSection(title: "Full Product Demo", items: HFFinalDemoTourData.fullProductPath, systemImage: "map.fill")
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Demo Paths")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Static paths", isProminent: true)

            Text("Demo Paths")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Choose the right walkthrough for viewers, creators, communities, launch, or export.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var audiencePathsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Audience Paths", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(HFFinalDemoTourData.audiencePaths) { path in
                        HFDemoAudiencePathCard(path: path)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private func pathSection(title: String, items: [String], systemImage: String, status: String = "Local") -> some View {
        HFDemoChecklistCard(title: title, items: items, systemImage: systemImage, status: status)
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

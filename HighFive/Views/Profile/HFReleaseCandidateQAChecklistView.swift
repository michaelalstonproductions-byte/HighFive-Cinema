import SwiftUI

struct HFReleaseCandidateQAChecklistView: View {
    @State private var completedIDs: Set<String> = []

    private let sections = HFReleaseCandidateQASection.all

    private var totalCount: Int {
        sections.reduce(0) { $0 + $1.items.count }
    }

    private var completedCount: Int {
        completedIDs.count
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                progressPanel

                ForEach(sections) { section in
                    checklistSection(section)
                }

                releaseLockPanel
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("RC 4.1 QA")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.profile.internal.rc41Checklist.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Internal QA", isProminent: true)

            Text("HighFive Cinema 4.1")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("Release Candidate checklist for real-device and TestFlight validation. This screen records local session checks only.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var progressPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Label("QA Progress", systemImage: "checkmark.seal.fill")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)

                    Spacer()

                    Text("\(completedCount)/\(totalCount)")
                        .font(HFTypography.caption.weight(.black))
                        .foregroundStyle(HFColors.gold)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.10))
                        Capsule()
                            .fill(HFColors.goldGradient)
                            .frame(width: proxy.size.width * progressFraction)
                    }
                }
                .frame(height: 10)

                Text("Use this as a manual release pass. It does not touch StoreKit, streaming, playback, Vertical Stage, Layer 4, Depth/Tilt/Peek, backend, rendering, publishing, or intelligence engines.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var progressFraction: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(completedCount) / CGFloat(totalCount)
    }

    private func checklistSection(_ section: HFReleaseCandidateQASection) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: section.title, actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Label(section.subtitle, systemImage: section.systemImage)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(section.items) { item in
                        checklistRow(item)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func checklistRow(_ item: HFReleaseCandidateQAItem) -> some View {
        let isComplete = completedIDs.contains(item.id)

        return Button {
            if isComplete {
                completedIDs.remove(item.id)
            } else {
                completedIDs.insert(item.id)
            }
        } label: {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isComplete ? HFColors.gold : HFColors.textMuted)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(item.title)
                        .font(HFTypography.body.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)

                Text(item.status)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(isComplete ? .black : HFColors.gold)
                    .padding(.horizontal, HFSpacing.xs)
                    .frame(height: 28)
                    .background(isComplete ? HFColors.gold : Color.white.opacity(0.08), in: Capsule())
            }
            .padding(HFSpacing.sm)
            .background(Color.white.opacity(isComplete ? 0.095 : 0.055), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isComplete ? HFColors.gold.opacity(0.34) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("hf.profile.internal.rc41Checklist.\(item.id)")
    }

    private var releaseLockPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Label("Release Candidate Lock", systemImage: "lock.shield.fill")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)

                Text("No new product layer is enabled by this checklist. Consumer tabs remain Home, Search, Library, Downloads, and Profile.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct HFReleaseCandidateQASection: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let items: [HFReleaseCandidateQAItem]

    static let all: [HFReleaseCandidateQASection] = [
        HFReleaseCandidateQASection(
            id: "consumer",
            title: "Consumer Streaming",
            subtitle: "Core viewer routes",
            systemImage: "play.rectangle.fill",
            items: [
                HFReleaseCandidateQAItem(id: "onboarding", title: "Onboarding", detail: "First launch, returning launch, and post-onboarding entry land cleanly in the streaming shell.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "home", title: "Home", detail: "Hero, rails, continue watching, and tab entry feel stable on device.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "movieDetail", title: "Movie Detail", detail: "Official titles show metadata, actions, purchase state, and trailer affordances without route confusion.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "search", title: "Search", detail: "Search field, suggestions, filters, results, and empty states are legible and responsive.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "library", title: "Library", detail: "Saved titles, continue watching, history, favorites, and empty state remain local and readable.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "downloads", title: "Downloads", detail: "Offline preview state, storage messaging, and unavailable states do not imply live server sync.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "profile", title: "Profile", detail: "Profile switcher, account rows, app settings, support, and internal tools stay contained in Profile.", status: "Manual")
            ]
        ),
        HFReleaseCandidateQASection(
            id: "commerce",
            title: "Purchases",
            subtitle: "StoreKit surface checks only",
            systemImage: "creditcard.and.123",
            items: [
                HFReleaseCandidateQAItem(id: "purchases", title: "Purchases", detail: "Purchase copy and disabled/staged states are clear without activating unscoped payment logic.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "restorePurchases", title: "Restore Purchases", detail: "Restore Purchases is visible where expected and communicates the current runtime state.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "friendlyUnlock", title: "The Friendly unlock", detail: "The Friendly access state maps to the intended unlock copy and never bypasses entitlement boundaries.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "paranormallE7V2", title: "Paranormall Episode 7 e7.v2", detail: "Episode 7 uses the e7.v2 release-candidate mapping and does not expose the retired Episode 7 product path.", status: "Manual")
            ]
        ),
        HFReleaseCandidateQASection(
            id: "playback",
            title: "Playback Boundaries",
            subtitle: "Protected systems are observed, not changed",
            systemImage: "lock.shield.fill",
            items: [
                HFReleaseCandidateQAItem(id: "trailerOnlyPreviews", title: "Trailer-only previews", detail: "Preview actions only open trailer-safe surfaces and do not imply full feature playback.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "officialNoImport", title: "Official titles never open Import", detail: "Official catalog titles route to streaming/detail/player surfaces, not media import.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "verticalStage", title: "Vertical Stage", detail: "Vertical Stage presentation remains stable on device with no new staging controls added.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "depthTiltPeek", title: "Depth/Tilt/Peek", detail: "Depth, Tilt, and Peek behavior is smoke-tested without modifying motion or playback math.", status: "Manual"),
                HFReleaseCandidateQAItem(id: "layer4", title: "Layer 4", detail: "Layer 4 remains protected and unchanged during the release-candidate pass.", status: "Manual")
            ]
        ),
        HFReleaseCandidateQASection(
            id: "release",
            title: "Release Hygiene",
            subtitle: "Final app-store-facing checks",
            systemImage: "checkmark.seal.fill",
            items: [
                HFReleaseCandidateQAItem(id: "noDebugUIRelease", title: "No debug UI in Release", detail: "Release/TestFlight builds do not expose simulator-only debug unlocks, import shortcuts, or development-only controls.", status: "Manual")
            ]
        )
    ]
}

private struct HFReleaseCandidateQAItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let status: String
}

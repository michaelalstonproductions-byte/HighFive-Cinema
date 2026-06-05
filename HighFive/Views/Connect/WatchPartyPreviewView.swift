import SwiftUI

struct WatchPartyPreviewView: View {
    @State private var joinedPartyIDs: Set<UUID> = []

    private let reactions = [
        ("flame.fill", "248"),
        ("hands.clap.fill", "132"),
        ("movieclapper.fill", "91"),
        ("text.bubble.fill", "37")
    ]

    private let comingNext = [
        "Real watch parties",
        "Synced playback",
        "Live chat",
        "Creator Q&A",
        "Moderation tools"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Watch Party Preview"])
                featuredWatchPartySection
                upcomingPartiesSection
                watchPartyRoomSection
                mockReactionsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Watch Party")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Watch Party Preview")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.76)

            Text("Preview shared viewing around HighFive originals and creator packages.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No synced playback, live chat, networking, or protected playback integration.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredWatchPartySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Watch Party", actionTitle: nil)

            if let party = HFConnectPreviewData.watchParties.first {
                watchPartyCard(party, isFeatured: true)
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var upcomingPartiesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Upcoming Parties", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.watchParties.dropFirst()) { party in
                    watchPartyCard(party, isFeatured: false)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var watchPartyRoomSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Watch Party Room Mock", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [HFColors.surfaceElevated, HFColors.gold.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 174)

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFStatusBadge(title: "Host", systemImage: "crown.fill", isProminent: true)
                            Text("Shared Preview")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("124 viewers waiting • The Friendly")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                        .padding(HFSpacing.md)
                    }

                    HFProgressBar(title: "Mock room progress", value: 0.42, valueLabel: "42%")

                    Text("This room card is a static local preview and does not control playback.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var mockReactionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Mock Live Reactions", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(reactions, id: \.0) { reaction in
                    HFMetricCard(title: "Local reaction", value: reaction.1, systemImage: reaction.0)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var comingNextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Coming Next", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(comingNext, id: \.self) { item in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 22)
                            Text(item)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func watchPartyCard(_ party: HFConnectWatchParty, isFeatured: Bool) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: isFeatured ? HFColors.goldStroke : HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 44, height: 44)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(party.title)
                                .font(isFeatured ? HFTypography.section : HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: party.status, isProminent: false)
                        }

                        Text("Host: \(party.host)")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                        Text("\(party.time) • \(party.guests)")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                    }
                }

                Button {
                    toggleJoin(party)
                } label: {
                    Text(joinedPartyIDs.contains(party.id) ? "Joined Preview" : "Preview Watch Party")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle mock watch party join for \(party.title)")
            }
            .padding(HFSpacing.md)
        }
    }

    private func toggleJoin(_ party: HFConnectWatchParty) {
        if joinedPartyIDs.contains(party.id) {
            joinedPartyIDs.remove(party.id)
        } else {
            joinedPartyIDs.insert(party.id)
        }
    }
}

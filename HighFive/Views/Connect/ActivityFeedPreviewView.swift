import SwiftUI

struct ActivityFeedPreviewView: View {
    @State private var selectedFilter = "For You"
    @State private var likedItemIDs: Set<UUID> = []
    @State private var savedItemIDs: Set<UUID> = []

    private let filters = [
        "For You",
        "Following",
        "Creators",
        "Movies",
        "Rooms"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                filterSection
                featuredPost
                activityFeedSection
                commentsSection
                roomRoutes
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Feed")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Feed")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)

                Text("Swipe through creator posts, film updates, watch rooms, and community reactions.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            NavigationLink {
                FollowSuggestionsPreviewView()
            } label: {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 46, height: 46)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Find people to follow")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(filters, id: \.self) { filter in
                    HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                        selectedFilter = filter
                    }
                    .accessibilityLabel("Select \(filter) feed filter")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    @ViewBuilder
    private var featuredPost: some View {
        if let item = HFConnectPreviewData.feedItems.first {
            activityCard(item, isFeatured: true)
                .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var activityFeedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "For You", actionTitle: nil)

            VStack(spacing: HFSpacing.lg) {
                ForEach(HFConnectPreviewData.feedItems.dropFirst()) { item in
                    activityCard(item, isFeatured: false)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func activityCard(_ item: HFConnectActivityItem, isFeatured: Bool) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: isFeatured ? HFColors.gold.opacity(0.42) : HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.goldGradient)
                        Image(systemName: item.systemImage)
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(item.actor)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Just now")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textMuted)
                    }

                    Spacer()

                    Button {} label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(HFColors.textMuted)
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                }

                ZStack(alignment: .bottomLeading) {
                    postArtwork(for: item)
                        .frame(height: isFeatured ? 390 : 270)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.78)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(item.title)
                            .font(isFeatured ? HFTypography.section : HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                        Text(item.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(3)
                    }
                    .padding(HFSpacing.md)
                }

                HStack(spacing: HFSpacing.sm) {
                    feedAction(
                        title: likedItemIDs.contains(item.id) ? "Liked" : item.reactions,
                        systemImage: likedItemIDs.contains(item.id) ? "heart.fill" : "heart"
                    ) {
                        toggleLiked(item.id)
                    }

                    feedAction(title: item.comments, systemImage: "text.bubble.fill") {}

                    feedAction(
                        title: savedItemIDs.contains(item.id) ? "Saved" : "Save",
                        systemImage: savedItemIDs.contains(item.id) ? "bookmark.fill" : "bookmark"
                    ) {
                        toggleSaved(item.id)
                    }

                    feedAction(title: "Share", systemImage: "square.and.arrow.up") {}
                }
            }
            .padding(HFSpacing.md)
        }
    }

    @ViewBuilder
    private func postArtwork(for item: HFConnectActivityItem) -> some View {
        let movie = item.title.localizedCaseInsensitiveContains("Paranormall")
            ? HFMockData.movie("paranormall-s1")
            : HFMockData.movie("friendly")

        if let movie,
           HFPosterAssetHealth.hasImage(named: movie.backdropAssetName ?? movie.posterAssetName),
           let assetName = movie.backdropAssetName ?? movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [HFColors.charcoal, HFColors.warmGlow.opacity(0.44), HFColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Image(systemName: item.systemImage)
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(HFColors.gold.opacity(0.72))
            )
        }
    }

    private func feedAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: HFSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .black))
                Text(title)
                    .font(HFTypography.micro)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .foregroundStyle(HFColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(Color.white.opacity(0.10))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Top Comments", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    commentLine(author: "Creative Lead", text: "The poster direction is strong. Keep the gold title treatment.")
                    commentLine(author: "Editor", text: "The trailer hook lands better when the first cut opens on the character.")
                    commentLine(author: "Studio Review", text: "The room feedback is clear enough for the next release pass.")
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var roomRoutes: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Keep Watching With Others", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    SocialRoomDetailPreviewView()
                } label: {
                    HFActionTile(
                        title: "The Friendly Watch Room",
                        subtitle: "Join the room, read reactions, and follow the creators behind the title.",
                        systemImage: "star.bubble.fill"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    WatchPartyPreviewView()
                } label: {
                    HFActionTile(
                        title: "Watch Parties",
                        subtitle: "Find scheduled watch nights and fan rooms for HighFive titles.",
                        systemImage: "play.tv.fill"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func toggleLiked(_ id: UUID) {
        if likedItemIDs.contains(id) {
            likedItemIDs.remove(id)
        } else {
            likedItemIDs.insert(id)
        }
    }

    private func toggleSaved(_ id: UUID) {
        if savedItemIDs.contains(id) {
            savedItemIDs.remove(id)
        } else {
            savedItemIDs.insert(id)
        }
    }

    private func commentLine(author: String, text: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(author)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(text)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}

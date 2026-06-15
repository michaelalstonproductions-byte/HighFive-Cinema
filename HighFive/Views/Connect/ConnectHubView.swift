import SwiftUI

struct ConnectHubView: View {
    @State private var followedCreatorIDs: Set<UUID> = []
    @State private var savedRoomIDs: Set<UUID> = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                storiesSection
                featuredReel
                feedEntry
                featuredCreatorsSection
                roomsSection
                projectUpdatesSection
                signalStrip
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Connect")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)

                Text("Follow creators, join rooms, and watch what the HighFive community is talking about.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            NavigationLink {
                ConnectNotificationsPreviewView()
            } label: {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 46, height: 46)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open notifications")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var storiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.featuredCreators) { creator in
                    NavigationLink {
                        CreatorProfilePreviewView(creator: creator)
                    } label: {
                        HFConnectStoryAvatar(
                            name: creator.name,
                            subtitle: creator.role,
                            systemImage: "person.crop.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }

                ForEach(HFConnectPreviewData.socialRooms.prefix(3)) { room in
                    NavigationLink {
                        SocialRoomDetailPreviewView(room: room)
                    } label: {
                        HFConnectStoryAvatar(
                            name: room.name,
                            subtitle: "\(room.activeNow) active",
                            systemImage: "bubble.left.and.bubble.right.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var featuredReel: some View {
        NavigationLink {
            ActivityFeedPreviewView()
        } label: {
            ZStack(alignment: .bottomLeading) {
                featuredArtwork
                    .frame(height: 520)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack {
                        HFStatusBadge(title: "Live", isProminent: true)
                        HFStatusBadge(title: "Creator Feed", isProminent: false)
                        Spacer()
                        VStack(spacing: HFSpacing.sm) {
                            HFConnectVerticalMetric(systemImage: "heart.fill", value: "4.8K")
                            HFConnectVerticalMetric(systemImage: "text.bubble.fill", value: "318")
                            HFConnectVerticalMetric(systemImage: "bookmark.fill", value: "1.2K")
                        }
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("The Friendly Watch Room")
                            .font(.system(size: 34, weight: .black, design: .default))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text("Poster reactions are up, trailer comments are moving, and creators are joining the room.")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: HFSpacing.sm) {
                            Label("Watch feed", systemImage: "play.fill")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.black)
                                .padding(.horizontal, HFSpacing.md)
                                .frame(height: 42)
                                .background(HFColors.goldGradient)
                                .clipShape(Capsule())

                            Label("37 active", systemImage: "person.2.fill")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textPrimary)
                                .padding(.horizontal, HFSpacing.sm)
                                .frame(height: 42)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.44), lineWidth: 1)
            )
            .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 26, x: 0, y: 18)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open The Friendly Watch Room feed")
    }

    private var featuredArtwork: some View {
        Group {
            if let movie = HFMockData.movie("friendly"),
               HFPosterAssetHealth.hasImage(named: movie.backdropAssetName ?? movie.posterAssetName),
               let assetName = movie.backdropAssetName ?? movie.posterAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [HFColors.charcoal, HFColors.warmGlow.opacity(0.42), HFColors.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var feedEntry: some View {
        NavigationLink {
            ActivityFeedPreviewView()
        } label: {
            HFActionTile(
                title: "Open Feed",
                subtitle: "Swipe through creator posts, community reactions, watch rooms, and project updates.",
                systemImage: "play.rectangle.on.rectangle.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Connect feed")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredCreatorsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creators to Follow", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(HFConnectPreviewData.featuredCreators) { creator in
                        NavigationLink {
                            CreatorProfilePreviewView(creator: creator)
                        } label: {
                            creatorCard(creator)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private func creatorCard(_ creator: HFConnectCreator) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(HFColors.goldGradient)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.black)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(creator.name)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(creator.role)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
            }

            Text(creator.bio)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("\(creator.followers) followers")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                Spacer()
            }

            Button {
                toggleFollow(creator.id)
            } label: {
                Text(followedCreatorIDs.contains(creator.id) ? "Following" : "Follow")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(followedCreatorIDs.contains(creator.id) ? HFColors.textPrimary : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(followedCreatorIDs.contains(creator.id) ? AnyShapeStyle(Color.white.opacity(0.14)) : AnyShapeStyle(HFColors.goldGradient))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 210, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(HFColors.surfaceElevated.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
        )
    }

    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Rooms For You", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.socialRooms.prefix(3)) { room in
                    NavigationLink {
                        SocialRoomDetailPreviewView(room: room)
                    } label: {
                        roomCard(room)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func roomCard(_ room: HFConnectSocialRoom) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack {
                        Text(room.name)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(room.activeNow)
                            .font(HFTypography.micro)
                            .foregroundStyle(.black)
                            .padding(.horizontal, HFSpacing.xs)
                            .frame(height: 22)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }

                    Text(room.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: HFSpacing.sm) {
                        Label(room.members, systemImage: "person.2.fill")
                        Label("\(room.comments) comments", systemImage: "text.bubble.fill")
                        Spacer()
                        Button {
                            toggleRoomSave(room.id)
                        } label: {
                            Image(systemName: savedRoomIDs.contains(room.id) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private var projectUpdatesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Trending Updates", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.projectUpdates) { update in
                    NavigationLink {
                        ProjectCommunityPreviewView()
                    } label: {
                        HStack(spacing: HFSpacing.md) {
                            Image(systemName: update.systemImage)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 44, height: 44)
                                .background(HFColors.gold.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                                Text(update.title)
                                    .font(HFTypography.cardTitle)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(update.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .padding(HFSpacing.md)
                        .background(HFColors.surface.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var signalStrip: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Community Pulse", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.communitySignals) { signal in
                    HFMetricCard(title: signal.title.replacingOccurrences(of: "Mock ", with: ""), value: signal.value, systemImage: signal.systemImage)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func toggleFollow(_ id: UUID) {
        if followedCreatorIDs.contains(id) {
            followedCreatorIDs.remove(id)
        } else {
            followedCreatorIDs.insert(id)
        }
    }

    private func toggleRoomSave(_ id: UUID) {
        if savedRoomIDs.contains(id) {
            savedRoomIDs.remove(id)
        } else {
            savedRoomIDs.insert(id)
        }
    }
}

private struct HFConnectStoryAvatar: View {
    let name: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: HFSpacing.xs) {
            ZStack {
                Circle()
                    .stroke(HFColors.goldGradient, lineWidth: 3)
                Circle()
                    .fill(HFColors.surfaceElevated)
                    .padding(4)
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(HFColors.gold)
            }
            .frame(width: 78, height: 78)

            Text(name)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .frame(width: 86)

            Text(subtitle)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
                .frame(width: 86)
        }
    }
}

private struct HFConnectVerticalMetric: View {
    let systemImage: String
    let value: String

    var body: some View {
        VStack(spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .frame(width: 42, height: 42)
                .background(Color.black.opacity(0.36))
                .clipShape(Circle())
            Text(value)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textPrimary)
        }
    }
}

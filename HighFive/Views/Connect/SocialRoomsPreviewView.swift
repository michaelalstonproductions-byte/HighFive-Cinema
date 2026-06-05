import SwiftUI

struct SocialRoomsPreviewView: View {
    @State private var joinedRoomIDs: Set<UUID> = []
    @State private var savedRoomIDs: Set<UUID> = []

    private let comingNext = [
        "Real rooms",
        "Real comments",
        "Real moderation",
        "Creator-hosted discussions",
        "Watch-party chat"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Social Rooms"])
                featuredRoomsSection
                roomCategoriesSection
                roomActivitySection
                mockRoomActionsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Social Rooms")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Social Rooms")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Preview creator-led rooms for projects, watch parties, reviews, and community discussions.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Room joins, saves, and discussions are local mock UI.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredRoomsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Rooms", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.socialRooms) { room in
                    NavigationLink {
                        SocialRoomDetailPreviewView(room: room)
                    } label: {
                        socialRoomCard(room)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(room.name) room detail preview")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var roomCategoriesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Room Categories", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(HFConnectPreviewData.roomCategories, id: \.self) { category in
                        HFRouteChip(title: category, systemImage: "bubble.left.and.bubble.right.fill")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var roomActivitySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Room Activity", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(HFConnectPreviewData.roomActivity, id: \.self) { activity in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)
                            Text(activity)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var mockRoomActionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Mock Room Actions", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                mockAction(title: "Join Room", systemImage: "plus.circle.fill") {
                    toggleFirstRoomJoin()
                }
                mockAction(title: "Save Room", systemImage: "bookmark.fill") {
                    toggleFirstRoomSave()
                }
                mockAction(title: "Preview Discussion", systemImage: "text.bubble.fill") {}
                mockAction(title: "Share Room", systemImage: "square.and.arrow.up.fill") {}
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

    private func socialRoomCard(_ room: HFConnectSocialRoom) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 44, height: 44)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(room.name)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: room.status, isProminent: false)
                        }
                        Text(room.type)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text(room.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    HFStatusBadge(title: "\(room.members) members", isProminent: false)
                    HFStatusBadge(title: "\(room.activeNow) active now", isProminent: false)
                    Spacer()
                }

                Text("Open room detail to preview discussions and room signals.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
            }
            .padding(HFSpacing.md)
        }
    }

    private func mockAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 36, height: 36)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                    Text(title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Local mock only")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) mock room action")
    }

    private func toggleJoin(_ id: UUID) {
        if joinedRoomIDs.contains(id) {
            joinedRoomIDs.remove(id)
        } else {
            joinedRoomIDs.insert(id)
        }
    }

    private func toggleSave(_ id: UUID) {
        if savedRoomIDs.contains(id) {
            savedRoomIDs.remove(id)
        } else {
            savedRoomIDs.insert(id)
        }
    }

    private func toggleFirstRoomJoin() {
        guard let id = HFConnectPreviewData.socialRooms.first?.id else { return }
        toggleJoin(id)
    }

    private func toggleFirstRoomSave() {
        guard let id = HFConnectPreviewData.socialRooms.first?.id else { return }
        toggleSave(id)
    }
}

import SwiftUI

struct SocialRoomDetailPreviewView: View {
    let room: HFConnectSocialRoom
    @State private var isJoined = false
    @State private var savedDiscussionIDs: Set<UUID> = []

    private let comingNext = [
        "Real discussion threads",
        "Real moderation",
        "Creator host controls",
        "Live room events",
        "Watch-party integration"
    ]

    init(room: HFConnectSocialRoom = HFConnectPreviewData.socialRooms[0]) {
        self.room = room
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                roomHeader
                HFBreadcrumbTrail(items: ["Connect", "Social Rooms", "Room Detail"])
                featuredDiscussionSection
                discussionPreviewSection
                roomSignalsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Room Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var roomHeader: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 62, height: 62)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(room.name)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(room.type)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                        HFStatusBadge(title: "Preview Only", isProminent: false)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                    HFMetricCard(title: "Members", value: room.members, systemImage: "person.3.fill")
                    HFMetricCard(title: "Active now", value: room.activeNow, systemImage: "dot.radiowaves.left.and.right")
                }

                Button {
                    isJoined.toggle()
                } label: {
                    Text(isJoined ? "Joined Room Preview" : "Join Room Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isJoined ? "Joined room preview" : "Join room preview")

                Text("Room membership, discussions, replies, and reactions are local mock state only.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredDiscussionSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Discussion", actionTitle: nil)

            if let discussion = HFConnectPreviewData.roomDiscussions.first {
                discussionCard(discussion, isFeatured: true)
                    .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var discussionPreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Discussion Preview", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.roomDiscussions.dropFirst()) { discussion in
                    discussionCard(discussion, isFeatured: false)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var roomSignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Room Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFMetricCard(title: "Reactions today", value: room.reactions, systemImage: "hand.thumbsup.fill")
                HFMetricCard(title: "Saved updates", value: "92", systemImage: "bookmark.fill")
                HFMetricCard(title: "Watch-party interest", value: "124", systemImage: "play.tv.fill")
                HFMetricCard(title: "Creator replies", value: "8", systemImage: "person.wave.2.fill")
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

    private func discussionCard(_ discussion: HFConnectRoomDiscussion, isFeatured: Bool) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: isFeatured ? HFColors.goldStroke : HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: isFeatured ? "star.bubble.fill" : "text.bubble.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(discussion.title)
                                .font(isFeatured ? HFTypography.section : HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: discussion.status, isProminent: false)
                        }
                        Text("Creator: \(discussion.author)")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text(discussion.body)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    HFStatusBadge(title: "\(discussion.replies) replies preview", isProminent: false)
                    HFStatusBadge(title: "\(discussion.reactions) reactions", isProminent: false)
                    Spacer()
                    Button {
                        toggleDiscussionSave(discussion.id)
                    } label: {
                        Image(systemName: savedDiscussionIDs.contains(discussion.id) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 32, height: 32)
                            .background(HFColors.gold.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Save mock discussion")
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private func toggleDiscussionSave(_ id: UUID) {
        if savedDiscussionIDs.contains(id) {
            savedDiscussionIDs.remove(id)
        } else {
            savedDiscussionIDs.insert(id)
        }
    }
}

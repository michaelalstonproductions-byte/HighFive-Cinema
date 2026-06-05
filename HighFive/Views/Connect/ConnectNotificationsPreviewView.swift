import SwiftUI

struct ConnectNotificationsPreviewView: View {
    @State private var readNotificationIDs: Set<UUID> = []
    @State private var isRoomSaved = false
    @State private var isCreatorFollowed = false

    private let groups = ["Streaming", "Creator", "Connect"]
    private let comingNext = [
        "Real social notifications",
        "Creator follow alerts",
        "Community moderation alerts",
        "Watch party reminders",
        "Push notifications"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Notifications"])
                prioritySignalsSection
                groupedNotificationsSection
                notificationActionsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Connect Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Connect Notifications")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.74)

            Text("Preview social signals from creators, rooms, projects, and watch parties.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No push notifications, permissions, backend alerts, or account graph are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var prioritySignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Priority Signals", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.priorityNotifications) { notification in
                    notificationCard(notification, isPriority: true)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var groupedNotificationsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFSectionHeader(title: "Notification Groups", actionTitle: nil)

            ForEach(groups, id: \.self) { group in
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack {
                        Text(group)
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                        Spacer()
                        HFStatusBadge(title: "\(notifications(for: group).count) mock", isProminent: false)
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)

                    VStack(spacing: HFSpacing.md) {
                        ForEach(notifications(for: group)) { notification in
                            notificationCard(notification, isPriority: false)
                        }
                    }
                    .padding(.horizontal, HFSpacing.screenHorizontal)
                }
            }
        }
    }

    private var notificationActionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Notification Actions", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                mockAction(title: "Mark all read", systemImage: "checkmark.circle.fill") {
                    markAllRead()
                }
                mockAction(title: isRoomSaved ? "Room saved" : "Save room", systemImage: isRoomSaved ? "bookmark.fill" : "bookmark") {
                    isRoomSaved.toggle()
                }
                mockAction(title: isCreatorFollowed ? "Creator followed" : "Follow creator", systemImage: isCreatorFollowed ? "person.fill.checkmark" : "person.badge.plus") {
                    isCreatorFollowed.toggle()
                }
                mockAction(title: "Preview update", systemImage: "eye.fill") {}
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

    private func notifications(for group: String) -> [HFConnectNotification] {
        HFConnectPreviewData.groupedNotifications.filter { $0.group == group }
    }

    private func notificationCard(_ notification: HFConnectNotification, isPriority: Bool) -> some View {
        Button {
            toggleRead(notification.id)
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: isPriority ? HFColors.goldStroke : HFColors.glassStroke) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: notification.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(readNotificationIDs.contains(notification.id) ? 0.08 : 0.16))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(notification.subtitle)
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.gold)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: readNotificationIDs.contains(notification.id) ? "Read" : notification.status, isProminent: !readNotificationIDs.contains(notification.id))
                        }

                        Text(notification.title)
                            .font(HFTypography.body)
                            .foregroundStyle(readNotificationIDs.contains(notification.id) ? HFColors.textSecondary : HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(notification.timestamp)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textMuted)
                    }
                }
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(readNotificationIDs.contains(notification.id) ? "Read mock notification" : "Unread mock notification")
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
                    Text("Local preview")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) mock notification action")
    }

    private func toggleRead(_ id: UUID) {
        if readNotificationIDs.contains(id) {
            readNotificationIDs.remove(id)
        } else {
            readNotificationIDs.insert(id)
        }
    }

    private func markAllRead() {
        readNotificationIDs.formUnion(HFConnectPreviewData.priorityNotifications.map(\.id))
        readNotificationIDs.formUnion(HFConnectPreviewData.groupedNotifications.map(\.id))
    }
}

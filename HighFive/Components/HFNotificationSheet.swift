import SwiftUI

struct HFNotificationSheet: View {
    @ObservedObject var store: HFNotificationCenterStore
    @Environment(\.dismiss) private var dismiss

    init(store: HFNotificationCenterStore = HFNotificationCenterStore()) {
        self.store = store
    }

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.sm) {
                            Text("Notifications")
                                .font(HFTypography.display)
                                .foregroundStyle(HFColors.textPrimary)
                                .minimumScaleFactor(0.82)

                            HFUnreadBadge(count: store.unreadCount)
                        }

                        Text("Local preview alerts for streaming and creator workflow.")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    HStack(spacing: HFSpacing.xs) {
                        Button {
                            store.markAllRead()
                        } label: {
                            Text("Mark Read")
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.gold)
                                .padding(.horizontal, HFSpacing.sm)
                                .frame(height: 36)
                                .background(Color.white.opacity(0.10))
                                .clipShape(Capsule())
                        }

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(HFColors.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Circle())
                        }
                    }
                    .buttonStyle(.plain)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: HFSpacing.lg) {
                        notificationGroup(title: "Streaming", items: store.streamingNotifications)
                        notificationGroup(title: "Creator", items: store.creatorNotifications)
                    }
                    .padding(.bottom, HFSpacing.xl)
                }
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func notificationGroup(title: String, items: [HFLocalNotificationItem]) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(items) { item in
                    HFNotificationRow(item: item)
                }
            }
        }
    }
}

struct HFNotificationRow: View {
    let item: HFLocalNotificationItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: item.isRead ? HFColors.glassStroke : HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(item.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.xs)

                        if !item.isRead {
                            Circle()
                                .fill(HFColors.gold)
                                .frame(width: 8, height: 8)
                                .accessibilityLabel("Unread")
                        }

                        HFStatusBadge(title: item.category, isProminent: false)
                    }

                    Text(item.message)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .opacity(item.isRead ? 0.72 : 1)
    }
}

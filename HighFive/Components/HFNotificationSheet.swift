import SwiftUI

struct HFNotificationSheet: View {
    @StateObject private var store = HFNotificationCenterStore()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Notifications")
                            .font(HFTypography.display)
                            .foregroundStyle(HFColors.textPrimary)
                            .minimumScaleFactor(0.82)

                        Text("Local preview alerts for streaming and creator workflow.")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

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
                    .buttonStyle(.plain)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: HFSpacing.md) {
                        ForEach(store.notifications) { item in
                            HFNotificationRow(item: item)
                        }
                    }
                    .padding(.bottom, HFSpacing.xl)
                }
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

private struct HFNotificationRow: View {
    let item: HFLocalNotificationItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
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
    }
}

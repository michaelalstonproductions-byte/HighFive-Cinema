import SwiftUI

struct HFAccountView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var restoreStatus: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                sectionCard(title: "Purchase Access", systemImage: "checkmark.seal.fill") {
                    Text("HighFive Cinema uses Apple In-App Purchase to verify paid movies and episodes.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)

                    Button {
                        Task { await restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise.circle.fill")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.account.restorePurchases")

                    if let restoreStatus {
                        Text(restoreStatus)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                sectionCard(title: "Access Status", systemImage: "play.rectangle.on.rectangle.fill") {
                    accessRow(title: "The Friendly", subtitle: "Movie purchase", isUnlocked: hasAccessToFriendly)
                    accessRow(title: "Paranormall", subtitle: "Episodes unlock individually", isUnlocked: hasAnyParanormallAccess)
                }

                sectionCard(title: "Privacy & Data", systemImage: "hand.raised.fill") {
                    Text("User-imported videos are intended for private local playback. Official title access is verified through Apple purchase records.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let url = HFSupportConfig.mailtoURL(
                        subject: HFSupportConfig.dataPrivacySubject,
                        body: HFSupportConfig.supportBody(context: "I need help with a HighFive Cinema privacy or data request.")
                    ) {
                        Link("Request Data / Privacy Help", destination: url)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.account.dataPrivacyRequest")
                    }
                }

                sectionCard(title: "Support", systemImage: "envelope.fill") {
                    if let url = HFSupportConfig.mailtoURL(
                        subject: HFSupportConfig.supportSubject,
                        body: HFSupportConfig.supportBody(context: "I need help with my HighFive Cinema account or purchase access.")
                    ) {
                        Link("Email Support", destination: url)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.account.emailSupport")
                    }

                    Text("No HighFive account is currently required.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                }
            }
            .padding(20)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.account.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            Text("No HighFive login is required. Purchases and restore are handled through Apple.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var hasAccessToFriendly: Bool {
        guard let friendly = streamingStore.movie(id: "friendly") else { return false }
        return streamingStore.hasVerifiedStoreKitAccess(for: friendly)
    }

    private var hasAnyParanormallAccess: Bool {
        streamingStore.verifiedStoreKitProductIDs.contains { productID in
            productID.hasPrefix("com.highfive.episode.paranormall.")
                || productID == HFProductIdentifier.paranormallSeasonOneUnlock.rawValue
        }
    }

    private func restorePurchases() async {
        restoreStatus = "Restoring purchases..."
        let result = await streamingStore.restoreStoreKitPurchases()
        restoreStatus = result
    }

    private func accessRow(title: String, subtitle: String, isUnlocked: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)

                Text(subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            Text(isUnlocked ? "Unlocked" : "Locked")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(isUnlocked ? .black : HFColors.gold)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(isUnlocked ? HFColors.gold : Color.white.opacity(0.08), in: Capsule())
        }
    }

    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(HFColors.gold)
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
            }

            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

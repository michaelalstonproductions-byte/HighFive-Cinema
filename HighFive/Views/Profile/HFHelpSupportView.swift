import SwiftUI

struct HFHelpSupportView: View {
    @State private var activeLegalDocument: HFLegalHelpDocument?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                helpCard(title: "Contact", systemImage: "envelope.fill") {
                    if let url = HFSupportConfig.mailtoURL(
                        subject: HFSupportConfig.supportSubject,
                        body: HFSupportConfig.supportBody(context: "I need help with HighFive Cinema.")
                    ) {
                        Link("Email Support", destination: url)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.help.emailSupport")
                    }

                    if let url = HFSupportConfig.mailtoURL(
                        subject: HFSupportConfig.playbackIssueSubject,
                        body: HFSupportConfig.supportBody(context: "I am reporting a playback or streaming issue. Title/Episode:")
                    ) {
                        Link("Report Playback Issue", destination: url)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .accessibilityIdentifier("hf.help.reportPlayback")
                    }
                }

                helpCard(title: "Quick Help", systemImage: "questionmark.circle.fill") {
                    faq(
                        question: "How do I restore purchases?",
                        answer: "Open Profile > Account and tap Restore Purchases. HighFive Cinema verifies eligible purchases through Apple."
                    )

                    faq(
                        question: "Why does a title say Stream Unavailable?",
                        answer: "That title does not currently have an available full playback source. Trailers remain preview-only and are not used as paid full playback."
                    )

                    faq(
                        question: "How do imported videos work?",
                        answer: "Imported videos are for private local playback. Official HighFive Cinema titles use streaming, paywall, and entitlement routing."
                    )

                    faq(
                        question: "How do Depth, Tilt, and Peek work?",
                        answer: "Supported videos can use device motion and Vertical Stage playback. Motion effects may vary by device, orientation, title, and accessibility settings."
                    )
                }

                helpCard(title: "Legal", systemImage: "doc.text.fill") {
                    Button {
                        activeLegalDocument = .terms
                    } label: {
                        rowLabel("Terms of Use")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.help.terms")

                    Button {
                        activeLegalDocument = .privacy
                    } label: {
                        rowLabel("Privacy Policy")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.help.privacy")
                }
            }
            .padding(20)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeLegalDocument) { document in
            switch document {
            case .terms:
                HFLegalTextSheet(
                    title: "Terms of Use",
                    version: HFLegalDocuments.currentTermsVersion,
                    text: HFLegalDocuments.fullTerms
                )
            case .privacy:
                HFLegalTextSheet(
                    title: "Privacy Policy",
                    version: HFLegalDocuments.currentPrivacyVersion,
                    text: HFLegalDocuments.privacyPolicy
                )
            }
        }
        .accessibilityIdentifier("hf.help.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Help & Support")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            Text("Get help with streaming, purchases, imports, and Vertical Stage playback.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func faq(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(question)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            Text(answer)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func rowLabel(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(HFColors.textMuted)
        }
        .padding(.vertical, 4)
    }

    private func helpCard<Content: View>(
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

            VStack(alignment: .leading, spacing: 14) {
                content()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

private enum HFLegalHelpDocument: String, Identifiable {
    case terms
    case privacy

    var id: String { rawValue }
}

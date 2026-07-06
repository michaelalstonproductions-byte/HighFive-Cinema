import SwiftUI

struct HFLegalGateView<Content: View>: View {
    @AppStorage(HFLegalDocuments.acceptedTermsVersionKey) private var acceptedTermsVersion = ""
    @AppStorage(HFLegalDocuments.acceptedPrivacyVersionKey) private var acceptedPrivacyVersion = ""
    @AppStorage(HFLegalDocuments.acceptedTermsDateKey) private var acceptedAt = ""
    @AppStorage(HFLegalDocuments.hasAcceptedTermsKey) private var hasAcceptedTerms = false

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if hasAcceptedTerms &&
            acceptedTermsVersion == HFLegalDocuments.currentTermsVersion &&
            acceptedPrivacyVersion == HFLegalDocuments.currentPrivacyVersion {
            content
        } else {
            HFTermsAgreementView {
                acceptCurrentTerms()
            }
        }
    }

    private func acceptCurrentTerms() {
        HFLegalDocuments.recordCurrentAcceptance()
        hasAcceptedTerms = true
        acceptedTermsVersion = HFLegalDocuments.currentTermsVersion
        acceptedPrivacyVersion = HFLegalDocuments.currentPrivacyVersion
        acceptedAt = UserDefaults.standard.string(forKey: HFLegalDocuments.acceptedTermsDateKey) ?? ""
    }
}

struct HFTermsAgreementView: View {
    let onAgree: () -> Void

    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showDeclineAlert = false
    @State private var hasScrolledToBottom = false

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.35),
                    HFColors.goldDeep.opacity(0.18),
                    Color.black.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    consentCard
                    bulletCard
                    legalReviewCard
                    actionButtons
                    footer
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, 34)
                .padding(.bottom, 34)
            }
        }
        .sheet(isPresented: $showTerms) {
            HFLegalDocumentSheet(
                title: "Terms of Use",
                version: HFLegalDocuments.currentTermsVersion,
                text: HFLegalDocuments.fullTerms
            )
        }
        .sheet(isPresented: $showPrivacy) {
            HFLegalDocumentSheet(
                title: "Privacy Policy",
                version: HFLegalDocuments.currentPrivacyVersion,
                text: HFLegalDocuments.privacyPolicy
            )
        }
        .alert("Terms Required", isPresented: $showDeclineAlert) {
            Button("Review Terms", role: .cancel) { }
        } message: {
            Text("You must accept the Terms of Use to use HighFive Cinema.")
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("hf.legal.gate")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles.tv")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(HFColors.gold)

                Text("HIGHFIVE CINEMA")
                    .font(.system(size: 13, weight: .black, design: .default))
                    .tracking(2.4)
                    .foregroundStyle(HFColors.gold)
            }

            Text(HFLegalDocuments.title)
                .font(.system(size: 38, weight: .black, design: .default))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(HFLegalDocuments.introCopy)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("hf.legal.header")
    }

    private var consentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Agreement Required")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            Text(HFLegalDocuments.consentCopy)
                .font(HFTypography.body)
                .lineSpacing(3)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(HFColors.glassSurfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.gold.opacity(0.28), lineWidth: 1)
        )
        .accessibilityIdentifier("hf.legal.consentCard")
    }

    private var bulletCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("You agree that:")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(HFLegalDocuments.summaryBullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .padding(.top, 1)

                        Text(bullet)
                            .font(HFTypography.caption.weight(.semibold))
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityIdentifier("hf.legal.summary")
    }

    private var legalReviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Scroll to Review", systemImage: hasScrolledToBottom ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                    .font(HFTypography.caption.weight(.black))
                    .foregroundStyle(hasScrolledToBottom ? HFColors.gold : HFColors.textPrimary)

                Spacer()

                Text(hasScrolledToBottom ? "Ready" : "Required")
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(hasScrolledToBottom ? .black : HFColors.gold)
                    .padding(.horizontal, 10)
                    .frame(height: 26)
                    .background(hasScrolledToBottom ? HFColors.gold : Color.white.opacity(0.08), in: Capsule())
            }

            HFLegalInlineReviewView(hasScrolledToBottom: $hasScrolledToBottom)

            Text(hasScrolledToBottom ? "You can now agree and enter HighFive Cinema." : "Scroll this legal review to the bottom before agreeing.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textMuted)
        }
        .padding(14)
        .background(HFColors.glassSurfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.gold.opacity(hasScrolledToBottom ? 0.50 : 0.22), lineWidth: 1)
        )
        .accessibilityIdentifier("hf.legal.review")
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                guard hasScrolledToBottom else {
                    showDeclineAlert = true
                    return
                }
                onAgree()
            } label: {
                Text(hasScrolledToBottom ? "Agree & Enter" : "Scroll to Bottom to Agree")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(hasScrolledToBottom ? .black : HFColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        hasScrolledToBottom ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.10)),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(HFColors.gold.opacity(hasScrolledToBottom ? 0.34 : 0.14), lineWidth: 1)
                    )
                    .shadow(color: HFColors.gold.opacity(hasScrolledToBottom ? 0.24 : 0), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.legal.agree")

            HStack(spacing: 10) {
                Button {
                    showTerms = true
                } label: {
                    Text("View Terms")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.glassSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(0.13), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.legal.viewTerms")

                Button {
                    showPrivacy = true
                } label: {
                    Text("View Privacy")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.glassSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(0.13), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.legal.viewPrivacy")
            }

            Button {
                showDeclineAlert = true
            } label: {
                Text("Decline")
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.legal.decline")
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Terms Version \(HFLegalDocuments.currentTermsVersion)")
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.gold.opacity(0.78))
        }
        .accessibilityIdentifier("hf.legal.footer")
    }
}

private struct HFLegalInlineReviewView: View {
    @Binding var hasScrolledToBottom: Bool

    private let reviewText = """
    \(HFLegalDocuments.fullTerms)

    \(HFLegalDocuments.privacyPolicy)
    """

    var body: some View {
        GeometryReader { outerProxy in
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(reviewText)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .lineSpacing(4)
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("End of HighFive Cinema Terms and Privacy Policy")
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.gold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    GeometryReader { markerProxy in
                        Color.clear
                            .preference(
                                key: HFLegalReviewBottomPreferenceKey.self,
                                value: markerProxy.frame(in: .named("hf.legal.reviewScroll")).maxY
                            )
                    }
                    .frame(height: 1)
                }
                .padding(14)
            }
            .coordinateSpace(name: "hf.legal.reviewScroll")
            .onPreferenceChange(HFLegalReviewBottomPreferenceKey.self) { bottomY in
                if bottomY > 0, bottomY <= outerProxy.size.height + 18 {
                    hasScrolledToBottom = true
                }
            }
        }
        .frame(height: 280)
        .background(Color.black.opacity(0.38), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityIdentifier("hf.legal.inlineReview")
    }
}

private struct HFLegalReviewBottomPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct HFLegalDocumentSheet: View {
    let title: String
    let version: String
    let text: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .lineSpacing(4)
                    .foregroundStyle(.white.opacity(0.84))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(22)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("v\(version)")
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("hf.legal.documentSheet")
    }
}

#if DEBUG
#Preview("Legal Gate") {
    HFTermsAgreementView { }
        .preferredColorScheme(.dark)
}
#endif

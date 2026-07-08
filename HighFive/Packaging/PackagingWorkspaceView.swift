import SwiftUI

private enum PackagingStudioPackageType: String, CaseIterable, Identifiable {
    case poster
    case trailer
    case social
    case pressKit
    case launchKit
    case distribution

    var id: String { rawValue }

    var title: String {
        switch self {
        case .poster: return "Poster Package"
        case .trailer: return "Trailer Package"
        case .social: return "Social Media Package"
        case .pressKit: return "Press Kit"
        case .launchKit: return "Launch Kit"
        case .distribution: return "Distribution Package"
        }
    }

    var subtitle: String {
        switch self {
        case .poster: return "Master poster, vertical, landscape, thumbnails, app art."
        case .trailer: return "Trailer cuts, preview stills, captions, platform checks."
        case .social: return "TikTok, Instagram, LinkedIn, hooks, hashtags."
        case .pressKit: return "Synopsis, credits, cast, director, companies."
        case .launchKit: return "Release checklist, trailer, poster, social, press."
        case .distribution: return "Storefront copy, platform assets, final QA packet."
        }
    }

    var systemImage: String {
        switch self {
        case .poster: return "photo.on.rectangle.angled"
        case .trailer: return "play.rectangle.fill"
        case .social: return "person.2.wave.2.fill"
        case .pressKit: return "doc.text.image.fill"
        case .launchKit: return "sparkles.tv.fill"
        case .distribution: return "shippingbox.fill"
        }
    }
}

struct PackagingWorkspaceView: View {
    private let package = MarkOfTheWestPromoKit.package
    private let hookGenerator = CaptionHookGenerator()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                hero
                packageTypeGrid
                posterBuilderShell
                socialBuilderShell
                pressKitShell
                launchKitShell
                promoKitPreviews
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
            .padding(.top, 28)
            .padding(.bottom, 44)
        }
        .background(studioBackground)
        .navigationTitle("Packaging Studio")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.packaging.workspace")
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black,
                            HFColors.gold.opacity(0.16),
                            Color.black.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    HFLayer4VolumetricGlow(
                        motion: .still,
                        tint: HFColors.gold,
                        intensity: 0.68
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.30), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 30, x: 0, y: 18)

            VStack(alignment: .leading, spacing: 12) {
                Text("INTERNAL / DRAFT")
                    .font(.system(size: 12, weight: .black))
                    .tracking(1.8)
                    .foregroundStyle(HFColors.gold)

                Text("Packaging Studio")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text("Build poster, trailer, social, press, launch, and distribution packages from local HighFive draft models. No backend, upload, CRM, or contact data is connected.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    studioPill("Local Models")
                    studioPill("Export Drafts")
                    studioPill("No Upload")
                }
            }
            .padding(22)
        }
        .frame(minHeight: 250)
        .accessibilityIdentifier("hf.packaging.hero")
    }

    private var packageTypeGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            studioSectionTitle("Package Types")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PackagingStudioPackageType.allCases) { packageType in
                    packageTypeCard(packageType)
                }
            }
        }
        .accessibilityIdentifier("hf.packaging.packageTypes")
    }

    private var posterBuilderShell: some View {
        builderPanel(
            title: "Poster Builder",
            subtitle: "Artwork package shell",
            systemImage: "rectangle.portrait.on.rectangle.portrait.angled",
            identifier: "hf.packaging.posterBuilder"
        ) {
            builderChecklist([
                "Master poster",
                "Vertical poster",
                "Landscape hero",
                "Thumbnail",
                "App artwork",
                "Export checklist"
            ])
        }
    }

    private var socialBuilderShell: some View {
        builderPanel(
            title: "Social Builder",
            subtitle: "Platform layout shell",
            systemImage: "sparkles.rectangle.stack.fill",
            identifier: "hf.packaging.socialBuilder"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                builderChecklist([
                    "TikTok layout",
                    "Instagram layout",
                    "LinkedIn layout"
                ])

                labeledDraftField(title: "Caption / Hook", value: hookGenerator.hooks(for: package.items[0]).first ?? "Original stories in motion.")
                labeledDraftField(title: "Hashtags", value: "#HighFiveCinema #OriginalStories #TheMarkOfTheWest")
                builderChecklist(["Export-ready checklist"])
            }
        }
    }

    private var pressKitShell: some View {
        builderPanel(
            title: "Press Kit",
            subtitle: "Editorial package shell",
            systemImage: "newspaper.fill",
            identifier: "hf.packaging.pressKit"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                builderChecklist([
                    "Synopsis",
                    "Credits",
                    "Cast",
                    "Director",
                    "Companies"
                ])

                Button {} label: {
                    Label("Download Package", systemImage: "arrow.down.doc.fill")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(HFColors.goldGradient, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(true)
                .opacity(0.62)
                .accessibilityIdentifier("hf.packaging.pressKit.downloadPlaceholder")
            }
        }
    }

    private var launchKitShell: some View {
        builderPanel(
            title: "Launch Kit",
            subtitle: "Release readiness shell",
            systemImage: "flag.checkered.2.crossed",
            identifier: "hf.packaging.launchKit"
        ) {
            builderChecklist([
                "Release checklist",
                "Trailer assets",
                "Poster assets",
                "Social captions",
                "Press contact package",
                "Distribution checklist"
            ])
        }
    }

    private var promoKitPreviews: some View {
        VStack(alignment: .leading, spacing: 14) {
            studioSectionTitle(package.title)

            ForEach(package.items) { item in
                previewCard(for: item)
            }
        }
        .accessibilityIdentifier("hf.packaging.promoKit")
    }

    private var studioBackground: some View {
        ZStack {
            HFColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.040, green: 0.032, blue: 0.022),
                    HFColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    HFColors.gold.opacity(0.16),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 18,
                endRadius: 520
            )
            .ignoresSafeArea()
        }
    }

    private func packageTypeCard(_ packageType: PackagingStudioPackageType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: packageType.systemImage)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.black)
                .frame(width: 42, height: 42)
                .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            Text(packageType.title)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)

            Text(packageType.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 174, alignment: .top)
        .padding(14)
        .background(Color.white.opacity(0.050), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(HFColors.gold.opacity(0.16), lineWidth: 1)
        )
    }

    private func builderPanel<Content: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.textPrimary)
                    Text(subtitle)
                        .font(HFTypography.caption.weight(.semibold))
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer()
            }

            content()
        }
        .padding(18)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.22),
                            Color.white.opacity(0.08),
                            HFColors.gold.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
        .accessibilityIdentifier(identifier)
    }

    private func builderChecklist(_ items: [String]) -> some View {
        VStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(HFColors.gold)
                    Text(item)
                        .font(HFTypography.caption.weight(.semibold))
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    Text("Draft")
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.textMuted)
                }
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private func labeledDraftField(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)
            Text(value)
                .font(HFTypography.caption.weight(.semibold))
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private func previewCard(for item: PromoPackageItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.62))
                }

                Spacer()

                Text(item.isInternalOnly ? "INTERNAL" : "DRAFT")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(item.isInternalOnly ? .white.opacity(0.70) : HFColors.gold)
            }

            HStack(spacing: 8) {
                ForEach(item.exportPresets) { preset in
                    Text(preset.aspectRatioLabel)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(.white.opacity(0.76))
                        .padding(.horizontal, 9)
                        .frame(height: 25)
                        .background(Color.white.opacity(0.07), in: Capsule())
                }
            }

            Text(hookGenerator.hooks(for: item).first ?? "Preview / Draft")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.70))
        }
        .padding(16)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.gold.opacity(item.isInternalOnly ? 0.12 : 0.22), lineWidth: 1)
        )
    }

    private func studioSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 22, weight: .black))
            .foregroundStyle(HFColors.textPrimary)
    }

    private func studioPill(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro.weight(.black))
            .foregroundStyle(HFColors.gold)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color.white.opacity(0.075), in: Capsule())
            .overlay(Capsule().stroke(HFColors.gold.opacity(0.18), lineWidth: 1))
    }
}

import SwiftUI

struct CreatorMarketplacePreviewView: View {
    private let featuredPackages = [
        MarketplacePackage(title: "The Friendly — Creator Package", type: "Feature package", status: "Draft", interest: "24 interested"),
        MarketplacePackage(title: "Paranormall — Season 1 Preview", type: "Series preview", status: "Preview", interest: "18 interested"),
        MarketplacePackage(title: "Behind the Vision — Short", type: "Short-form package", status: "Featured", interest: "6 interested")
    ]

    private let creatorCategories = [
        "Directors",
        "Writers",
        "Editors",
        "Cinematographers",
        "Composers",
        "Poster Designers"
    ]

    private let marketplaceSignals = [
        MarketplaceSignal(title: "Packages ready", value: "12", systemImage: "shippingbox.fill"),
        MarketplaceSignal(title: "Creators available", value: "48", systemImage: "person.2.fill"),
        MarketplaceSignal(title: "Studio requests", value: "7", systemImage: "tray.full.fill"),
        MarketplaceSignal(title: "Featured this week", value: "3", systemImage: "star.fill")
    ]

    private let comingNext = [
        "Creator hiring",
        "Paid package listings",
        "Collaboration requests",
        "Marketplace messaging",
        "Secure payments"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                featuredPackagesSection
                categoriesSection
                marketplaceSignalsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Marketplace")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Marketplace")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.82)

            Text("Discover creators, packages, and collaboration opportunities.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Real marketplace tools are coming soon.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredPackagesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Packages", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(featuredPackages.enumerated()), id: \.element) { index, package in
                        packageRow(index: index + 1, package: package)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creator Categories", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                ForEach(creatorCategories, id: \.self) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var marketplaceSignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Marketplace Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(marketplaceSignals) { signal in
                    MarketplaceSignalCard(signal: signal)
                }
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

    private func packageRow(index: Int, package: MarketplacePackage) -> some View {
        HStack(spacing: HFSpacing.md) {
            Text("\(index)")
                .font(HFTypography.caption)
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .background(HFColors.gold)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                HStack(spacing: HFSpacing.xs) {
                    Text(package.title)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: HFSpacing.xs)

                    MarketplaceStatusBadge(title: package.status)
                }

                Text(package.type)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)

                HStack(spacing: HFSpacing.xs) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                    Text(package.interest)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, HFSpacing.xs)
    }

    private func categoryChip(_ title: String) -> some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: icon(for: title))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(HFColors.gold)

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HFSpacing.sm)
        .padding(.vertical, HFSpacing.sm)
        .background(HFColors.glassSurface)
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))
    }

    private func icon(for category: String) -> String {
        switch category {
        case "Directors":
            return "megaphone.fill"
        case "Writers":
            return "pencil.and.outline"
        case "Editors":
            return "timeline.selection"
        case "Cinematographers":
            return "camera.fill"
        case "Composers":
            return "music.note"
        default:
            return "photo.artframe"
        }
    }
}

private struct MarketplacePackage: Hashable {
    let title: String
    let type: String
    let status: String
    let interest: String
}

private struct MarketplaceSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct MarketplaceStatusBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(.black)
            .lineLimit(1)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 5)
            .background(HFColors.gold)
            .clipShape(Capsule())
    }
}

private struct MarketplaceSignalCard: View {
    let signal: MarketplaceSignal

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: signal.systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(signal.value)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(signal.title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

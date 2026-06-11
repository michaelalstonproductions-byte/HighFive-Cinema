import SwiftUI

struct MyListView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onBrowseDiscover: (() -> Void)?
    @State private var selectedFilter = "Saved"

    private let filters = ["Saved", "Continue Watching", "Downloads"]
    private let columns = [
        GridItem(.adaptive(minimum: HFSpacing.posterGridWidth), spacing: HFSpacing.md)
    ]

    private var savedMovies: [Movie] {
        switch selectedFilter {
        case "Continue Watching":
            return streamingStore.savedMovies.filter { $0.progress != nil }
        case "Downloads":
            return streamingStore.savedMovies.filter { streamingStore.isDownloaded($0) }
        default:
            return streamingStore.savedMovies
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                header
                libraryShelfHero
                connectedStateSection
                catalogLibrarySection
                profileStateSection
                watchShelfSection
                shelfMomentumSection
                filterChips

                if savedMovies.isEmpty {
                    HFEmptyState(
                        title: "Your shelf is waiting",
                        message: "Save titles from Home, Search, Discover, or Movie Detail and they will appear here.",
                        systemImage: "bookmark",
                        actionTitle: "Browse Discover",
                        action: onBrowseDiscover
                    )
                        .padding(.horizontal, HFSpacing.screenHorizontal)
                } else {
                    savedSummary
                    savedGrid
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .accessibilityIdentifier("hf.consumer.library.root")
        .accessibilityIdentifier("hf.functional.library.savedState")
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Your Library")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Saved titles, offline-ready picks, and what you are watching next.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var libraryShelfHero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                            .fill(HFColors.gold.opacity(0.14))
                        Image(systemName: "bookmark.rectangle.stack.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Your Watch Shelf")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Saved titles, in-progress films, and offline-ready picks stay organized here.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: HFSpacing.sm) {
                    HFLibraryCountTile(value: "\(streamingStore.savedMovies.count)", label: "Saved")
                    HFLibraryCountTile(value: "\(streamingStore.savedMovies.filter { $0.progress != nil }.count)", label: "Resume")
                    HFLibraryCountTile(value: "\(streamingStore.savedMovies.filter { streamingStore.isDownloaded($0) }.count)", label: "Offline")
                }
            }
            .padding(HFSpacing.lg)
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.26), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Library shelf summary")
        .accessibilityIdentifier("hf.consumer.library.watchShelf")
    }

    private var watchShelfSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Your Watch Shelf", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 136), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                HFLibraryShelfCard(title: "Saved Titles", detail: "\(streamingStore.savedMovies.count) in your shelf", systemImage: "bookmark.fill", isActive: true)
                HFLibraryShelfCard(title: "Continue Watching", detail: "\(streamingStore.savedMovies.filter { $0.progress != nil }.count) in progress", systemImage: "play.circle.fill")
                HFLibraryShelfCard(title: "Downloads", detail: "\(streamingStore.savedMovies.filter { streamingStore.isDownloaded($0) }.count) offline-ready", systemImage: "arrow.down.circle.fill")
                HFLibraryShelfCard(title: "Recently Added", detail: "Fresh titles for later", systemImage: "clock.fill")
                HFLibraryShelfCard(title: "Recommended Next", detail: "A softer path back in", systemImage: "sparkles")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Your Watch Shelf, saved titles, continue watching, downloads, recently added, and recommended next")
        .accessibilityIdentifier("hf.consumer.library.watchShelf")
    }

    private var connectedStateSection: some View {
        HFInsightCard(
            title: "Connected State",
            message: "Saved movies update from Movie Detail.",
            systemImage: "point.3.connected.trianglepath.dotted"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.functional.library.connectedState")
    }

    private var catalogLibrarySection: some View {
        HFInsightCard(
            title: "Catalog Library",
            message: "Saved titles resolve through the shared movie catalog.",
            systemImage: "rectangle.stack.fill.badge.person.crop"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Catalog Library, saved titles resolve through the shared movie catalog")
        .accessibilityIdentifier("hf.catalog.library.connected")
    }

    private var profileStateSection: some View {
        HFInsightCard(
            title: "Saved for \(streamingStore.activeViewingProfile.displayName)",
            message: "My List uses your active local profile.",
            systemImage: streamingStore.activeViewingProfile.avatarSymbol
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Saved for \(streamingStore.activeViewingProfile.displayName), My List uses your active local profile")
        .accessibilityIdentifier("hf.account.library.profileState")
    }

    private var shelfMomentumSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Shelf Momentum", actionTitle: nil)

            VStack(spacing: HFSpacing.xs) {
                HFConsumerMomentumRow(title: "Saved shelf ready", detail: "Saved titles stay organized for later.", status: "Ready", systemImage: "bookmark.fill")
                HFConsumerMomentumRow(title: "Continue watching local", detail: "In-progress titles stay visible in your shelf.", status: "Local", systemImage: "play.circle.fill")
                HFConsumerMomentumRow(title: "Downloads preview", detail: "Offline-ready titles connect to Downloads.", status: "Preview", systemImage: "arrow.down.circle.fill")
                HFConsumerMomentumRow(title: "Watch mood organized", detail: "Filters keep tonight's choice easy to scan.", status: "Ready", systemImage: "line.3.horizontal.decrease.circle.fill")
                HFConsumerMomentumRow(title: "Local profile shelf", detail: "Your profile can browse this preview without setup.", status: "Local", systemImage: "person.crop.circle.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Library shelf momentum, saved shelf, continue watching, downloads, watch mood, and local profile shelf")
        .accessibilityIdentifier("hf.consumer.library.shelfMomentum")
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(filters, id: \.self) { filter in
                    HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.consumer.library.filters")
    }

    private var savedGrid: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: selectedFilter == "Saved" ? "Saved For Later" : selectedFilter, actionTitle: nil)

            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.lg) {
                ForEach(savedMovies) { movie in
                    NavigationLink(value: movie) {
                        HFPosterCard(movie: movie, width: HFSpacing.posterGridWidth, showMetadata: true, showProgress: movie.progress != nil)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(movie.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.consumer.library.savedShelf")
    }

    private var savedSummary: some View {
        HFInsightCard(
            title: selectedFilter == "Saved" ? "\(savedMovies.count) saved titles" : "\(savedMovies.count) titles ready",
            message: selectedFilter == "Saved" ? "Your saved slate is available across Home, Search, and Movie Detail." : "This filter reflects your saved and downloaded titles.",
            systemImage: "bookmark.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct HFLibraryShelfCard: View {
    let title: String
    let detail: String
    let systemImage: String
    var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 30, height: 30)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 102, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFLibraryCountTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: HFSpacing.xxs) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .default))
                .foregroundStyle(HFColors.textPrimary)
            Text(label)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 62)
        .background(Color.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous).stroke(HFColors.gold.opacity(0.18), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

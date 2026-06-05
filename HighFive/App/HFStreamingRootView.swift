import SwiftUI

enum HFStreamingTab: Hashable {
    case home
    case search
    case library
    case downloads
    case profile
}

struct HFStreamingRootView: View {
    @State private var selectedTab: HFStreamingTab = .home
    @State private var selectedProfile = HFMockData.userProfiles[0]
    @State private var searchMode: HFSearchHubMode = .search
    @StateObject private var streamingStore = HFStreamingStore()

    private let tabItems: [HFTabItem<HFStreamingTab>] = [
        HFTabItem(value: .home, title: "Home", systemImage: "house.fill"),
        HFTabItem(value: .search, title: "Search", systemImage: "magnifyingglass"),
        HFTabItem(value: .library, title: "Library", systemImage: "bookmark.fill"),
        HFTabItem(value: .downloads, title: "Downloads", systemImage: "arrow.down.circle.fill"),
        HFTabItem(value: .profile, title: "Profile", systemImage: "person.crop.circle.fill")
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                HFColors.screenBackground
                    .ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(
                            selectedProfile: selectedProfile,
                            onSearch: {
                                searchMode = .search
                                selectedTab = .search
                            },
                            onDiscover: {
                                searchMode = .discover
                                selectedTab = .search
                            },
                            onProfile: {
                                selectedTab = .profile
                            },
                            onMyList: {
                                selectedTab = .library
                            }
                        )
                    case .search:
                        SearchView(mode: $searchMode)
                    case .library:
                        MyListView(onBrowseDiscover: {
                            searchMode = .discover
                            selectedTab = .search
                        })
                    case .downloads:
                        DownloadsView(onFindMore: {
                            searchMode = .discover
                            selectedTab = .search
                        })
                    case .profile:
                        ProfileView(
                            selectedProfile: $selectedProfile,
                            onOpenMyList: {
                                selectedTab = .library
                            }
                        )
                    }
                }
                .padding(.bottom, HFSpacing.floatingTabClearance)

                HFTabBar(items: tabItems, selection: $selectedTab)
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .tint(HFColors.gold)
        .preferredColorScheme(.dark)
        .environmentObject(streamingStore)
    }
}

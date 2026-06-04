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
                        HomeView(selectedProfile: selectedProfile)
                    case .search:
                        SearchView()
                    case .library:
                        MyListView()
                    case .downloads:
                        DownloadsView()
                    case .profile:
                        ProfileView(selectedProfile: $selectedProfile)
                    }
                }
                .padding(.bottom, HFSpacing.tabBarHeight + HFSpacing.sm)

                HFTabBar(items: tabItems, selection: $selectedTab)
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .tint(HFColors.gold)
        .preferredColorScheme(.dark)
    }
}

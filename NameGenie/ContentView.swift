import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .generate

    var body: some View {
        ZStack(alignment: .bottom) {
            GenerateFlow(selectedTab: $selectedTab)
                .opacity(selectedTab == .generate ? 1 : 0)

            FavoritesFlow(selectedTab: $selectedTab)
                .opacity(selectedTab == .favorites ? 1 : 0)

            CultureFlow(selectedTab: $selectedTab)
                .opacity(selectedTab == .culture ? 1 : 0)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

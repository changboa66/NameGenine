import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GenerateView()
                .tabItem {
                    Label("Generate", systemImage: "sparkles")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "bookmark")
                }

            CultureView()
                .tabItem {
                    Label("Culture", systemImage: "book")
                }
        }
    }
}

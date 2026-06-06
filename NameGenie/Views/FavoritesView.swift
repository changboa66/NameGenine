import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteName.createdAt, order: .reverse) private var favorites: [FavoriteName]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""

    var body: some View {
        Group {
            if favorites.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("No favorites yet")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            Text("Save names you like by tapping the bookmark icon.")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredFavorites) { favorite in
                    NavigationLink {
                        NameDetailView(
                            hanzi: favorite.hanzi,
                            pinyin: favorite.pinyin,
                            meaning: favorite.meaning,
                            cachedDetailData: favorite.detailData
                        )
                    } label: {
                        FavoriteRow(favorite: favorite)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            modelContext.delete(favorite)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .searchable(text: $searchText, prompt: "Search names")
    }

    private var filteredFavorites: [FavoriteName] {
        if searchText.isEmpty {
            return favorites
        }
        return favorites.filter {
            $0.hanzi.localizedCaseInsensitiveContains(searchText) ||
            $0.pinyin.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct FavoritesFlow: View {
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FavoritesView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Favorites")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }

                CustomTabBar(selectedTab: $selectedTab, thisTab: .favorites)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct FavoriteRow: View {
    let favorite: FavoriteName

    var body: some View {
        HStack(spacing: 16) {
            Text(favorite.hanzi)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text(favorite.pinyin)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text(favorite.meaning)
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

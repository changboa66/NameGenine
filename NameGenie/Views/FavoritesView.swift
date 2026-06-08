import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteName.createdAt, order: .reverse) private var favorites: [FavoriteName]
    @Environment(\.modelContext) private var modelContext

    private var dayGroups: [DayGroup] {
        favorites.groupedByDay()
    }

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
        List {
            ForEach(dayGroups) { group in
                Section {
                    ForEach(group.items) { favorite in
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
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(group.items[index])
                        }
                    }
                } header: {
                    Text(group.displayDate)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct FavoritesFlow: View {
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FavoritesView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab, thisTab: .favorites)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct FavoriteRow: View {
    let favorite: FavoriteName

    private var style: String? {
        if favorite.meaning.hasPrefix("Classic") { "Classic" }
        else if favorite.meaning.hasPrefix("Modern") { "Modern" }
        else if favorite.meaning.hasPrefix("Unique") { "Unique" }
        else { nil }
    }

    private var styleColor: Color {
        switch style {
        case "Classic": .orange
        case "Modern": .blue
        case "Unique": .purple
        default: .gray
        }
    }

    private var cleanMeaning: String {
        guard let style else { return favorite.meaning }
        return String(favorite.meaning.dropFirst(style.count + 2))
    }

    var body: some View {
        HStack(spacing: 16) {
            Text(favorite.hanzi)
                .font(.system(size: 22, weight: .medium))

            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.pinyin.formattedPinyin(hanziCount: favorite.hanzi.count))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    if style != nil {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(styleColor)
                    }
                    Text(cleanMeaning)
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
    }
}

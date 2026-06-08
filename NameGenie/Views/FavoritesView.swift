import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteName.createdAt, order: .reverse) private var favorites: [FavoriteName]
    @Environment(\.modelContext) private var modelContext

    private var groupedFavorites: [(DateGroup, [FavoriteName])] {
        favorites.groupedByDate()
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
        ScrollView {
            LazyVStack(spacing: 8, pinnedViews: .sectionHeaders) {
                ForEach(groupedFavorites, id: \.0) { group, items in
                    Section {
                        ForEach(items) { favorite in
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
                    } header: {
                        sectionHeader(group)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private func sectionHeader(_ group: DateGroup) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iconName(for: group))
                .font(.system(size: 11, weight: .medium))
            Text(group.title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            Text("\(favoritesCount(in: group)) 个")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }

    private func iconName(for group: DateGroup) -> String {
        switch group {
        case .today: return "sun.max"
        case .yesterday: return "moon.stars"
        case .thisWeek: return "calendar"
        case .earlier: return "clock"
        }
    }

    private func favoritesCount(in group: DateGroup) -> Int {
        groupedFavorites.first { $0.0 == group }?.1.count ?? 0
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

    private var dateLabel: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(favorite.createdAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: favorite.createdAt)
        } else if calendar.isDateInYesterday(favorite.createdAt) {
            return "昨天"
        } else if calendar.isDate(favorite.createdAt, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "EEE"
            return formatter.string(from: favorite.createdAt)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            return formatter.string(from: favorite.createdAt)
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Text(favorite.hanzi)
                .font(.system(size: 22, weight: .medium))

            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.pinyin)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text(favorite.meaning)
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            Text(dateLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.tertiarySystemBackground))
                .clipShape(.rect(cornerRadius: 4))
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

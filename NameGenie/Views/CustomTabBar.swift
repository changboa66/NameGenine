import SwiftUI

enum Tab: String, CaseIterable {
    case generate
    case favorites
    case culture

    var icon: String {
        switch self {
        case .generate: return "sparkles"
        case .favorites: return "bookmark"
        case .culture: return "book"
        }
    }

    var label: String {
        switch self {
        case .generate: return "Generate"
        case .favorites: return "Favorites"
        case .culture: return "Culture"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    let thisTab: Tab

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18))
                            Text(tab.label)
                                .font(.system(size: 10))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .background(Color(.systemBackground))

            Color(.systemBackground)
                .frame(height: 20)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

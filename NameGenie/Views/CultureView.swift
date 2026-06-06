import SwiftUI

struct CultureView: View {
    @State private var snippets: [CulturalSnippet] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if snippets.isEmpty {
                    emptyState
                } else {
                    ForEach(snippets) { snippet in
                        SnippetCard(snippet: snippet)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .task {
            loadSnippets()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading cultural content...")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 60)
    }

    private func loadSnippets() {
        guard let url = Bundle.main.url(forResource: "cultural_content", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([CulturalSnippet].self, from: data) else {
            return
        }
        snippets = decoded
    }
}

struct CultureFlow: View {
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CultureView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Chinese Name Culture")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }

                CustomTabBar(selectedTab: $selectedTab, thisTab: .culture)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct CulturalSnippet: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let topic: String
    let example: String?
}

struct SnippetCard: View {
    let snippet: CulturalSnippet

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(snippet.topic.uppercased())
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)

            Text(snippet.title)
                .font(.system(size: 17, weight: .medium))

            Text(snippet.body)
                .font(.system(size: 13))
                .lineSpacing(4)
                .foregroundStyle(.secondary)

            if let example = snippet.example {
                Text(example)
                    .font(.system(size: 13))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

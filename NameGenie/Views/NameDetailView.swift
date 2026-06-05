import SwiftUI
import SwiftData

struct NameDetailView: View {
    let hanzi: String
    let pinyin: String
    let meaning: String

    @State private var detail: NameDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isFavorited = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if isLoading {
                    ProgressView()
                        .padding(.vertical, 40)
                } else if let errorMessage {
                    errorSection(errorMessage)
                } else if let detail {
                    detailSections(detail)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Name Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: isFavorited ? "bookmark.fill" : "bookmark")
                    }

                    ShareLink(items: [shareText])
                }
            }
        }
        .task {
            await loadDetail()
        }
        .onAppear {
            checkFavoriteStatus()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(hanzi)
                .font(.system(size: 36, weight: .light))
            Text(pinyin)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            Text(meaning)
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await loadDetail() }
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 40)
    }

    @ViewBuilder
    private func detailSections(_ detail: NameDetail) -> some View {
        characterBreakdownSection(detail.detail.characterBreakdown)
        pronunciationSection(detail.detail.pronunciation)
        culturalSection(detail.detail.culturalBackground)
        namesakesSection(detail.detail.namesakes)
    }

    private func characterBreakdownSection(_ breakdown: [CharacterBreakdown]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CHARACTER BREAKDOWN")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)

            ForEach(breakdown, id: \.character) { char in
                VStack(alignment: .leading, spacing: 8) {
                    Text(char.character)
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 4) {
                        LabeledContent("Radical", value: char.radical)
                        LabeledContent("Strokes", value: "\(char.strokeCount)")
                        LabeledContent("Name usage", value: char.nameUsage)
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                    Text(char.meaning)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 10))
            }
        }
    }

    private func pronunciationSection(_ pronunciation: PronunciationInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRONUNCIATION")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)

            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Pinyin", value: pronunciation.withTones)
                LabeledContent("Say it like", value: pronunciation.guideForLearners)
            }
            .font(.system(size: 13))
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func culturalSection(_ culturalBackground: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CULTURAL BACKGROUND")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)

            Text(culturalBackground)
                .font(.system(size: 13))
                .lineSpacing(4)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func namesakesSection(_ namesakes: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTABLE NAMESAKES")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)

            VStack(spacing: 0) {
                ForEach(Array(namesakes.enumerated()), id: \.offset) { index, name in
                    Text(name)
                        .font(.system(size: 13))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if index < namesakes.count - 1 {
                        Divider()
                            .padding(.leading, 0)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    private var shareText: String {
        var text = "NameGenie — \(hanzi) (\(pinyin))\n"
        text += "Meaning: \(meaning)\n"
        if let detail {
            text += "Cultural background: \(detail.detail.culturalBackground.prefix(200))..."
        }
        return text
    }

    private func loadDetail() async {
        isLoading = true
        errorMessage = nil
        do {
            detail = try await NameGenieAPI.shared.nameDetail(hanzi: hanzi, pinyin: pinyin)
        } catch {
            errorMessage = "Could not load details. Try again."
        }
        isLoading = false
    }

    private func checkFavoriteStatus() {
        let fetchDescriptor = FetchDescriptor<FavoriteName>(
            predicate: #Predicate { $0.hanzi == hanzi }
        )
        if let results = try? modelContext.fetch(fetchDescriptor) {
            isFavorited = !results.isEmpty
        }
    }

    private func toggleFavorite() {
        let predicate = #Predicate<FavoriteName> { $0.hanzi == hanzi }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            isFavorited = false
        } else {
            let detailData = detail.flatMap { try? JSONEncoder().encode($0) }
            let favorite = FavoriteName(
                hanzi: hanzi,
                pinyin: pinyin,
                meaning: meaning,
                detailData: detailData
            )
            modelContext.insert(favorite)
            isFavorited = true
        }
        try? modelContext.save()
    }
}

import SwiftUI
import SwiftData

struct NameDetailView: View {
    let hanzi: String
    let pinyin: String
    let meaning: String
    var cachedDetailData: Data?

    @ObservedObject private var pronunciationService = PronunciationService.shared
    @State private var detail: NameDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isFavorited = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var hanziCharacters: [String] {
        hanzi.map { String($0) }
    }

    private var pinyinParts: [String] {
        pinyin.split(separator: " ").map(String.init)
    }

    private var isPlaying: Bool {
        pronunciationService.isSpeaking && pronunciationService.currentHanzi == hanzi
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if isLoading {
                    LottieView("panda-fly", loopMode: .loop)
                        .frame(width: 120, height: 120)
                        .padding(.vertical, 40)
                        .transition(.opacity)
                } else if let errorMessage {
                    errorSection(errorMessage)
                } else if let detail {
                    detailSections(detail)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .animation(.default, value: isLoading)
            .animation(.default, value: detail != nil)
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
        .onChange(of: pronunciationService.currentCharIndex) { _, newIndex in
            if let index = newIndex, index < hanziCharacters.count {
                let char = hanziCharacters[index]
                let py = index < pinyinParts.count ? pinyinParts[index] : ""
                UIAccessibility.post(notification: .announcement, argument: "\(char) \(py)")
            }
        }
        .onChange(of: pronunciationService.isSpeaking) { _, speaking in
            if !speaking {
                UIAccessibility.post(notification: .announcement, argument: "播放结束")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        ForEach(Array(hanziCharacters.enumerated()), id: \.offset) { index, char in
                            VStack(spacing: 2) {
                                Text(char)
                                    .font(.system(size: 36, weight: .light))
                                    .scaleEffect(
                                        isPlaying && pronunciationService.currentCharIndex == index
                                            ? 1.15 : 1.0
                                    )
                                    .foregroundStyle(
                                        isPlaying && pronunciationService.currentCharIndex == index
                                            ? Color.accentColor : .primary
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: pronunciationService.currentCharIndex)

                                if index < pinyinParts.count {
                                    Text(pinyinParts[index])
                                        .font(.system(size: 13))
                                        .foregroundStyle(
                                            isPlaying && pronunciationService.currentCharIndex == index
                                                ? Color.accentColor : .secondary
                                        )
                                        .animation(.easeInOut(duration: 0.2), value: pronunciationService.currentCharIndex)
                                }
                            }
                        }
                    }

                    Text(meaning)
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Button {
                    if isPlaying {
                        pronunciationService.stop()
                    } else {
                        pronunciationService.speak(hanzi: hanzi, pinyin: pinyin)
                    }
                } label: {
                    Group {
                        if isPlaying {
                            Image(systemName: "stop.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Image(systemName: "speaker.wave.2.circle")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .font(.system(size: 28))
                }
                .accessibilityLabel(isPlaying ? "停止播放" : "播放\(hanzi)的发音")
                .accessibilityAddTraits(.startsMediaSession)
            }

            if let detail {
                pronounceGuide(detail.detail.pronunciation)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func pronounceGuide(_ pronunciation: PronunciationInfo) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "info.circle")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text(pronunciation.guideForLearners)
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        if let cachedDetailData, let decoded = try? JSONDecoder().decode(NameDetail.self, from: cachedDetailData) {
            detail = decoded
            return
        }
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
            try? modelContext.save()
        } else {
            Task {
                if detail == nil {
                    await loadDetail()
                }
                let detailData = detail.flatMap { try? JSONEncoder().encode($0) }
                let favorite = FavoriteName(
                    hanzi: hanzi,
                    pinyin: pinyin,
                    meaning: meaning,
                    detailData: detailData
                )
                modelContext.insert(favorite)
                isFavorited = true
                try? modelContext.save()
            }
        }
    }
}

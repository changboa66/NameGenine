import SwiftUI

struct GenerateViewContent: View {
    @State private var preferences = GenerationPreferences()
    @State private var candidates: [NameCandidate] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hasGenerated = false
    @State private var selectedName: NameCandidate?
    @State private var showDetail = false
    @State private var pandaLoaded = false
    @State private var scrollToResults = false
    @State private var showAllMeanings = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    headerSection

                    VStack(spacing: 16) {
                        preferencesSection
                        luckyButton
                        resultsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 3)
                    .padding(.bottom, 16)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .background(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.12), Color(.systemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(edges: .top)
            .overlay(loadingOverlay)
            .animation(.easeInOut(duration: 0.25), value: isLoading)
            .refreshable {
                if !candidates.isEmpty {
                    generate()
                }
            }
            .onChange(of: scrollToResults) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo("results", anchor: .top)
                        }
                        scrollToResults = false
                    }
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                if let name = selectedName {
                    NameDetailView(
                        hanzi: name.hanzi,
                        pinyin: name.pinyin,
                        meaning: name.meaning
                    )
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            PausedLottieView(name: "panda-fly", progress: 0)
                .frame(width: 80, height: 60)
                .onAppear { pandaLoaded = true }

            Text("Find Your Chinese Name")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, -4)

            Text("Tell us about yourself and discover meaningful Chinese names")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 0)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private var preferencesSection: some View {
        VStack(spacing: 8) {
            genderCountCard
            meaningsCard
            yourNameCard
        }
    }

    private var genderCountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "figure.stand.dress.line.vertical.figure")
                        .font(.system(size: 12))
                        .frame(width: 24)
                    Text("GENDER")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                CustomSegmentedPicker(
                    selection: $preferences.gender,
                    options: GenerationPreferences.Gender.allCases
                ) { $0.label }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "textformat.characters.arrow.left.and.right")
                        .font(.system(size: 12))
                        .frame(width: 24)
                    Text("CHARS")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                CustomSegmentedPicker(
                    selection: $preferences.characterCount,
                    options: GenerationPreferences.CharacterCount.allCases
                ) { $0.label }
            }

        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 2)
        )
    }

    private var meaningsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text("☯️")
                    .font(.system(size: 12))
                    .frame(width: 24)
                Text("MEANINGS")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.purple)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                spacing: 8
            ) {
                let tags = GenerationPreferences.MeaningTag.allCases
                let displayed = showAllMeanings ? tags : Array(tags.prefix(11))

                ForEach(displayed) { tag in
                    Button {
                        if preferences.meanings.contains(tag) {
                            preferences.meanings.remove(tag)
                        } else {
                            preferences.meanings.insert(tag)
                        }
                    } label: {
                        Text(tag.englishLabel)
                            .font(.system(size: 11))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                preferences.meanings.contains(tag)
                                    ? tag.color
                                    : Color(.secondarySystemBackground)
                            )
                            .foregroundStyle(
                                preferences.meanings.contains(tag)
                                    ? .white
                                    : .primary
                            )
                            .clipShape(.rect(cornerRadius: 6))
                    }
                }

                if !showAllMeanings {
                    Button {
                        showAllMeanings = true
                    } label: {
                        Text("...")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button {
                        showAllMeanings = false
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 2)
        )
    }

    private var yourNameCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "waveform.path")
                    .font(.system(size: 12))
                    .frame(width: 24)
                Text("PRONUNCIATION")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("APPROXIMATE YOUR SOUND")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                TextField("e.g. Christopher", text: $preferences.phoneticInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .focused($isInputFocused)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 2)
        )
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 8) {
                    LottieView("panda-fly", loopMode: .loop)
                        .frame(height: 120)

                    Text("Thinking…")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .transition(.opacity)
        }
    }

    private var luckyButton: some View {
        Button {
            generate()
        } label: {
            Text("🎲 I'm Feeling Lucky")
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.accentColor, Color.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
        }
        .disabled(isLoading)
    }

    @ViewBuilder
    private var resultsSection: some View {
        if let errorMessage {
            VStack(spacing: 12) {
                PausedLottieView(name: "panda-sleep", progress: 0.5)
                    .frame(width: 120, height: 120)
                    .offset(y: -40)
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .offset(y: -60)
            }
            .padding(.vertical, 32)
        } else if hasGenerated && candidates.isEmpty && !isLoading {
            VStack(spacing: 12) {
                PausedLottieView(name: "panda-sleep", progress: 0.5)
                    .frame(width: 120, height: 120)
                    .offset(y: -40)
                Text("No names generated. Try different preferences.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .offset(y: -60)
            }
            .padding(.vertical, 32)
        } else if !candidates.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "list.star")
                        .font(.system(size: 12))
                        .frame(width: 24)
                    Text("RESULTS")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                    .id("results")

                ForEach(candidates) { candidate in
                    Button {
                        selectedName = candidate
                        showDetail = true
                    } label: {
                        NameResultRow(candidate: candidate)
                    }
                    .buttonStyle(PressButtonStyle())
                }

                Button("More Names 🎲") {
                    loadMore()
                }
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 10))
            }
        }
    }

    private func generate() {
        isInputFocused = false
        preferences.phoneticInput = preferences.phoneticInput.trimmingCharacters(in: .whitespaces)
        isLoading = true
        errorMessage = nil
        candidates = []

        Task {
            do {
                let result = try await NameGenieAPI.shared.generateNames(preferences: preferences)
                candidates = result
                hasGenerated = true
                scrollToResults = true
            } catch {
                errorMessage = "Please check your connection and try again."
            }
            isLoading = false
        }
    }

    private func loadMore() {
        isInputFocused = false
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await NameGenieAPI.shared.generateNames(preferences: preferences)
                candidates += result
            } catch {
                errorMessage = "Please check your connection and try again."
            }
            isLoading = false
        }
    }
}

struct GenerateFlow: View {
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GenerateViewContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbarBackground(.hidden, for: .navigationBar)

                CustomTabBar(selectedTab: $selectedTab, thisTab: .generate)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct NameResultRow: View {
    let candidate: NameCandidate

    @ObservedObject private var pronunciationService = PronunciationService.shared

    private var isPlayingThis: Bool {
        pronunciationService.isSpeaking && pronunciationService.currentHanzi == candidate.hanzi
    }

    private var styleColor: Color {
        switch candidate.style {
        case "Classic": .orange
        case "Modern": .blue
        case "Unique": .purple
        default: .gray
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(candidate.hanzi)
                            .font(.system(size: 22))
                        if let style = candidate.style {
                            Text(style)
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(styleColor)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 4))
                        }
                    }
                    Text(candidate.pinyin.formattedPinyin(hanziCount: candidate.hanzi.count))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(candidate.cleanMeaning)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)

                Button {
                    if isPlayingThis {
                        pronunciationService.stop()
                    } else {
                        pronunciationService.speak(
                            hanzi: candidate.hanzi,
                            pinyin: candidate.pinyin
                        )
                    }
                } label: {
                    Group {
                        if isPlayingThis {
                            Image(systemName: "stop.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Image(systemName: "speaker.wave.2.circle")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .font(.system(size: 18))
                }
                .disabled(pronunciationService.isSpeaking && !isPlayingThis)
                .accessibilityLabel(isPlayingThis ? "停止播放" : "播放\(candidate.hanzi)的发音")
                .accessibilityAddTraits(.startsMediaSession)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            GeometryReader { geo in
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(width: geo.size.width * CGFloat(candidate.relevance))
                    .clipShape(.rect(cornerRadius: 1.5))
            }
            .frame(height: 3)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct CustomSegmentedPicker<T: Hashable & Identifiable>: View {
    @Binding var selection: T
    let options: [T]
    let label: (T) -> String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.id) { option in
                Button {
                    selection = option
                } label: {
                    Text(label(option))
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(selection == option ? Color.accentColor : Color(.secondarySystemBackground))
                        .foregroundStyle(selection == option ? .white : .primary)
                }
                .buttonStyle(.plain)

                if option != options.last {
                    Divider()
                        .frame(width: 1)
                        .background(Color(.separator))
                }
            }
        }
        .clipShape(.rect(cornerRadius: 8))
    }
}

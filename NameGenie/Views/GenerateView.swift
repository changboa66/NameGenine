import SwiftUI

struct GenerateViewContent: View {
    @State private var preferences = GenerationPreferences()
    @State private var candidates: [NameCandidate] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hasGenerated = false
    @State private var selectedName: NameCandidate?
    @State private var showDetail = false
    @State private var isRandomMode = false
    @State private var pandaLoaded = false
    @State private var scrollToResults = false

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
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
            }
            .ignoresSafeArea(edges: .top)
            .overlay(loadingOverlay)
            .animation(.easeInOut(duration: 0.25), value: isLoading)
            .refreshable {
                if !candidates.isEmpty {
                    generate(random: isRandomMode)
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
                .font(.system(size: 15, weight: .medium))
                .padding(.top, -8)

            Text("Tell us about yourself and discover meaningful Chinese names")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(Color.accentColor.opacity(0.08))
                .ignoresSafeArea(edges: .top)
        )
    }

    private var preferencesSection: some View {
        VStack(spacing: 8) {
            generateCard
            meaningsCard
            aboutYouCard
        }
    }

    private var generateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("GENDER")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Picker("Gender", selection: $preferences.gender) {
                    ForEach(GenerationPreferences.Gender.allCases) { gender in
                        Text(gender.label).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("CHARACTER COUNT")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Picker("Count", selection: $preferences.characterCount) {
                    ForEach(GenerationPreferences.CharacterCount.allCases) { count in
                        Text(count.label).tag(count)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("SURNAME (OPTIONAL)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                TextField("e.g. Wang, Li", text: $preferences.surname)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var meaningsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MEANINGS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                spacing: 8
            ) {
                ForEach(GenerationPreferences.MeaningTag.allCases) { tag in
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
                            .padding(.vertical, 6)
                            .background(
                                preferences.meanings.contains(tag)
                                    ? Color.accentColor
                                    : Color(.tertiarySystemBackground)
                            )
                            .foregroundStyle(
                                preferences.meanings.contains(tag)
                                    ? .white
                                    : .primary
                            )
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var aboutYouCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NAME / PRONUNCIATION")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                TextField("e.g. Christopher", text: $preferences.phoneticInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
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

                    Text("正在取名中…")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .transition(.opacity)
        }
    }

    private var luckyButton: some View {
        Button {
            generate(random: true)
        } label: {
            Text("🎲 I'm Feeling Lucky")
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
        }
        .disabled(isLoading)
    }

    @ViewBuilder
    private var resultsSection: some View {
        if let errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Try Again") {
                    generate(random: isRandomMode)
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 32)
        } else if hasGenerated && candidates.isEmpty && !isLoading {
            Text("No names generated. Try different preferences.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.vertical, 32)
        } else if !candidates.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("RESULTS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .id("results")

                ForEach(candidates) { candidate in
                    Button {
                        selectedName = candidate
                        showDetail = true
                    } label: {
                        NameResultRow(
                            candidate: candidate,
                            surname: preferences.surname
                        )
                    }
                    .buttonStyle(.plain)
                }

                if isRandomMode {
                    Button("不喜欢？再摇一次 → 🎲") {
                        generate(random: true)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))
                } else {
                    Button("Generate More") {
                        generate(random: false)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }

    private func generate(random: Bool) {
        isLoading = true
        isRandomMode = random
        errorMessage = nil
        candidates = []

        Task {
            do {
                let result = try await NameGenieAPI.shared.generateNames(
                    preferences: preferences,
                    random: random
                )
                candidates = result
                hasGenerated = true
                scrollToResults = true
            } catch {
                errorMessage = "Unable to generate names. Please check your connection and try again."
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
    let surname: String

    @ObservedObject private var pronunciationService = PronunciationService.shared

    private var isPlayingThis: Bool {
        pronunciationService.isSpeaking && pronunciationService.currentHanzi == candidate.hanzi
    }

    private var displayName: String {
        surname.isEmpty ? candidate.hanzi : "\(surname)\(candidate.hanzi)"
    }

    private var displayPinyin: String {
        surname.isEmpty ? candidate.pinyin : "\(surname) \(candidate.pinyin)"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 22))
                    Text(displayPinyin)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(candidate.meaning)
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
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

import SwiftUI

struct GenerateView: View {
    @State private var preferences = GenerationPreferences()
    @State private var candidates: [NameCandidate] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hasGenerated = false
    @State private var selectedName: NameCandidate?
    @State private var showDetail = false
    @State private var isRandomMode = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    preferencesSection
                    generateButton
                    luckyButton
                    resultsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .refreshable {
                if !candidates.isEmpty {
                    generate(random: isRandomMode)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
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
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 72, height: 72)
                Text("取名")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentColor)
            }

            Text("Find Your Chinese Name")
                .font(.system(size: 17, weight: .medium))

            Text("Tell us about yourself and discover meaningful Chinese names")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }

    private var preferencesSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("GENDER")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                Picker("Gender", selection: $preferences.gender) {
                    ForEach(GenerationPreferences.Gender.allCases) { gender in
                        Text(gender.label).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NAME / PRONUNCIATION")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                TextField("e.g. Christopher", text: $preferences.phoneticInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("DESIRED MEANINGS")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 90), spacing: 8)],
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
                                .font(.system(size: 13))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    preferences.meanings.contains(tag)
                                        ? Color.accentColor
                                        : Color(.secondarySystemBackground)
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

            VStack(alignment: .leading, spacing: 8) {
                Text("CHARACTER COUNT")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                Picker("Count", selection: $preferences.characterCount) {
                    ForEach(GenerationPreferences.CharacterCount.allCases) { count in
                        Text(count.label).tag(count)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("SURNAME (OPTIONAL)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
                TextField("e.g. Wang, Li", text: $preferences.surname)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
        }
    }

    private var generateButton: some View {
        Button {
            generate(random: false)
        } label: {
            HStack(spacing: 8) {
                if isLoading && !isRandomMode {
                    ProgressView()
                        .tint(.white)
                }
                Text(isLoading && !isRandomMode ? "Generating..." : "Generate Names")
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 10))
        }
        .disabled(isLoading)
    }

    private var luckyButton: some View {
        Button {
            generate(random: true)
        } label: {
            HStack(spacing: 8) {
                if isLoading && isRandomMode {
                    ProgressView()
                }
                Text(isLoading && isRandomMode ? "Rolling..." : "🎲 I'm Feeling Lucky")
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
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
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)

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
            } catch {
                errorMessage = "Unable to generate names. Please check your connection and try again."
            }
            isLoading = false
        }
    }
}

struct NameResultRow: View {
    let candidate: NameCandidate
    let surname: String

    private var displayName: String {
        surname.isEmpty ? candidate.hanzi : "\(surname)\(candidate.hanzi)"
    }

    private var displayPinyin: String {
        surname.isEmpty ? candidate.pinyin : "\(surname) \(candidate.pinyin)"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.system(size: 24))
                Text(displayPinyin)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(candidate.meaning)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                Text(String(format: "%.0f%%", candidate.relevance * 100))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

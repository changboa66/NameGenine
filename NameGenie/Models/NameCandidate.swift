import Foundation

struct NameCandidate: Codable, Identifiable, Hashable {
    let hanzi: String
    let pinyin: String
    let meaning: String
    let relevance: Double

    var id: String { hanzi }

    var style: String? {
        ["Classic", "Modern", "Unique"].first { meaning.hasPrefix($0) }
    }

    var cleanMeaning: String {
        if let range = meaning.range(of: "—") ?? meaning.range(of: "-") {
            String(meaning[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else {
            meaning
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hanzi)
    }

    static func == (lhs: NameCandidate, rhs: NameCandidate) -> Bool {
        lhs.hanzi == rhs.hanzi
    }
}

struct GenerateResponse: Codable {
    let candidates: [NameCandidate]
}

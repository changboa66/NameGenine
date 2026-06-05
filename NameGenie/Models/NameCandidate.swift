import Foundation

struct NameCandidate: Codable, Identifiable, Hashable {
    let hanzi: String
    let pinyin: String
    let meaning: String
    let relevance: Double

    var id: String { hanzi }

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

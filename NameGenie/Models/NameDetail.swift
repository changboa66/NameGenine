import Foundation

struct NameDetail: Codable {
    let detail: DetailContent
}

struct DetailContent: Codable {
    let hanzi: String
    let pinyin: String
    let characterBreakdown: [CharacterBreakdown]
    let pronunciation: PronunciationInfo
    let culturalBackground: String
    let namesakes: [String]
}

struct CharacterBreakdown: Codable {
    let character: String
    let meaning: String
    let radical: String
    let strokeCount: Int
    let nameUsage: String
}

struct PronunciationInfo: Codable {
    let withTones: String
    let guideForLearners: String
}

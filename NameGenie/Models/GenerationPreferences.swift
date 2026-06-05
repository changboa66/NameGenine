import Foundation

struct GenerationPreferences {
    var gender: Gender = .neutral
    var phoneticInput: String = ""
    var meanings: Set<MeaningTag> = []
    var characterCount: CharacterCount = .two
    var surname: String = ""

    enum Gender: String, CaseIterable, Identifiable {
        case male, female, neutral

        var id: Self { self }

        var label: String {
            switch self {
            case .male: "Male"
            case .female: "Female"
            case .neutral: "Neutral"
            }
        }
    }

    enum CharacterCount: String, CaseIterable, Identifiable {
        case one = "1"
        case two = "2"

        var id: Self { self }

        var label: String {
            switch self {
            case .one: "Single character"
            case .two: "Two characters"
            }
        }
    }

    enum MeaningTag: String, CaseIterable, Identifiable {
        case wisdom = "智慧"
        case beauty = "美丽"
        case bravery = "勇敢"
        case prosperity = "繁荣"
        case kindness = "善良"
        case nature = "自然"
        case strength = "坚强"
        case talent = "才华"
        case harmony = "和谐"
        case joy = "快乐"

        var id: Self { self }

        var englishLabel: String {
            switch self {
            case .wisdom: "Wisdom"
            case .beauty: "Beauty"
            case .bravery: "Bravery"
            case .prosperity: "Prosperity"
            case .kindness: "Kindness"
            case .nature: "Nature"
            case .strength: "Strength"
            case .talent: "Talent"
            case .harmony: "Harmony"
            case .joy: "Joy"
            }
        }
    }
}

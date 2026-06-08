import SwiftUI

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
            case .male: "♂ Male"
            case .female: "♀ Female"
            case .neutral: "○ Neutral"
            }
        }
    }

    enum CharacterCount: String, CaseIterable, Identifiable {
        case one = "1"
        case two = "2"
        case three = "3"

        var id: Self { self }

        var label: String {
            switch self {
            case .one: "Single"
            case .two: "Double"
            case .three: "Triple"
            }
        }
    }

    enum MeaningTag: String, CaseIterable, Identifiable {
        case wisdom = "智慧"
        case beauty = "美丽"
        case bravery = "勇敢"
        case kindness = "善良"
        case nature = "自然"
        case strength = "坚强"
        case talent = "才华"
        case harmony = "和谐"
        case joy = "快乐"
        case prosperity = "繁荣"
        case elegance = "优雅"
        case virtue = "品德"
        case intelligence = "聪慧"
        case peace = "和平"

        case diligence = "勤奋"
        case integrity = "正直"
        case longevity = "长寿"
        case fortune = "福气"
        case ambition = "志向"

        var id: Self { self }

        var englishLabel: String {
            switch self {
            case .wisdom: "Wisdom"
            case .beauty: "Beauty"
            case .bravery: "Bravery"
            case .kindness: "Kindness"
            case .nature: "Nature"
            case .strength: "Strength"
            case .talent: "Talent"
            case .harmony: "Harmony"
            case .joy: "Joy"
            case .prosperity: "Wealth"
            case .elegance: "Elegance"
            case .virtue: "Virtue"
            case .intelligence: "Clever"
            case .peace: "Peace"
            case .diligence: "Diligence"
            case .integrity: "Integrity"
            case .longevity: "Eternal"
            case .fortune: "Fortune"
            case .ambition: "Ambition"
            }
        }

        var color: Color {
            switch self {
            case .wisdom: .orange
            case .beauty: .pink
            case .bravery: Color(red: 0.82, green: 0.18, blue: 0.18)
            case .kindness: .mint
            case .nature: .green
            case .strength: .brown
            case .talent: .purple
            case .harmony: .teal
            case .joy: .yellow
            case .prosperity: Color(red: 0.85, green: 0.65, blue: 0.0)
            case .elegance: Color(red: 0.75, green: 0.35, blue: 0.60)
            case .virtue: .indigo
            case .intelligence: .cyan
            case .peace: Color(red: 0.42, green: 0.72, blue: 0.54)
            case .diligence: Color(red: 0.54, green: 0.28, blue: 0.08)
            case .integrity: Color(red: 0.20, green: 0.50, blue: 0.45)
            case .longevity: Color(red: 0.92, green: 0.45, blue: 0.20)
            case .fortune: Color(red: 0.96, green: 0.76, blue: 0.05)
            case .ambition: Color(red: 0.50, green: 0.18, blue: 0.55)
            }
        }
    }
}

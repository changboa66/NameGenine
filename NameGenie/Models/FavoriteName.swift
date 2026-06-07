import Foundation
import SwiftData

@Model
final class FavoriteName {
    var hanzi: String
    var pinyin: String
    var meaning: String
    var detailData: Data?
    var createdAt: Date

    init(hanzi: String, pinyin: String, meaning: String, detailData: Data? = nil) {
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.meaning = meaning
        self.detailData = detailData
        self.createdAt = Date()
    }
}

enum DateGroup: Comparable {
    case today
    case yesterday
    case thisWeek
    case earlier

    var title: String {
        switch self {
        case .today: return "今天"
        case .yesterday: return "昨天"
        case .thisWeek: return "本周"
        case .earlier: return "更早"
        }
    }
}

extension Array where Element == FavoriteName {
    func groupedByDate() -> [(DateGroup, [FavoriteName])] {
        let calendar = Calendar.current
        var groups: [DateGroup: [FavoriteName]] = [:]

        for favorite in self {
            let group: DateGroup
            if calendar.isDateInToday(favorite.createdAt) {
                group = .today
            } else if calendar.isDateInYesterday(favorite.createdAt) {
                group = .yesterday
            } else if calendar.isDate(favorite.createdAt, equalTo: Date(), toGranularity: .weekOfYear) {
                group = .thisWeek
            } else {
                group = .earlier
            }
            groups[group, default: []].append(favorite)
        }

        return groups.sorted { $0.key < $1.key }
    }
}

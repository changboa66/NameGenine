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

@available(*, deprecated, message: "Use DayGroup with groupedByDay() instead")
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

struct DayGroup: Identifiable {
    let date: Date
    let items: [FavoriteName]

    var id: String {
        dateKey
    }

    var dateKey: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}

extension Array where Element == FavoriteName {
    func groupedByDay() -> [DayGroup] {
        let calendar = Calendar.current
        var groups: [String: [FavoriteName]] = [:]

        for favorite in self {
            let components = calendar.dateComponents([.year, .month, .day], from: favorite.createdAt)
            let key = String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
            groups[key, default: []].append(favorite)
        }

        return groups
            .compactMap { key, items in
                guard let date = calendar.date(from: DateComponents(
                    year: Int(key.prefix(4)),
                    month: Int(key.dropFirst(5).prefix(2)),
                    day: Int(key.suffix(2))
                )) else { return nil }
                return DayGroup(date: date, items: items)
            }
            .sorted { $0.date > $1.date }
    }

    @available(*, deprecated, message: "Use groupedByDay() instead")
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

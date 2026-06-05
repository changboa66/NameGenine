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

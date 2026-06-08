import Foundation

extension String {
    func formattedPinyin(hanziCount: Int) -> String {
        let parts = split(separator: " ").map(String.init)
        if parts.count == hanziCount { return self }
        let expanded = parts.flatMap { part in
            var current = ""
            var result: [String] = []
            for (i, ch) in part.enumerated() {
                if i > 0, ch.isUppercase, !current.isEmpty {
                    result.append(current)
                    current = String(ch)
                } else {
                    current.append(ch)
                }
            }
            if !current.isEmpty { result.append(current) }
            return result.isEmpty ? [part] : result
        }
        return expanded.joined(separator: " ")
    }
}

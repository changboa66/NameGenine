import Foundation

actor NameGenieAPI {
    static let shared = NameGenieAPI()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let deviceID: String

    private var resultCache: [String: [NameCandidate]] = [:]
    private var detailCache: [String: NameDetail] = [:]

    private init() {
        self.baseURL = "https://namegenie-worker.changboa66.workers.dev"
        self.deviceID = DeviceIDService.getDeviceID()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    private func makeRequest(body: [String: Any]) throws -> URLRequest {
        let httpBody = try JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
        request.httpBody = httpBody
        return request
    }

    func generateNames(preferences: GenerationPreferences, random: Bool = false) async throws -> [NameCandidate] {
        var body: [String: Any] = [
            "action": "generate",
            "gender": preferences.gender.rawValue,
            "characterCount": preferences.characterCount.rawValue,
        ]

        if random {
            body["random"] = true
        }

        if !preferences.phoneticInput.isEmpty {
            body["phoneticInput"] = preferences.phoneticInput
        }

        if !preferences.meanings.isEmpty {
            body["meanings"] = preferences.meanings.map { $0.rawValue }
        }

        if !preferences.surname.isEmpty {
            body["surname"] = preferences.surname
        }

        let cacheKey = cacheKey(for: body)
        if !random, let cached = resultCache[cacheKey] {
            return cached
        }

        let request = try makeRequest(body: body)

        let (data, _) = try await session.data(for: request)
        let response = try decoder.decode(GenerateResponse.self, from: data)

        if !random {
            resultCache[cacheKey] = response.candidates
            if resultCache.count > 5 {
                let keys = resultCache.keys
                if let oldest = keys.first {
                    resultCache.removeValue(forKey: oldest)
                }
            }
        }

        return response.candidates
    }

    func nameDetail(hanzi: String, pinyin: String) async throws -> NameDetail {
        let cacheKey = "\(hanzi)|\(pinyin)"
        if let cached = detailCache[cacheKey] {
            return cached
        }

        let body: [String: Any] = [
            "action": "detail",
            "hanzi": hanzi,
            "pinyin": pinyin,
        ]

        let request = try makeRequest(body: body)

        let (data, _) = try await session.data(for: request)
        let detail = try decoder.decode(NameDetail.self, from: data)

        detailCache[cacheKey] = detail
        return detail
    }

    private func cacheKey(for body: [String: Any]) -> String {
        let sortedKeys = body.keys.sorted()
        var components: [String] = []
        for key in sortedKeys {
            if let value = body[key] {
                components.append("\(key)=\(value)")
            }
        }
        return components.joined(separator: "&")
    }
}

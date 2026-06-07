import Foundation
import CryptoKit

actor NameGenieAPI {
    static let shared = NameGenieAPI()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let deviceID: String

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

    private let signingKey = "92e4b115a656575f8c8c8de59225a59688cd0731458ef23dc5ad0e8d1c484cee"

    private func makeRequest(body: [String: Any]) throws -> URLRequest {
        let httpBody = try JSONSerialization.data(withJSONObject: body)
        let timestamp = Int(Date().timeIntervalSince1970)
        let bodyHash = SHA256.hash(data: httpBody).compactMap { String(format: "%02x", $0) }.joined()
        let message = "POST\napplication/json\n\(bodyHash)"

        let key = SymmetricKey(data: Data(signingKey.utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        let signature = mac.compactMap { String(format: "%02x", $0) }.joined()

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
        request.setValue(signature, forHTTPHeaderField: "X-Signature")
        request.setValue(String(timestamp), forHTTPHeaderField: "X-Timestamp")
        request.httpBody = httpBody
        return request
    }

    func generateNames(preferences: GenerationPreferences) async throws -> [NameCandidate] {
        var body: [String: Any] = [
            "action": "generate",
            "random": true,
            "gender": preferences.gender.rawValue,
            "characterCount": preferences.characterCount.rawValue,
        ]

        if !preferences.phoneticInput.isEmpty {
            body["phoneticInput"] = preferences.phoneticInput
        }

        if !preferences.meanings.isEmpty {
            body["meanings"] = preferences.meanings.map { $0.rawValue }
        }

        if !preferences.surname.isEmpty {
            body["surname"] = preferences.surname
        }

        let request = try makeRequest(body: body)

        let (data, _) = try await session.data(for: request)
        return try decoder.decode(GenerateResponse.self, from: data).candidates
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
}

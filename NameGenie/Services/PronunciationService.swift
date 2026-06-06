import Foundation
import AVFAudio

class PronunciationService: NSObject, ObservableObject {
    static let shared = PronunciationService()

    @Published var isSpeaking = false
    @Published var currentHanzi: String?
    @Published var currentCharIndex: Int?

    private let synthesizer = AVSpeechSynthesizer()
    private var version = 0

    func speak(hanzi: String, pinyin: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        version += 1
        let currentVersion = version

        currentHanzi = hanzi
        isSpeaking = true
        currentCharIndex = 0

        let characters = Array(hanzi)

        for char in characters {
            let utterance = AVSpeechUtterance(string: String(char))
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
            utterance.rate = 0.3
            utterance.postUtteranceDelay = 0.25
            synthesizer.speak(utterance)
        }

        let fullUtterance = AVSpeechUtterance(string: hanzi)
        fullUtterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        fullUtterance.rate = 0.35
        synthesizer.speak(fullUtterance)

        let perCharDelay: TimeInterval = 0.7

        for i in 0..<characters.count {
            let delay = Double(i) * perCharDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self, version == currentVersion else { return }
                currentCharIndex = i
            }
        }

        let clearDelay = Double(characters.count) * perCharDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + clearDelay) { [weak self] in
            guard let self, version == currentVersion else { return }
            currentCharIndex = nil
        }

        let resetDelay = clearDelay + 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) { [weak self] in
            guard let self, version == currentVersion else { return }
            isSpeaking = false
            currentHanzi = nil
            currentCharIndex = nil
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        version += 1
        isSpeaking = false
        currentHanzi = nil
        currentCharIndex = nil
    }
}

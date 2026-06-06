import Foundation
import AVFAudio

class PronunciationService: NSObject, ObservableObject {
    static let shared = PronunciationService()

    @Published var isSpeaking = false
    @Published var currentHanzi: String?
    @Published var currentCharIndex: Int?

    private var synthesizer: AVSpeechSynthesizer
    private var version = 0

    override init() {
        synthesizer = AVSpeechSynthesizer()
        super.init()
    }

    func speak(hanzi: String, pinyin: String) {
        synthesizer.stopSpeaking(at: .immediate)

        let currentVersion = version + 1
        version = currentVersion
        let characters = Array(hanzi)

        let newSynthesizer = AVSpeechSynthesizer()
        synthesizer = newSynthesizer

        for char in characters {
            let utterance = AVSpeechUtterance(string: String(char))
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
            utterance.rate = 0.3
            utterance.postUtteranceDelay = 0.25
            newSynthesizer.speak(utterance)
        }

        let fullUtterance = AVSpeechUtterance(string: hanzi)
        fullUtterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        fullUtterance.rate = 0.35
        newSynthesizer.speak(fullUtterance)

        currentHanzi = hanzi
        isSpeaking = true
        currentCharIndex = 0

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

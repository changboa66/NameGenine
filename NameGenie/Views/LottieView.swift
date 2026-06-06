import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let isDotLottie: Bool

    init(
        _ name: String,
        loopMode: LottieLoopMode = .loop,
        isDotLottie: Bool = false
    ) {
        self.name = name
        self.loopMode = loopMode
        self.isDotLottie = isDotLottie
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animation: LottieAnimationView
        if isDotLottie {
            animation = LottieAnimationView(dotLottieName: name)
        } else {
            animation = LottieAnimationView(name: name)
        }
        animation.loopMode = loopMode
        animation.contentMode = .scaleAspectFit
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.play()

        container.addSubview(animation)

        NSLayoutConstraint.activate([
            animation.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animation.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animation.widthAnchor.constraint(equalTo: container.widthAnchor),
            animation.heightAnchor.constraint(equalTo: container.heightAnchor),
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PausedLottieView: UIViewRepresentable {
    let name: String
    let progress: CGFloat

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let animation: LottieAnimationView
        if name.hasSuffix(".lottie") {
            animation = LottieAnimationView(dotLottieName: name)
        } else {
            animation = LottieAnimationView(name: name)
        }
        animation.contentMode = .scaleAspectFit
        animation.currentProgress = progress
        animation.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animation)

        NSLayoutConstraint.activate([
            animation.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animation.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animation.widthAnchor.constraint(equalTo: container.widthAnchor),
            animation.heightAnchor.constraint(equalTo: container.heightAnchor),
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

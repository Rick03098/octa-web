import SwiftUI
import Lottie

struct LottieLoopView: UIViewRepresentable {
    let resourceName: String

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: resourceName)
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) { }
}

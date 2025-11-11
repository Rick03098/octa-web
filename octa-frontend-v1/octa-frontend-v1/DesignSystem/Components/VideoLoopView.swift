import SwiftUI
import AVFoundation

struct VideoLoopView: UIViewRepresentable {
    let resourceName: String
    let resourceExtension: String

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView(resourceName: resourceName, resourceExtension: resourceExtension)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) { }
}

final class PlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    init(resourceName: String, resourceExtension: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        if let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) {
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let player = AVQueuePlayer(playerItem: item)
            player.isMuted = true
            let looper = AVPlayerLooper(player: player, templateItem: item)
            self.queuePlayer = player
            self.looper = looper
            playerLayer.player = player
            player.play()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

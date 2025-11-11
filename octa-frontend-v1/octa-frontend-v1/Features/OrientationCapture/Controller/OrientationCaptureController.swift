import SwiftUI
import Combine

@MainActor
final class OrientationCaptureController: ObservableObject {
    @Published var currentAngle: Double = 0
    @Published var progress: Double = 0
    @Published var isCompleted = false

    private let monitor = OrientationMonitor()
    private let flowState: UserOnboardingFlowState
    var onFinished: (() -> Void)?

    init(flowState: UserOnboardingFlowState) {
        self.flowState = flowState
    }

    func start() {
        isCompleted = false
        progress = 0
        monitor.start(onAngleUpdate: { [weak self] angle, progress in
            self?.currentAngle = angle
            self?.progress = progress
        }, completion: { [weak self] angle in
            guard let self else { return }
            self.flowState.orientationDegrees = angle
            self.isCompleted = true
            self.progress = 1
            self.onFinished?()
            self.monitor.stop()
        })
    }

    func stop() {
        monitor.stop()
    }
}

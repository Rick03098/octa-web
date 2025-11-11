import SwiftUI
import Combine

@MainActor
final class CaptureCompleteController: ObservableObject {
    var onFinished: (() -> Void)?
    private var task: Task<Void, Never>?

    func startCountdown() {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            onFinished?()
        }
    }

    func cancel() {
        task?.cancel()
    }
}

//
//  CaptureCameraController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class CaptureCameraController: ObservableObject {
    var onBack: (() -> Void)?
    var onCompleted: (() -> Void)?

    func goBack() {
        onBack?()
    }

    func capture() {
        onCompleted?()
    }
}

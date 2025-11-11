//
//  CaptureTutorialController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class CaptureTutorialController: ObservableObject {
    var onBack: (() -> Void)?
    var onContinue: (() -> Void)?

    func goBack() {
        onBack?()
    }

    func continueFlow() {
        onContinue?()
    }
}

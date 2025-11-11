//
//  EnvironmentPreviewController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class EnvironmentPreviewController: ObservableObject {
    var onContinue: (() -> Void)?

    func continueFlow() {
        onContinue?()
    }
}

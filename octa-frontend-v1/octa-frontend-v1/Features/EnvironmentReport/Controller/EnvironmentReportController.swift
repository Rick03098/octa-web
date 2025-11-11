//
//  EnvironmentReportController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class EnvironmentReportController: ObservableObject {
    @Published private(set) var report: EnvironmentReport

    private let useCase: EnvironmentReportUseCase
    var onChat: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: EnvironmentReportUseCase) {
        self.useCase = useCase
        self.report = useCase.loadReport()
    }

    func goBack() {
        onBack?()
    }

    func openChat() {
        onChat?()
    }
}

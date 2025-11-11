//
//  NameEntryController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

/// 控制名字信息頁的輸入與提交流程。
@MainActor
final class NameEntryController: ObservableObject {
    @Published private(set) var state = NameEntryState()

    private let useCase: NameEntryUseCase
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: NameEntryUseCase) {
        self.useCase = useCase
    }

    func updateInput(_ value: String) {
        state.input = value
    }

    func submit() {
        guard state.isValid else { return }
        useCase.submit(name: state.input)
        onContinue?()
    }

    func goBack() {
        onBack?()
    }
}

//
//  BirthLocationInputController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class BirthLocationInputController: ObservableObject {
    @Published private(set) var state: BirthLocationInputState

    private let useCase: BirthLocationInputUseCase
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: BirthLocationInputUseCase, initialValue: String) {
        self.useCase = useCase
        self.state = BirthLocationInputState(initial: initialValue)
    }

    func updateInput(_ value: String) {
        state.input = value
    }

    func submit() {
        guard state.isValid else { return }
        useCase.submit(location: state.input)
        onContinue?()
    }

    func goBack() {
        onBack?()
    }
}

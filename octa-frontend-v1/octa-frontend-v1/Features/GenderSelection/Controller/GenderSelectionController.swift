//
//  GenderSelectionController.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import SwiftUI
import Combine

@MainActor
final class GenderSelectionController: ObservableObject {
    @Published private(set) var state: GenderSelectionState

    private let useCase: GenderSelectionUseCase
    var onContinue: (() -> Void)?
    var onBack: (() -> Void)?

    init(useCase: GenderSelectionUseCase, initial: UserGender?) {
        self.useCase = useCase
        self.state = GenderSelectionState(selectedGender: initial)
    }

    func select(_ gender: UserGender) {
        state.selectedGender = gender
    }

    func submit() {
        guard let gender = state.selectedGender else { return }
        useCase.submit(gender: gender)
        onContinue?()
    }

    func goBack() {
        onBack?()
    }
}
